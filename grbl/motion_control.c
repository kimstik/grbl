/*
  motion_control.c - high level interface for issuing motion commands
  Part of Grbl

  Copyright (c) 2011-2016 Sungeun K. Jeon for Gnea Research LLC
  Copyright (c) 2009-2011 Simen Svale Skogsrud

  Grbl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Grbl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Grbl.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "grbl.h"


// Execute linear motion in absolute millimeter coordinates. Feed rate given in millimeters/second
// unless invert_feed_rate is true. Then the feed_rate means that the motion should be completed in
// (1 minute)/feed_rate time.
// NOTE: This is the primary gateway to the grbl planner. All line motions, including arc line
// segments, must pass through this routine before being passed to the planner. The seperation of
// mc_line and plan_buffer_line is done primarily to place non-planner-type functions from being
// in the planner and to let backlash compensation or canned cycle integration simple and direct.
void mc_line(float *target, plan_line_data_t *pl_data)
{
  // If enabled, check for soft limit violations. Placed here all line motions are picked up
  // from everywhere in Grbl.
  if (bit_istrue(settings.flags,BITFLAG_SOFT_LIMIT_ENABLE)) {
    // NOTE: Block jog state. Jogging is a special case and soft limits are handled independently.
    if (sys.state != STATE_JOG) { limits_soft_check(target); }
  }

  // If in check gcode mode, prevent motion by blocking planner. Soft limits still work.
  if (sys.state == STATE_CHECK_MODE) { return; }

  // NOTE: Backlash compensation may be installed here. It will need direction info to track when
  // to insert a backlash line motion(s) before the intended line motion and will require its own
  // plan_check_full_buffer() and check for system abort loop. Also for position reporting
  // backlash steps will need to be also tracked, which will need to be kept at a system level.
  // There are likely some other things that will need to be tracked as well. However, we feel
  // that backlash compensation should NOT be handled by Grbl itself, because there are a myriad
  // of ways to implement it and can be effective or ineffective for different CNC machines. This
  // would be better handled by the interface as a post-processor task, where the original g-code
  // is translated and inserts backlash motions that best suits the machine.
  // NOTE: Perhaps as a middle-ground, all that needs to be sent is a flag or special command that
  // indicates to Grbl what is a backlash compensation motion, so that Grbl executes the move but
  // doesn't update the machine position values. Since the position values used by the g-code
  // parser and planner are separate from the system machine positions, this is doable.

  // If the buffer is full: good! That means we are well ahead of the robot.
  // Remain in this loop until there is room in the buffer.
  do {
    protocol_execute_realtime(); // Check for any run-time commands
    if (sys.abort) { return; } // Bail, if system abort.
    if ( plan_check_full_buffer() ) { protocol_auto_cycle_start(); } // Auto-cycle start when buffer is full.
    else { break; }
  } while (1);

  // Plan and queue motion into planner buffer
  if (plan_buffer_line(target, pl_data) == PLAN_EMPTY_BLOCK) {
    if (bit_istrue(settings.flags,BITFLAG_LASER_MODE)) {
      // Correctly set spindle state, if there is a coincident position passed. Forces a buffer
      // sync while in M3 laser mode only.
      if (pl_data->condition & PL_COND_FLAG_SPINDLE_CW) {
        spindle_sync(PL_COND_FLAG_SPINDLE_CW, pl_data->spindle_speed);
      }
    }
  }
}


// Execute an arc in offset mode format. position == current xyz, target == target xyz,
// offset == offset from current xyz, axis_X defines circle plane in tool space, axis_linear is
// the direction of helical travel, radius == circle radius, isclockwise boolean. Used
// for vector transformation direction.
// The arc is approximated by generating a huge number of tiny, linear segments. The chordal tolerance
// of each segment is configured in settings.arc_tolerance, which is defined to be the maximum normal
// distance from segment to the circle when the end points both lie on the circle.
void mc_arc(float *target, plan_line_data_t *pl_data, float *position, float *offset, float radius,
  uint8_t axis_0, uint8_t axis_1, uint8_t axis_linear, uint8_t is_clockwise_arc)
{
  float center_axis0 = position[axis_0] + offset[axis_0];
  float center_axis1 = position[axis_1] + offset[axis_1];
  float r_axis0 = -offset[axis_0];  // Radius vector from center to current location
  float r_axis1 = -offset[axis_1];
  float rt_axis0 = target[axis_0] - center_axis0;
  float rt_axis1 = target[axis_1] - center_axis1;

  // CCW angle between position and target from circle center. Only one atan2() trig computation required.
  float angular_travel = atan2(r_axis0*rt_axis1-r_axis1*rt_axis0, r_axis0*rt_axis0+r_axis1*rt_axis1);
  if (is_clockwise_arc) { // Correct atan2 output per direction
    if (angular_travel >= -ARC_ANGULAR_TRAVEL_EPSILON) { angular_travel -= 2*M_PI; }
  } else {
    if (angular_travel <= ARC_ANGULAR_TRAVEL_EPSILON) { angular_travel += 2*M_PI; }
  }

  // NOTE: Segment end points are on the arc, which can lead to the arc diameter being smaller by up to
  // (2x) settings.arc_tolerance. For 99% of users, this is just fine. If a different arc segment fit
  // is desired, i.e. least-squares, midpoint on arc, just change the mm_per_arc_segment calculation.
  // For the intended uses of Grbl, this value shouldn't exceed 2000 for the strictest of cases.
  uint16_t segments = floor(fabs(0.5*angular_travel*radius)/
                          sqrt(settings.arc_tolerance*(2*radius - settings.arc_tolerance)) );

  if (segments) {
    // Multiply inverse feed_rate to compensate for the fact that this movement is approximated
    // by a number of discrete segments. The inverse feed_rate should be correct for the sum of
    // all segments.
    if (pl_data->condition & PL_COND_FLAG_INVERSE_TIME) { 
      pl_data->feed_rate *= segments; 
      bit_false(pl_data->condition,PL_COND_FLAG_INVERSE_TIME); // Force as feed absolute mode over arc segments.
    }
    
    float theta_per_segment = angular_travel/segments;
    float linear_per_segment = (target[axis_linear] - position[axis_linear])/segments;

    /* Vector rotation by transformation matrix: r is the original vector, r_T is the rotated vector,
       and phi is the angle of rotation. Solution approach by Jens Geisler.
           r_T = [cos(phi) -sin(phi);
                  sin(phi)  cos(phi] * r ;

       For arc generation, the center of the circle is the axis of rotation and the radius vector is
       defined from the circle center to the initial position. Each line segment is formed by successive
       vector rotations. Single precision values can accumulate error greater than tool precision in rare
       cases. So, exact arc path correction is implemented. This approach avoids the problem of too many very
       expensive trig operations [sin(),cos(),tan()] which can take 100-200 usec each to compute.

       Small angle approximation may be used to reduce computation overhead further. A third-order approximation
       (second order sin() has too much error) holds for most, if not, all CNC applications. Note that this
       approximation will begin to accumulate a numerical drift error when theta_per_segment is greater than
       ~0.25 rad(14 deg) AND the approximation is successively used without correction several dozen times. This
       scenario is extremely unlikely, since segment lengths and theta_per_segment are automatically generated
       and scaled by the arc tolerance setting. Only a very large arc tolerance setting, unrealistic for CNC
       applications, would cause this numerical drift error. However, it is best to set N_ARC_CORRECTION from a
       low of ~4 to a high of ~20 or so to avoid trig operations while keeping arc generation accurate.

       This approximation also allows mc_arc to immediately insert a line segment into the planner
       without the initial overhead of computing cos() or sin(). By the time the arc needs to be applied
       a correction, the planner should have caught up to the lag caused by the initial mc_arc overhead.
       This is important when there are successive arc motions.
    */
    // Computes: cos_T = 1 - theta_per_segment^2/2, sin_T = theta_per_segment - theta_per_segment^3/6) in ~52usec
    float cos_T = 2.0 - theta_per_segment*theta_per_segment;
    float sin_T = theta_per_segment*0.16666667*(cos_T + 4.0);
    cos_T *= 0.5;

    float sin_Ti;
    float cos_Ti;
    float r_axisi;
    uint16_t i;
    uint8_t count = 0;

    for (i = 1; i<segments; i++) { // Increment (segments-1).

      if (count < N_ARC_CORRECTION) {
        // Apply vector rotation matrix. ~40 usec
        r_axisi = r_axis0*sin_T + r_axis1*cos_T;
        r_axis0 = r_axis0*cos_T - r_axis1*sin_T;
        r_axis1 = r_axisi;
        count++;
      } else {
        // Arc correction to radius vector. Computed only every N_ARC_CORRECTION increments. ~375 usec
        // Compute exact location by applying transformation matrix from initial radius vector(=-offset).
        cos_Ti = cos(i*theta_per_segment);
        sin_Ti = sin(i*theta_per_segment);
        r_axis0 = -offset[axis_0]*cos_Ti + offset[axis_1]*sin_Ti;
        r_axis1 = -offset[axis_0]*sin_Ti - offset[axis_1]*cos_Ti;
        count = 0;
      }

      // Update arc_target location
      position[axis_0] = center_axis0 + r_axis0;
      position[axis_1] = center_axis1 + r_axis1;
      position[axis_linear] += linear_per_segment;

      mc_line(position, pl_data);

      // Bail mid-circle on system abort. Runtime command check already performed by mc_line.
      if (sys.abort) { return; }
    }
  }
  // Ensure last segment arrives at target location.
  mc_line(target, pl_data);
}


// Execute dwell in seconds.
void mc_dwell(float seconds)
{
  if (sys.state == STATE_CHECK_MODE) { return; }
  protocol_buffer_synchronize();
  delay_sec(seconds, DELAY_MODE_DWELL);
}


// Perform homing cycle to locate and set machine zero. Only '$H' executes this command.
// NOTE: There should be no motions in the buffer and Grbl must be in an idle state before
// executing the homing cycle. This prevents incorrect buffered plans after homing.
void mc_homing_cycle(uint8_t cycle_mask)
{
  // Check and abort homing cycle, if hard limits are already enabled. Helps prevent problems
  // with machines with limits wired on both ends of travel to one limit pin.
  // TODO: Move the pin-specific LIMIT_PIN call to limits.c as a function.
  #ifdef LIMITS_TWO_SWITCHES_ON_AXES
    if (limits_get_state()) {
      mc_reset(); // Issue system reset and ensure spindle and coolant are shutdown.
      system_set_exec_alarm(EXEC_ALARM_HARD_LIMIT);
      return;
    }
  #endif

  limits_disable(); // Disable hard limits pin change register for cycle duration

  // -------------------------------------------------------------------------------------
  // Perform homing routine. NOTE: Special motion case. Only system reset works.
  
  #ifdef HOMING_SINGLE_AXIS_COMMANDS
    if (cycle_mask) { limits_go_home(cycle_mask); } // Perform homing cycle based on mask.
    else
  #endif
  {
    // Search to engage all axes limit switches at faster homing seek rate.
    limits_go_home(HOMING_CYCLE_0);  // Homing cycle 0
    #ifdef HOMING_CYCLE_1
      limits_go_home(HOMING_CYCLE_1);  // Homing cycle 1
    #endif
    #ifdef HOMING_CYCLE_2
      limits_go_home(HOMING_CYCLE_2);  // Homing cycle 2
    #endif
  }

  protocol_execute_realtime(); // Check for reset and set system abort.
  if (sys.abort) { return; } // Did not complete. Alarm state set by mc_alarm.

  // Homing cycle complete! Setup system for normal operation.
  // -------------------------------------------------------------------------------------

  // Sync gcode parser and planner positions to homed position.
  gc_sync_position();
  plan_sync_position();

  // If hard limits feature enabled, re-enable hard limits pin change register after homing cycle.
  limits_init();
}


// Perform tool length probe cycle. Requires probe switch.
// NOTE: Upon probe failure, the program will be stopped and placed into ALARM state.
uint8_t mc_probe_cycle(float *target, plan_line_data_t *pl_data, uint8_t parser_flags)
{
  // TODO: Need to update this cycle so it obeys a non-auto cycle start.
  if (sys.state == STATE_CHECK_MODE) { return(GC_PROBE_CHECK_MODE); }

  // Finish all queued commands and empty planner buffer before starting probe cycle.
  protocol_buffer_synchronize();
  if (sys.abort) { return(GC_PROBE_ABORT); } // Return if system reset has been issued.

  // Initialize probing control variables
  uint8_t is_probe_away = bit_istrue(parser_flags,GC_PARSER_PROBE_IS_AWAY);
  uint8_t is_no_error = bit_istrue(parser_flags,GC_PARSER_PROBE_IS_NO_ERROR);
  sys.probe_succeeded = false; // Re-initialize probe history before beginning cycle.
  probe_configure_invert_mask(is_probe_away);

  // After syncing, check if probe is already triggered. If so, halt and issue alarm.
  // NOTE: This probe initialization error applies to all probing cycles.
  if ( probe_get_state() ) { // Check probe pin state.
    system_set_exec_alarm(EXEC_ALARM_PROBE_FAIL_INITIAL);
    protocol_execute_realtime();
    probe_configure_invert_mask(false); // Re-initialize invert mask before returning.
    return(GC_PROBE_FAIL_INIT); // Nothing else to do but bail.
  }

  // Setup and queue probing motion. Auto cycle-start should not start the cycle.
  mc_line(target, pl_data);

  // Activate the probing state monitor in the stepper module.
  sys_probe_state = PROBE_ACTIVE;

  // Perform probing cycle. Wait here until probe is triggered or motion completes.
  system_set_exec_state_flag(EXEC_CYCLE_START);
  do {
    protocol_execute_realtime();
    if (sys.abort) { return(GC_PROBE_ABORT); } // Check for system abort
  } while (sys.state != STATE_IDLE);

  // Probing cycle complete!

  // Set state variables and error out, if the probe failed and cycle with error is enabled.
  if (sys_probe_state == PROBE_ACTIVE) {
    if (is_no_error) { memcpy(sys_probe_position, sys_position, sizeof(sys_position)); }
    else { system_set_exec_alarm(EXEC_ALARM_PROBE_FAIL_CONTACT); }
  } else {
    sys.probe_succeeded = true; // Indicate to system the probing cycle completed successfully.
  }
  sys_probe_state = PROBE_OFF; // Ensure probe state monitor is disabled.
  probe_configure_invert_mask(false); // Re-initialize invert mask.
  protocol_execute_realtime();   // Check and execute run-time commands

  // Reset the stepper and planner buffers to remove the remainder of the probe motion.
  st_reset(); // Reset step segment buffer.
  plan_reset(); // Reset planner buffer. Zero planner positions. Ensure probing motion is cleared.
  plan_sync_position(); // Sync planner position to current machine position.

  #ifdef MESSAGE_PROBE_COORDINATES
    // All done! Output the probe position as message.
    report_probe_parameters();
  #endif

  if (sys.probe_succeeded) { return(GC_PROBE_FOUND); } // Successful probe cycle.
  else { return(GC_PROBE_FAIL_END); } // Failed to trigger probe within travel. With or without error.
}


// Plans and executes the single special motion case for parking. Independent of main planner buffer.
// NOTE: Uses the always free planner ring buffer head to store motion parameters for execution.
#ifdef PARKING_ENABLE
  void mc_parking_motion(float *parking_target, plan_line_data_t *pl_data)
  {
    if (sys.abort) { return; } // Block during abort.

    uint8_t plan_status = plan_buffer_line(parking_target, pl_data);

    if (plan_status) {
      bit_true(sys.step_control, STEP_CONTROL_EXECUTE_SYS_MOTION);
      bit_false(sys.step_control, STEP_CONTROL_END_MOTION); // Allow parking motion to execute, if feed hold is active.
      st_parking_setup_buffer(); // Setup step segment buffer for special parking motion case
      st_prep_buffer();
      st_wake_up();
      do {
        protocol_exec_rt_system();
        if (sys.abort) { return; }
      } while (sys.step_control & STEP_CONTROL_EXECUTE_SYS_MOTION);
      st_parking_restore_buffer(); // Restore step segment buffer to normal run state.
    } else {
      bit_false(sys.step_control, STEP_CONTROL_EXECUTE_SYS_MOTION);
      protocol_exec_rt_system();
    }

  }
#endif


#ifdef ENABLE_PARKING_OVERRIDE_CONTROL
  void mc_override_ctrl_update(uint8_t override_state)
  {
    // Finish all queued commands before altering override control state
    protocol_buffer_synchronize();
    if (sys.abort) { return; }
    sys.override_ctrl = override_state;
  }
#endif


// Method to ready the system to reset by setting the realtime reset command and killing any
// active processes in the system. This also checks if a system reset is issued while Grbl
// is in a motion state. If so, kills the steppers and sets the system alarm to flag position
// lost, since there was an abrupt uncontrolled deceleration. Called at an interrupt level by
// realtime abort command and hard limits. So, keep to a minimum.
void mc_reset()
{
  // Only this function can set the system reset. Helps prevent multiple kill calls.
  if (bit_isfalse(sys_rt_exec_state, EXEC_RESET)) {
    system_set_exec_state_flag(EXEC_RESET);

    // Kill spindle and coolant.
    spindle_stop();
    coolant_stop();

    // Kill steppers only if in any motion state, i.e. cycle, actively holding, or homing.
    // NOTE: If steppers are kept enabled via the step idle delay setting, this also keeps
    // the steppers enabled by avoiding the go_idle call altogether, unless the motion state is
    // violated, by which, all bets are off.
    if ((sys.state & (STATE_CYCLE | STATE_HOMING | STATE_JOG)) ||
    		(sys.step_control & (STEP_CONTROL_EXECUTE_HOLD | STEP_CONTROL_EXECUTE_SYS_MOTION))) {
      if (sys.state == STATE_HOMING) { 
        if (!sys_rt_exec_alarm) {system_set_exec_alarm(EXEC_ALARM_HOMING_FAIL_RESET); }
      } else { system_set_exec_alarm(EXEC_ALARM_ABORT_CYCLE); }
      st_go_idle(); // Force kill steppers. Position has likely been lost.
    }
  }
}


#ifdef ENABLE_CUBIC_SPLINES

#if BEZIER_Z_LINEAR == 3
#ifdef BEZIER_Z_TRACE
  // For the test benches only. Estimates made; of them, sums of the segments; those left too
  // wide to vouch for Z; early ends of Z; pieces gone through and segments summed for all of
  // that; the bound of the Z error that follows from the brackets, mm; the half bracket of the
  // estimate that the inverse time feed was taken from, as a share of the length; and that of
  // the latest estimate.
  struct { uint16_t estimates, sums, open, ends, pieces, summed; float bound, time, half; } bezier_z_trace;
  #define Z_TRACE(what) bezier_z_trace.what
#else
  #define Z_TRACE(what)
#endif

// Z of the curve under way. Static, and the functions below not inlined: without
// BEZIER_PARSER_SCRATCH, mc_cubic_b_spline ends up inside gc_execute_line. That frame stays
// under the planner and costs flash when its locals move out of short displacement reach.
// The experimental separate driver trades parser locals for nested frames, not free stack.
typedef struct {
  float step;      // Of the curve parameter from one point of the polyline to the next
  float rest;      // Estimate of the length of the polyline from the point in hand to the end
  float u;         // Z left from there to the end; next to rest, as a point has X and Y
  float chord;     // Estimate under way: the chords of its pieces so far, summed,
  float poly;      // and their control polygons. Otherwise free, and a point as well:
                   // the one before, while segments are summed into rest itself.
  uint16_t next;   // Segments left when the length is estimated next; zero if never
  uint16_t todo;   // Estimate under way: segments not in its pieces yet; zero if none is
  uint8_t pieces;  // Pieces of the next estimate; zero before the first one
} spline_z_t;
static spline_z_t spline_z;

// Where the pieces of an estimate stop doubling: at the most of them, or one doubling on, which
// stands for the segments summed.
#ifdef BEZIER_Z_LOOSE
  #define Z_PIECES_END BEZIER_Z_PIECES_MAX
#else
  #define Z_PIECES_END (2*BEZIER_Z_PIECES_MAX)
#endif

// X and Y of the point of the curve at t into p, by Horner's rule relative to the start point.
// If s is not zero, p[2] and p[3] get the control point next to that point of the piece of the
// curve that begins there and is s long in t, or ends there if s is negative: the point plus s
// thirds of the derivative.
#ifdef BEZIER_POINT_CACHE
static void mc_spline_point(float *p, float t, float s, float *position, spline_scratch_t *scratch)
                            __attribute__((noinline, noclone));
static void mc_spline_point(float *p, float t, float s, float *position, spline_scratch_t *scratch)
#else
static void mc_spline_point(float *p, float t, float s, float **net)
                            __attribute__((noinline, noclone));
static void mc_spline_point(float *p, float t, float s, float **net)
#endif
{
#ifndef BEZIER_POINT_CACHE
  float *position = net[0], *first = net[1], *second = net[2], *target = net[3];
#endif
  uint8_t i;
  for (i = 0; i < 2; i++) {
#ifdef BEZIER_POINT_CACHE
    float e0 = scratch->e0[i], d = scratch->d[i];
    float g = scratch->g[i], w = t*d;
#else
    float e0 = second[i] - 2.0f*first[i] + position[i];
    float e1 = target[i] - 2.0f*second[i] + first[i];
    float g = first[i] - position[i], w = t*(e1 - e0);
#endif
#ifdef BEZIER_LOCAL_LENGTH
    p[i] = t*(3.0f*g + t*(3.0f*e0 + w));
#else
    p[i] = position[i] + t*(3.0f*g + t*(3.0f*e0 + w));
#endif
    if (s != 0.0f) { p[i+2] = p[i] + s*(g + t*(2.0f*e0 + w)); }
  }
}

#ifdef BEZIER_POINT_CACHE
  #define SPLINE_POINT(p,t,s) mc_spline_point(p,t,s,position,scratch)
#else
  #define SPLINE_POINT(p,t,s) mc_spline_point(p,t,s,net)
#endif

#ifdef BEZIER_LOCAL_LENGTH
  #define SPLINE_END(p) do { (p)[0] = target[0] - position[0]; (p)[1] = target[1] - position[1]; } while (0)
#else
  #define SPLINE_END(p) memcpy(p, target, 2*sizeof(float))
#endif

#ifdef BEZIER_Z_NORM
// Return the distance; fixed-pass callers keep only the sums they still need.
static float mc_spline_dist(float *a, float *b) __attribute__((noinline));
static float mc_spline_dist(float *a, float *b)
{
  return(hypot_f(a[X_AXIS] - b[X_AXIS], a[Y_AXIS] - b[Y_AXIS]));
}
#else
// The distance between two points in the XY plane, which is also added to a sum.
static float mc_spline_dist(float *sum, float *a, float *b) __attribute__((noinline));
static float mc_spline_dist(float *sum, float *a, float *b)
{
  float d = hypot_f(a[X_AXIS] - b[X_AXIS], a[Y_AXIS] - b[Y_AXIS]);
  *sum += d;
  return(d);
}
#endif

#ifdef BEZIER_Z_SELECT
// One decision before the coarse pass. Wang's integrated second-difference energy models
// the polygon/chord width; a global mean speed replaces the varying speed. This is not a bound.
static uint8_t mc_spline_select(spline_z_t *z, float **net, uint16_t segments)
                               __attribute__((noinline, noclone));
static uint8_t mc_spline_select(spline_z_t *z, float **net, uint16_t segments)
{
  float length = 0.0f, projection, h;
  uint8_t i, axis;
  mc_spline_dist(&length, net[3], net[0]);
  for (i = 0; i < 3; i++) {
    projection = 0.0f;
    for (axis = 0; axis < 2; axis++) {
      projection += (net[3][axis] - net[0][axis])*(net[i+1][axis] - net[i][axis]);
    }
    // Positive chord projections exclude cusps in exact geometry, not float staircases.
    if (!(projection >= 0.0f && projection < 3.402823466e38f) ||
        (i != 1 && projection == 0.0f)) { return(16); }
    mc_spline_dist(&length, net[i+1], net[i]);
  }
  // poly temporarily holds (a + b) + c from the driver's Wang loop.
  h = ((segments + 7)/8)*z->step;
  projection = h*h*z->poly*(fabsf(z->u) + 2.0f*BEZIER_Z_SIGMA);
  // length is twice Lstar, so this is 2*sigma*Lstar^2, without division.
  length *= length*(0.5f*BEZIER_Z_SIGMA);
  if (projection >= 0.0f && projection <= length && length < 3.402823466e38f) { return(8); }
  return(16);
}

#endif

// The next point p of the polyline, the j-th of segments: X and Y, and Z. The segment to it takes
// the share of the Z left that its chord is of the length left; a chord as long as that length
// takes it all, so Z never passes the target, nor turns back.
//
// If the length left is to be found first, p stays as it is and true is returned: that was one
// piece of an estimate, and the caller is to look after realtime work before the next call,
// with none of this on the stack. The length is that of the last z->next segments. A piece of
// the curve is a whole number of them; its ends are points of the polyline, and its two other
// control points follow from the slopes there. The chords of the pieces are no longer than the
// segments, their control polygons no shorter than the curve, so the two sums bracket the
// length; the estimate is halfway. Z is then off the straight line through the length travelled
// by no more than half the bracket over the whole length, times the Z travel. If that may be
// more than BEZIER_Z_SIGMA, the pieces are gone through again: as many more as close the bracket
// if it narrows four times whenever they double, as it does on a smooth curve. Where that
// takes more than BEZIER_Z_PIECES_MAX of them, or pieces of no more than BEZIER_Z_PIECE_COST
// segments, the segments themselves are summed instead, one a call from point to point: the
// length to be travelled, to rounding. The cost cutoff is approximate, see config.h.
//
// With BEZIER_Z_LOOSE no more than those pieces are ever gone through ahead: a bracket that the
// most of them leave too wide is used as it is, and the length is found again when half of the
// segments are left.
#ifdef BEZIER_POINT_CACHE
static uint8_t mc_spline_next(spline_z_t *z, float *target, uint16_t j, uint16_t segments,
                              float *position, spline_scratch_t *scratch, plan_line_data_t *pl_data)
                              __attribute__((noinline, noclone));
static uint8_t mc_spline_next(spline_z_t *z, float *target, uint16_t j, uint16_t segments,
                              float *position, spline_scratch_t *scratch, plan_line_data_t *pl_data)
{
  float *p = scratch->point;
  float q[4], r[4], a, b;
#elif defined(BEZIER_PARSER_SCRATCH)
static uint8_t mc_spline_next(spline_z_t *z, float *p, uint16_t j, uint16_t segments,
                              float **net, plan_line_data_t *pl_data)
                              __attribute__((noinline, noclone));
static uint8_t mc_spline_next(spline_z_t *z, float *p, uint16_t j, uint16_t segments,
                              float **net, plan_line_data_t *pl_data)
{
  float *position = net[0], *first = net[1], *second = net[2], *target = net[3];
  float q[4], r[4], a, b, *from;
#else
static uint8_t mc_spline_next(spline_z_t *z, float *p, uint16_t j, uint16_t segments,
                              float *position, float *first, float *second, float *target,
                              plan_line_data_t *pl_data) __attribute__((noinline, noclone));
static uint8_t mc_spline_next(spline_z_t *z, float *p, uint16_t j, uint16_t segments,
                              float *position, float *first, float *second, float *target,
                              plan_line_data_t *pl_data)
{
#ifdef BEZIER_Z_SELECT
  float q[4], a, b;
  float *net[4] = { position, first, second, target };
  float r[4], *from;
#else
  float q[4], r[4], a, b, *from;
  float *net[4] = { position, first, second, target };
#endif
#endif
  uint16_t m;
#ifdef BEZIER_Z_FIXED
  uint8_t axis;
  if (!z->next) {
#else
#ifdef BEZIER_Z_LOOSE
  if (segments + 1 - j != z->next) { // Not where the length is found again
#else
  if (!z->next) { // The length is found, or not asked for
#endif
#endif
    SPLINE_POINT(q, j*z->step, 0.0f);
    if (z->u != 0.0f) {
#ifdef BEZIER_Z_NORM
#ifdef BEZIER_LOCAL_LENGTH
      a = mc_spline_dist(q, &z->chord);
#else
      a = mc_spline_dist(q, p);
#endif
#else
      a = mc_spline_dist(&z->poly, q, p); // The chord of the segment. The sum is not in use.
#endif
      b = a/z->rest;
      if (b < 0.999999f) { z->rest -= a; z->u -= b*z->u; } else { z->u = 0.0f; Z_TRACE(ends++); }
      p[Z_AXIS] = target[Z_AXIS] - z->u;
    }
#ifdef BEZIER_LOCAL_LENGTH
    memcpy(&z->chord, q, 2*sizeof(float));
    q[0] += position[0];
    q[1] += position[1];
#endif
    memcpy(p, q, 2*sizeof(float));
    return(false);
  }
  if (!z->pieces) { // Before the first point. A hair less than all of Z: no point before the start.
    z->pieces = BEZIER_Z_PIECES;
    z->todo = 0;
    z->step = 1.0f/segments;
    z->u = (target[Z_AXIS] - position[Z_AXIS])*0.9999999f;
#ifdef BEZIER_Z_FIXED
    z->pieces = 2; // One fixed coarse pass; 1 requests actual segment lengths.
#ifdef BEZIER_Z_SELECT
    z->pieces = 16;
#ifdef BEZIER_EXACT_INVERSE_TIME
    if (!(pl_data->condition & PL_COND_FLAG_INVERSE_TIME))
#endif
    if (z->u != 0.0f && (segments + 7)/8 > BEZIER_Z_PIECE_COST) {
      z->pieces = 4; // Selection is due after the initial realtime service.
    }
#endif
    z->rest = 1e-30f;
#ifdef BEZIER_Z_SELECT
    // Preserve the driver's energy in poly until selection; chord/poly then hold XY.
    if (z->pieces != 4)
#endif
#ifdef BEZIER_LOCAL_LENGTH
    z->chord = z->poly = 0.0f;
#else
    memcpy(&z->chord, p, 2*sizeof(float));
#endif
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
    if (!(pl_data->condition & PL_COND_FLAG_INVERSE_TIME))
#endif
    if (z->u == 0.0f) {
      z->next = 0; // No Z word, no estimate
#ifdef BEZIER_POINT_CACHE
      p[Z_AXIS] = position[Z_AXIS];
#endif
    }
    return(true); // Realtime work first: the line has taken its time to parse.
  }
#ifdef BEZIER_Z_FIXED
#ifdef BEZIER_Z_SELECT
  if (z->pieces == 4) {
    z->pieces = mc_spline_select(z, net, segments);
    memcpy(&z->chord, p, 2*sizeof(float));
    return(true); // No trial pieces or feed change; realtime before the selected pass.
  }
#endif
  // One coarse pass, with smaller pieces only at a reversal. There is no bracket gate
  // escalation or mid-curve re-estimation. This is an accuracy/latency tradeoff, not a bound.
#ifdef BEZIER_Z_SELECT
  m = (z->pieces == 8) ? (segments + 7)/8 : (segments + 15)/16;
  m = min(m, z->next);
#else
#ifdef BEZIER_Z_CHORDS
#ifdef TB_Z_FIXED_24
  m = (segments + 23)/24; // Bounded intermediate-density experiment.
#else
  m = (segments + 15)/16;
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
  if (!(pl_data->condition & PL_COND_FLAG_INVERSE_TIME))
#endif
  { m = max(m, 5); } // Four norms per piece, rather than five or more individual chords.
  m = min(m, z->next);
#else
  m = min((segments + 15)/16, z->next);
#endif
#endif
  if (z->todo) { m = z->todo; }
  if (z->pieces == 1 || m <= BEZIER_Z_PIECE_COST) { m = 1; }
  a = (segments - z->next)*z->step;
  b = (segments - z->next + m)*z->step;
#ifdef BEZIER_Z_SELECT
  if (m == 1) { a = b; } else { SPLINE_POINT(q, a, b - a); }
  SPLINE_POINT(r, b, a - b);
  if (z->next == m) { SPLINE_END(r); }
#endif
  if (m == 1) {
#ifndef BEZIER_Z_SELECT
    SPLINE_POINT(r, b, 0.0f);
    if (z->next == 1) { SPLINE_END(r); }
#endif
#ifdef BEZIER_Z_NORM
    z->rest += mc_spline_dist(r, &z->chord);
#else
    mc_spline_dist(&z->rest, r, &z->chord);
#endif
    Z_TRACE(summed++);
  } else {
#ifndef BEZIER_Z_SELECT
    SPLINE_POINT(q, a, b - a);
    SPLINE_POINT(r, b, a - b);
    if (z->next == m) { SPLINE_END(r); }
#endif
    // The three control-polygon edge directions. Reject a piece that turns back.
    a = b = 0.0f;
    for (axis = 0; axis < 2; axis++) {
      float e0 = q[axis + 2] - q[axis];
      float e1 = r[axis + 2] - q[axis + 2];
      float e2 = r[axis] - r[axis + 2];
      a += e0*e2;
      b += e1*(e0 + e2);
    }
    if (a < 0.0f || b < 0.0f) { z->todo = m/2; return(true); }
    a = b = 0.0f;
#ifdef BEZIER_Z_NORM
    a += mc_spline_dist(r, q);
    b += mc_spline_dist(q + 2, q);
    b += mc_spline_dist(r + 2, q + 2);
    b += mc_spline_dist(r, r + 2);
#else
    mc_spline_dist(&a, r, q);
    mc_spline_dist(&b, q + 2, q);
    mc_spline_dist(&b, r + 2, q + 2);
    mc_spline_dist(&b, r, r + 2);
#endif
#ifdef BEZIER_Z_CHORDS
#ifdef BEZIER_EXACT_INVERSE_TIME
    if (!(pl_data->condition & PL_COND_FLAG_INVERSE_TIME))
#endif
    { b -= (b - a)/(uint32_t)(m*(uint32_t)m); } // Finite chords, not the smooth arc midpoint.
#endif
    z->rest += 0.5f*(a + b);
    Z_TRACE(pieces++);
  }
  memcpy(&z->chord, r, 2*sizeof(float));
  z->next -= m;
  z->todo = 0;
  if (z->next) { return(true); }
  Z_TRACE(estimates++);
  Z_TRACE(half = 0.0f);
#ifndef BEZIER_LOCAL_LENGTH
#ifdef BEZIER_Z_SELECT
  if (z->pieces != 1) {
#else
  if (z->pieces == 2) {
#endif
#ifdef BEZIER_POINT_CACHE
    a = p[Z_AXIS]; // Original coordinate maximum, saved before the controls were overwritten.
#else
    a = 0.0f;
    for (axis = 0; axis < 2; axis++) {
      a = max(a, max(fabsf(position[axis]), fabsf(target[axis])));
      a = max(a, max(fabsf(first[axis]), fabsf(second[axis])));
    }
#endif
    // Smooth geometry cannot certify the rounded XY staircase. This risk heuristic
    // requests actual chord sums on sensitive coordinates; it is not a certificate.
    if (a*fabsf(z->u)*0.000001f > BEZIER_Z_SIGMA*z->rest) {
      z->pieces = 1;
      z->next = segments;
      z->rest = 1e-30f;
      memcpy(&z->chord, position, 2*sizeof(float));
      return(true);
    }
  }
#endif // !BEZIER_LOCAL_LENGTH
#ifdef BEZIER_POINT_CACHE
  p[Z_AXIS] = position[Z_AXIS]; // Restore the un-emitted point, including the no-Z G93 case.
#endif
#else
  m = (z->next + z->pieces - 1)/z->pieces; // Segments to a piece
  if (m <= BEZIER_Z_PIECE_COST || z->pieces > BEZIER_Z_PIECES_MAX) { m = 1; } // The segments
  from = &z->chord; // The point before, if segments are summed
  if (!z->todo) { // From the point in hand. The sums not zero: divisors.
    z->todo = z->next;
    z->rest = z->chord = z->poly = 1e-30f;
    from = p;
  }
  a = (segments - z->todo)*z->step; // The piece is from a to b, by the same products as the
  z->todo -= min(m, z->todo);       // points of the polyline are at.
  b = (segments - z->todo)*z->step;
  if (m == 1) { a = b; } else { SPLINE_POINT(q, a, b - a); } // Its first two control points
  SPLINE_POINT(r, b, a - b); // and its last two, last first; no slope for a segment.
  // The last point of the polyline is target itself, which Horner's rule misses by a bit.
  if (!z->todo) { SPLINE_END(r); }
  if (m == 1) { // The segment itself, from the point before, which is in no use as sums.
    mc_spline_dist(&z->rest, r, from);
    memcpy(&z->chord, r, 2*sizeof(float));
    Z_TRACE(summed++);
    if (z->todo) { return(true); }
    Z_TRACE(estimates++);
    Z_TRACE(sums++);
    Z_TRACE(half = 0.0f);
    z->next = 0;
  } else {
    mc_spline_dist(&z->chord, r, q);
    mc_spline_dist(&z->poly, q + 2, q);
    mc_spline_dist(&z->poly, r + 2, q + 2);
    mc_spline_dist(&z->poly, r, r + 2);
    Z_TRACE(pieces++);
    if (z->todo) { return(true); }
    Z_TRACE(estimates++);
    a = 0.5f*(z->poly - z->chord); // Half of the bracket
    z->rest = z->chord + a;
    Z_TRACE(half = a/z->chord);
    b = BEZIER_Z_SIGMA*z->chord;
    if (a*(fabsf(z->u) + BEZIER_Z_SIGMA) > b) { // Too wide to vouch for Z
#ifdef BEZIER_Z_LOOSE
      if (z->pieces == BEZIER_Z_PIECES_MAX) {
        z->next >>= 1;
        Z_TRACE(open++);
      } else
#endif
      {
        do { z->pieces <<= 1; b *= 4.0f; }
        while (z->pieces < Z_PIECES_END && a*(fabsf(z->u) + BEZIER_Z_SIGMA) > b);
        return(true);
      }
    } else {
      z->next = 0;
    }
    Z_TRACE(bound = max(bezier_z_trace.bound, a*(fabsf(z->u) + bezier_z_trace.bound)/z->chord));
  }
#ifdef BEZIER_Z_LOOSE
  z->pieces = BEZIER_Z_PIECES; // For the next estimate
#endif
#endif // BEZIER_Z_FIXED
#ifdef BEZIER_EXACT_INVERSE_TIME
  // Inverse time: the feed that covers the estimated length, Z included, in 1/F minutes. That
  // is how far the point (rest, u) is from the origin, which the sums are cleared to be.
  if (pl_data->condition & PL_COND_FLAG_INVERSE_TIME) {
    Z_TRACE(time = bezier_z_trace.half);
    z->chord = z->poly = 0.0f;
#ifdef BEZIER_Z_NORM
    pl_data->feed_rate *= mc_spline_dist(&z->rest, &z->chord);
#else
    pl_data->feed_rate *= mc_spline_dist(&z->chord, &z->rest, &z->chord);
#endif
    bit_false(pl_data->condition,PL_COND_FLAG_INVERSE_TIME);
  }
#endif
#ifdef BEZIER_LOCAL_LENGTH
  z->chord = z->poly = 0.0f; // Previous local point for emission, after the initial estimate.
#endif
  return(true);
}
#endif

#ifdef BEZIER_POINT_CACHE
// Finish coefficient preparation before the estimator, planner or realtime can extend the stack.
static void mc_spline_cache_init(float *target, float *position, spline_scratch_t *scratch)
  __attribute__((noinline, noclone));
static void mc_spline_cache_init(float *target, float *position, spline_scratch_t *scratch)
{
  float *first = scratch->first, *second = scratch->second, *p = scratch->point;
  uint8_t i;
  p[Z_AXIS] = 0.0f; // Free until emission: retain the original coordinate-risk input.
  // Keep coefficient formation separate from Wang's squared second differences: fast-math
  // must not reuse an already rounded e1 when forming the point evaluator's e1 - e0.
  for (i = 0; i < 2; i++) {
    float e0 = second[i] - 2.0f*first[i] + position[i];
    float e1 = target[i] - 2.0f*second[i] + first[i];
    float g = first[i] - position[i], d = e1 - e0;
#ifndef BEZIER_LOCAL_LENGTH
    // Only absolute-length mode consumes this risk input, before controls are replaced.
    p[Z_AXIS] = max(p[Z_AXIS], max(fabsf(position[i]), fabsf(target[i])));
    p[Z_AXIS] = max(p[Z_AXIS], max(fabsf(first[i]), fabsf(second[i])));
#endif
    scratch->g[i] = g;
    scratch->e0[i] = e0;
    scratch->d[i] = d;
  }
}
#endif

// Execute a cubic Bezier curve from position to target with control points first and second.
// Only X and Y follow the curve; the other axes stay at position, as the parser allows no others.
// The curve is cut into a number of segments of equal step in the curve parameter t, chosen in
// advance from Wang's bound: the chord of a step h deviates from the curve by at most
// h^2/8 * max|B''|, and B'' is linear in t, so max|B''| = 6 * max(|P0-2P1+P2|, |P1-2P2+P3|).
// This holds both ways (curve to segments and segments to curve) for any shape: inflections,
// cusps and coincident control points need no special case. Points are evaluated by Horner's
// rule relative to the start point; the last one is target itself, bit for bit.
#ifdef BEZIER_PARSER_SCRATCH
// Keep the spline's temporaries out of the parser's short-displacement frame.
void mc_cubic_b_spline(float *target, plan_line_data_t *pl_data, float *position,
#ifdef BEZIER_PARSER_WORKSPACE
                       spline_scratch_t *scratch) __attribute__((noinline, noclone));
#else
                       float *first, float *second) __attribute__((noinline, noclone));
#endif
#endif
void mc_cubic_b_spline(float *target, plan_line_data_t *pl_data, float *position,
#ifdef BEZIER_PARSER_WORKSPACE
                       spline_scratch_t *scratch)
#else
                       float *first, float *second)
#endif
{
#ifdef BEZIER_PARSER_WORKSPACE
  float *first = scratch->first, *second = scratch->second, *p = scratch->point;
#else
  float p[N_AXIS];
#endif
  float a = 0.0f, b = 0.0f;
  uint8_t i;
  memcpy(p, position, N_AXIS*sizeof(float));
#ifdef BEZIER_Z_SELECT
  spline_z.poly = 0.0f;
#endif
  for (i = 0; i < 2; i++) {
    float e0 = second[i] - 2.0f*first[i] + position[i];
    float e1 = target[i] - 2.0f*second[i] + first[i];
    a += e0*e0;
    b += e1*e1;
#ifdef BEZIER_Z_SELECT
    spline_z.poly += e0*e1;
#endif
  }
#ifdef BEZIER_Z_SELECT
  spline_z.poly += a + b; // Integrated second-difference energy for the initial selector.
#endif

  // Segments for a deviation of BEZIER_SIGMA at most: sqrt(0.75*max|P[k]-2P[k+1]+P[k+2]|/SIGMA),
  // with 0.8 for 0.75 to leave 6% of SIGMA to float rounding (a parabola meets the bound exactly).
  // Huge handles, inf and NaN fail the comparison and get the cap, never an undefined count.
  float n = sqrtf(sqrtf(max(a, b))*(0.8f/BEZIER_SIGMA));
  uint16_t segments = BEZIER_MAX_SEGMENTS;
  if (n < BEZIER_MAX_SEGMENTS) { segments = 1 + n; }
#ifdef BEZIER_POINT_CACHE
  mc_spline_cache_init(target, position, scratch);
#endif
#if BEZIER_Z_LINEAR != 3
  float step = 1.0f/segments;
#endif

  uint16_t j;
#if BEZIER_Z_LINEAR == 2
  // Two passes over the same points: the first sums the chords up to the target, the second
  // queues the points with Z at the share of that length travelled so far. The sum starts just
  // above zero, so a curve whose points all coincide divides by that instead of by zero.
  float q[2], s, length = 0.0f, dz = target[Z_AXIS] - position[Z_AXIS];
  uint8_t pass;
  segments++;
  for (pass = 0; pass < 2; pass++) {
  s = 1e-30f;
  memcpy(q, position, sizeof(q));
#elif BEZIER_Z_LINEAR == 3
  // One pass: Z takes its way from an estimate of the length ahead, see mc_spline_next. The
  // first one is due at once, and finds out whether there is a Z word at all.
  spline_z.next = segments;
  spline_z.pieces = 0;
#ifndef BEZIER_POINT_CACHE
#ifdef BEZIER_PARSER_WORKSPACE
  float **net = scratch->net;
  net[0] = position; net[1] = first; net[2] = second; net[3] = target;
#elif defined(BEZIER_PARSER_SCRATCH)
  float *net[4] = { position, first, second, target };
#endif
#endif
#endif
  for (j = 1; j < segments; j++) {
#if BEZIER_Z_LINEAR == 3
#ifdef BEZIER_POINT_CACHE
    while (mc_spline_next(&spline_z, target, j, segments, position, scratch, pl_data)) {
#elif defined(BEZIER_PARSER_SCRATCH)
    while (mc_spline_next(&spline_z, p, j, segments, net, pl_data)) {
#else
    while (mc_spline_next(&spline_z, p, j, segments, position, first, second, target, pl_data)) {
#endif
      // A piece of an estimate queues no block, so mc_line is not there to keep the stepper fed.
      protocol_execute_realtime();
      if (sys.abort) { return; }
    }
#else
    float t = j*step;
    for (i = 0; i < 2; i++) {
      float e0 = second[i] - 2.0f*first[i] + position[i];
      float e1 = target[i] - 2.0f*second[i] + first[i];
      p[i] = position[i] + t*(3.0f*(first[i] - position[i]) + t*(3.0f*e0 + t*(e1 - e0)));
    }
#endif
#if BEZIER_Z_LINEAR == 1
    p[Z_AXIS] = position[Z_AXIS] + t*(target[Z_AXIS] - position[Z_AXIS]);
#elif BEZIER_Z_LINEAR == 2
    // The last point of the polyline is target itself, which Horner's rule misses by a bit.
    if (!pass && j == segments - 1) { memcpy(p, target, sizeof(q)); }
    s += hypot_f(p[X_AXIS] - q[X_AXIS], p[Y_AXIS] - q[Y_AXIS]);
    memcpy(q, p, sizeof(q));
    if (!pass) {
      // Nothing is queued in this pass, so mc_line is not there to keep the stepper fed.
      protocol_execute_realtime();
      if (sys.abort) { return; }
      continue;
    }
    p[Z_AXIS] = position[Z_AXIS] + s/length*dz;
#endif
    mc_line(p, pl_data);
    if (sys.abort) { return; } // Bail mid-spline if system abort requested.
#if BEZIER_Z_LINEAR == 3 && defined(BEZIER_Z_REFILL)
    // Refill after queuing this target, before computing the next one.
    protocol_execute_realtime();
    if (sys.abort) { return; }
#endif
  }
#if BEZIER_Z_LINEAR == 2
#ifdef BEZIER_EXACT_INVERSE_TIME
  // Inverse time: the feed that covers the whole polyline, Z included, in 1/F minutes. Every
  // segment then takes its share of the length, not an equal share of the time.
  if (pl_data->condition & PL_COND_FLAG_INVERSE_TIME) {
    pl_data->feed_rate *= hypot_f(s, dz);
    bit_false(pl_data->condition,PL_COND_FLAG_INVERSE_TIME);
  }
#endif
  // A hair over the sum, so no point before the last gets all of dz: position + dz can be a
  // bit past the target, and the last segment would then take Z back.
  length = s*1.0000002f;
  segments--;
  }
#endif
  p[X_AXIS] = target[X_AXIS];
  p[Y_AXIS] = target[Y_AXIS];
#ifdef BEZIER_Z_LINEAR
  p[Z_AXIS] = target[Z_AXIS];
#endif
  mc_line(p, pl_data);
}

#endif // ENABLE_CUBIC_SPLINES
