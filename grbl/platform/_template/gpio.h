/*
  gpio.h - _template GPIO register accessors (copy-me starting point)
  Part of Grbl

  CONTRACTS.md §1: GPIO_OREG/IREG/DREG/PREG are the four register accessors
  common/gpio.h's GPIO_M* and GPIO_B* families compose on top of
  (name##_PORT picks the register set, name##_BIT/_MASK picks the bits
  within it). This
  file must be included BEFORE ../common/gpio.h (see
  boards/generic/prelude.h) - common/gpio.h only supplies AVR-style
  defaults for accessors that are not already defined.

  DESIGN: GPIO_OREG is used both as an rvalue (GPIO_MRD, GPIO_BSET, ...) AND
  as a raw lvalue (`GPIO_OREG(STEP) = st.step_bits` under STEP_PULSE_DELAY,
  stepper.c:513) - a call expression cannot serve as an lvalue, so the usual
  "call to undeclared PORT_TODO_<name>()" shape does not fit here. Instead
  each accessor indexes into an extern array that is declared but never
  DEFINED anywhere in this template: it compiles (arrays decay to valid
  lvalues/rvalues at any index), and it fails at LINK time with an
  undefined reference to the array's name - same "linker enumerates the gap
  by name" contract as every other PORT_TODO_* in this port, just shaped to
  stay assignable.

  Once you have real per-chip port registers, replace all four #defines
  below with direct register-struct member access (see samd21/gpio.h:15-18
  for the pattern: `PORT->Group[name##_PORT].OUT` etc.) and delete the
  PORT_TODO_GPIO_* array declarations.
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
