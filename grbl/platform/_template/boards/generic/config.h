/*
  config.h - Generic _template board configuration (copy-me starting point)
  Part of Grbl

  Placeholder pin map so the template compiles standalone. Every *_PORT
  value below is just an index into the PORT_TODO_GPIO_* arrays in
  ../../gpio.h - it has no hardware meaning until gpio.h's accessors are
  replaced with real registers. Copy this directory (boards/generic ->
  boards/yourboard) and replace every value with your real wiring; the
  *_BIT numbers only need to stay distinct within their own group and
  (for LIMIT/CONTROL/PROBE) inside bits 0-7 (CONTRACTS.md §1.3 - core
  truncates input-group reads to uint8_t; SAMD21's megarm board got this
  wrong for CONTROL, see CONTRACTS.md §13).

  PORT_TODO_GPIO_* is unset-length (extern volatile uint32_t foo[];), so
  nothing here needs to know how many logical "ports" exist - just keep
  distinct groups on distinct indices so one group's mask writes never
  disturb another's bits when GPIO_MWO does a real read-modify-write.
*/

#ifndef BOARD_GENERIC_TEMPLATE_CONFIG_H
#define BOARD_GENERIC_TEMPLATE_CONFIG_H

#warning "PORT-TODO: boards/generic/config.h"

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "Generic _template board"
#define BOARD_MCU  "PORT-TODO: your chip part number"
#define BOARD_URL  ""

// ============================================================================
// LOGICAL PORT INDICES (into PORT_TODO_GPIO_* arrays - see ../../gpio.h)
// ============================================================================

#define TEMPLATE_PORT_OUTPUTS   0   // STEP / DIRECTION / STEPPERS_DISABLE
#define TEMPLATE_PORT_INPUTS    1   // LIMIT / CONTROL / PROBE
#define TEMPLATE_PORT_AUX       2   // SPINDLE_* / COOLANT_*

// ============================================================================
// STEP / DIRECTION / STEPPERS_DISABLE (outputs)
// ============================================================================

#define X_STEP_PORT         TEMPLATE_PORT_OUTPUTS
#define X_STEP_PIN           0
#define X_STEP_BIT           0
#define Y_STEP_PORT         TEMPLATE_PORT_OUTPUTS
#define Y_STEP_PIN           1
#define Y_STEP_BIT           1
#define Z_STEP_PORT         TEMPLATE_PORT_OUTPUTS
#define Z_STEP_PIN           2
#define Z_STEP_BIT           2

#define STEP_PORT           TEMPLATE_PORT_OUTPUTS
#define STEP_MASK            ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))

#define X_DIRECTION_PORT    TEMPLATE_PORT_OUTPUTS
#define X_DIRECTION_PIN      3
#define X_DIRECTION_BIT      3
#define Y_DIRECTION_PORT    TEMPLATE_PORT_OUTPUTS
#define Y_DIRECTION_PIN      4
#define Y_DIRECTION_BIT      4
#define Z_DIRECTION_PORT    TEMPLATE_PORT_OUTPUTS
#define Z_DIRECTION_PIN      5
#define Z_DIRECTION_BIT      5

#define DIRECTION_PORT       TEMPLATE_PORT_OUTPUTS
#define DIRECTION_MASK       ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))

// PLAN.md Phase 2 static-assert sweep (2026-07-26): core packs
// step_outbits/dir_outbits/axislock into a uint8_t (BUG #17, CONTRACTS.md
// #1) - every *_STEP_BIT/*_DIRECTION_BIT must fit that byte. A new port
// copying this template gets the check for free; if your board's physical
// pins don't already sit at bits 0..7, follow the samd21/gpio.h
// logical-vs-physical dispatch pattern (STEP_L2P/STEP_P2L) instead of
// widening this assert.
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image (BUG #17 class, CONTRACTS.md #1)");

#define STEPPERS_DISABLE_PORT   TEMPLATE_PORT_OUTPUTS
#define STEPPERS_DISABLE_PIN     6
#define STEPPERS_DISABLE_BIT     6
#define STEPPERS_DISABLE_MASK    (1UL<<STEPPERS_DISABLE_BIT)

// ============================================================================
// LIMIT / CONTROL / PROBE (inputs - MUST stay within bits 0-7, CONTRACTS.md §1.3)
// ============================================================================

#define X_LIMIT_PORT        TEMPLATE_PORT_INPUTS
#define X_LIMIT_PIN          0
#define X_LIMIT_BIT          0
#define Y_LIMIT_PORT        TEMPLATE_PORT_INPUTS
#define Y_LIMIT_PIN          1
#define Y_LIMIT_BIT          1
#define Z_LIMIT_PORT        TEMPLATE_PORT_INPUTS
#define Z_LIMIT_PIN          2
#define Z_LIMIT_BIT          2

#define LIMIT_PORT           TEMPLATE_PORT_INPUTS
#define LIMIT_MASK           ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

#define CONTROL_RESET_PORT       TEMPLATE_PORT_INPUTS
#define CONTROL_RESET_PIN         3
#define CONTROL_RESET_BIT         3
#define CONTROL_FEED_HOLD_PORT   TEMPLATE_PORT_INPUTS
#define CONTROL_FEED_HOLD_PIN     4
#define CONTROL_FEED_HOLD_BIT     4
#define CONTROL_CYCLE_START_PORT TEMPLATE_PORT_INPUTS
#define CONTROL_CYCLE_START_PIN   5
#define CONTROL_CYCLE_START_BIT   5
// Safety door shares the feed-hold pin (no dedicated input on this generic
// board) - same convention as samd21/generic/config.h. Give it a real pin
// on a board that has one.
#define CONTROL_SAFETY_DOOR_PORT TEMPLATE_PORT_INPUTS
#define CONTROL_SAFETY_DOOR_PIN   4
#define CONTROL_SAFETY_DOOR_BIT   4

#define CONTROL_PORT         TEMPLATE_PORT_INPUTS
#define CONTROL_MASK         ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK  CONTROL_MASK

#define PROBE_PORT           TEMPLATE_PORT_INPUTS
#define PROBE_PIN             6
#define PROBE_BIT             6
#define PROBE_MASK            (1UL<<PROBE_BIT)

// ============================================================================
// SPINDLE (VARIABLE_SPINDLE PWM must be <= uint8_t range - CONTRACTS.md §6.2)
// ============================================================================

#define SPINDLE_PWM_PORT        TEMPLATE_PORT_AUX
#define SPINDLE_PWM_PIN          0
#define SPINDLE_PWM_BIT          0

#define SPINDLE_DIRECTION_PORT  TEMPLATE_PORT_AUX
#define SPINDLE_DIRECTION_PIN    1
#define SPINDLE_DIRECTION_BIT    1

#define SPINDLE_ENABLE_PORT     TEMPLATE_PORT_AUX
#define SPINDLE_ENABLE_PIN       2
#define SPINDLE_ENABLE_BIT       2

#define SPINDLE_PWM_MAX_VALUE   255   // core plumbs duty as uint8_t end-to-end - keep <= 255
#define SPINDLE_PWM_MIN_VALUE   1     // must be > 0 to avoid floating at "off"
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// PLAN.md Phase 2 static-assert sweep (2026-07-26): codify the CONTRACTS.md
// #6.2 duty-domain contract in code, so a new port copying this template
// gets the check for free - the STM32 "duty-cap-twins" bug
// (SPINDLE_PWM_MAX_VALUE=1000 against a uint8_t core duty) showed a comment
// alone does not stop the regression.
_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2, duty-cap-twins class)");

// ============================================================================
// COOLANT
// ============================================================================

#define COOLANT_FLOOD_PORT      TEMPLATE_PORT_AUX
#define COOLANT_FLOOD_PIN        3
#define COOLANT_FLOOD_BIT        3

// PORT-TODO NOTE (do not re-add `#ifdef ENABLE_M7` around this): this file
// arrives via the build prelude (-include boards/$(BOARD)/prelude.h),
// processed before grbl.h's own #include "config.h" ever defines
// ENABLE_M7 - a guard here can never observe it, silently dropping these
// pins even when a user of a port copied from this template enables the
// feature (CONTRACTS.md #19 "guard that certifies instead of checking",
// wrong-phase variant - every landed port hit this and had it removed
// here, see grbl/CONTRACTS.md gap log). Defining the pins unconditionally
// costs nothing; core's own (correctly-timed) `#ifdef ENABLE_M7` in
// coolant_control.c is the only place that ever reads them.
#define COOLANT_MIST_PORT     TEMPLATE_PORT_AUX
#define COOLANT_MIST_PIN       4
#define COOLANT_MIST_BIT       4

#endif // BOARD_GENERIC_TEMPLATE_CONFIG_H
