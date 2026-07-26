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

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards).
.DELETE_ON_ERROR:

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
# Keyed by BUILD flavor AND BOARD: DEBUG/RELEASE object dirs never alias, so
# switching flavors without `make clean` can't silently relink stale objects
# under the wrong name (bit samd21 twice, ch32v006 once in review - see
# PLAN.md/CONTRACTS.md). BOARD is in the path too (bit samd21 a THIRD time -
# BOARD wasn't keyed, so a no-clean board switch silently shipped the other
# board's binary).
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BOARD)/$(BUILD)
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

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding). See common/stm32/common.mk's
# matching comment for the full rationale/measurement; RELEASE (-g0) is
# verified unaffected (re-checked against this port's own committed
# artifacts/ch32v006 hashes), DEBUG becomes checkout-path-independent.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# FP PRECISION KNOB (CONTRACTS.md #17: "FP precision is a declared port
# property"). Landed pattern from samd21/Makefile - see that file for the
# full rationale (avr-gcc double==float template semantics; unsuffixed
# double literals/libm calls in core were always single precision on the
# origin AVR). This is the chip the original probe measured the leak on:
# ~13.5KB of DP soft-float/libm text with the knob absent (rv32ec has no
# FPU at all, so double is fully soft-float here too).
#   FP=SINGLE (default): -fsingle-precision-constant keeps unsuffixed FP
#     literals float; GRBL_FP_SINGLE arms the board prelude's SP libm
#     call-site mapping; post-link tools/assert_no_double.sh FAILS the
#     build listing offenders if any DP machinery still linked in.
#   FP=DOUBLE: conscious opt-in deviation, must be declared in port docs.
# Applied to BOTH build flavors - it is a semantics pin, not an
# optimization.
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(PREFIX)nm $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# picolibc supplies libc/libm/startfiles for this target (PLAN.md Decision
# Log toolchain recipe); -nostartfiles because startup.c supplies its own
# _start/Reset_Handler (PORTING-CHECKLIST Step 0/1) - without it the
# linker still pulls picolibc's own crt0 in as a start file, which would
# fight startup.c's .data/.bss init and mtvec setup.
CFLAGS += -specs=picolibc.specs

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
# this port uses SystemInit + SystemClock_Config, the dsPIC uses an underscore-
# prefixed _hal_clock_config reached through a crt0 user_init table.
INIT_SYMBOLS ?= Reset_Handler,SystemInit,SystemClock_Config
INIT_CHECK = ../common/init_check.sh

CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
#
# LTO: RELEASE only (house style - samd21/stm32*/hc32f460/sg2002 Makefiles
# all gate -flto on BUILD==RELEASE; DEBUG stays plain -Og for debuggability,
# same reasoning as every other port: LTO's cross-TU inlining/reordering
# makes single-stepping/variable-inspection unreliable, and DEBUG has no
# size pressure -Og doesn't already relieve).
#
# LTO-PROOFING (CONTRACTS.md gap log, this batch - BUG #21's mechanism on
# this ISA): naive -flto silently deletes Reset_Handler, whose only caller
# is _start's raw inline asm (invisible to LTO's IPA), and the link fails
# with "undefined reference to Reset_Handler". Fixed at the source
# (startup.c: `__attribute__((used))` on Reset_Handler) rather than here -
# every assembly-only-reachable symbol on this port is now audited and
# pinned (Reset_Handler; PFIC_Vector[] and every handler it addresses were
# already `used`/address-taken since the M1-M3 --gc-sections lifecycle
# fix, CONTRACTS.md #14.3).
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  CFLAGS += -flto -fno-fat-lto-objects
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

# LTO for release builds (samd21/stm32*/hc32f460/sg2002 house style: the
# link step re-invokes the compiler driver, which re-runs LTO codegen over
# the whole-program IR - -flto must be present here too, not just in CFLAGS).
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

# Steps 3-6 complete: full build (ELF + hex + bin), samd21 posture. The
# M3-era "objects only" default is gone - zero PORT_TODO_* remain.
all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE)

objects: $(BUILD_DIR) $(OUTPUT_DIR) $(OBJECTS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Board stamp: same mechanism as samd21/Makefile (the only port with a real
# second board today) - kept here so a second BOARD under boards/ never
# reintroduces the "final ELF path outlives the board that built it" bug.
# BUILD_DIR already keys the object dirs by board; this keys the LINK step
# too, without moving ELF_FILE/HEX_FILE/BIN_FILE/MAP_FILE (CI/smoke/
# build_artifacts.py all expect them at this exact un-keyed path). FORCE
# makes the recipe run every invocation; it only rewrites (and so only
# touches mtime) when BOARD actually changed since the last stamp.
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

# Full link. Historically the M3 "linker-as-checklist" diagnostic; now
# (Steps 3-6 done) it must succeed with ZERO undefined PORT_TODO_*.
link: $(ELF_FILE)

$(ELF_FILE): objects $(BOARD_STAMP)
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)
	$(ASSERT_FP)
	@sh $(INIT_CHECK) $(PREFIX)nm $@ $(INIT_SYMBOLS)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
#
# BOOT INTEGRITY (BUG #21 ratchet, CONTRACTS.md S18).
# The ARM form of this check (../common/boot_check.sh) is N/A here: RISC-V has
# no SP-in-word0 convention. A QingKe RV32EC does not autoload SP/PC from a
# table - it just starts executing at the flash base, and _start (naked, in
# .init) sets SP itself. So word0 of the .bin is an instruction by design, and
# testing it for 0x2xxxxxxx would be meaningless.
#
# The failure the ARM check exists to catch is still possible here, though:
# -flto can delete an unreferenced table/entry stub before codegen and leave
# KEEP() nothing to match. The equivalent assertion for this architecture is
# "the reset entry is where the hardware will look for it", i.e. _start must be
# linked at the flash base. That is what is checked below.
BOOT_ENTRY_ADDR = 00000000

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@start=$$($(PREFIX)nm $(ELF_FILE) | grep ' _start$$' | cut -d' ' -f1); \
	 if [ "$$start" != "$(BOOT_ENTRY_ADDR)" ]; then \
	   echo ""; \
	   echo "====================================================================="; \
	   echo "BOOT INTEGRITY: FAIL - _start is not at the flash base"; \
	   echo "  _start   = 0x$${start:-<missing>}"; \
	   echo "  expected = 0x$(BOOT_ENTRY_ADDR) (script.ld MEMORY{FLASH} ORIGIN)"; \
	   echo "  first 16 bytes of $@:"; \
	   od -An -tx4 -N16 $@; \
	   echo "  RISC-V has no SP-in-word0 convention, so this - not a word0"; \
	   echo "  check - is the boot-integrity assertion for this port."; \
	   echo "  See CONTRACTS.md S18 / BUG #21."; \
	   echo "====================================================================="; \
	   exit 1; \
	 fi; \
	 echo "BOOT INTEGRITY: OK  _start=0x$$start  ($@)"

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
	@echo "  make FP=SINGLE    - AVR-faithful double==float semantics (default)"
	@echo "  make FP=DOUBLE    - declared-double deviation, no-DP assert disarmed"
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
