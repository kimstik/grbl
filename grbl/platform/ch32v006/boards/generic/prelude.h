/*
  prelude.h - build prelude for CH32V006 / generic board
  Part of Grbl

  ONE header the platform Makefile injects into every translation unit
  via `-include boards/$(BOARD)/prelude.h` (post-prelude canon, see
  samd21/generic/prelude.h for the original writeup). Order is
  load-bearing (CONTRACTS.md #0):

    1. ../../gpio.h              CH32V006 register accessors. MUST come
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

#ifndef GRBL_PRELUDE_CH32V006_GENERIC_H
#define GRBL_PRELUDE_CH32V006_GENERIC_H

#define GRBL_PRELUDE 1

#include "../../gpio.h"
#include "../../../common/gpio.h"
#include "config.h"
#include "../../platform.h"

#endif // GRBL_PRELUDE_CH32V006_GENERIC_H
