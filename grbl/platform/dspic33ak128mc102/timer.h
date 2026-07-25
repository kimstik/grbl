/*
  timer.h - dsPIC33AK128MC102 stepper/pulse/PWM timer primitives
  Part of Grbl

  M1-M3 batch: every macro below is either (a) a pure naming convention
  with no chip content (ISR_STEP/ISR_STEP_RESET/ISR_STEP_DELAY) or (b) a
  call to an undeclared PORT_TODO_<name>() function - CONTRACTS.md's
  linker-as-checklist. Steps 3 fills these in against the RM.

  Do NOT "temporarily" make any of (b) an empty statement to get further
  (the STP_TMR_PRESCALER_SET cautionary tale, CONTRACTS.md top-of-file).

  CANDIDATE ALLOCATION for Step 3 (from the DFP vector list - every
  candidate HAS a real interrupt vector, the CONTRACTS.md #14.11 "does
  the timer have an IRQ" audit passes on paper):
    - Stepper timer:     Timer1 (T1CON/_T1Interrupt) - the only classic
                         timer on this chip; 32-bit period register.
    - Pulse-reset timer: SCCP1 timer half (CCP1CON1/_CCT1Interrupt).
                         The #4 8-bit-horizon contract (pulse width =
                         (256 - val) * 8 / F_CPU) must be reproduced by
                         biasing the load value or capping the period -
                         do NOT load the raw 8-bit value into the 32-bit
                         CCP timer (the samd21 TC4 COUNT16 bug).
    - Spindle PWM:       SCCP2 PWM mode -> RP21R (RB4) via PPS, or
                         motor-control PWM PG1 - decide in Step 3.
                         SPINDLE_PWM_MAX_VALUE is 255 (uint8_t duty
                         end-to-end, #6.2); PWM period register must be
                         sized so duty 255 = full scale.
  CLOCK WARNING for Step 3: peripheral clock source/ratio for T1/SCCP is
  NOT the CPU clock by default on dsPIC33A (separate CLKGENs) - verify
  against the RM before writing any period math (platform.h F_CPU note).
*/

#ifndef TIMER_DSPIC33AK128MC102_H
#define TIMER_DSPIC33AK128MC102_H

// ============================================================================
// ISR DEFINITION MACROS (CONTRACTS.md #5) - naming only, no chip content.
// ============================================================================
// Core supplies the ISR bodies (stepper.c:326,496,511) as plain named
// functions; handlers.c declares them `extern` and calls them from the
// real dsPIC ISR vectors (__attribute__((interrupt)) _T1Interrupt etc.),
// clearing the IFSx flag FIRST, then calling the body (#2.3/#5.1).
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (CONTRACTS.md #3) - semantic origin: AVR Timer1 CTC.
// ============================================================================
#define STP_TMR_INIT()                    PORT_TODO_STP_TMR_INIT()
#define STP_TMR_INT_ENA()                 PORT_TODO_STP_TMR_INT_ENA()
#define STP_TMR_INT_DIS()                 PORT_TODO_STP_TMR_INT_DIS()
#define STP_TMR_PERIOD_SET(cycles)        PORT_TODO_STP_TMR_PERIOD_SET(cycles)
#define STP_TMR_PRESCALER_SET(prescaler)  PORT_TODO_STP_TMR_PRESCALER_SET(prescaler)
#define STP_TMR_PRESCALER_RESET()         PORT_TODO_STP_TMR_PRESCALER_RESET()

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md #4) - semantic origin: AVR Timer0, 8-bit.
// ============================================================================
#define STP_PULSE_RESET_INIT()            PORT_TODO_STP_PULSE_RESET_INIT()
#define STP_PULSE_RESET_COUNT_SET(val)    PORT_TODO_STP_PULSE_RESET_COUNT_SET(val)
#define STP_PULSE_RESET_START()           PORT_TODO_STP_PULSE_RESET_START()
#define STP_PULSE_RESET_STOP()            PORT_TODO_STP_PULSE_RESET_STOP()

// Only compiled when STEP_PULSE_DELAY is on (default off, config.h:425) -
// absent entirely otherwise is the contract-correct "conditional" no-op.
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

#endif // TIMER_DSPIC33AK128MC102_H
