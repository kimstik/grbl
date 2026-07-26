/*
  gpio.h - SG2002 GPIO register accessors and macro overrides
  Part of Grbl

  Injected by prelude.h BEFORE platform/common/gpio.h (CONTRACTS.md #0) so
  these accessors win over that file's `#ifndef`-guarded AVR-shaped defaults.

  Three chip-shape facts drive everything here:

  1. FOUR BANKS, PORT-TYPED ACCESS. The DesignWare apb_gpio instantiation has
     four 32-pin banks at a regular stride, so `name##_PORT` is meaningful on
     this port (it is the bank index 0..3) and the accessors below are
     genuine functions of it - unlike ch570's single-port chip where the
     token is ignored.

  2. NO ATOMIC SET/CLEAR REGISTERS. DesignWare apb_gpio offers only
     SWPORTA_DR: every output change is a read-modify-write. CONTRACTS.md
     #1.2 is explicit that this is only acceptable if no two writers of the
     same physical register can preempt each other, and on this port they
     CAN: `st_go_idle()` runs inside ISR_STEP (stepper.c:401) and writes
     STEPPERS_DISABLE, while spindle_control.c/coolant_control.c write
     the SPINDLE_ and COOLANT_ bits from mainline - the same bank, the same DR
     register. §1.2's sanctioned remedy when hardware set/clear registers do
     not exist is a critical section, so every DR/DDR read-modify-write in
     this file goes through sg2002_gpio_rmw(), which brackets the update by
     saving and clearing mstatus.MIE. Cost is four instructions on a 700 MHz
     core; the ISR-hot budget (33.3 us) is untouched.

     Why the primitive is spelled out here instead of calling
     HAL_CRITICAL_SECTION_BEGIN/END: this file is injected FIRST in the
     prelude chain, before platform.h exists. Same instruction sequence,
     same register, same "memory" clobber - see platform.h.

  3. LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1). Core's step
     pipeline is a uint8_t port image. This board's STEP pins are physically
     bank-0 bits 8-10 and DIRECTION bank-0 bits 11-13 - past bit 7 on
     purpose, so the L2P/P2L machinery is genuinely exercised rather than
     carried unused. GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT dispatch per NAME
     (token-pasted; the dispatch itself costs nothing at runtime -
     samd21/gpio.h is the reference) into the board's L2P/P2L shifts.

     Input groups (LIMIT/CONTROL/PROBE) are deliberately kept in bits 0-7
     per #1.3 - core truncates those reads to uint8_t - so they need no
     translation and use the stock formula.
*/

#ifndef GPIO_SG2002_H
#define GPIO_SG2002_H

#include <stdint.h>
#include "sg2002.h"

// ----------------------------------------------------------------------------
// Register accessors consumed by common/gpio.h's compositions.
// `name##_PORT` is the DesignWare bank index.
// ----------------------------------------------------------------------------
#define GPIO_OREG(name)   SG2002_GPIO_SWPORTA_DR(name##_PORT)    // output data
#define GPIO_IREG(name)   SG2002_GPIO_EXT_PORTA(name##_PORT)     // pin level (read-only)
#define GPIO_DREG(name)   SG2002_GPIO_SWPORTA_DDR(name##_PORT)   // 1 = output

/*
  GPIO_PREG is deliberately LEFT AT common/gpio.h's default (`name##_PORT`)
  and never used: this IP has no pull-up register at all - pulls live in the
  SoC pad-control block, reached through the functions below. Leaving the
  default in place is not a silent no-op; it is a compile-time landmine on
  purpose. common/gpio.h's default pull-up macros expand to
  `BIT_SET(name##_PORT, bit)`, i.e. an assignment to an integer constant,
  which does not compile. Any future code path that reaches the generic
  pull-up formula instead of the overrides below therefore fails the build
  rather than quietly leaving inputs floating (CONTRACTS.md #1.4, the SAMD21
  gap this port must not reproduce).
*/

// ----------------------------------------------------------------------------
// Interrupt-safe read-modify-write for the shared DR/DDR registers (see the
// file header, point 2). Save/restore, never blind enable - this can be
// reached from inside an ISR (st_go_idle -> GPIO_BSET(STEPPERS_DISABLE)).
// ----------------------------------------------------------------------------
static inline void sg2002_gpio_rmw(volatile uint32_t *reg, uint32_t clr, uint32_t set) {
  uint64_t mstatus_save;
  __asm__ volatile ("csrr %0, mstatus" : "=r" (mstatus_save));
  __asm__ volatile ("csrci mstatus, 8" ::: "memory");
  *reg = (*reg & ~clr) | set;
  __asm__ volatile ("csrw mstatus, %0" : : "r" (mstatus_save) : "memory");
}

// ----------------------------------------------------------------------------
// Pull-ups (CONTRACTS.md #1.4) - real pad-block writes, implemented in
// platform.c. Declared with the concrete `uint8_t` bank type rather than the
// `hal_gpio_port_t` alias because this file is injected before platform.h
// declares that typedef; typedefs are aliases, not distinct types, so the
// later hal_gpio.h-shaped declaration is compatible.
// ----------------------------------------------------------------------------
void hal_gpio_pullup_enable(uint8_t bank, uint32_t mask);
void hal_gpio_pullup_disable(uint8_t bank, uint32_t mask);

#undef GPIO_PULLUP_EN
#undef GPIO_PULLUP_DIS
#undef GPIO_MPULLUP_EN
#undef GPIO_MPULLUP_DIS
#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable((name##_PORT), 1UL << (name##_BIT))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable((name##_PORT), 1UL << (name##_BIT))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable((name##_PORT), (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable((name##_PORT), (name##_MASK))

// ----------------------------------------------------------------------------
// Single-bit output and direction - critical-sectioned RMW (#1.2).
// ----------------------------------------------------------------------------
#undef GPIO_BSET
#undef GPIO_BCLR
#undef GPIO_DIR_OUT
#undef GPIO_DIR_INP
#define GPIO_BSET(name)    sg2002_gpio_rmw(&GPIO_OREG(name), 0UL, 1UL << (name##_BIT))
#define GPIO_BCLR(name)    sg2002_gpio_rmw(&GPIO_OREG(name), 1UL << (name##_BIT), 0UL)
#define GPIO_DIR_OUT(name) sg2002_gpio_rmw(&GPIO_DREG(name), 0UL, 1UL << (name##_BIT))
#define GPIO_DIR_INP(name) sg2002_gpio_rmw(&GPIO_DREG(name), 1UL << (name##_BIT), 0UL)

// ----------------------------------------------------------------------------
// Masked-group write with logical<->physical translation (BUG #17).
// GPIO_MWO is only ever called by core with STEP and DIRECTION (stepper.c);
// naming any other group here is a compile error rather than a silent
// fallthrough to the untranslated default, which is the point of the
// per-NAME dispatch.
// ----------------------------------------------------------------------------
#define GPIO_MWO(name, val)        GPIO_MWO_##name(val)
#define GPIO_MWO_STEP(val) \
  sg2002_gpio_rmw(&GPIO_OREG(STEP), STEP_MASK_PHYS, STEP_L2P(val) & STEP_MASK_PHYS)
#define GPIO_MWO_DIRECTION(val) \
  sg2002_gpio_rmw(&GPIO_OREG(DIRECTION), DIRECTION_MASK_PHYS, DIRECTION_L2P(val) & DIRECTION_MASK_PHYS)

// ----------------------------------------------------------------------------
// Masked reads. STEP reads back the commanded OUTPUT image (stepper.c:338,
// 340) and therefore needs P2L; the input groups are physical==logical.
// ----------------------------------------------------------------------------
#define GPIO_MRD(name, reg)        GPIO_MRD_##name(reg)
#define GPIO_MRD_STEP(reg)         STEP_P2L( GPIO_##reg(STEP) & STEP_MASK_PHYS )
#define GPIO_MRD_DIRECTION(reg)    DIRECTION_P2L( GPIO_##reg(DIRECTION) & DIRECTION_MASK_PHYS )
#define GPIO_MRD_LIMIT(reg)        ( GPIO_##reg(LIMIT)   & LIMIT_MASK )
#define GPIO_MRD_CONTROL(reg)      ( GPIO_##reg(CONTROL) & CONTROL_MASK )
#define GPIO_MRD_PROBE(reg)        ( GPIO_##reg(PROBE)   & PROBE_MASK )

// ----------------------------------------------------------------------------
// Group direction. STEP/DIRECTION configure the PHYSICAL pins.
// ----------------------------------------------------------------------------
#undef GPIO_MDIR_OUT
#undef GPIO_MDIR_INP
#define GPIO_MDIR_OUT(name)        GPIO_MDIR_OUT_##name()
#define GPIO_MDIR_OUT_STEP()       sg2002_gpio_rmw(&GPIO_DREG(STEP), 0UL, STEP_MASK_PHYS)
#define GPIO_MDIR_OUT_DIRECTION()  sg2002_gpio_rmw(&GPIO_DREG(DIRECTION), 0UL, DIRECTION_MASK_PHYS)

#define GPIO_MDIR_INP(name)        sg2002_gpio_rmw(&GPIO_DREG(name), (name##_MASK), 0UL)

#endif // GPIO_SG2002_H
