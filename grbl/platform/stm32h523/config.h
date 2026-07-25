/*
  config.h - STM32H523 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  STM32H523CBT6: 250MHz Cortex-M33, 32KB RAM, 128KB Flash
*/

#ifndef STM32H523_CONFIG_H
#define STM32H523_CONFIG_H

#include "../common/stm32/stm32_platform.h"

// ============================================================================
// STM32H523 PLATFORM CONFIGURATION
// ============================================================================

// Clock frequencies (250 MHz CPU, APB1=125MHz, APB2=125MHz, APB3=125MHz)
#define STM32H523_CPU_FREQ      250000000UL
#define STM32H523_APB1_FREQ     125000000UL
#define STM32H523_APB2_FREQ     125000000UL

// Flash geometry (8KB pages)
#define STM32H523_FLASH_PAGE_SIZE   8192    // 8KB pages
#define STM32H523_FLASH_BASE_ADDR   0x0801E000  // Last 8KB (0x0801E000-0x0801FFFF)
#define STM32H523_FLASH_NUM_PAGES   1       // 1 x 8KB = 8KB for NVMEM

// Memory sizes
#define STM32H523_RAM_SIZE      32768   // 32KB SRAM
#define STM32H523_FLASH_SIZE    131072  // 128KB Flash

// Hardware capabilities
#define STM32H523_HAS_FPU           true    // Cortex-M33 has FPU
#define STM32H523_HAS_32BIT_TIMERS  true    // TIM2/TIM3/TIM4/TIM5 are 32-bit
#define STM32H523_GPIO_MODEL        2       // H5 uses MODER/OTYPER (like F4)

// ============================================================================
// PIN MAPPING (Black Pill H5 compatible)
// ============================================================================

// Stepper motors (GPIOA)
#define X_STEP_PIN          0   // PA0
#define Y_STEP_PIN          1   // PA1
#define Z_STEP_PIN          2   // PA2
#define X_DIRECTION_PIN     3   // PA3
#define Y_DIRECTION_PIN     4   // PA4
#define Z_DIRECTION_PIN     5   // PA5
#define STEPPERS_DISABLE_PIN 6  // PA6 (active LOW)

// Limit switches (GPIOB)
#define X_LIMIT_PIN         0   // PB0
#define Y_LIMIT_PIN         1   // PB1
#define Z_LIMIT_PIN         10  // PB10

// Control pins (GPIOB)
#define RESET_PIN           3   // PB3
#define FEED_HOLD_PIN       4   // PB4
#define CYCLE_START_PIN     5   // PB5
#define SAFETY_DOOR_PIN     6   // PB6

// Spindle control
#define SPINDLE_ENABLE_PIN      7   // PB7
#define SPINDLE_PWM_PIN         8   // PA8 (TIM1 CH1)
#define SPINDLE_DIRECTION_PIN   9   // PA9

// Coolant (GPIOC)
#define COOLANT_FLOOD_PIN   0   // PC0
#define COOLANT_MIST_PIN    1   // PC1

// Serial (USART1)
#define SERIAL_TX_PIN       9   // PA9 (or PB6 alternate)
#define SERIAL_RX_PIN       10  // PA10 (or PB7 alternate)

// LED (built-in on board)
#define LED_PIN             7   // PB7 (green LED on Black Pill H5)

// Probe
#define PROBE_PIN           15  // PC15

// ============================================================================
// BITMASKS FOR GPIO OPERATIONS
// ============================================================================

#define STEP_MASK           ((1 << X_STEP_PIN) | (1 << Y_STEP_PIN) | (1 << Z_STEP_PIN))
#define DIRECTION_MASK      ((1 << X_DIRECTION_PIN) | (1 << Y_DIRECTION_PIN) | (1 << Z_DIRECTION_PIN))
#define STEPPERS_DISABLE_MASK (1 << STEPPERS_DISABLE_PIN)
#define LIMIT_MASK          ((1 << X_LIMIT_PIN) | (1 << Y_LIMIT_PIN) | (1 << Z_LIMIT_PIN))
#define CONTROL_MASK        ((1 << RESET_PIN) | (1 << FEED_HOLD_PIN) | (1 << CYCLE_START_PIN) | (1 << SAFETY_DOOR_PIN))
#define PROBE_MASK          (1 << PROBE_PIN)

// ============================================================================
// TIMER CONFIGURATION
// ============================================================================

// Stepper timer: TIM2 (32-bit on H5)
#define STEPPER_TIMER_IRQn  TIM2_IRQn

// Pulse reset timer: TIM3 (32-bit)
#define PULSE_TIMER_IRQn    TIM3_IRQn

// Spindle PWM: TIM1 CH1
// SPINDLE_PWM_MAX_VALUE is NOT redefined here - it is canonically defined in
// platform.h (255, CONTRACTS.md section 6.2: core plumbs duty as uint8_t
// end-to-end). A value here previously shadowed platform.h's 255 with 1000
// (config.h is included after platform.h in platform.c), so TIM1's ARR ran
// to 1000 while CCR1 was only ever driven up to 255 - capping real spindle
// duty at 25.5% of commanded. Do not reintroduce this definition here.

// ============================================================================
// SERIAL CONFIGURATION
// ============================================================================

#define SERIAL_BAUD_RATE    115200

#endif // STM32H523_CONFIG_H
