/*
  config.h - STM32F411 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef STM32F411_CONFIG_H
#define STM32F411_CONFIG_H

#include "../common/stm32/stm32_platform.h"

// STM32F411 PLATFORM CONFIGURATION

// Clock frequencies: HSE 25MHz -> PLL -> 96MHz CPU/AHB.
// APB1 prescaler /2 (max APB1 pclk is 50MHz on F411) -> APB1 pclk = 48MHz,
// but TIM2/TIM3 (APB1 timers) clock at 2x pclk = 96MHz whenever the APB1
// prescaler != /1 (RM0383 clock tree note) - so the stepper/pulse-reset
// timers still see the full 96MHz F_CPU, matching timer.h's comment.
// APB2 prescaler /1 (max APB2 pclk is 100MHz) -> APB2 pclk = 96MHz, so TIM1
// and USART1 (both APB2) also run at 96MHz.
#define STM32F411_CPU_FREQ      96000000UL
#define STM32F411_APB1_FREQ     48000000UL
#define STM32F411_APB2_FREQ     96000000UL

// Flash geometry: F4 sector erase, not F1/H5 page erase (see platform.h's
// HAL_NVMEM_FLASH_* comment for the cache_buffer[4096] sizing rationale -
// this logical window is intentionally smaller than the real 128KB sector).
#define STM32F411_FLASH_PAGE_SIZE   4096
#define STM32F411_FLASH_BASE_ADDR   0x08060000  // Start of sector 7 (last 128KB sector)
#define STM32F411_FLASH_NUM_PAGES   1

// Memory sizes
#define STM32F411_RAM_SIZE      131072   // 128KB
#define STM32F411_FLASH_SIZE    524288   // 512KB

// Hardware capabilities
#define STM32F411_HAS_FPU           true    // Cortex-M4F, fpv4-sp-d16
#define STM32F411_HAS_32BIT_TIMERS  true    // TIM2/TIM5 are 32-bit on F411
#define STM32F411_GPIO_MODEL        2       // F4 uses MODER/OTYPER (like H5)

// PIN MAPPING (mirrors platform.h - see that file's dual-canon note; do NOT
// redefine SPINDLE_PWM_MAX_VALUE here, it is canonical in platform.h only)

#define X_STEP_PIN          0   // PA0
#define Y_STEP_PIN          1   // PA1
#define Z_STEP_PIN          2   // PA2
#define X_DIRECTION_PIN     3   // PA3
#define Y_DIRECTION_PIN     4   // PA4
#define Z_DIRECTION_PIN     5   // PA5
#define STEPPERS_DISABLE_PIN 6  // PA6 (active LOW)

#define X_LIMIT_PIN         0   // PB0
#define Y_LIMIT_PIN         1   // PB1
#define Z_LIMIT_PIN         10  // PB10

#define RESET_PIN           3   // PB3
#define FEED_HOLD_PIN       4   // PB4
#define CYCLE_START_PIN     5   // PB5
#define SAFETY_DOOR_PIN     6   // PB6

#define SPINDLE_ENABLE_PIN      12  // PB12
#define SPINDLE_PWM_PIN         8   // PA8 (TIM1 CH1)
#define SPINDLE_DIRECTION_PIN   13  // PB13

#define COOLANT_FLOOD_PIN   13  // PC13
#define COOLANT_MIST_PIN    14  // PC14 (optional, ENABLE_M7)

#define SERIAL_TX_PIN       9   // PA9
#define SERIAL_RX_PIN       10  // PA10

#define PROBE_PIN           15  // PC15

// BITMASKS FOR GPIO OPERATIONS

#define STEP_MASK           ((1 << X_STEP_PIN) | (1 << Y_STEP_PIN) | (1 << Z_STEP_PIN))
#define DIRECTION_MASK      ((1 << X_DIRECTION_PIN) | (1 << Y_DIRECTION_PIN) | (1 << Z_DIRECTION_PIN))
#define STEPPERS_DISABLE_MASK (1 << STEPPERS_DISABLE_PIN)
#define LIMIT_MASK          ((1 << X_LIMIT_PIN) | (1 << Y_LIMIT_PIN) | (1 << Z_LIMIT_PIN))
#define CONTROL_MASK        ((1 << RESET_PIN) | (1 << FEED_HOLD_PIN) | (1 << CYCLE_START_PIN) | (1 << SAFETY_DOOR_PIN))
#define PROBE_MASK          (1 << PROBE_PIN)

// TIMER CONFIGURATION

#define STEPPER_TIMER_IRQn  TIM2_IRQn
#define PULSE_TIMER_IRQn    TIM3_IRQn

// Spindle PWM: TIM1 CH1. SPINDLE_PWM_MAX_VALUE is NOT redefined here - it is
// canonically defined in platform.h (255, CONTRACTS.md section 6.2: core
// plumbs duty as uint8_t end-to-end). A value here would shadow platform.h's
// 255 (config.h is included after platform.h in platform.c) exactly the way
// the stm32f103/stm32h523 "duty-cap twins" bug happened (PLAN.md commits
// 6e75218/5a56a5a) - do not reintroduce this definition here.

// SERIAL CONFIGURATION

#define SERIAL_BAUD_RATE    115200

#endif // STM32F411_CONFIG_H
