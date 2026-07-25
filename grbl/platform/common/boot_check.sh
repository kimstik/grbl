#!/bin/sh
#  boot_check.sh - post-link BOOT INTEGRITY check for ARM Cortex-M images
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  WHY THIS EXISTS (BUG #21, CONTRACTS.md S18)
#  -------------------------------------------
#  KEEP(*(.isr_vector)) in the linker script does NOT survive -flto. KEEP acts
#  at link time on input sections; GCC's whole-program IPA runs earlier and
#  deletes an unreferenced vector_table[] before codegen, so ltrans never emits
#  a .isr_vector section for KEEP to match. The link succeeds, --gc-sections is
#  happy, `size` reports a plausible number - and the resulting .bin has no
#  vector table at all. Word 0 is whatever code landed first, so the core loads
#  garbage into SP/PC and the chip cannot boot. DEBUG (no LTO) looks perfectly
#  fine. That "DEBUG works / RELEASE bricks" signature is the tell.
#
#  Nothing in a normal build fails on this. This check does: it reads the first
#  two words of the final .bin and demands they look like an ARMv6-M/v7-M/v8-M
#  reset record.
#
#  Usage:
#    boot_check.sh <image.bin> <flash_origin_hex> <flash_length_bytes>
#  e.g.
#    boot_check.sh build/grbl_stm32f103.bin 0x08000000 65536
#
#  Checks:
#    word0 = initial SP   - must be 0x2xxxxxxx (Cortex-M SRAM region) and
#                           4-byte aligned.
#    word1 = reset vector - must be odd (Thumb bit set) and land inside
#                           [flash_origin, flash_origin + flash_length).
#
#  Not applicable to RISC-V: see the note in ch32v006/Makefile.

set -e

BIN="$1"
FLASH_ORIGIN="$2"
FLASH_LEN="$3"

if [ -z "$BIN" ] || [ -z "$FLASH_ORIGIN" ] || [ -z "$FLASH_LEN" ]; then
  echo "boot_check.sh: usage: $0 <image.bin> <flash_origin_hex> <flash_length_bytes>" >&2
  exit 2
fi

if [ ! -f "$BIN" ]; then
  echo "BOOT INTEGRITY: FAIL - $BIN does not exist" >&2
  exit 1
fi

SIZE=$(wc -c < "$BIN" | tr -d ' ')
if [ "$SIZE" -lt 8 ]; then
  echo "BOOT INTEGRITY: FAIL - $BIN is only $SIZE bytes (need at least 8)" >&2
  exit 1
fi

# First two 32-bit little-endian words.
WORDS=$(od -An -tx4 -N8 "$BIN" | tr -s ' ' | sed 's/^ //')
SP=$(echo "$WORDS" | cut -d' ' -f1)
PC=$(echo "$WORDS" | cut -d' ' -f2)

FLASH_END=$(printf '%u' $(( FLASH_ORIGIN + FLASH_LEN )))
FAIL=0

# --- word0: initial stack pointer ------------------------------------------
# Cortex-M SRAM is architecturally 0x20000000..0x3FFFFFFF; every part we build
# for puts its stack top in the 0x2xxxxxxx quarter.
case "$SP" in
  2*) ;;
  *)  FAIL=1 ;;
esac
if [ $(( 0x$SP & 3 )) -ne 0 ]; then FAIL=1; fi

# --- word1: reset vector ----------------------------------------------------
# Thumb bit must be set, and the target must live in this image's flash.
if [ $(( 0x$PC & 1 )) -ne 1 ]; then FAIL=1; fi
if [ $(( 0x$PC )) -lt $(( FLASH_ORIGIN )) ] || [ $(( 0x$PC )) -ge $(( FLASH_END )) ]; then
  FAIL=1
fi

if [ "$FAIL" -ne 0 ]; then
  echo "" >&2
  echo "=========================================================================" >&2
  echo "BOOT INTEGRITY: FAIL - $BIN has no usable reset record" >&2
  echo "  word0 (initial SP)   = 0x$SP   expected 0x2xxxxxxx, 4-byte aligned" >&2
  echo "  word1 (reset vector) = 0x$PC   expected odd (Thumb) and inside" >&2
  echo "                                   [$FLASH_ORIGIN, +$FLASH_LEN)" >&2
  echo "  first 16 bytes:" >&2
  od -An -tx4 -N16 "$BIN" >&2
  echo "" >&2
  echo "  Most likely cause: the vector table was dropped. KEEP(*(.isr_vector))" >&2
  echo "  does not survive -flto on its own - vector_table[] needs a real code" >&2
  echo "  reference (SCB->VTOR = (uint32_t)vector_table in Reset_Handler) and" >&2
  echo "  __attribute__((used)). See CONTRACTS.md S18 / BUG #21." >&2
  echo "=========================================================================" >&2
  exit 1
fi

echo "BOOT INTEGRITY: OK  SP=0x$SP  reset=0x$PC  ($BIN)"
