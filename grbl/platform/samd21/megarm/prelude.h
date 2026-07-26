/*
  prelude.h - build prelude for SAMD21 / MegARM board
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GRBL_PRELUDE_SAMD21_MEGARM_H
#define GRBL_PRELUDE_SAMD21_MEGARM_H

#define GRBL_PRELUDE 1

#include "../gpio.h"
#include "../../common/gpio.h"
#include "config.h"
#include "../platform.h"

/*
  SINGLE-PRECISION LIBM PIN - armed only when the Makefile's FP knob is
  SINGLE (GRBL_FP_SINGLE defined; pairs with -fsingle-precision-constant
  there - see the FP PRECISION KNOB comment in the Makefile for the full
  story and the measured sizes).

  GRBL core calls the unsuffixed double libm entry points (sqrt, atan2,
  sin, cos, floor, ceil, round, lround, trunc, fabs) because on the origin
  avr-gcc double==float and those WERE the single-precision functions. On
  Cortex-M0+ (no FPU, 64-bit double) the math.h prototypes make every such
  call promote its float arguments to genuine 64-bit double and pull DP
  libm + DP soft-float into the binary.

  Mechanism: include <math.h> FIRST so its prototypes are declared
  untouched (the include guard makes grbl.h's later #include <math.h> a
  no-op), then rewrite ONLY call sites via function-like macros. A
  function-like macro does not expand a bare identifier, so the prototypes
  themselves and any non-call use stay legal. Verified: no identifier in
  core or this platform collides with these names outside of comments.

  This is call-site mapping, not --wrap: callers pass genuine floats to
  the f-suffixed functions, so no narrowing wrappers and no __aeabi_f2d at
  every call site.
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

#endif // GRBL_PRELUDE_SAMD21_MEGARM_H
