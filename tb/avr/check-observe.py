#!/usr/bin/env python3
"""Validate completed observe.elf logs, optionally requiring a positive control.

Usage: python3 check-observe.py LOG [--expect-moving]
The default checks structure/final step positions without assuming that an
algorithm has no starvation. --expect-moving is for the injected-stall control.
"""
import argparse
import pathlib
import re
import sys


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", nargs="?")
    parser.add_argument("--expect-moving", action="store_true")
    parser.add_argument("--no-moving", action="store_true")
    parser.add_argument("--programs", type=int, help="require exactly this many programs")
    parser.add_argument("--self-test", action="store_true", help="exercise malformed and rendered logs")
    args = parser.parse_args(argv)
    if args.self_test:
        self_test()
        return
    if args.log is None:
        parser.error("LOG is required unless --self-test is used")
    if args.expect_moving and args.no_moving:
        parser.error("moving expectations conflict")
    text = pathlib.Path(args.log).read_text(encoding="utf-8", errors="replace")
    text = re.sub(r"\x1b\[[0-9;]*m", "", text)
    runs = []
    rows = []
    done = False
    for line in text.splitlines():
        # simavr's UART renderer uses one dot for LF on Windows, two for CRLF
        # on Linux. All fields here are integers, so stripping the dots is safe.
        line = line.strip().rstrip(".")
        if line == "timeout":
            raise SystemExit("FAIL: simulated program timed out")
        if line == "done":
            done = True
        fields = line.split()
        if fields and fields[0] == "run":
            if len(fields) != 20:
                raise SystemExit("FAIL: unexpected run columns: " + line)
            if int(fields[-3]) or int(fields[-2]):
                raise SystemExit("FAIL: final XY step mismatch: " + line)
            runs.append(fields)
        if fields and fields[0] == "hold":
            if len(fields) != 11 or any(int(v) for v in fields[6:9]):
                raise SystemExit("FAIL: final hold XYZ step mismatch/format: " + line)
            runs.append(fields)
        if fields and fields[0] == "observe":
            if len(fields) != 8:
                raise SystemExit("FAIL: unexpected observe columns: " + line)
            row = list(map(int, fields[1:]))
            program, empty, queued, moving, max_milli, cycles, amass = row
            if program != len(rows) + 1 or empty < 1:
                raise SystemExit("FAIL: missing or unordered ISR shutdown records: " + line)
            if min(empty, queued, moving, max_milli, cycles, amass) < 0 or queued > empty or moving > empty or not 0 <= amass <= 3:
                raise SystemExit("FAIL: inconsistent ISR counters: " + line)
            if (not moving and max_milli) or (moving and cycles == 0):
                raise SystemExit("FAIL: inconsistent moving-exit snapshot: " + line)
            rows.append(row)
    if not done or not rows or len(rows) != len(runs):
        raise SystemExit("FAIL: incomplete observation log")
    if args.programs is not None and len(rows) != args.programs:
        raise SystemExit("FAIL: expected %d programs, got %d" % (args.programs, len(rows)))
    moving = sum(row[3] for row in rows)
    if args.expect_moving and not moving:
        raise SystemExit("FAIL: deliberately stalled foreground was not detected")
    if args.no_moving and moving:
        raise SystemExit("FAIL: nonzero planned endpoint speed at shutdown")
    print("observe: %d programs, %d ISR shutdowns, %d with planner queued, %d moving, max %.3f mm/min" % (
        len(rows), sum(row[1] for row in rows), sum(row[2] for row in rows), moving,
        max(row[4] for row in rows) / 1000.0))


def self_test():
    import contextlib
    import io
    import tempfile
    run = "run G5 5000 3000 2000 2 684 71094 2237 1906 15 0 0 21 0 0 0 0 0 345"
    normal = run + "\nobserve 1 1 0 0 0 0 0\ndone\n"
    moving = run + "\nobserve 1 2 1 1 3000000 1581 0\ndone\n"
    cases = [
        (normal, ["--no-moving", "--programs", "1"], True),
        (normal.replace("\n", ".\n"), ["--no-moving"], True),
        ("\x1b[32m" + normal.replace("\n", "..\n\x1b[0m\x1b[32m"), ["--no-moving"], True),
        (moving, ["--expect-moving"], True),
        (normal, ["--expect-moving"], False),
        (moving, ["--no-moving"], False),
        (normal.replace("done", ""), [], False),
        (normal, ["--programs", "126"], False),
        (normal.replace("0 0 345", "1 0 345"), [], False),
        (normal.replace("observe 1 1", "observe 2 1"), [], False),
    ]
    with tempfile.TemporaryDirectory(prefix="grbl-observe-") as tmp:
        log = pathlib.Path(tmp) / "control.txt"
        for i, (text, flags, expected) in enumerate(cases, 1):
            log.write_text(text, encoding="utf-8")
            with contextlib.redirect_stdout(io.StringIO()):
                try:
                    main([str(log), *flags])
                except (SystemExit, ValueError):
                    passed = False
                else:
                    passed = True
            if passed != expected:
                raise SystemExit("FAIL: observer checker self-test %d" % i)
    print("observe checker: %d self-tests passed" % len(cases))


if __name__ == "__main__":
    main(sys.argv[1:])
