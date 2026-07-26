/*
  timer.h - SG2002 stepper / pulse-reset / spindle-PWM timer primitives
  Part of Grbl

  TIMER ALLOTMENT (PORTING-CHECKLIST Step 3's rule, CONTRACTS.md §14 item
  11: audit IRQ capability BEFORE assigning roles):

    stepper timer  = DesignWare APB timer channel 0  (PLIC IRQ, user-defined
                     reload mode)
    pulse reset    = DesignWare APB timer channel 1  (PLIC IRQ, one-shot by
                     software: the handler stops it)
    spindle PWM    = cvitek PWM block 0, channel SPINDLE_PWM_CH (no IRQ
                     needed, and none is used)

  Both timer channels are in the SAME DesignWare block and therefore
  genuinely have interrupt lines - that is the property §14 item 11 says to
  check first, and it is checkable here from the DW databook independently
  of any SG2002 documentation (which does not exist). What is UNVERIFIED is
  the block's base, its PLIC IRQ numbers, and its input clock - see
  sg2002.h's banner over the timer block.

  ============================================================================
  TWO SHAPES THIS IP DOES NOT HAVE, AND HOW EACH IS SUPPLIED
  ============================================================================

  (1) NO HARDWARE PRESCALER. The DW APB timer counts at its input clock,
      period. CONTRACTS.md §3 requires STP_TMR_PRESCALER_SET(v) with v in
      {1,2,3} meaning divide-by-{1,8,64}, and explicitly forbids the silent
      no-op (the SAMD21 cautionary tale). This port does what ch570 did on
      the same problem: folds the divisor into a stored SOFTWARE multiplier
      that STP_TMR_PERIOD_SET applies to the value it writes. Externally
      observable semantics are identical - the step tick's real-time period
      scales by the selected divisor, and the change takes effect for the
      segment being loaded, exactly as the contract requires. The counter is
      32-bit, so 65535 (core's uint16_t period) * 64 = 4,194,240 has three
      orders of magnitude of headroom.

  (2) NO /8 TICK. AVR's Timer0 runs at F_CPU/8 and core's pulse arithmetic
      bakes that in as a `>> 3`. CONTRACTS.md §4 states the alternative
      plainly: "A port clocking this timer at F_CPU/1 must divide by 8 in
      hardware or rescale". This port rescales, in the one place that can do
      it without touching core arithmetic: START() loads

          (256 - val) * 8

      counts, where `val` is the uint8_t two's-complement preload core
      handed to COUNT_SET. That reproduces BOTH halves of the §4 contract at
      once - the exact `(256 - val) * 8 / F_CPU` pulse width, and the 8-bit
      overflow HORIZON (the 256 is computed from a uint8_t, so the wrap
      point is core's, not the 32-bit counter's). This is the SAMD21 gap of
      §4 fixed rather than inherited: samd21 loaded the raw 8-bit value into
      a 16-bit counter and got millisecond pulses.

  ============================================================================
  STEP_PULSE_DELAY
  ============================================================================
  Supported - unlike ch32v006/ch570, which had to #error because their
  pulse timer had a single compare. The DW block has eight independent
  channels; channel 2 is free and takes the delayed-step role.
*/

#ifndef TIMER_SG2002_H
#define TIMER_SG2002_H

#include <stdint.h>
#include "sg2002.h"

// Channel allocation. Board config may not override these - they are
// peripheral-internal, not pins.
#define SG2002_TMR_CH_STEP        0u
#define SG2002_TMR_CH_PULSE       1u
#define SG2002_TMR_CH_PULSE_DLY   2u

// ============================================================================
// ISR DEFINITION MACROS (CONTRACTS.md #5) - core supplies the bodies; the
// vector wrappers in handlers.c clear the peripheral flag first, then call
// these.
// ============================================================================
#define ISR_STEP()          void __isr_step_impl(void)
#define ISR_STEP_RESET()    void __isr_step_reset_impl(void)
#define ISR_STEP_DELAY()    void __isr_step_delay_impl(void)

// ============================================================================
// STEPPER TIMER (CONTRACTS.md #3)
// ============================================================================
void hal_timer_stepper_init(void);
#define STP_TMR_INIT()          hal_timer_stepper_init()

// INT_MASK is active-high "masked", so enabling the interrupt CLEARS it.
#define STP_TMR_INT_ENA()       (SG2002_TMR_CONTROL(SG2002_TMR_CH_STEP) &= ~SG2002_TMR_CTRL_INT_MASK)
#define STP_TMR_INT_DIS()       (SG2002_TMR_CONTROL(SG2002_TMR_CH_STEP) |=  SG2002_TMR_CTRL_INT_MASK)

/*
  PERIOD_SET (ISR-hot, every step tick). In user-defined-reload mode the DW
  timer latches LoadCount at the NEXT expiry, so writing it mid-count changes
  the period of the following tick without disturbing the one in flight -
  precisely the AVR OCR1A semantic §3 specifies. The software divisor from
  PRESCALER_SET is applied here (see this file's header).
*/
extern uint32_t g_sg2002_stepper_divisor;   // 1, 8 or 64 - platform.c
#define STP_TMR_PERIOD_SET(cycles) \
  (SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_STEP) = (uint32_t)(cycles) * g_sg2002_stepper_divisor)

// Prescaler encoding is fixed by core (stepper.c:1032-1044): 1=/1, 2=/8, 3=/64.
#define STP_TMR_PRESCALER_SET(v) \
  (g_sg2002_stepper_divisor = ((v) == 1u ? 1u : ((v) == 2u ? 8u : 64u)))
#define STP_TMR_PRESCALER_RESET() (g_sg2002_stepper_divisor = 1u)

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md #4)
//
// COUNT_SET stores core's uint8_t preload; START converts it to the real
// tick count. Splitting it this way (rather than computing in COUNT_SET) is
// what keeps the 8-bit horizon exact: `256 - val` is evaluated on the
// uint8_t core actually handed us.
// ============================================================================
void hal_timer_pulse_reset_init(void);
#define STP_PULSE_RESET_INIT()   hal_timer_pulse_reset_init()

extern uint8_t g_sg2002_pulse_preload;   // platform.c

#define STP_PULSE_RESET_COUNT_SET(val)  (g_sg2002_pulse_preload = (uint8_t)(val))

#define STP_PULSE_RESET_START()  do { \
    SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE)   &= ~SG2002_TMR_CTRL_ENABLE; \
    SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_PULSE)  = \
        ((uint32_t)(256u - (uint32_t)g_sg2002_pulse_preload) * 8u); \
    SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE)   |= SG2002_TMR_CTRL_ENABLE; \
  } while (0)

#define STP_PULSE_RESET_STOP()   (SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE) &= ~SG2002_TMR_CTRL_ENABLE)

/*
  STEP_PULSE_DELAY support. Defined UNCONDITIONALLY, not behind
  `#ifdef STEP_PULSE_DELAY`, and that is deliberate: this header is injected
  by the prelude at the very top of every translation unit, BEFORE grbl.h
  pulls in core's config.h, so no core build option is visible here yet. A
  guard written at this point would silently never fire - the exact
  compiles-but-dead shape this project keeps finding. Core only expands these
  macros when the option is on, and --gc-sections drops the unused init
  otherwise, so unconditional definition costs nothing and cannot lie.
*/
void hal_timer_pulse_delay_init(void);
#define STP_PULSE_DELAY_INIT()  hal_timer_pulse_delay_init()

// Core hands the SAME two's-complement 8-bit form here (stepper.c:242), so
// the same (256 - val) * 8 rescale applies.
#define STP_PULSE_RESET_COMPARE_SET(val)  do { \
    SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE_DLY)   &= ~SG2002_TMR_CTRL_ENABLE; \
    SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_PULSE_DLY)  = \
        ((uint32_t)(256u - (uint32_t)(uint8_t)(val)) * 8u); \
    SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE_DLY)   |= SG2002_TMR_CTRL_ENABLE; \
  } while (0)

// ============================================================================
// SPINDLE PWM (CONTRACTS.md #6) - cvitek PWM block, UNVERIFIED register
// layout (sg2002.h). Duty is core's uint8_t against a PERIOD register
// programmed to SPINDLE_PWM_MAX_VALUE so the ratio is exact with no
// rescaling: HLPERIOD = duty, PERIOD = 255.
// ============================================================================
// Defined unconditionally for the same reason as the STEP_PULSE_DELAY block
// above: VARIABLE_SPINDLE lives in core's config.h, which this header is
// injected long before.
void hal_timer_spindle_pwm_init(void);
#define PWM_INIT()          hal_timer_spindle_pwm_init()

#define PWM_ENABLE()        do { SG2002_PWM_OE    |= (1UL << SPINDLE_PWM_CH); \
                                 SG2002_PWM_START |= (1UL << SPINDLE_PWM_CH); } while (0)
#define PWM_DISABLE()       do { SG2002_PWM_START &= ~(1UL << SPINDLE_PWM_CH); \
                                 SG2002_PWM_OE    &= ~(1UL << SPINDLE_PWM_CH); } while (0)
#define PWM_IS_ENABLED()    ((SG2002_PWM_OE >> SPINDLE_PWM_CH) & 1UL)

// PWMUPDATE latches the new HLPERIOD/PERIOD pair atomically at the next
// period boundary - without it a duty write can be sampled mid-period and
// emit one runt pulse. ISR-hot but bounded: a multiply and two stores, no
// polling.
//
// g_sg2002_pwm_scale is the same factor PERIOD carries (platform.c), so the
// duty RATIO - the thing CONTRACTS.md #6 binds - is exact for every value of
// the uint8_t duty domain, with no rounding introduced by the scaling.
extern uint32_t g_sg2002_pwm_scale;   // platform.c
#define PWM_SET(duty_value) do { \
    SG2002_PWM_HLPERIOD(SPINDLE_PWM_CH) = (uint32_t)(uint8_t)(duty_value) * g_sg2002_pwm_scale; \
    SG2002_PWM_UPDATE |= (1UL << SPINDLE_PWM_CH); \
  } while (0)

#endif // TIMER_SG2002_H
