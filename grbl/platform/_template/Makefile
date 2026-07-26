#  Makefile for GRBL on _template (copy-me starting point for new ports)
#  Part of Grbl
#
#  This Makefile is modeled directly on grbl/platform/samd21/Makefile - the
#  canonical post-prelude structure. Copy this whole _template/ directory,
#  rename it to your platform, then edit every line marked PORT-TODO below.
#  See README.md for the full copy -> rename -> fill-in order.
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
# Your chip part number, e.g. STM32F103C8.
DEVICE         = CHANGEME
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
# Keyed by BUILD flavor: DEBUG/RELEASE object dirs never alias, so switching
# flavors without `make clean` can't silently relink stale objects under the
# wrong name (bit samd21 twice, ch32v006 once in review - see PLAN.md/
# CONTRACTS.md). New ports copy this file - keep it fixed here.
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources (from grbl directory). Excludes serial.c/nvmem.c/eeprom.c:
# this template uses the TU-replacement route (CONTRACTS.md §0/§7/§10) for
# those three, same as samd21.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources (this directory). No platform.c: critical
# sections and sei/cli are pure macros in platform.h (no state needed);
# everything else stateful (ISR dispatch wrappers, delay stubs) lives in
# handlers.c, and the TU-replacement files are serial.c/nvmem.c.
PLATFORM_SOURCES = startup.c handlers.c serial.c nvmem.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources (platform dir first to override grbl/ files)
vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

# Base compiler flags
CFLAGS  = -mcpu=$(CPU) -mthumb $(FPU)
CFLAGS += -DPLATFORM_TEMPLATE -DF_CPU=$(CLOCK)
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding, rolled into the template so
# every future port inherits it by default). See
# common/stm32/common.mk's matching comment for the full rationale.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

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

# Linker flags. NOTE: --gc-sections is deliberately OMITTED here (unlike
# samd21). The ISR dispatch wrappers in handlers.c are not yet wired into
# any real vector table (this chip's IRQ layout is unknown), so nothing
# keeps them reachable from Reset_Handler; --gc-sections would silently
# discard those functions - and the PORT_TODO_* symbols they reference -
# before the linker ever reports them, defeating the whole
# linker-as-checklist mechanism (CONTRACTS.md, "the cautionary tale").
# Objects on this link line are passed directly (not archived), so without
# --gc-sections every section from every .o is kept and every PORT_TODO_*
# reference surfaces. Re-add -Wl,--gc-sections once your vector table
# really calls these dispatchers (PORTING-CHECKLIST Step 6).
# -nostartfiles: this template supplies its own Reset_Handler/vector table
# (startup.c) instead of newlib's crt0 - without this flag the linker still
# pulls crt0.o in as a start file (independent of --gc-sections, which is
# already omitted above), and crt0's _mainCRTStartup drags in exit()/_read/
# _write/_sbrk/_close/_lseek from libc.a purely as C-runtime plumbing -
# undefined-reference noise that has nothing to do with this port and would
# pollute the PORT_TODO_* self-test signal.
#
# --specs=nosys.specs: some reachable libm/libc code path (unrelated to any
# PORT_TODO_*) still references the low-level _sbrk/_read/_write/_close/
# _lseek syscall stubs - normally invisible because --gc-sections (which
# this template omits on purpose, see above) strips the specific unused
# function pulling them in. nosys.specs supplies real (error-returning) stub
# definitions for exactly those five, so the self-test's undefined-symbol
# list stays 100% PORT_TODO_* signal. It does NOT switch to newlib-nano (no
# feature/size tradeoff) - just the syscall layer.
#
# --gc-sections LIFECYCLE (CONTRACTS.md #14.3): "omit while PORT_TODO_* is
# non-empty, re-add once it's zero" applies to every port copied from this
# template, this Makefile included - a porter should flip the comment
# above (and re-add -Wl,--gc-sections) the same session the port's
# `make link` first reports zero PORT_TODO_*, not leave it omitted
# forever "because the template did it that way." ch32v006/Makefile is
# the reference: it started with this template's exact posture, then
# needed an *explicit* -Wl,--no-gc-sections (not just omission) because
# its picolibc-based toolchain's `-specs=picolibc.specs` unconditionally
# re-appends --gc-sections to the link line regardless of what this
# Makefile passes (a hazard this nosys.specs/arm-none-eabi toolchain does
# NOT have - confirmed via -dumpspecs; that's why plain omission is
# sufficient here and picolibc needed the stronger override) - then, once
# the port reached zero PORT_TODO_* (all handlers wired into a real
# vector table), switched to -Wl,--gc-sections for the size win with no
# regression, verified by KEEP()ing the vector table in script.ld and
# comparing nm/readelf on the IVT symbols before/after the flip.
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

# Compile GRBL core files
$(BUILD_DIR)/%.o: $(GRBL_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Compile platform-specific files
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
link: objects
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)

# Create hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# Create binary file
#
# BOOT INTEGRITY (BUG #21 ratchet, CONTRACTS.md S18) - DO NOT DELETE THIS.
# On a RELEASE (-flto) build the linker will happily produce an image with no
# vector table: KEEP(*(.isr_vector)) acts at link time, but LTO's whole-program
# IPA deletes an unreferenced vector_table[] before codegen, so there is no
# input section left for KEEP to match. The link succeeds, `size` looks normal,
# and the chip cannot boot because word0 of the .bin is code instead of the
# initial SP. DEBUG (no LTO) looks fine - "DEBUG works / RELEASE bricks" is the
# signature. This check reads word0/word1 of the finished image and fails the
# build unless they are a real (SP, Thumb reset vector) pair.
#
# The image-side half of the fix lives in startup.c: Reset_Handler must write
# SCB->VTOR = (uint32_t)vector_table, and vector_table must carry
# __attribute__((used)).
#
# PORT-TODO: set FLASH_ORIGIN/FLASH_LENGTH to match script.ld MEMORY{FLASH}.
# PORT-TODO: on a non-ARM target (RISC-V has no SP-in-word0 convention) replace
#            this with an equivalent entry-point assertion rather than deleting
#            it - see ch32v006/Makefile for how that is written up.
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
