/*
  prelude.h - build prelude for dsPIC33AK128MC102 / generic board
  Part of Grbl
*/

#ifndef GRBL_PRELUDE_DSPIC33AK128MC102_GENERIC_H
#define GRBL_PRELUDE_DSPIC33AK128MC102_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../gpio.h"
#include "../../../common/gpio.h"
#include "../../../common/clock_width.h" // CONTRACTS.md #36: F_CPU width guard
// CONTRACTS.md #amass-floor: this port's floor (200 MHz -> 381
// steps/sec, 57.2 mm/min @ 400 steps/mm / 286.1 mm/min @ 80 steps/mm)
// exceeds amass_floor.h's 200 steps/sec threshold. Acknowledged, not
// fixed: the real remedy is a platform-owned divided/prescaled stepper-
// timer input clock (sg2002/Makefile precedent), which is real per-port
// clock-tree hardware work outside this investigation's scope. See
// CONTRACTS.md #amass-floor for the full arithmetic and severity call.
#define GRBL_ACKNOWLEDGE_AMASS_FLOOR
#include "../../../common/amass_floor.h"
#include "config.h"
#include "../../platform.h"

/*
  FP PRECISION KNOB (CONTRACTS.md #17, samd21 prelude the origin pattern) -
  this port's Makefile defaults FP=DOUBLE (native DP FPU, declared port
  property - see Makefile comment) so GRBL_FP_SINGLE is normally NOT
  defined and this whole block is inert. It exists so `make FP=SINGLE`
  still works (the knob is bidirectional) - a board without this shim
  would silently opt out of the SP pin the same way the samd21 precedent
  warns about.
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

#endif // GRBL_PRELUDE_DSPIC33AK128MC102_GENERIC_H
