/*
  gpio.h - dsPIC33AK128MC102 GPIO register accessors and macro overrides
  Part of Grbl
*/

#ifndef GPIO_DSPIC33AK128MC102_H
#define GPIO_DSPIC33AK128MC102_H

#include <xc.h>
#include <stdint.h>

// Token-pasting plumbing: boards define NAME##_PORT as a bare port letter
// (A/B/C/D); these two-level pastes turn (LAT, STEP_PORT) into LATB.

#define GPIO_SFR_I(reg, p)  reg##p
#define GPIO_SFR(reg, p)    GPIO_SFR_I(reg, p)

// Port letter -> index (for the function-call helpers in platform.c)
#define GPIO_PIDX_A 0
#define GPIO_PIDX_B 1
#define GPIO_PIDX_C 2
#define GPIO_PIDX_D 3
#define GPIO_PIDX_I(p)  GPIO_PIDX_##p
#define GPIO_PIDX(p)    GPIO_PIDX_I(p)

// Register accessors consumed by common/gpio.h compositions

#define GPIO_OREG(name)   GPIO_SFR(LAT,  name##_PORT)   // output latch
#define GPIO_IREG(name)   GPIO_SFR(PORT, name##_PORT)   // input pins

// No GPIO_DREG/GPIO_PREG - TRIS polarity is inverted vs AVR DDR and
// direction config must also clear ANSELx; see file header. Every macro
// that would touch them is overridden below with function calls.

void hal_gpio_set_output(uint32_t port_idx, uint32_t mask);
void hal_gpio_set_input(uint32_t port_idx, uint32_t mask);
void hal_gpio_pullup_enable(uint32_t port_idx, uint32_t mask);
void hal_gpio_pullup_disable(uint32_t port_idx, uint32_t mask);

// Single-bit data writes - critical-section wrapped (see ATOMICITY above).
// Statement contexts only (all core use sites are statements - CONTRACTS.md
// #1 table). HAL_CRITICAL_SECTION_* come from platform.h; prelude order
// guarantees they are defined before any core TU expands these.

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

// Direction / pull-up configuration (init context only)

#define GPIO_DIR_OUT(name)      hal_gpio_set_output(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_DIR_INP(name)      hal_gpio_set_input(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_MDIR_OUT(name)     hal_gpio_set_output(GPIO_PIDX(name##_PORT), (name##_MASK))
#define GPIO_MDIR_INP(name)     hal_gpio_set_input(GPIO_PIDX(name##_PORT), (name##_MASK))

#define GPIO_PULLUP_EN(name)    hal_gpio_pullup_enable(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_PULLUP_DIS(name)   hal_gpio_pullup_disable(GPIO_PIDX(name##_PORT), (1UL << (name##_BIT)))
#define GPIO_MPULLUP_EN(name)   hal_gpio_pullup_enable(GPIO_PIDX(name##_PORT), (name##_MASK))
#define GPIO_MPULLUP_DIS(name)  hal_gpio_pullup_disable(GPIO_PIDX(name##_PORT), (name##_MASK))

#endif // GPIO_DSPIC33AK128MC102_H
