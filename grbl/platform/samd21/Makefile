#  Makefile for GRBL on SAMD21G18A
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  SAMD21G18A: ARM Cortex-M0+, 48MHz, 32KB RAM, 256KB Flash
#  Used in Arduino Zero, MKR series

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards).
.DELETE_ON_ERROR:

# Platform-specific configuration
PLATFORM_NAME  = samd21
DEVICE         = SAMD21G18A
CPU            = cortex-m0plus
CLOCK          = 48000000
FPU            =                # Cortex-M0+ has no FPU
OPENOCD_TARGET = at91samdXX.cfg

# Board selection (override with make BOARD=generic)
BOARD         ?= megarm

# Include paths (platform dir first to override common files)
# Platform-specific avr/ overrides common/dummy/avr/
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD) 

# Build prelude: ONE injected header per board (invisible porting).
# Replaces the former chain of four -include flags (gpio.h, ../common/gpio.h,
# $(BOARD)/config.h, platform.h); the prelude chains exactly those headers in
# exactly that order - see $(BOARD)/prelude.h for why the order is load-bearing.
CFLAGS_EXTRA  += -include $(BOARD)/prelude.h

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
# Keyed by BUILD flavor AND BOARD: DEBUG/RELEASE object dirs never alias, so
# switching flavors without `make clean` can't silently relink stale objects
# under the wrong name (bit samd21 twice - see PLAN.md/CONTRACTS.md). BOARD is
# in the path too (bit samd21 a THIRD time - megarm/generic aliased the same
# dir since BOARD wasn't keyed): a no-clean `make BOARD=megarm` after a
# `BOARD=generic` build must rebuild, not silently relink/ship the other
# board's stale objects under this board's output name.
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BOARD)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources (from grbl directory)
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources
PLATFORM_SOURCES = platform.c startup.c handlers.c serial.c nvmem.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources (platform dir first to override grbl/ files)
vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
# BUG #18: F_CPU feeds TICKS_PER_MICROSECOND (grbl/nuts_bolts.h:47,
# `(F_CPU/1000000)`, core file - not editable). On AVR the 1000000 literal
# doesn't fit avr-gcc's 16-bit int, so the compiler auto-promotes to (32-bit)
# long and stepper.c:1015's `TICKS_PER_MICROSECOND*1000000*60` stays in
# range. On this platform's 32-bit int, 1000000 fits as plain int, so that
# same expression (2.88e9 @ 48MHz) overflows signed int32 - UB plus a
# compiler warning. The UL suffix here makes F_CPU (and therefore
# TICKS_PER_MICROSECOND's expansion) unsigned long, so the product is
# computed in uint32 - no core edit, no more overflow.
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)UL
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding). See common/stm32/common.mk's
# matching comment for the full rationale/measurement; RELEASE (-g0) is
# verified unaffected, DEBUG becomes checkout-path-independent.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# FP PRECISION KNOB (CONTRACTS #17: "FP precision is a declared port
# property"). GRBL core is float-typed throughout but was written against
# avr-gcc, where double==float (32-bit) - so its unsuffixed double literals
# (0.5*x, 1.0-y) and unsuffixed libm calls (sqrt/atan2/sin/cos/floor/ceil/
# round/lround/trunc/fabs) were ALWAYS single precision on the origin AVR.
# Cortex-M0+ has no FPU at all and double is a real 64-bit type here, so
# those same expressions promote for real and drag in DP soft-float
# (__aeabi_dadd/dsub/dmul/ddiv, __eqdf2) plus DP libm (__ieee754_atan2,
# __ieee754_sqrt, __ieee754_rem_pio2, __kernel_sin/cos, atan, ...) that the
# AVR binary never contained - all of it computing precision core
# immediately truncates back to float.
#
#   FP=SINGLE (default): template-faithful AVR double==float semantics.
#     - -fsingle-precision-constant keeps unsuffixed FP literals float
#     - GRBL_FP_SINGLE arms the board prelude's SP libm call-site mapping
#     - post-link, tools/assert_no_double.sh FAILS the build listing
#       offenders if any DP machinery still linked in - the linker is the
#       truth, not the compile flags.
#   FP=DOUBLE: conscious opt-in deviation - MORE precise than the template,
#     must be declared in the port's docs. No SP pins, assert disarmed.
#     Intended for ports with a native DP FPU, which the M0+ is not.
#
# Applied to BOTH build flavors - it is a semantics pin, not an
# optimization, and DEBUG must debug the same arithmetic RELEASE ships.
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(PREFIX)nm $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# Floating point: default is float (single precision) - software emulation on M0+
# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
BUILD ?= DEBUG
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
#LDFLAGS += -specs=nano.specs -specs=nosys.specs
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

# Board stamp: the FINAL artifact path (ELF_FILE = build/grbl_samd21[_dbg].elf,
# and everything objcopy'd from it) is deliberately left un-keyed by BOARD -
# .github/actions/build-platform/action.yml, ci/renode/smoke.sh, and
# tools/build_artifacts.py all expect it at exactly this path (verified by
# grep before adding this). BUILD_DIR above already keys the OBJECT dirs by
# board, so object staleness is correct per-board - but that alone doesn't
# save the LINK step: after `make BOARD=generic` leaves grbl_samd21.elf newer
# than megarm's (unchanged, already-fresh) object files, a later no-clean
# `make BOARD=megarm` finds every megarm prerequisite older than the existing
# ELF and reports "Nothing to be done" - silently shipping generic's binary
# under megarm's name (bit samd21 a FOURTH time). Force a relink on ANY board
# switch, without moving a single consumer path: the stamp's CONTENT is the
# board that produced the current ELF, and FORCE makes the recipe run every
# invocation - but it only rewrites (and so only touches mtime) the file when
# that content actually changes, so a same-board rebuild never spuriously
# forces a relink.
BOARD_STAMP = $(OUTPUT_DIR)/.board_stamp_$(PLATFORM_NAME)

$(BOARD_STAMP): FORCE
	@mkdir -p $(OUTPUT_DIR)
	@if [ ! -f $@ ] || [ "$$(cat $@ 2>/dev/null)" != "$(BOARD)" ]; then \
	  echo $(BOARD) > $@; \
	fi

.PHONY: FORCE
FORCE:

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

$(BUILD_DIR)/serial.o: serial.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/nvmem.o: nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link
$(ELF_FILE): $(OBJECTS) $(BOARD_STAMP)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $@
	$(ASSERT_FP)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
#
# BOOT INTEGRITY (BUG #21 ratchet): objcopy will happily emit a .bin with no
# vector table in it - KEEP(*(.isr_vector)) does not survive -flto, and nothing
# else in the build fails when the table is gone. samd21 already survives by
# construction (Reset_Handler writes SCB->VTOR = vector_table, which anchors
# the table against LTO's IPA), so this check passes today - it is here so the
# guarantee stays checked rather than accidental. See CONTRACTS.md S18.
# FLASH window must match script.ld MEMORY{FLASH}: 0x200, 255488 bytes.
BOOT_CHECK   = ../common/boot_check.sh
FLASH_ORIGIN = 0x00000200
FLASH_LENGTH = 255488

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@sh $(BOOT_CHECK) $@ $(FLASH_ORIGIN) $(FLASH_LENGTH)

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

# Generate compile_commands.json for clangd/LSP (stdlib-only, no bear/compiledb).
# Re-runs this Makefile as `make -nB` and parses the printed compiler recipe
# lines - see tools/gen_compile_commands.py for details. To copy this pattern
# into another platform's Makefile, add:
#   compdb:
#   	$(GRBL_DIR)/../tools/gen_compile_commands.py $(PLATFORM_NAME) --build $(BUILD)
# (adjusting $(GRBL_DIR)/../ to however many levels get you back to the repo
# root from that Makefile's directory).
compdb:
	$(GRBL_DIR)/../tools/gen_compile_commands.py $(PLATFORM_NAME) --board $(BOARD) --build $(BUILD)

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
	@echo "  make FP=SINGLE    - AVR-faithful double==float semantics (default)"
	@echo "  make FP=DOUBLE    - declared-double deviation, no-DP assert disarmed"
	@echo ""
	@echo "Other targets:"
	@echo "  make flash        - Flash using OpenOCD"
	@echo "  make flash-bossa  - Flash using BOSSA (Arduino bootloader)"
	@echo "  make debug        - Start GDB debugger"
	@echo "  make compdb       - Generate compile_commands.json for clangd/LSP"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform = $(PLATFORM_NAME)"
	@echo "  CPU = $(CPU)"
	@echo "  Clock = $(CLOCK) Hz"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  FP precision = $(FP)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all clean clean-all flash flash-bossa debug help compdb

# Include dependencies
-include $(BUILD_DIR)/*.d
