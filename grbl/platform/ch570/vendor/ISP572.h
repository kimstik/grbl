/*
  ISP572.h - Flash-ROM/Data-Flash driver ABI (linked object, not a ROM call)
  VENDORED from openwch/ch570 (Apache-2.0, see LICENSE-openwch-ch570-Apache-2.0.txt
  in this directory) - StdPeriphDriver/inc/ISP572.h, trimmed to only the
  symbols this port calls (CMD_FLASH_ROM_ERASE/WRITE + FLASH_EEPROM_CMD).

  CORRECTION (adversarial review this batch, PLAN.md Phase 6 rolling #4
  Part B): earlier drafts of this port's comments called this a "boot-ROM
  call". That was imprecise and is fixed here. `FLASH_EEPROM_CMD` is NOT a
  far call into a separate boot-ROM address range - full disassembly of
  `vendor/ISP572.o` (`riscv64-unknown-elf-objdump -d`) shows it is an
  ordinary, statically-linked function (all its internal calls are
  PC-relative `auipc`/`jalr` to OTHER FUNCTIONS IN THE SAME OBJECT, not to
  any fixed external address) that talks directly to memory-mapped flash-
  controller registers at 0x40001800-0x40001807
  (`R32_FLASH_DATA`/`R32_FLASH_CONTROL`/`R8_FLASH_CTRL`/`R8_FLASH_CFG` -
  all real, datasheet-listed addresses) using an internal byte-level
  command/status protocol on `R8_FLASH_CTRL` (0x40001806) that the public
  datasheet explicitly declines to document (see WHY VENDORED below).

  WHY VENDORED, NOT REIMPLEMENTED (the actual investigated question, not
  assumed): the CH572/CH570 Datasheet V1.1 states, in the paragraph
  immediately before its "4.4 Flash-ROM Operation Steps" section: *"For
  the operation or setting of FlashROM, please refer to related
  subprograms. This datasheet does not provide the introductions to
  FlashROM word data registers and FlashROM control registers."* Section
  4.4 itself: *"1. Erase Flash-ROM, please refer to and call related
  subprograms. 2. Write Flash-ROM, please refer to and call the related
  subprograms."* The vendor is not merely offering a convenience routine
  here - it is stating plainly that the register-level protocol is
  DELIBERATELY UNDOCUMENTED and that calling this exact function is the
  only supported path. Disassembly confirms the function is not a thin
  trampoline either (the "20 instructions of load-address-and-jump" test
  a reviewer should apply before accepting any vendored blob): it saves
  and restores the PFIC interrupt-enable state around the operation
  (`PFIC->ISR`/`IENR` at 0xE000E000, masking all interrupts while flash is
  unreadable - correct and necessary, since the CPU cannot fetch
  instructions from flash during program/erase), validates the requested
  address range against the boot-ROM boundary (0x3C000, this port's own
  `FLASH_USER_SIZE`), dispatches EIGHT distinct sub-commands (erase,
  write, verify, get-ROM-info, get-unique-ID, power up/down, software
  reset, start-I/O - the full `CMD_*` set below), and for erase
  specifically runs a real block-size-selection loop (choosing among
  multiple erase granularities depending on address alignment, then
  iterating over the requested range) - roughly 1.3KB of real control
  flow, not a stub. Because the byte-level protocol it drives has NO
  independent public specification to derive from, transcribing the
  disassembly into new "clean-room" source would not actually be clean
  room - it would be a hand-copy of this exact vendor logic with strictly
  MORE transcription-error risk than linking the vendor's own tested
  object, for no corresponding gain (Apache-2.0 already grants full
  reproduction/modification/redistribution rights, so there is no legal
  reason to paraphrase it into new text). This is, honestly, the first
  vendored BINARY artifact in this project's tree (every other port's
  "vendored with attribution" precedent was header/register-fact text) -
  flagged plainly here, in CONTRACTS.md's CH570 gap-log entry, and in
  PLAN.md, so the project owner can knowingly accept or reject the
  trade-off rather than discover it later.
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
