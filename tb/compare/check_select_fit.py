#!/usr/bin/env python3
"""Fail acceptance for overflow, even when a static-inspection ELF was produced."""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('root', type=Path)
parser.add_argument('--mode', choices=('g94', 'g93'))
parser.add_argument('--family', choices=('selector', 'parser'), default='selector')
args = parser.parse_args()

for mode in (args.mode,) if args.mode else ('g94', 'g93'):
    path = args.root / (args.family + '-' + mode) / 'sizes.txt'
    rows = [line.split() for line in path.read_text().splitlines()[1:]]
    candidate = 'select' if args.family == 'selector' else 'scratch'
    row, = [row for row in rows if row[0] == candidate and row[1] == mode]
    flash, ram, free, boot, full = map(int, row[2:7])
    assert free == 2048 - ram and boot == 32256 - flash and full == 32768 - flash
    print(f'{mode}: flash={flash}, RAM={ram}, boot margin={boot}, full margin={full}, normal link={row[7]}', flush=True)
    assert row[7] == 'yes' and flash <= 32256, args.family + ' exceeds ATmega328P boot flash region'
