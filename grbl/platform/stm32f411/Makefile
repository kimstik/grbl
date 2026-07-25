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
# Hardware FPU present (single-precision, FPv4-SP-D16) and core grbl is
# float-heavy throughout (planner/gcode/motion_control) - CONTRACTS.md
# porting-checklist Step 1 FPU note. -mfloat-abi=hard passes float args in
# FPU registers (fastest calling convention); it requires libgcc/libm/newlib
# variants built for hard-float, which arm-none-eabi's multilib provides for
# fpv4-sp-d16 (verified: this toolchain's default multilib includes a
# hard-float fpv4-sp-d16 variant, unlike the ch32v006 rv32ec case where no
# hardware F/D extension exists at all - CONTRACTS.md section 14.4). Falling
# back to softfp would still interoperate ABI-wise with any hard-float object
# but throws away the FPU register-passing benefit that is the whole reason
# to port to an FPU-bearing chip; hard is used here as done on stm32h523
# (same FPU class one notch up, fpv5-sp-d16).
FPU            = -mfpu=fpv4-sp-d16 -mfloat-abi=hard
OPENOCD_TARGET = stm32f4x.cfg

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
# prelude.h is the single injected build prelude (defines GRBL_PRELUDE,
# checked by grbl/platform/hal.h) - same pattern as samd21's $(BOARD)/prelude.h
CFLAGS_EXTRA   = -I. -I../common/dummy -include prelude.h

# Include common build rules
include ../common/stm32/common.mk
