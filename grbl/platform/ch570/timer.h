/*
  timer.h - CH570 stepper/pulse/PWM timer primitives
  Part of Grbl
*/

#ifndef TIMER_CH570_H
#define TIMER_CH570_H

#include "ch570.h"

// ISR DEFINITION MACROS (CONTRACTS.md #5)
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// STEPPER TIMER (TMR0 - CONTRACTS.md #3)
void hal_timer_stepper_init(void);
#define STP_TMR_INIT()                  hal_timer_stepper_init()

#define STP_TMR_INT_ENA()               (TMR0->INTER_EN |= RB_TMR_IE_CYC_END)
#define STP_TMR_INT_DIS()               (TMR0->INTER_EN &= ~RB_TMR_IE_CYC_END)

// PERIOD_SET writes CNT_END scaled by the currently-selected software
// divisor (see file header) - ISR-hot, single function call, no branch on
// the hot path beyond the multiply that was already needed.
extern uint32_t g_ch570_stepper_divisor;   // 1, 8, or 64 - platform.c
#define STP_TMR_PERIOD_SET(cycles)      (TMR0->CNT_END = ((uint32_t)(cycles) * g_ch570_stepper_divisor))

// Prescaler encoding fixed by stepper.c:1032-1044: 1=/1, 2=/8, 3=/64.
#define STP_TMR_PRESCALER_SET(v)        (g_ch570_stepper_divisor = ((v) == 1 ? 1u : ((v) == 2 ? 8u : 64u)))
#define STP_TMR_PRESCALER_RESET()       (g_ch570_stepper_divisor = 1u)

// PULSE RESET TIMER (STK - CONTRACTS.md #4) - identical shape to
// ch32v006's STK usage (same core peripheral, same STCLK=0 => HCLK/8
// convenience matching AVR Timer0's F_CPU/8 prescale 1:1).
void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()          hal_timer_pulse_reset_init()

#define STP_PULSE_RESET_COUNT_SET(val)  (STK->CNTL = (uint32_t)(uint8_t)(val))
#define STP_PULSE_RESET_START()         (STK->CTLR |= STK_CTLR_STE)
#define STP_PULSE_RESET_STOP()          (STK->CTLR &= ~STK_CTLR_STE)

// Same single-compare limitation as ch32v006 (CONTRACTS.md #14 item 11):
// STK has one compare channel, and TMR0 is already the stepper timer - no
// second interrupt-capable counter is free for the delayed-step scheme.
// This is meant to fail loudly per CONTRACTS.md #4's conditional rule.
// The `#ifdef STEP_PULSE_DELAY / #error` used to live right here, but
// this file is reached through the build prelude (-include, CONTRACTS.md
// #0), which runs before grbl.h's own #include "config.h" ever defines
// STEP_PULSE_DELAY - the guard could never see it and the #error could
// never fire (CONTRACTS.md #19 "guard that certifies instead of
// checking", wrong-phase variant; see grbl/CONTRACTS.md gap log). Moved
// to serial.c (already includes grbl.h for other reasons, so it runs
// after core config.h has actually been processed) where it now
// genuinely fires.

// SPINDLE PWM (PWM1, fixed pin PA7 - CONTRACTS.md #6)
void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

#define PWM_ENABLE()            (R8_PWM_OUT_EN |= RB_PWM1_OUT_EN)
#define PWM_DISABLE()           (R8_PWM_OUT_EN &= ~RB_PWM1_OUT_EN)
#define PWM_IS_ENABLED()        (R8_PWM_OUT_EN & RB_PWM1_OUT_EN)
#define PWM_SET(duty_value)     (R8_PWM1_DATA = (uint8_t)(duty_value))

#endif // TIMER_CH570_H
