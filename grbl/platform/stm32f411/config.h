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

// PIN MAPPING
//
// BUG #25 (CONTRACTS.md #gpio-pin-map-single-owner): this file used to carry
// a second copy of every GPIO pin number (X_STEP_PIN, SPINDLE_ENABLE_PIN,
// ...) alongside platform.h's copy of the same names. Unlike stm32f103/h523,
// every value here happened to numerically match platform.h's (this file's
// own previous header comment called it out: "mirrors platform.h"), so this
// port never shipped the live split-pin defect - but the duplication itself
// was the hazard: a hand-mirrored copy is exactly one unreviewed edit away
// from drifting out of sync the way f103/h523 already did, and the compiler
// silently accepts a redefinition whose value matches (no warning), so nothing
// would have caught it splitting again either. platform.h is now the SOLE
// owner of every GPIO pin/port/bit/mask this single-board port has - do not
// add a pin-number define here. If this board ever needs a user-selectable
// pin map, that is a per-board config.h under boards/<name>/ selected via its
// own prelude.h (the samd21/ch32v006 pattern, CONTRACTS.md
// #boundary-wiring), not a second copy living beside platform.h's.

// Serial pins are documentation only here (the USART1 pin assignment is
// fixed by platform.h's HAL_SERIAL_* wiring, not read back from these
// macros) - no .c file in this port references either.
#define SERIAL_TX_PIN       9   // PA9
#define SERIAL_RX_PIN       10  // PA10

// TIMER CONFIGURATION
//
// STEPPER_TIMER_IRQn / PULSE_TIMER_IRQn / SPINDLE_PWM_MAX_VALUE are NOT
// redefined here - they are canonically defined in platform.h (BUG #25;
// SPINDLE_PWM_MAX_VALUE specifically per CONTRACTS.md section 6.2: core
// plumbs duty as uint8_t end-to-end). A value here would shadow platform.h's
// inside platform.c ONLY (config.h is included after platform.h there)
// without touching any core .c file - exactly the stm32f103/stm32h523
// "duty-cap twins" mechanism (PLAN.md commits 6e75218/5a56a5a) and BUG #25's
// pin-map mechanism. Do not reintroduce any of these definitions here.

// SERIAL CONFIGURATION

#define SERIAL_BAUD_RATE    115200

#endif // STM32F411_CONFIG_H
