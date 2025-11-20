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

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "MegARM"
#define BOARD_MCU  "ATSAMC21E18A-MZ"
#define BOARD_URL  "https://github.com/kimstik/MegARM"

// ============================================================================
// STEP PINS (D2, D3, D4 on Arduino Mega pinout)
// ============================================================================

#define X_STEP_PORT         PORT_GROUPA
#define X_STEP_PIN          25   // PA25 (D2)
#define X_STEP_BIT          25

#define Y_STEP_PORT         PORT_GROUPA
#define Y_STEP_PIN          27   // PA27 (D3)
#define Y_STEP_BIT          27

#define Z_STEP_PORT         PORT_GROUPA
#define Z_STEP_PIN          28   // PA28 (D4)
#define Z_STEP_BIT          28

// Combined step mask (all on PORT A)
#define STEP_MASK_A         ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))
#define STEP_MASK_B         0

// ============================================================================
// DIRECTION PINS (D5, D6, D7)
// ============================================================================

#define X_DIRECTION_PORT    PORT_GROUPA
#define X_DIRECTION_PIN     0    // PA0 (D5)
#define X_DIRECTION_BIT     0

#define Y_DIRECTION_PORT    PORT_GROUPA
#define Y_DIRECTION_PIN     1    // PA1 (D6)
#define Y_DIRECTION_BIT     1

#define Z_DIRECTION_PORT    PORT_GROUPA
#define Z_DIRECTION_PIN     2    // PA2 (D7)
#define Z_DIRECTION_BIT     2

// Combined direction mask (all on PORT A)
#define DIRECTION_MASK_A    ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))
#define DIRECTION_MASK_B    0

// ============================================================================
// STEPPER ENABLE PIN (B0)
// ============================================================================

#define STEPPERS_DISABLE_PORT   PORT_GROUPA
#define STEPPERS_DISABLE_PIN    3    // PA3 (B0)
#define STEPPERS_DISABLE_BIT    3

#define STEPPERS_DISABLE_MASK_A (1UL<<STEPPERS_DISABLE_PIN)
#define STEPPERS_DISABLE_MASK_B 0

// ============================================================================
// LIMIT SWITCH PINS (B1, B2, B4)
// ============================================================================

#define X_LIMIT_PORT        PORT_GROUPA
#define X_LIMIT_PIN         4    // PA4 (B1)
#define X_LIMIT_BIT         4

#define Y_LIMIT_PORT        PORT_GROUPA
#define Y_LIMIT_PIN         5    // PA5 (B2)
#define Y_LIMIT_BIT         5

#define Z_LIMIT_PORT        PORT_GROUPA
#define Z_LIMIT_PIN         7    // PA7 (B4)
#define Z_LIMIT_BIT         7

// Combined limit mask (all on PORT A)
#define LIMIT_MASK_A        ((1UL<<X_LIMIT_PIN)|(1UL<<Y_LIMIT_PIN)|(1UL<<Z_LIMIT_PIN))
#define LIMIT_MASK_B        0

// ============================================================================
// CONTROL PINS (C0, C1, C2)
// ============================================================================

#define CONTROL_RESET_PORT      PORT_GROUPA
#define CONTROL_RESET_PIN       14   // PA14 (C0)
#define CONTROL_RESET_BIT       14

#define CONTROL_FEED_HOLD_PORT  PORT_GROUPA
#define CONTROL_FEED_HOLD_PIN   15   // PA15 (C1)
#define CONTROL_FEED_HOLD_BIT   15

#define CONTROL_CYCLE_START_PORT   PORT_GROUPA
#define CONTROL_CYCLE_START_PIN    16   // PA16 (C2)
#define CONTROL_CYCLE_START_BIT    16

#define CONTROL_SAFETY_DOOR_PORT   PORT_GROUPA
#define CONTROL_SAFETY_DOOR_PIN    15   // PA15 (C1 - shared with FEED_HOLD)
#define CONTROL_SAFETY_DOOR_BIT    15

// Combined control mask (all on PORT A)
#define CONTROL_MASK_A      ((1UL<<CONTROL_RESET_PIN)|(1UL<<CONTROL_FEED_HOLD_PIN)|(1UL<<CONTROL_CYCLE_START_PIN))
#define CONTROL_MASK_B      0

#define CONTROL_INVERT_MASK CONTROL_MASK_A

// ============================================================================
// PROBE PIN (C5)
// ============================================================================

#define PROBE_PORT          PORT_GROUPA
#define PROBE_PIN           19   // PA19 (C5)
#define PROBE_BIT           19

#define PROBE_MASK_A        (1UL<<PROBE_PIN)
#define PROBE_MASK_B        0

// ============================================================================
// SPINDLE CONTROL PINS (B3, B5)
// ============================================================================

#define SPINDLE_PWM_PORT       PORT_GROUPA
#define SPINDLE_PWM_PIN        6    // PA6 (B3) - TCC0/WO[0]
#define SPINDLE_PWM_BIT        6
#define SPINDLE_PWM_CHANNEL    0    // TCC0 channel 0

#define SPINDLE_DIRECTION_PORT PORT_GROUPA
#define SPINDLE_DIRECTION_PIN  8    // PA8 (B5)
#define SPINDLE_DIRECTION_BIT  8

#define SPINDLE_ENABLE_PORT    PORT_GROUPA
#define SPINDLE_ENABLE_PIN     9    // PA9 (optional)
#define SPINDLE_ENABLE_BIT     9

// Spindle PWM configuration
#define SPINDLE_PWM_MAX_VALUE  65535  // 16-bit PWM
#define SPINDLE_PWM_MIN_VALUE  1      // Must be > 0 to avoid floating
#define SPINDLE_PWM_OFF_VALUE  0
#define SPINDLE_PWM_RANGE      (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// ============================================================================
// COOLANT CONTROL PINS (C3, C4)
// ============================================================================

#define COOLANT_FLOOD_PORT     PORT_GROUPA
#define COOLANT_FLOOD_PIN      17   // PA17 (C3)
#define COOLANT_FLOOD_BIT      17

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT    PORT_GROUPA
  #define COOLANT_MIST_PIN     18   // PA18 (C4)
  #define COOLANT_MIST_BIT     18
#endif

// ============================================================================
// UART PINS (D0, D1)
// ============================================================================

#define UART_RX_PORT           PORT_GROUPA
#define UART_RX_PIN            23   // PA23 (D0) - SERCOM3 PAD[1]
#define UART_RX_BIT            23
#define UART_RX_PAD            1    // SERCOM PAD[1]

#define UART_TX_PORT           PORT_GROUPA
#define UART_TX_PIN            24   // PA24 (D1) - SERCOM3 PAD[2]
#define UART_TX_BIT            24
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

#endif // BOARD_MEGARM_CONFIG_H
