/*
  gpio.h - dsPIC33AK128MC102 GPIO register accessors and macro overrides
  Part of Grbl

  Injected by prelude.h BEFORE platform/common/gpio.h (that file only
  supplies AVR-style defaults for accessors not already defined -
  CONTRACTS.md #0). Composition contract (CONTRACTS.md #1): core calls
  GPIO_*(NAME); NAME##_PORT/_BIT/_MASK come from boards/<board>/config.h.

  HEADER PROVENANCE DECISION (vs the samd21 clean-room precedent): this
  port uses the DFP's own p33AK128MC102.h SFR declarations via <xc.h>.
  The samd21 port wrote clean-room register structs because Atmel/ASF
  headers carry a Microchip-proprietary license; the dsPIC33AK-MC DFP is
  explicitly Apache-2.0 (LICENSE.txt in the .atpack, "Copyright (c) 2026
  Microchip... Licensed under the Apache License, Version 2.0") - GPL-
  compatible, legally usable, and the DFP is ALSO the compiler's own
  -mdfp source of device truth. Re-deriving 38k lines of SFR addresses by
  hand would add transcription risk for zero legal gain.

  Register model (dsPIC33A GPIO, from the DFP header):
    LATx   - output latch (GPIO_OREG)
    PORTx  - input pins   (GPIO_IREG)
    TRISx  - direction, 1 = INPUT (INVERTED vs AVR DDR where 1 = output -
             the common/gpio.h DREG-based defaults would set direction
             BACKWARDS; every direction macro is overridden with a
             function call instead, stm32f103/ch32v006 precedent)
    ANSELx - analog select, resets to ANALOG on analog-capable pins; a
             digital input with ANSEL set reads 0 forever ("compiles but
             dead" class) - the hal_gpio_* helpers clear it on every
             direction config
    CNPUx  - pull-up enable, bit-per-pin (a REAL pull-up register - the
             samd21 PORT-CTRL mis-mapping (#1.4) cannot recur here)

  ATOMICITY (CONTRACTS.md #1.2) - measured, not assumed: xc-dsc-gcc 8.3.1
  compiles `LATB |= (1u<<3)` to a THREE-instruction load/bset-register/
  store sequence at -Og AND -Os (verified by disassembly this session) -
  the AVR single-SBI atomicity does NOT transfer, and dsPIC33A has no
  LATxSET/LATxCLR alias registers (grepped the DFP header). Consequences:
    - GPIO_BSET/GPIO_BCLR (STEPPERS_DISABLE/SPINDLE/COOLANT bits, written
      from BOTH mainline and st_go_idle() inside ISR_STEP) are wrapped in
      the save/restore critical section from platform.h.
    - GPIO_MWO (STEP/DIRECTION group writes) keeps the plain RMW formula:
      those groups are written ONLY from stepper ISRs and from init/reset
      paths with stepper interrupts off (core writer discipline, #1.2),
      and a mainline writer of the same LATx register cannot interrupt an
      ISR - while the wrapped GPIO_BSET above means the mainline writer
      itself cannot be torn by the ISR either. Both directions audited.
*/

#ifndef GPIO_DSPIC33AK128MC102_H
#define GPIO_DSPIC33AK128MC102_H

#include <xc.h>
#include <stdint.h>

// ----------------------------------------------------------------------------
// Token-pasting plumbing: boards define NAME##_PORT as a bare port letter
// (A/B/C/D); these two-level pastes turn (LAT, STEP_PORT) into LATB.
// ----------------------------------------------------------------------------

#define GPIO_SFR_I(reg, p)  reg##p
#define GPIO_SFR(reg, p)    GPIO_SFR_I(reg, p)

// Port letter -> index (for the function-call helpers in platform.c)
#define GPIO_PIDX_A 0
#define GPIO_PIDX_B 1
#define GPIO_PIDX_C 2
#define GPIO_PIDX_D 3
#define GPIO_PIDX_I(p)  GPIO_PIDX_##p
#define GPIO_PIDX(p)    GPIO_PIDX_I(p)

// ----------------------------------------------------------------------------
// Register accessors consumed by common/gpio.h compositions
// ----------------------------------------------------------------------------

#define GPIO_OREG(name)   GPIO_SFR(LAT,  name##_PORT)   // output latch
#define GPIO_IREG(name)   GPIO_SFR(PORT, name##_PORT)   // input pins

// No GPIO_DREG/GPIO_PREG - TRIS polarity is inverted vs AVR DDR and
// direction config must also clear ANSELx; see file header. Every macro
// that would touch them is overridden below with function calls.

void hal_gpio_set_output(uint32_t port_idx, uint32_t mask);
void hal_gpio_set_input(uint32_t port_idx, uint32_t mask);
void hal_gpio_pullup_enable(uint32_t port_idx, uint32_t mask);
void hal_gpio_pullup_disable(uint32_t port_idx, uint32_t mask);

// ----------------------------------------------------------------------------
// Single-bit data writes - critical-section wrapped (see ATOMICITY above).
// Statement contexts only (all core use sites are statements - CONTRACTS.md
// #1 table). HAL_CRITICAL_SECTION_* come from platform.h; prelude order
// guarantees they are defined before any core TU expands these.
// ----------------------------------------------------------------------------

#define GPIO_BSET(name)  do { HAL_CRITICAL_SECTION_BEGIN(); \
                              GPIO_OREG(name) |=  (1UL << (name##_BIT)); \
                              HAL_CRITICAL_SECTION_END(); } while (0)
#define GPIO_BCLR(name)  do { HAL_CRITICAL_SECTION_BEGIN(); \
                              GPIO_OREG(name) &= ~(1UL << (name##_BIT)); \
                              HAL_CRITICAL_SECTION_END(); } while (0)

// GPIO_MWO / GPIO_MRD: stock common/gpio.h formulas are correct on this
// board - STEP and DIRECTION are physically pins 0-2 of their ports, so
// logical == physical (BUG #17 contract satisfied by identity; see
// boards/generic/config.h header). Boards that scatter STEP/DIR pins must
// add per-NAME L2P/P2L dispatch here (samd21/gpio.h reference).

// ----------------------------------------------------------------------------
// Direction / pull-up configuration (init context only)
// ----------------------------------------------------------------------------

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_MDIR_OUT(name)     hal_gpio_set_output(GPIO_PIDX(name##_PORT), (name##_MASK))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(GPIO_PIDX(name##_PORT), (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(GPIO_PIDX(name##_PORT), (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(GPIO_PIDX(name##_PORT), (name##_MASK))

#endif // GPIO_DSPIC33AK128MC102_H
