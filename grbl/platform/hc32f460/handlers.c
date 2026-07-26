/*
  handlers.c - HC32F460 interrupt vector wrappers
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "platform.h"
#include "regs.h"

/* STEPPER / PULSE-RESET TIMER ISRs
 * __isr_step_impl / __isr_step_reset_impl are the named bodies stepper.c
 * defines via ISR_STEP()/ISR_STEP_RESET() (timer.h).
 */

extern void __isr_step_impl(void);
extern void __isr_step_reset_impl(void);
#ifdef STEP_PULSE_DELAY
  extern void __isr_step_delay_impl(void);
#endif

/* Int000 - stepper timer (STP_TMR_*, platform.c hal_timer_stepper_init) */
void Int000_IRQHandler(void) {
  TMR0_1->STFLR = 0;   /* clear all flags first - see timer.h STP_TMR note re compare-match clear */
  __isr_step_impl();
}

/* Int001 - pulse reset timer (STP_PULSE_RESET_*, platform.c hal_timer_pulse_reset_init) */
void Int001_IRQHandler(void) {
  TMR0_2->STFLR = 0;   /* clear flags before the body stops the timer (section 5.1) */
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
  /* Step pulse delay shares TIMER0 unit 2's second compare (timer.h
     STP_PULSE_DELAY_INIT) - same "no separate timer peripheral needed"
     shape as the STM32 donors' TIM3 CC1. */
  void Int011_IRQHandler(void) {
    TMR0_2->STFLR = 0;
    __isr_step_delay_impl();
  }
#endif

/* SERIAL (USART1 RX / TX - SEPARATE interrupt sources on this chip,
   CONFIRMED via Klipper's serial.c: distinct RI/TI event ids, unlike every
   STM32 donor's shared SR-flag-dispatch vector) */

extern void hc32_usart1_rx_handler(void);
extern void hc32_usart1_tx_handler(void);

/* Int002 - USART1 RX. Reading DR (inside the core RX ISR body,
   HAL_SERIAL_READ_DATA) is what clears RXNE - same "read clears flag"
   semantic as AVR UDR0 and every other port's USART RX path. */
void Int002_IRQHandler(void) {
  hc32_usart1_rx_handler();
}

/* Int003 - USART1 TX. Writing DR (inside the core TX ISR body,
   HAL_SERIAL_WRITE_DATA) is what clears TXE. */
void Int003_IRQHandler(void) {
  hc32_usart1_tx_handler();
}

/* GPIO INTERRUPTS (PORT EIRQ - limit switches and control pins)
 * LIMIT_INT_IRQHandler()/CONTROL_INT_IRQHandler() are the core-supplied
 * bodies (limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT), system.c via
 * HAL_GPIO_IRQ_HANDLER(CONTROL_INT)) - CONTRACTS.md section 2. Channel
 * number == pin number (platform.h pin-map note); LIMIT owns EIRQ0-2,
 * CONTROL owns EIRQ3-6, so no vector ever needs to dispatch to both
 * handlers (unlike the shared-vector STM32 EXTI9_5/EXTI15_10 donors).
 */

extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

/* X limit switch (PB0, EIRQ0) */
void Int004_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 0);   /* clear pending bit FIRST (write-1-to-clear) */
  LIMIT_INT_IRQHandler();
}

/* Y limit switch (PB1, EIRQ1) */
void Int005_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 1);
  LIMIT_INT_IRQHandler();
}

/* Z limit switch (PB2, EIRQ2) */
void Int006_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 2);
  LIMIT_INT_IRQHandler();
}

/* Reset button (PB3, EIRQ3) */
void Int007_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 3);
  CONTROL_INT_IRQHandler();
}

/* Feed hold (PB4, EIRQ4) */
void Int008_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 4);
  CONTROL_INT_IRQHandler();
}

/* Cycle start (PB5, EIRQ5) */
void Int009_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 5);
  CONTROL_INT_IRQHandler();
}

/* Safety door (PB6, EIRQ6) */
void Int010_IRQHandler(void) {
  PORT_EIRQ->EIRQFR = (1UL << 6);
  CONTROL_INT_IRQHandler();
}
