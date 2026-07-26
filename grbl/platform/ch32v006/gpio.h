/*
  gpio.h - CH32V006 GPIO register accessors and macro overrides
  Part of Grbl
*/

#ifndef GPIO_CH32V006_H
#define GPIO_CH32V006_H

#include "ch32v006.h"

// Register accessors consumed by common/gpio.h compositions

#define GPIO_OREG(name)   ((name##_PORT)->OUTDR)   // output data register
#define GPIO_IREG(name)   ((name##_PORT)->INDR)    // input data register

// No GPIO_DREG/GPIO_PREG - see file header. Every macro that would touch
// them is overridden below with function calls.

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask);

// Masked-group write/read with logical<->physical translation (BUG #17).
// GPIO_MWO is only ever called with STEP/DIRECTION (+_DUAL variants, not
// configured on this port's boards) - stepper.c:331,343,499,561-567.
// The RMW on OUTDR is ISR-only for both groups (core writer discipline,
// CONTRACTS.md #1.2), so no BSHR atomicity is needed on this path.

#define GPIO_MWO(name, val)        GPIO_MWO_##name(val)
#define GPIO_MWO_STEP(val)         ( GPIO_OREG(STEP)      = (GPIO_OREG(STEP)      & ~STEP_MASK_PHYS)      | STEP_L2P(val) )
#define GPIO_MWO_DIRECTION(val)    ( GPIO_OREG(DIRECTION) = (GPIO_OREG(DIRECTION) & ~DIRECTION_MASK_PHYS) | DIRECTION_L2P(val) )

// GPIO_MRD: STEP path (stepper.c:338, OREG readback) needs P2L; the input
// groups are physical==logical on this board (bits 0-7, CONTRACTS.md #1.3)
// and reproduce the stock common/gpio.h formula.
#define GPIO_MRD(name, reg)        GPIO_MRD_##name(reg)
#define GPIO_MRD_STEP(reg)         STEP_P2L( GPIO_##reg(STEP) & STEP_MASK_PHYS )
#define GPIO_MRD_LIMIT(reg)        ( GPIO_##reg(LIMIT)   & LIMIT_MASK )
#define GPIO_MRD_CONTROL(reg)      ( GPIO_##reg(CONTROL) & CONTROL_MASK )
#define GPIO_MRD_PROBE(reg)        ( GPIO_##reg(PROBE)   & PROBE_MASK )

// GPIO_MDIR_OUT: STEP/DIRECTION must configure the PHYSICAL pins
// (stepper.c:576,578). GPIO_MDIR_INP (inputs only - LIMIT/CONTROL/PROBE,
// physical==logical) keeps the generic mask-based function call below.
#define GPIO_MDIR_OUT(name)        GPIO_MDIR_OUT_##name()
#define GPIO_MDIR_OUT_STEP()       hal_gpio_set_output(STEP_PORT,      STEP_MASK_PHYS)
#define GPIO_MDIR_OUT_DIRECTION()  hal_gpio_set_output(DIRECTION_PORT, DIRECTION_MASK_PHYS)

// Single-bit data writes: BSHR is hardware-atomic set/reset (BS[7:0] set,
// BR[23:16] reset), satisfying the mixed mainline/ISR writer contract
// (CONTRACTS.md #1.2) without a critical section.

#define GPIO_BSET(name)   ((name##_PORT)->BSHR = (1UL << (name##_BIT)))
#define GPIO_BCLR(name)   ((name##_PORT)->BSHR = ((1UL << (name##_BIT)) << 16))

// Direction / pull-up configuration (init context only)

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(name##_PORT, (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(name##_PORT, (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(name##_PORT, (name##_MASK))

#endif // GPIO_CH32V006_H
