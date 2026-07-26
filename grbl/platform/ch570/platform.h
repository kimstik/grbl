/*
  platform.h - CH570 chip-specific HAL
  Part of Grbl
*/

#ifndef PLATFORM_CH570_H
#define PLATFORM_CH570_H

#include <stdint.h>
#include "ch570.h"
#include "timer.h"

// GRBL_BOOT_INIT - the anchor attribute on the pre-main init chain (BUG #23)
#include "common/boot_init.h"

// PLATFORM IDENTIFICATION
#undef PLATFORM_NAME
#define PLATFORM_NAME     "CH570"
#define PLATFORM_CPU      "RISC-V RV32IMC (QingKe V3C)"
#define PLATFORM_ARCH     "RISC-V"

// PLATFORM CAPABILITIES
#define PLATFORM_HAS_FPU           0   // no FPU
#define PLATFORM_HAS_DMA           1   // TMR0/PWMX both have DMA channels (unused by this port)
#define PLATFORM_HAS_USB           1   // present on-chip (unused by this port)
#define PLATFORM_HAS_HW_EEPROM     0   // flash emulation via nvmem.c (CONTRACTS.md #10)
#define PLATFORM_HAS_HW_MULTIPLY   1   // RV32IMC has the M extension - real hw mul/div
#define PLATFORM_HAS_HW_DIVIDE     1

// PLATFORM SPECIFICATIONS
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

#define RAM_SIZE          12288       // 12 KB (datasheet SZ_RAM 0x3000)
#define FLASH_SIZE        245760      // 240 KB user code area (datasheet FLASH_ROM_MAX_SIZE)
#define HAL_EEPROM_SIZE   0           // no hardware EEPROM

// TYPE DEFINITIONS (must be before hal_gpio.h include). Single GPIO port
// on this chip - hal_gpio_port_t exists only so common/gpio.h's port-
// typed accessor pattern still compiles; every port macro resolves to the
// one real PA register set (gpio.h), the "port" argument is unused.
typedef uint8_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// FLASH EMULATION FOR EEPROM (nvmem.c) - last 4KB erase-sector of the
// 240KB user code area (PLAN.md recon: "4096-byte erase blocks", NOT
// ch32v006's 256B pages - materially different flash IP).
#define HAL_NVMEM_FLASH_SIZE       FLASH_BLOCK_SIZE          // 4096 (vendor/ISP572.h)
#define HAL_NVMEM_FLASH_START      (FLASH_USER_SIZE - HAL_NVMEM_FLASH_SIZE)
#define HAL_NVMEM_FLASH_PAGE_SIZE  FLASH_BLOCK_SIZE

// GPIO INTERRUPTS (CONTRACTS.md #2)
#define HAL_GPIO_INTERRUPT_ENABLE(port, pcie, mask)   hal_gpio_interrupt_enable((mask))
#define HAL_GPIO_INTERRUPT_DISABLE(port, pcie, mask)  hal_gpio_interrupt_disable((mask))
void hal_gpio_interrupt_enable(uint32_t mask);
void hal_gpio_interrupt_disable(uint32_t mask);

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h owns
// it exclusively (CONTRACTS.md #2.2).

// CRITICAL SECTIONS / sei() / cli() / MEMORY BARRIERS (CONTRACTS.md
// #8/#11/#12) - common/wch/wch_critical.h; see that file for why
// `mstatus` is correct on QingKe V3C too, not just V2C.
#include "../common/wch/wch_critical.h"

// WATCHDOG (CONTRACTS.md #9) - deliberately UNDEFINED, same rationale as
// ch32v006 (a no-op would be illegal under ENABLE_SOFTWARE_DEBOUNCE).

#endif // PLATFORM_CH570_H
