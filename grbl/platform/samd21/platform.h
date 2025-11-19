/*
  platform.h - SAMD21 platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for SAMD21G18A.
  ARM Cortex-M0+, 48 MHz, 32KB RAM, 256KB Flash
  Used in Arduino Zero, MKR series
*/

#ifndef PLATFORM_SAMD21_H
#define PLATFORM_SAMD21_H

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

// PLATFORM_NAME is defined in hal.h as "SAMD21"
// Board-specific name for reference
#define PLATFORM_BOARD_NAME     "SAMD21G18A"
#define PLATFORM_CPU      "ARM Cortex-M0+"
#define PLATFORM_ARCH     "ARM"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           0   // Cortex-M0+ has no FPU (software emulation)
#define HAL_HAS_DMA           1   // 12 DMA channels
#define HAL_HAS_USB           1   // Native USB device
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define HAL_HAS_HW_DIVIDE     1   // DIVAS - Division and Square Root Accelerator
#define HAL_HAS_DIVAS         1   // Hardware 32-bit division, sqrt, modulo (1-3 cycles)

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        48000000UL  // 48 MHz
#endif

#define HAL_RAM_SIZE          32768       // 32 KB
#define HAL_FLASH_SIZE        262144      // 256 KB
#define HAL_EEPROM_SIZE       0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   20      // 20.8 ns @ 48 MHz

// ============================================================================
// SAMD21 INCLUDES
// ============================================================================

#include "samd21.h"
#include "core_cm0plus.h"

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS
// ============================================================================

/*
  SAMD21G18A (Arduino Zero/MKR) Pin Mapping for GRBL:

  Step pins:
    X_STEP   → PA02  (Port A, Pin 2)
    Y_STEP   → PA04  (Port A, Pin 4)
    Z_STEP   → PA05  (Port A, Pin 5)

  Direction pins:
    X_DIR    → PA06  (Port A, Pin 6)
    Y_DIR    → PA07  (Port A, Pin 7)
    Z_DIR    → PA08  (Port A, Pin 8)

  Stepper enable:
    ENABLE   → PA09  (Port A, Pin 9)

  Limit switches:
    X_LIMIT  → PA10  (Port A, Pin 10)
    Y_LIMIT  → PA11  (Port A, Pin 11)
    Z_LIMIT  → PB10  (Port B, Pin 10)

  Control pins:
    RESET       → PB11  (Port B, Pin 11)
    FEED_HOLD   → PA12  (Port A, Pin 12)
    CYCLE_START → PA13  (Port A, Pin 13)
    SAFETY_DOOR → PA14  (Port A, Pin 14)

  Spindle control:
    SPINDLE_PWM    → PA15  (Port A, Pin 15, TCC0/WO[5])
    SPINDLE_ENABLE → PA16  (Port A, Pin 16)
    SPINDLE_DIR    → PA17  (Port A, Pin 17)

  Coolant control:
    COOLANT_FLOOD → PA18  (Port A, Pin 18)
    COOLANT_MIST  → PA19  (Port A, Pin 19)

  Probe:
    PROBE → PA20  (Port A, Pin 20)

  UART (Serial):
    TX    → PA22  (SERCOM3 PAD[0])
    RX    → PA23  (SERCOM3 PAD[1])
*/

// --------------------------------------------------------------------------
// STEP PINS (Port A)
// --------------------------------------------------------------------------

#define STEP_PORT           PORT_GROUPA
#define STEP_PORT_ID        ((hal_gpio_port_t)PORT_GROUPA)
#define STEP_DDR            STEP_PORT_ID  // DDR alias for AVR compatibility
#define X_STEP_PIN          2
#define Y_STEP_PIN          4
#define Z_STEP_PIN          5
#define X_STEP_BIT          2
#define Y_STEP_BIT          4
#define Z_STEP_BIT          5
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))

// --------------------------------------------------------------------------
// DIRECTION PINS (Port A)
// --------------------------------------------------------------------------

#define DIRECTION_PORT      PORT_GROUPA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)PORT_GROUPA)
#define DIRECTION_DDR       DIRECTION_PORT_ID  // DDR alias for AVR compatibility
#define X_DIRECTION_PIN     6
#define Y_DIRECTION_PIN     7
#define Z_DIRECTION_PIN     8
#define X_DIRECTION_BIT     6
#define Y_DIRECTION_BIT     7
#define Z_DIRECTION_BIT     8
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

// --------------------------------------------------------------------------
// STEPPER ENABLE PIN (Port A)
// --------------------------------------------------------------------------

#define STEPPERS_DISABLE_PORT   PORT_GROUPA
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define STEPPERS_DISABLE_DDR    STEPPERS_DISABLE_PORT_ID  // DDR alias for AVR compatibility
#define STEPPERS_DISABLE_PIN    9
#define STEPPERS_DISABLE_BIT    9
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (Port A/B)
// --------------------------------------------------------------------------

#define X_LIMIT_PORT        PORT_GROUPA
#define X_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define X_LIMIT_PIN         10
#define X_LIMIT_BIT         10

#define Y_LIMIT_PORT        PORT_GROUPA
#define Y_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define Y_LIMIT_PIN         11
#define Y_LIMIT_BIT         11

#define Z_LIMIT_PORT        PORT_GROUPB
#define Z_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPB)
#define Z_LIMIT_PIN         10
#define Z_LIMIT_BIT         10

// For mask operations (if all on same port)
#define LIMIT_MASK_A        ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN))
#define LIMIT_MASK_B        (1<<Z_LIMIT_PIN)

// --------------------------------------------------------------------------
// CONTROL PINS (Port A/B)
// --------------------------------------------------------------------------

#define CONTROL_RESET_PORT        PORT_GROUPB
#define CONTROL_RESET_PORT_ID     ((hal_gpio_port_t)PORT_GROUPB)
#define CONTROL_RESET_PIN         11
#define CONTROL_RESET_BIT         11

#define CONTROL_FEED_HOLD_PORT    PORT_GROUPA
#define CONTROL_FEED_HOLD_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_FEED_HOLD_PIN     12
#define CONTROL_FEED_HOLD_BIT     12

#define CONTROL_CYCLE_START_PORT  PORT_GROUPA
#define CONTROL_CYCLE_START_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_CYCLE_START_PIN   13
#define CONTROL_CYCLE_START_BIT   13

#define CONTROL_SAFETY_DOOR_PORT  PORT_GROUPA
#define CONTROL_SAFETY_DOOR_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_SAFETY_DOOR_PIN   14
#define CONTROL_SAFETY_DOOR_BIT   14

#define CONTROL_MASK_A      ((1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN)|(1<<CONTROL_SAFETY_DOOR_PIN))
#define CONTROL_MASK_B      (1<<CONTROL_RESET_PIN)
#define CONTROL_INVERT_MASK (CONTROL_MASK_A | CONTROL_MASK_B)

// --------------------------------------------------------------------------
// PROBE PIN (Port A)
// --------------------------------------------------------------------------

#define PROBE_PORT          PORT_GROUPA
#define PROBE_PORT_ID       ((hal_gpio_port_t)PORT_GROUPA)
#define PROBE_PIN           20
#define PROBE_BIT           20
#define PROBE_MASK          (1<<PROBE_PIN)

// --------------------------------------------------------------------------
// SPINDLE PINS
// --------------------------------------------------------------------------

// Spindle PWM (PA15, TCC0/WO[5])
#define SPINDLE_PWM_PORT        PORT_GROUPA
#define SPINDLE_PWM_PIN         15
#define SPINDLE_PWM_BIT         15
#define SPINDLE_PWM_TCC         TCC0
#define SPINDLE_PWM_CHANNEL     5      // WO[5]
#define SPINDLE_PWM_PMUX        PORT_PMUX_PMUXO_F  // Function F

// Spindle enable/direction
#define SPINDLE_ENABLE_PORT     PORT_GROUPA
#define SPINDLE_ENABLE_PIN      16
#define SPINDLE_ENABLE_BIT      16

#define SPINDLE_DIRECTION_PORT  PORT_GROUPA
#define SPINDLE_DIRECTION_PIN   17
#define SPINDLE_DIRECTION_BIT   17

// PWM resolution (16-bit counter)
#ifdef VARIABLE_SPINDLE
  #define SPINDLE_PWM_MAX_VALUE     65535  // 16-bit PWM
  #define SPINDLE_PWM_MIN_VALUE     1
  #define SPINDLE_PWM_OFF_VALUE     0
  #define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)
#endif

// --------------------------------------------------------------------------
// COOLANT PINS (Port A)
// --------------------------------------------------------------------------

#define COOLANT_FLOOD_PORT      PORT_GROUPA
#define COOLANT_FLOOD_PIN       18
#define COOLANT_FLOOD_BIT       18

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     PORT_GROUPA
  #define COOLANT_MIST_PIN      19
  #define COOLANT_MIST_BIT      19
#endif

// ============================================================================
// TIMER MAPPING
// ============================================================================

// Stepper timer: TC3 (16-bit timer/counter)
#define STEPPER_TIMER           TC3
#define STEPPER_TIMER_IRQn      TC3_IRQn
#define STEPPER_TIMER_IRQHandler TC3_Handler

// Step pulse reset timer: TC4 (16-bit timer/counter)
#define PULSE_TIMER             TC4
#define PULSE_TIMER_IRQn        TC4_IRQn
#define PULSE_TIMER_IRQHandler  TC4_Handler

// Spindle PWM timer: TCC0 (Timer/Counter for Control)
// Already defined above

// ============================================================================
// SERIAL/UART MAPPING
// ============================================================================

// Using SERCOM3 for UART
#define GRBL_SERCOM             SERCOM3
#define GRBL_SERCOM_IRQn        SERCOM3_IRQn
#define GRBL_SERCOM_IRQHandler  SERCOM3_Handler

// ============================================================================
// FLASH EMULATION FOR EEPROM
// ============================================================================

// Use last 4KB of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   (0x00000000 + HAL_FLASH_SIZE - 4096)
#define HAL_NVMEM_FLASH_SIZE    4096
#define HAL_NVMEM_FLASH_PAGE_SIZE 64  // SAMD21 has 64-byte pages

// ============================================================================
// USB SUPPORT
// ============================================================================

#ifdef HAL_USE_USB
  #define HAL_USB_ENABLED       1
  // USB VID/PID (use Arduino Zero defaults or custom)
  #define USB_VID               0x2341
  #define USB_PID               0x804D
#endif

// ============================================================================
// PLATFORM-SPECIFIC FUNCTIONS
// ============================================================================

// Platform initialization
void hal_system_init(void);

// Clock configuration (48 MHz from DFLL48M)
void hal_clock_config(void);

// GPIO initialization
void hal_gpio_init(void);

// Timer functions
uint32_t hal_millis(void);
uint64_t hal_micros(void);

#endif // PLATFORM_SAMD21_H
