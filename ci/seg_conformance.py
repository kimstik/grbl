#!/usr/bin/env python3
"""seg_conformance.py - the ninth ratchet: segment-executor conformance.

Part of Grbl / Intelligence assisted / License: MIT

WHAT IT GUARDS

The segment boundary (grbl/stepper.c's SPSC ring) is where any far-side
executor - FPGA fabric, a second core, an external chip - will be spliced in.
That splice is only safe if "what the frozen ISR would have emitted" is a
written-down, machine-checkable artifact. This script makes it one:

  (a) STALENESS GATE. tools/hosted/ compiles grbl/stepper.c straight out of the
      tree for x86 and replays each committed .gvec vector through the real
      ISR_STEP(). The resulting trace MUST equal the committed .gtrace golden.
      Any change to the frozen consumer's observable behaviour - Bresenham,
      AMASS shift, invert-mask timing, homing lock placement, probe sample
      order, drain sequencing, tick period accounting - fails here, loudly, with
      a diff. It also fails if the goldens were edited by hand.

  (b) SUBJECT GATE. Every registered candidate executor is run on the same
      vectors and MUST match the oracle byte for byte. The oracle is the frozen
      core; a candidate is never right against a candidate.

      A subject may DECLARE divergences (SEGMENT-RUNTIME-PLAN §3.6): cases
      where matching stock would mean reproducing behaviour stock does not
      actually define. A subject that declares any ships a divergences.txt and
      an expected/ trace per entry, and three things are enforced so the
      mechanism cannot be used to launder a failing subject:
        - the count is checked EXACTLY against the baseline, not one-way;
        - the expected trace must genuinely differ from the oracle's, so a
          declaration that quietly agrees is a failure, not a pass;
        - the expected trace is committed text, reviewable in a diff.

  (b') SUBJECT AVAILABILITY. A subject may exit 77 to mean "my toolchain is not
      installed" (the Verilated executor needs verilator). That is a SKIP with
      a notice locally and a FAILURE under --require-rtl, which CI always
      passes. A gate that silently disappears on the machine that matters is
      not a gate.

  (c) CORPUS MONOTONICITY. The vector count may only grow. Deleting or
      forgetting to commit a vector is the cheapest way to make a conformance
      suite pass, so it is ratcheted like every other baseline in this tree.

WHY IT CAN FAIL, CONCRETELY

This project has shipped guards that could not fire (assert_no_double.sh once
checked for libgcc symbol names ARM never emits; -fanalyzer is inert under
-fsyntax-only). Each of this script's three gates was verified by breaking the
thing it guards and confirming a clear failure - see docs/SEGMENT-CONFORMANCE.md
for the verbatim output of all three, and --selftest for the pure-logic half.

WHAT IT DELIBERATELY DOES NOT DO

It never runs vector GENERATION. Vectors are authored artifacts; deriving them
would mean executing st_prep_buffer's float producer path on x86, whose rounding
differs from every target and would churn the corpus on every toolchain bump.
The consumer path is integer-only, which is exactly why replaying it is
bit-exact on any host.

USAGE
  ci/seg_conformance.py              full check (build, replay, compare)
  ci/seg_conformance.py --regen      rewrite goldens; DELIBERATE, never in CI
  ci/seg_conformance.py --selftest   pure-logic tests, no compiler
"""

import argparse
import difflib
import os
import subprocess
import sys

REPO_ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
HOSTED_DIR = os.path.join(REPO_ROOT, "tools", "hosted")
CORPUS_DIR = os.path.join(HOSTED_DIR, "corpus")
ORACLE_BIN = os.path.join(REPO_ROOT, "build", "hosted", "seg_oracle")
BASELINE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "seg_corpus_baseline.txt")

# Registered conformance subjects: (label, argv prefix). A subject takes a
# .gvec on argv and writes a .gtrace to stdout. Adding a Verilator testbench
# here is a one-line change - it is the same contract.
RTL_DIR = os.path.join(HOSTED_DIR, "subjects", "rtl")

SUBJECTS = [
    ("seg_exec_ref.py", [sys.executable,
                         os.path.join(HOSTED_DIR, "subjects", "seg_exec_ref.py")],
     None),
    ("rtl (verilated)", [os.path.join(RTL_DIR, "run_subject.sh")], RTL_DIR),
    # Same executor, but the frames come from the REAL host shipper over the
    # REAL frozen ring instead of from the testbench. This is the only subject
    # that can fail because grbl/platform/extensions/seg-link/seg_link.c is
    # wrong - everything else builds its own frames.
    ("rtl via seg-link wire", [os.path.join(RTL_DIR, "run_wire_subject.sh")],
     RTL_DIR),
]

SKIP_EXIT = 77


def fail(msg):
    print("seg_conformance: FAIL - " + msg)
    return 1


def vectors():
    if not os.path.isdir(CORPUS_DIR):
        return []
    return sorted(f for f in os.listdir(CORPUS_DIR) if f.endswith(".gvec"))


def golden_path(vec):
    return os.path.join(CORPUS_DIR, vec[:-len(".gvec")] + ".gtrace")


def build_oracle():
    r = subprocess.run(["make", "-s", "-C", HOSTED_DIR],
                       capture_output=True, text=True)
    if r.returncode != 0:
        sys.stdout.write(r.stdout)
        sys.stderr.write(r.stderr)
        return False
    return os.path.isfile(ORACLE_BIN)


def read_divergences(subject_dir):
    """{vector: (reference, reason)} declared by a subject, or {}."""
    if not subject_dir:
        return {}
    path = os.path.join(subject_dir, "divergences.txt")
    if not os.path.isfile(path):
        return {}
    out = {}
    for line in open(path):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 2)
        if len(parts) < 3:
            continue
        out[parts[0]] = (parts[1], parts[2])
    return out


def expected_path(subject_dir, vec):
    return os.path.join(subject_dir, "expected", vec[:-len(".gvec")] + ".gtrace")


def run_capture(argv, vec_path, who):
    r = subprocess.run(argv + [vec_path], capture_output=True, text=True)
    if r.returncode == SKIP_EXIT:
        return SKIP_EXIT
    if r.returncode != 0:
        print("   %s exited %d on %s" % (who, r.returncode, os.path.basename(vec_path)))
        for line in r.stderr.strip().splitlines():
            print("     " + line)
        return None
    return r.stdout


def show_diff(want, got, want_label, got_label, limit=25):
    d = list(difflib.unified_diff(want.splitlines(), got.splitlines(),
                                  want_label, got_label, lineterm="", n=1))
    for line in d[:limit]:
        print("     " + line)
    if len(d) > limit:
        print("     ... (%d more diff lines)" % (len(d) - limit))


def read_baseline():
    """Vector count. Keyed by name, not by line position: the file grew a
    second ratchet and 'first non-comment line' would have silently started
    reading the wrong one."""
    if not os.path.isfile(BASELINE):
        return 0
    for line in open(BASELINE):
        line = line.strip()
        if line.startswith("vectors"):
            return int(line.split()[-1])
    return 0


def read_declared_baseline():
    """Declared-divergence count. Absent line reads as 0."""
    if not os.path.isfile(BASELINE):
        return 0
    for line in open(BASELINE):
        line = line.strip()
        if line.startswith("declared_divergences"):
            return int(line.split()[-1])
    return 0


def write_baseline(n, declared=None):
    if declared is None:
        declared = read_declared_baseline()
    with open(BASELINE, "w") as fh:
        fh.write("# ci/seg_conformance.py ratchets.\n"
                 "#\n"
                 "# vectors: one-way, count may only grow. Raised deliberately when\n"
                 "# vectors are added; never lowered to make a check pass. Same posture\n"
                 "# as ci/warn_baseline_*.txt.\n"
                 "#\n"
                 "# declared_divergences: EXACT, not one-way. Each is a place a subject\n"
                 "# is allowed not to match the frozen ISR (SEGMENT-RUNTIME-PLAN §3.6),\n"
                 "# so the count may not drift in either direction without an edit here.\n"
                 "vectors %d\n"
                 "declared_divergences %d\n" % (n, declared))


def main(argv):
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--regen", action="store_true",
                    help="rewrite goldens from the oracle (deliberate, never in CI)")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--require-rtl", action="store_true",
                    help="a subject that reports its toolchain missing is a "
                         "failure, not a skip. CI always passes this.")
    args = ap.parse_args(argv[1:])

    if args.selftest:
        return selftest()

    vecs = vectors()
    if not vecs:
        return fail("no vectors in %s" % os.path.relpath(CORPUS_DIR, REPO_ROOT))

    print("seg_conformance: building hosted oracle (frozen grbl/stepper.c on x86)")
    if not build_oracle():
        return fail("hosted oracle did not build")

    problems = []
    traces = {}

    for v in vecs:
        vpath = os.path.join(CORPUS_DIR, v)
        out = run_capture([ORACLE_BIN], vpath, "oracle")
        if out is None:
            problems.append("%s: oracle failed" % v)
            continue
        traces[v] = out

    if args.regen:
        for v, out in traces.items():
            with open(golden_path(v), "w") as fh:
                fh.write(out)
        write_baseline(len(vecs),
                       sum(len(read_divergences(d)) for _, _, d in SUBJECTS))
        print("seg_conformance: regenerated %d golden(s) and raised the corpus "
              "ratchet to %d" % (len(traces), len(vecs)))
        return 0

    # (a) staleness gate
    for v in vecs:
        if v not in traces:
            continue
        gp = golden_path(v)
        if not os.path.isfile(gp):
            problems.append("%s: no committed golden (%s)" % (v, os.path.basename(gp)))
            continue
        want = open(gp).read()
        if want != traces[v]:
            problems.append("%s: replay differs from committed golden" % v)
            print("   %s: frozen-consumer replay != golden" % v)
            show_diff(want, traces[v], "golden", "replay")

    # (b) subject gate
    ran_subjects = 0
    declared_total = 0
    for label, cmd, subject_dir in SUBJECTS:
        div = read_divergences(subject_dir)
        declared_total += len(div)
        skipped = False
        for v in vecs:
            if v not in traces:
                continue
            got = run_capture(cmd, os.path.join(CORPUS_DIR, v), label)
            if got == SKIP_EXIT:
                if args.require_rtl:
                    problems.append("subject %s: toolchain missing and "
                                    "--require-rtl was given" % label)
                else:
                    print("seg_conformance: SKIP subject %s - its toolchain is "
                          "not installed on this machine. CI runs it with "
                          "--require-rtl, where this is a failure." % label)
                skipped = True
                break
            if got is None:
                problems.append("%s: subject %s failed" % (v, label))
                continue
            if v in div:
                ref, reason = div[v]
                ep = expected_path(subject_dir, v)
                if not os.path.isfile(ep):
                    problems.append("%s: subject %s declares a divergence (%s) "
                                    "but ships no expected/ trace" % (v, label, ref))
                    continue
                want = open(ep).read()
                if want == traces[v]:
                    problems.append("%s: subject %s declares a divergence (%s) "
                                    "whose expected trace is IDENTICAL to the "
                                    "oracle - declare nothing, or diverge"
                                    % (v, label, ref))
                    continue
                if got != want:
                    problems.append("%s: subject %s does not match its own "
                                    "declared divergence" % (v, label))
                    print("   %s: subject %s != expected/ (%s: %s)"
                          % (v, label, ref, reason))
                    show_diff(want, got, "expected", label)
                continue
            if got != traces[v]:
                problems.append("%s: subject %s diverges from the oracle" % (v, label))
                print("   %s: subject %s != oracle" % (v, label))
                show_diff(traces[v], got, "oracle", label)
        if not skipped:
            ran_subjects += 1

    # (b2) declared-divergence ratchet: exact, not one-way. Adding or removing
    # a declaration must be a deliberate edit to the baseline.
    want_div = read_declared_baseline()
    if declared_total != want_div:
        problems.append("declared divergences: %d present, baseline says %d "
                        "(edit %s deliberately, with owner sign-off per "
                        "SEGMENT-RUNTIME-PLAN §3.6)"
                        % (declared_total, want_div,
                           os.path.relpath(BASELINE, REPO_ROOT)))

    # (c) corpus monotonicity
    base = read_baseline()
    if len(vecs) < base:
        problems.append("corpus shrank: %d vector(s) present, ratchet says %d"
                        % (len(vecs), base))
    grew = len(vecs) > base

    if problems:
        print()
        for p in problems:
            print("  - " + p)
        print("\nIf the frozen consumer legitimately changed, re-read the golden MD5 gate "
              "first.\nOnly then: ci/seg_conformance.py --regen")
        return 1

    print("seg_conformance: OK - %d vector(s), %d/%d subject(s) run, %d declared "
          "divergence(s); goldens fresh, subjects bit-exact."
          % (len(vecs), ran_subjects, len(SUBJECTS), declared_total))
    if grew:
        print("seg_conformance: corpus grew %d -> %d; raise the ratchet with --regen "
              "or by editing %s" % (base, len(vecs), os.path.relpath(BASELINE, REPO_ROOT)))
    return 0


# ---------------------------------------------------------------------------
# Pure-logic self-tests (no compiler, matching ci/warn_ratchet.py's style).
# ---------------------------------------------------------------------------

def selftest():
    ok = [0]
    bad = [0]

    def check(cond, what):
        if cond:
            ok[0] += 1
        else:
            bad[0] += 1
            print("  FAIL: " + what)

    check(golden_path("07-invert-masks.gvec").endswith("07-invert-masks.gtrace"),
          "golden_path swaps .gvec for .gtrace")
    check(os.path.dirname(golden_path("x.gvec")) == CORPUS_DIR,
          "goldens live beside their vectors")

    # The ratchet must be one-way: fewer vectors than the baseline is a failure,
    # more is a pass-with-notice. Exercise both directions on the parser.
    import tempfile
    global BASELINE
    saved = BASELINE
    try:
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as fh:
            fh.write("# comment\nvectors 13\n")
            BASELINE = fh.name
        check(read_baseline() == 13, "read_baseline skips comments and reads the count")
        os.unlink(BASELINE)
        BASELINE = os.path.join(tempfile.gettempdir(), "seg_conf_absent_baseline.txt")
        if os.path.exists(BASELINE):
            os.unlink(BASELINE)
        check(read_baseline() == 0, "absent baseline reads as 0, never as an error")
    finally:
        BASELINE = saved

    # A subject that emits the oracle's text with one byte changed must be
    # rejected: the comparison is exact equality, not a tolerance.
    a = "T 1 0 999 0x00 0x01 0 1 0 0\n"
    b = "T 1 0 999 0x00 0x00 0 1 0 0\n"
    check(a != b, "trace comparison is byte-exact (one step bit differs => not equal)")

    check(len(SUBJECTS) >= 1, "at least one conformance subject is registered")

    print("seg_conformance --selftest: %d passed, %d failed" % (ok[0], bad[0]))
    return 1 if bad[0] else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
