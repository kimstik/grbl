#!/usr/bin/env python3
"""Fail closed on incomplete or inconsistent generator-only simavr output."""
import argparse
from pathlib import Path


def check(text, expected=9, generator=None):
    rows = []
    calibration = []
    done = 0
    for raw in text.splitlines():
        line = raw.rstrip(".")
        if line.startswith("calib "):
            calibration.append(int(line.split()[1]))
        elif line.startswith("case "):
            row = list(map(int, line.split()[1:]))
            if len(row) != 11:
                raise ValueError(f"wrong micro field count: {line}")
            rows.append(row)
        elif line == "done":
            done += 1
    if len(calibration) != 1 or not 1_000_000 <= calibration[0] <= 1_001_000:
        raise ValueError(f"cycle calibration failed: {calibration}")
    if done != 1 or len(rows) != expected:
        raise ValueError(f"incomplete micro run: done={done}, cases={len(rows)}, expected={expected}")
    for k, row in enumerate(rows):
        case, status, chords, total, dry, first, gap, hash_value, exact, realtime, spare = row
        if case != k or total <= 0 or not 0 <= dry <= total or realtime <= 0 or spare <= 0:
            raise ValueError(f"invalid timing/state: {row}")
        cap = generator == "circle" and k == 8 and expected == 9
        if cap:
            if status != 38 or chords != 0 or exact != 0 or first != 0:
                raise ValueError(f"cap policy changed: {row}")
        elif status != 0 or chords <= 0 or exact != 1 or not 0 < first <= total or not 0 <= gap <= total or hash_value == 0:
            raise ValueError(f"bad accepted case: {row}")
    return rows


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--generator", choices=("circle", "wang"), required=True)
    args = parser.parse_args()
    rows = check(args.output.read_text(), generator=args.generator)
    print(f"micro assertions: {len(rows)} cases passed ({args.generator}); isolated cost only")
