/*
  platform.h - dsPIC33AK128MC102 chip-specific HAL
  Part of Grbl

  THE THIRD ISA FAMILY: dsPIC33A 32-bit DSC core (Microchip) - neither ARM
  nor RISC-V. 200 MHz, dual-precision hardware FPU, hardware multiply/
  divide. Phase 6 rolling port #2, M1-M3 batch: identification, clock,
  GPIO, interrupt-global-control and critical sections are REAL; timers/
  serial/nvmem/CN-interrupt arming are PORT_TODO_* (Steps 3-6, next batch).

  Chip facts in this file come from the Apache-2.0 DFP
  (Microchip.dsPIC33AK-MC_DFP 1.5.263: p33AK128MC102.h SFR set,
  p33AK128MC102.gld memory map) and from toolchain-disassembly evidence
  gathered this session; anything not verifiable from those is marked
  UNVERIFIED loudly.
*/

#ifndef PLATFORM_DSPIC33AK128MC102_H
#define PLATFORM_DSPIC33AK128MC102_H

#include <xc.h>
#include <stdint.h>
#include "timer.h"

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

// hal.h pre-defines PLATFORM_NAME before including this file; refine it
// here the same way stm32f103/ch32v006 do.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "dsPIC33AK128MC102"
#define PLATFORM_CPU      "dsPIC33A 32-bit DSC (DP-FPU)"
#define PLATFORM_ARCH     "dsPIC33A"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define PLATFORM_HAS_FPU           1   // dual-precision hardware FPU (first port with one that is not ARM)
#define PLATFORM_HAS_DMA           1   // 6-channel DMA (unused by this port)
#define PLATFORM_HAS_USB           0
#define PLATFORM_HAS_HW_EEPROM     0   // flash emulation via nvmem.c (CONTRACTS.md #10) - Step 5
#define PLATFORM_HAS_HW_MULTIPLY   1
#define PLATFORM_HAS_HW_DIVIDE     1

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

// F_CPU feeds TICKS_PER_MICROSECOND (nuts_bolts.h) and all stepper timing
// math (PORTING-CHECKLIST Step 1). Clock path: FRC 8 MHz -> PLL1
// (FBDIV 200 / PRE 1 / POSTDIV1 4 / POSTDIV2 2 = 200 MHz) -> CLKGEN1
// NOSC=5 (see platform.c hal_clock_config). UNVERIFIED ON SILICON - and
// NOTE for Step 3: on dsPIC33A the CPU clock (CLKGEN1) and the peripheral
// clock generators are SEPARATE clock generators; which CLKGEN feeds
// Timer1/SCCP/UART1 and at what ratio is NOT yet verified - the stepper-
// timer tick MUST be re-derived against the RM before Step 3 encodes any
// period math (the "F_CPU lie" class, CONTRACTS.md #14.9).
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

#define RAM_SIZE          16384       // 16 KB  (DFP .gld: data ORIGIN 0x4000, LENGTH 0x4000)
#define FLASH_SIZE        131072      // 128 KB (DFP .gld: reset+program = 0x800000..0x820000)
#define HAL_EEPROM_SIZE   0           // no hardware EEPROM

// NVMEM flash-emulation window (Step 5, next batch): dsPIC33A program
// flash erase granularity (page size) and the NVMCON/NVMKEY command
// sequence are NOT yet mined from the RM - do not size the window until
// they are (the stm32h523 cache-overflow lesson, CONTRACTS.md #15.4).

// ============================================================================
// TYPE DEFINITIONS (must be before hal_gpio.h include)
// ============================================================================

// Port index (A=0..D=3) for the hal_gpio_* helpers - dsPIC33A GPIO
// registers are individual SFR symbols (LATA, LATB, ...), not struct
// pointers, so the "port handle" is an index into address tables in
// platform.c (the zero-cost ISR paths use token-pasted SFR names
// directly - gpio.h).
typedef uint32_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// ============================================================================
// GPIO INTERRUPTS (CONTRACTS.md #2) - PORT_TODO (Step 6, next batch)
// ============================================================================
// Target model (researched, not yet implemented): dsPIC33AK Change
// Notification, per-port - CNEN0x arms per-pin, CNCONx.ON+CNIE gate the
// port, vectors _CNAInterrupt (CONTROL) / _CNDInterrupt (LIMIT) are
// per-port so no shared-vector dispatch is needed (#2.5). Both macros are
// called REPEATEDLY at runtime (homing/settings writes - #2.1): arm/disarm
// via CNEN0x per-group mask, cheap and idempotent.

#define HAL_GPIO_INTERRUPT_ENABLE(port_idx, pcie, mask)   PORT_TODO_GPIO_INT_ON(port_idx, pcie, mask)
#define HAL_GPIO_INTERRUPT_DISABLE(port_idx, pcie, mask)  PORT_TODO_GPIO_INT_OFF(port_idx, pcie, mask)

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h is
// its single owner (CONTRACTS.md #2.2); a platform-local redefinition
// would be silently shadowed in every core TU.

// ============================================================================
// CRITICAL SECTIONS (CONTRACTS.md #8) - save/restore via XC-DSC builtins.
// ============================================================================
/*
  __builtin_get_isr_state() / __builtin_set_isr_state() /
  __builtin_disable_interrupts() are the vendor-blessed primitives;
  DISASSEMBLY-VERIFIED this session: get_isr_state packs SR.IPL[2:0]
  (bits 7:5) + INTCON1.GIE (the dsPIC33A global-interrupt-enable bit -
  this core HAS one, unlike classic 16-bit dsPIC33); disable_interrupts
  is a SINGLE `bclr.b INTCON1+1,#7` (interrupt-atomic); set_isr_state
  restores both fields. Save/restore, not blind disable/enable - the pair
  runs inside the RX ISR on the debug path (serial.c:153).

  The explicit ""::: "memory" asm is belt-and-braces compiler-barrier
  insurance: the XC16/XC-DSC manual documents the builtins as scheduling
  barriers, but that claim is not verifiable from disassembly alone
  (CONTRACTS.md #16 gap log) - an empty asm with a memory clobber costs
  zero instructions and closes the question.
*/
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint32_t __hal_isr_state_save = __builtin_get_isr_state(); \
  __builtin_disable_interrupts(); \
  __asm__ volatile ("" ::: "memory")

#define HAL_CRITICAL_SECTION_END() \
  __asm__ volatile ("" ::: "memory"); \
  __builtin_set_isr_state(__hal_isr_state_save)

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
// ============================================================================
// INTCON1.GIE, set/cleared by single interrupt-atomic bset/bclr via the
// builtins (verified by disassembly). Memory-clobber asm on the correct
// side of each transition: stores must not float below a cli() or above
// a sei() (#12.6).
#define sei()  do { __asm__ volatile ("" ::: "memory"); __builtin_enable_interrupts(); } while (0)
#define cli()  do { __builtin_disable_interrupts(); __asm__ volatile ("" ::: "memory"); } while (0)

// ============================================================================
// MEMORY BARRIERS (CONTRACTS.md #12) - dsPIC33A memory model
// ============================================================================
/*
  What barriers exist on this ISA: NONE. The dsPIC33A instruction set has
  no fence/DSB/DMB-class instruction at all (checked the DFP toolchain's
  full opcode table via objdump and the instruction-set docs shipped with
  XC-DSC). The architectural facts that stand in for them:
    - single core, single bus master (DMA unused by this port), no cache;
    - loads/stores complete in program order (in-order DSC pipeline);
    - the COMPILER is the only reordering agent - so __DMB/__DSB reduce
      to compiler barriers, which is exactly what the ring-buffer publish
      (#12.1) and flash-commit (#12.4) contracts need on this chip;
    - SFR read-after-write pipeline hazards are handled BY THE COMPILER:
      xc-dsc inserts `neop` padding after SFR stores (visible in every
      disassembly this session) - not a porting obligation.
  UNVERIFIED residue (logged in CONTRACTS.md #16): the RM's word on
  write-buffer behavior for NVM controller commands - Step 5 must check
  whether NVMCON command sequencing needs an explicit SFR readback (the
  classic PIC idiom) rather than trusting store order.
*/
#define __DSB() __asm__ volatile ("" ::: "memory")
#define __DMB() __asm__ volatile ("" ::: "memory")

// ============================================================================
// WATCHDOG (CONTRACTS.md #9)
// ============================================================================
// Deliberately UNDEFINED (only compiled under ENABLE_SOFTWARE_DEBOUNCE,
// default off) - a no-op here is ILLEGAL per contract when that option is
// on; leaving the macros absent gives a loud compile failure instead.
// Config-word note: platform.c sets `#pragma config FWDT_WDTEN = SW` so
// the hardware watchdog is OFF unless software enables it - an erased/
// default FWDT would otherwise let the WDT reset mid-run ("compiles but
// dead" class).

#endif // PLATFORM_DSPIC33AK128MC102_H
