/*
  nvmem.c - _template EEPROM emulation (copy-me starting point)
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../../nvmem.h"

#warning "PORT-TODO: nvmem.c"

// CONTRACTS.md §10.2: at least 1 KB flat, byte-addressable, address 0 valid
// (AVR's HAL_EEPROM_SIZE is 1024 - atmega328p/platform.h:41). This is a
// logical size only; PORT_TODO_NVMEM_READ_BYTE/WRITE_BYTE own the real
// flash address layout internally (page size, erase granularity, the
// reserved region at the top of flash, ...) - nothing above them needs to
// know it.
#define EEPROM_SIZE 1024

// Out-of-range reads return 0xFF, writes are dropped (§10.6 - matches
// erased-flash semantics; core never reads out of range in practice).
unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }
  return PORT_TODO_NVMEM_READ_BYTE(addr);
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) { return; }

  // Wear guard (§10.3): skip writes that would not change the stored byte.
  // Flash erase/write cycles are finite; AVR hardware does this
  // selectively, we do it explicitly.
  if (PORT_TODO_NVMEM_READ_BYTE(addr) == new_value) { return; }

  // PORT_TODO_NVMEM_WRITE_BYTE must itself: fill a page buffer, __DSB()
  // between the fill and the commit command (§10.5/§12.4, BUG #13 - a
  // weakly-ordered core can issue the MMIO commit before the page-buffer
  // stores complete), then poll the controller's READY/busy flag before
  // returning. None of that is expressible generically here because page
  // size and command sequencing are chip-specific.
  PORT_TODO_NVMEM_WRITE_BYTE(addr, new_value);
}

// Bulk write with checksum - real, working code; only the per-byte
// primitive above is a stand-in.
void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += source[i];
    eeprom_put_char(destination + i, source[i]);
  }

  eeprom_put_char(destination + size, checksum);
}

// Bulk read with checksum verification - real, working code.
int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    destination[i] = eeprom_get_char(source + i);
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += destination[i];
  }

  uint8_t stored_checksum = eeprom_get_char(source + size);
  return (checksum == stored_checksum) ? 1 : 0;
}
