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
OUTPUT_DIR = ../../../build
# Whole-platform object root (every BOARD and BUILD flavor lives under
# here) - `clean` below removes THIS, not just $(BUILD_DIR), so it can't
# leave a stale board/flavor combo behind for a knob change (FP=, BOARD=,
# or any -D) to silently relink under the wrong label (CONTRACTS.md gap
# log: "make clean cleans only the invoked BUILD flavor's object dir").
PLATFORM_BUILD_ROOT = $(OUTPUT_DIR)/$(PLATFORM_NAME)
BUILD_DIR  = $(PLATFORM_BUILD_ROOT)/$(BOARD)/$(BUILD)
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
# compiler warning.
# WIDENED UL -> ULL (CONTRACTS.md #36 clock-constant-width): this port was
# left at UL when the stm32/hc32/dspic siblings were widened, because
# 48 MHz keeps the UL product under 2^32-1 today - but that was true only
# for TODAY's CLOCK, and unsigned long is still 32-bit on this ABI, so any
# future board revision clocked above ~71 MHz would have wrapped silently
# (unsigned overflow isn't warned, unlike signed) with zero diagnostic.
# Widened uniformly with the other 7 ports so the class has no exception
# left standing; common/clock_width.h (included via prelude.h) now asserts
# the WIDTH of this token at every build, so a future accidental revert to
# UL fails loudly instead of depending on someone re-deriving this comment.
# Measured before/after both flavors, both boards - see PLAN.md/CONTRACTS.md
# #36 for the exact byte deltas (48 MHz is far under the overflow
# threshold, so the folded constant is numerically identical either way;
# operand width can still perturb codegen at the register-pressure edges).
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)ULL
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding). See common/stm32/common.mk's
# matching comment for the full rationale/measurement; RELEASE (-g0) is
# verified unaffected, DEBUG becomes checkout-path-independent.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# FP PRECISION KNOB (CONTRACTS.md #17). Cortex-M0+ has no FPU; double is a
# real 64-bit type here, so unsuffixed literals/libm calls promote for real
# unless pinned to single (original probe chip for this knob).
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
# BOOT-INIT REACHABILITY KNOB (BUG #23, CONTRACTS.md #boot-init-unreachable).
# Post-link proof that this port's pre-main bring-up is still REACHABLE:
# after -flto + --gc-sections, a function survives only if something
# reaches it, so "defined in the final ELF" == "reachable". Four sibling
# ports (stm32f103/f411/h523, hc32f460) shipped a complete bring-up chain
# that nothing called - core grbl/main.c is the golden gate and never calls
# platform init - and LTO silently deleted all of it.
#
# Declarable per port because ports genuinely name this differently: the
# STM32/HC32 family uses hal_system_init/hal_clock_config/hal_gpio_init,
# this port uses SystemInit, the dsPIC uses an underscore-
# prefixed _hal_clock_config reached through a crt0 user_init table.
INIT_SYMBOLS ?= Reset_Handler,SystemInit
INIT_CHECK = ../common/init_check.sh

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

all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE) $(DUMP_FILE) warn_check

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
	@sh $(INIT_CHECK) $(PREFIX)nm $@ $(INIT_SYMBOLS)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
# BOOT INTEGRITY (BUG #21, CONTRACTS.md S18) - see common/boot_check.sh.
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

# WARNING RATCHET (ci/warn_ratchet.py) wired at build time - CONTRACTS.md
# #warn-ratchet-build-time-wiring. See common/warn_check.sh's header for the
# full soundness rationale: this forces its own from-scratch build in a
# scratch directory (never the developer's own $(BUILD_DIR)) so the
# captured log can never be an incomplete/incremental one, and the object
# count check after the rebuild proves that really happened rather than
# trusting it.
#
# $(BOARD) is folded into the scratch path: this port's baseline is a UNION
# over megarm+generic (PLAN.md), so a run under either BOARD is checked
# against the same file - correct, if narrower than checking both boards in
# one invocation (CI's matrix already runs them as separate legs, each its
# own `make BUILD=... BOARD=...` - this mirrors that shape rather than
# inventing a two-board single-target one).
#
# The recursive $(MAKE) targets the scratch ELF path directly (never `all`/
# `warn_check`) to avoid a `warn_check -> rebuild -> all -> warn_check ->
# ...` infinite recursion, since `all` above lists `warn_check` as its own
# prerequisite. BUILD_DIR/OUTPUT_DIR are overridden to two DISTINCT scratch
# subdirectories (obj/ vs out/) - overriding both to the same path makes
# this Makefile's own directory-creation rules collide ("overriding recipe
# for target", a real warning the ratchet then correctly fails on - caught
# by this exact mechanism while landing it on stm32f103, see common.mk).
WARN_SCRATCH     = $(OUTPUT_DIR)/.warncheck/$(PLATFORM_NAME)/$(BOARD)/$(BUILD)
WARN_SCRATCH_OBJ = $(WARN_SCRATCH)/obj
WARN_SCRATCH_OUT = $(WARN_SCRATCH)/out
WARN_LOG         = $(WARN_SCRATCH)/build.log
WARN_BASELINE    = ../../../ci/warn_baseline_$(PLATFORM_NAME).txt
WARN_RATCHET     = ../../../ci/warn_ratchet.py
WARN_CHECK       = ../common/warn_check.sh

warn_check:
	@mkdir -p $(WARN_SCRATCH_OUT)
	@sh $(WARN_CHECK) $(WARN_SCRATCH_OBJ) $(words $(OBJECTS)) $(WARN_LOG) \
	    $(WARN_BASELINE) $(WARN_RATCHET) -- \
	    $(MAKE) --no-print-directory BUILD=$(BUILD) BOARD=$(BOARD) FP=$(FP) \
	      BUILD_DIR=$(WARN_SCRATCH_OBJ) OUTPUT_DIR=$(WARN_SCRATCH_OUT) \
	      $(WARN_SCRATCH_OUT)/$(BINARY_NAME).elf

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
	rm -rf $(PLATFORM_BUILD_ROOT)
	rm -rf $(OUTPUT_DIR)/.warncheck/$(PLATFORM_NAME)

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

.PHONY: all clean clean-all flash flash-bossa debug help compdb warn_check

# Include dependencies
-include $(BUILD_DIR)/*.d
