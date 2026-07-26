/*
  handlers.c - STM32F411 interrupt vector wrappers
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "platform.h"
#include "regs.h"

// STEPPER / PULSE-RESET TIMER ISRs
// __isr_step_impl / __isr_step_reset_impl / __isr_step_delay_impl are the
// named bodies stepper.c defines via ISR_STEP()/ISR_STEP_RESET()/
// ISR_STEP_DELAY() (timer.h). startup.c's vector table requires
// TIM2_IRQHandler and TIM3_IRQHandler as real (non-weak) symbols.

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
  // same as the f103/h523 reference - no separate timer peripheral needed.
  void TIM4_IRQHandler(void) {
    TIM3->SR = 0;
    __isr_step_delay_impl();
  }
#endif

// GPIO INTERRUPTS (EXTI - limit switches and control pins)
// LIMIT_INT_IRQHandler()/CONTROL_INT_IRQHandler() are the core-supplied
// bodies (limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT), system.c via
// HAL_GPIO_IRQ_HANDLER(CONTROL_INT)) - CONTRACTS.md section 2. Those core
// bodies are what perform BUG#19-class realtime-command interception
// (control pins feed sys_rt_exec_state) - this file changes nothing about
// that path, it only arranges for the right core body to be called with the
// peripheral flag already cleared.

extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

// X limit switch (PB0, EXTI0)
void EXTI0_IRQHandler(void) {
  if (EXTI->PR & (1UL << 0)) {
    EXTI->PR = (1UL << 0);  // Clear pending bit FIRST
    LIMIT_INT_IRQHandler();
  }
}

// Y limit switch (PB1, EXTI1)
void EXTI1_IRQHandler(void) {
  if (EXTI->PR & (1UL << 1)) {
    EXTI->PR = (1UL << 1);
    LIMIT_INT_IRQHandler();
  }
}

// Z limit switch (PB2, EXTI2) - BUG #26: moved here from PB10/EXTI15_10.
// PB10 put Z_LIMIT_BIT at bit 10, which limits.c's uint8_t group-read
// (and core get_limit_pin_mask()'s uint8_t return) silently truncates to
// zero - the Z switch was structurally invisible to limits_get_state(),
// which is the ONLY detection path during homing (motion_control.c
// disables the interrupt-driven hard-limit ISR for the whole homing
// cycle). PB2 keeps Z_LIMIT_BIT within bits 0-7 (CONTRACTS.md section
// 1.3), matching every other port's LIMIT pin choice. See PLAN.md BUG #26.
void EXTI2_IRQHandler(void) {
  if (EXTI->PR & (1UL << Z_LIMIT_PIN)) {
    EXTI->PR = (1UL << Z_LIMIT_PIN);
    LIMIT_INT_IRQHandler();
  }
}

// Reset button (PB3, EXTI3)
void EXTI3_IRQHandler(void) {
  if (EXTI->PR & (1UL << 3)) {
    EXTI->PR = (1UL << 3);
    CONTROL_INT_IRQHandler();
  }
}

// Feed hold button (PB4, EXTI4)
void EXTI4_IRQHandler(void) {
  if (EXTI->PR & (1UL << 4)) {
    EXTI->PR = (1UL << 4);
    CONTROL_INT_IRQHandler();
  }
}

// Cycle start and safety door (PB5-6, EXTI9_5) - dispatch to both if pending
// (CONTRACTS.md section 2.5: shared-vector platforms must dispatch to every
// core handler whose group is pending, not just the first match)
void EXTI9_5_IRQHandler(void) {
  uint32_t pr = EXTI->PR & ((1UL << 5) | (1UL << 6));

  if (pr) {
    EXTI->PR = pr;
    CONTROL_INT_IRQHandler();
  }
}

// EXTI15_10 is unused on this port since BUG #26 moved Z off PB10 - the
// weak alias to Default_Handler in startup.c covers this vector now.
