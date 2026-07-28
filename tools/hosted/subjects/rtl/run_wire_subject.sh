#!/bin/sh
# run_wire_subject.sh - the WHOLE loop as one conformance subject.
#
# Part of Grbl / Intelligence assisted / License: MIT
#
#   run_wire_subject.sh <vector.gvec>   -> .gtrace on stdout
#
# The sibling run_subject.sh has the testbench serialise the vector itself.
# This one does not: it runs the real host shipper
# (grbl/platform/extensions/seg-link/seg_link.c, the same file the firmware
# compiles) over the real frozen ring, captures the Profile F bytes it emits,
# and replays THOSE through the executor.
#
#   vector -> frozen ring -> seg_link.c -> SOF/TAG/LEN/CRC bytes
#          -> segx_rx.v -> segx_exec.v -> trace
#
# So this subject fails if the shipper mislabels a block generation, drops a
# BLK, breaks the sequence, or miscomputes a CRC - none of which the other
# subjects can see, because they all build their own frames.
#
# Exit 77 = verilator missing; see run_subject.sh.

set -e
here=$(cd "$(dirname "$0")" && pwd)
root=$here/../../../..
wire=$root/build/hosted/seg_wire
tb=$root/build/hosted/rtl/tb_segx

command -v verilator >/dev/null 2>&1 || exit 77

make -s -C "$root/tools/hosted" >&2
make -s -C "$here" >&2

tmp=$(mktemp -t segx_wire.XXXXXX)
trap 'rm -f "$tmp"' EXIT
"$wire" "$1" > "$tmp" 2>/dev/null
exec "$tb" --wire "$tmp" "$1"
