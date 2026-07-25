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

// ============================================================================
// BUILD PRELUDE CHECK (non-AVR platforms)
// ============================================================================
// Every non-AVR platform Makefile injects a build prelude into each
// translation unit via `-include <board>/prelude.h` (samd21) or
// `-include prelude.h` (stm32f103, stm32h523, sg2002); the prelude defines
// GRBL_PRELUDE. Compiling without it silently loses the injected macro chain
// (GPIO register accessors, board pin map, platform.h ordering), so fail
// loudly instead of mis-building:
#if !defined(__AVR__) && !defined(GRBL_PRELUDE)
  #error "No build prelude injected - build via the platform Makefile (it passes -include <board>/prelude.h); see grbl/platform/ARCHITECTURE.md"
#endif

// ============================================================================
// STANDARD LIBRARY INCLUDES (platform-specific)
// ============================================================================

#if defined(PLATFORM_STM32F103) || defined(PLATFORM_STM32H523) || defined(PLATFORM_RP2040) || defined(PLATFORM_RP2350)
  // ARM platforms: Include only standard C libraries
  #include <stdint.h>
  #include <stdbool.h>
  #include <string.h>
  #include <stdlib.h>
  #include <math.h>
  #include <inttypes.h>

  // Define AVR compatibility macros (to avoid modifying original code).
  // Guarded: the platform's own avr/io.h stub (pulled in by grbl.h BEFORE
  // this header) already defines sei()/cli() as CPSIE/CPSID inline asm and
  // owns those names. The fallbacks below only apply to a TU that includes
  // hal.h without grbl.h. (Note: HAL_INTERRUPTS_ENABLE/DISABLE currently
  // exist only in atmega328p/platform.h, so the fallback expansion is a
  // compile error if ever reached on ARM - better loud than silent.)
  #ifndef sei
    #define sei()  HAL_INTERRUPTS_ENABLE()
  #endif
  #ifndef cli
    #define cli()  HAL_INTERRUPTS_DISABLE()
  #endif
  #define __flash const  // AVR __flash (program memory) -> ARM const (in flash anyway)

#else
  // AVR platform: Include AVR-specific libraries
  #include <avr/io.h>
  #include <avr/pgmspace.h>
  #include <avr/interrupt.h>
  #include <avr/wdt.h>
  #include <util/delay.h>
  #include <math.h>
  #include <inttypes.h>
  #include <string.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <stdbool.h>
#endif

// ============================================================================
// PLATFORM AUTO-DETECTION
// ============================================================================

// Platform can be specified via -DPLATFORM_xxx in Makefile
// Or auto-detected from compiler defines

// Check explicit platform defines first (from Makefile)
#if defined(PLATFORM_STM32F103)
  #define PLATFORM_NAME "STM32F103"

#elif defined(PLATFORM_STM32H523)
  #define PLATFORM_NAME "STM32H523"

#elif defined(PLATFORM_STM32F411)
  #define PLATFORM_NAME "STM32F411"

#elif defined(PLATFORM_RP2040)
  #define PLATFORM_NAME "RP2040"

#elif defined(PLATFORM_RP2350)
  #define PLATFORM_NAME "RP2350"

#elif defined(PLATFORM_SAMD21)
  #define PLATFORM_NAME "SAMD21"

#elif defined(PLATFORM_CH32V006)
  #define PLATFORM_NAME "CH32V006"

#elif defined(PLATFORM_HC32F460)
  #define PLATFORM_NAME "HC32F460"

#elif defined(PLATFORM_SG2002)
  #define PLATFORM_NAME "Sophgo SG2002"

#elif defined(PLATFORM_TEMPLATE)
  #define PLATFORM_NAME "_template (copy-me starting point - not a real port)"

// Auto-detection from compiler defines
#elif defined(__AVR_ATmega328P__) || defined(__AVR_ATmega328__)
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
  #include "atmega328p/platform.h"

#elif defined(PLATFORM_STM32F103)
  #include "stm32f103/platform.h"

#elif defined(PLATFORM_STM32F411)
  #include "stm32f411/platform.h"

#elif defined(PLATFORM_STM32H523)
  #include "stm32h523/platform.h"

#elif defined(PLATFORM_SG2002)
  #include "sg2002/platform.h"

#elif defined(PLATFORM_SAMD21)
  #include "samd21/platform.h"

#elif defined(PLATFORM_TEMPLATE)
  #include "_template/platform.h"

#elif defined(PLATFORM_CH32V006)
  #include "ch32v006/platform.h"

#elif defined(PLATFORM_HC32F460)
  #include "hc32f460/platform.h"
#endif

// ============================================================================
// HAL COMPONENT HEADERS
// ============================================================================

#if !defined(__AVR_ATmega328P__)
// HAL component headers (all platforms)
//#include "hal_system.h"
#include "hal_timer.h"
//#include "hal_serial.h"
#endif

//#include "hal_nvmem.h"
#include "hal_gpio.h"

// ============================================================================
// PLATFORM CAPABILITIES (for compile-time feature detection)
// ============================================================================

// These are defined by platform headers
// #define HAL_HAS_FPU          0/1
// #define HAL_HAS_DMA          0/1
// #define HAL_HAS_USB          0/1
// #define HAL_HAS_HW_EEPROM    0/1

#endif // GRBL_HAL_H
