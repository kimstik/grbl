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
// LIMIT SWITCHES INTERRUPT (EIC)
// ============================================================================

// External interrupt controller handler
// Used for limit switch detection
void EIC_Handler(void) {
  // Get interrupt flags
  // uint32_t flags = EIC->INTFLAG.reg;

  // Clear interrupt flags
  // EIC->INTFLAG.reg = flags;

  // Call GRBL limits interrupt
  // extern void limits_interrupt(void);
  // limits_interrupt();
}

// ============================================================================
// CONTROL PINS INTERRUPT (EIC)
// ============================================================================

// Control pins (reset, feed hold, cycle start, safety door)
// are also handled by EIC
// Implementation shares EIC_Handler above
