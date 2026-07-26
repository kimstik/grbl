/*
  timer.h - HC32F460 timer primitives with contract naming
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef HC32F460_TIMER_H
#define HC32F460_TIMER_H

#include "regs.h"

/* ISR DEFINITIONS
 * Core defines the ISR bodies through these macros as plain named functions.
 * The real vectors (handlers.c) clear the peripheral flag FIRST, then call
 * the body (CONTRACTS.md section 5.1).
 */

#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

/* STEPPER TIMER (TIMER0 unit 1)
 * hal_timer_stepper_init() (platform.c) leaves the counter running at /1
 * with the compare interrupt masked; INIT + STP_TMR_PRESCALER_RESET()
 * therefore yield the AVR post-init state: running, /1, interrupt masked.
 */

void hal_timer_stepper_init(void);
#define STP_TMR_INIT()                  hal_timer_stepper_init()

#define STP_TMR_INT_ENA()               (TMR0_1->IER |= TMR0_IER_CMPAIE)
#define STP_TMR_INT_DIS()                (TMR0_1->IER &= ~TMR0_IER_CMPAIE)
#define STP_TMR_PERIOD_SET(cycles)      (TMR0_1->CMPAR = (cycles))

/* Prescaler encoding fixed by stepper.c:1032-1044: 1 = /1, 2 = /8, 3 = /64.
   CR bits [2:1] (UNVERIFIED position, regs.h) select the divider - this
   port's own placeholder field, not vendor-confirmed. */
#define TMR0_CR_PRESCALE_Pos  1
#define STP_TMR_PRESCALER_SET(v)   \
  (TMR0_1->CR = (TMR0_1->CR & ~(0x3u << TMR0_CR_PRESCALE_Pos)) | \
                (((v) == 1 ? 0u : ((v) == 2 ? 1u : 2u)) << TMR0_CR_PRESCALE_Pos))
#define STP_TMR_PRESCALER_RESET()  (TMR0_1->CR &= ~(0x3u << TMR0_CR_PRESCALE_Pos))

/* PULSE RESET TIMER (TIMER0 unit 2)
 * 8-bit overflow horizon contract (CONTRACTS.md section 4): core hands us
 * a uint8_t two's-complement negative count; the compare event must fire
 * after (256 - val) ticks of F_CPU/8. Modeled as an auto-reload compare
 * timer (CMPAR = ticks, CNTER reset to 0 at START) rather than a
 * free-running-overflow timer, since TMR0's real reset/reload behavior is
 * UNVERIFIED - this shape reproduces the exact tick count either way.
 */

void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()          hal_timer_pulse_reset_init()

#define STP_PULSE_RESET_START()         do { TMR0_2->CNTER = 0; TMR0_2->CR |= TMR0_CR_START; } while (0)
#define STP_PULSE_RESET_STOP()          (TMR0_2->CR &= ~TMR0_CR_START)
#define STP_PULSE_RESET_COUNT_SET(val)  (TMR0_2->CMPAR = 256u - (uint32_t)(uint8_t)(val))
#define STP_PULSE_RESET_COMPARE_SET(val) (TMR0_2->CMPBR = 256u - (uint32_t)(uint8_t)(val))

#ifdef STEP_PULSE_DELAY
  #define TMR0_IER_CMPBIE  (1U << 1)   /* UNVERIFIED bit position */
  #define STP_PULSE_DELAY_INIT()        (TMR0_2->IER |= TMR0_IER_CMPBIE)
#endif

/* SPINDLE PWM TIMER (TIMERA unit 1, channel 1)
 * hal_timer_spindle_pwm_init() (platform.c) configures PERAR =
 * SPINDLE_PWM_MAX_VALUE and starts the counter with the channel output
 * disconnected (CCONR1 channel-enable bit clear). All macros are single
 * register accesses: ISR-hot safe (section 6.1).
 */

void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

#define PWM_ENABLE()            (TMRA_1->CCONR1 |= TMRA_CCONR_CH_ENABLE)
#define PWM_DISABLE()           (TMRA_1->CCONR1 &= ~TMRA_CCONR_CH_ENABLE)
#define PWM_IS_ENABLED()        (TMRA_1->CCONR1 & TMRA_CCONR_CH_ENABLE)
#define PWM_SET(duty_value)     (TMRA_1->CMPAR1 = (duty_value))

#endif /* HC32F460_TIMER_H */
