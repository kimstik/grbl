#  Makefile for GRBL on HC32F460 (HDSC/Huada, generic reference board)
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  HC32F460JETA: ARM Cortex-M4F, up to 200MHz, up to 512KB Flash, up to
#  192KB SRAM. Vendor-exotic: no sibling HC32 port exists in this tree yet,
#  so this Makefile is standalone (not a shared common.mk) - see
#  regs.h/platform.md for the full clean-room verification methodology.

PLATFORM_NAME  = hc32f460
DEVICE         = HC32F460
CPU            = cortex-m4
CLOCK          = 200000000

# Hardware FPU present (single-precision, fpv4-sp-d16-class) and core grbl
# is float-heavy throughout (planner/gcode/motion_control) - CONTRACTS.md
# porting-checklist Step 1 FPU note, same justification stm32f411/
# stm32h523 already established: hard-float register passing is the whole
# reason to port to an FPU-bearing chip, and this toolchain's arm-none-eabi
# multilib provides a matching hard-float fpv4-sp-d16 variant.
FPU            = -mfpu=fpv4-sp-d16 -mfloat-abi=hard

# Flash window for the post-link BOOT INTEGRITY check. Must match script.ld's
# MEMORY{FLASH} (BUG #21 ratchet, CONTRACTS.md S18).
FLASH_ORIGIN   = 0x00000000
FLASH_LENGTH   = 524288

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards) -
# CONTRACTS.md S19 lesson 2.
.DELETE_ON_ERROR:

BUILD ?= DEBUG

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

GRBL_DIR   = ../..
# Keyed by BUILD flavor: DEBUG/RELEASE object dirs never alias (landed
# repo-wide convention, PLAN.md/CONTRACTS.md).
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources. nvmem.c IS compiled (macro route, CONTRACTS.md section
# 10): its platform-agnostic memcpy_to/from_nvmem_with_checksum functions
# are used as-is; flash.c below supplies hal_nvmem_read_byte/write_byte,
# which eeprom_get_char/eeprom_put_char (platform.h) map onto.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c serial.c \
               protocol.c stepper.c nvmem.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

PLATFORM_SOURCES = platform.c startup.c handlers.c flash.c

SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

vpath %.c $(GRBL_DIR)
vpath %.c $(PLATFORM_DIR)

CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# FP PRECISION KNOB (CONTRACTS.md section 17: "FP precision is a declared
# port property"). Landed pattern from samd21/ch32v006/stm32*, applied here
# identically - this port's whole reason to exist is an FPU-bearing chip,
# so FP=SINGLE is both a size win (soft-float DP elimination) and a speed
# win (real vsqrt.f32/vmul.f32 instructions, verified by disassembly - see
# platform.md).
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(PREFIX)nm $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS_EXTRA = -I. -I../common/dummy -include prelude.h
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  CFLAGS += -flto -fno-fat-lto-objects
else
  CFLAGS += -O0 -g3
  CFLAGS += -DDEBUG
endif

LDFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(MAP_FILE)
LDFLAGS += -specs=nano.specs -specs=nosys.specs
LDFLAGS += -T script.ld

ifeq ($(BUILD),RELEASE)
  LDFLAGS += -flto -Os
endif

LIBS = -lm

ifeq ($(BUILD),RELEASE)
  BINARY_NAME = grbl_$(PLATFORM_NAME)
else
  BINARY_NAME = grbl_$(PLATFORM_NAME)_dbg
endif

ELF_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).elf
HEX_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).hex
BIN_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).bin
DUMP_FILE = $(OUTPUT_DIR)/$(BINARY_NAME).dump
MAP_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).map

all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE) $(DUMP_FILE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

$(BUILD_DIR)/%.o: $(GRBL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/platform.o: platform.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/startup.o: startup.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/handlers.o: handlers.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/flash.o: flash.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(ELF_FILE): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $@
	$(ASSERT_FP)

$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# BOOT INTEGRITY (BUG #21 ratchet, CONTRACTS.md S18): see common/boot_check.sh
BOOT_CHECK = ../common/boot_check.sh

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@sh $(BOOT_CHECK) $@ $(FLASH_ORIGIN) $(FLASH_LENGTH)

$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

flash: $(BIN_FILE)
	@echo "No OpenOCD/st-link target configured for HC32F460 in this tree - use the vendor ISP tool or a SEGGER J-Link with the HC32F460 device pack."

debug: $(ELF_FILE)
	$(GDB) $<

clean:
	rm -f $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.elf \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.hex \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.bin \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.dump \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.map
	rm -rf $(BUILD_DIR)

clean-all:
	rm -rf $(OUTPUT_DIR)

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

.PHONY: all clean clean-all flash debug help

-include $(BUILD_DIR)/*.d
