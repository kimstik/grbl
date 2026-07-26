/*
  nvmem.c - CH570 EEPROM emulation in main flash (TU-replacement route)
  Part of Grbl

  CONTRACTS.md #10. Materially different flash IP from ch32v006
  (PLAN.md recon): 4096-byte erase blocks (not 256B pages), and
  write/erase go through a real, linked vendor function (`FLASH_EEPROM_CMD`,
  vendor/ISP572.o - NOT a boot-ROM call, see vendor/ISP572.h's header for
  the full investigation and why this port vendors the algorithm instead
  of reimplementing it), gated by:
    1. the "safe access" SIG1/SIG2 unlock (ch570.h's
       CH570_SAFE_ACCESS_BEGIN/END, ~112-cycle window per write), AND
    2. R8_GLOB_ROM_CFG's RB_ROM_CODE_WE region-write-enable field.

  CORRECTION (adversarial review this batch): an earlier draft of this
  file set RB_ROM_CODE_WE to "enable 129-240K" (0x40) here believing that
  was the operative grant for the whole erase/write operation - narrower
  than "enable 0-240K" (0xC0), on a least-privilege theory. Disassembly +
  relocation analysis of vendor/ISP572.o
  (`riscv64-unknown-elf-readelf -r ISP572.o`) shows this does NOT hold:
  both `FLASH_CMD_ROM_WRITE` and `FLASH_CMD_ROM_ERASE` call `FLASH_START`
  as their FIRST action, and `FLASH_START` itself unconditionally ORs
  R8_GLOB_ROM_CFG with 0xE0 (0xC0 RB_ROM_CODE_WE + 0x20 RB_ROM_CTRL_EN) -
  i.e. the vendor code re-widens access to the FULL 0-240K region every
  time, regardless of what this file sets beforehand. The narrower grant
  below therefore protects only the (very short) margins immediately
  before/after the `FLASH_EEPROM_CMD` call, NOT the actual erase/write
  window itself - stated honestly rather than left as a false
  least-privilege claim. It is kept anyway as cheap, harmless
  defense-in-depth for those margins (a stray write elsewhere in this
  file reaching a RWA register would still be narrower-scoped), not
  because it changes what happens during the real operation.

  Region: last 4KB of the 240KB user flash (HAL_NVMEM_FLASH_START,
  platform.h), reserved out of script.ld's FLASH region so code can never
  collide with it.

  Wear model: same page(here: block)-granular read-modify-write batching
  as every other port's nvmem.c - a bulk settings write touches the
  4KB block ONCE (erase+program), not once per byte.

  BUG #13 fence discipline (#10.5/#12.4): __DSB() between the RAM staging
  buffer being filled and the FLASH_EEPROM_CMD call that reads it (the
  vendor routine reads Buffer from RAM - CONTRACTS' "commit after store,
  not before" lesson applies to the argument buffer here, not to MMIO
  writes directly, since the whole erase/program sequence is opaque
  vendor code).

  Context contract (#10.1): mainline only, interrupts enabled outside the
  safe-access brackets, blocking allowed - settings writes only happen
  during `$` commands in IDLE/ALARM, same as every other port. NOTE:
  `FLASH_EEPROM_CMD` itself additionally masks ALL PFIC interrupts for the
  duration of the actual erase/write (confirmed by disassembly - it saves
  and clears PFIC->IENR, restoring it on return), which is necessary
  regardless of this file's own interrupt state, since the CPU cannot
  fetch code from flash while it is being programmed/erased.
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

// ----------------------------------------------------------------------------
// Region write-enable bracket (RB_ROM_CODE_WE + RB_ROM_CTRL_EN, RWA/SAM).
// Narrower-than-full grant (0x40, "129-240K") for the MARGINS around the
// FLASH_EEPROM_CMD call only - it does NOT narrow access during the call
// itself, since FLASH_START (called internally by both the erase and
// write paths) unconditionally re-widens this same register to 0xC0
// ("0-240K") every time. See this file's header for the disassembly
// evidence - kept as harmless defense-in-depth for the margins, not
// claimed as protection for the operation itself.
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Four-function NVMEM API (CONTRACTS.md #10)
// ----------------------------------------------------------------------------

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
