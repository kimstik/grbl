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

// ============================================================================
// NOTE: TC3_Handler and TC4_Handler are defined in stepper.c
// ============================================================================

// ============================================================================
// SERIAL INTERRUPT (SERCOM3)
// ============================================================================

// UART RX interrupt handler
void SERCOM3_Handler(void) {
  // Check for RX complete
  // if (SERCOM3->USART.INTFLAG.bit.RXC) {
  //   uint8_t data = SERCOM3->USART.DATA.reg;
  //   extern void serial_rx_interrupt(uint8_t data);
  //   serial_rx_interrupt(data);
  // }
}

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
