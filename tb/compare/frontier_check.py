#!/usr/bin/env python3
"""Check noninterference and classify every traced empty event."""
import hashlib
import json
import sys
from pathlib import Path

root, old = map(Path, sys.argv[1:])
rows = [l.split() for l in (root/'observed.txt').read_text().splitlines()]
blind = [l.split() for l in (root/'blind.txt').read_text().splitlines()]
assert rows[-1][0] == blind[-1][0] == 'end'
assert rows[-1][1:5] == blind[-1][1:5], 'cycle/state/UART timing changed'
assert rows[-1][2] == '6', 'not cpu_Done'
a = (root/'observed-uart.txt').read_bytes()
b = (root/'blind-uart.txt').read_bytes()
assert a == b, 'UART bytes changed'
assert list(map(int, rows[-1][5:7]))[0] == int(rows[-1][6]), 'unconsumed publication'
# Distro simavr emits color/prefix text around UART, so compare the actual
# protocol result rows rather than claiming a byte/cycle identity across builds.
def results(text):
    return [l.strip() for l in text.replace('\r', '').splitlines()
            if l.startswith(('run ', 'hold', 'stack', 'done', 'timeout'))]
previous = results(old.read_text())
current = results(a.decode())
distro_differences = [dict(index=i, retained=old_row, pinned=new_row)
                      for i, (old_row, new_row) in enumerate(zip(previous, current))
                      if old_row != new_row]
assert len(current) == len(previous), 'different result row count'
assert [r for r in current if r.startswith('run ')] == [r for r in previous if r.startswith('run ')], 'ordinary/steep motion differs from retained distro-run'
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
               distro_motion_rows_identical=True,
               distro_other_row_differences=distro_differences,
               simulator_cycle_identity='observed versus blind only; distro cycle identity not asserted',
               empty_events=classified,
               limits=['planned endpoint is saved per published slot generation, not physical velocity',
                       'zero end classification alone does not identify sender versus estimator cause'])
(root/'classification.json').write_text(json.dumps(summary, indent=2))
for c in classified:
    print(json.dumps(c))
