#!/usr/bin/env python3
"""warn_ratchet.py - one-way warning ratchet for CI build logs.

Fails (exit 1) when a build log contains warnings that are NOT in the
checked-in baseline. Warnings that disappear are only reported as manual
cleanup candidates - the baseline is never rewritten automatically.

Warnings are normalized before comparison so baselines survive rebuilds,
path changes and minor toolchain differences:
  * only "<file>:<line>[:<col>]: warning: <text>" and
    "<tool>: warning: <text>" lines are considered
  * file path reduced to basename, line/column numbers dropped
  * whitespace runs collapsed
  * Unicode quotes and backticks mapped to "'"
  * space before "?" dropped (gcc 7 prints "'<' ?", newer gcc "'<'?")

Baseline file format: one normalized warning per line; blank lines and
lines starting with "#" are ignored. Generate entries with --emit.

Usage:
  warn_ratchet.py --log build.log --baseline ci/warn_baseline_x.txt
  warn_ratchet.py --log build.log --emit     # print normalized warnings
  warn_ratchet.py --selftest
"""

import argparse
import os
import re
import sys
import tempfile

WARN_WITH_LOC = re.compile(
    r"^(?P<path>[^:\s][^:]*):\d+(?::\d+)?:\s*warning:\s*(?P<msg>.+)$")
WARN_NO_LOC = re.compile(
    r"^(?P<path>[^:\s][^:]*):\s*warning:\s*(?P<msg>.+)$")
QUOTE_MAP = str.maketrans({"‘": "'", "’": "'", "`": "'"})


def normalize_line(line):
    """Return the normalized warning for a log line, or None if not a warning."""
    line = line.strip().translate(QUOTE_MAP)
    m = WARN_WITH_LOC.match(line) or WARN_NO_LOC.match(line)
    if m is None:
        return None
    path = os.path.basename(m.group("path").strip())
    msg = " ".join(m.group("msg").split())
    msg = re.sub(r"\s+\?", "?", msg)
    return "{}: warning: {}".format(path, msg)


def parse_log(lines):
    return {w for w in map(normalize_line, lines) if w is not None}


def parse_baseline(lines):
    out = set()
    for ln in lines:
        ln = ln.strip()
        if ln and not ln.startswith("#"):
            out.add(ln)
    return out


def compare(log_warnings, baseline):
    """Return (new, resolved) as sorted lists."""
    return (sorted(log_warnings - baseline), sorted(baseline - log_warnings))


def run_compare(log_path, baseline_path):
    with open(log_path, encoding="utf-8", errors="replace") as f:
        found = parse_log(f)
    if not os.path.exists(baseline_path):
        print("warn_ratchet: baseline file not found: {}\n"
              "Create it (empty is fine) so the ratchet is explicit."
              .format(baseline_path), file=sys.stderr)
        return 2
    with open(baseline_path, encoding="utf-8") as f:
        baseline = parse_baseline(f)
    new, resolved = compare(found, baseline)
    if new:
        print("warn_ratchet: FAIL - {} new warning(s) not in {}:"
              .format(len(new), baseline_path))
        for w in new:
            print("  + " + w)
        print("Fix them, or - only for warnings accepted as known debt - "
              "append the lines above to the baseline.")
        return 1
    print("warn_ratchet: OK - {} distinct warning(s), all in baseline."
          .format(len(found)))
    if resolved:
        print("warn_ratchet: {} baseline entr{} no longer observed "
              "(candidates for manual removal):"
              .format(len(resolved), "y" if len(resolved) == 1 else "ies"))
        for w in resolved:
            print("  - " + w)
    return 0


def selftest():
    checks = 0

    def check(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            print("selftest: FAIL - " + what)
            sys.exit(1)

    # normalization: strip path, line and column
    check(normalize_line("grbl/nvmem.c:127:26: warning: '<<' in boolean "
                         "context, did you mean '<' ? [-Wint-in-bool-context]")
          == "nvmem.c: warning: '<<' in boolean context, did you mean '<'? "
             "[-Wint-in-bool-context]", "path/line/col + '?' spacing")
    # cpp diagnostics have no column; unicode quotes map to '
    check(normalize_line("../../hal_gpio.h:129: warning: ‘X’ redefined")
          == "hal_gpio.h: warning: 'X' redefined", "no-column + unicode quotes")
    # tool warnings without any location
    check(normalize_line("cc1: warning: something odd")
          == "cc1: warning: something odd", "no-location tool warning")
    # non-warning lines are ignored
    check(normalize_line("grbl/system.c:249:22: error: boom") is None, "error ignored")
    check(normalize_line("In file included from grbl/hal.h:182:") is None,
          "include trace ignored")
    check(normalize_line("  CC build/main.o") is None, "plain line ignored")

    log = [
        "avr-gcc -Wall -c grbl/nvmem.c",
        "grbl/nvmem.c:127:26: warning: '<<' in boolean context, did you mean '<' ? [-Wint-in-bool-context]",
        "grbl/nvmem.c:149:26: warning: '<<' in boolean context, did you mean '<' ? [-Wint-in-bool-context]",
        "platform.c:122:25: warning: unused parameter ‘__us’ [-Wunused-parameter]",
    ]
    found = parse_log(log)
    check(len(found) == 2, "duplicate warnings dedup to one entry")

    baseline = parse_baseline([
        "# comment",
        "",
        "nvmem.c: warning: '<<' in boolean context, did you mean '<'? [-Wint-in-bool-context]",
        "system.c: warning: this statement may fall through [-Wimplicit-fallthrough=]",
    ])
    new, resolved = compare(found, baseline)
    check(new == ["platform.c: warning: unused parameter '__us' [-Wunused-parameter]"],
          "new warning detected")
    check(resolved == ["system.c: warning: this statement may fall through "
                       "[-Wimplicit-fallthrough=]"], "resolved warning listed")

    # end-to-end through files and exit codes
    with tempfile.TemporaryDirectory() as d:
        log_path = os.path.join(d, "b.log")
        base_path = os.path.join(d, "base.txt")
        with open(log_path, "w") as f:
            f.write("\n".join(log) + "\n")
        with open(base_path, "w") as f:
            f.write("nvmem.c: warning: '<<' in boolean context, did you mean "
                    "'<'? [-Wint-in-bool-context]\n")
        check(run_compare(log_path, base_path) == 1, "exit 1 on new warning")
        with open(base_path, "a") as f:
            f.write("platform.c: warning: unused parameter '__us' "
                    "[-Wunused-parameter]\n")
        check(run_compare(log_path, base_path) == 0, "exit 0 when baselined")
        check(run_compare(log_path, os.path.join(d, "missing.txt")) == 2,
              "exit 2 on missing baseline")

    print("selftest: PASS ({} checks)".format(checks))
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--log", help="build log to scan")
    p.add_argument("--baseline", help="baseline file of accepted warnings")
    p.add_argument("--emit", action="store_true",
                   help="print normalized warnings from --log and exit")
    p.add_argument("--selftest", action="store_true", help="run unit checks")
    a = p.parse_args(argv)

    if a.selftest:
        return selftest()
    if not a.log:
        p.error("--log is required (or use --selftest)")
    if a.emit:
        with open(a.log, encoding="utf-8", errors="replace") as f:
            for w in sorted(parse_log(f)):
                print(w)
        return 0
    if not a.baseline:
        p.error("--baseline is required (or use --emit)")
    return run_compare(a.log, a.baseline)


if __name__ == "__main__":
    sys.exit(main())
