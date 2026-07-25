/*
  platform.h - CH32V006 chip-specific HAL
  Part of Grbl

  RISC-V RV32EC (QingKe V2C core), 48 MHz max, PFIC interrupt controller
  (WCH vendor fast-interrupt scheme - NOT CLINT/PLIC). Ported from
  `_template` + grbl/platform/CONTRACTS.md + PORTING-CHECKLIST.md per
  PLAN.md Phase 4 ("first battle test of _template"). Every macro this
  file cannot implement without a verified chip fact still expands to a
  call to an undeclared PORT_TODO_<name>() - CONTRACTS.md's "no silent
  no-op stubs, ever" (the cautionary tale: STP_TMR_PRESCALER_SET as an
  empty comment on SAMD21).

  This batch (Phase 4 M1-M3) implements Steps 0-2 for real (skeleton,
  clock, GPIO) and leaves Steps 3-6 (timers/serial/nvmem/handlers) as
  PORT_TODO, same shape as _template - that is by design, not a shortcut:
  M3's exit test is "compiles, link shows PORT_TODO_* for
  serial/nvmem/timers".
*/

#ifndef PLATFORM_CH32V006_H
#define PLATFORM_CH32V006_H

#include <stdint.h>
#include "ch32v006.h"
#include "timer.h"

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

// hal.h pre-defines PLATFORM_NAME "CH32V006" before including this file
// (grbl/platform/hal.h); refine it here the same way stm32f103/platform.h
// does.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "CH32V006"
#define PLATFORM_CPU      "RISC-V RV32EC (QingKe V2C)"
#define PLATFORM_ARCH     "RISC-V"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define PLATFORM_HAS_FPU           0   // no FPU
#define PLATFORM_HAS_DMA           1   // WCH V00x family has a DMA1 block (unused by this port)
#define PLATFORM_HAS_USB           0
#define PLATFORM_HAS_HW_EEPROM     0   // flash emulation via nvmem.c (CONTRACTS.md #10)
#define PLATFORM_HAS_HW_MULTIPLY   0   // rv32eC has no M extension (PLAN.md toolchain recon)
#define PLATFORM_HAS_HW_DIVIDE     0

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

// F_CPU feeds TICKS_PER_MICROSECOND (nuts_bolts.h) and all stepper timing
// math (PORTING-CHECKLIST Step 1) - a lie here breaks every later step
// invisibly. Verified path for this batch: HSI (24 MHz, family-standard
// per CH32V00x public references) x2 fixed-ratio PLL = 48 MHz - see
// SystemInit() in startup.c. Actual silicon speed NOT scope-verified in
// this session (no hardware) - Renode/scope verification is Phase-4
// follow-up, same posture SAMD21 had before its own Renode smoke test.
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

#define RAM_SIZE          8192        // 8 KB  - PLAN.md Decision Log figure, UNVERIFIED against a real TRM this session
#define FLASH_SIZE         63488       // 62 KB - ditto
#define HAL_EEPROM_SIZE   0            // no hardware EEPROM

// ============================================================================
// TYPE DEFINITIONS (must be before hal_gpio.h include)
// ============================================================================

typedef GPIO_TypeDef* hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// ============================================================================
// FLASH EMULATION FOR EEPROM (Step 5 - not implemented this batch)
// ============================================================================

#define HAL_NVMEM_FLASH_SIZE       1024
#define HAL_NVMEM_FLASH_START      (FLASH_BASE + FLASH_SIZE - HAL_NVMEM_FLASH_SIZE)
#define HAL_NVMEM_FLASH_PAGE_SIZE  64   // UNVERIFIED page size for V006 (V003 family value)

// ============================================================================
// GPIO INTERRUPTS (CONTRACTS.md #2) - Step 6, not implemented this batch.
// ============================================================================
/*
  GPIO_INT_ON/OFF are called REPEATEDLY at runtime (homing disables hard
  limits; settings writes re-enable them) - a "handled at init only"
  no-op is ILLEGAL (limits.c:102-105). Left as PORT_TODO (undefined
  reference at link time) rather than empty, per CONTRACTS.md's
  cautionary tale - this is exactly the class of bug that design exists
  to catch.
*/
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   PORT_TODO_GPIO_INT_ON(pcmsk, interrupt, mask)
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  PORT_TODO_GPIO_INT_OFF(pcmsk, interrupt, mask)

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h is its
// single owner (CONTRACTS.md #2.2); a platform-local redefinition would be
// silently shadowed in every core TU.

// ============================================================================
// CRITICAL SECTIONS (CONTRACTS.md #8) - real implementation, not PORT_TODO.
// ============================================================================
/*
  Save/restore mstatus.MIE (bit 3), not blind disable/enable - the pair
  runs inside the RX ISR on the debug path (serial.c:153); an END that
  always re-enables interrupts would corrupt nesting. mstatus.MIE is
  standard RISC-V privileged-spec state (not a QingKe extension), so this
  is correct on any RV32/64 core, same as the ARM PRIMASK pattern in
  samd21/_template. Needs Zicsr (csrr/csrs/csrc) - see the Makefile's
  ARCHFLAGS comment: `-march=rv32ec` ALONE rejects these opcodes on this
  toolchain (binutils enforces Zicsr as a separate, non-implied
  extension); `_zicsr` must be appended. GAP found empirically this
  session, folded into CONTRACTS.md.
*/
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint32_t __hal_mstatus_save; \
  __asm volatile ("csrr %0, mstatus" : "=r" (__hal_mstatus_save)); \
  __asm volatile ("csrci mstatus, 8" ::: "memory")

#define HAL_CRITICAL_SECTION_END() \
  __asm volatile ("csrw mstatus, %0" : : "r" (__hal_mstatus_save) : "memory")

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11) - real implementation.
// ============================================================================
// mstatus.MIE = bit 3. "memory" clobber mandatory (CONTRACTS.md #12.6) -
// the compiler barrier that keeps stores from floating across the
// interrupt-enable boundary.
#define sei()  __asm volatile ("csrsi mstatus, 8" ::: "memory")
#define cli()  __asm volatile ("csrci mstatus, 8" ::: "memory")

// ============================================================================
// MEMORY BARRIERS (CONTRACTS.md #12)
// ============================================================================
/*
  QingKe V2C is a single in-order pipeline with no store buffer / no
  documented weak-memory reordering of ordinary loads/stores (unlike
  Cortex-M's occasional posted-write buffering) - HOWEVER this is NOT
  independently verified against the CH32V006 TRM in this session, and
  the RISC-V base ISA's `fence` instruction is the architecturally
  correct primitive regardless: `fence rw,rw` orders all prior
  loads/stores against all subsequent ones, which is what __DSB()/__DMB()
  need to guarantee (CONTRACTS.md #12.1 ring-buffer lesson, #12.4 NVM
  commit lesson). Kept as two distinct names (matching every ARM port)
  for macro-compatibility even though RISC-V has only one fence - GAP:
  if QingKe is confirmed strictly in-order with no store buffering, these
  could legally become compiler-barrier-only (no actual fence
  instruction needed); left as real `fence` for correctness-first since
  that confirmation does not exist yet.
*/
#define __DSB() __asm volatile ("fence rw, rw" ::: "memory")
#define __DMB() __asm volatile ("fence rw, rw" ::: "memory")

// ============================================================================
// WATCHDOG (CONTRACTS.md #9)
// ============================================================================
// Deliberately UNDEFINED (only compiled under ENABLE_SOFTWARE_DEBOUNCE,
// default off) - a no-op here is ILLEGAL per contract when that option is
// on; leaving the macros absent gives a loud compile failure instead.

#endif // PLATFORM_CH32V006_H
