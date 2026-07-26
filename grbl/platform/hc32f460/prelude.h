/*
  prelude.h - build prelude for HC32F460
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GRBL_PRELUDE_HC32F460_H
#define GRBL_PRELUDE_HC32F460_H

#define GRBL_PRELUDE 1

#include "gpio.h"
#include "../common/gpio.h"
#include "../common/cortexm/cortexm_critical.h"

/*
  SINGLE-PRECISION LIBM PIN (CONTRACTS.md section 17) - armed only when the
  Makefile's FP knob is SINGLE (GRBL_FP_SINGLE defined; pairs with
  -fsingle-precision-constant there). This is an M4F WITH a real
  fpv4-sp-d16-class single-precision-only hardware FPU: without this pin,
  unsuffixed libm calls (sqrt/atan2/sin/cos/...) promote to double and the
  FPU cannot help at all; with it, those call sites go to sqrtf/sinf/etc,
  which this FPU executes as real vsqrt.f32/vmul.f32/... instructions
  instead of software routines - the same win stm32f411/stm32h523 measured
  (CONTRACTS.md section 17.7's "stm32f411 FPU FINDING").

  Mechanism: include <math.h> FIRST so its prototypes are declared
  untouched, then rewrite ONLY call sites via function-like macros - see
  stm32f411/prelude.h for the full rationale, copied verbatim in spirit.
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
#endif /* GRBL_FP_SINGLE */

#endif /* GRBL_PRELUDE_HC32F460_H */
