/*
  platform.h - CH32V006 chip-specific HAL
  Part of Grbl
*/

#ifndef PLATFORM_CH32V006_H
#define PLATFORM_CH32V006_H

#include <stdint.h>
#include "ch32v006.h"
#include "timer.h"

// GRBL_BOOT_INIT - the anchor attribute on the pre-main init chain (BUG #23)
#include "common/boot_init.h"

// BUG #24: enables every GPIO port the board's *_PORT macros reference
// (platform.c) - must run before any GPIO_DIR_*/GPIO_MDIR_*/hal_gpio_config_pin
// call. Called from SystemInit() (startup.c).
GRBL_BOOT_INIT void hal_gpio_clock_init(void);

// PLATFORM IDENTIFICATION

// hal.h pre-defines PLATFORM_NAME "CH32V006" before including this file
// (grbl/platform/hal.h); refine it here the same way stm32f103/platform.h
// does.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "CH32V006"
#define PLATFORM_CPU      "RISC-V RV32EC (QingKe V2C)"
#define PLATFORM_ARCH     "RISC-V"

// PLATFORM CAPABILITIES

#define PLATFORM_HAS_FPU           0   // no FPU
#define PLATFORM_HAS_DMA           1   // DMA1, 7 channels (unused by this port)
#define PLATFORM_HAS_USB           0
#define PLATFORM_HAS_HW_EEPROM     0   // flash emulation via nvmem.c (CONTRACTS.md #10)
#define PLATFORM_HAS_HW_MULTIPLY   0   // rv32ec has no M extension
#define PLATFORM_HAS_HW_DIVIDE     0

// PLATFORM SPECIFICATIONS

// F_CPU feeds TICKS_PER_MICROSECOND (nuts_bolts.h) and all stepper timing
// math (PORTING-CHECKLIST Step 1). Clock path (TRM-verified this session):
// HSI 24 MHz (RM 3.3.2) -> fixed x2 PLL (RM clock tree) -> SYSCLK 48 MHz,
// HPRE cleared to /1 (its RESET value is /3! - see SystemClock_Config).
// Still not scope/emulator-verified on silicon - hardware validation item.
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

#define RAM_SIZE          8192        // 8 KB  (RM figure 1-8, TRM-verified)
#define FLASH_SIZE        63488       // 62 KB (pages 0-247 x 256B, TRM-verified)
#define HAL_EEPROM_SIZE   0           // no hardware EEPROM

// TYPE DEFINITIONS (must be before hal_gpio.h include)

typedef GPIO_TypeDef* hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// FLASH EMULATION FOR EEPROM (Step 5, nvmem.c)
// Last 1 KB of main flash (4 x 256B pages, pages 244-247). Addresses here
// are PHYSICAL (0x08xxxxxx) - the FLASH controller programs through the
// physical alias (RM 18.4.5). script.ld shortens its FLASH region to 61K
// so code can never grow into this window.

#define HAL_NVMEM_FLASH_SIZE       1024
#define HAL_NVMEM_FLASH_START      (FLASH_PHYS_BASE + FLASH_SIZE - HAL_NVMEM_FLASH_SIZE)
#define HAL_NVMEM_FLASH_PAGE_SIZE  FLASH_PAGE_SIZE_BYTES   // 256 (RM 18.1)

// GPIO INTERRUPTS (CONTRACTS.md #2) - real, runtime-callable (Step 6).
// GPIO_INT_ON/OFF are called REPEATEDLY at runtime (homing disables hard
// limits; settings writes re-enable them - #2.1). hal_gpio_interrupt_
// enable/disable (platform.c) are cheap, idempotent, and actually gate
// delivery via EXTI_INTENR per line. Signature plumbing: first argument
// is the GPIO port (boards define name_PCMSK as name_PORT), second is the
// unused AVR PCIE bit - f103 precedent.

#define HAL_GPIO_INTERRUPT_ENABLE(port, pcie, mask)   hal_gpio_interrupt_enable((port), (mask))
#define HAL_GPIO_INTERRUPT_DISABLE(port, pcie, mask)  hal_gpio_interrupt_disable((port), (mask))

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h is its
// single owner (CONTRACTS.md #2.2); a platform-local redefinition would be
// silently shadowed in every core TU.

// CRITICAL SECTIONS / sei() / cli() / MEMORY BARRIERS
// (CONTRACTS.md #8, #11, #12)
// EXTRACTED (Phase 6 rolling #4, Part A) to common/wch/wch_critical.h,
// verbatim - see that file for the full rationale (mstatus.MIE bit 3,
// Zicsr requirement, fence rw,rw semantics) and for why `mstatus` is the
// right primitive on every QingKe generation this tree ports, not just
// this one. QingKe note specific to THIS port: with INTSYSCR.INESTEN=0
// (see startup.c), core's sei() inside ISR_STEP (stepper.c:355) does NOT
// nest another interrupt into the running handler; delivery is deferred
// to handler exit - same accepted posture as the SAMD21 M0+ reference
// (CONTRACTS.md #5.2).
#include "../common/wch/wch_critical.h"

// WATCHDOG (CONTRACTS.md #9)
// Deliberately UNDEFINED (only compiled under ENABLE_SOFTWARE_DEBOUNCE,
// default off) - a no-op here is ILLEGAL per contract when that option is
// on; leaving the macros absent gives a loud compile failure instead.

#endif // PLATFORM_CH32V006_H
