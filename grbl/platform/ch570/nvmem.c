/*
  nvmem.c - CH570 EEPROM emulation in main flash (TU-replacement route)
  Part of Grbl
*/

#include <stdint.h>
#include <string.h>
#include "platform.h"
#include "vendor/ISP572.h"
#include "../../nvmem.h"

#define EEPROM_SIZE       HAL_NVMEM_FLASH_SIZE          // 4096
#define NVMEM_BASE        HAL_NVMEM_FLASH_START         // FLASH_USER_SIZE - 4096
#define NVMEM_BLOCK_SIZE  HAL_NVMEM_FLASH_PAGE_SIZE      // 4096 (one block == the whole window)

_Static_assert(HAL_NVMEM_FLASH_SIZE == FLASH_BLOCK_SIZE,
               "CH570 NVMEM window must be exactly one erase block (4096B) - see ch570.h");

// Region write-enable bracket (RB_ROM_CODE_WE + RB_ROM_CTRL_EN, RWA/SAM).
// Narrower-than-full grant (0x40, "129-240K") for the MARGINS around the
// FLASH_EEPROM_CMD call only - it does NOT narrow access during the call
// itself, since FLASH_START (called internally by both the erase and
// write paths) unconditionally re-widens this same register to 0xC0
// ("0-240K") every time. See this file's header for the disassembly
// evidence - kept as harmless defense-in-depth for the margins, not
// claimed as protection for the operation itself.
static void nvmem_region_unlock(void) {
  CH570_SAFE_ACCESS_BEGIN();
  R8_GLOB_ROM_CFG = (uint8_t)((R8_GLOB_ROM_CFG & ~RB_ROM_CODE_WE) | 0x40u /* 129-240K, margins only - see header */ | RB_ROM_CTRL_EN);
  CH570_SAFE_ACCESS_END();
}

static void nvmem_region_lock(void) {
  CH570_SAFE_ACCESS_BEGIN();
  R8_GLOB_ROM_CFG = (uint8_t)(R8_GLOB_ROM_CFG & ~(RB_ROM_CODE_WE | RB_ROM_CTRL_EN));
  CH570_SAFE_ACCESS_END();
}

// Page(block)-batched RMW write of an arbitrary byte range inside the
// NVMEM window. The whole window IS one erase block on this chip (4096B,
// no sub-page granularity to exploit), so any dirty byte forces a
// whole-block erase+program - same wear-guard discipline (skip if
// nothing actually changed) as every other port's nvmem.c.
static void nvmem_write_range(unsigned int addr, const uint8_t *src, unsigned int size) {
  static uint8_t block_buffer[NVMEM_BLOCK_SIZE];
  uint8_t dirty = 0;

  for (uint32_t i = 0; i < NVMEM_BLOCK_SIZE; i++) {
    block_buffer[i] = *(const volatile uint8_t *)(FLASH_BASE + NVMEM_BASE + i);
  }
  for (unsigned int i = 0; i < size; i++) {
    if (block_buffer[addr + i] != src[i]) {
      block_buffer[addr + i] = src[i];
      dirty = 1;
    }
  }
  if (!dirty) { return; }

  __DSB();   // BUG #13: staging buffer fully written before the vendor
             // routine (which reads it) is invoked.

  nvmem_region_unlock();
  FLASH_EEPROM_CMD(CMD_FLASH_ROM_ERASE, NVMEM_BASE, NULL, NVMEM_BLOCK_SIZE);
  FLASH_EEPROM_CMD(CMD_FLASH_ROM_WRITE, NVMEM_BASE, block_buffer, NVMEM_BLOCK_SIZE);
  nvmem_region_lock();
}

// Four-function NVMEM API (CONTRACTS.md #10)

unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }   // erased-flash semantics (#10.6)
  return *(const volatile uint8_t *)(FLASH_BASE + NVMEM_BASE + addr);
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
