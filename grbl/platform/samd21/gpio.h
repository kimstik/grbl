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

#include "../common/gpio_logical.h"

/* ---------------------------------------------------------------------
 * LOGICAL PORT-IMAGE CONTRACT (BUG #17 fix, PLAN.md Phase 3, CONTRACTS.md #1;
 * extended to CONTROL/PROBE below - CONTRACTS.md #limit-bit-width-second-consumer)
 *
 * GRBL core's step pipeline is a uint8_t port image: st.step_outbits,
 * st.dir_outbits, axislock and the step/dir invert masks all live in bits
 * 0..7 (stepper.c get_step_pin_mask()/get_direction_pin_mask() compute
 * `1<<X_STEP_BIT` and OR it into a uint8_t; limits.c:342 tests
 * `STEP_MASK & axislock`). The same is true of every input-group read:
 * limits.c/system.c/probe.c each narrow `GPIO_MRD(name, IREG)` into a
 * uint8_t local. A board whose physical pins for one of these groups do
 * not already sit at bits 0..7 silently truncates - no warning, dead input
 * or dead output, forever (megarm STEP: PA25/27/28; megarm CONTROL:
 * PA14/15/16; both boards' PROBE and part of CONTROL on generic).
 *
 * Fix, uniform across all five truncation-risk groups (STEP, DIRECTION,
 * LIMIT, CONTROL, PROBE - SPINDLE/COOLANT/STEPPERS_DISABLE are single-bit
 * ops on the native register width and never narrow, see CONTRACTS.md
 * #gpio-data): every board's config.h defines the group's *_BIT constants
 * as LOGICAL bits (0.. board's group width, core's native assumption); the
 * real silicon pin moves to a matching *_PIN define. GPIO_LOGICAL_DISPATCH_*
 * (common/gpio_logical.h) fans core's six group-macro entry points out per
 * NAME at compile time (token-pasted - zero runtime branching, ISR-hot
 * safe); a NAME dispatches either to GPIO_LOGICAL_PASSTHRU_* (physical
 * already fits, byte-identical to the stock common/gpio.h formula) or to a
 * real translation consuming that NAME's <NAME>_L2P/_P2L/_MASK_PHYS.
 *
 * generic board: STEP/DIRECTION/CONTROL/PROBE pins are each contiguous, so
 * their L2P/P2L pair collapses to a pure shift. megarm board: STEP scatters
 * over PA25/27/28 (a 3-term OR-of-shifts gather/scatter, no data-dependent
 * branch - stepper.c:318-320 33.3us@30kHz ISR-hot budget); CONTROL/PROBE
 * there are each contiguous (pure shift) even though DIRECTION on the same
 * board also happens to need none (physical == logical already).
 *
 * CONTROL_MASK/PROBE_MASK below are the LOGICAL, core-visible masks (used in
 * system.c:43's `GPIO_MRD(CONTROL,IREG) ^ CONTROL_MASK` and probe.c's
 * invert-mask XOR) - NOT the physical interrupt-arm mask GPIO_INT_ON's
 * CONTROL_MASK argument would need if the logical value were fed to it
 * as-is; the SAMD21 GPIO_INT_ON/OFF are still an empty no-op (CONTRACTS
 * #gpio-interrupts item 1, unrelated open gap) so this is inert today. If
 * that gap is ever closed, the fix reaches for CONTROL_L2P(CONTROL_MASK) to
 * recover the physical arm pattern - do not repurpose CONTROL_MASK itself.
 * -------------------------------------------------------------------*/

#define GPIO_MWO(name, val)        GPIO_LOGICAL_DISPATCH_MWO(name, val)
#define GPIO_MRD(name, reg)        GPIO_LOGICAL_DISPATCH_MRD(name, reg)
#define GPIO_MDIR_OUT(name)        GPIO_LOGICAL_DISPATCH_MDIR_OUT(name)
#define GPIO_MDIR_INP(name)        GPIO_LOGICAL_DISPATCH_MDIR_INP(name)
#define GPIO_MPULLUP_EN(name)      GPIO_LOGICAL_DISPATCH_MPULLUP_EN(name)
#define GPIO_MPULLUP_DIS(name)     GPIO_LOGICAL_DISPATCH_MPULLUP_DIS(name)

// -- output groups: STEP/DIRECTION are the only GPIO_MWO/GPIO_MDIR_OUT callers --
#define GPIO_MWO_STEP(val)         ( GPIO_OREG(STEP)      = (GPIO_OREG(STEP)      & ~STEP_MASK_PHYS)      | STEP_L2P(val) )
#define GPIO_MWO_DIRECTION(val)    ( GPIO_OREG(DIRECTION) = (GPIO_OREG(DIRECTION) & ~DIRECTION_MASK_PHYS) | DIRECTION_L2P(val) )
#define GPIO_MDIR_OUT_STEP()       MSK_SET( GPIO_DREG(STEP),      STEP_MASK_PHYS )
#define GPIO_MDIR_OUT_DIRECTION()  MSK_SET( GPIO_DREG(DIRECTION), DIRECTION_MASK_PHYS )

// -- GPIO_MRD: STEP needs translation (only live under STEP_PULSE_DELAY, off
// by default); LIMIT stays a passthrough (physical already fits both boards);
// CONTROL/PROBE are translated (megarm 14/15/16 and 19; generic 8/9 and 10 -
// both boards' donor pin maps put these past bit 7) --
#define GPIO_MRD_STEP(reg)         STEP_P2L( GPIO_##reg(STEP) & STEP_MASK_PHYS )
#define GPIO_MRD_LIMIT(reg)        GPIO_LOGICAL_PASSTHRU_MRD(LIMIT, reg)
#define GPIO_MRD_CONTROL(reg)      CONTROL_P2L( GPIO_##reg(CONTROL) & CONTROL_MASK_PHYS )
#define GPIO_MRD_PROBE(reg)        PROBE_P2L( GPIO_##reg(PROBE) & PROBE_MASK_PHYS )

// -- input groups: LIMIT/CONTROL/PROBE are the only GPIO_MDIR_INP/
// GPIO_MPULLUP_EN/DIS callers (limits.c/system.c/probe.c init). Direction
// and pull-up configuration always needs the PHYSICAL mask regardless of
// whether the group's read path is translated - LIMIT is a passthrough
// (physical mask == logical mask there), CONTROL/PROBE use their real
// silicon mask directly (the dispatch ignores the `name` argument, same as
// GPIO_MDIR_OUT_STEP() above; nothing here reads a logical value) --
#define GPIO_MDIR_INP_LIMIT()      GPIO_LOGICAL_PASSTHRU_MDIR_INP(LIMIT)
#define GPIO_MDIR_INP_CONTROL()    MSK_CLR( GPIO_DREG(CONTROL), CONTROL_MASK_PHYS )
#define GPIO_MDIR_INP_PROBE()      MSK_CLR( GPIO_DREG(PROBE),   PROBE_MASK_PHYS )

#define GPIO_MPULLUP_EN_LIMIT()    GPIO_LOGICAL_PASSTHRU_MPULLUP_EN(LIMIT)
#define GPIO_MPULLUP_DIS_LIMIT()   GPIO_LOGICAL_PASSTHRU_MPULLUP_DIS(LIMIT)
#define GPIO_MPULLUP_EN_CONTROL()  MSK_SET( GPIO_PREG(CONTROL), CONTROL_MASK_PHYS )
#define GPIO_MPULLUP_DIS_CONTROL() MSK_CLR( GPIO_PREG(CONTROL), CONTROL_MASK_PHYS )
#define GPIO_MPULLUP_EN_PROBE()    MSK_SET( GPIO_PREG(PROBE),   PROBE_MASK_PHYS )
#define GPIO_MPULLUP_DIS_PROBE()   MSK_CLR( GPIO_PREG(PROBE),   PROBE_MASK_PHYS )

#endif // GPIO_SAMD21_H
