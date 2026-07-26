/*
  config.h - STM32F103 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Defines all STM32F103-specific parameters for the common code.
*/

#ifndef STM32F103_CONFIG_H
#define STM32F103_CONFIG_H

#include "../common/stm32/stm32_platform.h"

// ============================================================================
// STM32F103 PLATFORM CONFIGURATION
// ============================================================================

// Clock frequencies (72 MHz CPU, APB1=36MHz, APB2=72MHz)
#define STM32F103_CPU_FREQ      72000000UL
#define STM32F103_APB1_FREQ     36000000UL
#define STM32F103_APB2_FREQ     72000000UL

// Flash geometry (1KB pages)
#define STM32F103_FLASH_PAGE_SIZE   1024
#define STM32F103_FLASH_BASE_ADDR   0x0800F800  // Last 2KB (pages at 0x0800F800-0x0800FFFF)
#define STM32F103_FLASH_NUM_PAGES   2           // 2 x 1KB = 2KB for NVMEM

// Memory sizes
#define STM32F103_RAM_SIZE      20480   // 20KB
#define STM32F103_FLASH_SIZE    65536   // 64KB (some variants have 128KB)

// Hardware capabilities
#define STM32F103_HAS_FPU           false
#define STM32F103_HAS_32BIT_TIMERS  false   // Only 16-bit TIM2/TIM3/TIM4
#define STM32F103_GPIO_MODEL        1       // F1 family uses CRL/CRH registers

// ============================================================================
// PIN MAPPING (can be customized per project)
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
#define Z_LIMIT_PIN         2   // PB2 (BUG #26: moved off PB10 - see platform.h)

// Control pins (GPIOB)
#define RESET_PIN           3   // PB3
#define FEED_HOLD_PIN       4   // PB4
#define CYCLE_START_PIN     5   // PB5
#define SAFETY_DOOR_PIN     6   // PB6

// Spindle control (GPIOA/GPIOB)
#define SPINDLE_ENABLE_PIN      7   // PB7
#define SPINDLE_PWM_PIN         8   // PA8 (TIM1 CH1)
#define SPINDLE_DIRECTION_PIN   9   // PA9

// Coolant (GPIOC)
#define COOLANT_FLOOD_PIN   0   // PC0
#define COOLANT_MIST_PIN    1   // PC1 (optional, if ENABLE_M7)

// Serial (USART1)
#define SERIAL_TX_PIN       9   // PA9
#define SERIAL_RX_PIN       10  // PA10

// Debug LED
#define LED_PIN             13  // PC13 (built-in on Blue Pill, active LOW)

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

// Stepper timer: TIM2 (16-bit on F103)
#define STEPPER_TIMER_IRQn  TIM2_IRQn

// Pulse reset timer: TIM3
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

#endif // STM32F103_CONFIG_H
