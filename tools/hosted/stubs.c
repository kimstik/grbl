/*
  stubs.c - the rest of GRBL, reduced to what the frozen stepper TU links against.

  Part of Grbl / Intelligence assisted / License: MIT

  Only the CONSUMER path is exercised by the oracle, and the consumer path
  (ISR_STEP / ISR_STEP_RESET) touches exactly: sys, sys_position,
  sys_probe_state, settings, spindle_set_speed(), probe_state_monitor(),
  system_set_exec_state_flag(), st_go_idle(). Everything else here exists only
  so the producer half of stepper.c (st_prep_buffer, never called) resolves at
  link time; a stub that IS reachable from the ISR is marked REACHABLE and does
  something real, a stub that is not aborts if ever called, so an unnoticed
  dependency cannot silently return zeros into a golden trace.
*/

#include "prelude.h"
#include <stdio.h>

system_t sys;
int32_t sys_position[N_AXIS];
int32_t sys_probe_position[N_AXIS];
volatile uint8_t sys_probe_state;
volatile uint8_t sys_rt_exec_state;
volatile uint8_t sys_rt_exec_alarm;
volatile uint8_t sys_rt_exec_motion_override;
volatile uint8_t sys_rt_exec_accessory_override;
settings_t settings;

/* Set by the driver when the probe pin should read TRIGGERED. */
uint8_t hosted_probe_pin_triggered;
uint32_t hosted_probe_tick;      /* tick# of the latch, 0 = never */
extern uint32_t hosted_tick_no;

static void unreachable(const char *who)
{
  fprintf(stderr, "hosted oracle: producer-side stub '%s' was called - the "
                  "oracle must only drive the consumer path\n", who);
  abort();
}

/* REACHABLE from ISR_STEP. */
void spindle_set_speed(uint8_t pwm_value) { hrt_spindle_pwm(pwm_value); }

void system_set_exec_state_flag(uint8_t mask)
{
  sys_rt_exec_state |= mask;
  if (mask & EXEC_CYCLE_STOP) { hrt.cycle_stop = 1; }
}

/* REACHABLE from ISR_STEP when sys_probe_state == PROBE_ACTIVE. Mirrors
   probe.c's probe_state_monitor() exactly: sample the ($6-inverted) pin, and on
   a trigger latch all three position counters in this same tick and disarm. */
void probe_state_monitor(void)
{
  if (hosted_probe_pin_triggered) {
    sys_probe_state = PROBE_OFF;
    memcpy(sys_probe_position, sys_position, sizeof(sys_position));
    hosted_probe_tick = hosted_tick_no + 1u;
    bit_true(sys_rt_exec_state, EXEC_MOTION_CANCEL);
  }
}

/* REACHABLE from st_go_idle(). $1 idle lock; the oracle takes no wall time. */
void delay_ms(uint16_t ms) { (void)ms; hrt.idle_called = 1; }
void delay_us(uint32_t us) { (void)us; }
void _delay_ms(double ms)  { (void)ms; }
void _delay_us(double us)  { (void)us; }

/* Producer side - linked, never called. */
plan_block_t *plan_get_current_block(void) { unreachable("plan_get_current_block"); return NULL; }
plan_block_t *plan_get_system_motion_block(void) { unreachable("plan_get_system_motion_block"); return NULL; }
void plan_discard_current_block(void) { unreachable("plan_discard_current_block"); }
float plan_get_exec_block_exit_speed_sqr(void) { unreachable("plan_get_exec_block_exit_speed_sqr"); return 0.0f; }
float plan_compute_profile_nominal_speed(plan_block_t *b) { (void)b; unreachable("plan_compute_profile_nominal_speed"); return 0.0f; }
void plan_cycle_reinitialize(void) { unreachable("plan_cycle_reinitialize"); }
uint8_t plan_get_block_buffer_available(void) { unreachable("plan_get_block_buffer_available"); return 0; }
uint8_t spindle_compute_pwm_value(float rpm) { (void)rpm; unreachable("spindle_compute_pwm_value"); return 0; }
uint8_t get_step_pin_mask(uint8_t axis) { return (uint8_t)(1u << axis); }
uint8_t get_direction_pin_mask(uint8_t axis) { return (uint8_t)(1u << axis); }
