/*
  nvmem.c - dsPIC33AK128MC102 EEPROM emulation in main program flash
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../../nvmem.h"

#define EEPROM_SIZE       1024u                          // CONTRACTS.md #10.2 minimum
#define NVMEM_BASE        HAL_NVMEM_FLASH_START            // 0x81F800 (physical, platform.h)
#define NVMEM_PAGE_SIZE   HAL_NVMEM_FLASH_PAGE_SIZE         // 2048 (atdf-derived)
#define NVMEM_ROW_SIZE    HAL_NVMEM_FLASH_ROW_SIZE          // 256  (atdf-derived)

// The reserved erase-page window - never placed by the linker's normal
// input-section packing (see file header): a fixed-address, uninitialized
// `const` object claims the address range so `ld` can never place other
// code/data there (would be a hard link error, not silent corruption).
// It is never read or written BY NAME - actual flash access below goes
// through a plain pointer cast to the same physical address, `volatile`-
// qualified because the NVM controller changes flash content underneath
// without going through a normal C store (the compiler must not cache or
// elide repeat reads of it).
static const uint8_t nvmem_reservation[NVMEM_PAGE_SIZE] __attribute__((address(NVMEM_BASE), used));
static volatile const uint8_t * const nvmem_flash = (volatile const uint8_t *)NVMEM_BASE;

// RAM staging buffer for the read-modify-write cycle (file-scope, not on
// the stack - NVMEM_PAGE_SIZE is 2KB, comfortably inside the 16KB RAM
// budget but no reason to risk a stack watermark for a mainline-only,
// infrequent operation).
static uint8_t page_buffer[NVMEM_PAGE_SIZE];

// Flash controller primitives

static void flash_wait_wr(void) {
  while (NVMCONbits.WR) { /* bounded - hardware-timed erase/program op */ }
}

// Whole-page erase (NVMOP=0x3, atdf-verified). page_addr: physical,
// NVMEM_PAGE_SIZE-aligned.
static void flash_erase_page(uint32_t page_addr) {
  NVMCONbits.NVMOP = 0x3;
  NVMADR = page_addr;
  __DSB();                       // BUG #13: order the address store before the commit command
  NVMCONbits.WREN = 1;
  NVMCONbits.WR   = 1;
  flash_wait_wr();
  NVMCONbits.WRERR = 0;          // clear (best-effort - see file header)
  NVMCONbits.WREN = 0;
}

// One row (NVMEM_ROW_SIZE bytes) programmed from a RAM source buffer
// (NVMOP=0x2, atdf-verified: "Memory page row operation", source =
// NVMSRCADR). row_addr/src both real addresses (row_addr physical flash,
// src a RAM pointer).
static void flash_program_row(uint32_t row_addr, const uint8_t *src) {
  NVMCONbits.NVMOP = 0x2;
  NVMADR    = row_addr;
  NVMSRCADR = (uint32_t)(uintptr_t)src;
  __DSB();                       // BUG #13: order address/source stores before the commit command
  NVMCONbits.WREN = 1;
  NVMCONbits.WR   = 1;
  flash_wait_wr();
  NVMCONbits.WRERR = 0;
  NVMCONbits.WREN = 0;
}

// Page-batched RMW write of an arbitrary byte range inside the NVMEM
// window. The window is exactly one erase page, so there is only ever
// one page to consider - simpler than the multi-page general case in
// samd21/stm32_nvmem.c, same shape otherwise: read the whole page from
// flash into RAM, patch it, erase+reprogram at most once and only if
// content actually changed (wear guard, #10.3).
static void nvmem_write_range(unsigned int addr, const uint8_t *src, unsigned int size) {
  uint8_t dirty = 0;

  for (unsigned int i = 0; i < NVMEM_PAGE_SIZE; i++) {
    page_buffer[i] = nvmem_flash[i];
  }
  for (unsigned int i = 0; i < size; i++) {
    if (page_buffer[addr + i] != src[i]) {
      page_buffer[addr + i] = src[i];
      dirty = 1;
    }
  }

  if (!dirty) { return; }

  flash_erase_page(NVMEM_BASE);
  for (unsigned int row = 0; row < NVMEM_PAGE_SIZE; row += NVMEM_ROW_SIZE) {
    flash_program_row(NVMEM_BASE + row, &page_buffer[row]);
  }
}

// Four-function NVMEM API (CONTRACTS.md #10)

unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }   // erased-flash semantics (#10.6)
  return nvmem_flash[addr];
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) { return; }
  nvmem_write_range(addr, &new_value, 1);
}

// Checksum-copy wrappers core GRBL calls (memcpy_to/from_nvmem_with_
// checksum) are shared verbatim with every other non-AVR TU-replacement
// port. GRBL_NVMEM_HAS_WRITE_RANGE opts this port into the block-staging
// write form (samd21, which has no nvmem_write_range, takes only the read
// half). Included HERE, after EEPROM_SIZE/eeprom_get_char/nvmem_write_
// range above, because it is those it operates on. That header also holds
// the CONTRACTS.md #10.4 boundary note: this is the bitwise-`|` rotate,
// and core grbl/nvmem.c's logical-`||` AVR form must never be "fixed".
#define GRBL_NVMEM_HAS_WRITE_RANGE
#include "../common/nvmem_checksum.h"
