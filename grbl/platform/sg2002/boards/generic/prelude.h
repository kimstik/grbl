/*
  prelude.h - build prelude for SG2002 / generic board
  Part of Grbl

  ONE header the platform Makefile injects into every translation unit via
  `-include boards/$(BOARD)/prelude.h` (CONTRACTS.md #0). The order below is
  load-bearing:

    1. ../../gpio.h            SG2002 register accessors. MUST come first:
                                ../../../common/gpio.h only fills in
                                AVR-shaped defaults for accessors that are
                                not already defined.
    2. ../../../common/gpio.h  Generic bit-op helpers built on those
                                accessors.
    3. config.h                Board pin map (this directory).
    4. ../../platform.h        Chip HAL: sei/cli, critical sections, GPIO
                                interrupt macros, timer.h. Must be injected
                                before grbl.h so common/dummy/avr/io.h sees
                                sei/cli already defined.

  GRBL_PRELUDE is the marker grbl/platform/hal.h checks, so a translation
  unit compiled without this injection fails loudly instead of mis-building.
*/

#ifndef GRBL_PRELUDE_SG2002_GENERIC_H
#define GRBL_PRELUDE_SG2002_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../../common/clock_width.h" // CONTRACTS.md #36: F_CPU width guard
#include "../../gpio.h"
#include "../../../common/gpio.h"
#include "config.h"
#include "../../platform.h"

/*
  SINGLE-PRECISION LIBM PIN - armed only when the Makefile's FP knob is
  SINGLE (CONTRACTS.md #17). Pairs with -fsingle-precision-constant: the flag
  keeps unsuffixed literals float, these macros keep libm CALL SITES float.
  Function-like macros rewrite calls only - prototypes and bare identifiers
  are untouched, which is why this beats -Wl,--wrap (that would keep the
  double ABI at every call site and pay for narrowing wrappers on top).

  This shim belongs in EVERY board's prelude, not one of them: boards are
  selected by which prelude the Makefile injects, so a board without it
  silently opts out of the whole knob.

  On this port the leak the knob plugs is exactly as real as on ch32v006 and
  ch570 - rv64imac has no F extension, so a promoted double drags in the full
  DP soft-float and DP libm set. The post-link assert
  (tools/assert_no_double.sh) is what actually proves it worked.
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

#endif // GRBL_PRELUDE_SG2002_GENERIC_H
