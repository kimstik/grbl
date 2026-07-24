/*
  prelude.h - build prelude for Sophgo SG2002 (LicheeRV-Nano)
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Injected into every translation unit by the Makefile via -include, same
  pattern as samd21's $(BOARD)/prelude.h. Unlike samd21 (whose prelude chains
  GPIO register accessors, common/gpio.h helpers, the board pin map and
  platform.h), sg2002 currently takes everything through grbl.h's ordinary
  include chain, so this prelude deliberately includes nothing - it only
  carries the GRBL_PRELUDE marker that grbl/platform/hal.h checks to reject
  compiles that bypass the platform Makefile.

  When this platform grows -include needs, add them HERE, in dependency
  order, instead of adding new -include flags to the Makefile.
*/

#ifndef GRBL_PRELUDE_SG2002_H
#define GRBL_PRELUDE_SG2002_H

#define GRBL_PRELUDE 1

#endif // GRBL_PRELUDE_SG2002_H
