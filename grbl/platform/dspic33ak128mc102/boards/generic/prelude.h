/*
  prelude.h - build prelude for dsPIC33AK128MC102 / generic board
  Part of Grbl

  ONE header the platform Makefile injects into every translation unit
  via `-include boards/$(BOARD)/prelude.h` (post-prelude canon, see
  samd21/generic/prelude.h for the original writeup). Order is
  load-bearing (CONTRACTS.md #0):

    1. ../../gpio.h              dsPIC33AK register accessors (LATx/PORTx/
                                  TRISx token-paste dispatch). MUST come
                                  first: ../../../common/gpio.h only
                                  supplies AVR-style defaults for
                                  accessors not already defined.
    2. ../../../common/gpio.h    Generic GPIO bit-op helpers built on
                                  top of the accessors from step 1.
    3. config.h                  Board pin map (this directory).
    4. ../../platform.h          Chip-specific HAL: sei/cli, critical
                                  sections, GPIO interrupt macros. Must
                                  be injected before grbl.h so that
                                  common/dummy/avr/io.h sees sei/cli
                                  already defined.

  GRBL_PRELUDE is the marker grbl/platform/hal.h checks to fail loudly
  when a non-AVR translation unit is compiled without this injection.
*/

#ifndef GRBL_PRELUDE_DSPIC33AK128MC102_GENERIC_H
#define GRBL_PRELUDE_DSPIC33AK128MC102_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../gpio.h"
#include "../../../common/gpio.h"
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
