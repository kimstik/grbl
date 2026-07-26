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
// PIN MAPPING
// ============================================================================
//
// BUG #25 (CONTRACTS.md #gpio-pin-map-single-owner): this file used to carry
// its own copy of every GPIO pin number (X_STEP_PIN, SPINDLE_ENABLE_PIN, ...)
// alongside platform.h's copy of the same names. The two disagreed for
// SPINDLE_ENABLE_PIN (7 here vs platform.h's 12), SPINDLE_DIRECTION_PIN (9
// vs 13) and COOLANT_FLOOD_PIN (0 vs 13) - and which one won depended on
// per-translation-unit include order: platform.c includes this file last, so
// it won there (hal_gpio_init configured PB7/PB9/PC0 as outputs); every core
// .c file (spindle_control.c, coolant_control.c, ...) reaches platform.h
// last through grbl.h, so platform.h's PB12/PB13/PC13 won there instead (the
// pins GPIO_BSET/GPIO_BCLR actually drive, via the *_BIT macros which were
// never split). Net effect: the spindle enable relay's pin was configured as
// an output on PB7, which is never written again, while the pin that is
// actually toggled (PB12) was never configured as an output at all - GRBL
// could set/clear the enable signal all day and no physical pin would move.
// platform.h is now the SOLE owner of every GPIO pin/port/bit/mask this
// single-board port has - do not add a pin-number #define here. If this
// board ever needs a user-selectable pin map, that is a per-board config.h
// under boards/<name>/ selected via its own prelude.h (the samd21/ch32v006
// pattern, CONTRACTS.md #boundary-wiring), not a second copy living beside
// platform.h's.

// Serial pins are documentation only here (the USART1 pin assignment is
// fixed by platform.h's HAL_SERIAL_* wiring, not read back from these
// macros) and LED_PIN is unused - no .c file in this port references either.
#define SERIAL_TX_PIN       9   // PA9
#define SERIAL_RX_PIN       10  // PA10
#define LED_PIN             13  // PC13 (built-in on Blue Pill, active LOW)

// ============================================================================
// TIMER CONFIGURATION
// ============================================================================
//
// STEPPER_TIMER_IRQn / PULSE_TIMER_IRQn / SPINDLE_PWM_MAX_VALUE are NOT
// redefined here - they are canonically defined in platform.h (BUG #25;
// SPINDLE_PWM_MAX_VALUE specifically per CONTRACTS.md section 6.2: core
// plumbs duty as uint8_t end-to-end). A value here would shadow platform.h's
// inside platform.c ONLY (config.h is included after platform.h there)
// without touching any core .c file - the exact split-brain mechanism BUG
// #25 fixed for the pin map. SPINDLE_PWM_MAX_VALUE was hit by precisely this
// once already (1000 here vs platform.h's 255, capping real spindle duty at
// 25.5% of commanded). Do not reintroduce any of these definitions here.

// ============================================================================
// SERIAL CONFIGURATION
// ============================================================================

#define SERIAL_BAUD_RATE    115200

#endif // STM32F103_CONFIG_H
