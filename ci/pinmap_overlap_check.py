#!/usr/bin/env python3
"""pinmap_overlap_check.py - config.h/platform.h macro single-owner guard.

Why this exists (BUG #25 class, CONTRACTS.md #gpio-pin-map-single-owner):
when a port's board config.h and its platform.h both `#define` the same
pin-shaped macro name, which value survives in any given translation unit is
decided by C's ordinary #define-redefinition rule (last include wins) - a
per-TU accident, not a decision. stm32f103/stm32h523 both shipped this for
real (SPINDLE_ENABLE_PIN: config.h said 7, platform.h said 12 - the pin that
got CONFIGURED as an output was not the pin that ever got WRITTEN). A repo
audit (2026-07-26) found a fourth, previously-unflagged instance on samd21
(LIMIT_MASK, config.h and platform.h both defining it with no preceding
`#undef` - currently harmless only because both sides happen to expand to
the same token).

The project's accepted way to defuse this (CONTRACTS.md #gpio-pin-map-single-
owner) is not "make both files agree on a value" (that fixes the symptom,
not the mechanism - a future edit to either file can silently reintroduce
the split with nothing to warn about it). It is "one file owns the name";
when platform.h deliberately repurposes a name its board config.h also
defines, that repurposing must announce itself with a `#undef NAME`
immediately before platform.h's own `#define NAME` - visible in the diff,
not just in a compiler warning nobody reads (GCC does not even warn when the
two definitions happen to expand to the same token).

This script fails (exit 1) if ANY config.h/platform.h pair in the tree has a
macro name defined in both files where platform.h's (re)definition is NOT
preceded, anywhere earlier in platform.h, by an `#undef` of that exact name.

Discovery is automatic, not a hardcoded port list: every `grbl/platform/*/`
directory that contains a `platform.h` directly in its own root is a "port";
every `config.h` found anywhere under that port's own directory tree
(covering both single-board ports like stm32f103/config.h and per-board
ports like samd21/generic/config.h, samd21/megarm/config.h, and samd21's own
shared samd21/config.h) is paired against that port's platform.h. A port
with no config.h at all (atmega328p, hc32f460) contributes zero pairs -
structurally immune, not exempted by this script.

Usage:
  pinmap_overlap_check.py [--repo-root PATH]
  pinmap_overlap_check.py --selftest
"""

import argparse
import glob
import os
import re
import sys
import tempfile

DEFINE_RE = re.compile(
    r'^\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*)(\((?:[^)]*)\))?\s*(.*?)\s*(?://.*|/\*.*)?$')
UNDEF_RE = re.compile(r'^\s*#\s*undef\s+([A-Za-z_][A-Za-z0-9_]*)')


def parse_file(path):
    """Return (defs, events): defs = {name: (value, is_function_like)} using
    the LAST #define seen (so a file that #undef+#redefines its own macro is
    represented by its final value); events = ordered [(lineno, kind, name)]
    for every #define/#undef line, kind in {'define', 'undef'}."""
    defs = {}
    events = []
    with open(path, "r", errors="replace") as f:
        for i, line in enumerate(f, 1):
            m = UNDEF_RE.match(line)
            if m:
                events.append((i, "undef", m.group(1)))
                continue
            m = DEFINE_RE.match(line)
            if m:
                name = m.group(1)
                is_func = m.group(2) is not None
                value = m.group(3).strip()
                defs[name] = (value, is_func)
                events.append((i, "define", name))
    return defs, events


def first_define_line(events, name):
    for (ln, kind, n) in events:
        if kind == "define" and n == name:
            return ln
    return None


def undef_precedes(events, name, before_line):
    for (ln, kind, n) in events:
        if kind == "undef" and n == name and ln < before_line:
            return True
    return False


def discover_pairs(repo_root):
    """Returns list of (label, config_path, platform_path)."""
    platform_root = os.path.join(repo_root, "grbl", "platform")
    pairs = []
    for entry in sorted(os.listdir(platform_root)):
        port_dir = os.path.join(platform_root, entry)
        if not os.path.isdir(port_dir):
            continue
        plat_path = os.path.join(port_dir, "platform.h")
        if not os.path.isfile(plat_path):
            continue  # not a port directory (e.g. common/, docs/)
        config_paths = sorted(
            p for p in glob.glob(os.path.join(port_dir, "**", "config.h"), recursive=True))
        for cfg_path in config_paths:
            rel_cfg = os.path.relpath(cfg_path, platform_root)
            pairs.append((f"{entry}: {rel_cfg}", cfg_path, plat_path))
    return pairs


def check(repo_root, verbose=False):
    pairs = discover_pairs(repo_root)
    violations = []
    total_overlaps = 0
    for label, cfg_path, plat_path in pairs:
        cfg_defs, _ = parse_file(cfg_path)
        plat_defs, plat_events = parse_file(plat_path)
        common = sorted(set(cfg_defs) & set(plat_defs))
        for name in common:
            total_overlaps += 1
            fline = first_define_line(plat_events, name)
            guarded = undef_precedes(plat_events, name, fline) if fline else False
            if verbose:
                print(f"  [{label}] {name}: config.h={cfg_defs[name][0]!r} "
                      f"platform.h={plat_defs[name][0]!r} "
                      f"{'GUARDED' if guarded else 'UNGUARDED'}")
            if not guarded:
                violations.append((label, name, os.path.relpath(plat_path, repo_root), fline))
    return pairs, total_overlaps, violations


def selftest():
    tests = 0
    passed = 0

    with tempfile.TemporaryDirectory() as tmp:
        port_dir = os.path.join(tmp, "grbl", "platform", "fakeport")
        os.makedirs(port_dir)

        def write(rel, content):
            path = os.path.join(port_dir, rel)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w") as f:
                f.write(content)
            return path

        # Test 1: clean pair, no common names -> zero violations.
        tests += 1
        write("boards/generic/config.h", "#define FOO 1\n")
        write("platform.h", "#define BAR 2\n")
        _, overlaps, violations = check(tmp)
        if overlaps == 0 and violations == []:
            passed += 1
        else:
            print(f"FAIL test1: expected 0/[] got {overlaps}/{violations}")

        # Test 2: common name, no #undef -> 1 violation (the exact bug class).
        tests += 1
        write("boards/generic/config.h", "#define FOO 1\n#define SHARED 7\n")
        write("platform.h", "#define BAR 2\n#define SHARED 7\n")
        _, overlaps, violations = check(tmp)
        if overlaps == 1 and len(violations) == 1 and violations[0][1] == "SHARED":
            passed += 1
        else:
            print(f"FAIL test2: expected 1 overlap/1 violation got {overlaps}/{violations}")

        # Test 3: common name, WITH preceding #undef -> 0 violations.
        tests += 1
        write("platform.h", "#define BAR 2\n#undef SHARED\n#define SHARED 7\n")
        _, overlaps, violations = check(tmp)
        if overlaps == 1 and violations == []:
            passed += 1
        else:
            print(f"FAIL test3: expected 1 overlap/0 violations got {overlaps}/{violations}")

        # Test 4: #undef AFTER the #define (does not count - must precede).
        tests += 1
        write("platform.h", "#define BAR 2\n#define SHARED 7\n#undef SHARED\n")
        _, overlaps, violations = check(tmp)
        if overlaps == 1 and len(violations) == 1:
            passed += 1
        else:
            print(f"FAIL test4: expected 1 overlap/1 violation (undef-after doesn't count) got {overlaps}/{violations}")

        # Test 5: no config.h anywhere -> zero pairs discovered, not an error.
        tests += 1
        os.remove(os.path.join(port_dir, "boards", "generic", "config.h"))
        pairs, overlaps, violations = check(tmp)
        if pairs == [] and overlaps == 0 and violations == []:
            passed += 1
        else:
            print(f"FAIL test5: expected zero pairs got {pairs}/{overlaps}/{violations}")

    print(f"pinmap_overlap_check selftest: {passed}/{tests} passed")
    return passed == tests


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo-root", default=None,
                     help="repo root containing grbl/platform (default: inferred from this script's location)")
    ap.add_argument("--verbose", action="store_true", help="print every overlap found, not just violations")
    ap.add_argument("--selftest", action="store_true", help="run internal selftest and exit")
    args = ap.parse_args()

    if args.selftest:
        sys.exit(0 if selftest() else 1)

    repo_root = args.repo_root or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pairs, total_overlaps, violations = check(repo_root, verbose=args.verbose)

    if violations:
        print(f"pinmap_overlap_check: FAIL - {len(violations)} unguarded macro overlap(s) "
              f"(CONTRACTS.md #gpio-pin-map-single-owner, BUG #25 class):")
        for label, name, plat_rel, fline in violations:
            print(f"  [{label}] '{name}' is defined in both files, but {plat_rel}:{fline} "
                  f"has no preceding '#undef {name}' - add one immediately before that "
                  f"#define to make the repurposing a visible, deliberate decision.")
        sys.exit(1)

    print(f"pinmap_overlap_check: OK - {len(pairs)} config.h/platform.h pair(s) checked, "
          f"{total_overlaps} overlapping macro name(s), all guarded by a preceding #undef.")
    sys.exit(0)


if __name__ == "__main__":
    main()
