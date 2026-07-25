/*
  prelude.h - build prelude for STM32F411 ("Black Pill")
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Injected into every translation unit by the Makefile via -include, same
  pattern as samd21's $(BOARD)/prelude.h and stm32f103/stm32h523's prelude.h.
  Order is load-bearing:

    1. gpio.h               STM32F411 register accessors (GPIO_OREG/IREG) and
                            MODER/PUPDR-based direction/pull overrides. MUST
                            come first: platform/common/gpio.h only supplies
                            AVR-style defaults for names not already defined.
    2. ../common/gpio.h     Generic GPIO bit-op helpers (GPIO_MWO, GPIO_MRD,
                            GPIO_BGETOUT, ...) built on the accessors above.

  The pin map and chip HAL (platform.h, which includes timer.h) arrive through
  grbl.h's ordinary include chain (grbl.h -> platform/hal.h -> platform.h).

  GRBL_PRELUDE is the marker grbl/platform/hal.h checks to reject compiles
  that bypass the platform Makefile.
*/

#ifndef GRBL_PRELUDE_STM32F411_H
#define GRBL_PRELUDE_STM32F411_H

#define GRBL_PRELUDE 1

#include "gpio.h"
#include "../common/gpio.h"

#endif // GRBL_PRELUDE_STM32F411_H
