/*
  config.h - Generic CH32V006 board configuration
  Part of Grbl

  PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up: this is a
  plausible 20-pin-package assignment (task brief: "plausible 20-pin
  map"), NOT verified against a real CH32V006 datasheet/pinout in this
  session. Copy this directory to boards/yourboard and replace every
  value once real silicon wiring is known.

  LOGICAL PORT-IMAGE CONTRACT (BUG #17, PLAN.md Phase 3 / CONTRACTS.md
  #1): X/Y/Z_STEP_BIT and X/Y/Z_DIRECTION_BIT are LOGICAL bits 0,1,2
  (core's native uint8_t port image - stepper.c get_step_pin_mask()/
  get_direction_pin_mask()). STEP's physical pins happen to already be
  0,1,2 (no translation needed); DIRECTION's physical pins are 3,4,5, so
  gpio.h-equivalent translation is needed at the GPIO_MWO/GPIO_MDIR_OUT
  layer - this port does NOT yet have that samd21-style GPIO_MWO_STEP/
  GPIO_MWO_DIRECTION override (gpio.h only defines the plain
  GPIO_OREG/IREG accessors this batch), so DIRECTION_MASK below is
  PHYSICAL for now. GAP: this must be added (mirroring
  samd21/gpio.h's GPIO_MWO_STEP/DIRECTION dispatch) before Step 3
  (timers) makes ISR_STEP/ISR_STEP_RESET live, or DIRECTION output will
  silently write the wrong bits the same way BUG #17 did on SAMD21 -
  logged in CONTRACTS.md's new RISC-V section rather than silently
  deferred.
*/

#ifndef BOARD_GENERIC_CH32V006_CONFIG_H
#define BOARD_GENERIC_CH32V006_CONFIG_H

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "Generic CH32V006 (20-pin, PLACEHOLDER pinout)"
#define BOARD_MCU  "CH32V006"
#define BOARD_URL  ""

// ============================================================================
// STEP PINS (GPIOC: PC0, PC1, PC2) - physical == logical, no translation
// ============================================================================

#define X_STEP_PORT         GPIOC
#define X_STEP_PIN          0
#define X_STEP_BIT          0
#define Y_STEP_PORT         GPIOC
#define Y_STEP_PIN          1
#define Y_STEP_BIT          1
#define Z_STEP_PORT         GPIOC
#define Z_STEP_PIN          2
#define Z_STEP_BIT          2

#define STEP_PORT           GPIOC
#define STEP_MASK           ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))

// ============================================================================
// DIRECTION PINS (GPIOC: PC3, PC4, PC5) - see file header GAP note
// ============================================================================

#define X_DIRECTION_PORT    GPIOC
#define X_DIRECTION_PIN     3
#define X_DIRECTION_BIT     3   // PHYSICAL for now - see file header GAP
#define Y_DIRECTION_PORT    GPIOC
#define Y_DIRECTION_PIN     4
#define Y_DIRECTION_BIT     4
#define Z_DIRECTION_PORT    GPIOC
#define Z_DIRECTION_PIN     5
#define Z_DIRECTION_BIT     5

#define DIRECTION_PORT      GPIOC
#define DIRECTION_MASK      ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))

// ============================================================================
// STEPPER ENABLE (GPIOC: PC6)
// ============================================================================

#define STEPPERS_DISABLE_PORT   GPIOC
#define STEPPERS_DISABLE_PIN    6
#define STEPPERS_DISABLE_BIT    6
#define STEPPERS_DISABLE_MASK   (1UL<<STEPPERS_DISABLE_BIT)

// ============================================================================
// COOLANT FLOOD (GPIOC: PC7)
// ============================================================================

#define COOLANT_FLOOD_PORT      GPIOC
#define COOLANT_FLOOD_PIN       7
#define COOLANT_FLOOD_BIT       7

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     GPIOD
  #define COOLANT_MIST_PIN      7
  #define COOLANT_MIST_BIT      7
#endif

// ============================================================================
// LIMIT SWITCHES (GPIOD: PD0, PD1, PD2) - inputs, bits 0-7 (CONTRACTS.md #1.3)
// ============================================================================

#define X_LIMIT_PORT        GPIOD
#define X_LIMIT_PIN         0
#define X_LIMIT_BIT         0
#define Y_LIMIT_PORT        GPIOD
#define Y_LIMIT_PIN         1
#define Y_LIMIT_BIT         1
#define Z_LIMIT_PORT        GPIOD
#define Z_LIMIT_PIN         2
#define Z_LIMIT_BIT         2

#define LIMIT_PORT          GPIOD
#define LIMIT_MASK          ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

// ============================================================================
// USART1 (GPIOD: PD5=TX, PD6=RX) - fixed pins, no AFIO remap assumed
// ============================================================================

#define SERIAL_TX_PORT      GPIOD
#define SERIAL_TX_PIN       5
#define SERIAL_RX_PORT      GPIOD
#define SERIAL_RX_PIN       6

// ============================================================================
// CONTROL PINS (GPIOA: PA0-PA2) - inputs, bits 0-7
// ============================================================================

#define CONTROL_RESET_PORT       GPIOA
#define CONTROL_RESET_PIN        0
#define CONTROL_RESET_BIT        0
#define CONTROL_FEED_HOLD_PORT   GPIOA
#define CONTROL_FEED_HOLD_PIN    1
#define CONTROL_FEED_HOLD_BIT    1
#define CONTROL_CYCLE_START_PORT GPIOA
#define CONTROL_CYCLE_START_PIN  2
#define CONTROL_CYCLE_START_BIT  2
// Safety door shares the feed-hold pin (no dedicated input on this generic
// board) - same convention as samd21/generic/config.h.
#define CONTROL_SAFETY_DOOR_PORT GPIOA
#define CONTROL_SAFETY_DOOR_PIN  1
#define CONTROL_SAFETY_DOOR_BIT  1

#define CONTROL_PORT         GPIOA
#define CONTROL_MASK         ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK  CONTROL_MASK

// ============================================================================
// PROBE (GPIOA: PA3)
// ============================================================================

#define PROBE_PORT           GPIOA
#define PROBE_PIN            3
#define PROBE_BIT             3
#define PROBE_MASK            (1UL<<PROBE_BIT)

// ============================================================================
// SPINDLE (GPIOA: PA4=enable, PA5=direction, PA6=PWM/TIM1)
// SPINDLE_PWM_MAX_VALUE must be <= 255 - core plumbs duty as uint8_t
// end-to-end (CONTRACTS.md #6.2).
// ============================================================================

#define SPINDLE_ENABLE_PORT     GPIOA
#define SPINDLE_ENABLE_PIN      4
#define SPINDLE_ENABLE_BIT      4

#define SPINDLE_DIRECTION_PORT  GPIOA
#define SPINDLE_DIRECTION_PIN   5
#define SPINDLE_DIRECTION_BIT   5

#define SPINDLE_PWM_PORT        GPIOA
#define SPINDLE_PWM_PIN         6
#define SPINDLE_PWM_BIT         6
#define SPINDLE_PWM_TIMER       TIM1
#define SPINDLE_PWM_CHANNEL     1

#define SPINDLE_PWM_MAX_VALUE   255
#define SPINDLE_PWM_MIN_VALUE   1
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// ============================================================================
// PERIPHERAL ASSIGNMENTS (Step 3/4 - not wired yet)
// ============================================================================

#define STEPPER_TIMER           TIM2
#define PULSE_TIMER             TIM3
#define GRBL_USART              USART1

#endif // BOARD_GENERIC_CH32V006_CONFIG_H
