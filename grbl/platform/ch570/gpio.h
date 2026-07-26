/*
  gpio.h - CH570 GPIO register accessors and macro overrides
  Part of Grbl
*/

#ifndef GPIO_CH570_H
#define GPIO_CH570_H

#include "ch570.h"

// Register accessors consumed by common/gpio.h compositions. `name##_PORT`
// is never referenced - GPIO_OREG/IREG/DREG/PREG below ignore it entirely.

#define GPIO_OREG(name)   R32_PA_OUT
#define GPIO_IREG(name)   R32_PA_PIN
#define GPIO_DREG(name)   R32_PA_DIR     // direction: 1 = out, 0 = in - plain bit, no packing
#define GPIO_PREG(name)   R32_PA_PU      // pull-up enable (paired with PD_DRV via the functions below)

// NOTE: hal_gpio.h (shared core file, all non-AVR platforms) unconditionally
// declares `hal_gpio_pullup_enable/disable(hal_gpio_port_t port, uint32_t
// mask)` - this port's `hal_gpio_port_t` (platform.h) is a dummy uint8_t
// (single real GPIO port, no meaningful port value to pass), but the
// FUNCTION SIGNATURE must still match exactly or the two declarations
// conflict at compile time. Written as `uint8_t` here (not the
// `hal_gpio_port_t` alias) deliberately: this file (gpio.h) is injected by
// prelude.h BEFORE platform.h defines that typedef, so the alias name
// itself is not yet in scope at this point - the underlying concrete type
// is what must match, and typedefs are aliases, not distinct types, so a
// later `hal_gpio_port_t`-spelled declaration (hal_gpio.h) of the exact
// same underlying type is compatible regardless of which spelling came
// first. The `port` parameter is accepted and ignored (matches
// ch32v006's own pattern of satisfying this shared contract by name,
// even though ch32v006's port type is a real pointer and this one isn't).
void hal_gpio_pullup_enable(uint8_t port, uint32_t mask);
void hal_gpio_pullup_disable(uint8_t port, uint32_t mask);
void hal_gpio_interrupt_enable(uint32_t mask);
void hal_gpio_interrupt_disable(uint32_t mask);

// Pull-up needs PD_DRV cleared too (PD_DRV=1 forces pull-DOWN regardless
// of PU - platform.c mirrors the vendor's own GPIOA_ModeCfg truth table).
// Two independent full-width registers, no nibble packing - safe as a
// small function rather than the default single-register macro.
#undef GPIO_PULLUP_EN
#undef GPIO_PULLUP_DIS
#undef GPIO_MPULLUP_EN
#undef GPIO_MPULLUP_DIS
#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(0, 1UL << (name##_BIT))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(0, 1UL << (name##_BIT))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(0, (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(0, (name##_MASK))

// Atomic single-bit output (CONTRACTS.md #1.2) - SET/CLR registers, not a
// RMW on OUT (safe against an ISR touching a different bit concurrently).
#undef GPIO_BSET
#undef GPIO_BCLR
#define GPIO_BSET(name)   (R32_PA_SET = (1UL << (name##_BIT)))
#define GPIO_BCLR(name)   (R32_PA_CLR = (1UL << (name##_BIT)))

// Masked-group write/read with logical<->physical translation (BUG #17).
// GPIO_MWO is only ever called with STEP/DIRECTION - stepper.c.

static inline void hal_gpio_mwo(uint32_t phys_mask, uint32_t phys_val) {
  R32_PA_SET = phys_val & phys_mask;
  R32_PA_CLR = phys_mask & ~phys_val;
}

#define GPIO_MWO(name, val)        GPIO_MWO_##name(val)
#define GPIO_MWO_STEP(val)         hal_gpio_mwo(STEP_MASK_PHYS,      STEP_L2P(val))
#define GPIO_MWO_DIRECTION(val)    hal_gpio_mwo(DIRECTION_MASK_PHYS, DIRECTION_L2P(val))

// GPIO_MRD: STEP path (stepper.c OREG readback) needs P2L; input groups
// (LIMIT/CONTROL/PROBE) are physical==logical on this board and reuse the
// stock common/gpio.h formula (no override needed for them specifically).
#define GPIO_MRD(name, reg)        GPIO_MRD_##name(reg)
#define GPIO_MRD_STEP(reg)         STEP_P2L( GPIO_##reg(STEP) & STEP_MASK_PHYS )
#define GPIO_MRD_LIMIT(reg)        ( GPIO_##reg(LIMIT)   & LIMIT_MASK )
#define GPIO_MRD_CONTROL(reg)      ( GPIO_##reg(CONTROL) & CONTROL_MASK )
#define GPIO_MRD_PROBE(reg)        ( GPIO_##reg(PROBE)   & PROBE_MASK )

// GPIO_MDIR_OUT: STEP/DIRECTION configure the PHYSICAL pins (stepper.c).
// Direction is a plain bit here (no packing) - a straight mask OR is
// correct without a function call.
#define GPIO_MDIR_OUT(name)        GPIO_MDIR_OUT_##name()
#define GPIO_MDIR_OUT_STEP()       (R32_PA_DIR |= STEP_MASK_PHYS)
#define GPIO_MDIR_OUT_DIRECTION()  (R32_PA_DIR |= DIRECTION_MASK_PHYS)

#endif // GPIO_CH570_H
