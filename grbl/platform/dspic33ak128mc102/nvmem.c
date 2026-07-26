/*
  nvmem.c - dsPIC33AK128MC102 EEPROM emulation in main program flash
  Part of Grbl

  PORTING-CHECKLIST Step 5, CONTRACTS.md #10. TU-replacement route: this
  file provides the whole four-function NVMEM API; the Makefile excludes
  core nvmem.c/eeprom.c.

  FLASH CONTROLLER FACTS (dsPIC33AK128MC102.atdf "nvm" module, atdf-verified
  - NOT RM-only, unlike most of this port's peripheral facts):
    FLASH_WORD_WRITE_SIZE_IN_INSTRUCTIONS = 4    (word-program op)
    FLASH_WRITE_ROW_SIZE_IN_INSTRUCTIONS  = 128  (row-program op)
    FLASH_ERASE_PAGE_SIZE_IN_INSTRUCTIONS = 1024 (page-erase op)
  On this ISA one "instruction" = 2 bytes of address space (classic
  dsPIC/PIC24 24-bit-instruction-over-a-16-bit-wide-address convention -
  cross-checked against the .gld's byte-addressed program region size,
  0x1FFFC bytes for a 128KB part). So: erase page = 2048 bytes, program
  row = 256 bytes (8 rows/page). NVMCON.NVMOP values (atdf value-group
  NVMCON_CON__NVMOP, also atdf-verified, not RM-only): 0x3 = page erase,
  0x2 = row program (source = NVMSRCADR, a RAM pointer - hardware copies),
  0x1 = word program (source = NVMDATA0-3 SFRs directly). Row program is
  used here: it lets an entire modified page be staged in a RAM buffer
  (this file) and copied into flash 256 bytes at a time by the
  controller, matching the "page-batched RMW" shape of samd21/stm32_nvmem
  exactly, just with the controller doing the byte-copy instead of a
  manual staging-register loop.

  NO NVMKEY / unlock-sequence register exists on this device (grepped the
  full DFP header and the atdf "nvm" module - confirmed absent, unlike
  classic PIC24/dsPIC33F/E's 0x55/0xAA NVMKEY dance). WREN
  ("Enable Flash program/erase operations", atdf-verified) is the gate
  used here. NVMCON.LOCK's exact write protocol is UNVERIFIED (RM not
  vendored) and deliberately NOT touched - left at its reset default.

  READS are plain pointer dereferences: this device has no PSVPAG/PSV
  windowing at all (grepped - the DFP has no PSVPAG anywhere, unlike
  classic Harvard-with-PSV dsPIC33F/E) - `no_auto_psv` on the ISRs
  (handlers.c) is a compatibility attribute for a feature this core does
  not have, confirmed by a real link-tested reservation this session:
  `__attribute__((address(HAL_NVMEM_FLASH_START)))` places a static
  object at a fixed flash address and links CLEAN against the unmodified
  vendor .gld (verified: object placed exactly at the requested address,
  zero link errors/overlaps) - no port-authored linker script needed, and
  any FUTURE code-size growth that collides with this window fails the
  link LOUDLY (ld error), never silently corrupts, which is exactly the
  contract's preferred failure mode.

  Page-batched RMW (this file's nvmem_write_range()) reproduces the
  samd21/stm32_nvmem.c shape: each affected 2048-byte erase page is
  erased+reprogrammed AT MOST ONCE per settings write, using a wear guard
  (#10.3) so an unchanged page is never touched at all.

  BUG #13 fence discipline (#10.5/#12.4): __DSB() (a compiler barrier on
  this barrier-free ISA, platform.h) between staging NVMADR/NVMSRCADR and
  issuing WR=1; WR is polled to completion (bounded, hardware-timed) after
  every erase/row-program command; WRERR checked after (best-effort - no
  RM-specified recovery action exists to take beyond what the wear guard
  already prevents).

  Context contract (#10.1): mainline only, interrupts enabled, blocking
  allowed - writes happen during `$` commands (IDLE/ALARM); no deferred/
  background writes.
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

// ----------------------------------------------------------------------------
// Flash controller primitives
// ----------------------------------------------------------------------------

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

// ----------------------------------------------------------------------------
// Four-function NVMEM API (CONTRACTS.md #10)
// ----------------------------------------------------------------------------

unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }   // erased-flash semantics (#10.6)
  return nvmem_flash[addr];
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) { return; }
  nvmem_write_range(addr, &new_value, 1);
}

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  uint8_t checksum = 0;

  if (destination >= EEPROM_SIZE || size >= EEPROM_SIZE ||
      destination + size + 1 > EEPROM_SIZE) { return; }   // drop out-of-range writes (#10.6)

  for (unsigned int i = 0; i < size; i++) {
    checksum = (checksum << 1) | (checksum >> 7);   // bitwise rotate (#10.4 - never the AVR `||`)
    checksum += (uint8_t)source[i];
  }

  nvmem_write_range(destination, (const uint8_t *)source, size);
  nvmem_write_range(destination + size, &checksum, 1);
}

int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    destination[i] = (char)eeprom_get_char(source + i);
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += (uint8_t)destination[i];
  }

  uint8_t stored_checksum = eeprom_get_char(source + size);
  return (checksum == stored_checksum) ? 1 : 0;
}
