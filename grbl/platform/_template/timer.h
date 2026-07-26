/*
  timer.h - _template stepper/pulse/PWM timer primitives (copy-me starting point)
  Part of Grbl

  Every macro below is either (a) a pure naming convention with no chip
  content (ISR_STEP/ISR_STEP_RESET/ISR_STEP_DELAY - just tell the core what
  to call the ISR body function) or (b) a call to an undeclared
  PORT_TODO_<name>() function. (b) compiles today (implicit-declaration
  warning) and only fails at LINK time, once and only for the macros this
  build path actually reaches - CONTRACTS.md's linker-as-checklist.

  Do NOT "temporarily" make any of (b) an empty statement to get further.
  That is exactly the STP_TMR_PRESCALER_SET trap CONTRACTS.md opens with:
  SAMD21's empty prescaler macro compiles, links, and silently runs slow
  segments 8-64x too fast. An undefined symbol is loud; an empty macro is
  not - that is the entire point of this design.
*/

#ifndef TIMER_TEMPLATE_H
#define TIMER_TEMPLATE_H

#warning "PORT-TODO: timer.h"

// ============================================================================
// ISR DEFINITION MACROS (CONTRACTS.md §5) - naming only, no chip content.
// ============================================================================
// Core supplies the ISR bodies (stepper.c:326,496,511) as plain named
// functions; handlers.c declares them `extern` and calls them from vector
// wrappers that clear the peripheral INTFLAG FIRST, then call the body
// (§2.3/§5.1 - order matters, reversing it drops/ghosts the final edge).
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (CONTRACTS.md §3) - semantic origin: AVR Timer1 CTC.
// ============================================================================
/*
  STP_TMR_INIT()          periodic compare timer, CTC-class mode, compare
                          interrupt masked, no PWM output routing. Context: init.
  STP_TMR_INT_ENA()       unmask compare interrupt. Context: main (st_wake_up).
  STP_TMR_INT_DIS()       mask it. Context: ISR (st_go_idle runs inside ISR_STEP).
  STP_TMR_PERIOD_SET(v)   uint16_t ticks; next tick's period, without
                          stopping/resetting the counter mid-count. ISR-hot.
  STP_TMR_PRESCALER_SET(v) v in {1,2,3} = /1,/8,/64 (stepper.c:1032-1044).
                          Only reached in non-AMASS builds (default AMASS on
                          - config.h:304 - never calls this by default).
                          ISR-hot. No-op is conditional-legal ONLY with an
                          #error in non-AMASS builds - PORT_TODO already
                          gives you that failure for free, don't also stub it.
  STP_TMR_PRESCALER_RESET() restore /1. UNCONDITIONAL - called every
                          st_go_idle() regardless of AMASS (stepper.c:258).
                          This one WILL show up in the default self-test link.
*/
#define STP_TMR_INIT()                    PORT_TODO_STP_TMR_INIT()
#define STP_TMR_INT_ENA()                 PORT_TODO_STP_TMR_INT_ENA()
#define STP_TMR_INT_DIS()                 PORT_TODO_STP_TMR_INT_DIS()
#define STP_TMR_PERIOD_SET(cycles)        PORT_TODO_STP_TMR_PERIOD_SET(cycles)
#define STP_TMR_PRESCALER_SET(prescaler)  PORT_TODO_STP_TMR_PRESCALER_SET(prescaler)
#define STP_TMR_PRESCALER_RESET()         PORT_TODO_STP_TMR_PRESCALER_RESET()

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md §4) - semantic origin: AVR Timer0, 8-bit.
// ============================================================================
/*
  The 8-bit horizon contract: core computes step_pulse_time into a uint8_t
  (stepper.c:245) and expects the pulse width to equal
  `(256 - val) * 8 / F_CPU`. Your PORT_TODO_STP_PULSE_RESET_START()
  implementation must reproduce the 256-count overflow horizon on whatever
  width counter your chip has (8-bit mode, or bias the load value, or
  TOP=255) - do not just load a wider counter and get ms-scale pulses
  instead of settings.pulse_microseconds (the SAMD21 TC4 COUNT16 bug this
  contract exists to prevent you from repeating).
*/
#define STP_PULSE_RESET_INIT()            PORT_TODO_STP_PULSE_RESET_INIT()
#define STP_PULSE_RESET_COUNT_SET(val)    PORT_TODO_STP_PULSE_RESET_COUNT_SET(val)
#define STP_PULSE_RESET_START()           PORT_TODO_STP_PULSE_RESET_START()
#define STP_PULSE_RESET_STOP()            PORT_TODO_STP_PULSE_RESET_STOP()

// PORT-TODO NOTE (do not re-add `#ifdef STEP_PULSE_DELAY` around this):
// this file is reached through the build prelude (-include
// boards/$(BOARD)/prelude.h, CONTRACTS.md #0), which runs before grbl.h's
// own #include "config.h" ever defines STEP_PULSE_DELAY - a guard here
// can never observe it, silently dropping these macros even when a port
// copied from this template enables the feature (CONTRACTS.md #19 "guard
// that certifies instead of checking", wrong-phase variant - every landed
// port hit this and had it removed here, see grbl/CONTRACTS.md gap log).
// Defining them unconditionally costs nothing: the PORT_TODO_* stubs are
// only ever referenced from core's own (correctly-timed)
// `#ifdef STEP_PULSE_DELAY` in stepper.c, and the linker-as-checklist
// mechanism (CONTRACTS.md #14.3) still catches an unimplemented stub the
// moment a real port turns the feature on.
#define STP_PULSE_RESET_COMPARE_SET(val) PORT_TODO_STP_PULSE_RESET_COMPARE_SET(val)
#define STP_PULSE_DELAY_INIT()           PORT_TODO_STP_PULSE_DELAY_INIT()

// ============================================================================
// SPINDLE PWM (CONTRACTS.md §6) - only compiled under VARIABLE_SPINDLE.
// ============================================================================
/*
  ISR-hot is not optional: spindle_set_speed() runs from ISR_STEP
  (stepper.c:396,404) - SET/ENABLE/DISABLE must be bounded-time.
  Duty domain: core plumbs duty as uint8_t end-to-end - your board's
  SPINDLE_PWM_MAX_VALUE (boards/generic/config.h) MUST be <= 255, and your
  PWM_SET() must accept exactly that range. SAMD21 got this wrong in both
  directions at once (65535 vs an 0xFF PER register) - see CONTRACTS.md §6.2.
*/
#define PWM_INIT()              PORT_TODO_PWM_INIT()
#define PWM_ENABLE()            PORT_TODO_PWM_ENABLE()
#define PWM_DISABLE()           PORT_TODO_PWM_DISABLE()
#define PWM_IS_ENABLED()        PORT_TODO_PWM_IS_ENABLED()
#define PWM_SET(duty_value)     PORT_TODO_PWM_SET(duty_value)

#endif // TIMER_TEMPLATE_H
