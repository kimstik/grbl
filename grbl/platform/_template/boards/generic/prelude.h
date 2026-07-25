/*
  prelude.h - build prelude for _template / generic board (copy-me starting point)
  Part of Grbl

  This is the ONE header the platform Makefile injects into every
  translation unit via `-include boards/$(BOARD)/prelude.h`
  (post-prelude canon - see grbl/platform/samd21/generic/prelude.h for the
  original writeup). It replaces a hand-maintained chain of separate
  -include flags and fixes their order, which is load-bearing:

    1. ../../gpio.h        This platform's register accessors
                            (GPIO_OREG/IREG/DREG/PREG). MUST come first:
                            ../../../common/gpio.h only supplies AVR-style
                            defaults for accessors that are not already
                            defined.
    2. ../../../common/gpio.h   Generic GPIO bit-op helpers (GPIO_BSET, ...)
                            built on top of the accessors from step 1.
    3. config.h             Board pin map (this directory). Board selection
                            is just the Makefile's BOARD variable pointing
                            -include at a different boards/<name>/prelude.h.
    4. ../../platform.h     Chip-specific HAL: sei/cli, critical sections,
                            GPIO interrupt macros. Must be injected before
                            grbl.h so that common/dummy/avr/io.h sees
                            sei/cli already defined.

  GRBL_PRELUDE is the marker grbl/platform/hal.h checks in order to fail
  loudly when a non-AVR translation unit is compiled without this
  injection (e.g. by invoking the compiler manually instead of the
  platform Makefile).

  To create a custom board: copy this whole boards/generic/ directory,
  adjust config.h - this file usually needs nothing but its header guard
  renamed.
*/

#ifndef GRBL_PRELUDE_TEMPLATE_GENERIC_H
#define GRBL_PRELUDE_TEMPLATE_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../gpio.h"
#include "../../../common/gpio.h"
#include "config.h"
#include "../../platform.h"

#endif // GRBL_PRELUDE_TEMPLATE_GENERIC_H
