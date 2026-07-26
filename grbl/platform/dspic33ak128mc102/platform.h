/*
  platform.h - dsPIC33AK128MC102 chip-specific HAL
  Part of Grbl
*/

#ifndef PLATFORM_DSPIC33AK128MC102_H
#define PLATFORM_DSPIC33AK128MC102_H

#include <xc.h>
#include <stdint.h>
#include "timer.h"

// PPS OUTPUT FUNCTION-SELECT CODES - UNVERIFIED (CONTRACTS.md #16 new item)
// RPn INPUT muxing (RPINRx) is fully verified: the field IS the target
// RPn's own pin number (standard PPS input-mux convention, unchanged for
// decades of PIC24/dsPIC33). RPn OUTPUT muxing (RPORx) is the opposite
// direction - the field holds a small numeric FUNCTION code from a fixed
// per-device table (e.g. "this code = route U1TX here") - and that table
// is NOT present anywhere in the vendored DFP/.atdf (grepped: zero
// `RPOR*_RP*R` value-groups exist, unlike e.g. NVMCON_CON__NVMOP which
// does have one). These two placeholders are best-effort, clearly
// NON-authoritative, and MUST be verified against the datasheet's
// Peripheral Pin Select Output table before hardware bring-up trusts the
// UART TX line or the spindle PWM pin.
#define PPS_RPOR_FN_U1TX_UNVERIFIED   1
#define PPS_RPOR_FN_CCP2_UNVERIFIED   2

// PLATFORM IDENTIFICATION

// hal.h pre-defines PLATFORM_NAME before including this file; refine it
// here the same way stm32f103/ch32v006 do.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "dsPIC33AK128MC102"
#define PLATFORM_CPU      "dsPIC33A 32-bit DSC (DP-FPU)"
#define PLATFORM_ARCH     "dsPIC33A"

// PLATFORM CAPABILITIES

#define PLATFORM_HAS_FPU           1   // dual-precision hardware FPU (first port with one that is not ARM)
#define PLATFORM_HAS_DMA           1   // 6-channel DMA (unused by this port)
#define PLATFORM_HAS_USB           0
#define PLATFORM_HAS_HW_EEPROM     0   // flash emulation via nvmem.c (CONTRACTS.md #10) - Step 5
#define PLATFORM_HAS_HW_MULTIPLY   1
#define PLATFORM_HAS_HW_DIVIDE     1

// PLATFORM SPECIFICATIONS

// F_CPU feeds TICKS_PER_MICROSECOND (nuts_bolts.h) and all stepper timing
// math (PORTING-CHECKLIST Step 1). Clock path: FRC 8 MHz -> PLL1
// (FBDIV 200 / PRE 1 / POSTDIV1 4 / POSTDIV2 2 = 200 MHz) -> CLKGEN1
// NOSC=5 (see platform.c hal_clock_config). UNVERIFIED ON SILICON.
//
// Steps 3-6 UPDATE: the CLKGEN1 (CPU) vs peripheral-clock-generator split
// noted below is STILL UNVERIFIED (no RM vendored) - Timer1/SCCP1/SCCP2/
// UART1 period and baud math in timer.h/serial.c/platform.c all ASSUME
// their peripheral clock (Fp) equals F_CPU (CLKGEN1 output). This is the
// single biggest hardware-bring-up risk item in this port (CONTRACTS.md
// #16.10, #16 new items) - if Fp turns out to be a divided-down generator
// instead, every stepper/pulse/PWM/baud constant below needs rescaling,
// but the STRUCTURE (double-buffered period registers, row-programmed
// NVM, edge-style CN) does not change.
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real, verified clock frequency in Hz");

#define RAM_SIZE          16384       // 16 KB  (DFP .gld: data ORIGIN 0x4000, LENGTH 0x4000)
#define FLASH_SIZE        131072      // 128 KB (DFP .gld: reset+program = 0x800000..0x820000)
#define HAL_EEPROM_SIZE   0           // no hardware EEPROM

// NVMEM flash-emulation window (Step 5, real implementation - nvmem.c).
// Program-flash erase granularity IS in the vendored .atdf (unlike the
// RM-only facts above): FLASH_ERASE_PAGE_SIZE_IN_INSTRUCTIONS=1024 and
// FLASH_WRITE_ROW_SIZE_IN_INSTRUCTIONS=128 (dsPIC33AK128MC102.atdf, "nvm"
// module params) - on this ISA one "instruction" = 2 bytes of address
// space (classic dsPIC/PIC24 addressing; cross-checked against the .gld's
// byte-addressed 0x1F000-byte program region), so erase page = 2048
// bytes, program row = 256 bytes. The last erase page of program flash
// (0x81F800-0x820000) is reserved for NVMEM via a fixed-address object
// (nvmem.c) rather than editing the vendored .gld (link-tested this
// session: `__attribute__((address(0x81F800)))` places a static object
// there and links clean against the unmodified DFP script - ld would
// error loudly on any future collision with code growth, never silently
// corrupt).
#define HAL_NVMEM_FLASH_PAGE_SIZE   2048u   // erase granularity (atdf-derived, see nvmem.c)
#define HAL_NVMEM_FLASH_ROW_SIZE    256u    // row-program granularity (atdf-derived)
#define HAL_NVMEM_FLASH_START       0x81F800UL   // last page of program flash (0x800004+0x1FFFC region)

// TYPE DEFINITIONS (must be before hal_gpio.h include)

// Port index (A=0..D=3) for the hal_gpio_* helpers - dsPIC33A GPIO
// registers are individual SFR symbols (LATA, LATB, ...), not struct
// pointers, so the "port handle" is an index into address tables in
// platform.c (the zero-cost ISR paths use token-pasted SFR names
// directly - gpio.h).
typedef uint32_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// GPIO INTERRUPTS (CONTRACTS.md #2) - Step 6, real implementation.
// dsPIC33AK Change Notification, per-port: CNEN0x/CNEN1x arm per-pin
// (edge-style, both registers together = any-change trigger, #2.6),
// CNCONx.ON+CNSTYLE gate the port, vectors _CNAInterrupt (CONTROL) /
// _CNDInterrupt (LIMIT) are per-port so no shared-vector dispatch is
// needed (#2.5, boards/generic/config.h). Both macros are called
// REPEATEDLY at runtime (homing/settings writes - #2.1): hal_gpio_cn_*
// below only OR/AND per-pin enable bits - cheap and idempotent, matches
// contract. Implementation lives in platform.c (needs the CN register
// tables); port_idx comes from GPIO_PIDX() via board config (LIMIT_PCMSK/
// CONTROL_PCMSK), the middle "pcie" arg is unused on this platform (AVR
// PCIE-bit legacy parameter - stm32f103/ch32v006 precedent).

void hal_gpio_cn_enable(uint32_t port_idx, uint32_t mask);
void hal_gpio_cn_disable(uint32_t port_idx, uint32_t mask);

#define HAL_GPIO_INTERRUPT_ENABLE(port_idx, pcie, mask)   hal_gpio_cn_enable(port_idx, mask)
#define HAL_GPIO_INTERRUPT_DISABLE(port_idx, pcie, mask)  hal_gpio_cn_disable(port_idx, mask)

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h is
// its single owner (CONTRACTS.md #2.2); a platform-local redefinition
// would be silently shadowed in every core TU.

// CRITICAL SECTIONS (CONTRACTS.md #8) - save/restore via XC-DSC builtins.
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

// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11)
// INTCON1.GIE, set/cleared by single interrupt-atomic bset/bclr via the
// builtins (verified by disassembly). Memory-clobber asm on the correct
// side of each transition: stores must not float below a cli() or above
// a sei() (#12.6).
#define sei()  do { __asm__ volatile ("" ::: "memory"); __builtin_enable_interrupts(); } while (0)
#define cli()  do { __builtin_disable_interrupts(); __asm__ volatile ("" ::: "memory"); } while (0)

// MEMORY BARRIERS (CONTRACTS.md #12) - dsPIC33A memory model
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

// WATCHDOG (CONTRACTS.md #9)
// Deliberately UNDEFINED (only compiled under ENABLE_SOFTWARE_DEBOUNCE,
// default off) - a no-op here is ILLEGAL per contract when that option is
// on; leaving the macros absent gives a loud compile failure instead.
// Config-word note: platform.c sets `#pragma config FWDT_WDTEN = SW` so
// the hardware watchdog is OFF unless software enables it - an erased/
// default FWDT would otherwise let the WDT reset mid-run ("compiles but
// dead" class).

#endif // PLATFORM_DSPIC33AK128MC102_H
