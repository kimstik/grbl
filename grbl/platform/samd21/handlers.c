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
// STEPPER TIMER INTERRUPT (TC3)
// ============================================================================

// Stepper interrupt handler
// Called at configured step rate
void TC3_Handler(void) {
  // Clear interrupt flag
  // TC3->COUNT16.INTFLAG.bit.MC0 = 1;

  // Call GRBL stepper interrupt
  // extern void st_interrupt(void);
  // st_interrupt();
}

// ============================================================================
// STEP PULSE RESET TIMER INTERRUPT (TC4)
// ============================================================================

// Step pulse reset interrupt handler
// Called to end step pulse
void TC4_Handler(void) {
  // Clear interrupt flag
  // TC4->COUNT16.INTFLAG.bit.MC0 = 1;

  // Reset step pins
  // extern void st_reset_interrupt(void);
  // st_reset_interrupt();
}

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
