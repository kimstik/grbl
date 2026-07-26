/*
  cortexm_critical.h - PRIMASK-based critical sections + sei/cli, shared
  across every ARM Cortex-M port in this tree
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  EXTRACTED verbatim from the four ports that had byte-identical copies of
  this text inline - stm32f103, stm32f411, stm32h523, hc32f460 - following
  the common/wch/wch_critical.h precedent (Phase 6 rolling #4). The macro
  bodies below are the SAME text those ports shipped; only their location
  changed, so every consumer preprocesses to what it did before. HARD GATE
  for this extraction: all four ports' RELEASE .bin MD5 unchanged against
  artifacts/<port>/ (CONTRACTS.md #build-artifacts-tracked).

  WHY THIS HEADER IS INJECTED BY prelude.h, NOT INCLUDED BY platform.h
  (the one non-obvious thing here): grbl.h includes <avr/io.h> at its line
  29, LONG before platform/hal.h -> platform.h at line 49. The shared AVR
  stub common/dummy/avr/io.h deliberately `#error`s when sei()/cli() are
  not already defined, because it cannot know a given chip's interrupt
  primitive. So sei/cli must exist BEFORE grbl.h is parsed. Two ways exist
  to arrange that, and both are used in this tree:

    - samd21 injects ../platform.h itself from its prelude (so platform.h's
      own sei/cli land early);
    - stm32f103/f411/h523 + hc32f460 have no platform.h in their prelude, so
      each previously carried a LOCAL avr/io.h that shadowed the shared stub
      via `-I.` preceding `-I../common/dummy`. Those four local stubs were
      identical apart from a chip name in two comments.

  Including THIS header from those four preludes replaces both copies at
  once - the shadowing avr/io.h stubs are gone (the shared
  common/dummy/avr/io.h now resolves, and is satisfied because sei/cli are
  already defined by the time grbl.h runs) and the HAL_* block is no longer
  duplicated in four platform.h files.

  Applicability: PRIMASK and CPSIE/CPSID exist on every Cortex-M profile
  (M0/M0+/M3/M4/M33 - ARMv6-M and ARMv7-M/ARMv8-M alike), so this file is
  correct for any Cortex-M port, not just the four listed above. It relies
  on __enable_irq/__disable_irq/__get_PRIMASK/__set_PRIMASK, which each port
  defines in its own regs.h (or gets from CMSIS core_cm*.h).
*/

#ifndef GRBL_PLATFORM_COMMON_CORTEXM_CRITICAL_H
#define GRBL_PLATFORM_COMMON_CORTEXM_CRITICAL_H

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
// ============================================================================
// Direct CPSIE/CPSID inline asm. "memory" clobber mandatory (CONTRACTS.md
// #12.6) so the compiler cannot hoist a ring-buffer access across the gate.
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

// Interrupt control
#define HAL_ENABLE_INTERRUPTS()                 __enable_irq()
#define HAL_DISABLE_INTERRUPTS()                __disable_irq()

// Critical section (save/restore, ISR-safe: CONTRACTS.md section 8.2)
// Core consumes HAL_CRITICAL_SECTION_BEGIN/END (system.c:357-401, serial.c:153)
#define HAL_CRITICAL_SECTION_BEGIN()            uint32_t __primask = __get_PRIMASK(); __disable_irq()
#define HAL_CRITICAL_SECTION_END()              __set_PRIMASK(__primask)

#endif // GRBL_PLATFORM_COMMON_CORTEXM_CRITICAL_H
