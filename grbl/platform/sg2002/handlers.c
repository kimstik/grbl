/*
  handlers.c - SG2002 interrupt handlers
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Interrupt handlers for UART, GPIO, and timers
*/

#include "platform.h"
#include "../../grbl.h"

// Placeholder interrupt handlers
// These will be properly implemented when integrating with GRBL

void uart0_rx_handler(void) {
  // Handle UART RX interrupt
  // This will call into GRBL serial RX handler
}

void uart0_tx_handler(void) {
  // Handle UART TX interrupt
  // This will call into GRBL serial TX handler
}

void timer0_ch0_handler(void) {
  // Clear timer interrupt
  TIMER0->TIMER[0].EOI;

  // This will call GRBL stepper ISR
  // Stepper interrupt handler is defined in stepper.c via HAL_TIMER_STEPPER_ISR()
}

// GPIO interrupt handlers for limit switches and control pins
void gpio_handler(void) {
  // Handle GPIO interrupts for limit switches and control pins
}
