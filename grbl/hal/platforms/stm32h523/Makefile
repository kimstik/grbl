# Makefile for GRBL on STM32H523
# Part of Grbl
#
# Copyright (c) 2025 kimstik
# Intelligence assisted
# License: MIT
#
# STM32H523CBT6: ARM Cortex-M33, 250MHz, 32KB RAM, 128KB Flash

# Build configuration
BUILD ?= DEBUG

# Device settings
DEVICE     = STM32H523xx
CPU        = cortex-m33
CLOCK      = 250000000
FPU        = -mfpu=fpv5-sp-d16 -mfloat-abi=hard

# Toolchain
PREFIX     = arm-none-eabi-
CC         = $(PREFIX)gcc
OBJCOPY    = $(PREFIX)objcopy
SIZE       = $(PREFIX)size
GDB        = $(PREFIX)gdb

# Paths
GRBL_DIR   = ../../..
BUILD_DIR  = $(GRBL_DIR)/../build_h523_$(BUILD)
PLATFORM_DIR = .

SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
          protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
          print.c probe.c report.c system.c \
          platform.c startup.c handlers.c flash.c

# STM32 common code
SOURCES += ../stm32_common/stm32_nvmem.c \
           ../stm32_common/stm32_timing.c \
           ../stm32_common/stm32_watchdog.c

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
CFLAGS += -DPLATFORM_STM32H523 -DF_CPU=$(CLOCK)
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -I$(GRBL_DIR) -I$(PLATFORM_DIR) -I../stm32_common

# Build-specific flags
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  CFLAGS += -DENABLE_WATCHDOG
  CFLAGS += -DNDEBUG
else
  CFLAGS += -O0 -g3
endif

# Linker flags
LDFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/grbl_h523.map
LDFLAGS += -specs=nano.specs -specs=nosys.specs
LDFLAGS += -T stm32h523.ld
LDFLAGS += -lm

# Targets
all: $(BUILD_DIR) grbl_h523.hex grbl_h523.bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile GRBL core files
$(BUILD_DIR)/%.o: $(GRBL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile platform-specific files
$(BUILD_DIR)/platform.o: platform.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/startup.o: startup.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/exti_handlers.o: handlers.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/flash.o: flash.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile STM32 common files
$(BUILD_DIR)/stm32_nvmem.o: ../stm32_common/stm32_nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/stm32_timing.o: ../stm32_common/stm32_timing.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/stm32_watchdog.o: ../stm32_common/stm32_watchdog.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link
$(BUILD_DIR)/grbl_h523.elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS)
	$(SIZE) --format=berkeley $@

# Create hex file
$(BUILD_DIR)/grbl_h523.hex: $(BUILD_DIR)/grbl_h523.elf
	$(OBJCOPY) -O ihex $< $@

# Create binary file
$(BUILD_DIR)/grbl_h523.bin: $(BUILD_DIR)/grbl_h523.elf
	$(OBJCOPY) -O binary $< $@

# Convenience targets
grbl_h523.hex: $(BUILD_DIR)/grbl_h523.hex
grbl_h523.bin: $(BUILD_DIR)/grbl_h523.bin

# Flash using st-link
flash: $(BUILD_DIR)/grbl_h523.bin
	st-flash write $< 0x8000000

# Flash using OpenOCD
flash-openocd: $(BUILD_DIR)/grbl_h523.hex
	openocd -f interface/stlink.cfg -f target/stm32h5x.cfg \
	        -c "program $< verify reset exit"

# Debug with gdb
debug: $(BUILD_DIR)/grbl_h523.elf
	$(GDB) $<

# Clean
clean:
	rm -rf $(BUILD_DIR)

clean-all:
	rm -rf $(GRBL_DIR)/../build_h523_DEBUG $(GRBL_DIR)/../build_h523_RELEASE

# Help
help:
	@echo "GRBL STM32H523 Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make              - Build DEBUG version (default)"
	@echo "  make BUILD=DEBUG  - Build with debugging symbols"
	@echo "  make BUILD=RELEASE - Build optimized for production"
	@echo ""
	@echo "Other targets:"
	@echo "  make flash        - Flash using st-link"
	@echo "  make flash-openocd - Flash using OpenOCD"
	@echo "  make debug        - Start GDB debugger"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all clean clean-all flash flash-openocd debug help

# Include dependencies
-include $(BUILD_DIR)/*.d
