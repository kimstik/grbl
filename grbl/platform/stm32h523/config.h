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
// PIN MAPPING
// ============================================================================
//
// BUG #25 (CONTRACTS.md #gpio-pin-map-single-owner): this file used to carry
// its own copy of every GPIO pin number (X_STEP_PIN, SPINDLE_ENABLE_PIN, ...)
// alongside platform.h's copy of the same names. The two disagreed for
// SPINDLE_ENABLE_PIN (7 here vs platform.h's 12), SPINDLE_DIRECTION_PIN (9
// vs 13) and COOLANT_FLOOD_PIN (0 vs 13) - and which one won depended on
// per-translation-unit include order: platform.c includes this file last, so
// it used to win there, except this port's hal_gpio_init() never actually
// consumed either macro (it hardcoded raw literals, e.g. `(1 << 7)` for
// SPINDLE_ENABLE) - see the fix in platform.c, now derived from platform.h's
// macros instead. Every core .c file (spindle_control.c, coolant_control.c,
// ...) reaches platform.h last through grbl.h, so platform.h's PB12/PB13/
// PC13 won there (the pins GPIO_BSET/GPIO_BCLR actually drive, via the
// *_BIT macros which were never split). Net effect: the spindle enable
// relay's pin was hardcoded as an output on PB7, which nothing ever wrote
// again, while the pin actually toggled (PB12) was never configured as an
// output at all. platform.h is now the SOLE owner of every GPIO pin/port/
// bit/mask this single-board port has - do not add a pin-number #define
// here. If this board ever needs a user-selectable pin map, that is a
// per-board config.h under boards/<name>/ selected via its own prelude.h
// (the samd21/ch32v006 pattern, CONTRACTS.md #boundary-wiring), not a second
// copy living beside platform.h's.

// Serial pins are documentation only here (the USART1 pin assignment is
// fixed by platform.h's HAL_SERIAL_* wiring, not read back from these
// macros) and LED_PIN is unused - no .c file in this port references either.
#define SERIAL_TX_PIN       9   // PA9 (or PB6 alternate)
#define SERIAL_RX_PIN       10  // PA10 (or PB7 alternate)
#define LED_PIN             7   // PB7 (green LED on Black Pill H5)

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

#endif // STM32H523_CONFIG_H
