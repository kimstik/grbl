/*
  wch_critical.h - mstatus-based critical sections + sei/cli + memory
  Part of Grbl
*/

#ifndef GRBL_PLATFORM_COMMON_WCH_CRITICAL_H
#define GRBL_PLATFORM_COMMON_WCH_CRITICAL_H

// CRITICAL SECTIONS (CONTRACTS.md #8) - save/restore mstatus.MIE (bit 3).
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

// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
// mstatus.MIE = bit 3. "memory" clobber mandatory (CONTRACTS.md #12.6).
#define sei()  __asm volatile ("csrsi mstatus, 8" ::: "memory")
#define cli()  __asm volatile ("csrci mstatus, 8" ::: "memory")

// MEMORY BARRIERS (CONTRACTS.md #12)
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
