#!/usr/bin/env python3
"""Check headless timing/dump integrity; tolerance excess is reported elsewhere."""
import argparse
import json
import re
from pathlib import Path


def clean(path):
    return [re.sub(r"\x1b\[[0-9;]*m", "", line).rstrip(".\r\n")
            for line in path.read_text().splitlines()]


def bench(lines, commands, hostile):
    assert lines.count("done") == 1, "missing or duplicate done"
    calibration = [int(line.split()[1]) for line in lines if line.startswith("calib ")]
    assert len(calibration) == 1 and 1000000 <= calibration[0] <= 1001000, "Timer1 calibration"
    rows = []
    for line in lines:
        match = re.fullmatch(r"(G\S+)\s+((?:\d+\s+){9}\d+)", line)
        if match:
            rows.append((match[1], list(map(int, match[2].split()))))
    assert [row[0] for row in rows] == commands, "measured command order/count"
    for command, row in rows:
        assert row[0] == 0 and row[1] > 0, f"status or no targets: {command} {row}"
        assert row[2] - row[3] == row[4], f"cycle accounting: {command}"
        if hostile and command == "G5X10Y0I1000000000000000000000000000000000000000J0P1Q1":
            # This existing parser probe deliberately overflows a literal. It is
            # not a finite-curve success and is never part of the accuracy corpus.
            assert row[8] > 0, "overflow probe unexpectedly finite"
        else:
            assert row[7] == 1 and row[8] == 0, f"end/nonfinite: {command} {row}"
    return rows


def dump(lines, commands, *, include_points=False):
    assert lines.count("done") == 1, "missing or duplicate dump done"
    groups, cursor = [], 0
    for command in commands:
        while cursor < len(lines) and lines[cursor] != command:
            cursor += 1
        assert cursor < len(lines), f"dump command missing: {command}"
        cursor += 1
        points = []
        while cursor < len(lines) and lines[cursor].startswith("p "):
            point = list(map(int, lines[cursor].split()[1:]))
            assert len(point) == 5 and all(0 <= value < 2**32 for value in point), "point fields"
            points.append(point)
            cursor += 1
        assert cursor < len(lines), f"dump summary missing: {command}"
        summary = list(map(int, lines[cursor].split()))
        assert len(summary) in (10, 18), f"dump summary fields: {command}"
        assert summary[1] == len(points), f"dump target count: {command}"
        value = 2166136261
        for point in points:
            for word in point[:3]:
                for shift in (0, 8, 16, 24):
                    value = ((value ^ ((word >> shift) & 255)) * 16777619) & 0xffffffff
        assert summary[9] == value, f"dump hash: {command}"
        groups.append((points, summary) if include_points else summary)
        cursor += 1
    return groups


def identity(groups, reference, commands, xy_only=False):
    """Exclude only Z and estimator trace when a policy may change them."""
    assert len(groups) == len(reference) == len(commands), "identity command count"
    errors = []
    for command, (points, summary), (old, old_summary) in zip(commands, groups, reference):
        if len(points) != len(old):
            errors.append(f"{command}: target count {len(old)} -> {len(points)}")
            continue
        fields = (0, 1, 3, 4) if xy_only else range(5)
        for field in fields:
            changed = [i for i, (a, b) in enumerate(zip(old, points), 1) if a[field] != b[field]]
            if changed:
                i = changed[0]
                name = ("X", "Y", "Z", "feed", "condition")[field]
                errors.append(f"{command}: {name} differs at {len(changed)} targets; "
                              f"first {i}: {old[i-1][field]} -> {points[i-1][field]}")
        if [summary[i] for i in (0, 1, 7, 8)] != [old_summary[i] for i in (0, 1, 7, 8)]:
            errors.append(f"{command}: status/count/end/nonfinite differs")
        if not xy_only and summary[10:] != old_summary[10:]:
            errors.append(f"{command}: estimator trace differs")
    assert not errors, "raw identity failed:\n" + "\n".join(errors)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lines", type=Path)
    parser.add_argument("bench", type=Path)
    parser.add_argument("--dump", type=Path)
    parser.add_argument("--reference", type=Path, help="raw dump whose outputs must be preserved")
    parser.add_argument("--xy-only", action="store_true", help="exclude Z and estimator trace, not feed")
    parser.add_argument("--hostile", action="store_true")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.reference and not args.dump:
        parser.error("--reference requires --dump")
    if args.xy_only and not args.reference:
        parser.error("--xy-only requires --reference")
    commands = [line[1:] for line in args.lines.read_text().splitlines() if line.startswith("*")]
    assert commands, "empty corpus"
    rows = bench(clean(args.bench), commands, args.hostile)
    groups = dump(clean(args.dump), commands, include_points=True) if args.dump else []
    summaries = [summary for _, summary in groups] if groups else [None] * len(rows)
    metrics = []
    for (command, row), summary in zip(rows, summaries):
        if summary is not None:
            # Neither headless image runs the stepper. In the scheduling arm the
            # reserve getter is false, so the UART must not select another policy.
            assert [row[i] for i in (0, 1, 7, 8, 9)] == [summary[i] for i in (0, 1, 7, 8, 9)], f"timed/dump targets differ: {command}"
        result = dict(command=command, segments=row[1], total_ms=row[2]/16000,
                      planner_ms=row[3]/16000, generator_ms=row[4]/16000,
                      first_ms=row[5]/16000, gap_ms=row[6]/16000, hash=row[9])
        if summary is not None and len(summary) == 18:
            result["trace"] = summary[10:]
        metrics.append(result)
    if args.output:
        args.output.write_text(json.dumps(metrics, indent=2) + "\n")
    print(f"bench: {len(rows)} commands, calibration/end/finite/accounting checked" +
          (", raw dump hashes and timed/dump targets agree" if args.dump else ""))
    if args.reference:
        reference = dump(clean(args.reference), commands, include_points=True)
        identity(groups, reference, commands, args.xy_only)
        fields = "XY/feed/condition" if args.xy_only else "XYZ/feed/condition/trace"
        print(f"raw identity: {len(groups)} commands, {fields} identical")


if __name__ == "__main__":
    main()
