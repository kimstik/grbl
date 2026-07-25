/*
  handlers.c - CH32V006 interrupt vector bodies
  Part of Grbl

  PORTING-CHECKLIST Step 6. Real PFIC vector targets (startup.c's
  vector table points here): each wrapper clears its peripheral flag
  FIRST, then calls the core-supplied ISR body - clearing after would
  lose edges/updates arriving during the body, and for ISR_STEP_RESET
  specifically would ghost the final compare event after the body stops
  the counter (CONTRACTS.md #2.3 / #5.1).

  __attribute__((interrupt)): QingKe V2C runs with INTSYSCR.HWSTKEN=0
  (no vendor hardware prologue/epilogue - the reset default, see
  startup.c's documented choice), so GCC's standard RISC-V interrupt
  attribute - full caller-saved spill + `mret` - is exactly the right
  frame. Verified by disassembly in the M1-M3 session.

  Core-ISR dedup pattern: the bodies (__isr_step_impl, LIMIT_INT_
  IRQHandler, ...) are defined by CORE macros (stepper.c ISR_STEP(),
  limits.c/system.c HAL_GPIO_IRQ_HANDLER(...)) - this file only owns the
  vector frame + flag hygiene, the same split every ARM port uses.
*/

#include <stdint.h>
#include "platform.h"

// Core-supplied ISR bodies
extern void __isr_step_impl(void);        // stepper.c via ISR_STEP()
extern void __isr_step_reset_impl(void);  // stepper.c via ISR_STEP_RESET()
extern void LIMIT_INT_IRQHandler(void);   // limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT)
extern void CONTROL_INT_IRQHandler(void); // system.c via HAL_GPIO_IRQ_HANDLER(CONTROL_INT)
extern void serial_irq_dispatch(void);    // serial.c

// ============================================================================
// STEPPER TIMER - TIM2 update, vector 38 (CONTRACTS.md #3, #5)
// ============================================================================
__attribute__((interrupt))
void TIM2_IRQHandler(void) {
  TIM2->INTFR = 0;            // RW0 register: writing 0 clears all flags FIRST
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER - STK compare, vector 12 (CONTRACTS.md #4, #5)
// ============================================================================
// SR.CNTIF is write-0-to-clear (RM 6.5.4.2) - `= 0` is the clear idiom.
// Cleared before the body because the body stops the counter (#5.1).
__attribute__((interrupt))
void SysTick_Handler(void) {
  STK->SR = 0;
  __isr_step_reset_impl();
}

// ============================================================================
// GPIO EXTERNAL INTERRUPTS - EXTI lines 0-7, ONE shared vector 20
// (CONTRACTS.md #2). LIMIT = PD0-2 (lines 0-2), CONTROL = PB3-5 (lines
// 3-5) - distinct line sets, so pending bits identify the group. Shared-
// vector rule #2.5: dispatch to BOTH core handlers when both are pending.
// ============================================================================
#define CONTROL_EXTI_LINES  CONTROL_MASK   // pins==lines (bits 3-5)
#define LIMIT_EXTI_LINES    LIMIT_MASK     // pins==lines (bits 0-2)

__attribute__((interrupt))
void EXTI7_0_IRQHandler(void) {
  uint32_t pending = EXTI->INTFR;
  EXTI->INTFR = pending;      // write-1-to-clear, FIRST (#2.3)

  if (pending & LIMIT_EXTI_LINES)   { LIMIT_INT_IRQHandler(); }
  if (pending & CONTROL_EXTI_LINES) { CONTROL_INT_IRQHandler(); }
}

// ============================================================================
// USART1 - vector 32 (CONTRACTS.md #7). RXNE clears on DATAR read, TXE on
// DATAR write - flag hygiene lives inside serial_irq_dispatch's servicing.
// ============================================================================
__attribute__((interrupt))
void USART1_IRQHandler(void) {
  serial_irq_dispatch();
}
