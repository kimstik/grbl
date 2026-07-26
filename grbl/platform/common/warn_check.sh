#!/bin/sh
#  warn_check.sh - post-link WARNING RATCHET wiring, build-log edition.
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  WHY THIS EXISTS
#  ----------------
#  ci/warn_ratchet.py has existed since Phase 0 but was invoked from NOWHERE
#  in any port Makefile - only from .github/workflows/ci.yml, after the fact,
#  against a log the CI job captured itself. A developer's local `make` was
#  therefore completely blind to warning regressions; the baseline files were
#  only ever consulted in CI. assert_no_double.sh/init_check.sh/boot_check.sh
#  all run from the port's OWN Makefile, right after the link step, so they
#  fire for every developer on every build. This script closes the same gap
#  for the warning ratchet.
#
#  THE HARD PART: A LOG, NOT AN ELF
#  ---------------------------------
#  The other three ratchets inspect the linked ELF/bin - a single artifact
#  that is either right or wrong regardless of how it got built. The warning
#  ratchet needs a build LOG (every TU's compiler stdout/stderr) to compare
#  against the baseline. That log is only trustworthy if it reflects EVERY
#  translation unit - `make`'s whole point is to SKIP recompiling files whose
#  dependencies did not change, so a normal incremental build's log silently
#  lacks whatever warnings an untouched file would still emit today. A
#  ratchet that green-lights a build because the evidence for a warning
#  happened to be missing is exactly the failure class this project has
#  already been burned by twice: assert_no_double.sh once denylisted only
#  the generic libgcc double-precision symbol family and PASSED an ARM
#  object full of __aeabi_dadd (the family ARM's ABI actually emits); a
#  -fanalyzer pass elsewhere in this tree turned out to be silently inert
#  under -fsyntax-only. "The check ran and reported clean" and "the check
#  actually examined the thing" are different claims, and this script is
#  written to never let the former stand in for the latter.
#
#  THE APPROACH
#  ------------
#  1. Force a FULL rebuild, always, in a directory this script itself
#     controls: the caller passes a build-artifact directory ($1) that this
#     script clears of every *.o before the build runs. Make's own
#     dependency tracking then has no choice but to recompile every single
#     source file - "full build" is a structural guarantee from the object
#     directory being empty, not a promise the caller has to keep honestly.
#     For most ports that directory is a dedicated scratch path (never the
#     directory the developer's normal incremental build uses, so this
#     never slows down `make link`/`make objects` day to day - only `all`/
#     `validate`, which is where CI and "give me the real artifacts" already
#     pay full-build cost). For the atmega328p shim, which has no scratch
#     knob because the real link lives in the golden-MD5-gated root
#     Makefile, this directory IS the root build/ dir - clearing its *.o
#     (not the whole directory: grbl.hex/main.elf/*.d are left alone until
#     the rebuild naturally regenerates them) is exactly what the root
#     Makefile's own `clean` target already does to that same file set.
#  2. Capture the rebuild's output with a single, unconditional `>file 2>&1`
#     redirection - no pipe, no `tee`, no bash-only PIPESTATUS/pipefail
#     trick. That class of shell trap already broke this project's CI once
#     for real (dsPIC's RELEASE workflow step: `elf="...$([ "$X" = Y ] &&
#     echo z)..."` silently killed a `run:` step under bash -eo pipefail the
#     moment the test was false - see PLAN.md). A plain redirection has no
#     pipeline, so there is no pipefail hazard and the exit status captured
#     immediately after is unambiguously the build's own. It is also safe
#     under `make -j`: this is ONE process tree (the recursive $(MAKE),
#     itself free to use -j for its own compiles) writing to ONE inherited
#     fd. Individual compiler diagnostics can still interleave with each
#     other at the OS's whim between distinct child processes, exactly as
#     they already do in the project's existing CI log capture
#     (.github/actions/build-platform/action.yml's `2>&1 | tee`) - this
#     script does not make that pre-existing characteristic worse, and each
#     single diagnostic line is still written by one process's own ordered
#     output, so line-oriented parsing (ci/warn_ratchet.py's job) stays
#     sound.
#  3. Prove step 1 actually happened before trusting the log at all: count
#     the *.o files sitting in the object directory after the rebuild
#     succeeds and demand it equals the caller-declared expected count. If
#     the count is wrong - wrong directory got passed, the recursive make
#     invocation silently no-op'd, a build tool crashed and its recipe kept
#     going under `-k` - FAIL LOUDLY instead of ratcheting a log that cannot
#     be trusted to represent a full build. This is the "fail or skip
#     loudly, never silently pass" requirement made concrete: the one thing
#     this script must never do is print "OK" over missing evidence.
#
#  Usage:
#    warn_check.sh <obj_dir> <expected_object_count> <log_file> \
#                  <baseline_file> <ratchet_py> -- <full rebuild command...>
#
#  <obj_dir> is scanned non-recursively (-maxdepth 1) for *.o; the rebuild
#  command is responsible for putting exactly <expected_object_count> of
#  them there (normally by way of BUILD_DIR=<obj_dir> on a recursive $(MAKE)
#  invocation - see any port Makefile's `warn_check` target for the exact
#  invocation).

set -eu

if [ $# -lt 6 ]; then
  echo "usage: $0 <obj_dir> <expected_count> <log_file> <baseline_file> <ratchet_py> -- <rebuild command...>" >&2
  exit 2
fi

OBJ_DIR="$1"; shift
EXPECT_N="$1"; shift
LOG="$1"; shift
BASELINE="$1"; shift
RATCHET="$1"; shift

if [ "${1:-}" != "--" ]; then
  echo "warn_check.sh: usage error - expected '--' before the rebuild command, got '${1:-}'" >&2
  exit 2
fi
shift

mkdir -p "$OBJ_DIR"
# Clear any *.o already sitting here (from a previous run, or - for the
# atmega328p shim - from the developer's own last golden build) so the
# post-build count below cannot be inflated by stale leftovers. `rm -f` on a
# non-matching glob is a no-op, not an error, so this is safe when the
# directory is already empty.
rm -f "$OBJ_DIR"/*.o 2>/dev/null || true

rm -f "$LOG"
STATUS=0
"$@" >"$LOG" 2>&1 || STATUS=$?

if [ "$STATUS" -ne 0 ]; then
  echo "" >&2
  echo "=========================================================================" >&2
  echo "warn_check: FAIL - the full rebuild for the warning ratchet did not" >&2
  echo "  complete (exit $STATUS). A build that did not finish cannot be" >&2
  echo "  ratcheted for warnings - fix the build first. Full log: $LOG" >&2
  echo "  Last 40 lines:" >&2
  echo "=========================================================================" >&2
  tail -n 40 "$LOG" >&2 || true
  exit "$STATUS"
fi

GOT_N=$(find "$OBJ_DIR" -maxdepth 1 -name '*.o' | wc -l | tr -d ' ')
if [ "$GOT_N" -ne "$EXPECT_N" ]; then
  echo "" >&2
  echo "=========================================================================" >&2
  echo "warn_check: FAIL - expected $EXPECT_N freshly-compiled object file(s) in" >&2
  echo "  $OBJ_DIR, found $GOT_N. The captured log does not provably represent a" >&2
  echo "  full build (wrong directory, a no-op rebuild, or a tool failure" >&2
  echo "  swallowed under -k) and cannot be trusted - refusing to ratchet a" >&2
  echo "  partial/incremental log rather than risk a silent pass on missing" >&2
  echo "  evidence (see this script's header, and CONTRACTS.md's warning-" >&2
  echo "  ratchet build-time wiring entry)." >&2
  echo "=========================================================================" >&2
  exit 1
fi

python3 "$RATCHET" --log "$LOG" --baseline "$BASELINE"
