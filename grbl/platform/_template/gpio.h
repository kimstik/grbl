/*
  gpio.h - _template GPIO register accessors (copy-me starting point)
  Part of Grbl
*/

#ifndef GPIO_TEMPLATE_H
#define GPIO_TEMPLATE_H

#warning "PORT-TODO: gpio.h"

#include <stdint.h>

extern volatile uint32_t PORT_TODO_GPIO_OREG[];  // GPIO_OREG - output data register
extern volatile uint32_t PORT_TODO_GPIO_IREG[];  // GPIO_IREG - input data register (LIMIT/CONTROL/PROBE reads)
extern volatile uint32_t PORT_TODO_GPIO_DREG[];  // GPIO_DREG - direction register
extern volatile uint32_t PORT_TODO_GPIO_PREG[];  // GPIO_PREG - pull-up control register (§1.4: must actually enable pull-ups)

#define GPIO_OREG(name)  PORT_TODO_GPIO_OREG[name##_PORT]
#define GPIO_IREG(name)  PORT_TODO_GPIO_IREG[name##_PORT]
#define GPIO_DREG(name)  PORT_TODO_GPIO_DREG[name##_PORT]
#define GPIO_PREG(name)  PORT_TODO_GPIO_PREG[name##_PORT]

// CONTRACTS.md §1.2 (RMW atomicity): audit every register above that is
// written from BOTH mainline and an ISR (STEPPERS_DISABLE/SPINDLE/COOLANT
// bits share OREG with STEP/DIRECTION-adjacent writers on most chips). If
// your chip lacks hardware atomic set/clear registers (OUTSET/OUTCLR, BSRR
// class), GPIO_MWO/GPIO_BSET must be redefined here to wrap
// HAL_CRITICAL_SECTION_BEGIN/END (platform.h) instead of doing a bare RMW.
// This is a design decision the linker cannot check for you - do it before
// calling GPIO done, not after finding the race on hardware.

#endif // GPIO_TEMPLATE_H
