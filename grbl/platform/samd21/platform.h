/*
  platform.h - SAMD21/ATSAMC21 platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

#ifndef PLATFORM_SAMD21_H
#define PLATFORM_SAMD21_H

#include <stdint.h>
#include "timer.h"

// PLATFORM IDENTIFICATION

// PLATFORM_NAME is defined in hal.h as "SAMD21"
// Board-specific name for reference
#define PLATFORM_BOARD_NAME     "ATSAMC21E18A-MZ (MegARM)"
#define PLATFORM_CPU      "ARM Cortex-M0+"
#define PLATFORM_ARCH     "ARM"

// PLATFORM CAPABILITIES
// TODO: HAL_HAS_* -> PLATFORM_HAS_*
// TODO: HAL_*     -> PLATFORM_*

#define PLATFORM_HAS_FPU           0   // Cortex-M0+ has no FPU (software emulation)
#define PLATFORM_HAS_DMA           1   // 12 DMA channels
#define PLATFORM_HAS_USB           1   // Native USB device
#define PLATFORM_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define PLATFORM_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define PLATFORM_HAS_HW_DIVIDE     1   // DIVAS - Division and Square Root Accelerator
#define PLATFORM_HAS_DIVAS         1   // Hardware 32-bit division, sqrt, modulo (1-3 cycles)

// PLATFORM SPECIFICATIONS

#ifndef CPU_FREQ
  #define CPU_FREQ        48000000UL  // 48 MHz
#endif

_Static_assert(CPU_FREQ % 3000000UL == 0, "DELAY_LOOP_ITERS_PER_US truncates: CPU_FREQ must be divisible by 3 MHz");

#define RAM_SIZE          32768       // 32 KB
#define FLASH_SIZE        262144      // 256 KB
// Capability flag, HAL_-prefixed like every other platform's. The bare name
// EEPROM_SIZE is owned by nvmem.c (bytes of flash reserved for EEPROM
// emulation, 4096) - a different quantity; the two used to collide here.
#define HAL_EEPROM_SIZE   0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   20      // 20.8 ns @ 48 MHz

// TYPE DEFINITIONS (must be before hal_gpio.h include)

// Define hal_gpio_port_t before hal_gpio.h includes it
// For SAMD21: port ID is an integer (0 = PORT_GROUPA, 1 = PORT_GROUPB)
typedef uint32_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// SAMD21 INCLUDES

#include "samd21.h"
#include "core_cm0plus.h"

// GRBL_BOOT_INIT - the anchor attribute on the pre-main init chain (BUG #23)
#include "common/boot_init.h"

// BOARD CONFIGURATION

/*
  Board-specific pin mappings are now in:
    boards/megarm/config.h   - MegARM board (ATSAMC21E18A-MZ)
    boards/generic/config.h  - Generic SAMD21 board

  To select board: make BOARD=megarm (default) or make BOARD=generic
  To create custom board: copy boards/generic to boards/yourboard and modify

  All pin definitions (X_STEP_PIN, Y_DIR_PIN, etc.) are in board config.
  This file (platform.h) contains only chip-specific HAL code.
*/


// CHIP-SPECIFIC PERIPHERAL CONFIGURATION

// Note: All pin mapping definitions moved to boards/*/config.h
// Board-specific: X_STEP_PIN, Y_DIRECTION_PIN, LIMIT_MASK_A, etc.

// Chip-specific peripheral IDs and IRQ handlers defined below

// FLASH EMULATION FOR EEPROM

// Use last 4KB of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   (0x00000000 + FLASH_SIZE - 4096)
#define HAL_NVMEM_FLASH_SIZE    4096
#define HAL_NVMEM_FLASH_PAGE_SIZE 64  // SAMD21 has 64-byte pages

// USB SUPPORT

#ifdef HAL_USE_USB
  #define HAL_USB_ENABLED       1
  // USB VID/PID (use Arduino Zero defaults or custom)
  #define USB_VID               0x2341
  #define USB_PID               0x804D
#endif

// TIMER MACROS - moved to timer.h
// Timer macros (STP_TMR_*, STP_PULSE_RESET_*, PWM_*, ISR_*) now in timer.h

// GPIO INTERRUPT MACROS - EIC (External Interrupt Controller)

// EIC initialization - must be called before enabling any GPIO interrupts
#define EIC_INIT() \
  do { \
    PM->APBAMASK |= PM_APBAMASK_EIC; \
    GCLK->CLKCTRL = (GCLK_CLKCTRL_ID_EIC << GCLK_CLKCTRL_ID_Pos) | \
                     GCLK_CLKCTRL_GEN_GCLK0 | GCLK_CLKCTRL_CLKEN; \
    while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY); \
    EIC->CTRL = 0; \
    while (EIC->STATUS & (1 << 7)); \
    EIC->CTRL = EIC_CTRL_ENABLE; \
    while (EIC->STATUS & (1 << 7)); \
  } while(0)

// Map pin to EIC channel: PA[n] -> EXTINT[n % 16] via PMUX Function A (0x0)
#define EIC_CHANNEL(pin_bit)  ((pin_bit) & 0xF)

// Configure pin for EIC interrupt (PMUX + PINCFG)
#define EIC_PIN_CONFIG(port, pin_bit) \
  do { \
    PORT->Group[port].PINCFG[pin_bit] = PORT_PINCFG_PMUXEN | PORT_PINCFG_INEN; \
    uint8_t pmux_idx = (pin_bit) >> 1; \
    if ((pin_bit) & 1) { \
      PORT->Group[port].PMUX[pmux_idx] = (PORT->Group[port].PMUX[pmux_idx] & 0x0F) | (0x0 << 4); \
    } else { \
      PORT->Group[port].PMUX[pmux_idx] = (PORT->Group[port].PMUX[pmux_idx] & 0xF0) | 0x0; \
    } \
  } while(0)

// Configure EIC channel for edge detection (BOTH edges for limits/control/probe)
#define EIC_CONFIG_CHANNEL(ch, sense) \
  do { \
    uint8_t cfg_idx = (ch) >> 3; \
    uint8_t bit_pos = ((ch) & 0x7) * 4; \
    EIC->CONFIG[cfg_idx] = (EIC->CONFIG[cfg_idx] & ~(0xF << bit_pos)) | \
                           ((sense) << bit_pos) | EIC_CONFIG_FILTEN(ch & 0x7); \
  } while(0)

// Enable/disable EIC interrupt for channel
#define EIC_INT_ENABLE(ch)      (EIC->INTENSET = (1 << (ch)))
#define EIC_INT_DISABLE(ch)     (EIC->INTENCLR = (1 << (ch)))

// Backward compatibility for base code (used in cpu_map.h)
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   /* Handled by EIC_INIT + pin setup */
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  /* Handled by EIC_INT_DISABLE */

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - platform/hal_gpio.h
// is its single owner and expands it to `void <name>_IRQHandler(void)`.
// handlers.c's EIC dispatcher declares and calls LIMIT_INT_IRQHandler /
// CONTROL_INT_IRQHandler by exactly that name; a platform-local redefinition
// (e.g. with a *_Handler suffix, as once lived here) is shadowed by
// hal_gpio.h in every core TU and would only break the link if it ever won.


// PLATFORM-SPECIFIC FUNCTIONS

// BOOT INIT (BUG #23). This port's 48MHz DFLL bring-up lives in
// startup.c::SystemInit() and is called from Reset_Handler before main() -
// core grbl/main.c is the golden gate and never calls platform init. That
// call is why samd21 was never hit by BUG #23 the way f103/f411/h523/
// hc32f460 were, and it is the precedent those four now follow.
//
// GRBL_BOOT_INIT (== noinline, common/boot_init.h) keeps SystemInit a real
// out-of-line symbol: with a single call site LTO used to inline it into
// Reset_Handler and drop the symbol entirely, so `nm` on the RELEASE ELF
// showed nothing - indistinguishable from the BUG #23 signature and
// unverifiable by common/init_check.sh. Must stay in sync with
// INIT_SYMBOLS in this port's Makefile.
//
// NOTE: platform.c used to ALSO carry a hal_clock_config() - a second,
// slightly different copy of this same DFLL sequence that nothing called.
// It was pure BUG #23 bait (defined, unreachable, LTO-stripped, free to
// drift out of sync with the copy that actually runs) and was deleted;
// SystemInit() below is the one and only clock bring-up on this port.
GRBL_BOOT_INIT void SystemInit(void);

// GPIO interrupt initialization (EIC setup for limits/control/probe)
void hal_gpio_interrupt_init(void);

// Timing functions
uint32_t hal_millis(void);
uint64_t hal_micros(void);

// AVR COMPATIBILITY LAYER

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
