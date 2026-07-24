/*
  prelude.h - build prelude for STM32F103 (Blue Pill)
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Injected into every translation unit by the Makefile via -include, same
  pattern as samd21's $(BOARD)/prelude.h. Unlike samd21 (whose prelude chains
  GPIO register accessors, common/gpio.h helpers, the board pin map and
  platform.h), stm32f103 currently takes everything through grbl.h's ordinary
  include chain, so this prelude deliberately includes nothing - it only
  carries the GRBL_PRELUDE marker that grbl/platform/hal.h checks to reject
  compiles that bypass the platform Makefile.

  When this platform grows -include needs (e.g. common/gpio.h injection for
  the GPIO_* macro family), add them HERE, in dependency order, instead of
  adding new -include flags to the Makefile.
*/

#ifndef GRBL_PRELUDE_STM32F103_H
#define GRBL_PRELUDE_STM32F103_H

#define GRBL_PRELUDE 1

#endif // GRBL_PRELUDE_STM32F103_H
