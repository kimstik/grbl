/*
  prelude.h - build prelude for CH570 / generic board
  Part of Grbl
*/

#ifndef GRBL_PRELUDE_CH570_GENERIC_H
#define GRBL_PRELUDE_CH570_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../gpio.h"
#include "../../../common/gpio.h"
#include "config.h"
#include "../../platform.h"

/*
  SINGLE-PRECISION LIBM PIN - armed only when the Makefile's FP knob is
  SINGLE (GRBL_FP_SINGLE defined; pairs with -fsingle-precision-constant -
  see ch32v006/boards/generic/prelude.h for the full rationale, identical
  here: no FPU on this core either, so the DP-soft-float leak this knob
  exists to plug is exactly as real).
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

#endif // GRBL_PRELUDE_CH570_GENERIC_H
