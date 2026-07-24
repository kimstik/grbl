#  Makefile for GRBL on STM32H523
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  STM32H523CBT6: ARM Cortex-M33, 250MHz, 32KB RAM, 128KB Flash

# Platform-specific configuration
PLATFORM_NAME  = stm32h523
DEVICE         = STM32H523
CPU            = cortex-m33
CLOCK          = 250000000
FPU            = -mfpu=fpv5-sp-d16 -mfloat-abi=hard
OPENOCD_TARGET = stm32h5x.cfg

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
# NOTE: this line was missing entirely (copy/paste omission vs stm32f103's
# Makefile), which made every build die at `avr/pgmspace.h: No such file`.
# prelude.h is the single injected build prelude (defines GRBL_PRELUDE,
# checked by grbl/platform/hal.h) - same pattern as samd21's $(BOARD)/prelude.h
CFLAGS_EXTRA   = -I. -I../common/dummy -include prelude.h

# Include common build rules
include ../common/stm32/common.mk
