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

#define X_STEP_PORT         PORT_GROUPA
#define X_STEP_PIN          16
#define X_STEP_BIT          16

#define Y_STEP_PORT         PORT_GROUPA
#define Y_STEP_PIN          17
#define Y_STEP_BIT          17

#define Z_STEP_PORT         PORT_GROUPA
#define Z_STEP_PIN          18
#define Z_STEP_BIT          18

#define STEP_MASK_A         ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))
#define STEP_MASK_B         0

// ============================================================================
// DIRECTION PINS
// ============================================================================

#define X_DIRECTION_PORT    PORT_GROUPA
#define X_DIRECTION_PIN     19
#define X_DIRECTION_BIT     19

#define Y_DIRECTION_PORT    PORT_GROUPA
#define Y_DIRECTION_PIN     20
#define Y_DIRECTION_BIT     20

#define Z_DIRECTION_PORT    PORT_GROUPA
#define Z_DIRECTION_PIN     21
#define Z_DIRECTION_BIT     21

#define DIRECTION_MASK_A    ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))
#define DIRECTION_MASK_B    0

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

#define SPINDLE_PWM_MAX_VALUE  65535
#define SPINDLE_PWM_MIN_VALUE  0
#define SPINDLE_PWM_OFF_VALUE  0

// ============================================================================
// COOLANT CONTROL PINS
// ============================================================================

#define COOLANT_FLOOD_PORT     PORT_GROUPA
#define COOLANT_FLOOD_PIN      24
#define COOLANT_FLOOD_BIT      24

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT    PORT_GROUPA
  #define COOLANT_MIST_PIN     25
  #define COOLANT_MIST_BIT     25
#endif

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

#endif // BOARD_GENERIC_CONFIG_H
