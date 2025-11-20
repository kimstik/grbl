#  Makefile for GRBL on SAMD21G18A
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  SAMD21G18A: ARM Cortex-M0+, 48MHz, 32KB RAM, 256KB Flash
#  Used in Arduino Zero, MKR series

# Platform-specific configuration
PLATFORM_NAME  = samd21
DEVICE         = SAMD21G18A
CPU            = cortex-m0plus
CLOCK          = 48000000
FPU            =                # Cortex-M0+ has no FPU
OPENOCD_TARGET = at91samdXX.cfg

# Board selection (override with make BOARD=generic)
BOARD         ?= megarm

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD)

# Include board-specific config
CFLAGS_EXTRA  += -include $(BOARD)/config.h

# Toolchain
TOOLCHAIN_PATH ?=
ifdef TOOLCHAIN_PATH
  PREFIX     = $(TOOLCHAIN_PATH)/arm-none-eabi-
else
  PREFIX     = arm-none-eabi-
endif
CC         = $(PREFIX)gcc
OBJCOPY    = $(PREFIX)objcopy
OBJDUMP    = $(PREFIX)objdump
SIZE       = $(PREFIX)size
GDB        = $(PREFIX)gdb

# Paths
GRBL_DIR   = ../..
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources (from grbl directory)
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
               protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources
PLATFORM_SOURCES = platform.c startup.c handlers.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources
vpath %.c $(GRBL_DIR)
vpath %.c $(PLATFORM_DIR)

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Floating point: default is float (single precision) - software emulation on M0+
# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  CFLAGS += -flto -fno-fat-lto-objects
  CFLAGS += -DNDEBUG
else
  CFLAGS += -O0 -g3
endif

# Linker flags
LDFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(MAP_FILE)
LDFLAGS += -specs=nano.specs -specs=nosys.specs
LDFLAGS += -T script.ld

# LTO for release builds
ifeq ($(BUILD),RELEASE)
  LDFLAGS += -flto -Os
endif

# Libraries (must come after objects in link command)
LIBS = -lm

# Output file naming: release gets clean name, debug gets _dbg suffix
ifeq ($(BUILD),RELEASE)
  BINARY_NAME = grbl_$(PLATFORM_NAME)
else
  BINARY_NAME = grbl_$(PLATFORM_NAME)_dbg
endif

# Output files - artifacts go to /build, object files to /build/$(PLATFORM_NAME)
ELF_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).elf
HEX_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).hex
BIN_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).bin
DUMP_FILE = $(OUTPUT_DIR)/$(BINARY_NAME).dump
MAP_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).map

# ============================================================================
# TARGETS
# ============================================================================

all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE) $(DUMP_FILE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Compile GRBL core files
$(BUILD_DIR)/%.o: $(GRBL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile platform-specific files
$(BUILD_DIR)/platform.o: platform.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/startup.o: startup.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/handlers.o: handlers.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link
$(ELF_FILE): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $@

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@

# Create disassembly dump
$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

# Flash using OpenOCD
flash: $(HEX_FILE)
	openocd -f interface/cmsis-dap.cfg -f target/$(OPENOCD_TARGET) \
	        -c "program $< verify reset exit"

# Flash using BOSSA (native Arduino Zero bootloader)
flash-bossa: $(BIN_FILE)
	bossac -i -d -U -e -w -v -R -p ttyACM0 $<

# Debug with gdb
debug: $(ELF_FILE)
	$(GDB) $<

# Clean platform-specific files only
clean:
	rm -f $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.elf \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.hex \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.bin \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.dump \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.map
	rm -rf $(BUILD_DIR)

# Clean all build artifacts
clean-all:
	rm -rf $(OUTPUT_DIR)

# Help
help:
	@echo "GRBL $(PLATFORM_NAME) Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make              - Build DEBUG version (default)"
	@echo "  make BUILD=DEBUG  - Build with debugging symbols"
	@echo "  make BUILD=RELEASE - Build optimized for production"
	@echo ""
	@echo "Other targets:"
	@echo "  make flash        - Flash using OpenOCD"
	@echo "  make flash-bossa  - Flash using BOSSA (Arduino bootloader)"
	@echo "  make debug        - Start GDB debugger"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform = $(PLATFORM_NAME)"
	@echo "  CPU = $(CPU)"
	@echo "  Clock = $(CLOCK) Hz"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all clean clean-all flash flash-bossa debug help

# Include dependencies
-include $(BUILD_DIR)/*.d
