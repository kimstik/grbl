#  Makefile for GRBL on CH32V006 (RISC-V RV32EC, QingKe V2C)
#  Part of Grbl
#
#  Phase 4 "first battle test of _template" - modeled directly on
#  grbl/platform/_template/Makefile, adapted from ARM to RISC-V. See
#  README.md's copy/rename/fill-in order for the general pattern; the
#  RISC-V-specific deltas are called out below.
#
#  TOOLCHAIN (PLAN.md Decision Log, verified live this session):
#    sudo apt-get install -y gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf
#  gives riscv64-unknown-elf-gcc 13.2.0 with rv32e multilibs + picolibc.
#
#  ARCHFLAGS GAP found empirically this session: the Decision Log's
#  recorded recipe (`-march=rv32ec -mabi=ilp32e`) is INSUFFICIENT on this
#  toolchain - any `csr*` instruction (interrupt enable/disable, critical
#  sections - i.e. most of platform.h) fails to assemble with
#  "unrecognized opcode ... extension `zicsr' required". This binutils
#  unbundles Zicsr from the base ISA per the current ISA-string spec
#  version; `_zicsr` must be appended explicitly. Folded back into
#  CONTRACTS.md's new RISC-V section - PLAN.md's recipe should be
#  corrected the same way for the next RISC-V port.

# ============================================================================
# Chip identification
# ============================================================================

PLATFORM_NAME  = ch32v006
DEVICE         = CH32V006
# rv32e core ("Embedded" - 16 registers) + Compressed instructions + Zicsr
# (see the ARCHFLAGS gap note above). NOT rv32i - this chip's QingKe V2C
# core is genuinely register-file-reduced (RV32E), unlike most hobbyist
# RISC-V MCUs which are plain RV32I(MAC).
ARCH           = rv32ec_zicsr
ABI            = ilp32e
# Verified system clock in Hz - feeds F_CPU (PORTING-CHECKLIST Step 1).
# UNVERIFIED end-to-end on real hardware this session - see platform.c's
# SystemClock_Config() comment (HSI x2 PLL assumption).
CLOCK          = 48000000

# Board selection (only "generic" ships with this port - a real board
# would copy this directory, same as every other platform)
BOARD         ?= generic
BOARD_DIR      = boards/$(BOARD)

# Include paths (platform dir first to override common/dummy defaults).
# common/dummy supplies the AVR compatibility stubs every non-AVR
# platform needs (avr/io.h, cpu_map.h, util/delay.h, ...) - reused as-is,
# never copied (samd21/Makefile:24, _template/Makefile:45-46).
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD_DIR)

# Build prelude: ONE injected header per board (CONTRACTS.md #0).
CFLAGS_EXTRA  += -include $(BOARD_DIR)/prelude.h

# Toolchain
TOOLCHAIN_PATH ?=
ifdef TOOLCHAIN_PATH
  PREFIX     = $(TOOLCHAIN_PATH)/riscv64-unknown-elf-
else
  PREFIX     = riscv64-unknown-elf-
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
# wrong name (bit samd21 twice, ch32v006 once in review - see PLAN.md/CONTRACTS.md).
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources. Excludes serial.c/nvmem.c/eeprom.c: TU-replacement
# route (CONTRACTS.md #0/#7/#10), same as samd21/_template.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources. platform.c exists here (unlike _template,
# which has none) because CFGLR/CFGHR direction config is a genuine
# function, not a macro - see gpio.h's file header.
PLATFORM_SOURCES = platform.c startup.c handlers.c serial.c nvmem.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources (platform dir first to override grbl/ files)
vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

# Base compiler flags
ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI)
CFLAGS  = $(ARCHFLAGS)
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)UL
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# picolibc supplies libc/libm/startfiles for this target (PLAN.md Decision
# Log toolchain recipe); -nostartfiles because startup.c supplies its own
# _start/Reset_Handler (PORTING-CHECKLIST Step 0/1) - without it the
# linker still pulls picolibc's own crt0 in as a start file, which would
# fight startup.c's .data/.bss init and mtvec setup.
CFLAGS += -specs=picolibc.specs

# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
else
  # -Og, not -O0: soft-float rv32ec grbl at -O0 is ~77KB of .text and the
  # chip has 62KB (61K after the NVMEM window). -Og keeps single-stepping
  # sane while fitting the part - found the day `make link` first became
  # a hard gate for this port.
  CFLAGS += -Og -g3
  CFLAGS += -DDEBUG
endif

# Linker flags.
#
# --gc-sections LIFECYCLE (CONTRACTS.md #14.3): during porting, this
# Makefile carried an explicit -Wl,--no-gc-sections COUNTERING
# `-specs=picolibc.specs`'s own unconditional `--gc-sections` append
# (see `riscv64-unknown-elf-gcc ... -dumpspecs`'s `*link:` rule) - not
# merely "omitted" the way _template's (non-picolibc) Makefile gets away
# with. Reason at the time: with gc-sections live, handlers.c's
# stepper_timer_irq_dispatch / pulse_reset_timer_irq_dispatch /
# gpio_irq_dispatch (and _delay_us) were unreached from main()'s call
# graph (nothing wired them into a vector yet - pre Step 3), so the
# linker's reachability pass dropped their sections BEFORE checking
# whether their PORT_TODO_* calls resolved - `__keep_alive[]`
# (`__attribute__((used))`, _template's stated insurance against exactly
# this) was NOT sufficient by itself on this toolchain/version to keep
# them reachable. Confirmed via `nm -u` on handlers.o (6 undefined
# PORT_TODO_* symbols present in the object) vs. `make link`'s reported
# list (those 6 silently absent) before --no-gc-sections was added.
#
# Port is now COMPLETE (zero PORT_TODO_* at link, every handler wired
# into PFIC_Vector) - the reachability hazard that motivated
# --no-gc-sections no longer applies, and --gc-sections is now a real
# size win (dead/unreached code no longer gets a free pass). Re-enabled
# below. Vector table survives this because it's protected independently
# of reachability: PFIC_Vector is `__attribute__((used, section(".vectors")))`
# and script.ld KEEP()s `.vectors`/`.init` explicitly (see script.ld
# header comment) - verified post-flip via `nm`/`readelf` (IVT symbols
# and .init/.vectors sections identical before/after). The NVMEM window
# is untouched by either setting - it's addressed directly by physical
# address (nvmem.c), not placed via a linker section.
#
# General rule for any picolibc-based port (folded into CONTRACTS.md
# #14.3): --no-gc-sections while PORT_TODO_* is non-empty (so the
# linker-as-checklist mechanism can't be defeated by silent section
# discard), switch to --gc-sections once the port reaches zero
# PORT_TODO_* (so the release binary isn't paying rent on dead code
# forever). Do the flip in ONE place, not per-BUILD-flavor: DEBUG has no
# reason to retain unreached code once the same completeness holds.
LDFLAGS  = $(ARCHFLAGS) -nostartfiles -specs=picolibc.specs
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(MAP_FILE)
LDFLAGS += -T script.ld

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

# Steps 3-6 complete: full build (ELF + hex + bin), samd21 posture. The
# M3-era "objects only" default is gone - zero PORT_TODO_* remain.
all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE)

objects: $(BUILD_DIR) $(OUTPUT_DIR) $(OBJECTS)

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

$(BUILD_DIR)/serial.o: serial.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/nvmem.o: nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Full link. Historically the M3 "linker-as-checklist" diagnostic; now
# (Steps 3-6 done) it must succeed with ZERO undefined PORT_TODO_*.
link: $(ELF_FILE)

$(ELF_FILE): objects
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@

# Create disassembly dump
$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

# Debug with gdb
debug: $(ELF_FILE)
	$(GDB) $<

# Generate compile_commands.json for clangd/LSP
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
	@echo "GRBL $(PLATFORM_NAME) Build System (Phase 4 - Steps 0-6 complete)"
	@echo ""
	@echo "Usage:"
	@echo "  make              - Full build: ELF + hex + bin (DEBUG, default)"
	@echo "  make BUILD=RELEASE - Full build, optimized"
	@echo "  make link         - Link only (must show zero PORT_TODO_*)"
	@echo "  make compdb       - Generate compile_commands.json for clangd/LSP"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform = $(PLATFORM_NAME)"
	@echo "  Board    = $(BOARD)"
	@echo "  Arch = $(ARCH) / $(ABI)"
	@echo "  Clock = $(CLOCK) Hz"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all objects link clean clean-all debug help compdb

# Include dependencies
-include $(BUILD_DIR)/*.d
