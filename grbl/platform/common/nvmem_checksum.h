/*
  nvmem_checksum.h - the chip-agnostic checksum-copy wrappers core GRBL
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
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
