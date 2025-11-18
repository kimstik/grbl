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

# Include common build rules
include ../stm32_common/common.mk
