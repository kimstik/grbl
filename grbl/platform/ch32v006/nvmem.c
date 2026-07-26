/*
  nvmem.c - CH32V006 EEPROM emulation in main flash (TU-replacement route)
  Part of Grbl

  PORTING-CHECKLIST Step 5, CONTRACTS.md #10. samd21/nvmem.c is the
  structural reference; the flash controller here is WCH's fast-page
  model (RM 18.4, TRM-verified this session):

  - 256-byte pages, program AND erase are whole-page only - there is no
    F1-style halfword PG mode on V00X main flash.
  - Two lock layers: LOCK (FLASH_KEYR) gates the FPEC, FLOCK
    (FLASH_MODEKEYR) gates fast page mode. Keys 0x45670123/0xCDEF89AB.
  - Program sequence (RM 18.4.5): FTPG -> BUFRST (+BSY wait) -> 64 x
    { 32-bit store to the page address, BUFLOAD, BSY wait } -> ADDR ->
    STRT -> BSY wait. Erase (RM 18.4.6): FTER -> ADDR -> STRT -> BSY wait.
  - Programming addresses are PHYSICAL (0x08xxxxxx); reads below use the
    same alias for symmetry.

  Region: last 1 KB of the 62 KB flash (pages 244-247, 0x0800F400+),
  reserved out of script.ld's FLASH region so code can never collide.

  Wear model: writes are page-granular read-modify-write, batched per
  page by nvmem_write_range() - a bulk settings write touches each
  affected 256-byte page ONCE (erase+program), not once per byte. This is
  still a synchronous, blocking path (#10.1: no deferred/background
  writes - settings_read may follow immediately).

  BUG #13 fence discipline (#10.5 / #12.4): __DSB() (fence rw,rw) between
  buffer-fill stores and every commit-command MMIO write; BSY polled to
  completion after every command. RM note: HSI must be running during
  program/erase - it is never turned off by this port.

  Context contract (#10.1): mainline only, interrupts enabled, blocking
  allowed. While an erase/program is in progress the flash stalls - ISRs
  (whose code lives in flash) stall with it; tolerated because settings
  writes only happen during `$` commands in IDLE/ALARM.
*/

#include <stdint.h>
#include "platform.h"
#include "../../nvmem.h"

#define EEPROM_SIZE       HAL_NVMEM_FLASH_SIZE          // 1024
#define NVMEM_BASE        HAL_NVMEM_FLASH_START         // 0x0800F400 (physical)
#define NVMEM_PAGE_SIZE   HAL_NVMEM_FLASH_PAGE_SIZE     // 256

// ----------------------------------------------------------------------------
// Flash controller primitives
// ----------------------------------------------------------------------------

static void flash_wait_busy(void) {
  while (FLASH->STATR & FLASH_STATR_BSY) { /* spin - bounded by hardware op time */ }
}

static void flash_clear_eop(void) {
  if (FLASH->STATR & FLASH_STATR_EOP) { FLASH->STATR = FLASH_STATR_EOP; }  // write-1-clear
}

// Unlock both lock layers (LOCK via KEYR, FLOCK via MODEKEYR - RM 18.4.4).
// Key writes must be consecutive; a botched sequence locks until reset,
// which shows up loudly in the Step 5 exit test (settings fail to save).
static void flash_unlock(void) {
  if (FLASH->CTLR & FLASH_CTLR_LOCK) {
    FLASH->KEYR = FLASH_KEY1;
    FLASH->KEYR = FLASH_KEY2;
  }
  if (FLASH->CTLR & FLASH_CTLR_FLOCK) {
    FLASH->MODEKEYR = FLASH_KEY1;
    FLASH->MODEKEYR = FLASH_KEY2;
  }
}

static void flash_lock(void) {
  FLASH->CTLR |= FLASH_CTLR_FLOCK;   // re-lock fast mode (software sets 1)
  FLASH->CTLR |= FLASH_CTLR_LOCK;    // re-lock FPEC
}

// Fast page erase, 256 bytes (RM 18.4.6). page_addr: physical, 256-aligned.
static void flash_erase_page(uint32_t page_addr) {
  flash_wait_busy();
  FLASH->CTLR |= FLASH_CTLR_FTER;
  FLASH->ADDR = page_addr;
  __DSB();                            // BUG #13: order prior stores before commit
  FLASH->CTLR |= FLASH_CTLR_STRT;
  flash_wait_busy();
  flash_clear_eop();
  FLASH->CTLR &= ~FLASH_CTLR_FTER;
}

// Fast page program, 256 bytes from data[] (RM 18.4.5).
static void flash_program_page(uint32_t page_addr, const uint8_t *data) {
  flash_wait_busy();
  FLASH->CTLR |= FLASH_CTLR_FTPG;

  FLASH->CTLR |= FLASH_CTLR_BUFRST;   // clear the internal 256-byte buffer
  flash_wait_busy();
  flash_clear_eop();

  for (uint32_t i = 0; i < NVMEM_PAGE_SIZE; i += 4) {
    uint32_t word = (uint32_t)data[i]
                  | ((uint32_t)data[i + 1] << 8)
                  | ((uint32_t)data[i + 2] << 16)
                  | ((uint32_t)data[i + 3] << 24);
    *(volatile uint32_t *)(page_addr + i) = word;   // stage into page buffer
    __DSB();                          // BUG #13: staging store before BUFLOAD command
    FLASH->CTLR |= FLASH_CTLR_BUFLOAD;
    flash_wait_busy();
  }

  FLASH->ADDR = page_addr;
  __DSB();
  FLASH->CTLR |= FLASH_CTLR_STRT;
  flash_wait_busy();
  flash_clear_eop();
  FLASH->CTLR &= ~FLASH_CTLR_FTPG;
}

// Page-batched RMW write of an arbitrary byte range inside the NVMEM
// window. Each affected page is erased+programmed at most once, and only
// if its content actually changes (wear guard, #10.3).
static void nvmem_write_range(unsigned int addr, const uint8_t *src, unsigned int size) {
  while (size > 0) {
    uint32_t byte_addr   = NVMEM_BASE + addr;
    uint32_t page_addr   = byte_addr & ~(uint32_t)(NVMEM_PAGE_SIZE - 1);
    uint32_t page_offset = byte_addr & (uint32_t)(NVMEM_PAGE_SIZE - 1);
    uint32_t chunk       = NVMEM_PAGE_SIZE - page_offset;
    if (chunk > size) { chunk = size; }

    uint8_t page_buffer[NVMEM_PAGE_SIZE];
    uint8_t dirty = 0;
    for (uint32_t i = 0; i < NVMEM_PAGE_SIZE; i++) {
      page_buffer[i] = *(const volatile uint8_t *)(page_addr + i);
    }
    for (uint32_t i = 0; i < chunk; i++) {
      if (page_buffer[page_offset + i] != src[i]) {
        page_buffer[page_offset + i] = src[i];
        dirty = 1;
      }
    }

    if (dirty) {
      flash_unlock();
      flash_erase_page(page_addr);
      flash_program_page(page_addr, page_buffer);
      flash_lock();
    }

    addr += chunk;
    src  += chunk;
    size -= chunk;
  }
}

// ----------------------------------------------------------------------------
// Four-function NVMEM API (CONTRACTS.md #10)
// ----------------------------------------------------------------------------

unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }   // erased-flash semantics (#10.6)
  return *(const volatile uint8_t *)(NVMEM_BASE + addr);
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
