#  Makefile for GRBL on _template (copy-me starting point for new ports)
#  Part of Grbl
#
#  This Makefile's PRELUDE STRUCTURE (one -include per board, chaining
#  gpio.h -> common/gpio.h -> config.h -> platform.h) is modeled on
#  grbl/platform/samd21/Makefile - the original post-prelude reference.
#  Its BOARD DIRECTORY LAYOUT (boards/<name>/ instead of a bare <name>/ at
#  the platform root) instead follows ch32v006/ch570/dspic33ak128mc102 -
#  those three plus this template are the majority (4 of 5 multi-board-
#  capable ports); samd21 (<name>/ at root, no boards/ level) is the
#  outlier that predates the boards/ convention and was never migrated.
#  Audit note: if you're reconciling this with samd21 for a "which is the
#  template modeled on" question, that's why the two don't match on this
#  one axis - it's not a copy error. Moving samd21 to boards/<name>/ for
#  full consistency is a reasonable future cleanup (RECOMMENDED, not done
#  here - it touches a golden-adjacent, gate-verified port for a pure
#  layout change with no functional benefit, so it's left as the
#  integrator's call rather than performed inside this audit).
#  Copy this whole _template/ directory, rename it to your platform, then
#  edit every line marked PORT-TODO below. See README.md for the full
#  copy -> rename -> fill-in order.
#
#  DESIGN NOTE (why this will not link): every macro this Makefile's sources
#  need but the chip doesn't yet have expands to a call to an undeclared
#  PORT_TODO_<name>() function (see platform.h/gpio.h/timer.h). That is
#  intentional - grbl/platform/CONTRACTS.md's "linker-as-checklist": the
#  template compiles every .c file today; it links only once a real port has
#  replaced every PORT_TODO_* stub. Do not "fix" that by stubbing them out
#  here - see CONTRACTS.md's cautionary tale (STP_TMR_PRESCALER_SET).

# ============================================================================
# PORT-TODO: chip identification - replace these five with your real values.
# NOTE: never append an inline "# comment" after a value used below in a
# concatenated path/flag (e.g. "-D__$(DEVICE)__" or "$(BUILD_DIR)/%.o") -
# GNU Make strips the comment but NOT the whitespace before it, so the
# variable's value keeps trailing spaces that split later concatenations
# into extra, broken words. Comments live on their own line instead.
# ============================================================================

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards).
.DELETE_ON_ERROR:

# Rename to your platform's directory name.
PLATFORM_NAME  = _template
# PORT-TODO: your platform token - must equal the suffix of a
# `#elif defined(PLATFORM_<TOKEN>)` branch in grbl/platform/hal.h (add one
# there for your new platform; see stm32f103/ch32v006/ch570/hc32f460/
# dspic33ak128mc102's DEVICE values - all are the uppercased PLATFORM_NAME,
# NOT a full chip part number like "STM32F103C8"). Below, CFLAGS derives
# `-DPLATFORM_$(DEVICE)` from this ONE variable (no separate line to
# remember). Leaving DEVICE=TEMPLATE (the shipped default) resolves through
# hal.h's own `PLATFORM_TEMPLATE` branch -> this directory's platform.h,
# which is what keeps the raw, unedited template compiling (PORT_TODO_*
# stubs only fail at link - CONTRACTS.md's "linker-as-checklist"). The
# moment you change DEVICE to a real token you MUST also add hal.h's
# matching elif branch; forgetting that is now a LOUD compile-time
# `#error "Unknown platform!"` from hal.h instead of silently falling back
# to this template's generic stub file while your real platform.h is never
# even included - that silent-wrong-file class of bug is exactly what the
# old hardcoded `-DPLATFORM_TEMPLATE` line (unparametrized, easy to forget
# because nothing marked it PORT-TODO) used to allow.
DEVICE         = TEMPLATE
# -mcpu value for your core (cortex-m0/m0plus/m3/m4/...).
CPU            = cortex-m0
# Verified system clock in Hz - feeds F_CPU (nuts_bolts.h's
# TICKS_PER_MICROSECOND and all stepper timing math); a lie here breaks
# every later timing step invisibly (PORTING-CHECKLIST Step 1).
CLOCK          = 48000000
# "-mfpu=fpv4-sp-d16 -mfloat-abi=hard" class cores only; leave empty for
# software-float cores (Cortex-M0/M0+/M3 and most M4 without an FPU part suffix).
FPU            =

# Board selection (only "generic" ships with the template - copy it for a real board)
BOARD         ?= generic
BOARD_DIR      = boards/$(BOARD)

# Include paths (platform dir first to override common/dummy defaults).
# common/dummy supplies the AVR compatibility stubs (avr/io.h, cpu_map.h, ...)
# every non-AVR platform needs - reused as-is, never copied (samd21/Makefile:24).
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD_DIR)

# Build prelude: ONE injected header per board (invisible porting). Chains
# gpio.h -> ../../common/gpio.h -> $(BOARD_DIR)/config.h -> platform.h in
# exactly that order - see $(BOARD_DIR)/prelude.h for why the order is
# load-bearing. This is the post-prelude canon (samd21/Makefile:26-30);
# never go back to a multi-flag -include chain.
CFLAGS_EXTRA  += -include $(BOARD_DIR)/prelude.h

# Toolchain (PORT-TODO placeholder: point TOOLCHAIN_PATH at your cross
# compiler's bin/ directory, or leave unset to use $(PREFIX)gcc from PATH).
# arm-none-eabi- is the default prefix; change it for a RISC-V or other target.
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
# under the wrong name (bit samd21 twice, ch32v006 once in review - see
# PLAN.md/CONTRACTS.md). BOARD is in the path too (bit samd21 a THIRD time -
# BOARD wasn't keyed, so a no-clean board switch silently shipped the other
# board's binary). New ports copy this file - keep it fixed here.
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BOARD)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources (from grbl directory). Excludes serial.c/nvmem.c/eeprom.c:
# this template uses the TU-replacement route (CONTRACTS.md §0/§7/§10) for
# those three, same as samd21.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources (this directory). Critical sections and sei/cli
# stay pure macros in platform.h (genuinely no state needed - PRIMASK
# save/restore is a two-instruction inline asm sequence on every Cortex-M
# core). Everything else STATEFUL - clock/GPIO-IRQ chip bring-up, the
# delay-loop calibration constants, hal_millis()-class timebases - lives in
# platform.c, same as every landed port (samd21/ch32v006/ch570/hc32f460/
# dspic33ak128mc102/stm32f103 all needed one; a prior revision of this
# template claimed "no state needed" for the whole file, which was only
# ever true of the critical-section macros). ISR *vector* dispatch wrappers
# stay in handlers.c; the TU-replacement files are serial.c/nvmem.c.
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
# Parametrized per DEVICE (see the PORT-TODO comment on DEVICE above) - every
# real port uses this same `-DPLATFORM_$(DEVICE)` form (samd21/ch32v006/
# ch570/dspic33ak128mc102/hc32f460 Makefiles, common/stm32/common.mk); the
# old hardcoded `-DPLATFORM_TEMPLATE` here was the one line the "edit every
# PORT-TODO" convention didn't cover.
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding, rolled into the template so
# every future port inherits it by default). See
# common/stm32/common.mk's matching comment for the full rationale.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# FP PRECISION KNOB (CONTRACTS.md #17: "FP precision is a declared port
# property"). PORT-TODO: every non-AVR port needs this - see samd21/Makefile
# for the full rationale, and PORT-TODO: add the SP libm call-site mapping
# to boards/$(BOARD)/prelude.h (samd21/generic/prelude.h has the pattern).
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
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
else
  CFLAGS += -O0 -g3
  CFLAGS += -DDEBUG
endif

# Linker flags. --gc-sections OMITTED (PORT_TODO_* linker-checklist
# mechanism, CONTRACTS.md #14.3 LIFECYCLE - re-add once this port reaches
# zero PORT_TODO_* at link; ch32v006/Makefile is the reference for the flip).
# -nostartfiles + --specs=nosys.specs: this template supplies its own
# Reset_Handler/vector table, not newlib's crt0; nosys stubs
# _sbrk/_read/_write/_close/_lseek so the PORT_TODO_* signal stays clean of
# unrelated libc syscall symbols.
LDFLAGS  = -mcpu=$(CPU) -mthumb $(FPU) -nostartfiles --specs=nosys.specs
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

# NOTE: "all" intentionally builds only object files, not the linked ELF.
# This template is NOT expected to link (see design note at the top) - a
# real port renames this target back to depend on $(HEX_FILE)/$(BIN_FILE)/
# $(DUMP_FILE) once every PORT_TODO_* symbol is gone (see the "link" target
# below for the diagnostic full-link path used by the self-test).
all: objects

objects: $(BUILD_DIR) $(OUTPUT_DIR) $(OBJECTS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Board stamp: same mechanism as samd21/Makefile (the only port with a real
# second board today) - copy this into a real port so a second BOARD under
# boards/ never reintroduces the "final ELF path outlives the board that
# built it" bug. BUILD_DIR already keys the object dirs by board; this keys
# the LINK step too, without moving ELF_FILE/HEX_FILE/BIN_FILE/MAP_FILE
# (CI/smoke/build_artifacts.py all expect them at this exact un-keyed
# path). FORCE makes the recipe run every invocation; it only rewrites
# (and so only touches mtime) when BOARD actually changed since the last
# stamp. The `link` target below is PHONY and always relinks regardless -
# this stamp matters once a real port flips `all` to depend on
# $(HEX_FILE)/$(BIN_FILE)/$(DUMP_FILE) per the note above.
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

# Diagnostic full link: expected to FAIL with a list of undefined
# PORT_TODO_* symbols - that failure IS the exit test for Step 0 of
# PORTING-CHECKLIST.md ("undefined PORT_TODO_* symbols enumerate the
# remaining work by name"). Kept as its own target (not part of "all") so
# CI/`make all` never trips over an expected-red exit code.
link: objects $(BOARD_STAMP)
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)
	$(ASSERT_FP)
	@sh $(INIT_CHECK) $(PREFIX)nm $(ELF_FILE) $(INIT_SYMBOLS)

# BOOT-INIT REACHABILITY (BUG #23 ratchet, CONTRACTS.md
# #boot-init-unreachable) - DO NOT DELETE THIS.
#
# Four landed ports shipped a complete, reviewed hal_system_init() ->
# hal_clock_config() + hal_gpio_init() chain that NOTHING CALLED. Core
# grbl/main.c is the golden gate and never calls platform init; no
# Reset_Handler called it either; -flto deleted the entire subgraph. The
# link succeeded, --gc-sections was happy, `size` looked normal,
# boot_check.sh above PASSED (the vector table was fine) - and the chips
# booted on their reset-default oscillator with unconfigured GPIO. DEBUG
# (no LTO) retained the dead code and looked perfect.
#
# After -flto + --gc-sections a function survives ONLY if something reaches
# it, so "defined in the final ELF" == "reachable". This check demands that
# of every symbol you list.
#
# PORT-TODO: list every function that must run before main() - your
#            Reset_Handler (or the toolchain crt0 entry on a target where
#            crt0 is supplied, see dspic33ak128mc102/Makefile), plus each
#            clock/GPIO bring-up function it reaches. Names differ per port
#            by design; that is why this is declared here and not shared.
# PORT-TODO: tag every function you list GRBL_BOOT_INIT (common/boot_init.h)
#            at BOTH its declaration and its definition. That macro is
#            `noinline` and deliberately NOT `used`: a single-call-site init
#            inlined into Reset_Handler leaves no symbol and would look
#            exactly like the bug, while `used` would force the symbol into
#            the image whether or not anything called it - blinding this
#            check completely.
INIT_CHECK   = ../common/init_check.sh
INIT_SYMBOLS = Reset_Handler,SystemInit

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
# BOOT INTEGRITY (BUG #21, CONTRACTS.md S18) - DO NOT DELETE. See
# common/boot_check.sh for the LTO/vector-table rationale; startup.c's
# Reset_Handler must set SCB->VTOR and vector_table must be
# __attribute__((used)).
# PORT-TODO: set FLASH_ORIGIN/FLASH_LENGTH to match script.ld MEMORY{FLASH}.
# PORT-TODO: on a non-ARM target (no SP-in-word0 convention) replace this
#            with an entry-point assertion instead - see ch32v006/Makefile.
BOOT_CHECK   = ../common/boot_check.sh
FLASH_ORIGIN = 0x00000000
FLASH_LENGTH = 65536

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@sh $(BOOT_CHECK) $@ $(FLASH_ORIGIN) $(FLASH_LENGTH)

# Create disassembly dump
$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

# Debug with gdb
debug: $(ELF_FILE)
	$(GDB) $<

# Generate compile_commands.json for clangd/LSP (stdlib-only, no bear/compiledb).
# Same mechanism as every other platform (tools/gen_compile_commands.py) -
# reused as-is, nothing platform-specific in the tool itself.
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
	@echo "GRBL $(PLATFORM_NAME) Build System (COPY-ME TEMPLATE - see README.md)"
	@echo ""
	@echo "Usage:"
	@echo "  make              - Compile all object files (DEBUG, default)"
	@echo "  make BUILD=RELEASE - Compile all object files, optimized"
	@echo "  make link         - Attempt full link (EXPECTED TO FAIL until the"
	@echo "                      port is complete - undefined PORT_TODO_* symbols"
	@echo "                      enumerate remaining work by name)"
	@echo "  make compdb       - Generate compile_commands.json for clangd/LSP"
	@echo "  make clean        - Clean current build"
	@echo "  make clean-all    - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform = $(PLATFORM_NAME)"
	@echo "  Board    = $(BOARD)"
	@echo "  CPU = $(CPU)"
	@echo "  Clock = $(CLOCK) Hz"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all objects link clean clean-all debug help compdb

# Include dependencies
-include $(BUILD_DIR)/*.d
