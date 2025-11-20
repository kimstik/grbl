/*
  platform.h - SAMD21/ATSAMC21 platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for SAMD21G18A / ATSAMC21E18A-MZ.
  ARM Cortex-M0+, 48 MHz, 32KB RAM, 256KB Flash
  Target: MegARM board - https://github.com/kimstik/MegARM
*/

#ifndef PLATFORM_SAMD21_H
#define PLATFORM_SAMD21_H

#include <stdint.h>

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

// PLATFORM_NAME is defined in hal.h as "SAMD21"
// Board-specific name for reference
#define PLATFORM_BOARD_NAME     "ATSAMC21E18A-MZ (MegARM)"
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
// TYPE DEFINITIONS (must be before hal_gpio.h include)
// ============================================================================

// Define hal_gpio_port_t before hal_gpio.h includes it
// For SAMD21: port ID is an integer (0 = PORT_GROUPA, 1 = PORT_GROUPB)
typedef uint32_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// ============================================================================
// SAMD21 INCLUDES
// ============================================================================

#include "samd21.h"
#include "core_cm0plus.h"

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS
// ============================================================================

/*
  ATSAMC21E18A-MZ / SAMD21G18A Pin Mapping for GRBL (MegARM Layout):
  Target: MegARM - ATmega328P replacement board
  Reference: https://github.com/kimstik/MegARM

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
    RX    → PA23 (D0 - SERCOM3 PAD[1])
    TX    → PA24 (D1 - SERCOM3 PAD[2])

  Debug (B6, B7):
    SWCLK → PA30 (B6 - SWD Clock)
    SWDIO → PA31 (B7 - SWD Data)
*/

// --------------------------------------------------------------------------
// DIRECTION PINS (Port A: PA0, PA1, PA2)
// --------------------------------------------------------------------------

#define DIRECTION_PORT      PORT_GROUPA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)PORT_GROUPA)
#define DIRECTION_DDR       DIRECTION_PORT_ID  // DDR alias for AVR compatibility
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
#define STEP_PORT_ID        ((hal_gpio_port_t)PORT_GROUPA)
#define STEP_DDR            STEP_PORT_ID  // DDR alias for AVR compatibility
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
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define STEPPERS_DISABLE_DDR    STEPPERS_DISABLE_PORT_ID  // DDR alias for AVR compatibility
#define STEPPERS_DISABLE_PIN    3   // PA3 (B0)
#define STEPPERS_DISABLE_BIT    3
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (Port A: PA4, PA5, PA7)
// --------------------------------------------------------------------------

#define X_LIMIT_PORT        PORT_GROUPA
#define X_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define X_LIMIT_PIN         4   // PA4 (B1)
#define X_LIMIT_BIT         4

#define Y_LIMIT_PORT        PORT_GROUPA
#define Y_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define Y_LIMIT_PIN         5   // PA5 (B2)
#define Y_LIMIT_BIT         5

#define Z_LIMIT_PORT        PORT_GROUPA
#define Z_LIMIT_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define Z_LIMIT_PIN         7   // PA7 (B4)
#define Z_LIMIT_BIT         7

// For mask operations (all on Port A)
#define LIMIT_MASK_A        ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))
#define LIMIT_MASK_B        0

// --------------------------------------------------------------------------
// CONTROL PINS (Port A: PA14, PA15, PA16)
// --------------------------------------------------------------------------

#define CONTROL_RESET_PORT        PORT_GROUPA
#define CONTROL_RESET_PORT_ID     ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_RESET_PIN         14  // PA14 (C0)
#define CONTROL_RESET_BIT         14

#define CONTROL_FEED_HOLD_PORT    PORT_GROUPA
#define CONTROL_FEED_HOLD_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_FEED_HOLD_PIN     15  // PA15 (C1)
#define CONTROL_FEED_HOLD_BIT     15

#define CONTROL_CYCLE_START_PORT  PORT_GROUPA
#define CONTROL_CYCLE_START_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_CYCLE_START_PIN   16  // PA16 (C2)
#define CONTROL_CYCLE_START_BIT   16

#define CONTROL_SAFETY_DOOR_PORT  PORT_GROUPA
#define CONTROL_SAFETY_DOOR_PORT_ID ((hal_gpio_port_t)PORT_GROUPA)
#define CONTROL_SAFETY_DOOR_PIN   15  // PA15 (C1 - shared with FEED_HOLD)
#define CONTROL_SAFETY_DOOR_BIT   15

#define CONTROL_MASK_A      ((1<<CONTROL_RESET_PIN)|(1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN))
#define CONTROL_MASK_B      0
#define CONTROL_INVERT_MASK (CONTROL_MASK_A)

// --------------------------------------------------------------------------
// PROBE PIN (Port A: PA19)
// --------------------------------------------------------------------------

#define PROBE_PORT          PORT_GROUPA
#define PROBE_PORT_ID       ((hal_gpio_port_t)PORT_GROUPA)
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

// Using SERCOM3 for UART (PA23=RX, PA24=TX)
#define GRBL_SERCOM             SERCOM3
#define GRBL_SERCOM_IRQn        SERCOM3_IRQn
#define GRBL_SERCOM_IRQHandler  SERCOM3_Handler

// Pin mux for UART
#define UART_RX_PIN             23  // PA23 (D0)
#define UART_TX_PIN             24  // PA24 (D1)
#define UART_RX_PAD             1   // SERCOM PAD[1]
#define UART_TX_PAD             2   // SERCOM PAD[2]

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
// HAL GPIO MACROS
// ============================================================================

// Override generic hal_gpio.h macros with platform-specific 2-argument versions
#define HAL_GPIO_READ_PORT(port, mask)          (hal_gpio_read_port(port) & (mask))
#define HAL_GPIO_WRITE_PORT(port, mask, value)  hal_gpio_write_port(port, mask, value)

// ============================================================================
// HAL TIMER MACROS
// ============================================================================

// Stepper timer macros (TC3)
#define HAL_TIMER_STEPPER_INIT()              hal_stepper_timer_init()
#define HAL_TIMER_STEPPER_START()             hal_stepper_timer_start()
#define HAL_TIMER_STEPPER_STOP()              hal_stepper_timer_stop()
#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)  hal_stepper_timer_set_period(cycles)
#define HAL_TIMER_STEPPER_INTERRUPT_ENABLE()  (TC3->INTENSET = TC_INTFLAG_MC0)
#define HAL_TIMER_STEPPER_INTERRUPT_DISABLE() (TC3->INTENCLR = TC_INTFLAG_MC0)
#define HAL_TIMER_STEPPER_RESET_PRESCALER()   /* No prescaler reset needed */
#define HAL_TIMER_STEPPER_ISR()               void TC3_Handler(void)

// Pulse reset timer macros (TC4)
#define HAL_TIMER_PULSE_RESET_INIT()          hal_pulse_timer_init()
#define HAL_TIMER_PULSE_RESET_START()         (TC4->CTRLA |= TC_CTRLA_ENABLE)
#define HAL_TIMER_PULSE_RESET_STOP()          (TC4->CTRLA &= ~TC_CTRLA_ENABLE)
#define HAL_TIMER_PULSE_RESET_ISR()           void TC4_Handler(void)

// Spindle PWM timer macros
#define HAL_TIMER_SPINDLE_PWM_INIT()          hal_spindle_pwm_init()
#define HAL_TIMER_SPINDLE_PWM_ENABLE()        (TCC0->CTRLA |= TC_CTRLA_ENABLE)
#define HAL_TIMER_SPINDLE_PWM_DISABLE()       (TCC0->CTRLA &= ~TC_CTRLA_ENABLE)
#define HAL_TIMER_SPINDLE_PWM_IS_ENABLED()    (TCC0->CTRLA & TC_CTRLA_ENABLE)
#define HAL_TIMER_SPINDLE_PWM_SET(value)      hal_spindle_pwm_set(value)

// ============================================================================
// HAL GPIO INTERRUPT MACROS
// ============================================================================

// GPIO interrupt macros (simplified - actual implementation would use EIC)
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   /* TODO: Implement EIC */
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  /* TODO: Implement EIC */

// ============================================================================
// HAL DELAY MACROS
// ============================================================================

#define _delay_us(us)  hal_delay_us(us)

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
void hal_stepper_timer_init(void);
void hal_stepper_timer_start(void);
void hal_stepper_timer_stop(void);
void hal_stepper_timer_set_period(uint32_t period);
void hal_pulse_timer_init(void);
void hal_spindle_pwm_init(void);
void hal_spindle_pwm_set(uint16_t value);

// ============================================================================
// AVR COMPATIBILITY LAYER
// ============================================================================

// These are used by core GRBL code (limits.c, probe.c, system.c)
// Map AVR pin definitions to SAMD21 GPIO ports

// Limit switches
#define LIMIT_DDR     0      // Not used on ARM (DDR is for AVR only)
#define LIMIT_PORT    0      // Not used on ARM (PORT is for AVR pullup)
#define LIMIT_PCMSK   0      // Not used on ARM
#define LIMIT_INT     0      // Not used on ARM
#undef LIMIT_PIN
#define LIMIT_PIN     PORT_GROUPA  // Used for reading limit switches (redefine as PORT)
#define LIMIT_MASK    LIMIT_MASK_A // Combined mask for all limit pins

// Control pins
#define CONTROL_DDR   0      // Not used on ARM
#define CONTROL_PORT  0      // Not used on ARM
#define CONTROL_PCMSK 0      // Not used on ARM
#define CONTROL_INT   0      // Not used on ARM
#undef CONTROL_PIN
#define CONTROL_PIN   PORT_GROUPA  // Used for reading control pins (redefine as PORT)
#undef CONTROL_MASK
#define CONTROL_MASK  CONTROL_MASK_A // Combined mask for all control pins

// Probe pin
#define PROBE_DDR     0      // Not used on ARM
#define PROBE_PORT    0      // Not used on ARM
#undef PROBE_PIN
#define PROBE_PIN     PORT_GROUPA  // Used for reading probe pin (redefine as PORT)
#undef PROBE_MASK
#define PROBE_MASK    (1<<PROBE_BIT)  // Redefine using BIT instead of PIN

#endif // PLATFORM_SAMD21_H
