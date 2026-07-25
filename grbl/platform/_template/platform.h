/*
  platform.h - _template chip-specific HAL (copy-me starting point)
  Part of Grbl

  PORT-TODO: this whole file. Copy _template/ (see README.md), rename the
  include guard below, then work through PORTING-CHECKLIST.md in order.
  Ground truth for every contract cited here: grbl/platform/CONTRACTS.md.

  DESIGN: every macro this file cannot implement without knowing the real
  chip expands to a call to an undeclared PORT_TODO_<name>() function
  (grbl/platform/CONTRACTS.md, "the cautionary tale" - no silent no-op
  stubs, ever). Each .c file that uses one still compiles; the full port
  only links once every PORT_TODO_* symbol has a real definition. Undefined
  symbols at link time enumerate the remaining work BY NAME - that is the
  point of this design, not a bug to work around.
*/

#ifndef PLATFORM_TEMPLATE_H
#define PLATFORM_TEMPLATE_H

#warning "PORT-TODO: platform.h"

#include <stdint.h>
#include "timer.h"

// ============================================================================
// PLATFORM IDENTIFICATION - PORT-TODO: replace with your chip's real strings
// ============================================================================

#define PLATFORM_BOARD_NAME     "PORT-TODO board name"
#define PLATFORM_CPU            "PORT-TODO CPU core (e.g. ARM Cortex-M0+)"
#define PLATFORM_ARCH           "PORT-TODO architecture (ARM / RISC-V / ...)"

// ============================================================================
// PLATFORM CAPABILITIES - PORT-TODO: set to what your chip actually has
// ============================================================================

#define PLATFORM_HAS_FPU           0
#define PLATFORM_HAS_DMA           0
#define PLATFORM_HAS_USB           0
#define PLATFORM_HAS_HW_EEPROM     0   // 0 => nvmem.c must emulate in flash (CONTRACTS.md §10)
#define PLATFORM_HAS_HW_MULTIPLY   0
#define PLATFORM_HAS_HW_DIVIDE     0

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

// CPU_FREQ feeds TICKS_PER_MICROSECOND (nuts_bolts.h) and ALL stepper timing
// math. F_CPU comes from the Makefile's CLOCK variable (PORT-TODO there) -
// a lie here breaks every later porting step invisibly (PORTING-CHECKLIST
// Step 1). This _Static_assert only catches "nobody set it"; it cannot
// catch "set it to the wrong number" - verify against a scope/emulator.
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK))"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

// PORT-TODO: real numbers, informational only (not consumed by core logic)
#define RAM_SIZE          0       // bytes of SRAM
#define FLASH_SIZE        0       // bytes of flash
#define HAL_EEPROM_SIZE   0       // 0 = no hardware EEPROM (flash emulation via nvmem.c)

// ============================================================================
// TYPE DEFINITIONS (must be before hal_gpio.h include)
// ============================================================================

// Index type for the PORT_TODO_GPIO_* accessor arrays in gpio.h. Keep as a
// plain integer here; a real port may redefine to whatever its register
// struct pointer type is once GPIO_OREG/IREG/DREG/PREG stop being
// PORT_TODO stand-ins (gpio.h).
typedef uint32_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// ============================================================================
// GPIO INTERRUPTS (CONTRACTS.md §2)
// ============================================================================
/*
  GPIO_INT_ON/OFF are called REPEATEDLY at runtime (homing disables hard
  limits; settings writes re-enable them) - not just once at boot. A
  "handled at init only" implementation is ILLEGAL (limits.c:102-105): it
  would let homing trip its own hard-limit alarm. Context: init + main.
  pcmsk/interrupt/mask are forwarded verbatim from limits.c/system.c call
  sites; on most chips only `mask` (which pins) and `interrupt` (which
  IRQ/channel) end up mattering - `pcmsk` is an AVR-shaped leftover
  parameter every non-AVR platform ignores (see samd21/platform.h:175-176).
*/
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   PORT_TODO_GPIO_INT_ON(pcmsk, interrupt, mask)
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  PORT_TODO_GPIO_INT_OFF(pcmsk, interrupt, mask)

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here. hal_gpio.h is its
// single owner (`void <name>_IRQHandler(void)`) - a platform-local
// redefinition is shadowed in every core TU and only breaks the link if it
// ever wins (CONTRACTS.md §2.2; this bit us on SAMD21 once already).

// ============================================================================
// CRITICAL SECTIONS (CONTRACTS.md §8) - real implementation, not a PORT_TODO.
// ============================================================================
/*
  Save/restore PRIMASK, not blind disable/enable (contract: BEGIN...END runs
  inside the RX ISR on the debug path, serial.c:153 - an END that always
  re-enables interrupts would corrupt nesting). This is generic to every
  ARMv6-M/v7-M/v8-M core - PRIMASK exists on all of them - so unlike most of
  this file it needs no chip-specific data and ships working out of the box.
  "memory" clobber is mandatory: it is the compiler barrier that keeps
  stores from floating across the interrupt-enable boundary (CONTRACTS.md
  §12.6).
*/
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint32_t __hal_primask_save; \
  __asm volatile ("MRS %0, primask" : "=r" (__hal_primask_save)); \
  __asm volatile ("cpsid i" ::: "memory")

#define HAL_CRITICAL_SECTION_END() \
  __asm volatile ("MSR primask, %0" : : "r" (__hal_primask_save) : "memory")

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md §11) - real implementation.
// ============================================================================
#define sei()  __asm volatile ("cpsie i" ::: "memory")
#define cli()  __asm volatile ("cpsid i" ::: "memory")

// ============================================================================
// MEMORY BARRIERS (CONTRACTS.md §12) - real implementation, generic to every
// ARMv6-M+ core (DSB/DMB are baseline instructions, no chip data needed).
// ============================================================================
// Required: __DMB() between a ring buffer's data store and its index
// publish (§12.1, BUG #12 - serial.c uses this). Required: __DSB() between
// a flash page-buffer fill and the commit command (§12.4, BUG #13 -
// nvmem.c uses this), and between startup's .data-copy/.bss-zero/SystemInit
// phases (startup.c). If you later add a vendor CMSIS core_cmX.h, it
// defines these as real inline functions - delete this fallback then
// instead of carrying two definitions.
#ifndef __DSB
  #define __DSB() __asm volatile ("dsb 0xF" ::: "memory")
#endif
#ifndef __DMB
  #define __DMB() __asm volatile ("dmb 0xF" ::: "memory")
#endif

// ============================================================================
// WATCHDOG (CONTRACTS.md §9)
// ============================================================================
// Deliberately UNDEFINED. Only compiled under ENABLE_SOFTWARE_DEBOUNCE
// (default off) - contract says a no-op here is ILLEGAL when that option is
// on, so leaving the macros absent (loud compile failure if someone turns
// it on) is the correct move until you implement it properly. Do not add
// empty HAL_WATCHDOG_* stubs.

// PORT_TODO_GPIO_INT_ON/OFF above are deliberately NOT prototyped anywhere:
// an undeclared call is the whole mechanism (implicit-declaration warning
// at compile time via -Wall, undefined reference at link time) - adding a
// prototype would silence exactly the signal this design depends on.

#endif // PLATFORM_TEMPLATE_H
