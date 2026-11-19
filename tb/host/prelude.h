/* prelude.h - forced include (-include) for the host build of real grbl sources.
   Makes the host closer to avr-gcc semantics where it matters for float code:
   on AVR double == float, so double math calls and unsuffixed literals are single
   precision. Literals are handled by -fsingle-precision-constant; calls here. */
#ifndef TB_PRELUDE_H
#define TB_PRELUDE_H
#include <math.h>
#ifndef TB_HOST_DOUBLE
  #define sqrt  sqrtf
  #define fabs  fabsf
  #define floor floorf
  #define ceil  ceilf
  #define round roundf
  #define trunc truncf
  #define lround lroundf
  #define atan2 atan2f
  #define sin   sinf
  #define cos   cosf
#endif
#endif
