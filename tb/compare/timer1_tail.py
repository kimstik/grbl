"""Frozen exact-image gates and one matched diagnostic; preserve conservative failures."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys

HASHES = {'off': '0e747a0c99cea41fe033ac93920de5a6a2ad2cc540b1ceedd8848c0d75ca8c11',
          'on': 'ac24b27b9048ba95073a1eafa798c23793c3ca22eb56511d9db2c6171c6d6961'}

def fields(s):
    return dict(re.findall(r'(\w+)=([^ ]+)', s))

def one(lines, prefix):
    values = [s for s in lines if s.startswith(prefix)]
    assert len(values) == 1, (prefix, len(values))
    return values[0]

if sys.argv[1] == 'prepare':
    src, out = map(Path, sys.argv[2:])
    out.mkdir(exist_ok=True)
    images = {}
    for arm in ('off', 'on'):
        p = src / arm / 'main.elf'
        sha = hashlib.sha256(p.read_bytes()).hexdigest()
        assert sha == HASHES[arm], (arm, sha)
        size = subprocess.check_output(['avr-size', str(p)], text=True)
        a, b, c = map(int, size.splitlines()[1].split()[:3])
        assert a + b <= 32256 and a + b <= 32768 and b + c == 1670
        assert a + b == (32074 if arm == 'off' else 32076)
        text = subprocess.check_output(['avr-objdump', '-d', str(p)], text=True)
        ins = {}
        for line in text.splitlines():
            m = re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} ){1,4})', line)
            if m:
                ins[int(m[1], 16)] = bytes.fromhex(m[2])
        for pc, raw in ((0x1f00, 'a6e3'), (0x1ae2, 'ace0'), (0x3e82, 'a4e0'),
                        (0x3eb6, '0e94710d'), (0x2d52, '10ff'), (0x2d56, '8ce0'),
                        (0x6e08, '2093')):
            assert ins[pc].startswith(bytes.fromhex(raw)), (arm, hex(pc), ins[pc])
        assert ins[0x715a] == bytes.fromhex('f894' if arm == 'on' else '10928c01')
        assert ins[0x71a4 if arm == 'on' else 0x71a2] == bytes.fromhex('1895')
        shutil.copyfile(p, out / f'{arm}.elf')
        (out / f'{arm}-disassembly.txt').write_text(text)
        images[arm] = {'sha256': sha, 'flash': a+b, 'ram': b+c}
    (out / 'images.json').write_text(json.dumps(images, indent=2))
else:
    root = Path(sys.argv[2])
    results = {}
    errors = []
    for arm in ('off', 'on'):
        traces = [(root / f'{arm}-{mode}.trace').read_text().splitlines() for mode in ('observed', 'blind')]
        metrics = [(root / f'{arm}-{mode}.metrics').read_text().splitlines() for mode in ('observed', 'blind')]
        parity = all((root / f'{arm}-observed.{s}').read_bytes() == (root / f'{arm}-blind.{s}').read_bytes()
                     for s in ('events', 'uart', 'metrics'))
        if any(not any(s.startswith('end ') for s in t) for t in traces):
            results[arm] = {'classification': 'aborted harness; no completed firmware verdict',
                            'prefix_parity': parity,
                            'logs': [(root / f'{arm}-{mode}.log').read_text() for mode in ('observed', 'blind')]}
            errors.append(arm + ': harness aborted before completion')
            continue
        end = [one(t, 'end ') for t in traces]
        parity = parity and end[0].split(' raw=')[0] == end[1].split(' raw=')[0]
        timer = fields(one(traces[0], 'timer '))
        cal = fields(one(traces[0], 'calibration '))
        known = all(timer[k] == '0' for k in ('missed', 'near', 'equal', 'boundary', 'prescaler_changes')) and timer['initial_start'] == '1' and not any(s.startswith('ocr1a stopped') for s in traces[0])
        statuses = [s for s in (root / f'{arm}-observed.uart').read_text().splitlines() if s.startswith('<')]
        good = parity and 'state=0' in end[0] and 'commands=22 acks=22' in end[0] and cal['unknown'] == '0' and cal['generations'] == cal['returns'] == '4' and cal['active'] == '0' and cal['udr'] == cal['status'] == '1' and len(statuses) == 1
        axes = [s for s in metrics[0] if s.startswith('axis ')]
        good = good and len(axes) == 3 and all('signed='+str(n) in axes[i].split() for i, n in enumerate((10000, 0, -7500)))
        anchor = one(traces[0], 'anchor ')
        vectors = [s for s in metrics[0] if s.startswith('vector ') and 'vector=4 ' in s]
        tails = [s for s in metrics[0] if s.startswith('tail-return ')]
        results[arm] = {'parity': parity, 'functional_gates': good, 'timer': timer,
                        'known_hazards_not_observed': known, 'end': end[0],
                        'calibration': cal, 'anchor': anchor, 'status': statuses, 'axes': axes,
                        'configuration': one(metrics[0], 'configuration '),
                        'nesting': one(metrics[0], 'nest '), 'tail': tails, 'pcint_vectors': vectors,
                        'latency_events': [s for s in metrics[0] if s.startswith(('control-', 'status-'))]}
        if not good:
            errors.append(arm + ': functional/parity gate failed')
        if not known:
            errors.append(arm + ': known timer hazard or ambiguity observed')
    results['cross_motion_edges_equal'] = [re.sub(r'^pin \d+ ', '', s) for s in (root/'off-observed.metrics').read_text().splitlines() if s.startswith('pin ')] == [re.sub(r'^pin \d+ ', '', s) for s in (root/'on-observed.metrics').read_text().splitlines() if s.startswith('pin ')]
    if not results['cross_motion_edges_equal']:
        errors.append('cross-firmware step/direction edge sequence mismatch')
    results['errors'] = errors
    (root / 'paired-result.json').write_text(json.dumps(results, indent=2)+'\n')
    print(json.dumps(results, indent=2))
    assert not errors, '; '.join(errors)
