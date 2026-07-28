/*
  prelude.h - build prelude for STM32F411 ("Black Pill")
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GRBL_PRELUDE_STM32F411_H
#define GRBL_PRELUDE_STM32F411_H

#define GRBL_PRELUDE 1

#include "gpio.h"
#include "../common/gpio.h"
#include "../common/cortexm/cortexm_critical.h"
#include "../common/clock_width.h" // CONTRACTS.md #36: F_CPU width guard
#include "../common/amass_floor.h" // CONTRACTS.md #amass-floor: AMASS floor guard

/*
  SINGLE-PRECISION LIBM PIN - armed only when the Makefile's FP knob is
  SINGLE (GRBL_FP_SINGLE defined; pairs with -fsingle-precision-constant
  there - see the FP PRECISION KNOB comment in common/stm32/common.mk, and
  samd21/megarm/prelude.h for the full story and the measured sizes).

  GRBL core calls the unsuffixed double libm entry points (sqrt, atan2,
  sin, cos, floor, ceil, round, lround, trunc, fabs) because on the origin
  avr-gcc double==float and those WERE the single-precision functions.
  SPECIAL CASE FOR THIS PORT: the Cortex-M4F here has a real fpv4-sp-d16
  FPU - SINGLE precision only, no DP hardware. Without this pin, unsuffixed
  libm calls promote to double and the FPU can't help at all (DP is
  emulated in soft-float, same as a plain M4 with no FPU); WITH this pin,
  those exact call sites go to sqrtf/sinf/etc, which this FPU executes as
  real vsqrt.f32/vmul.f32/... instructions instead of software routines -
  a speed win on top of the usual size win (verified via disassembly, see
  CONTRACTS.md #17 rollout note and PLAN.md's f411 FPU verdict).

  Mechanism: include <math.h> FIRST so its prototypes are declared
  untouched (the include guard makes grbl.h's later #include <math.h> a
  no-op), then rewrite ONLY call sites via function-like macros. A
  function-like macro does not expand a bare identifier, so the prototypes
  themselves and any non-call use stay legal. Verified: no identifier in
  core or this platform collides with these names outside of comments.

  This is call-site mapping, not --wrap: callers pass genuine floats to
  the f-suffixed functions, so no narrowing wrappers and no extra
  conversions at every call site.
*/
#ifdef GRBL_FP_SINGLE
#include <math.h>
#define sqrt(x)    sqrtf(x)
#define atan2(y,x) atan2f(y,x)
#define sin(x)     sinf(x)
#define cos(x)     cosf(x)
#define tan(x)     tanf(x)
#define floor(x)   floorf(x)
#define ceil(x)    ceilf(x)
#define round(x)   roundf(x)
#define lround(x)  lroundf(x)
#define trunc(x)   truncf(x)
#define fabs(x)    fabsf(x)
#define fmod(x,y)  fmodf(x,y)
#define pow(x,y)   powf(x,y)
#endif // GRBL_FP_SINGLE

#endif // GRBL_PRELUDE_STM32F411_H
