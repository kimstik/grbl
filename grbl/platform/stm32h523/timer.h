// STM32H523 specific timer primitives with correct naming
// (contracts: platform/CONTRACTS.md sections 3-6; naming: platform/common/timer.md)
// Ported from stm32f103/timer.h: TIM2/TIM3 register shape (CR1/DIER/SR/EGR/
// PSC/ARR/CCR1) is field-identical between F1 and H5 (regs.h), and TIM1 is
// an advanced-control timer on BOTH parts, so the contract macros below are
// the same encoding - only the base addresses (regs.h) differ.

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

#ifndef STM32H523_TIMER_H
#define STM32H523_TIMER_H

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
// STEPPER TIMER (TIM2, 32-bit on H523)
// ============================================================================
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
// PULSE RESET TIMER (TIM3)
// ============================================================================
// 8-bit overflow horizon contract (CONTRACTS.md section 4): core hands us a
// uint8_t two's-complement negative count; the overflow ISR must fire after
// (256 - val) ticks of F_CPU/8. TIM3 is (at least) 16-bit, so bias the
// preload into the top 8-bit lane: CNT = 0xFF00 | val overflows after exactly
// (256 - val) ticks, same as the f103 reference.

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
// ARR = SPINDLE_PWM_MAX_VALUE. TIM1 is an ADVANCED-CONTROL timer (same as
// F1's TIM1): its channel outputs are gated by BDTR.MOE in addition to
// CCER.CCxE - without MOE set the OCx pins never leave the "disabled" state
// even with CC1E set (RM0481 advanced-control timer chapter). CCER.CC1E
// still connects/disconnects the output on top of that (PWM_ENABLE/DISABLE).
// All macros are single register accesses: ISR-hot safe (section 6.1).

void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

#define PWM_ENABLE()            (TIM1->CCER |= TIM_CCER_CC1E)
#define PWM_DISABLE()           (TIM1->CCER &= ~TIM_CCER_CC1E)
#define PWM_IS_ENABLED()        (TIM1->CCER & TIM_CCER_CC1E)
#define PWM_SET(duty_value)     (TIM1->CCR1 = (duty_value))

#endif // STM32H523_TIMER_H
