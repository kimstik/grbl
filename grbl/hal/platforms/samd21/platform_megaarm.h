/*
  platform_megaarm.h - ATSAMC21E18A-MZ platform configuration (MegARM board)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for ATSAMC21E18A-MZ.
  ARM Cortex-M0+, 48 MHz, 32KB RAM, 256KB Flash
  Used in kimstik/MegARM board

  Pinout reference: https://github.com/kimstik/MegARM
*/

#ifndef PLATFORM_SAMD21_MEGAARM_H
#define PLATFORM_SAMD21_MEGAARM_H

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

#define PLATFORM_NAME     "ATSAMC21E18A-MZ (MegARM)"
#define PLATFORM_CPU      "ARM Cortex-M0+"
#define PLATFORM_ARCH     "ARM"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           0   // Cortex-M0+ has no FPU
#define HAL_HAS_DMA           1   // 12 DMA channels
#define HAL_HAS_USB           0   // ATSAMC21 doesn't have USB (use UART)
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define HAL_HAS_HW_DIVIDE     1   // Hardware divider
#define HAL_HAS_CAN           1   // CAN bus support

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
// ATSAMC21 INCLUDES
// ============================================================================

#include "samc21.h"
#include "core_cm0plus.h"

// ============================================================================
// PIN MAPPING - MegARM PINOUT
// ============================================================================

/*
  ATSAMC21E18A-MZ (MegARM board) Pin Mapping for GRBL:
  Source: https://github.com/kimstik/MegARM/blob/master/README.md

  Direction pins (D5, D6, D7):
    X_DIR    → PA0  (D5 - Port A, Pin 0)
    Y_DIR    → PA1  (D6 - Port A, Pin 1)
    Z_DIR    → PA2  (D7 - Port A, Pin 2)

  Step pins (D2, D3, D4):
    X_STEP   → PA25 (D2 - Port A, Pin 25)
    Y_STEP   → PA27 (D3 - Port A, Pin 27)
    Z_STEP   → PA28 (D4 - Port A, Pin 28)

  Stepper enable (B0):
    ENABLE   → PA3  (B0 - Port A, Pin 3)

  Limit switches (B1, B2, B4):
    X_LIMIT  → PA4  (B1 - Port A, Pin 4)
    Y_LIMIT  → PA5  (B2 - Port A, Pin 5)
    Z_LIMIT  → PA7  (B4 - Port A, Pin 7)

  Control pins (C0, C1, C2):
    RESET       → PA14 (C0 - Port A, Pin 14)
    FEED_HOLD   → PA15 (C1 - Port A, Pin 15) - shared with SAFETY_DOOR
    CYCLE_START → PA16 (C2 - Port A, Pin 16)
    SAFETY_DOOR → PA15 (C1 - same as FEED_HOLD)

  Spindle control (B3, B5):
    SPINDLE_PWM    → PA6  (B3 - Port A, Pin 6, TCC0/WO[0])
    SPINDLE_DIR    → PA8  (B5 - Port A, Pin 8)
    SPINDLE_ENABLE → PA8  (B5 - shared with DIR, use external logic)

  Coolant control (C3, C4):
    COOLANT_FLOOD → PA17 (C3 - Port A, Pin 17)
    COOLANT_MIST  → PA18 (C4 - Port A, Pin 18)

  Probe (C5):
    PROBE → PA19 (C5 - Port A, Pin 19)

  UART (Serial D0, D1):
    RX    → PA23 (D0 - SERCOM PAD[1])
    TX    → PA24 (D1 - SERCOM PAD[0])

  Debug (B6, B7):
    SWCLK → PA30 (B6 - SWD Clock)
    SWDIO → PA31 (B7 - SWD Data)
*/

// --------------------------------------------------------------------------
// DIRECTION PINS (Port A: PA0, PA1, PA2)
// --------------------------------------------------------------------------

#define DIRECTION_PORT      PORT_GROUPA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)&PORT->Group[0])
#define X_DIRECTION_PIN     0   // PA0 (D5)
#define Y_DIRECTION_PIN     1   // PA1 (D6)
#define Z_DIRECTION_PIN     2   // PA2 (D7)
#define X_DIRECTION_BIT     0
#define Y_DIRECTION_BIT     1
#define Z_DIRECTION_BIT     2
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

// --------------------------------------------------------------------------
// STEP PINS (Port A: PA25, PA27, PA28)
// --------------------------------------------------------------------------

#define STEP_PORT           PORT_GROUPA
#define STEP_PORT_ID        ((hal_gpio_port_t)&PORT->Group[0])
#define X_STEP_PIN          25  // PA25 (D2)
#define Y_STEP_PIN          27  // PA27 (D3)
#define Z_STEP_PIN          28  // PA28 (D4)
#define X_STEP_BIT          25
#define Y_STEP_BIT          27
#define Z_STEP_BIT          28
#define STEP_MASK           ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))

// --------------------------------------------------------------------------
// STEPPER ENABLE PIN (Port A: PA3)
// --------------------------------------------------------------------------

#define STEPPERS_DISABLE_PORT   PORT_GROUPA
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)&PORT->Group[0])
#define STEPPERS_DISABLE_PIN    3   // PA3 (B0)
#define STEPPERS_DISABLE_BIT    3
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (Port A: PA4, PA5, PA7)
// --------------------------------------------------------------------------

#define LIMIT_PORT          PORT_GROUPA
#define LIMIT_PORT_ID       ((hal_gpio_port_t)&PORT->Group[0])
#define X_LIMIT_PIN         4   // PA4 (B1)
#define Y_LIMIT_PIN         5   // PA5 (B2)
#define Z_LIMIT_PIN         7   // PA7 (B4)
#define X_LIMIT_BIT         4
#define Y_LIMIT_BIT         5
#define Z_LIMIT_BIT         7
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))

// --------------------------------------------------------------------------
// CONTROL PINS (Port A: PA14, PA15, PA16)
// --------------------------------------------------------------------------

#define CONTROL_PORT              PORT_GROUPA
#define CONTROL_PORT_ID           ((hal_gpio_port_t)&PORT->Group[0])
#define CONTROL_RESET_PIN         14  // PA14 (C0)
#define CONTROL_FEED_HOLD_PIN     15  // PA15 (C1)
#define CONTROL_CYCLE_START_PIN   16  // PA16 (C2)
#define CONTROL_SAFETY_DOOR_PIN   15  // PA15 (C1 - shared with FEED_HOLD)
#define CONTROL_RESET_BIT         14
#define CONTROL_FEED_HOLD_BIT     15
#define CONTROL_CYCLE_START_BIT   16
#define CONTROL_SAFETY_DOOR_BIT   15
#define CONTROL_MASK              ((1<<CONTROL_RESET_PIN)|(1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN))
#define CONTROL_INVERT_MASK       CONTROL_MASK

// --------------------------------------------------------------------------
// PROBE PIN (Port A: PA19)
// --------------------------------------------------------------------------

#define PROBE_PORT          PORT_GROUPA
#define PROBE_PORT_ID       ((hal_gpio_port_t)&PORT->Group[0])
#define PROBE_PIN           19  // PA19 (C5)
#define PROBE_BIT           19
#define PROBE_MASK          (1<<PROBE_PIN)

// --------------------------------------------------------------------------
// SPINDLE PINS (Port A: PA6, PA8)
// --------------------------------------------------------------------------

// Spindle PWM (PA6, TCC0/WO[0])
#define SPINDLE_PWM_PORT        PORT_GROUPA
#define SPINDLE_PWM_PIN         6   // PA6 (B3)
#define SPINDLE_PWM_BIT         6
#define SPINDLE_PWM_TCC         TCC0
#define SPINDLE_PWM_CHANNEL     0   // WO[0]
#define SPINDLE_PWM_PMUX        PORT_PMUX_PMUXE_E  // Function E

// Spindle direction (PA8 - shared with enable, use external logic if needed)
#define SPINDLE_DIRECTION_PORT  PORT_GROUPA
#define SPINDLE_DIRECTION_PIN   8   // PA8 (B5)
#define SPINDLE_DIRECTION_BIT   8

// Spindle enable (same pin as direction - external logic required)
#define SPINDLE_ENABLE_PORT     PORT_GROUPA
#define SPINDLE_ENABLE_PIN      8   // PA8 (B5)
#define SPINDLE_ENABLE_BIT      8

// PWM resolution (16-bit counter)
#ifdef VARIABLE_SPINDLE
  #define SPINDLE_PWM_MAX_VALUE     65535  // 16-bit PWM
  #define SPINDLE_PWM_MIN_VALUE     1
  #define SPINDLE_PWM_OFF_VALUE     0
  #define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)
#endif

// --------------------------------------------------------------------------
// COOLANT PINS (Port A: PA17, PA18)
// --------------------------------------------------------------------------

#define COOLANT_FLOOD_PORT      PORT_GROUPA
#define COOLANT_FLOOD_PIN       17  // PA17 (C3)
#define COOLANT_FLOOD_BIT       17

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     PORT_GROUPA
  #define COOLANT_MIST_PIN      18  // PA18 (C4)
  #define COOLANT_MIST_BIT      18
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

// Using SERCOM for UART (PA23=RX, PA24=TX)
#define GRBL_SERCOM             SERCOM3
#define GRBL_SERCOM_IRQn        SERCOM3_IRQn
#define GRBL_SERCOM_IRQHandler  SERCOM3_Handler

// Pin mux for UART
#define UART_RX_PIN             23  // PA23 (D0)
#define UART_TX_PIN             24  // PA24 (D1)
#define UART_RX_PAD             1   // SERCOM PAD[1]
#define UART_TX_PAD             0   // SERCOM PAD[0]

// ============================================================================
// FLASH EMULATION FOR EEPROM
// ============================================================================

// Use last 4KB of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   (0x00000000 + HAL_FLASH_SIZE - 4096)
#define HAL_NVMEM_FLASH_SIZE    4096
#define HAL_NVMEM_FLASH_PAGE_SIZE 64  // ATSAMC21 has 64-byte pages

// ============================================================================
// CAN BUS SUPPORT (Optional)
// ============================================================================

#ifdef HAL_USE_CAN
  #define HAL_CAN_ENABLED       1
  // CAN pins need to be defined based on MegARM schematic
#endif

// ============================================================================
// PLATFORM INFO STRUCTURE
// ============================================================================

extern const hal_platform_info_t samd21_platform_info;

const hal_platform_info_t* hal_platform_get_info(void);

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

#endif // PLATFORM_SAMD21_MEGAARM_H
