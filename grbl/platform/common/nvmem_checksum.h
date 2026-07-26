/*
  nvmem_checksum.h - the chip-agnostic checksum-copy wrappers core GRBL
  calls into a port's nvmem.c (NON-AVR ports only)
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  NOT AN ORDINARY HEADER - this file contains FUNCTION DEFINITIONS and is
  meant to be #included exactly once, from inside a port's nvmem.c, AFTER
  that port has defined EEPROM_SIZE, eeprom_get_char/eeprom_put_char and
  (if it opts into the write half, see below) nvmem_write_range. Same
  rationale as common/serial_ring_accessors.h: these are TU-replacement
  ports (CONTRACTS.md #7) that do not link core grbl/nvmem.c at all, so
  there is no translation unit these functions could otherwise share
  without every port growing an extra object file and Makefile line.

  ============================================================================
  HARD BOUNDARY: THIS FILE IS FOR NON-AVR PORTS ONLY. IT MUST NEVER BE
  INCLUDED BY grbl/nvmem.c OR BY atmega328p.
  ============================================================================
  Core grbl/nvmem.c computes its rolling checksum with

      checksum = (checksum << 1) || (checksum >> 7);   // LOGICAL or

  which is upstream GRBL's long-standing typo: `||` yields 0 or 1, so the
  "rotate" degenerates to a boolean and the core checksum is a much weaker
  function than it looks. CONTRACTS.md §10.4 says NEVER to "fix" it - the
  AVR golden binary (ratchet #1, Makefile:validate MD5) and every settings
  blob already written by an atmega328p in the field depend on that exact
  arithmetic. This file uses the BITWISE `|` rotate, which is what every
  non-AVR port in this tree has always used: those ports were never
  bug-compatible with AVR's EEPROM contents in the first place (different
  storage, different sizes, no shared media), so they get the correct
  rotate. Extracting the non-AVR form here does not touch, and must not be
  made to touch, the core/AVR form.

  ============================================================================
  WHAT THE INCLUDING nvmem.c MUST PROVIDE FIRST
  ============================================================================
    EEPROM_SIZE                emulated-EEPROM byte count (per port)
    eeprom_get_char(addr)      single-byte read
    GRBL_NVMEM_HAS_WRITE_RANGE optional opt-in, see below
    nvmem_write_range(addr, const uint8_t *src, size)
                               staged block write - ONLY required when
                               GRBL_NVMEM_HAS_WRITE_RANGE is defined

  The write half is OPT-IN because the two write strategies in this tree
  are genuinely different code, not formatting:

    - ch32v006, ch570, dspic33ak128mc102 stage a whole flash block once and
      program it (nvmem_write_range), so the wrapper computes the checksum
      first and then issues exactly two range writes. They `#define
      GRBL_NVMEM_HAS_WRITE_RANGE` before including this file.
    - samd21 has no nvmem_write_range at all: its eeprom_put_char does its
      own page read-modify-write per byte, and its wrapper interleaves
      checksum accumulation with per-byte puts. Sharing the block form
      there would change what the chip actually does to its flash (and its
      binary), so samd21 keeps its own write wrapper and takes only the
      read half below. Do not "unify" this without first giving samd21 a
      real nvmem_write_range - that is a behavior change, not a cleanup.

  EXTRACTED verbatim from ch32v006/nvmem.c (character-identical in
  ch570/nvmem.c apart from an explanatory comment, and in
  dspic33ak128mc102/nvmem.c apart from a redundant (char) cast; samd21's
  read half was the same logic with if/else instead of a conditional
  expression). Byte-invariance proven on all four consumers.
*/

#ifndef GRBL_PLATFORM_COMMON_NVMEM_CHECKSUM_H
#define GRBL_PLATFORM_COMMON_NVMEM_CHECKSUM_H

#ifdef __AVR__
  #error "common/nvmem_checksum.h is the non-AVR bitwise-rotate form; AVR must keep core grbl/nvmem.c's logical-|| checksum (CONTRACTS.md #10.4)"
#endif

#ifdef GRBL_NVMEM_HAS_WRITE_RANGE
void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  uint8_t checksum = 0;

  if (destination >= EEPROM_SIZE || size >= EEPROM_SIZE ||
      destination + size + 1 > EEPROM_SIZE) { return; }   // drop out-of-range writes (#10.6)

  for (unsigned int i = 0; i < size; i++) {
    checksum = (checksum << 1) | (checksum >> 7);   // bitwise rotate (#10.4 - never the AVR `||`)
    checksum += (uint8_t)source[i];
  }

  // Two calls, not one (data, then checksum) - each re-stages the block
  // from flash into nvmem_write_range's own staging buffer and only
  // actually erases/programs if something changed (wear guard, #10.3). A
  // checksum-only delta after an identical data write is the common case
  // and correctly costs a second stage-and-compare, not a second erase.
  nvmem_write_range(destination, (const uint8_t *)source, size);
  nvmem_write_range(destination + size, &checksum, 1);
}
#endif // GRBL_NVMEM_HAS_WRITE_RANGE

int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    destination[i] = eeprom_get_char(source + i);
    checksum = (checksum << 1) | (checksum >> 7);   // bitwise rotate (#10.4 - never the AVR `||`)
    checksum += (uint8_t)destination[i];
  }

  uint8_t stored_checksum = eeprom_get_char(source + size);
  return (checksum == stored_checksum) ? 1 : 0;
}

#endif // GRBL_PLATFORM_COMMON_NVMEM_CHECKSUM_H
