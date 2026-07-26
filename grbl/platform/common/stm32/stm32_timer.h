/*
  stm32_timer.h - GRBL timer contract macros shared by every STM32 port
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Contracts: platform/CONTRACTS.md sections 3-6; naming: platform/common/timer.md

  EXTRACTED from stm32f103/timer.h, stm32f411/timer.h and stm32h523/timer.h,
  which were 100% code-identical - every macro body below was already
  character-for-character the same in all three; only comments and the
  include-guard name differed. The per-family notes those three carried are
  merged inline below rather than dropped.

  WHY ONE FILE IS CORRECT ACROSS F1/F4/H5: the TIM2/TIM3 register shape
  (CR1/DIER/SR/EGR/PSC/ARR/CNT/CCR1) is field-identical on all three
  families, and TIM1 is an advanced-control timer on all three. Only the
  BASE ADDRESSES differ, and those live in each port's own regs.h - which
  this file includes by the plain name "regs.h", resolved per port through
  the port directory's own `-I.` (F411's TIM1 is at 0x40010000, NOT F1/H5's
  0x40012C00 - see stm32f411/regs.h's file header). Same division of labor
  as the rest of common/stm32/: shared logic here, per-chip addresses and
  clock trees there.

  ISR-HOT CONTRACT SURFACE (CONTRACTS.md section 6.1): every macro below is
  a SINGLE register access. Do not grow them into multi-statement bodies,
  add read-modify-write where a plain store is used, or wrap them in
  critical sections - stepper.c calls these from inside the step ISR.
*/

/* TODO list - keep me compact for reference at the file top

// spindle_control.c
PWM_INIT();
PWM_DISABLE();
PWM_ENABLE();
PWM_IS_ENABLED()
PWM_SET(duty_value);

// stepper.c
 ISR_STEP_DELAY()
 ISR_STEP_RESET()
 ISR_STEP()

STP_PULSE_DELAY_INIT()

STP_PULSE_RESET_INIT()
STP_PULSE_RESET_COMPARE_SET(val);
STP_PULSE_RESET_COUNT_SET(val);
STP_PULSE_RESET_START();
STP_PULSE_RESET_STOP();

STP_TMR_INIT();
STP_TMR_INT_DIS();
STP_TMR_INT_ENA();
STP_TMR_PERIOD_SET(val);
STP_TMR_PRESCALER_SET(val);
STP_TMR_PRESCALER_RESET();
*/

#ifndef GRBL_PLATFORM_COMMON_STM32_TIMER_H
#define GRBL_PLATFORM_COMMON_STM32_TIMER_H

#include "regs.h"

// ============================================================================
// ISR DEFINITIONS
// ============================================================================
// Core defines the ISR bodies through these macros as plain named functions.
// The real vectors (TIM2_IRQHandler/TIM3_IRQHandler in handlers.c) clear the
// peripheral flag FIRST, then call the body (CONTRACTS.md section 5.1).

#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (TIM2)
// ============================================================================
// Kernel clock is per port: F103 72 MHz; H523 250 MHz (TIM2 32-bit); F411
// 96 MHz (TIM2 32-bit) - on F411 see platform.c hal_clock_config: the APB1
// timer clock is 2x APB1 pclk whenever the APB1 prescaler is not /1, so
// TIM2/TIM3 run at the full 96 MHz core clock even though APB1 itself is
// divided by 2, and F_CPU (Makefile CLOCK=96000000) matches that. None of
// this changes the macro encodings below - only the tick period.
//
// hal_timer_stepper_init() (platform.c) leaves the counter running at /1 with
// the update interrupt masked; INIT + STP_TMR_PRESCALER_RESET() therefore
// yield the AVR post-init state: running, /1, interrupt masked.

void hal_timer_stepper_init(void);
#define STP_TMR_INIT()                  hal_timer_stepper_init()

#define STP_TMR_INT_ENA()               (TIM2->DIER |= TIM_DIER_UIE)
#define STP_TMR_INT_DIS()               (TIM2->DIER &= ~TIM_DIER_UIE)
#define STP_TMR_PERIOD_SET(cycles)      (TIM2->ARR = (cycles))

// Prescaler encoding fixed by stepper.c:1032-1044: 1 = /1, 2 = /8, 3 = /64.
// TIM PSC is preloaded in hardware: a written value is latched at the next
// update event, i.e. for the segment being loaded (AMASS-off builds only).
// No EGR_UG here - forcing an update event would set UIF inside ISR_STEP.
#define STP_TMR_PRESCALER_SET(v)        (TIM2->PSC = ((v) == 1 ? 0u : ((v) == 2 ? 7u : 63u)))
#define STP_TMR_PRESCALER_RESET()       (TIM2->PSC = 0)

// ============================================================================
// PULSE RESET TIMER (TIM3, clocked at F_CPU/8 via PSC=7)
// ============================================================================
// 8-bit overflow horizon contract (CONTRACTS.md section 4): core hands us a
// uint8_t two's-complement negative count; the overflow ISR must fire after
// (256 - val) ticks of F_CPU/8. TIM3 is (at least) 16-bit on every family
// here (16-bit on F103, 32-bit on F411/H523), so bias the preload into the
// top 8-bit lane: CNT = 0xFF00 | val overflows (F103: ARR = 0xFFFF) after
// exactly (256 - val) ticks.

void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()          hal_timer_pulse_reset_init()

#define STP_PULSE_RESET_START()         (TIM3->CR1 |= TIM_CR1_CEN)
#define STP_PULSE_RESET_STOP()          (TIM3->CR1 &= ~TIM_CR1_CEN)
#define STP_PULSE_RESET_COUNT_SET(val)  (TIM3->CNT = 0xFF00u | (uint8_t)(val))
#define STP_PULSE_RESET_COMPARE_SET(val) (TIM3->CCR1 = 0xFF00u | (uint8_t)(val))

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_DELAY_INIT()        (TIM3->DIER |= TIM_DIER_CC1IE)
#endif

// ============================================================================
// SPINDLE PWM TIMER (TIM1 CH1 on PA8)
// ============================================================================
// hal_timer_spindle_pwm_init() (platform.c) configures PWM mode 1 with
// ARR = SPINDLE_PWM_MAX_VALUE and re-muxes PA8 to the timer's alternate
// function (spindle_init() calls GPIO_DIR_OUT(SPINDLE_PWM) first, which
// leaves the pin as plain GPIO).
//
// TIM1 is an ADVANCED-CONTROL timer on every family here: its channel
// outputs are gated by BDTR.MOE IN ADDITION to CCER.CCxE - without MOE set
// the OCx pins never leave the "disabled" state even with CC1E set (RM0008 /
// RM0383 / RM0481 advanced-control timer chapters; PORTING-CHECKLIST.md's
// TIM1 BDTR.MOE note). MOE is set once by the init above; CCER.CC1E is what
// connects/disconnects the output on top of that, so with CC1E clear the
// OC1 output is not driven and the pin sits inactive.
//
// All macros are single register accesses: ISR-hot safe (section 6.1).

void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

#define PWM_ENABLE()            (TIM1->CCER |= TIM_CCER_CC1E)
#define PWM_DISABLE()           (TIM1->CCER &= ~TIM_CCER_CC1E)
#define PWM_IS_ENABLED()        (TIM1->CCER & TIM_CCER_CC1E)
#define PWM_SET(duty_value)     (TIM1->CCR1 = (duty_value))

#endif // GRBL_PLATFORM_COMMON_STM32_TIMER_H
