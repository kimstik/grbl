"""Bounded fixed24/local-length comparison; distinct chord and spatial oracles."""
import json
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from bounded import decode, timed, metrics, control

root = Path(sys.argv[1])
mode = sys.argv[2]
assert mode in ('g94', 'g93')
names = ('short_s', 'long_s', 'translated_line', 'origin_line', 'no_z', 'near_cusp')
results = {}
groups = {}
for arm in ('control', 'candidate'):
    path = root/arm
    for image in ('bench', 'dump'):
        text = re.sub(r'\x1b\[[0-9;]*m', '', (path/(image+'-simavr.txt')).read_text())
        text = '\n'.join(line.rstrip('.') for line in text.splitlines())+'\n'
        (path/(image+'.txt')).write_text(text)
        assert text.splitlines().count('done') == 1
    rows, untouched = timed(path/'bench.txt', expected=6)
    gs = decode(path/'dump.txt')
    assert len(gs) == 6 and len(rows) == 6
    groups[arm] = gs
    results[arm] = []
    for g, name in zip(gs, names):
        t = rows[g['command']]
        s = g['summary']
        assert t[0:2] == s[0:2] and t[7:10] == s[7:10]
        m = metrics(g, name, mode)
        m.update(first_cycles=t[5], first_ms=t[5]/16000, gap_cycles=t[6], generation_cycles=t[4])
        results[arm].append(m)
for i, (a, b) in enumerate(zip(groups['control'], groups['candidate'])):
    assert a['command'] == b['command'] and a['start'] == b['start']
    assert len(a['words']) == len(b['words'])
    assert all(x[:2] == y[:2] and x[4] == y[4] for x, y in zip(a['words'], b['words'])), names[i]
    assert a['words'][-1][:3] == b['words'][-1][:3]
    if mode == 'g94':
        assert all(x[3] == y[3] for x, y in zip(a['words'], b['words']))
        if names[i] == 'no_z':
            assert a['words'] == b['words']
            assert a['summary'][:2]+a['summary'][7:] == b['summary'][:2]+b['summary'][7:]
print(json.dumps(dict(mode=mode, xy_identity=True, results=results,
    semantics='chord_z uses emitted absolute XY chords; true_line_3d uses exact intended straight geometry; G93 time uses emitted 3D segments and raw converted feeds; no general smooth-3D S certificate'), indent=2))
