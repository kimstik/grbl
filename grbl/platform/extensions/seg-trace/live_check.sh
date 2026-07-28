#!/bin/sh
# live_check.sh - post-link proof that seg-trace's capture ring SURVIVED.
# Part of Grbl / Intelligence assisted / License: MIT
#
# WHY THIS EXISTS, in one measured sentence: the first RELEASE build of this
# extension linked cleanly, passed every existing ratchet, and captured nothing,
# because LTO correctly proved that no code in the image ever reads the capture
# ring and deleted both arrays and every store into them. "It built" is not
# evidence that a tap taps.
#
# The check is deliberately about STORAGE, not about a function symbol: an
# elided ring still leaves seg_trace_publish_hook in the image, so checking the
# hook would be a guard that cannot fire. It asserts the ring exists AND is at
# least the size SEG_TRACE_RECORDS demands, so a future "optimization" that
# shrinks it to a stub also trips.
#
# usage: live_check.sh <nm> <elf> <records>

set -e
NM="$1"; ELF="$2"; RECORDS="$3"
[ -n "$NM" ] && [ -n "$ELF" ] && [ -n "$RECORDS" ] || {
  echo "seg-trace live_check: usage: live_check.sh <nm> <elf> <records>" >&2; exit 2; }

REC_MAX=20                       # 1 tag + SEGX_BLK_WIRE_LEN, see seg_trace.c
WANT=$(( RECORDS * REC_MAX ))

GOT=$("$NM" --print-size --radix=d "$ELF" 2>/dev/null \
      | awk '$NF == "seg_trace_buf" { print $2; found=1 } END { if (!found) print "" }')

if [ -z "$GOT" ]; then
  echo "seg-trace live_check: FAIL - seg_trace_buf is not in $ELF." >&2
  echo "  The capture ring was optimized away; the tap records nothing." >&2
  echo "  (This is what happens without the volatile qualifier - see seg_trace.c.)" >&2
  exit 1
fi

if [ "$GOT" -lt "$WANT" ]; then
  echo "seg-trace live_check: FAIL - seg_trace_buf is $GOT bytes, expected >= $WANT" >&2
  echo "  ($RECORDS records x $REC_MAX bytes). The ring was shrunk or partly elided." >&2
  exit 1
fi

echo "seg-trace live_check: OK  seg_trace_buf = $GOT bytes (>= $WANT) in $ELF"
