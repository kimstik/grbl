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
# BUG #20: H523's flash erase granularity is a fixed 8KB sector (flash.c
# computes page_num = addr/8192; there is no smaller erase unit on this
# family), so FLASH_NUM_PAGES=1 in config.h already gives the smallest
# possible NVMEM window at 8192B - it can't be shrunk to fit the common
# code's 4096B default. Override the shared cache buffer in
# common/stm32/stm32_nvmem.c to match instead (see stm32_nvmem.h).
CFLAGS_EXTRA  += -DNVMEM_WINDOW_SIZE=8192

# Include common build rules
include ../common/stm32/common.mk
