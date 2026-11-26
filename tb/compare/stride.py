"""Compare complete raw targets and trace counters; report non-dump cycle deltas."""
import json
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])

def read(path, dump):
    text = re.sub(r'\x1b\[[0-9;]*m', '', path.read_text())
    rows, current = [], None
    calibration = False
    for line in text.splitlines():
        line = line.rstrip('.')
        words = line.split()
        if not words:
            continue
        if words[0] == 'calib':
            assert 1000000 <= int(words[1]) <= 1001000
            calibration = True
        if words[0].startswith('G5'):
            current = {'command': words[0], 'points': []}
            rows.append(current)
            if len(words) > 1:
                current['summary'] = list(map(int, words[1:]))
        elif words[0] == 'p':
            assert current is not None
            point = list(map(int, words[1:]))
            assert len(point) == 5
            current['points'].append(point)
        elif dump and current is not None and words[0].isdigit():
            current['summary'] = list(map(int, words))
    assert calibration and len(rows) == 6 and 'done' in text
    for row in rows:
        s = row['summary']
        assert len(s) == (18 if dump else 10), s
        assert s[0] == 0 and s[1] > 0 and s[7] == 1 and s[8] == 0
        if dump:
            assert len(row['points']) == s[1]
    return rows

control = read(root/'control/dump-simavr.txt', True)
candidate = read(root/'candidate/dump-simavr.txt', True)
a = read(root/'control/bench-simavr.txt', False)
b = read(root/'candidate/bench-simavr.txt', False)
result = []
for x, y, ta, tb in zip(control, candidate, a, b):
    assert x['command'] == y['command'] == ta['command'] == tb['command']
    assert x['points'] == y['points'], x['command']
    # Only timing fields differ. Preserve status/count/end/hash/all estimator counters.
    assert x['summary'][:2] + x['summary'][7:] == y['summary'][:2] + y['summary'][7:]
    sa, sb = ta['summary'], tb['summary']
    assert sa[:2] + sa[7:] == sb[:2] + sb[7:]
    result.append(dict(command=x['command'], segments=sa[1],
                       first_control_cycles=sa[5], first_candidate_cycles=sb[5],
                       first_saved_cycles=sa[5]-sb[5],
                       generation_saved_cycles=sa[4]-sb[4],
                       gap_control_cycles=sa[6], gap_candidate_cycles=sb[6],
                       trace=x['summary'][10:16]))
print(json.dumps({'raw_identity': True, 'cases': result}, indent=2))
