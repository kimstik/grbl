#  common.mk - Common Makefile rules for all STM32 platforms
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  This file contains shared build rules for all STM32 platforms.
#  Platform-specific Makefiles should define:
#    PLATFORM_NAME - Platform identifier (e.g., stm32f103, stm32h523)
#    CPU           - ARM core (e.g., cortex-m3, cortex-m33)
#    CLOCK         - CPU frequency in Hz
#    FPU           - FPU flags (empty for M3, -mfpu=... for M4/M33)
#    DEVICE        - Device define (e.g., STM32F103xB, STM32H523xx)
#    OPENOCD_TARGET - OpenOCD target config (e.g., stm32f1x.cfg, stm32h5x.cfg)
#    FLASH_ORIGIN  - Flash base address, must match script.ld (e.g. 0x08000000)
#    FLASH_LENGTH  - Flash size in bytes, must match script.ld (e.g. 65536)
#
#  and MAY override:
#    INIT_SYMBOLS  - comma-separated boot-init symbols that must survive the
#                    link (BUG #23 ratchet, see the default below)

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards).
.DELETE_ON_ERROR:

# Build configuration
BUILD ?= DEBUG

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
# Keyed by BUILD flavor: DEBUG/RELEASE object dirs never alias, so switching
# flavors without `make clean` can't silently relink stale objects under the
# wrong name (bit samd21 twice - see PLAN.md/CONTRACTS.md). Shared here so
# both stm32f103 and stm32h523 get the fix from one place.
OUTPUT_DIR = ../../../build
# Whole-platform object root (both BUILD flavors live under here) - `clean`
# below removes THIS, not just $(BUILD_DIR), so it can't leave the OTHER
# flavor's stale objects behind for a knob change (FP=, or any -D) to
# silently relink under the wrong label (CONTRACTS.md gap log: "make clean
# cleans only the invoked BUILD flavor's object dir"). Shared here so
# every STM32 family Makefile including this file gets the fix from one
# place, same as the BUILD_DIR keying above.
PLATFORM_BUILD_ROOT = $(OUTPUT_DIR)/$(PLATFORM_NAME)
BUILD_DIR  = $(PLATFORM_BUILD_ROOT)/$(BUILD)
PLATFORM_DIR = .

# GRBL core sources (from grbl directory)
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
               protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources
PLATFORM_SOURCES = platform.c startup.c handlers.c flash.c

# STM32 common code
COMMON_DIR = ../common/stm32
COMMON_SOURCES = $(COMMON_DIR)/stm32_nvmem.c \
                 $(COMMON_DIR)/stm32_timing.c \
                 $(COMMON_DIR)/stm32_watchdog.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES) \
          $(COMMON_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources
vpath %.c $(GRBL_DIR)
vpath %.c $(PLATFORM_DIR)
vpath %.c $(COMMON_DIR)

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
# BUG #18 class, widened: plain UL is NOT enough here. F_CPU feeds
# stepper.c:1015's `TICKS_PER_MICROSECOND*1000000*60`, a compile-time
# constant; on this ABI unsigned long is still 32-bit, so it only avoids
# overflow up to ~71 MHz - every port on this file (72/96/250 MHz) exceeds
# that and silently wraps to the WRONG constant with no warning (unsigned
# wraparound isn't diagnosed, unlike signed). ULL is unsigned long long,
# >=64-bit on every ISO C target, so the constant folds correctly at any
# real clock. Verified: arm-none-eabi-gcc -S at 250 MHz emits the exact
# 15000000000 value with ULL vs a silently wrapped 2115098112 with UL.
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)ULL
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding): -g3 embeds this Makefile's
# absolute cwd (DW_AT_comp_dir) into debug info, so a DEBUG .elf built from
# an identical tree checked out at a different absolute path is a
# different file. Verified this batch: RELEASE (-g0, no debug info) is
# UNCHANGED by this flag (nothing to remap); DEBUG becomes fully
# path-independent with it (0-byte diff across two differently-pathed
# checkouts, was a 20-byte path-length-sized diff without it). The target
# string is arbitrary - only that it is IDENTICAL across checkouts matters.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# FP PRECISION KNOB (CONTRACTS.md #17). Shared here for every STM32 family
# using this common.mk (f103/h523/f411) - see samd21/Makefile for the full
# rationale. On h523/f411 (SP-only hardware FPU) it also turns soft-float
# calls into real FPU instructions - a speed win, not just size (#17 pt 7).
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(PREFIX)nm $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# BOOT-INIT REACHABILITY KNOB (BUG #23, CONTRACTS.md #boot-init-unreachable)
#
# The three-function bring-up chain every STM32 family in this tree shares.
# It was DEFINED and CALLED FROM NOWHERE on f103/f411/h523 until BUG #23:
# core grbl/main.c is the golden gate and never calls platform init, no
# Reset_Handler called it either, so -flto deleted the whole subgraph and
# the shipped RELEASE images configured neither clock nor GPIO. The call
# now lives in each port's Reset_Handler; THIS is the check that the call
# is still there, and that LTO still keeps what it reaches.
#
# Declarable per port (a port that renames or splits its bring-up sets its
# own list in its Makefile before including this file) - ports genuinely
# name this differently: samd21/ch32v006/ch570 use SystemInit, the dsPIC
# uses _hal_clock_config via a crt0 user_init hook.
INIT_SYMBOLS ?= Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init
INIT_CHECK = ../common/init_check.sh

# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(COMMON_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  CFLAGS += -flto -fno-fat-lto-objects
  CFLAGS += -DWATCHDOG_ENABLE
else
  CFLAGS += -O0 -g3
  CFLAGS += -DDEBUG
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

$(BUILD_DIR)/flash.o: flash.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile STM32 common files
$(BUILD_DIR)/stm32_nvmem.o: $(COMMON_DIR)/stm32_nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/stm32_timing.o: $(COMMON_DIR)/stm32_timing.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/stm32_watchdog.o: $(COMMON_DIR)/stm32_watchdog.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link
$(ELF_FILE): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $@
	$(ASSERT_FP)
	@sh $(INIT_CHECK) $(PREFIX)nm $@ $(INIT_SYMBOLS)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
#
# BOOT INTEGRITY (BUG #21 ratchet): objcopy will happily emit a .bin with no
# vector table in it - KEEP(*(.isr_vector)) does not survive -flto, and nothing
# else in the build fails when the table is gone. The image links, `size` looks
# normal, and the chip bricks. boot_check.sh reads word0/word1 of the finished
# image and fails the build unless they are a real (SP, Thumb reset vector)
# pair. See CONTRACTS.md S18.
BOOT_CHECK = ../common/boot_check.sh

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@sh $(BOOT_CHECK) $@ $(FLASH_ORIGIN) $(FLASH_LENGTH)

# Create disassembly dump
$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

# Flash using st-link
flash: $(BIN_FILE)
	st-flash write $< 0x8000000

# Flash using OpenOCD
flash-openocd: $(HEX_FILE)
	openocd -f interface/stlink.cfg -f target/$(OPENOCD_TARGET) \
	        -c "program $< verify reset exit"

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
	rm -rf $(PLATFORM_BUILD_ROOT)

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
	@echo "  make FP=SINGLE    - AVR-faithful double==float semantics (default)"
	@echo "  make FP=DOUBLE    - declared-double deviation, no-DP assert disarmed"
	@echo ""
	@echo "Other targets:"
	@echo "  make flash        - Flash using st-link"
	@echo "  make flash-openocd - Flash using OpenOCD"
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

.PHONY: all clean clean-all flash flash-openocd debug help

# Include dependencies
-include $(BUILD_DIR)/*.d
