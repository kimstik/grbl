#  Makefile for GRBL on STM32F103 (Blue Pill)
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  STM32F103C8T6: ARM Cortex-M3, 72MHz, 20KB RAM, 64KB Flash

# Platform-specific configuration
PLATFORM_NAME  = stm32f103
DEVICE         = STM32F103
CPU            = cortex-m3
CLOCK          = 72000000
FPU            =
OPENOCD_TARGET = stm32f1x.cfg

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
CFLAGS_EXTRA   = -I. -I./avr_stubs

# Include common build rules
include ../stm32_common/common.mk
