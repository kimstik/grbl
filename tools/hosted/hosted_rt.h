/*
  hosted_rt.h - virtual machine the hosted oracle runs the frozen ISR against.

  Part of Grbl / Intelligence assisted / License: MIT

  Models exactly the observable surface of the stepper consumer, and nothing
  else: three GPIO ports (STEP, DIRECTION, STEPPERS_DISABLE), the stepper tick
  timer's period register, the pulse-reset one-shot, and the spindle PWM
  register. Every write the frozen ISR performs lands here and is timestamped
  in virtual clocks, so the recorded trace IS the step/dir waveform.

  Virtual time model (normative for the whole conformance corpus):
    - Invocation k of the stepper ISR happens at clock t_k.
    - The period register value P in effect when invocation k RETURNS
      determines the next invocation: t_{k+1} = t_k + (P + 1).
      "+1" is AVR CTC semantics - TOP = OCR1A, so the period is OCR1A+1 counts
      (CONTRACTS.md §3). The frozen ISR writes the period for a freshly popped
      segment near the top of the invocation that pops it, so that segment's
      FIRST tick already runs at the new rate; that is exactly what SEGX/1 §3.3
      requires of an executor, and it falls out of this model for free rather
      than being asserted separately.
    - The pulse-reset one-shot fires at t_k + pulse_ticks, where pulse_ticks is
      derived from $0 by the platform. The hosted platform makes it an explicit
      configured constant instead of AVR's two's-complement Timer0 reload,
      because $0-in-Timer0-counts is a per-platform quantity (CONTRACTS.md §4)
      and the oracle must not bake one platform's prescaler into the goldens.
*/

#ifndef GRBL_HOSTED_RT_H
#define GRBL_HOSTED_RT_H

#include <stdint.h>

enum { HRT_PORT_STEP = 0, HRT_PORT_DIRECTION = 1, HRT_PORT_ENABLE = 2, HRT_PORT_N = 3 };

typedef struct {
  uint8_t  port[HRT_PORT_N];
  uint16_t period;        /* stepper tick period register (cycles_per_tick) */
  uint8_t  timer_enabled;
  uint8_t  pulse_armed;
  uint8_t  pulse_reload;  /* value the ISR handed to STP_PULSE_RESET_COUNT_SET */
  uint8_t  pwm;
  uint8_t  pwm_written;   /* set on any spindle_set_speed() this invocation */
  uint8_t  port_written;  /* bitmask of ports written this invocation */
  uint8_t  idle_called;
  uint8_t  cycle_stop;
} hrt_state_t;

extern hrt_state_t hrt;

void hrt_reset(void);
void hrt_port_write(uint8_t idx, uint8_t v);
uint8_t hrt_port_read(uint8_t idx);
void hrt_bit_set(uint8_t idx, uint8_t mask);
void hrt_bit_clear(uint8_t idx, uint8_t mask);
void hrt_period_set(uint16_t v);
void hrt_pulse_count_set(uint8_t v);
void hrt_pulse_start(void);
void hrt_pulse_stop(void);
void hrt_timer_enable(void);
void hrt_timer_disable(void);
void hrt_spindle_pwm(uint8_t v);

/* The frozen ISRs, named by the hosted ISR_STEP()/ISR_STEP_RESET() macros. */
void grbl_hosted_isr_step(void);
void grbl_hosted_isr_step_reset(void);

#endif /* GRBL_HOSTED_RT_H */
