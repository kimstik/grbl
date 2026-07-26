/*
  config.h - Generic SAMD21 Board Configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  Board: Generic SAMD21G18A
  MCU: SAMD21G18A
  Description: Generic configuration for SAMD21 development boards

  This is a template configuration. Copy this file to create
  a custom board configuration in a new boards/ subdirectory.
*/

#ifndef BOARD_GENERIC_CONFIG_H
#define BOARD_GENERIC_CONFIG_H

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "Generic SAMD21"
#define BOARD_MCU  "SAMD21G18A"
#define BOARD_URL  ""

// ============================================================================
// STEP PINS
// ============================================================================
// LOGICAL PORT-IMAGE CONTRACT (BUG #17, PLAN.md Phase 3 / CONTRACTS.md #1):
// see samd21/megarm/config.h for the full rationale. X/Y/Z_STEP_BIT are
// LOGICAL (core's native uint8_t port image, stepper.c get_step_pin_mask());
// the real silicon pin is X/Y/Z_STEP_PIN. This board's physical pins happen
// to be contiguous, so gpio.h's translation collapses to a pure shift
// (STEP_L2P/STEP_P2L below) instead of megarm's 3-term gather/scatter.

#define X_STEP_PORT         PORT_GROUPA
#define X_STEP_PIN          16   // real silicon pin
#define X_STEP_BIT          0    // LOGICAL

#define Y_STEP_PORT         PORT_GROUPA
#define Y_STEP_PIN          17
#define Y_STEP_BIT          1

#define Z_STEP_PORT         PORT_GROUPA
#define Z_STEP_PIN          18
#define Z_STEP_BIT          2

// Physical register mask - consumed only by gpio.h's GPIO_MWO_STEP/
// GPIO_MDIR_OUT_STEP/GPIO_MRD_STEP; core never sees it.
#define STEP_MASK_PHYS      ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))

// Logical <-> physical: pins are contiguous (16,17,18 for bits 0,1,2), so
// this is a pure shift by the X pin's offset - no gather/scatter needed.
#define STEP_L2P(v)         ((uint32_t)(v) << X_STEP_PIN)
#define STEP_P2L(v)         ((uint32_t)(v) >> X_STEP_PIN)

// Combined step mask (all on PORT A) - LOGICAL, this is the core-visible
// STEP_MASK aliased below (limits.c:342, stepper.c:499,561)
#define STEP_MASK_A         ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))
#define STEP_MASK_B         0

// ============================================================================
// DIRECTION PINS
// ============================================================================
// Same contract, same contiguous-shift shape as STEP above.

#define X_DIRECTION_PORT    PORT_GROUPA
#define X_DIRECTION_PIN     19   // real silicon pin
#define X_DIRECTION_BIT     0    // LOGICAL

#define Y_DIRECTION_PORT    PORT_GROUPA
#define Y_DIRECTION_PIN     20
#define Y_DIRECTION_BIT     1

#define Z_DIRECTION_PORT    PORT_GROUPA
#define Z_DIRECTION_PIN     21
#define Z_DIRECTION_BIT     2

#define DIRECTION_MASK_PHYS ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))
#define DIRECTION_L2P(v)    ((uint32_t)(v) << X_DIRECTION_PIN)
#define DIRECTION_P2L(v)    ((uint32_t)(v) >> X_DIRECTION_PIN)

// Combined direction mask (all on PORT A) - LOGICAL
#define DIRECTION_MASK_A    ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))
#define DIRECTION_MASK_B    0

// PLAN.md Phase 2 static-assert sweep (2026-07-26): same BUG #17 invariant
// as megarm/config.h - kept even though this board's translation is a pure
// shift (no gather/scatter) since a future re-pinning could still pick
// bits >7.
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image (BUG #17 class, CONTRACTS.md #1)");

// ============================================================================
// STEPPER ENABLE PIN
// ============================================================================

#define STEPPERS_DISABLE_PORT   PORT_GROUPA
#define STEPPERS_DISABLE_PIN    22
#define STEPPERS_DISABLE_BIT    22

#define STEPPERS_DISABLE_MASK_A (1UL<<STEPPERS_DISABLE_PIN)
#define STEPPERS_DISABLE_MASK_B 0

// ============================================================================
// LIMIT SWITCH PINS
// ============================================================================

#define X_LIMIT_PORT        PORT_GROUPA
#define X_LIMIT_PIN         4
#define X_LIMIT_BIT         4

#define Y_LIMIT_PORT        PORT_GROUPA
#define Y_LIMIT_PIN         5
#define Y_LIMIT_BIT         5

#define Z_LIMIT_PORT        PORT_GROUPA
#define Z_LIMIT_PIN         6
#define Z_LIMIT_BIT         6

#define LIMIT_MASK_A        ((1UL<<X_LIMIT_PIN)|(1UL<<Y_LIMIT_PIN)|(1UL<<Z_LIMIT_PIN))
#define LIMIT_MASK_B        0

// ============================================================================
// CONTROL PINS
// ============================================================================

#define CONTROL_RESET_PORT      PORT_GROUPA
#define CONTROL_RESET_PIN       7
#define CONTROL_RESET_BIT       7

#define CONTROL_FEED_HOLD_PORT  PORT_GROUPA
#define CONTROL_FEED_HOLD_PIN   8
#define CONTROL_FEED_HOLD_BIT   8

#define CONTROL_CYCLE_START_PORT   PORT_GROUPA
#define CONTROL_CYCLE_START_PIN    9
#define CONTROL_CYCLE_START_BIT    9

#define CONTROL_SAFETY_DOOR_PORT   PORT_GROUPA
#define CONTROL_SAFETY_DOOR_PIN    8
#define CONTROL_SAFETY_DOOR_BIT    8

#define CONTROL_MASK_A      ((1UL<<CONTROL_RESET_PIN)|(1UL<<CONTROL_FEED_HOLD_PIN)|(1UL<<CONTROL_CYCLE_START_PIN))
#define CONTROL_MASK_B      0

#define CONTROL_INVERT_MASK CONTROL_MASK_A

// ============================================================================
// PROBE PIN
// ============================================================================

#define PROBE_PORT          PORT_GROUPA
#define PROBE_PIN           10
#define PROBE_BIT           10

#define PROBE_MASK_A        (1UL<<PROBE_PIN)
#define PROBE_MASK_B        0

// ============================================================================
// SPINDLE CONTROL PINS
// ============================================================================

#define SPINDLE_PWM_PORT       PORT_GROUPA
#define SPINDLE_PWM_PIN        14   // TCC0/WO[0]
#define SPINDLE_PWM_BIT        14
#define SPINDLE_PWM_CHANNEL    0

#define SPINDLE_DIRECTION_PORT PORT_GROUPA
#define SPINDLE_DIRECTION_PIN  15
#define SPINDLE_DIRECTION_BIT  15

#define SPINDLE_ENABLE_PORT    PORT_GROUPA
#define SPINDLE_ENABLE_PIN     23
#define SPINDLE_ENABLE_BIT     23

// PWM duty domain: core plumbs duty as uint8_t end-to-end
// (spindle_control.c:122, CONTRACTS.md #6.2) - full scale MUST fit uint8_t.
// TCC0 runs with PER = 0xFF (samd21/timer.h:109); CC[0] must never exceed
// that or the compare saturates. Full scale is therefore 255, matching PER
// exactly - correct by construction, not by truncation.
#define SPINDLE_PWM_MAX_VALUE  255
#define SPINDLE_PWM_MIN_VALUE  1      // Must be > 0 to avoid floating
#define SPINDLE_PWM_OFF_VALUE  0
#define SPINDLE_PWM_RANGE      (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// PLAN.md Phase 2 static-assert sweep (2026-07-26) closure (2026-07-26):
// same fix/reasoning as megarm/config.h - this board shared the identical
// tracked violation (65535 vs PER=0xFF vs uint8_t core duty). BUG #22
// (reclassified 2026-07-26): the uint8_t assignment site truncated
// harmlessly, but spindle_control.c:45's pwm_gradient computation is a
// FLOAT expression that did NOT truncate - pwm_gradient was ~258x too
// large, producing wrapped-mod-256 garbage spindle duty for real commanded
// RPMs (see megarm/config.h and PLAN.md/CONTRACTS.md #6.2 for the
// objdump-verified reproduction). Fixed to the single canon (255); the
// duty-cap-twins class is now closed on every port, no exceptions.
_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2, duty-cap-twins class)");

// ============================================================================
// COOLANT CONTROL PINS
// ============================================================================

#define COOLANT_FLOOD_PORT     PORT_GROUPA
#define COOLANT_FLOOD_PIN      24
#define COOLANT_FLOOD_BIT      24

// NOT gated on `#ifdef ENABLE_M7`: this file arrives via the build prelude
// (-include $(BOARD)/prelude.h), processed before grbl.h's own #include
// "config.h" ever defines ENABLE_M7 - a guard here can never observe it,
// silently dropping these pins even when the user enables the feature
// (CONTRACTS.md #19 "guard that certifies instead of checking", wrong-
// phase variant - see grbl/CONTRACTS.md gap log). Worse than a compile
// error on this port: common/dummy/cpu_map.h's `#ifndef COOLANT_MIST_PORT`
// fallback silently supplies PORT_GROUPA/bit 0 (Group[0].OUT bit 0) once
// core's own ENABLE_M7 check (correctly timed) fires, aliasing whatever
// bit 0 actually is - a genuinely wrong pin, not a build failure. Defining
// these unconditionally costs nothing; core's own `#ifdef ENABLE_M7` in
// coolant_control.c is the only place that ever reads them.
#define COOLANT_MIST_PORT    PORT_GROUPA
#define COOLANT_MIST_PIN     25
#define COOLANT_MIST_BIT     25

// ============================================================================
// UART PINS
// ============================================================================

#define UART_RX_PORT           PORT_GROUPA
#define UART_RX_PIN            11   // SERCOM0 PAD[3]
#define UART_RX_BIT            11
#define UART_RX_PAD            3

#define UART_TX_PORT           PORT_GROUPA
#define UART_TX_PIN            10   // SERCOM0 PAD[2]
#define UART_TX_BIT            10
#define UART_TX_PAD            2

#define UART_SERCOM            SERCOM0
#define UART_SERCOM_PMUX       0x2  // Function C

// ============================================================================
// PERIPHERAL ASSIGNMENTS
// ============================================================================

#define STEPPER_TIMER          TC3
#define STEPPER_TIMER_IRQn     TC3_IRQn

#define PULSE_TIMER            TC4
#define PULSE_TIMER_IRQn       TC4_IRQn

#define SPINDLE_PWM_TIMER      TCC0
#define SPINDLE_PWM_TIMER_IRQn TCC0_IRQn

#define STEPPER_TIMER_GCLK_ID  GCLK_CLKCTRL_ID_TC3_TC4
#define SPINDLE_PWM_GCLK_ID    GCLK_CLKCTRL_ID_TCC0_TCC1
#define UART_GCLK_ID           GCLK_CLKCTRL_ID_SERCOM0_CORE

// ============================================================================
// SINGLE-PORT ALIASES (for gpio.h compatibility)
// ============================================================================
// generic board uses single port (PORT A), so map _MASK to _MASK_A

#define STEP_MASK               STEP_MASK_A
#define DIRECTION_MASK          DIRECTION_MASK_A
#define STEPPERS_DISABLE_MASK   STEPPERS_DISABLE_MASK_A
#define LIMIT_MASK              LIMIT_MASK_A
#define CONTROL_MASK            CONTROL_MASK_A
#define PROBE_MASK              PROBE_MASK_A

#define STEP_PORT               PORT_GROUPA
#define DIRECTION_PORT          PORT_GROUPA
#define LIMIT_PORT              PORT_GROUPA
#define CONTROL_PORT            PORT_GROUPA
#define STEPPERS_DISABLE_PORT_ALIAS   PORT_GROUPA

#endif // BOARD_GENERIC_CONFIG_H
