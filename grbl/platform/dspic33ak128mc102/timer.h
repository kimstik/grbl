/*
  timer.h - dsPIC33AK128MC102 stepper/pulse/PWM timer primitives
  Part of Grbl
*/

#ifndef TIMER_DSPIC33AK128MC102_H
#define TIMER_DSPIC33AK128MC102_H

#include <xc.h>
#include <stdint.h>

// ISR DEFINITION MACROS (CONTRACTS.md #5) - naming only, no chip content.
// Core supplies the ISR bodies (stepper.c:326,496,511) as plain named
// functions; handlers.c declares them `extern` and calls them from the
// real dsPIC ISR vectors (__attribute__((interrupt)) _T1Interrupt etc.),
// clearing the IFSx flag FIRST, then calling the body (#2.3/#5.1).
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// STEPPER TIMER (CONTRACTS.md #3) - Timer1, semantic origin AVR Timer1 CTC.
// hal_timer_stepper_init() (platform.c): T1CON cleared, TMR1=0, PR1 set to
// a safe default, TCKPS=0 (/1), counter STARTED (T1CONbits.ON=1) with the
// compare interrupt masked (_T1IE=0) - INIT+RESET together yield the
// contract's "running, /1, interrupt masked" state (samd21 TC3 precedent,
// CONTRACTS.md #3 INIT row).
void hal_timer_stepper_init(void);
#define STP_TMR_INIT()                    hal_timer_stepper_init()

#define STP_TMR_INT_ENA()                 (_T1IE = 1)
#define STP_TMR_INT_DIS()                 (_T1IE = 0)

// PR1 is a real double-buffered period register (T1CONbits.PRWIP signals
// a pending write) - functionally the same "takes effect for the next
// compare without stopping the counter" semantic as AVR's OCR1A
// (CONTRACTS.md #3 PERIOD_SET row); `cycles` is uint16_t per stepper.c:86,
// PR1 is a 32-bit SFR so this just zero-extends.
#define STP_TMR_PERIOD_SET(cycles)        (PR1 = (cycles))

// TCKPS is a real 2-bit hardware prescaler (00=/1,01=/8,10=/64 - the
// standard PIC24/dsPIC Type-B/C timer encoding, unchanged across the
// whole family for decades); prescaler encoding fixed by stepper.c:
// 1={1}, 2={2}, 3={3} map to /1,/8,/64 (stepper.c:1032-1044). Real
// implementation, not a no-op - the SAMD21 cautionary tale does not
// recur here because this hardware genuinely has the field.
#define STP_TMR_PRESCALER_SET(prescaler)  (T1CONbits.TCKPS = ((prescaler) == 1 ? 0u : ((prescaler) == 2 ? 1u : 2u)))
#define STP_TMR_PRESCALER_RESET()         (T1CONbits.TCKPS = 0)

// PULSE-RESET TIMER (CONTRACTS.md #4) - SCCP1 in 16-bit Timer mode.
// The 8-bit overflow-horizon contract (core hands a uint8_t two's-
// complement negative count; the real AVR hardware free-runs an 8-bit
// counter from that preload to its natural 256-count overflow) is
// reproduced WITHOUT needing an 8-bit counter or an exact /8 hardware
// prescale: SCCP1 has a real period-compare register (CCP1PR), so
// hal_timer_pulse_count_set() below computes ticks_needed = 256 - val
// (1..256) directly and multiplies by 8 IN SOFTWARE before loading
// CCP1PR, running the timer at its raw /1 tick (CLKSEL/TMRPS both
// UNVERIFIED-assumed - see file header) instead of trying to force an
// exact F_CPU/8 hardware prescale. This is the "or rescale" branch of the
// CONTRACTS.md #4 prescale note, not the "hardware /8" branch - cleaner
// than fighting a 2-bit TMRPS field that (per the standard family
// encoding assumed here) offers /1,/4,/16,/64, none of which is /8.
void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()            hal_timer_pulse_reset_init()

static inline void hal_timer_pulse_count_set(uint8_t val) {
  uint16_t ticks_needed = (uint16_t)(256u - (uint16_t)val);   // 1..256
  CCP1PR = (uint32_t)(ticks_needed * 8u - 1u);                // max 2047, fits easily
}
#define STP_PULSE_RESET_COUNT_SET(val)    hal_timer_pulse_count_set(val)

// START: reset the counter to 0 then run - each pulse gets a fresh count
// from zero, matching the AVR "preload then free-run to overflow" shape.
#define STP_PULSE_RESET_START()           do { CCP1TMR = 0; CCP1CON1bits.ON = 1; } while (0)
#define STP_PULSE_RESET_STOP()            do { CCP1CON1bits.ON = 0; } while (0)

#ifdef STEP_PULSE_DELAY
  // CCP1 does have a second compare channel (CCP1RB) that COULD support
  // the two-interrupt delayed-step scheme, but the exact dual-compare
  // interrupt semantics needed (CONTRACTS.md #4 conditional macros) are
  // unverified against real hardware and not implemented - fail loudly
  // per the contract's conditional-no-op rule instead of mistiming
  // pulses silently (STEP_PULSE_DELAY defaults off, config.h:425, so
  // this does not affect the zero-PORT_TODO_* default build).
  #error "STEP_PULSE_DELAY is not supported on dsPIC33AK128MC102 (CCP1RB dual-compare scheme not implemented/verified - see timer.h)"
#endif

// SPINDLE PWM (CONTRACTS.md #6) - SCCP2, only compiled under VARIABLE_SPINDLE.
// SPINDLE_PWM_MAX_VALUE is 255 (boards/generic/config.h) - core plumbs
// duty as uint8_t end-to-end (#6.2); CCP2PR is fixed at 255 for full
// 8-bit duty resolution, never touched again after init.
void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()              hal_timer_spindle_pwm_init()

static inline void hal_timer_spindle_pwm_enable(void)  { CCP2CON2bits.OCAEN = 1; }
static inline void hal_timer_spindle_pwm_disable(void) { CCP2CON2bits.OCAEN = 0; }
#define PWM_ENABLE()            hal_timer_spindle_pwm_enable()
#define PWM_DISABLE()           hal_timer_spindle_pwm_disable()
#define PWM_IS_ENABLED()        (CCP2CON2bits.OCAEN != 0)
#define PWM_SET(duty_value)     (CCP2RA = (duty_value))

#endif // TIMER_DSPIC33AK128MC102_H
