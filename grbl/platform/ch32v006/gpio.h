/*
  gpio.h - CH32V006 GPIO register accessors and macro overrides
  Part of Grbl

  Injected by prelude.h BEFORE platform/common/gpio.h (that file only
  supplies AVR-style defaults for accessors not already defined -
  CONTRACTS.md #0). Composition contract (CONTRACTS.md #1): core calls
  GPIO_*(NAME); NAME##_PORT/_BIT/_MASK come from boards/<board>/config.h.

  CH32V006 GPIO (like every WCH QingKe V00x part - clean-room, see
  ch32v006.h's header comment) configures direction/pull via a 4-bit
  CNF+MODE nibble per pin packed into CFGLR (pins 0-7) / CFGHR (pins
  8-15) - NOT a separate single-bit "direction register" the way AVR
  (DDRx) or SAMD21 (PORT.DIR) has. GPIO_DIR_OUT/INP/PULLUP_* therefore
  cannot be simple GPIO_DREG/GPIO_PREG bit-ops (common/gpio.h's default
  GPIO_BWR/GPIO_MWR formula ORs/ANDs a single bit into a register - that
  would corrupt the 3 other bits of whatever pin's nibble it lands on).
  Same shape of problem stm32f103 already solved (its CRL/CRH register is
  byte-identical to this chip's CFGLR/CFGHR) - reused here rather than
  reinvented: no GPIO_DREG/GPIO_PREG at all, direction/pull-up become
  real function calls (implemented in platform.c) instead of macros.
*/

#ifndef GPIO_CH32V006_H
#define GPIO_CH32V006_H

#include "ch32v006.h"

// ----------------------------------------------------------------------------
// Register accessors consumed by common/gpio.h compositions
// (GPIO_MWO/GPIO_MRD/GPIO_BGET/GPIO_BGETOUT/...)
// ----------------------------------------------------------------------------

#define GPIO_OREG(name)   ((name##_PORT)->OUTDR)   // output data register
#define GPIO_IREG(name)   ((name##_PORT)->INDR)    // input data register

// No GPIO_DREG/GPIO_PREG - see file header. Every macro that would touch
// them is overridden below with function calls.

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask);

// ----------------------------------------------------------------------------
// Single-bit data writes: BSHR is hardware-atomic set/reset (low 16 bits
// set, high 16 bits reset - identical shape to STM32 BSRR), satisfying
// the mixed mainline/ISR writer contract (CONTRACTS.md #1.2) without a
// critical section.
// ----------------------------------------------------------------------------

#define GPIO_BSET(name)   ((name##_PORT)->BSHR = (1UL << (name##_BIT)))
#define GPIO_BCLR(name)   ((name##_PORT)->BSHR = ((1UL << (name##_BIT)) << 16))

// ----------------------------------------------------------------------------
// Direction / pull-up configuration (init context only)
// ----------------------------------------------------------------------------

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_MDIR_OUT(name)     hal_gpio_set_output(name##_PORT, (name##_MASK))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(name##_PORT, (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(name##_PORT, (1UL << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(name##_PORT, (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(name##_PORT, (name##_MASK))

#endif // GPIO_CH32V006_H
