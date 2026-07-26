/*
  ISP572.h - Flash-ROM/Data-Flash driver ABI (linked object, not a ROM call)
  VENDORED from openwch/ch570 (Apache-2.0, see LICENSE-openwch-ch570-Apache-2.0.txt
  in this directory) - StdPeriphDriver/inc/ISP572.h, trimmed to only the
  symbols this port calls (CMD_FLASH_ROM_ERASE/WRITE + FLASH_EEPROM_CMD).

  WHY VENDORED, NOT REIMPLEMENTED: Datasheet V1.1 §4.4 declines to document
  the FlashROM data/control registers at all ("please refer to related
  subprograms"), so the byte protocol `FLASH_EEPROM_CMD` drives on
  R8_FLASH_CTRL (0x40001806) has NO independent public specification -
  "clean-room" source would be a hand-copy of this vendor logic with more
  transcription risk and no legal gain (Apache-2.0 already grants
  reproduction/modification/redistribution). Not a trampoline: ~1.3KB of
  real control flow, statically linked, eight CMD_* sub-commands. This is
  the tree's FIRST vendored BINARY artifact (prior precedent was register-
  fact text only) - flagged here, in CONTRACTS.md's CH570 gap-log and in
  PLAN.md so the owner can accept or reject it knowingly. Disassembly
  evidence: ch570/platform.md.
*/

#ifndef GRBL_PLATFORM_CH570_VENDOR_ISP572_H
#define GRBL_PLATFORM_CH570_VENDOR_ISP572_H

#include <stdint.h>

#define CMD_FLASH_ROM_ERASE   0x01   // erase FlashROM block, return 0 if success, @StartAddr,Length
#define CMD_FLASH_ROM_WRITE   0x02   // write FlashROM data block (dword-multiple), @StartAddr,Buffer,Length

#define FLASH_BLOCK_SIZE      4096u  // erase granularity (PLAN.md CH570 recon: "4096-byte erase blocks")
#define FLASH_MIN_WR_SIZE     4u     // minimum/alignment unit for writes (one dword)

// Implemented in vendor/ISP572.o (linked by this port's Makefile) - real
// WCH flash-controller sequencing, not something this port reimplements.
// Buffer must be RAM, 4-byte aligned. Returns 0 on success.
extern uint32_t FLASH_EEPROM_CMD(uint8_t cmd, uint32_t StartAddr, void *Buffer, uint32_t Length);

#endif // GRBL_PLATFORM_CH570_VENDOR_ISP572_H
