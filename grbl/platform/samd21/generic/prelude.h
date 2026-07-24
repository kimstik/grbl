/*
  prelude.h - build prelude for SAMD21 / generic board
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  This is the ONE header the platform Makefile injects into every translation
  unit via `-include $(BOARD)/prelude.h`.  It replaces the former chain of
  four separate -include flags and preserves their exact order, which is
  load-bearing:

    1. ../gpio.h            SAMD21 register accessors (GPIO_OREG/IREG/DREG/PREG).
                            MUST come first: platform/common/gpio.h only
                            supplies AVR-style defaults for accessors that are
                            not already defined.
    2. ../../common/gpio.h  Generic GPIO bit-op helpers (GPIO_BSET, ...) built
                            on top of the accessors from step 1.
    3. config.h             Board pin map (this directory). Board selection is
                            the Makefile pointing -include at <board>/prelude.h.
    4. ../platform.h        Chip-specific HAL: registers, EIC macros, sei/cli.
                            Must be injected before grbl.h so that
                            common/dummy/avr/io.h sees sei/cli already defined.

  GRBL_PRELUDE is the marker grbl/platform/hal.h checks in order to fail
  loudly when a non-AVR translation unit is compiled without this injection
  (e.g. by invoking the compiler manually instead of the platform Makefile).

  To create a custom board: copy the generic/ directory, adjust config.h -
  this file usually needs nothing but its header guard renamed.
*/

#ifndef GRBL_PRELUDE_SAMD21_GENERIC_H
#define GRBL_PRELUDE_SAMD21_GENERIC_H

#define GRBL_PRELUDE 1

#include "../gpio.h"
#include "../../common/gpio.h"
#include "config.h"
#include "../platform.h"

#endif // GRBL_PRELUDE_SAMD21_GENERIC_H
