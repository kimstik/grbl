/*
  core_cm0plus.h - Cortex-M0+ stub header
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal stub header for ARM Cortex-M0+ core
  TODO: Replace with official CMSIS core headers from ARM
*/

#ifndef CORE_CM0PLUS_H
#define CORE_CM0PLUS_H

#include <stdint.h>

// ============================================================================
// COMPILER INTRINSICS
// ============================================================================

#define __ASM            __asm
#define __INLINE         inline
#define __STATIC_INLINE  static inline

// No operation
#define __NOP()          __ASM volatile ("nop")

// Wait for interrupt
#define __WFI()          __ASM volatile ("wfi")

// Wait for event
#define __WFE()          __ASM volatile ("wfe")

// Send event
#define __SEV()          __ASM volatile ("sev")

// Instruction synchronization barrier
#define __ISB()          __ASM volatile ("isb 0xF":::"memory")

// Data synchronization barrier
#define __DSB()          __ASM volatile ("dsb 0xF":::"memory")

// Data memory barrier
#define __DMB()          __ASM volatile ("dmb 0xF":::"memory")

// Enable IRQ Interrupts
__STATIC_INLINE void __enable_irq(void) {
  __ASM volatile ("cpsie i" : : : "memory");
}

// Disable IRQ Interrupts
__STATIC_INLINE void __disable_irq(void) {
  __ASM volatile ("cpsid i" : : : "memory");
}

// ============================================================================
// NVIC - Nested Vectored Interrupt Controller
// ============================================================================

typedef struct {
  volatile uint32_t ISER[1];        // Interrupt Set Enable Register
  uint32_t RESERVED0[31];
  volatile uint32_t ICER[1];        // Interrupt Clear Enable Register
  uint32_t RESERVED1[31];
  volatile uint32_t ISPR[1];        // Interrupt Set Pending Register
  uint32_t RESERVED2[31];
  volatile uint32_t ICPR[1];        // Interrupt Clear Pending Register
  uint32_t RESERVED3[31];
  uint32_t RESERVED4[64];
  volatile uint32_t IP[8];          // Interrupt Priority Register
} NVIC_Type;

#define NVIC_BASE         (0xE000E100UL)
#define NVIC              ((NVIC_Type *)NVIC_BASE)

// NVIC helper functions
__STATIC_INLINE void NVIC_EnableIRQ(IRQn_Type IRQn) {
  NVIC->ISER[0] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

__STATIC_INLINE void NVIC_DisableIRQ(IRQn_Type IRQn) {
  NVIC->ICER[0] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

__STATIC_INLINE void NVIC_SetPendingIRQ(IRQn_Type IRQn) {
  NVIC->ISPR[0] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

__STATIC_INLINE void NVIC_ClearPendingIRQ(IRQn_Type IRQn) {
  NVIC->ICPR[0] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

__STATIC_INLINE void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority) {
  NVIC->IP[(uint32_t)(IRQn)] = ((priority << 6) & 0xC0);
}

__STATIC_INLINE uint32_t NVIC_GetPriority(IRQn_Type IRQn) {
  return (NVIC->IP[(uint32_t)(IRQn)] >> 6);
}

// ============================================================================
// SysTick
// ============================================================================

typedef struct {
  volatile uint32_t CTRL;           // Control and Status Register
  volatile uint32_t LOAD;           // Reload Value Register
  volatile uint32_t VAL;            // Current Value Register
  volatile const uint32_t CALIB;    // Calibration Register
} SysTick_Type;

#define SysTick_BASE      (0xE000E010UL)
#define SysTick           ((SysTick_Type *)SysTick_BASE)

// SysTick Control / Status Register Definitions
#define SysTick_CTRL_COUNTFLAG_Pos    16
#define SysTick_CTRL_COUNTFLAG_Msk    (1UL << SysTick_CTRL_COUNTFLAG_Pos)

#define SysTick_CTRL_CLKSOURCE_Pos    2
#define SysTick_CTRL_CLKSOURCE_Msk    (1UL << SysTick_CTRL_CLKSOURCE_Pos)

#define SysTick_CTRL_TICKINT_Pos      1
#define SysTick_CTRL_TICKINT_Msk      (1UL << SysTick_CTRL_TICKINT_Pos)

#define SysTick_CTRL_ENABLE_Pos       0
#define SysTick_CTRL_ENABLE_Msk       (1UL << SysTick_CTRL_ENABLE_Pos)

// SysTick Reload Register Definitions
#define SysTick_LOAD_RELOAD_Pos       0
#define SysTick_LOAD_RELOAD_Msk       (0xFFFFFFUL << SysTick_LOAD_RELOAD_Pos)

// SysTick Current Register Definitions
#define SysTick_VAL_CURRENT_Pos       0
#define SysTick_VAL_CURRENT_Msk       (0xFFFFFFUL << SysTick_VAL_CURRENT_Pos)

// SysTick Configuration
__STATIC_INLINE uint32_t SysTick_Config(uint32_t ticks) {
  if ((ticks - 1) > SysTick_LOAD_RELOAD_Msk) return (1);

  SysTick->LOAD = ticks - 1;
  SysTick->VAL = 0;
  SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk |
                  SysTick_CTRL_TICKINT_Msk   |
                  SysTick_CTRL_ENABLE_Msk;
  return (0);
}

// ============================================================================
// SCB - System Control Block
// ============================================================================

typedef struct {
  volatile const uint32_t CPUID;    // CPUID Base Register
  volatile uint32_t ICSR;           // Interrupt Control and State Register
  uint32_t RESERVED0;
  volatile uint32_t AIRCR;          // Application Interrupt and Reset Control Register
  volatile uint32_t SCR;            // System Control Register
  volatile uint32_t CCR;            // Configuration Control Register
  uint32_t RESERVED1;
  volatile uint32_t SHP[2];         // System Handlers Priority Registers
  volatile uint32_t SHCSR;          // System Handler Control and State Register
} SCB_Type;

#define SCB_BASE          (0xE000ED00UL)
#define SCB               ((SCB_Type *)SCB_BASE)

#endif // CORE_CM0PLUS_H
