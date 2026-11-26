#!/usr/bin/env python3
"""Check noninterference and classify every traced empty event."""
import hashlib
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
rows = [l.split() for l in (root/'observed.txt').read_text().splitlines()]
blind = [l.split() for l in (root/'blind.txt').read_text().splitlines()]
assert rows[-1][0] == blind[-1][0] == 'end'
assert rows[-1][1:5] == blind[-1][1:5], 'cycle/state/UART timing changed'
assert rows[-1][2] == '6', 'not cpu_Done'
a = (root/'observed-uart.txt').read_bytes()
b = (root/'blind-uart.txt').read_bytes()
assert a == b, 'UART bytes changed'
assert list(map(int, rows[-1][5:7]))[0] == int(rows[-1][6]), 'unconsumed publication'
current = a.decode().replace('\r', '').splitlines()
assert current.count('done') == 1 and not any('timeout' in r for r in current)
runs = [r.split() for r in current if r.startswith('run ')]
assert len(runs) == 4 and all(len(r) == 21 for r in runs)
assert [tuple(map(int,r[2:6])) for r in runs] == [(5000,4000,2000,2),(5000,4000,2000,16),(5000,5000,2000,2),(5000,5000,2000,16)]
assert all(r[1] == 'G5' and list(map(int,r[17:20])) == [0,0,0] for r in runs)
assert list(map(int,blind[-1][5:])) == [0,0,0]
published = {}
consumed = {}
last = {}
classified = []
for row in rows:
    if row[0] == 'publish':
        cycle, program, slot, gen, line = map(int, row[1:6])
        key = (program, slot, gen)
        assert key not in published
        published[key] = row
    elif row[0] == 'consume':
        cycle, program, slot, gen = map(int, row[1:5])
        key = (program, slot, gen)
        assert key in published and key not in consumed
        assert float(row[5]) == float(published[key][6])
        consumed[key] = row
        last[program] = key
    elif row[0] == 'empty':
        cycle, program, line, point, queued, head, tail = map(int, row[1:8])
        key = last[program]
        pub = published[key]
        speed = float(row[8])
        assert speed == float(pub[6]) and int(row[10]) == int(pub[1])
        assert float(row[9]) == float(pub[7]) and head == tail
        assert not any(k[0] == program and k not in consumed for k in published)
        classified.append(dict(cycle=cycle, program=program, line=line,
                               point=point, queued_at_empty=queued,
                               consumed_slot=key[1], consumed_generation=key[2],
                               publication_cycle=int(pub[1]), planned_end_speed=speed,
                               planned_block_exit=float(row[9]),
                               category='nonzero-publication-starvation' if speed > 0 else 'planned-zero-end',
                               interrupted_pc=row[14]))
assert {c['program'] for c in classified} == {37,38,39,40}
summary = dict(observed_end=rows[-1], blind_end=blind[-1],
               uart_sha256=hashlib.sha256(a).hexdigest(),
               motion_rows=runs,
               intermediate_empty_counts={p:sum(c['program']==p for c in classified)-1 for p in (37,38,39,40)},
               simulator_cycle_identity='observed versus blind only; isolated p37-p40 start, not full-sweep identity',
               empty_events=classified,
               limits=['planned endpoint is saved per published slot generation, not physical velocity',
                       'zero end classification alone does not identify sender versus estimator cause'])
(root/'classification.json').write_text(json.dumps(summary, indent=2))
for c in classified:
    print(json.dumps(c))
