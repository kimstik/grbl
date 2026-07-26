/*
  handlers.c - STM32H523 interrupt vector wrappers
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "platform.h"
#include "regs.h"

// STEPPER / PULSE-RESET TIMER ISRs
// __isr_step_impl / __isr_step_reset_impl are the named bodies stepper.c
// defines via ISR_STEP()/ISR_STEP_RESET() (timer.h). startup.c's vector
// table requires TIM2_IRQHandler and TIM3_IRQHandler as real (non-weak)
// symbols.

extern void __isr_step_impl(void);
extern void __isr_step_reset_impl(void);
#ifdef STEP_PULSE_DELAY
  extern void __isr_step_delay_impl(void);
#endif

// TIM2 - stepper timer (STP_TMR_*, platform.c hal_timer_stepper_init)
void TIM2_IRQHandler(void) {
  TIM2->SR = 0;  // Clear all flags first - see timer.h STP_TMR note re UIF-only clear
  __isr_step_impl();
}

// TIM3 - pulse reset timer (STP_PULSE_RESET_*, platform.c hal_timer_pulse_reset_init)
void TIM3_IRQHandler(void) {
  TIM3->SR = 0;  // Clear flags before the body stops the timer (section 5.1)
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
  // Step pulse delay shares TIM3's CC1 compare (timer.h STP_PULSE_DELAY_INIT),
  // same as the f103 reference - no separate timer peripheral needed.
  void TIM4_IRQHandler(void) {
    TIM3->SR = 0;
    __isr_step_delay_impl();
  }
#endif

// GPIO INTERRUPTS (EXTI - limit switches and control pins)
// LIMIT_INT_IRQHandler()/CONTROL_INT_IRQHandler() are the core-supplied
// bodies (limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT), system.c via
// HAL_GPIO_IRQ_HANDLER(CONTROL_INT)) - CONTRACTS.md section 2.
//
// STM32H5 EXTI splits the classic single PR pending register into RPR1
// (rising edge) / FPR1 (falling edge). hal_gpio_interrupt_enable()
// (platform.c) currently arms falling-edge only, but both are cleared here
// unconditionally (write-1-to-clear on a bit that was never set is a
// documented no-op) so a future rising/both-edges config (CONTRACTS.md
// section 2.6 - core treats any change as a trigger) does not silently
// break this vector. Each line has its OWN vector on H5 (no shared
// EXTI9_5/EXTI15_10 group like F1), so no multi-handler dispatch is needed
// here (contrast f103/handlers.c EXTI9_5_IRQHandler).

extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

// X limit switch (PB0, EXTI0)
void EXTI0_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 0)) {
    EXTI->FPR1 = (1 << 0);  // Clear pending bit(s) FIRST
    EXTI->RPR1 = (1 << 0);
    LIMIT_INT_IRQHandler();
  }
}

// Y limit switch (PB1, EXTI1)
void EXTI1_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 1)) {
    EXTI->FPR1 = (1 << 1);
    EXTI->RPR1 = (1 << 1);
    LIMIT_INT_IRQHandler();
  }
}

// EXTI10 is unused on this port since BUG #26 moved Z off PB10 - the weak
// alias to Default_Handler in startup.c covers this vector now.

// Z limit switch (PB2, EXTI2) - BUG #26: moved here from PB10/EXTI10.
// PB10 put Z_LIMIT_BIT at bit 10, which limits.c's uint8_t group-read (and
// core get_limit_pin_mask()'s uint8_t return) silently truncates to zero -
// the Z switch was structurally invisible to limits_get_state(), the ONLY
// detection path during homing (motion_control.c disables the
// interrupt-driven hard-limit ISR for the whole homing cycle). PB2 keeps
// Z_LIMIT_BIT within bits 0-7 (CONTRACTS.md section 1.3). See PLAN.md
// BUG #26.
void EXTI2_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1UL << Z_LIMIT_PIN)) {
    EXTI->FPR1 = (1UL << Z_LIMIT_PIN);
    EXTI->RPR1 = (1UL << Z_LIMIT_PIN);
    LIMIT_INT_IRQHandler();
  }
}

// Reset button (PB3, EXTI3)
void EXTI3_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 3)) {
    EXTI->FPR1 = (1 << 3);
    EXTI->RPR1 = (1 << 3);
    CONTROL_INT_IRQHandler();
  }
}

// Feed hold button (PB4, EXTI4)
void EXTI4_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 4)) {
    EXTI->FPR1 = (1 << 4);
    EXTI->RPR1 = (1 << 4);
    CONTROL_INT_IRQHandler();
  }
}

// Cycle start button (PB5, EXTI5) - own vector on H5, unlike f103's shared
// EXTI9_5 line, so no multi-line dispatch is required here.
void EXTI5_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 5)) {
    EXTI->FPR1 = (1 << 5);
    EXTI->RPR1 = (1 << 5);
    CONTROL_INT_IRQHandler();
  }
}

// Safety door button (PB6, EXTI6)
void EXTI6_IRQHandler(void) {
  if ((EXTI->FPR1 | EXTI->RPR1) & (1 << 6)) {
    EXTI->FPR1 = (1 << 6);
    EXTI->RPR1 = (1 << 6);
    CONTROL_INT_IRQHandler();
  }
}
