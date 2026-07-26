/*
  wch_critical.h - mstatus-based critical sections + sei/cli + memory
  barriers, shared across WCH QingKe RISC-V cores
  Part of Grbl

  EXTRACTED (Phase 6 rolling #4, CH570 recon) verbatim from ch32v006's
  Phase 4 platform.h - the macro bodies below are byte-for-byte the same
  text that shipped there (CONTRACTS.md §8/§11/§12), only relocated so a
  second WCH port does not re-derive or copy/paste them. HARD GATE
  (PLAN.md Phase 6 rolling #4 Part A): ch32v006 including this header must
  preprocess to the SAME text as its previous inline copy - verified by
  this batch's rebuild (identical RELEASE text/data).

  Why `mstatus` (not the vendor SDK's raw CSR 0x800) is the right register
  on QingKe V3C too, not just V2C: the CH570 recon (CONTRACTS.md §20 gap
  log, this batch) found the vendor's own `core_riscv.h`
  (__risc_v_enable_irq/__risc_v_disable_irq) reads/writes CSR **0x800**
  with a two-bit mask (0x88) - a DIFFERENT numeric address than the
  standard `mstatus` (0x300) this file uses. That looked, at first, like a
  real hardware difference between V2C and V3C that would make this
  extraction wrong. It is not: WCH's own OFFICIAL startup assembly for
  this exact chip (`startup_CH572.S`, Apache-2.0, openwch/ch570) enables
  interrupts with `li t0, 0x88` / `csrw mstatus, t0` using the STANDARD
  named CSR - the identical instruction and mask this file already used
  for ch32v006. Independently, cnlohr/ch32fun (MIT) uses the same named
  `mstatus` mnemonic uniformly across EVERY QingKe generation it supports,
  V2 through the CH5xx (V3) family CH570 belongs to, and is exercised on
  real hardware by its userbase. Two independent, hardware-facing sources
  agree that `mstatus` (0x300) is the correct, portable primitive under a
  MAINLINE mainline riscv64-unknown-elf-gcc toolchain; the vendor SDK's
  raw-0x800 helpers are written for WCH's OWN forked compiler/runtime
  convention (used internally by their `sys_safe_access_enable/disable()`
  flash-unlock bracket) and are not evidence against using `mstatus` here.
  This project does not reproduce the 0x800 primitive - CH570's nvmem.c
  brackets its safe-access window with these same sei()/cli() macros
  instead, deliberately choosing the one interrupt-gate primitive this
  whole platform layer already trusts over introducing a second, less
  understood one. See CONTRACTS.md §20 gap log entry for this batch.
*/

#ifndef GRBL_PLATFORM_COMMON_WCH_CRITICAL_H
#define GRBL_PLATFORM_COMMON_WCH_CRITICAL_H

// ============================================================================
// CRITICAL SECTIONS (CONTRACTS.md #8) - save/restore mstatus.MIE (bit 3).
// ============================================================================
/*
  Save/restore, not blind disable/enable - critical sections on this
  project's WCH ports run inside RX ISRs on the debug path; an END that
  always re-enables interrupts would corrupt nesting. mstatus.MIE is
  standard RISC-V privileged-spec state (needs Zicsr - see each port's
  Makefile ARCHFLAGS note, CONTRACTS.md #14.1).
*/
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint32_t __hal_mstatus_save; \
  __asm volatile ("csrr %0, mstatus" : "=r" (__hal_mstatus_save)); \
  __asm volatile ("csrci mstatus, 8" ::: "memory")

#define HAL_CRITICAL_SECTION_END() \
  __asm volatile ("csrw mstatus, %0" : : "r" (__hal_mstatus_save) : "memory")

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
// ============================================================================
// mstatus.MIE = bit 3. "memory" clobber mandatory (CONTRACTS.md #12.6).
#define sei()  __asm volatile ("csrsi mstatus, 8" ::: "memory")
#define cli()  __asm volatile ("csrci mstatus, 8" ::: "memory")

// ============================================================================
// MEMORY BARRIERS (CONTRACTS.md #12)
// ============================================================================
/*
  `fence rw,rw` orders all prior loads/stores against all subsequent ones -
  the architecturally correct primitive for the #12.1 ring-buffer publish
  and #12.4 flash-commit lessons, regardless of whether a given QingKe
  core's in-order pipeline would reorder in practice (neither the V2C nor
  V3C TRM states this either way - correctness-first stance kept on both).
  Note: masking interrupts via PFIC_IENRx/IRERx needs a SEPARATE `fence.i`
  for core/PFIC state sync (wch_pfic.h's PFIC_DisableIRQ) - a different
  instruction from these data fences, not interchangeable with them.
*/
#define __DSB() __asm volatile ("fence rw, rw" ::: "memory")
#define __DMB() __asm volatile ("fence rw, rw" ::: "memory")

#endif // GRBL_PLATFORM_COMMON_WCH_CRITICAL_H
