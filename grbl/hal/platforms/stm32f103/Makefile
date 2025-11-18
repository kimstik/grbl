#  Makefile for GRBL on STM32F103 (Blue Pill)
#  Part of Grbl
#
#  Copyright (c) 2025 Grbl HAL Contributors
#
#  STM32F103C8T6: ARM Cortex-M3, 72MHz, 20KB RAM, 64KB Flash

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
BUILD_DIR  = $(GRBL_DIR)/../build_stm32
PLATFORM_DIR = .

SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
          protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
          print.c probe.c report.c system.c \
          platform.c startup_stm32f103.c exti_handlers.c

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb
CFLAGS += -DPLATFORM_STM32F103 -DF_CPU=$(CLOCK)
CFLAGS += -Wall -Wextra
CFLAGS += -Os -g3
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -I$(GRBL_DIR) -I$(PLATFORM_DIR)

# Linker flags
LDFLAGS  = -mcpu=$(CPU) -mthumb
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/grbl_stm32.map
LDFLAGS += -specs=nano.specs -specs=nosys.specs
LDFLAGS += -T stm32f103c8.ld
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

$(BUILD_DIR)/exti_handlers.o: exti_handlers.c | $(BUILD_DIR)
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

# Clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean flash flash-openocd debug

# Include dependencies
-include $(BUILD_DIR)/*.d
