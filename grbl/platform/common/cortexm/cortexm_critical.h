/*
  cortexm_critical.h - PRIMASK-based critical sections + sei/cli, shared
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GRBL_PLATFORM_COMMON_CORTEXM_CRITICAL_H
#define GRBL_PLATFORM_COMMON_CORTEXM_CRITICAL_H

// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
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
