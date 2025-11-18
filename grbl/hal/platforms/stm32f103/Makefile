#  Makefile for GRBL on STM32F103 (Blue Pill)
#  Part of Grbl
#
#  Copyright (c) 2025 Grbl HAL Contributors
#
#  STM32F103C8T6: ARM Cortex-M3, 72MHz, 20KB RAM, 64KB Flash

# Build configuration (make BUILD=DEBUG or BUILD=RELEASE)
# Default is DEBUG for development convenience
BUILD ?= DEBUG

# Device settings
DEVICE     = STM32F103xB
CPU        = cortex-m3
CLOCK      = 72000000

# Toolchain
PREFIX     = arm-none-eabi-
CC         = $(PREFIX)gcc
OBJCOPY    = $(PREFIX)objcopy
SIZE       = $(PREFIX)size
GDB        = $(PREFIX)gdb

# Paths (Makefile is in grbl/hal/platforms/stm32f103/)
GRBL_DIR   = ../../..
BUILD_DIR  = $(GRBL_DIR)/../build_stm32_$(BUILD)
PLATFORM_DIR = .

SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
          protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
          print.c probe.c report.c system.c \
          platform.c startup_stm32f103.c handlers.c

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb
CFLAGS += -DPLATFORM_STM32F103 -DF_CPU=$(CLOCK)
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -I$(GRBL_DIR) -I$(PLATFORM_DIR)

# Build-specific flags
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0              # Optimize for size, no debug symbols
  CFLAGS += -DENABLE_WATCHDOG    # Enable watchdog in release builds
  CFLAGS += -DNDEBUG             # Disable assertions
else
  CFLAGS += -O0 -g3              # No optimization, full debug symbols
  # Watchdog disabled by default in debug builds (enable manually if needed)
  # CFLAGS += -DENABLE_WATCHDOG
endif

# Linker flags
LDFLAGS  = -mcpu=$(CPU) -mthumb
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/grbl_stm32.map
LDFLAGS += -specs=nano.specs -specs=nosys.specs
LDFLAGS += -T script.ld
LDFLAGS += -lm

# Targets
all: $(BUILD_DIR) grbl_stm32.hex grbl_stm32.bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile GRBL core files
$(BUILD_DIR)/%.o: $(GRBL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile platform-specific files (from current directory)
$(BUILD_DIR)/platform.o: platform.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/startup_stm32f103.o: startup_stm32f103.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/exti_handlers.o: handlers.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link
$(BUILD_DIR)/grbl_stm32.elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS)
	$(SIZE) --format=berkeley $@

# Create hex file
$(BUILD_DIR)/grbl_stm32.hex: $(BUILD_DIR)/grbl_stm32.elf
	$(OBJCOPY) -O ihex $< $@

# Create binary file
$(BUILD_DIR)/grbl_stm32.bin: $(BUILD_DIR)/grbl_stm32.elf
	$(OBJCOPY) -O binary $< $@

# Convenience targets
grbl_stm32.hex: $(BUILD_DIR)/grbl_stm32.hex
grbl_stm32.bin: $(BUILD_DIR)/grbl_stm32.bin

# Flash using st-link
flash: $(BUILD_DIR)/grbl_stm32.bin
	st-flash write $< 0x8000000

# Flash using openocd
flash-openocd: $(BUILD_DIR)/grbl_stm32.hex
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	        -c "program $< verify reset exit"

# Debug with gdb
debug: $(BUILD_DIR)/grbl_stm32.elf
	$(GDB) $<

# Clean (clean current build or clean-all for both DEBUG and RELEASE)
clean:
	rm -rf $(BUILD_DIR)

clean-all:
	rm -rf $(GRBL_DIR)/../build_stm32_DEBUG $(GRBL_DIR)/../build_stm32_RELEASE

# Help
help:
	@echo "GRBL STM32F103 Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make              - Build DEBUG version (default)"
	@echo "  make BUILD=DEBUG  - Build with debugging symbols, no optimization"
	@echo "  make BUILD=RELEASE - Build optimized for production (watchdog enabled)"
	@echo ""
	@echo "Other targets:"
	@echo "  make flash        - Flash using st-link"
	@echo "  make flash-openocd - Flash using OpenOCD"
	@echo "  make debug        - Start GDB debugger"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds (DEBUG and RELEASE)"
	@echo ""
	@echo "Build configuration:"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all clean clean-all flash flash-openocd debug help

# Include dependencies
-include $(BUILD_DIR)/*.d
