/*
  timer.h - CH32V006 stepper/pulse/PWM timer primitives
  Part of Grbl
*/

#ifndef TIMER_CH32V006_H
#define TIMER_CH32V006_H

#include "ch32v006.h"

// ISR DEFINITION MACROS (CONTRACTS.md #5) - core defines the bodies as
// plain named functions; the real PFIC vectors live in handlers.c and
// clear the peripheral flag FIRST, then call these.
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// STEPPER TIMER (TIM2 - CONTRACTS.md #3)
// hal_timer_stepper_init() (platform.c) leaves the counter running at /1
// with the update interrupt masked at the peripheral (UIE=0) and the PFIC
// channel enabled; INIT + STP_TMR_PRESCALER_RESET() therefore yield the
// AVR post-init state: running, /1, interrupt masked (CONTRACTS.md #3
// INIT row).

void hal_timer_stepper_init(void);
#define STP_TMR_INIT()                  hal_timer_stepper_init()

#define STP_TMR_INT_ENA()               (TIM2->DMAINTENR |= TIM_DMAINTENR_UIE)
#define STP_TMR_INT_DIS()               (TIM2->DMAINTENR &= ~TIM_DMAINTENR_UIE)
#define STP_TMR_PERIOD_SET(cycles)      (TIM2->ATRLR = (cycles))

// Prescaler encoding fixed by stepper.c:1032-1044: 1 = /1, 2 = /8, 3 = /64.
// TIM PSC is preloaded in hardware: a written value latches at the next
// update event, i.e. for the segment being loaded (AMASS-off builds only).
// No SWEVGR.UG here - forcing an update event would set UIF inside
// ISR_STEP (f103/timer.h has the same note).
#define STP_TMR_PRESCALER_SET(v)        (TIM2->PSC = ((v) == 1 ? 0u : ((v) == 2 ? 7u : 63u)))
#define STP_TMR_PRESCALER_RESET()       (TIM2->PSC = 0)

// PULSE RESET TIMER (STK - CONTRACTS.md #4)
// 8-bit overflow horizon contract: core hands a uint8_t two's-complement
// negative count; the ISR must fire after (256 - val) ticks of F_CPU/8.
// STK setup (hal_timer_pulse_reset_init): STCLK=0 -> HCLK/8 tick, STIE=1,
// STRE=0, STE=0 (stopped), CMPLR=256 fixed. COUNT_SET preloads the 32-bit
// up-counter with the 8-bit value; compare fires at CNT==256, i.e. after
// exactly (256 - val) ticks. SR.CNTIF is cleared (write-0) in the
// handlers.c vector wrapper, flag-clear-first.

void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()          hal_timer_pulse_reset_init()

#define STP_PULSE_RESET_COUNT_SET(val)  (STK->CNTL = (uint32_t)(uint8_t)(val))
#define STP_PULSE_RESET_START()         (STK->CTLR |= STK_CTLR_STE)
#define STP_PULSE_RESET_STOP()          (STK->CTLR &= ~STK_CTLR_STE)

#ifdef STEP_PULSE_DELAY
  // The STK has a single compare channel: the delayed-step scheme (AVR
  // Timer0 OCR0A compare + overflow on one counter) needs two interrupt
  // sources on the pulse timer and this chip has no second interrupt-
  // capable timer left (TIM3 has no IRQ). Fail loudly per CONTRACTS.md
  // #4 "conditional" rule rather than mis-time pulses silently.
  #error "STEP_PULSE_DELAY is not supported on CH32V006 (single-compare STK pulse timer; TIM3 has no interrupt - see timer.h)"
#endif

// SPINDLE PWM TIMER (TIM1 CH1 on PA3 via TIM1_RM=0100 - CONTRACTS.md #6)
// hal_timer_spindle_pwm_init() (platform.c) configures PWM mode 1 with
// ATRLR = SPINDLE_PWM_MAX_VALUE (255), PSC for an AVR-comparable base
// frequency, BDTR.MOE set (advanced-timer master output gate), and
// re-muxes PA3 to the timer AF (spindle_init() calls
// GPIO_DIR_OUT(SPINDLE_PWM) first, which leaves the pin plain GPIO - the
// f103 pattern). CCER.CC1E connects/disconnects the output; with CC1E
// clear OC1 is not driven and the pin sits at the inactive (OIS1=0)
// level, satisfying #6.4. All macros are single register accesses:
// ISR-hot safe (#6.1).

void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

#define PWM_ENABLE()            (TIM1->CCER |= TIM_CCER_CC1E)
#define PWM_DISABLE()           (TIM1->CCER &= ~TIM_CCER_CC1E)
#define PWM_IS_ENABLED()        (TIM1->CCER & TIM_CCER_CC1E)
#define PWM_SET(duty_value)     (TIM1->CH1CVR = (duty_value))

#endif // TIMER_CH32V006_H
