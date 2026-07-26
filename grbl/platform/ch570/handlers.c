/*
  handlers.c - CH570 interrupt vector bodies
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"

// Core-supplied ISR bodies
extern void __isr_step_impl(void);        // stepper.c via ISR_STEP()
extern void __isr_step_reset_impl(void);  // stepper.c via ISR_STEP_RESET()
extern void LIMIT_INT_IRQHandler(void);   // limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT)
extern void CONTROL_INT_IRQHandler(void); // system.c via HAL_GPIO_IRQ_HANDLER(CONTROL_INT)
extern void serial_irq_dispatch(void);    // serial.c

// STEPPER TIMER - TMR0 cycle-end, vector 24 (CONTRACTS.md #3, #5)
__attribute__((interrupt))
void TMR_IRQHandler(void) {
  TMR0->INT_FLAG = RB_TMR_IF_CYC_END;   // RW1: write-1-to-clear, FIRST
  __isr_step_impl();
}

// PULSE-RESET TIMER - STK compare, vector 12 (CONTRACTS.md #4, #5)
__attribute__((interrupt))
void SysTick_Handler(void) {
  STK->SR = 0;   // write-0-to-clear (same inverted polarity as ch32v006's STK)
  __isr_step_reset_impl();
}

// GPIO PORT A - ONE shared vector for ALL pins, vector 17 (CONTRACTS.md
// #2). LIMIT and CONTROL groups occupy disjoint bit ranges (board config)
// so the pending-mask test below correctly separates them per #2.5.
//
// ANY-CHANGE technique (platform.c's hal_gpio_interrupt_enable header has
// the full rationale): after servicing each pending bit, flip its
// EDGE_TYPE polarity so the NEXT interrupt fires on the opposite
// transition - this is what turns single-polarity edge hardware into
// "any pin CHANGE" semantics across consecutive interrupts, matching
// CONTRACTS.md #2.6.
__attribute__((interrupt))
void GPIOA_IRQHandler(void) {
  uint16_t pending = R16_PA_INT_IF;
  R16_PA_INT_IF = pending;                              // write-1-to-clear, FIRST (#2.3)
  R16_PA_INT_EDGE_TYPE ^= pending;                       // arm the opposite edge for next time

  // `pending` is the raw PHYSICAL interrupt-flag register - LIMIT_MASK is
  // physical==logical (unaffected), but CONTROL_MASK is now core-visible
  // LOGICAL (BUG #17 class fix, boards/generic/config.h); this dispatch
  // test needs CONTROL_MASK_PHYS, not CONTROL_MASK, or it silently checks
  // the wrong bits of a physical register.
  if (pending & LIMIT_MASK)        { LIMIT_INT_IRQHandler(); }
  if (pending & CONTROL_MASK_PHYS) { CONTROL_INT_IRQHandler(); }
}

// UART1 - vector 27 (CONTRACTS.md #7). RBR read clears DATA_RDY, THR
// write clears TX_FIFO_EMP - flag hygiene lives inside serial_irq_dispatch.
__attribute__((interrupt))
void UART_IRQHandler(void) {
  serial_irq_dispatch();
}
