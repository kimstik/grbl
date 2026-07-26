/*
  config.h - MegARM Board Configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  Board: MegARM
  MCU: ATSAMC21E18A-MZ
  Description: Arduino Mega pin-compatible replacement board
  Reference: https://github.com/kimstik/MegARM

  Pin mapping based on MegARM layout - ATmega328P to ATSAMC21E18A-MZ
*/

#ifndef BOARD_MEGARM_CONFIG_H
#define BOARD_MEGARM_CONFIG_H

//	notation - specified in platform\samd21\gpio.h 

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "MegARM"
#define BOARD_MCU  "ATSAMC21E18A-MZ"
#define BOARD_URL  "https://github.com/kimstik/MegARM"

// ============================================================================
// STEP PINS (D2, D3, D4 on Arduino Mega pinout)
// ============================================================================

// LOGICAL PORT-IMAGE CONTRACT (BUG #17, PLAN.md Phase 3 / CONTRACTS.md #1):
// core packs step_outbits/dir_outbits/axislock into a uint8_t and derives
// per-axis bits as `1<<X_STEP_BIT` (stepper.c get_step_pin_mask(), limits.c:342
// `STEP_MASK & axislock`). X/Y/Z_STEP_BIT MUST be logical bits 0..2 on every
// board - MegARM's real pins (PA25/27/28) don't fit a byte and silently
// truncated in the ISR's compound |= when used directly here (that was the
// bug: zero step output, ever, on this board). The real silicon pin now
// lives in the matching *_STEP_PIN define; samd21/gpio.h's GPIO_MWO_STEP/
// GPIO_MDIR_OUT_STEP translate logical<->physical via STEP_L2P/STEP_P2L
// (3-term OR-of-shifts gather/scatter - branch-free, ISR-hot safe).

#define X_STEP_PIN          25   // PA25 (D2) - real silicon pin
#define Y_STEP_PIN          27   // PA27 (D3)
#define Z_STEP_PIN          28   // PA28 (D4)

#define X_STEP_PORT         PORT_GROUPA
#define X_STEP_BIT          0    // LOGICAL (core's native uint8_t port image)

#define Y_STEP_PORT         PORT_GROUPA
#define Y_STEP_BIT          1

#define Z_STEP_PORT         PORT_GROUPA
#define Z_STEP_BIT          2

// Physical register mask (real PA25/27/28) - consumed only by gpio.h's
// GPIO_MWO_STEP/GPIO_MDIR_OUT_STEP/GPIO_MRD_STEP; core never sees it.
#define STEP_MASK_PHYS      ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))

// Logical <-> physical: PA25/27/28 scatter, so this is a 3-term gather/
// scatter (OR of independently shifted single bits) - no data-dependent
// branch, safe inside the ISR-hot GPIO_MWO_STEP path.
#define STEP_L2P(v) ( \
    ((((uint32_t)(v) >> 0) & 1UL) << 25) | \
    ((((uint32_t)(v) >> 1) & 1UL) << 27) | \
    ((((uint32_t)(v) >> 2) & 1UL) << 28) )
#define STEP_P2L(v) ( \
    ((((uint32_t)(v) >> 25) & 1UL) << 0) | \
    ((((uint32_t)(v) >> 27) & 1UL) << 1) | \
    ((((uint32_t)(v) >> 28) & 1UL) << 2) )

// Combined step mask (all on PORT A) - LOGICAL, this is the core-visible
// STEP_MASK aliased below (limits.c:342, stepper.c:499,561)
#define STEP_MASK_A         ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))
#define STEP_MASK_B         0

// ============================================================================
// DIRECTION PINS (D5, D6, D7)
// ============================================================================
// Real silicon pins (PA0/1/2) already sit at bits 0..2, so logical ==
// physical here - DIRECTION_L2P/P2L are identity. Kept explicit (rather
// than skipping the override) so gpio.h's dispatch is uniform across groups
// and boards; costs nothing (folds to the identity at -O0 and vanishes at -Os).

#define X_DIRECTION_PIN     0    // PA0 (D5) - real silicon pin
#define Y_DIRECTION_PIN     1    // PA1 (D6)
#define Z_DIRECTION_PIN     2    // PA2 (D7)

#define X_DIRECTION_PORT    PORT_GROUPA
#define X_DIRECTION_BIT     0    // LOGICAL - identical to physical on this board

#define Y_DIRECTION_PORT    PORT_GROUPA
#define Y_DIRECTION_BIT     1

#define Z_DIRECTION_PORT    PORT_GROUPA
#define Z_DIRECTION_BIT     2

#define DIRECTION_MASK_PHYS ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))
#define DIRECTION_L2P(v)    ((uint32_t)(v))
#define DIRECTION_P2L(v)    ((uint32_t)(v))

// Combined direction mask (all on PORT A) - LOGICAL
#define DIRECTION_MASK_A    ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))
#define DIRECTION_MASK_B    0

// PLAN.md Phase 2 static-assert sweep (2026-07-26): the BUG #17 fix above
// made X/Y/Z_STEP_BIT/X/Y/Z_DIRECTION_BIT logical-by-construction; this
// codifies the invariant so a future edit to this board's bit numbers
// cannot silently regress into the exact truncation BUG #17 was.
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image (BUG #17 class, CONTRACTS.md #1)");

// ============================================================================
// STEPPER ENABLE PIN (B0)
// ============================================================================

#define STEPPERS_DISABLE_PORT   PORT_GROUPA
#define STEPPERS_DISABLE_BIT    3    // PA3 (B0)

#define STEPPERS_DISABLE_MASK_A (1UL<<STEPPERS_DISABLE_BIT)
#define STEPPERS_DISABLE_MASK_B 0

// ============================================================================
// LIMIT SWITCH PINS (B1, B2, B4)
// ============================================================================

#define X_LIMIT_PORT        PORT_GROUPA
#define X_LIMIT_BIT         4    // PA4 (B1)

#define Y_LIMIT_PORT        PORT_GROUPA
#define Y_LIMIT_BIT         5    // PA5 (B2)

#define Z_LIMIT_PORT        PORT_GROUPA
#define Z_LIMIT_BIT         7    // PA7 (B4)

// Combined limit mask (all on PORT A)
#define LIMIT_MASK_A        ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))
#define LIMIT_MASK_B        0

// ============================================================================
// CONTROL PINS (C0, C1, C2)
// ============================================================================

#define CONTROL_RESET_PORT      PORT_GROUPA
#define CONTROL_RESET_BIT       14   // PA14 (C0)

#define CONTROL_FEED_HOLD_PORT  PORT_GROUPA
#define CONTROL_FEED_HOLD_BIT   15   // PA15 (C1)

#define CONTROL_CYCLE_START_PORT   PORT_GROUPA
#define CONTROL_CYCLE_START_BIT    16   // PA16 (C2)

#define CONTROL_SAFETY_DOOR_PORT   PORT_GROUPA
#define CONTROL_SAFETY_DOOR_BIT    15   // PA15 (C1 - shared with FEED_HOLD)

// Combined control mask (all on PORT A)
#define CONTROL_MASK_A      ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_MASK_B      0

#define CONTROL_INVERT_MASK CONTROL_MASK_A

// ============================================================================
// PROBE PIN (C5)
// ============================================================================

#define PROBE_PORT          PORT_GROUPA
#define PROBE_BIT           19   // PA19 (C5)

#define PROBE_MASK_A        (1UL<<PROBE_BIT)
#define PROBE_MASK_B        0

// ============================================================================
// SPINDLE CONTROL PINS (B3, B5)
// ============================================================================

#define SPINDLE_PWM_PORT       PORT_GROUPA
#define SPINDLE_PWM_BIT        6    // PA6 (B3) - TCC0/WO[0]
#define SPINDLE_PWM_CHANNEL    0    // TCC0 channel 0

#define SPINDLE_DIRECTION_PORT PORT_GROUPA
#define SPINDLE_DIRECTION_BIT  8    // PA8 (B5)

#define SPINDLE_ENABLE_PORT    PORT_GROUPA
#define SPINDLE_ENABLE_BIT     9    // PA9 (optional)

// Spindle PWM configuration
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
// this board was the one deliberately-excluded, tracked violation of the
// duty-cap-twins class (CONTRACTS.md static-assert-sweep slug) - it shipped
// SPINDLE_PWM_MAX_VALUE=65535 while TCC0's PER=0xFF and core's duty is
// uint8_t. BUG #22 (reclassified 2026-07-26, was wrongly called cosmetic):
// only ONE use site (the uint8_t assignment in spindle_compute_pwm_value())
// silently truncated 65535->255 harmlessly; spindle_control.c:45's
// `pwm_gradient = SPINDLE_PWM_RANGE/(rpm_max-rpm_min)` is a FLOAT
// expression with no such truncation, so pwm_gradient was ~258x too large
// and real commanded spindle speeds produced wrapped-mod-256 garbage duty
// values - see CONTRACTS.md #6.2/static-assert-sweep and PLAN.md's BUG #22
// entry for the objdump diff and reproduction numbers. Not a benign
// accident: a live, silent spindle-output defect. Fixed to the single
// canon (255) in the same commit that adds this assert, per the
// instruction the exclusion comment left. The class is now closed on
// every port, no exceptions.
_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2, duty-cap-twins class)");

// ============================================================================
// COOLANT CONTROL PINS (C3, C4)
// ============================================================================

#define COOLANT_FLOOD_PORT     PORT_GROUPA
#define COOLANT_FLOOD_BIT      17   // PA17 (C3)

// NOT gated on `#ifdef ENABLE_M7`: this file arrives via the build prelude
// (-include $(BOARD)/prelude.h), processed before grbl.h's own #include
// "config.h" ever defines ENABLE_M7 - a guard here can never observe it,
// silently dropping this pin even when the user enables the feature
// (CONTRACTS.md #19 "guard that certifies instead of checking", wrong-
// phase variant - see grbl/CONTRACTS.md gap log and samd21/generic/
// config.h's identical fix). Defining it unconditionally costs nothing;
// core's own (correctly-timed) `#ifdef ENABLE_M7` in coolant_control.c is
// the only place that ever reads it.
#define COOLANT_MIST_PORT    PORT_GROUPA
#define COOLANT_MIST_BIT     18   // PA18 (C4)

// ============================================================================
// UART PINS (D0, D1)
// ============================================================================

#define UART_RX_PORT           PORT_GROUPA
#define UART_RX_BIT            23   // PA23 (D0) - SERCOM3 PAD[1]
#define UART_RX_PAD            1    // SERCOM PAD[1]

#define UART_TX_PORT           PORT_GROUPA
#define UART_TX_BIT            24   // PA24 (D1) - SERCOM3 PAD[2]
#define UART_TX_PAD            2    // SERCOM PAD[2]

// UART peripheral selection
#define UART_SERCOM            SERCOM3
#define UART_SERCOM_PMUX       0x2  // Function C

// ============================================================================
// PERIPHERAL ASSIGNMENTS
// ============================================================================

// Timers
#define STEPPER_TIMER          TC3
#define STEPPER_TIMER_IRQn     TC3_IRQn

#define PULSE_TIMER            TC4
#define PULSE_TIMER_IRQn       TC4_IRQn

#define SPINDLE_PWM_TIMER      TCC0
#define SPINDLE_PWM_TIMER_IRQn TCC0_IRQn

// Clock configuration
#define STEPPER_TIMER_GCLK_ID  GCLK_CLKCTRL_ID_TC3_TC4
#define SPINDLE_PWM_GCLK_ID    GCLK_CLKCTRL_ID_TCC0_TCC1
#define UART_GCLK_ID           GCLK_CLKCTRL_ID_SERCOM3_CORE

// ============================================================================
// SINGLE-PORT ALIASES (for gpio.h compatibility)
// ============================================================================
// MegARM uses single port (PORT A), so map _MASK to _MASK_A

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

#endif // BOARD_MEGARM_CONFIG_H
