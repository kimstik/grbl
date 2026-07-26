/*
  gpio.h - SAMD21 platform-specific GPIO register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GPIO_SAMD21_H
#define GPIO_SAMD21_H

// Platform-specific register accessors - defined before platform/common/gpio.h

#define GPIO_OREG(name)	PORT->Group[name##_PORT].OUT	// GPIO output register - to write to
#define GPIO_IREG(name)	PORT->Group[name##_PORT].IN		// GPIO input register  - to read from (LIMIT/CONTROL/PROBE)
#define GPIO_DREG(name)	PORT->Group[name##_PORT].DIR    // GPIO direction control reg
#define GPIO_PREG(name)	PORT->Group[name##_PORT].CTRL   // GPIO pullup control

/* ---------------------------------------------------------------------
 * LOGICAL PORT-IMAGE CONTRACT (BUG #17 fix, CONTRACTS.md #1)
 *
 * GRBL core's step pipeline is a uint8_t port image: st.step_outbits,
 * st.dir_outbits, axislock and the step/dir invert masks all live in bits
 * 0..7 (stepper.c get_step_pin_mask()/get_direction_pin_mask() compute
 * `1<<X_STEP_BIT` and OR it into a uint8_t; limits.c:342 tests
 * `STEP_MASK & axislock`). A board whose physical STEP/DIRECTION pins do
 * not already sit at bits 0..7 (megarm: PA25/27/28) silently truncates in
 * that compound `|=` - no warning, zero step output, ever.
 *
 * Fix: every board's config.h defines X/Y/Z_STEP_BIT and X/Y/Z_DIRECTION_BIT
 * as LOGICAL bits 0,1,2 (core's native assumption); the real silicon pin
 * moves to the matching *_STEP_PIN / *_DIRECTION_PIN define. STEP_MASK/
 * DIRECTION_MASK (core-visible: limits.c:342, stepper.c:499,561-567) are
 * therefore logical masks too.
 *
 * GPIO_MWO(name, val) is the only macro through which core ever writes the
 * physical STEP/DIRECTION registers (ISR_STEP, ISR_STEP_RESET, st_reset -
 * CONTRACTS.md #1); GPIO_MRD's STEP path and GPIO_MDIR_OUT's STEP/DIRECTION
 * path need the same translation. All three dispatch per NAME (token-pasted
 * at compile time - zero runtime branching, ISR-hot safe) to a board-
 * supplied translation, each board's config.h defining:
 *   <NAME>_MASK_PHYS   - the real register mask
 *   <NAME>_L2P(v)      - logical byte -> physical register pattern
 *   <NAME>_P2L(v)      - physical register bits -> logical byte
 * generic board: pins are contiguous, L2P/P2L collapse to a pure shift.
 * megarm board: STEP scatters over PA25/27/28, L2P/P2L are a fixed 3-term
 * OR-of-shifts gather/scatter (no data-dependent branch - stepper.c:318-320
 * 33.3us@30kHz ISR-hot budget, CONTRACTS.md #1).
 *
 * LIMIT/CONTROL/PROBE never go through GPIO_MWO/GPIO_MDIR_OUT with a
 * remapped mask (their pins are not touched by this bug); the dispatch
 * entries for them below simply reproduce the stock common/gpio.h formula
 * so nothing about those groups changes.
 * -------------------------------------------------------------------*/

// -- GPIO_MWO: physical write, only STEP/DIRECTION ever call this --
#define GPIO_MWO(name, val)        GPIO_MWO_##name(val)
#define GPIO_MWO_STEP(val)         ( GPIO_OREG(STEP)      = (GPIO_OREG(STEP)      & ~STEP_MASK_PHYS)      | STEP_L2P(val) )
#define GPIO_MWO_DIRECTION(val)    ( GPIO_OREG(DIRECTION) = (GPIO_OREG(DIRECTION) & ~DIRECTION_MASK_PHYS) | DIRECTION_L2P(val) )

// -- GPIO_MRD: STEP needs translation (only live under STEP_PULSE_DELAY,
// off by default); LIMIT/CONTROL/PROBE are passthroughs (physical==logical
// there - untouched by this bug) --
#define GPIO_MRD(name, reg)        GPIO_MRD_##name(reg)
#define GPIO_MRD_STEP(reg)         STEP_P2L( GPIO_##reg(STEP) & STEP_MASK_PHYS )
#define GPIO_MRD_LIMIT(reg)        ( GPIO_##reg(LIMIT)   & LIMIT_MASK )
#define GPIO_MRD_CONTROL(reg)      ( GPIO_##reg(CONTROL) & CONTROL_MASK )
#define GPIO_MRD_PROBE(reg)        ( GPIO_##reg(PROBE)   & PROBE_MASK )

// -- GPIO_MDIR_OUT: STEP/DIRECTION need the physical mask so the real pins
// (not the logical bit numbers) get configured as outputs; LIMIT/CONTROL/
// PROBE are passthroughs --
#define GPIO_MDIR_OUT(name)        GPIO_MDIR_OUT_##name()
#define GPIO_MDIR_OUT_STEP()       MSK_SET( GPIO_DREG(STEP),      STEP_MASK_PHYS )
#define GPIO_MDIR_OUT_DIRECTION()  MSK_SET( GPIO_DREG(DIRECTION), DIRECTION_MASK_PHYS )
#define GPIO_MDIR_OUT_LIMIT()      MSK_SET( GPIO_DREG(LIMIT),     LIMIT_MASK )
#define GPIO_MDIR_OUT_CONTROL()    MSK_SET( GPIO_DREG(CONTROL),   CONTROL_MASK )
#define GPIO_MDIR_OUT_PROBE()      MSK_SET( GPIO_DREG(PROBE),     PROBE_MASK )

#endif // GPIO_SAMD21_H
