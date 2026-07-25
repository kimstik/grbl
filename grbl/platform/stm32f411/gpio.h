/*
  gpio.h - STM32F411 GPIO register accessors and macro overrides
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Injected by prelude.h BEFORE platform/common/gpio.h: that file only
  supplies AVR-style defaults for accessors/macros that are not already
  defined (all of its definitions are #ifndef-guarded), so everything
  here wins by coming first.

  Composition contract (platform/CONTRACTS.md section 1): core code calls
  GPIO_*(NAME) macros; NAME##_PORT / NAME##_BIT / NAME##_MASK come from the
  pin map in platform.h (NAME##_PORT is a GPIO_TypeDef*).

  Ported from stm32h523/gpio.h (byte-identical shape - F4's MODER/OTYPER/
  PUPDR is the same 2-bit-per-pin model as H5's, so every macro that would
  touch them is overridden below with function calls, implemented in
  platform.c: hal_gpio_set_output/set_input/pullup_enable/pullup_disable).
*/

#ifndef STM32F411_GPIO_H
#define STM32F411_GPIO_H

#include "regs.h"

// ----------------------------------------------------------------------------
// Register accessors consumed by common/gpio.h compositions
// (GPIO_MWO/GPIO_MRD/GPIO_BGET/GPIO_BGETOUT/...)
// ----------------------------------------------------------------------------

#define GPIO_OREG(name)   ((name##_PORT)->ODR)   // output data register
#define GPIO_IREG(name)   ((name##_PORT)->IDR)   // input data register

// No GPIO_DREG/GPIO_PREG: F4 direction (MODER) and pull configuration
// (PUPDR) are 2-bit-per-pin fields, so every macro that would touch them is
// overridden below with function calls (implemented in platform.c).

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask);

// ----------------------------------------------------------------------------
// Single-bit data writes: BSRR is hardware-atomic set/reset, satisfying the
// mixed mainline/ISR writer contract (CONTRACTS.md section 1.2) without a
// read-modify-write critical section.
// ----------------------------------------------------------------------------

#define GPIO_BSET(name)   ((name##_PORT)->BSRR = (1u << (name##_BIT)))
#define GPIO_BCLR(name)   ((name##_PORT)->BSRR = ((uint32_t)1u << (name##_BIT)) << 16)

// ----------------------------------------------------------------------------
// Direction / pull-up configuration (init context only)
// ----------------------------------------------------------------------------

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(name##_PORT, (1u << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(name##_PORT, (1u << (name##_BIT)))
#define GPIO_MDIR_OUT(name)     hal_gpio_set_output(name##_PORT, (name##_MASK))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(name##_PORT, (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(name##_PORT, (1u << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(name##_PORT, (1u << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(name##_PORT, (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(name##_PORT, (name##_MASK))

#endif // STM32F411_GPIO_H
