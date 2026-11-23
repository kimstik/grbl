#!/usr/bin/env python3
"""Check the complete reduced TB_DYN_SPLINES_ONLY sweep, not just its footer."""
import itertools
import sys
from pathlib import Path

rows = Path(sys.argv[1]).read_text().splitlines()
runs = [s.split() for s in rows if s.startswith('run ')]
holds = [s.split() for s in rows if s.startswith('hold ')]
want = set(itertools.product((2000, 5000), (1000, 2000, 3000, 4000, 5000), (500, 2000), (2, 16)))
seen = set()
for row in runs:
    assert len(row) == 21, f'run fields: {row}'
    assert row[1] == 'G5', f'not a spline: {row}'
    key = tuple(map(int, row[2:6]))
    assert key in want and key not in seen, f'duplicate or wrong program: {row}'
    seen.add(key)
    assert int(row[6]) > 0 and int(row[8]) > 0, f'no motion: {row}'
    assert list(map(int, row[17:20])) == [0, 0, 0], f'XYZ endpoint: {row}'
assert seen == want, f'missing programs: {want - seen}'
assert len(holds) == 6, f'hold count {len(holds)}'
assert {int(r[1]) for r in holds} == {60, 150, 333, 500, 777, 1000}, 'hold delays'
for row in holds:
    assert len(row) == 11, f'hold fields: {row}'
    assert list(map(int, row[6:9])) == [0, 0, 0], f'hold XYZ endpoint: {row}'
assert 'done' in rows and not any('timeout' in s for s in rows), 'missing done or timeout'
stack = [s.split() for s in rows if s.startswith('stack ')]
assert len(stack) == 1 and len(stack[0]) == 3, 'stack footer'
print(f'dyn: {len(runs)} G5 programs, {len(holds)} holds, XYZ exact; stack {stack[0][1]} bytes')
