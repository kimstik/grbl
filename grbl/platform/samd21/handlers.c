/*
  handlers.c - SAMD21 interrupt handlers
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Interrupt handlers for GRBL on SAMD21
*/

#include "../hal.h"
#include "platform.h"
#include "timer.h"
#include "../../grbl.h"

// ============================================================================
// TIMER ISR WRAPPERS - Auto-clear interrupt flags before calling implementation
// ============================================================================
// ARM Cortex-M requires manual clearing of peripheral INTFLAG registers
// These wrappers clear flags then call the actual ISR implementation from stepper.c

// Forward declarations of ISR implementations (defined in stepper.c via macros)
extern void __isr_step_impl(void);
extern void __isr_step_reset_impl(void);
#ifdef STEP_PULSE_DELAY
  extern void __isr_step_delay_impl(void);
#endif

// TC3 Handler - Stepper timer (MC0 match interrupt)
void TC3_Handler(void) {
  TC3->INTFLAG = TC_INTFLAG_MC0;  // Clear MC0 interrupt flag FIRST
  __isr_step_impl();               // Call stepper ISR implementation
}

// TC4 Handler - Pulse reset timer (Overflow interrupt)
void TC4_Handler(void) {
  TC4->INTFLAG = TC_INTFLAG_OVF;  // Clear OVF interrupt flag FIRST
  __isr_step_reset_impl();         // Call pulse reset ISR implementation
}

#ifdef STEP_PULSE_DELAY
  // TC5 Handler - Step pulse delay timer (MC0 match interrupt)
  void TC5_Handler(void) {
    TC5->INTFLAG = TC_INTFLAG_MC0;  // Clear MC0 interrupt flag FIRST
    __isr_step_delay_impl();         // Call delay ISR implementation
  }
#endif

// ============================================================================
// SERIAL INTERRUPT (SERCOM3)
// ============================================================================
// SERCOM3_Handler is implemented in serial.c

// ============================================================================
// GPIO INTERRUPTS (EIC - External Interrupt Controller)
// ============================================================================

// Forward declarations - these functions are defined in base GRBL code:
// - LIMIT_INT_IRQHandler() is defined in limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT)
// - CONTROL_INT_IRQHandler() is defined in system.c via HAL_GPIO_IRQ_HANDLER(CONTROL_INT)
extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

// EIC channels mapped to pins:
// - EXTINT[4]  -> PA4  (X_LIMIT)
// - EXTINT[5]  -> PA5  (Y_LIMIT)
// - EXTINT[7]  -> PA7  (Z_LIMIT)
// - EXTINT[14] -> PA14 (CONTROL_RESET)
// - EXTINT[15] -> PA15 (CONTROL_FEED_HOLD)
// - EXTINT[0]  -> PA16 (CONTROL_CYCLE_START) - PA16 % 16 = 0
// Note: PROBE pin (PA19) is polled, not interrupt-driven

// External interrupt controller handler
// Handles all GPIO interrupts (limits, control)
// Calls base GRBL interrupt handlers from limits.c and system.c
void EIC_Handler(void) {
  // Get pending interrupt flags
  uint32_t flags = EIC->INTFLAG;

  // Clear all pending interrupts
  EIC->INTFLAG = flags;

  // Check limit switches (EXTINT[4,5,7])
  if (flags & ((1<<4) | (1<<5) | (1<<7))) {
    LIMIT_INT_IRQHandler();  // Call base GRBL limit handler from limits.c
  }

  // Check control pins (EXTINT[0,14,15])
  if (flags & ((1<<0) | (1<<14) | (1<<15))) {
    CONTROL_INT_IRQHandler();  // Call base GRBL control handler from system.c
  }
}
