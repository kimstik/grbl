/* stubs.c - the rest of Grbl, reduced to what gcode.c, motion_control.c and planner.c
   link against. Reachable stubs model the real behaviour the tests rely on; the rest
   abort, so an unnoticed dependency cannot feed zeros into a result. */
#include "grbl.h"
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

float tb_coord[N_COORDINATE_SYSTEM + 2][N_AXIS]; /* G54..G59, G28, G30 */
int tb_soft_limit_hits, tb_realtime_calls;
void tb_drain(void);

static void unreachable(const char *who) { fprintf(stderr, "tb: unexpected call %s\n", who); abort(); }

/* --- reachable --- */
uint8_t settings_read_coord_data(uint8_t i, float *v) { memcpy(v, tb_coord[i], sizeof(tb_coord[i])); return true; }
void settings_write_coord_data(uint8_t i, float *v) { memcpy(tb_coord[i], v, sizeof(tb_coord[i])); }
/* Past a million calls for one line the line is not going to end: abort it, as a reset would. */
void protocol_execute_realtime(void) { if (++tb_realtime_calls > 1000000) { sys.abort = true; } }
void protocol_auto_cycle_start(void) { tb_drain(); }     /* planner full: consume blocks */
void protocol_buffer_synchronize(void) { tb_drain(); }
void st_update_plan_block_parameters(void) {}
#ifdef BEZIER_Z_SCHEDULE
/* No stepper or future-segment runway exists in the ordinary host bench. */
uint8_t st_has_compute_reserve(void) { return false; }
#endif
void system_flag_wco_change(void) {}
void report_status_message(uint8_t s) { (void)s; }
void report_feedback_message(uint8_t m) { (void)m; }
void spindle_sync(uint8_t s, float r) { (void)s; (void)r; }
void coolant_sync(uint8_t m) { (void)m; }
void spindle_stop(void) {}
void coolant_stop(void) {}
void st_go_idle(void) {}
void st_reset(void) {}
void system_set_exec_state_flag(uint8_t m) { sys_rt_exec_state |= m; }
void system_set_exec_alarm(uint8_t c) { sys_rt_exec_alarm = c; }
uint8_t get_direction_pin_mask(uint8_t axis) { return (uint8_t)(1u << axis); }
void system_convert_array_steps_to_mpos(float *pos, int32_t *steps)
{
  for (uint8_t i = 0; i < N_AXIS; i++) { pos[i] = steps[i] / settings.steps_per_mm[i]; }
}
/* limits.c/system.c semantics, minus the feed-hold wait: violation -> reset -> abort */
void limits_soft_check(float *target)
{
  for (uint8_t i = 0; i < N_AXIS; i++) {
    if (target[i] > 0 || target[i] < settings.max_travel[i]) {
      tb_soft_limit_hits++; sys.soft_limit = true; sys.abort = true;
      sys_rt_exec_alarm = EXEC_ALARM_SOFT_LIMIT; return;
    }
  }
}

/* --- not reachable from the tested paths --- */
void coolant_set_state(uint8_t m) { (void)m; unreachable("coolant_set_state"); }
void spindle_set_state(uint8_t s, float r) { (void)s; (void)r; unreachable("spindle_set_state"); }
uint8_t jog_execute(plan_line_data_t *p, parser_block_t *b) { (void)p; (void)b; unreachable("jog_execute"); return 0; }
void limits_disable(void) { unreachable("limits_disable"); }
void limits_init(void) { unreachable("limits_init"); }
void limits_go_home(uint8_t m) { (void)m; unreachable("limits_go_home"); }
void probe_configure_invert_mask(uint8_t m) { (void)m; unreachable("probe_configure_invert_mask"); }
uint8_t probe_get_state(void) { unreachable("probe_get_state"); return 0; }
void protocol_exec_rt_system(void) { unreachable("protocol_exec_rt_system"); }
void report_probe_parameters(void) { unreachable("report_probe_parameters"); }
