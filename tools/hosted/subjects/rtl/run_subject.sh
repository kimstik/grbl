#!/bin/sh
# run_subject.sh - the Verilated executor, wrapped in the subject contract.
#
# Part of Grbl / Intelligence assisted / License: MIT
#
#   run_subject.sh <vector.gvec>   -> .gtrace on stdout
#
# Builds on demand (verilator is slow to install, fast to re-run) and keeps the
# build chatter off stdout, which belongs entirely to the trace.
#
# Exit 77 means "verilator is not installed". ci/seg_conformance.py treats 77
# as a SKIP with a notice unless --require-rtl is given, and CI always gives
# it - so a machine without verilator gets a warning while CI cannot silently
# lose the gate.

set -e
here=$(cd "$(dirname "$0")" && pwd)
bin=$here/../../../../build/hosted/rtl/tb_segx

command -v verilator >/dev/null 2>&1 || exit 77

make -s -C "$here" >&2
exec "$bin" "$@"
