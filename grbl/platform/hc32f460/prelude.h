/*
  prelude.h - build prelude for HC32F460
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Injected into every translation unit by the Makefile via -include, same
  pattern as every other non-AVR port in this tree. Order is load-bearing:

    1. gpio.h               HC32F460 register accessors (GPIO_OREG/IREG) and
                            PCONR-based direction/pull overrides. MUST come
                            first: platform/common/gpio.h only supplies
                            AVR-style defaults for names not already defined.
    2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                            GPIO_BGETOUT, ...) built on the accessors above.
    3. ../common/cortexm/cortexm_critical.h
                            sei/cli plus the HAL critical-section and
                            interrupt-control macros, shared verbatim by every
                            Cortex-M port here. MUST be injected before grbl.h:
                            grbl.h pulls <avr/io.h> (the shared common/dummy
                            stub) at its line 29, and that stub errors out
                            unless sei/cli already exist. This port used to
                            satisfy that with a LOCAL avr/io.h shadowing the
                            shared stub; see that header for the full argument.

  The pin map and chip HAL (platform.h, which includes regs.h/timer.h)
  arrive through grbl.h's ordinary include chain (grbl.h -> platform/hal.h
  -> platform.h). GRBL_PRELUDE is the marker grbl/platform/hal.h checks to
  reject compiles that bypass the platform Makefile.
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
