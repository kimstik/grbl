#!/usr/bin/env python3
"""Bounded native selector controls; not AVR timing or tolerance certification."""
import argparse
import copy
import hashlib
import json
import math
import os
from pathlib import Path
import struct
import subprocess
import sys

SIGMA = .002
OPTIONS = ('-DBEZIER_SIGMA=settings.arc_tolerance -DBEZIER_Z_LINEAR=3 '
           '-DBEZIER_Z_LOOSE -DBEZIER_EXACT_INVERSE_TIME -DTB_ARC_TOLERANCE=.002f')
EXTRA = {
    'baseline': '',
    'refill': '-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL',
    'seed': '-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_Z_SEED',
    'select': '-DBEZIER_Z_FIXED -DBEZIER_Z_REFILL -DBEZIER_Z_SELECT',
}
HERE = Path(__file__).resolve().parent


def require(ok, message):
    if not ok:
        raise AssertionError(message)


def floats(words):
    return struct.unpack('<' + 'f' * len(words), struct.pack('<' + 'I' * len(words), *words))


def words(fields, count):
    require(len(fields) == count, 'field count')
    result = tuple(map(int, fields))
    require(all(0 <= x <= 0xffffffff for x in result), 'word range')
    return result


def decode(text, commands, mode):
    curves, current = [], None
    for line in text.splitlines():
        fields = line.split()
        require(bool(fields), 'empty record')
        tag, values = fields[0], fields[1:]
        if tag == 'line':
            require(current is None, 'missing end')
            current = {'command': line[5:], 'raw': []}
        else:
            require(current is not None, 'record outside curve')
            if tag in ('start', 'net'):
                require(tag not in current and not current['raw'], 'duplicate or late header')
                current[tag] = words(values, 3 if tag == 'start' else 12)
                require(all(math.isfinite(x) for x in floats(current[tag])), 'nonfinite header')
            elif tag == 'p':
                require('start' in current and 'net' in current, 'missing header')
                point = words(values, 5)
                require(point[4] <= 255, 'condition range')
                xyzw = floats(point[:4])
                require(all(math.isfinite(x) for x in xyzw), 'nonfinite target')
                require(xyzw[3] > 0, 'nonpositive feed')
                current['raw'].append(point)
            elif tag == 'end':
                summary = words(values, 12)
                raw = current['raw']
                require('start' in current and 'net' in current and bool(raw), 'empty curve')
                require(summary[:3] == (0, len(raw), 1), 'status/count/parse')
                require(all(x <= 65535 for x in summary[3:9]), 'trace counter range')
                require(all(math.isfinite(x) for x in floats(summary[9:])), 'nonfinite trace')
                require(raw[-1][:3] == current['net'][9:12], 'endpoint bits')
                start = floats(current['start'])
                points = [floats(p[:4]) + (p[4],) for p in raw]
                xyz = [start] + [p[:3] for p in points]
                dz = xyz[-1][2] - start[2]
                low, high = sorted((start[2], xyz[-1][2]))
                require(all(low <= p[2] <= high for p in xyz), 'Z overshoot')
                require(all((b[2] - a[2]) * dz >= 0 for a, b in zip(xyz, xyz[1:])), 'Z reversal')
                chords = [math.dist(a[:2], b[:2]) for a, b in zip(xyz, xyz[1:])]
                length, travelled, error = math.fsum(chords), 0., 0.
                for chord, point in zip(chords, xyz[1:]):
                    travelled += chord
                    expected = start[2] + dz * travelled / length if length else xyz[-1][2]
                    error = max(error, abs(point[2] - expected))
                minutes = math.fsum((1. if b[4] & 8 else math.dist(a, b[:3])) / b[3]
                                   for a, b in zip(xyz, points))
                current.update(summary=summary, z_mm=error,
                               g93_relative=abs(minutes / .5 - 1.) if mode == 'G93' else None)
                curves.append(current)
                current = None
            else:
                raise AssertionError('unknown record: ' + tag)
    require(current is None, 'truncated curve')
    require([c['command'] for c in curves] == commands, 'command count/order')
    return curves


def identity(current, reference, xy_only=False, geometry_only=False, selected_eight=False):
    # SEED measures a half bracket; SELECT intentionally does not measure one.
    # Only that diagnostic differs for the eight-piece policy, never target/feed words.
    require(not selected_eight or not (xy_only or geometry_only), 'incompatible identity modes')
    require(len(current) == len(reference), 'identity curve count')
    fields = (0, 1) if geometry_only else ((0, 1, 3, 4) if xy_only else range(5))
    for a, b in zip(current, reference):
        require(a['command'] == b['command'] and a['start'] == b['start'] and a['net'] == b['net'],
                'identity input: ' + a['command'])
        require(len(a['raw']) == len(b['raw']), 'identity target count')
        require(all(tuple(x[k] for k in fields) == tuple(y[k] for k in fields)
                    for x, y in zip(a['raw'], b['raw'])), 'raw identity failed: ' + a['command'])
        indices = (0, 1, 2) if xy_only or geometry_only else range(11 if selected_eight else 12)
        require(all(a['summary'][k] == b['summary'][k] for k in indices),
                'trace identity failed: ' + a['command'])
        if selected_eight:
            require(a['summary'][11] == 0 and floats(b['summary'][11:])[0] >= 0.,
                    'selected-eight half diagnostic')


def controls():
    bits = lambda x: struct.unpack('<I', struct.pack('<f', x))[0]
    zero, one = bits(0.), bits(1.)
    command = 'G5X1Y0Z1I0J0P0Q0F2'
    rows = ['line ' + command, 'start 0 0 0',
            'net ' + ' '.join(map(str, (0,) * 9 + (one, zero, one))),
            'p ' + ' '.join(map(str, (one, zero, one, bits(2.), 0))),
            'end 0 1 1 1 0 0 0 1 0 0 0 0']
    text = '\n'.join(rows)
    reference = decode(text, [command], 'G94')
    identity(reference, reference)
    decode(text.replace(str(bits(2.)) + ' 0', str(bits(4.)) + ' 0'), [command], 'G94')
    negative = [
        ('truncation', '\n'.join(rows[:-1])),
        ('duplicate start', '\n'.join(rows[:2] + [rows[1]] + rows[2:])),
        ('unknown record', text + '\nwrong 0'),
        ('command order', text.replace('G5X1', 'G5X2')),
        ('bad word', text.replace('start 0 0 0', 'start -1 0 0')),
        ('bad fields', text.replace('start 0 0 0', 'start 0 0')),
        ('status', text.replace('end 0 1 1', 'end 1 1 1')),
        ('count', text.replace('end 0 1 1', 'end 0 2 1')),
        ('parse', text.replace('end 0 1 1', 'end 0 1 0')),
        ('endpoint', text.replace('p ' + str(one), 'p ' + str(bits(2.)))),
        ('nonfinite', text.replace(str(bits(2.)) + ' 0', str(0x7fc00000) + ' 0')),
        ('zero feed', text.replace(str(bits(2.)) + ' 0', '0 0')),
        ('bad condition', text.replace(str(bits(2.)) + ' 0', str(bits(2.)) + ' 256')),
        ('trace nonfinite', '\n'.join(rows[:-1] + ['end 0 1 1 1 0 0 0 1 0 2143289344 0 0'])),
    ]
    for name, damaged in negative:
        try:
            decode(damaged, [command], 'G94')
        except (AssertionError, ValueError):
            continue
        raise AssertionError('negative control accepted: ' + name)
    for name, field, xy_only in (('X', 0, False), ('Y', 1, True), ('Z', 2, False),
                                  ('feed', 3, True), ('condition', 4, True)):
        damaged = copy.deepcopy(reference)
        point = list(damaged[0]['raw'][0])
        point[field] += 1
        damaged[0]['raw'][0] = tuple(point)
        try:
            identity(damaged, reference, xy_only=xy_only)
        except AssertionError:
            continue
        raise AssertionError('identity control accepted: ' + name)
    for field in range(3, 12):
        damaged = copy.deepcopy(reference)
        summary = list(damaged[0]['summary'])
        summary[field] += 1
        damaged[0]['summary'] = tuple(summary)
        try:
            identity(damaged, reference)
        except AssertionError:
            continue
        raise AssertionError('trace control accepted: ' + str(field))
    permitted = copy.deepcopy(reference)
    permitted[0]['raw'][0] = (one, zero, zero, bits(2.), 0)
    identity(permitted, reference, xy_only=True)
    seed = copy.deepcopy(reference)
    seed[0]['summary'] = seed[0]['summary'][:11] + (one,)
    identity(reference, seed, selected_eight=True)
    for field in (3, 10, 11):
        damaged = copy.deepcopy(reference)
        summary = list(damaged[0]['summary'])
        summary[field] += 1
        damaged[0]['summary'] = tuple(summary)
        try:
            identity(damaged, seed, selected_eight=True)
        except AssertionError:
            continue
        raise AssertionError('selected-eight trace control accepted: ' + str(field))
    try:
        identity(reference, seed)
    except AssertionError:
        pass
    else:
        raise AssertionError('full identity ignored the half diagnostic')
    print('32 negative controls and two identity-mode positive controls: PASS')


def ordinary(mode):
    lines = []
    for size, dz in ((2, -.2), (5, -.2), (10, -30), (20, -10), (60, -30)):
        lines += ['G90G94G0X0Y0Z0', 'G91' + mode + ('G1F2' if mode == 'G93' else 'G1F5000')]
        h = size / 2
        for i in range(12 if size in (2, 5) else 3):
            handles = f'I{-h:g}J{h:g}' if i == 0 else ''
            feed = 'F2' if mode == 'G93' else ''
            lines.append(f'*G5{handles}P{h:g}Q{-h:g}Z{dz:g}X{-size:g}{feed}')
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for arm in EXTRA:
        parser.add_argument('--' + arm, required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--make', default='make')
    parser.add_argument('--cc', default='gcc')
    args = parser.parse_args()
    controls()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    temporary = out / 'tmp'
    temporary.mkdir()
    env = os.environ.copy()
    for name in ('TMP', 'TEMP', 'TMPDIR'):
        env[name] = str(temporary)
    priority = {'creationflags': subprocess.IDLE_PRIORITY_CLASS} if os.name == 'nt' else {}

    def run(command, log, cwd=HERE, seconds=120):
        proc = subprocess.run(list(map(str, command)), cwd=cwd, env=env, capture_output=True,
                              timeout=seconds, **priority)
        log.write_bytes(proc.stdout + proc.stderr)
        require(proc.returncode == 0, f'{log.name}: exit {proc.returncode}')
        return proc.stdout.decode('ascii')

    metrics = {'notice': 'Native integrity only; no AVR timing or tolerance certificate.',
               'sigma_mm': SIGMA, 'executable_sha256': {}, 'source_revision': {}, 'input_sha256': {}}
    executables = {}
    for arm, extra in EXTRA.items():
        source = getattr(args, arm).resolve()
        revision = run(['git', '-C', source, 'rev-parse', 'HEAD'], out / (arm + '-revision.txt')).strip()
        metrics['source_revision'][arm] = revision
        build = out / arm
        run([args.make, '-s', '-j1', 'GRBL=' + (source / 'grbl').as_posix(),
             'BUILD=' + build.as_posix(), 'CC=' + args.cc, 'OPT=' + OPTIONS + ' ' + extra,
             (build / 'select-emit').as_posix()], out / (arm + '-build.txt'), HERE.parent / 'host', 180)
        exe = build / ('select-emit.exe' if os.name == 'nt' else 'select-emit')
        executables[arm] = exe
        metrics['executable_sha256'][arm] = hashlib.sha256(exe.read_bytes()).hexdigest()
    for mode in ('G94', 'G93'):
        for corpus_name in ('ordinary', 'loose'):
            input_file = out / f'{corpus_name}-{mode}.in'
            if corpus_name == 'ordinary':
                input_file.write_text(ordinary(mode), encoding='ascii')
            else:
                run([sys.executable, '-I', HERE / 'render.py', HERE / 'loose.in', input_file,
                     '--mode', mode], out / f'render-{mode}.txt')
            text = input_file.read_text(encoding='ascii')
            require(all(len(line) < 80 for line in text.splitlines() if line and not line.startswith('#')),
                    'input line too long')
            commands = [line[1:] for line in text.splitlines() if line.startswith('*')]
            require(len(commands) == (33 if corpus_name == 'ordinary' else 18), 'input curve count')
            key = corpus_name + '/' + mode
            metrics['input_sha256'][key] = hashlib.sha256(input_file.read_bytes()).hexdigest()
            decoded = {}
            for arm, exe in executables.items():
                raw = run([exe, input_file], out / f'{arm}-{corpus_name}-{mode}.txt', out, 45)
                decoded[arm] = decode(raw, commands, mode)
                identity(decoded[arm], decoded['baseline'], xy_only=mode == 'G94', geometry_only=mode == 'G93')
                metrics[key + '/' + arm] = [
                    {k: c[k] for k in ('command', 'summary', 'z_mm', 'g93_relative')}
                    for c in decoded[arm]]
            if mode == 'G93':
                identity(decoded['select'], decoded['refill'])
            elif corpus_name == 'ordinary':
                identity(decoded['select'][:24], decoded['seed'][:24], selected_eight=True)
                identity(decoded['select'][24:], decoded['refill'][24:])
            else:
                identity(decoded['select'], decoded['refill'], xy_only=True)
            for arm, curves in decoded.items():
                error = max(c['z_mm'] for c in curves)
                over = sum(c['z_mm'] > SIGMA for c in curves)
                print(f'{key}/{arm}: {len(curves)} curves, raw max Z {error:.12g} mm, over .002: {over}')
            print(key + ': selector identity PASS')
    (out / 'metrics.json').write_text(json.dumps(metrics, indent=2) + '\n', encoding='ascii')
    print('Native controls PASS. AVR fit, latency, stops and exact G93 remain separate checks.')


if __name__ == '__main__':
    main()
