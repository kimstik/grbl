#  Makefile for GRBL on STM32F411 (Black Pill)
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  STM32F411CEU6: ARM Cortex-M4F, 96MHz (25MHz HSE * 192/25/2), 128KB RAM, 512KB Flash

# Platform-specific configuration
PLATFORM_NAME  = stm32f411
DEVICE         = STM32F411
CPU            = cortex-m4
CLOCK          = 96000000
# fpv4-sp-d16 hardware FPU (single-precision); -mfloat-abi=hard for FPU
# register-passing, same class as stm32h523 (fpv5-sp-d16).
FPU            = -mfpu=fpv4-sp-d16 -mfloat-abi=hard
OPENOCD_TARGET = stm32f4x.cfg

# Flash window for the post-link BOOT INTEGRITY check. Must match script.ld's
# MEMORY{FLASH} - 0x08000000, 512K. (BUG #21 ratchet, CONTRACTS.md S18)
FLASH_ORIGIN   = 0x08000000
FLASH_LENGTH   = 524288

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
# prelude.h is the single injected build prelude (defines GRBL_PRELUDE,
# checked by grbl/platform/hal.h) - same pattern as samd21's $(BOARD)/prelude.h
CFLAGS_EXTRA   = -I. -I../common/dummy -include prelude.h

# Include common build rules
include ../common/stm32/common.mk
