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
#include "timer.h"

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
// TODO: HAL_HAS_* -> PLATFORM_HAS_*
// TODO: HAL_*     -> PLATFORM_*

#define PLATFORM_HAS_FPU           0   // Cortex-M0+ has no FPU (software emulation)
#define PLATFORM_HAS_DMA           1   // 12 DMA channels
#define PLATFORM_HAS_USB           1   // Native USB device
#define PLATFORM_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define PLATFORM_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define PLATFORM_HAS_HW_DIVIDE     1   // DIVAS - Division and Square Root Accelerator
#define PLATFORM_HAS_DIVAS         1   // Hardware 32-bit division, sqrt, modulo (1-3 cycles)

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#ifndef CPU_FREQ
  #define CPU_FREQ        48000000UL  // 48 MHz
#endif

#define RAM_SIZE          32768       // 32 KB
#define FLASH_SIZE        262144      // 256 KB
#define EEPROM_SIZE       0           // No hardware EEPROM

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
// BOARD CONFIGURATION
// ============================================================================

/*
  Board-specific pin mappings are now in:
    boards/megarm/config.h   - MegARM board (ATSAMC21E18A-MZ)
    boards/generic/config.h  - Generic SAMD21 board

  To select board: make BOARD=megarm (default) or make BOARD=generic
  To create custom board: copy boards/generic to boards/yourboard and modify

  All pin definitions (X_STEP_PIN, Y_DIR_PIN, etc.) are in board config.
  This file (platform.h) contains only chip-specific HAL code.
*/


// ============================================================================
// CHIP-SPECIFIC PERIPHERAL CONFIGURATION
// ============================================================================

// Note: All pin mapping definitions moved to boards/*/config.h
// Board-specific: X_STEP_PIN, Y_DIRECTION_PIN, LIMIT_MASK_A, etc.

// Chip-specific peripheral IDs and IRQ handlers defined below

// ============================================================================
// FLASH EMULATION FOR EEPROM
// ============================================================================

// Use last 4KB of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   (0x00000000 + FLASH_SIZE - 4096)
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
// TIMER MACROS - moved to timer.h
// ============================================================================
// Timer macros (STP_TMR_*, STP_PULSE_RESET_*, PWM_*, ISR_*) now in timer.h

// ============================================================================
// GPIO INTERRUPT MACROS
// ============================================================================

// ISSUE #4 (CRITICAL): GPIO interrupts NOT IMPLEMENTED!
// Hard limits won't trigger interrupts - must rely on polling (slow, unreliable)
// Control pins (reset, feed hold, cycle start) won't work as interrupts
// Probe detection may miss fast events
//
// TODO: Implement External Interrupt Controller (EIC):
// 1. Enable EIC clock: PM->APBAMASK |= PM_APBAMASK_EIC
// 2. Configure GCLK for EIC
// 3. Map pins to EIC channels via PMUX (Function A)
// 4. Configure EIC->CONFIG for edge/level detection
// 5. Enable interrupts: EIC->INTENSET
// 6. Implement EIC_Handler() ISR
//
// See SAMD21 datasheet section 21 (External Interrupt Controller)

// Backward compatibility for base code (used in cpu_map.h)
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   /* TODO: Implement EIC */
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  /* TODO: Implement EIC */
#define HAL_GPIO_IRQ_HANDLER(int_name)                      void int_name##_Handler(void)

// New short names (for future migration)
#define GPIO_INT_ENA(name)  /* TODO: Implement EIC for name */
#define GPIO_INT_DIS(name)  /* TODO: Implement EIC for name */
#define IRQ_HANDLER(name)   void name##_Handler(void)


// ============================================================================
// PLATFORM-SPECIFIC FUNCTIONS
// ============================================================================

// Clock configuration (48 MHz from DFLL48M)
void hal_clock_config(void);

// Timing functions
uint32_t hal_millis(void);
uint64_t hal_micros(void);

// ============================================================================
// AVR COMPATIBILITY LAYER
// ============================================================================

// SAMD21 ARM Cortex-M0+ interrupt control
// Use inline assembly for direct CPSIE/CPSID instructions
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

#define HAL_CRITICAL_SECTION_BEGIN()
#define HAL_CRITICAL_SECTION_END()




// ISSUE #12 (MODERATE): Confusing AVR compatibility definitions
// These macros define meaningless zero values that confuse readers
// They exist only to satisfy AVR-style code but serve no purpose on ARM
//
// Options:
// 1. Remove these entirely (best - requires fixing core GRBL to be platform-agnostic)
// 2. Add clear comments explaining they're dummy values
// 3. Use #ifdef PLATFORM_AVR guards in core GRBL code

// These are used by core GRBL code (limits.c, probe.c, system.c)
// Map AVR pin definitions to SAMD21 GPIO ports


// FIXME: what it is? it have to be no here, but in board config!! to trash it
// Limit switches (AVR compatibility - DDR/PCMSK/INT only)
#define LIMIT_DDR     0      // DUMMY: Not used on ARM (DDR is for AVR only)
#define LIMIT_PCMSK   0      // DUMMY: Not used on ARM (PCMSK is for AVR only)
#define LIMIT_INT     0      // DUMMY: Not used on ARM (INT is for AVR only)
#undef LIMIT_PIN
#define LIMIT_PIN     PORT_GROUPA  // Used for reading limit switches (redefine as PORT)
#define LIMIT_MASK    LIMIT_MASK_A // Combined mask for all limit pins

// Control pins (AVR compatibility - DDR/PCMSK/INT only)
#define CONTROL_DDR   0      // Not used on ARM
#define CONTROL_PCMSK 0      // Not used on ARM
#define CONTROL_INT   0      // Not used on ARM
#undef CONTROL_PIN
#define CONTROL_PIN   PORT_GROUPA  // Used for reading control pins (redefine as PORT)
#undef CONTROL_MASK
#define CONTROL_MASK  CONTROL_MASK_A // Combined mask for all control pins

// Probe pin (AVR compatibility - DDR only)
#define PROBE_DDR     0      // Not used on ARM
#undef PROBE_PIN
#define PROBE_PIN     PORT_GROUPA  // Used for reading probe pin (redefine as PORT)
#undef PROBE_MASK
#define PROBE_MASK    (1<<PROBE_BIT)  // Redefine using BIT instead of PIN

#endif // PLATFORM_SAMD21_H
