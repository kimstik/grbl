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

// EIC channels mapped to pins:
// - EXTINT[4]  -> PA4  (X_LIMIT)
// - EXTINT[5]  -> PA5  (Y_LIMIT)
// - EXTINT[7]  -> PA7  (Z_LIMIT)
// - EXTINT[14] -> PA14 (CONTROL_RESET)
// - EXTINT[15] -> PA15 (CONTROL_FEED_HOLD)
// - EXTINT[0]  -> PA16 (CONTROL_CYCLE_START) - PA16 % 16 = 0
// - EXTINT[3]  -> PA19 (PROBE) - PA19 % 16 = 3

// External interrupt controller handler
// Handles all GPIO interrupts (limits, control, probe)
void EIC_Handler(void) {
  // Get pending interrupt flags
  uint32_t flags = EIC->INTFLAG;

  // Clear all pending interrupts
  EIC->INTFLAG = flags;

  // Check limit switches (EXTINT[4,5,7])
  if (flags & ((1<<4) | (1<<5) | (1<<7))) {
    extern void limits_isr(void);
    limits_isr();
  }

  // Check control pins (EXTINT[0,14,15])
  if (flags & ((1<<0) | (1<<14) | (1<<15))) {
    extern void control_interrupt_handler(void);
    control_interrupt_handler();
  }

  // Check probe pin (EXTINT[3])
  if (flags & (1<<3)) {
    extern void probe_isr(void);
    probe_isr();
  }
}
