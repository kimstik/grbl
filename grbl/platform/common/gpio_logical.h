/*
  gpio_logical.h - reusable logical<->physical GPIO port-image dispatch
  Part of Grbl

  Copyright (c) 2026 kimstik
  Intelligence assisted
  License: MIT

  Promoted out of samd21/gpio.h (BUG #17 fix, PLAN.md Phase 3) once a SECOND
  port needed the identical shape for a second pair of groups (CONTROL/PROBE
  truncation on samd21 itself, and the PROBE-15 class found on stm32f103/
  f411/h523 during the BUG #26 follow-up audit, CONTRACTS.md
  #limit-bit-width-second-consumer). Core packs STEP/DIR/LIMIT/CONTROL/PROBE
  group reads and the STEP/DIR write-back path into a `uint8_t` (CONTRACTS.md
  #gpio-data); any board whose physical pins for one of these groups don't
  already sit at bits 0-7 needs a per-NAME logical<->physical translation
  layer, not a wider core type (the core type is frozen, golden-MD5-gated).

  A port's own gpio.h defines the six GPIO_M*(name,...) entry points ONCE as
  the *_DISPATCH forms below, then supplies one GPIO_xxx_<NAME>(...)
  definition per group core actually calls it for - GPIO_LOGICAL_PASSTHRU_*
  for a group whose physical pins already fit (reproduces the stock
  common/gpio.h formula so nothing about that group changes), or a real
  translated body (using board-supplied <NAME>_L2P/_P2L/_MASK_PHYS) for a
  group that doesn't. Constraint (a `<=7` _Static_assert on the physical bit)
  is still the right answer when a port's whole pin map already fits -
  the deliberate choice is per-group, not per-port: STEP/DIRECTION on
  samd21/generic use a pure-shift translation, LIMIT there stays passthrough,
  and this header does not force a port that needs neither into using either.

  Not every one of core's six group-macro entry points is called for every
  NAME - GPIO_MWO/GPIO_MDIR_OUT only ever fire for STEP/DIRECTION (output
  groups); GPIO_MDIR_INP/GPIO_MPULLUP_EN/GPIO_MPULLUP_DIS only ever fire for
  LIMIT/CONTROL/PROBE (input groups); GPIO_MRD fires for all of the above
  (CONTRACTS.md #gpio-data's call-site table). A port only needs to supply
  the entries core will actually reach for the NAMEs it dispatches through
  this header - an un-dispatched NAME keeps using common/gpio.h's own
  #ifndef-guarded default untouched.
*/

#ifndef GPIO_LOGICAL_H
#define GPIO_LOGICAL_H

#define GPIO_LOGICAL_DISPATCH_MWO(name, val)     GPIO_MWO_##name(val)
#define GPIO_LOGICAL_DISPATCH_MRD(name, reg)     GPIO_MRD_##name(reg)
#define GPIO_LOGICAL_DISPATCH_MDIR_OUT(name)     GPIO_MDIR_OUT_##name()
#define GPIO_LOGICAL_DISPATCH_MDIR_INP(name)     GPIO_MDIR_INP_##name()
#define GPIO_LOGICAL_DISPATCH_MPULLUP_EN(name)   GPIO_MPULLUP_EN_##name()
#define GPIO_LOGICAL_DISPATCH_MPULLUP_DIS(name)  GPIO_MPULLUP_DIS_##name()

// Passthrough bodies: byte-identical to common/gpio.h's own #ifndef-guarded
// defaults (GPIO_MWR/GPIO_MWV formulas) - for a NAME whose physical mask
// already equals its core-visible logical mask, wiring the dispatch through
// these costs nothing and changes no behavior.
#define GPIO_LOGICAL_PASSTHRU_MRD(name, reg)        ( GPIO_##reg(name) & name##_MASK )
#define GPIO_LOGICAL_PASSTHRU_MDIR_INP(name)        MSK_CLR( GPIO_DREG(name), name##_MASK )
#define GPIO_LOGICAL_PASSTHRU_MPULLUP_EN(name)      MSK_SET( GPIO_PREG(name), name##_MASK )
#define GPIO_LOGICAL_PASSTHRU_MPULLUP_DIS(name)     MSK_CLR( GPIO_PREG(name), name##_MASK )

#endif // GPIO_LOGICAL_H
