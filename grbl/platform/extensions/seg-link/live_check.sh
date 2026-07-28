#!/bin/sh
# live_check.sh - post-link proof that the shipper's bytes go SOMEWHERE.
# Part of Grbl / Intelligence assisted / License: MIT
#
# Same lesson as seg-trace's: a sink with no reader is deleted by LTO, along
# with every call into it and, transitively, the shipper itself - and the unit
# still "builds" and still passes every other ratchet. The check asserts
# STORAGE, because an elided mailbox still leaves seg_link_tx in the image, so
# checking the function would be a guard that cannot fire.
#
# usage: live_check.sh <nm> <elf>

set -e
NM="$1"; ELF="$2"
[ -n "$NM" ] && [ -n "$ELF" ] || {
  echo "seg-link live_check: usage: live_check.sh <nm> <elf>" >&2; exit 2; }

WANT=32                          # SEG_LINK_NULL_MAILBOX, see seg_link_null.c

GOT=$("$NM" --print-size --radix=d "$ELF" 2>/dev/null \
      | awk '$NF == "seg_link_null_mailbox" { print $2; found=1 } END { if (!found) print "" }')

if [ -z "$GOT" ]; then
  echo "seg-link live_check: FAIL - seg_link_null_mailbox is not in $ELF." >&2
  echo "  The transport sink was optimized away, which means the shipper's" >&2
  echo "  stores went with it: the extension is linked but inert." >&2
  echo "  (This is what happens without the volatile qualifier - see" >&2
  echo "   seg_link_null.c.)" >&2
  exit 1
fi

if [ "$GOT" -lt "$WANT" ]; then
  echo "seg-link live_check: FAIL - seg_link_null_mailbox is $GOT bytes, expected >= $WANT" >&2
  exit 1
fi

echo "seg-link live_check: OK  seg_link_null_mailbox = $GOT bytes (>= $WANT) in $ELF"
