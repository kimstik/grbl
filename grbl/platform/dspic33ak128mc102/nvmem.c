/*
  nvmem.c - dsPIC33AK128MC102 EEPROM emulation (M1-M3: hardware = PORT_TODO)
  Part of Grbl

  TU-replacement route (CONTRACTS.md #0/#10): provides the four-function
  NVMEM API core settings.c needs; this platform's Makefile excludes core
  nvmem.c/eeprom.c. Bounds-checking, wear guard and bulk checksum loops
  are chip-agnostic (from _template/nvmem.c); only the two innermost
  primitives are PORT_TODO for Step 5, which must first mine the RM for:
    - program-flash page size / erase granularity (do NOT size the
      logical window before knowing it - CONTRACTS.md #15.4 lesson);
    - the NVMCON/NVMKEY unlock + command sequence and its BUSY/WR poll;
    - whether an SFR readback is needed between page-buffer fill and the
      commit command (this chip's analog of the BUG #13 __DSB - see
      platform.h's memory-model note);
    - reserving the window pages from the .gld `program` region (the DFP
      script does NOT reserve anything - likely a small local wrapper
      script or a section pragma; decide in Step 5).

  Context (#10.1): mainline only, interrupts enabled, never called from
  ISR. Checksum fidelity (#10.4): bitwise `|` here, never the AVR `||`
  quirk.
*/

#include <stdint.h>
#include "platform.h"
#include "../../nvmem.h"

// CONTRACTS.md #10.2: at least 1 KB flat, byte-addressable, address 0
// valid. Logical size only - the PORT_TODO primitives own the physical
// flash layout.
#define EEPROM_SIZE 1024

// Out-of-range reads return 0xFF, writes are dropped (#10.6 - matches
// erased-flash semantics).
unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }
  return PORT_TODO_NVMEM_READ_BYTE(addr);
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) { return; }

  // Wear guard (#10.3): skip writes that would not change the stored byte.
  if (PORT_TODO_NVMEM_READ_BYTE(addr) == new_value) { return; }

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
