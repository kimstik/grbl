/*
  grbl_hal.h - Hardware Abstraction Layer for GRBL
  Part of Grbl

  Copyright (c) 2025 GRBL HAL Contributors

  Grbl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Grbl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Grbl.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
  GRBL Hardware Abstraction Layer (HAL)

  This HAL provides platform-independent interface for:
  - AVR ATmega328p (original, zero-overhead macros)
  - STM32F103 (ARM Cortex-M3, Blue Pill)
  - STM32F411 (ARM Cortex-M4F, Black Pill)
  - STM32H523 (ARM Cortex-M33, 250MHz!)
  - SAMD21 (ARM Cortex-M0+)
  - CH32V006 (RISC-V)
  - HC32F460 (ARM Cortex-M4F, 200MHz!)

  For AVR: All HAL macros expand to original code - ZERO overhead!
  For other platforms: HAL provides abstraction layer.
*/

#ifndef GRBL_HAL_H
#define GRBL_HAL_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// PLATFORM AUTO-DETECTION
// ============================================================================

// Platform can be specified via -DPLATFORM_xxx in Makefile
// Or auto-detected from compiler defines

#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
  #define PLATFORM_AVR_ATMEGA328P
  #define PLATFORM_NAME "AVR ATmega328P"

#elif defined(STM32F103xB) || defined(STM32F103x8)
  #define PLATFORM_STM32F103
  #define PLATFORM_NAME "STM32F103"

#elif defined(STM32F411xE) || defined(STM32F411xx)
  #define PLATFORM_STM32F411
  #define PLATFORM_NAME "STM32F411"

#elif defined(STM32H523xx) || defined(STM32H5)
  #define PLATFORM_STM32H523
  #define PLATFORM_NAME "STM32H523"

#elif defined(__SAMD21G18A__) || defined(__SAMD21__)
  #define PLATFORM_SAMD21
  #define PLATFORM_NAME "SAMD21"

#elif defined(CH32V00x) || defined(CH32V006)
  #define PLATFORM_CH32V006
  #define PLATFORM_NAME "CH32V006"

#elif defined(HC32F460) || defined(__HC32F460__)
  #define PLATFORM_HC32F460
  #define PLATFORM_NAME "HC32F460"

#else
  #error "Unknown platform! Define PLATFORM_xxx in Makefile"
#endif

// ============================================================================
// PLATFORM-SPECIFIC INCLUDES
// ============================================================================

#if defined(PLATFORM_AVR_ATMEGA328P)
  #include "platforms/avr_atmega328p/platform.h"

#elif defined(PLATFORM_STM32F103)
  #include "platforms/stm32f103/platform.h"

#elif defined(PLATFORM_STM32F411)
  #include "platforms/stm32f411/platform.h"

#elif defined(PLATFORM_STM32H523)
  #include "platforms/stm32h523/platform.h"

#elif defined(PLATFORM_SAMD21)
  #include "platforms/samd21/platform.h"

#elif defined(PLATFORM_CH32V006)
  #include "platforms/ch32v006/platform.h"

#elif defined(PLATFORM_HC32F460)
  #include "platforms/hc32f460/platform.h"
#endif

// ============================================================================
// HAL COMPONENT HEADERS
// ============================================================================

// Note: For AVR, most HAL macros are defined in platform.h
// But hal_nvmem.h contains eeprom_get_char/eeprom_put_char macros needed by all
#include "hal_nvmem.h"

// For other platforms, include additional component headers
#ifndef PLATFORM_AVR_ATMEGA328P
  #include "hal_system.h"
  #include "hal_gpio.h"
  #include "hal_timer.h"
  #include "hal_serial.h"
#endif

// ============================================================================
// PLATFORM CAPABILITIES (for compile-time feature detection)
// ============================================================================

// These are defined by platform headers
// #define HAL_HAS_FPU          0/1
// #define HAL_HAS_DMA          0/1
// #define HAL_HAS_USB          0/1
// #define HAL_HAS_HW_EEPROM    0/1

#endif // GRBL_HAL_H
