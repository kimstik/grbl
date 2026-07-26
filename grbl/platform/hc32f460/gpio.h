/*
  gpio.h - HC32F460 GPIO register accessors and macro overrides
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef HC32F460_GPIO_H
#define HC32F460_GPIO_H

#include "regs.h"

/* Register accessors consumed by common/gpio.h compositions
   (GPIO_MWO/GPIO_MRD/GPIO_BGET/GPIO_BGETOUT/...) */

#define GPIO_OREG(name)   ((name##_PORT)->PODR)   /* output data register */
#define GPIO_IREG(name)   ((name##_PORT)->PIDR)   /* input data register */

/* No GPIO_DREG/GPIO_PREG: direction and pull-up are per-pin PCONR words,
   not per-port bit-op registers - overridden below with function calls
   (implemented in platform.c). */

void hal_gpio_set_output(HC32_PORT_TypeDef *port, uint32_t mask);
void hal_gpio_set_input(HC32_PORT_TypeDef *port, uint32_t mask);
void hal_gpio_pullup_enable(HC32_PORT_TypeDef *port, uint32_t mask);
void hal_gpio_pullup_disable(HC32_PORT_TypeDef *port, uint32_t mask);

/* Single-bit data writes: POSR/PORR are hardware atomic set/reset
   (CONFIRMED register names, regs.h header), satisfying the mixed
   mainline/ISR writer contract (CONTRACTS.md section 1.2) without a
   read-modify-write critical section - same shape as STM32 BSRR. */

#define GPIO_BSET(name)   ((name##_PORT)->POSR = (1u << (name##_BIT)))
#define GPIO_BCLR(name)   ((name##_PORT)->PORR = (1u << (name##_BIT)))

/* Direction / pull-up configuration (init context only) */

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(name##_PORT, (1u << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(name##_PORT, (1u << (name##_BIT)))
#define GPIO_MDIR_OUT(name)     hal_gpio_set_output(name##_PORT, (name##_MASK))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(name##_PORT, (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(name##_PORT, (1u << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(name##_PORT, (1u << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(name##_PORT, (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(name##_PORT, (name##_MASK))

#endif /* HC32F460_GPIO_H */
