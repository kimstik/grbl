/*
  timer.h - CH32V006 stepper/pulse/PWM timer primitives
  Part of Grbl

  PORTING-CHECKLIST Step 3 - NOT implemented this batch (Phase 4 M1-M3
  stops after clock+GPIO; timers/serial/nvmem are "the NEXT batch" per
  the batch's own mandate). Kept exactly at the `_template` stage: every
  macro expands to a call to an undeclared PORT_TODO_<name>() function
  (CONTRACTS.md's linker-as-checklist) rather than a stubbed no-op -
  the cautionary tale this whole design exists to prevent
  (STP_TMR_PRESCALER_SET as an empty comment on SAMD21).

  Real register facts this port WILL need for Step 3 (recorded here so
  the next batch doesn't start from zero): TIM2 = stepper timer, TIM1 =
  spindle PWM (has BDTR/MOE, the advanced-timer output-enable STM32F1
  boards also need - CONTRACTS.md #6 PWM_ENABLE), TIM3 candidate for
  pulse-reset. See ch32v006.h for the TIM_TypeDef shape - UNVERIFIED
  field-by-field, same caveat as everywhere else in this port.
*/

#ifndef TIMER_CH32V006_H
#define TIMER_CH32V006_H

// ============================================================================
// ISR DEFINITION MACROS (CONTRACTS.md #5) - naming only, no chip content.
// ============================================================================
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (CONTRACTS.md #3)
// ============================================================================
#define STP_TMR_INIT()                    PORT_TODO_STP_TMR_INIT()
#define STP_TMR_INT_ENA()                 PORT_TODO_STP_TMR_INT_ENA()
#define STP_TMR_INT_DIS()                 PORT_TODO_STP_TMR_INT_DIS()
#define STP_TMR_PERIOD_SET(cycles)        PORT_TODO_STP_TMR_PERIOD_SET(cycles)
#define STP_TMR_PRESCALER_SET(prescaler)  PORT_TODO_STP_TMR_PRESCALER_SET(prescaler)
#define STP_TMR_PRESCALER_RESET()         PORT_TODO_STP_TMR_PRESCALER_RESET()

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md #4)
// ============================================================================
#define STP_PULSE_RESET_INIT()            PORT_TODO_STP_PULSE_RESET_INIT()
#define STP_PULSE_RESET_COUNT_SET(val)    PORT_TODO_STP_PULSE_RESET_COUNT_SET(val)
#define STP_PULSE_RESET_START()           PORT_TODO_STP_PULSE_RESET_START()
#define STP_PULSE_RESET_STOP()            PORT_TODO_STP_PULSE_RESET_STOP()

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_RESET_COMPARE_SET(val) PORT_TODO_STP_PULSE_RESET_COMPARE_SET(val)
  #define STP_PULSE_DELAY_INIT()           PORT_TODO_STP_PULSE_DELAY_INIT()
#endif

// ============================================================================
// SPINDLE PWM (CONTRACTS.md #6) - only compiled under VARIABLE_SPINDLE.
// ============================================================================
#define PWM_INIT()              PORT_TODO_PWM_INIT()
#define PWM_ENABLE()            PORT_TODO_PWM_ENABLE()
#define PWM_DISABLE()           PORT_TODO_PWM_DISABLE()
#define PWM_IS_ENABLED()        PORT_TODO_PWM_IS_ENABLED()
#define PWM_SET(duty_value)     PORT_TODO_PWM_SET(duty_value)

#endif // TIMER_CH32V006_H
