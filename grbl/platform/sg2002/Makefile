#  Makefile for GRBL on Sophgo SG2002 (LicheeRV-Nano)
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  Sophgo SG2002: RISC-V C906, 700MHz, RV64IMAFDC, 256MB DDR3

# Platform-specific configuration
PLATFORM_NAME  = sg2002
DEVICE         = SG2002
CPU            = rv64imafdc
ARCH           = rv64gc
ABI            = lp64d
CLOCK          = 700000000
CMODEL         = medany

# Toolchain
TOOLCHAIN_PATH ?=
ifdef TOOLCHAIN_PATH
  PREFIX     = $(TOOLCHAIN_PATH)/riscv64-unknown-elf-
else
  PREFIX     = riscv64-unknown-elf-
endif
CC         = $(PREFIX)gcc
OBJCOPY    = $(PREFIX)objcopy
SIZE       = $(PREFIX)size
GDB        = $(PREFIX)gdb

# Paths
GRBL_DIR   = ../..
BUILD_DIR  = ../../../build_$(PLATFORM_NAME)_$(BUILD)
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

# AVR stubs (temporary workaround for grbl.h AVR includes)
# Platform dir must be first to override cpu_map.h
CFLAGS_EXTRA   = -I. -I../common/dummy

# Base compiler flags
CFLAGS  = -march=$(ARCH) -mabi=$(ABI) -mcmodel=$(CMODEL)
CFLAGS += -mtune=thead-c906
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/hal -I$(GRBL_DIR)

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
LDFLAGS  = -march=$(ARCH) -mabi=$(ABI) -mcmodel=$(CMODEL)
LDFLAGS += -mtune=thead-c906
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/grbl_$(PLATFORM_NAME).map
LDFLAGS += -nostartfiles
LDFLAGS += -T script.ld

# LTO for release builds
ifeq ($(BUILD),RELEASE)
  LDFLAGS += -flto -Os
endif

# Libraries
LIBS = -lm

# Output files
ELF_FILE = $(BUILD_DIR)/grbl_$(PLATFORM_NAME).elf
BIN_FILE = $(BUILD_DIR)/grbl_$(PLATFORM_NAME).bin
HEX_FILE = $(BUILD_DIR)/grbl_$(PLATFORM_NAME).hex

# ============================================================================
# TARGETS
# ============================================================================

all: $(BUILD_DIR) $(ELF_FILE) $(HEX_FILE) $(BIN_FILE)

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

# Clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean

# Include dependency files
-include $(BUILD_DIR)/*.d
