#  Makefile for GRBL on dsPIC33AK128MC102 (dsPIC33A 32-bit DSC core)
#  Part of Grbl
#
#  Phase 6 rolling port #2 - THE THIRD ISA FAMILY (neither ARM nor RISC-V).
#  Modeled on grbl/platform/ch32v006/Makefile (the newest non-ARM port);
#  see _template/README.md for the general copy/rename/fill-in order.
#
#  TOOLCHAIN (PLAN.md Decision Log recipe, re-verified end-to-end this
#  session - xc-dsc-gcc 8.3.1 / XC-DSC v3.30, EULA approved by owner
#  2026-07-24):
#
#    1. Download (83 MB, SHA-256
#       0df20c1a552bf0ce08aa139b9cb1efd71bf65b9d9f37e3982763f4f8738bfa11):
#       https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc-dsc-v3.30-full-install-linux64-installer.run
#    2. Unattended install (the trailing --netservername "" is REQUIRED
#       though undocumented - installer hangs/fails without it):
#       ./xc-dsc-v3.30-full-install-linux64-installer.run --mode unattended \
#         --unattendedmodeui none --prefix /opt/xc-dsc --LicenseType FreeMode \
#         --ModifyAll 0 --netservername ""
#       FreeMode is the INSTALLER'S OWN DEFAULT, not a restrictive choice made
#       here - the alternatives (WorkstationMode/NetworkMode) need an
#       account-bound activated license file, not a flag, so no install-recipe
#       change avoids what FreeMode does below. Settled by codegen comparison
#       (PLAN.md Decision Log 2026-07-26): FreeMode silently substitutes -O2
#       codegen for -O3/-Os ("Options have been disabled due to restricted
#       license" printed, no functional effect on -O0/-O1/-O2 which already
#       compile at their own level) - RELEASE below is -O2-equivalent, not
#       true -Os, but its byte count is exact and reproducible (proven via a
#       byte-identical whole-firmware rebuild with an explicit -O2).
#    3. Device Family Pack (SEPARATE download, Apache-2.0 licensed - see
#       gpio.h header for why this port uses DFP headers instead of the
#       samd21 clean-room route):
#       https://packs.download.microchip.com/Microchip.dsPIC33AK-MC_DFP.1.5.263.atpack
#       unzip into $(DFP_PATH) (an .atpack is a plain zip).
#
#  COMPILE PATTERN (Decision Log, verified): -mcpu=33AK128MC102
#  -mdfp=$(DFP_PATH)/xc16 AND an explicit -Wl,--script=<dfp .gld> - the
#  toolchain's built-in default linker script is 30F-era and does not fit
#  this device.
#
#  NOT IN CI YET: unattended toolchain fetch in CI is a separate ledger
#  item (PLAN.md Phase 6) - this Makefile is CI-shaped (all knowledge here,
#  thin-invoker compatible) but no .github/workflows/ci.yml row exists.

# A failed recipe must not leave a half-built target on disk for the next
# `make` to mistake for up to date (skipping objcopy/the FP+boot guards).
.DELETE_ON_ERROR:

# ============================================================================
# Chip identification
# ============================================================================

PLATFORM_NAME  = dspic33ak128mc102
DEVICE         = DSPIC33AK128MC102
# -mcpu drives codegen AND predefines __dsPIC33AK128MC102__ (which <xc.h>
# dispatches on); there is no -march/-mabi split on this toolchain.
MCPU           = 33AK128MC102
# Verified system clock in Hz - feeds F_CPU (PORTING-CHECKLIST Step 1).
# 200 MHz = FRC 8 MHz -> PLL1 (FBDIV=200, PRE=1, POSTDIV1=4, POSTDIV2=2)
# -> CLKGEN1 NOSC=5. Sequence encoded in platform.c from Microchip's own
# dsPIC33A clock documentation; UNVERIFIED ON SILICON (no emulator exists
# for dsPIC33A) - hardware validation item, see platform.c banner.
CLOCK          = 200000000

# Board selection (only "generic" ships with this port)
BOARD         ?= generic
BOARD_DIR      = boards/$(BOARD)

# Include paths (platform dir first to override common/dummy defaults).
# common/dummy supplies the AVR compatibility stubs every non-AVR platform
# needs (avr/io.h, cpu_map.h, util/delay.h, ...) - reused as-is.
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD_DIR)

# Build prelude: ONE injected header per board (CONTRACTS.md #0).
CFLAGS_EXTRA  += -include $(BOARD_DIR)/prelude.h

# Toolchain. XC-DSC is never on PATH by default - point TOOLCHAIN_PATH at
# the install prefix's bin directory (recipe above) or add it to PATH.
TOOLCHAIN_PATH ?= /opt/xc-dsc/bin
ifneq ($(TOOLCHAIN_PATH),)
  PREFIX     = $(TOOLCHAIN_PATH)/xc-dsc-
else
  PREFIX     = xc-dsc-
endif
CC         = $(PREFIX)gcc
OBJCOPY    = $(PREFIX)objcopy
OBJDUMP    = $(PREFIX)objdump
BIN2HEX    = $(PREFIX)bin2hex
NM         = $(PREFIX)nm

# Device Family Pack root (the unzipped .atpack - must contain xc16/).
DFP_PATH  ?= /opt/Microchip.dsPIC33AK-MC_DFP.1.5.263
DFP_XC16   = $(DFP_PATH)/xc16
GLD_SCRIPT = $(DFP_XC16)/support/dsPIC33A/gld/p$(MCPU).gld

# Paths
GRBL_DIR   = ../..
# Keyed by BUILD flavor: DEBUG/RELEASE object dirs never alias, so switching
# flavors without `make clean` can't silently relink stale objects under the
# wrong name (thrice-bitten repo-wide fix - see PLAN.md).
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources. Excludes serial.c/nvmem.c/eeprom.c: TU-replacement
# route (CONTRACTS.md #0/#7/#10), same as samd21/_template/ch32v006.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

# Platform-specific sources. NO startup.c: unlike every ARM/RISC-V port,
# the XC-DSC toolchain's own crt0 is used deliberately (verified by
# disassembly this session: __reset sets W15/SPLIM/IVTBASE, runs __data_init
# over .dinit, then calls __user_init-marked functions, then main -
# platform.c's hal_clock_config carries __attribute__((user_init))).
# See platform.c's "startup model" banner for the full writeup.
PLATFORM_SOURCES = platform.c handlers.c serial.c nvmem.c

# All sources
SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# Search paths for sources (platform dir first to override grbl/ files)
vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

# Base compiler flags.
# -std=gnu11: XC-DSC v3.30 is GCC 8.3.1 - full C11 (_Static_assert et al)
# is available but the toolchain default is gnu99-era; pin it explicitly.
ARCHFLAGS = -mcpu=$(MCPU) -mdfp=$(DFP_XC16)
CFLAGS  = $(ARCHFLAGS) -std=gnu11
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)UL
CFLAGS += -Wall -Wextra

# ----------------------------------------------------------------------------
# FP PRECISION KNOB (CONTRACTS.md #17) - THIS PORT'S DECLARED DEFAULT IS
# DOUBLE, the opposite default of every prior port (samd21/ch32v006 both
# default SINGLE, template-faithful AVR double==float semantics).
#
# WHY: dsPIC33AK128MC102 has a NATIVE hardware DOUBLE-PRECISION FPU
# (platform.h PLATFORM_HAS_FPU, DFP-confirmed dual-precision FPU) - the
# first port in this tree where 64-bit float arithmetic is a few cycles
# in silicon rather than either (a) free because it's identical to
# single (AVR) or (b) tens of software soft-float instructions per op
# (every M0+/rv32ec port so far). §17.3's own framing: "FP=DOUBLE ... is
# intended for ports with a native DP FPU (dsPIC33AK class) where DP costs
# cycles, not kilobytes. The M0+/rv32ec class is exactly who should never
# use it." This chip is exactly who SHOULD: DOUBLE is MORE PRECISE than
# the AVR-template SINGLE semantics (a conscious upgrade, not a template
# violation - §17.3 requires it be declared as a port property, which
# this comment + CONTRACTS.md #16/#17 do), and costs nothing extra in
# code size or cycles versus SINGLE on this hardware (the FPU does 32-bit
# and 64-bit ops at comparable cost - unlike every soft-float port where
# DOUBLE measurably grows .text by ~25%, CONTRACTS.md #17.2).
#
# FP=SINGLE remains available (the knob still works both ways - a future
# board/use-case that wants AVR-bit-exact arc/junction math could ask for
# it) but is NOT this port's default and has not been exercised this
# session (no Renode/emulator exists for dsPIC33A - CONTRACTS.md #16).
FP ?= DOUBLE
# BOOT-INIT REACHABILITY KNOB (BUG #23, CONTRACTS.md #boot-init-unreachable).
# Post-link proof that this port's pre-main bring-up is still REACHABLE.
# Four sibling ARM ports (stm32f103/f411/h523, hc32f460) shipped a complete
# bring-up chain that nothing called - core grbl/main.c is the golden gate
# and never calls platform init - and LTO silently deleted all of it.
#
# This port reaches its clock config by a DIFFERENT mechanism and so needs a
# different symbol list, which is exactly why the list is per-port:
#   __reset            - the toolchain crt0 reset entry (this port has no
#                        hand-written startup.c; xc-dsc supplies crt0).
#   __user_init        - the crt0 phase that walks the .user_init table of
#                        function pointers, after __data_init/.dinit and
#                        before main().
#   _hal_clock_config  - platform.c's 200MHz PLL1 bring-up, tagged
#                        __attribute__((user_init)) so its ADDRESS lands in
#                        that table. Address-taken means it can never be
#                        inlined away, so it needs no GRBL_BOOT_INIT anchor;
#                        this check is what proves the table still points at
#                        it. Underscore prefix = the pic30 assembler naming
#                        convention, hence a per-port list rather than a
#                        shared one.
#   _main              - end of the chain.
# There is no _hal_gpio_init: this port follows the AVR model where TRIS/
# ANSEL/CNPU are set per pin group by core's stepper_init/limits_init/
# system_init/spindle_init/coolant_init/probe_init, and the device has no
# GPIO clock gating to enable first.
INIT_SYMBOLS ?= __reset,__user_init,_hal_clock_config,_main
INIT_CHECK = ../common/init_check.sh

ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(NM) $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port property (native DP FPU, CONTRACTS.md \#17) - no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# CFLAGS_EXTRA must be ABSOLUTELY FIRST to override grbl headers (cpu_map.h, etc)
CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

# Build-specific flags
BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  # Requested -Os; the free-tier compiler (see toolchain header note above)
  # silently gives -O2-equivalent codegen instead. That does not make the
  # resulting size approximate - a whole-firmware rebuild with an explicit
  # -O2 here is byte-identical (41816 B) to what this line actually produces.
  CFLAGS += -Os -g0
else
  # -O0, NOT -Og: xc-dsc-gcc 8.3.1 ICEs ("insn does not satisfy its
  # constraints ... movfpsf_32 ... during RTL pass: postreload",
  # gcode.c:1133) at -Og AND -O1 - an FPU float-store-to-static pattern.
  # Probed empirically this session: -O0/-O2/-O3/-Os all clean, only
  # -O1/-Og trip it. 128 KB flash absorbs -O0 (no ch32-class squeeze).
  # Logged in CONTRACTS.md #16.
  CFLAGS += -O0 -g3
  CFLAGS += -DDEBUG
endif

# Linker flags. The explicit DFP .gld is load-bearing (see header). No
# --gc-sections anywhere on this toolchain (verified: `xc-dsc-gcc
# -dumpspecs` contains no gc-sections rule, unlike picolibc's - the
# CONTRACTS.md #14.3 hazard does not apply here), so the linker's undefined-
# symbol report is the complete PORT_TODO_* checklist by construction.
LDFLAGS  = $(ARCHFLAGS)
LDFLAGS += -Wl,--script=$(GLD_SCRIPT)
LDFLAGS += -Wl,-Map=$(MAP_FILE)

# libm: core grbl is float-heavy (planner/gcode/motion_control); the
# dsPIC33A hardware FPU (single+double precision) is used automatically by
# -mcpu codegen. DFP/xc-dsc supply the matching libm.
LIBS = -lm

# Output file naming: release gets clean name, debug gets _dbg suffix
ifeq ($(BUILD),RELEASE)
  BINARY_NAME = grbl_$(PLATFORM_NAME)
else
  BINARY_NAME = grbl_$(PLATFORM_NAME)_dbg
endif

# Output files - artifacts go to /build, object files to /build/$(PLATFORM_NAME)/$(BUILD)
ELF_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).elf
HEX_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).hex
BIN_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).bin
DUMP_FILE = $(OUTPUT_DIR)/$(BINARY_NAME).dump
MAP_FILE  = $(OUTPUT_DIR)/$(BINARY_NAME).map

# ============================================================================
# TARGETS
# ============================================================================

# Steps 3-6 complete, zero PORT_TODO_* remain (per the M1-M3-era comment's
# own instruction: "flip `all` to the full ELF+hex once zero remain") -
# default target now builds the full ELF+hex+bin, matching every other
# completed port's Makefile shape (bin added: tools/build_artifacts.py /
# PLAN.md "build artifacts tracked in git" batch - this toolchain's ELF is
# a Microchip `elf32-pic30` variant, so plain objcopy needs an explicit
# -I to recognise it; see the $(BIN_FILE) recipe below).
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

$(BUILD_DIR)/handlers.o: handlers.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/serial.o: serial.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/nvmem.o: nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# Link diagnostic (enumerates any remaining PORT_TODO_* work by name -
# empty output at zero PORT_TODO_* is the Definition-of-Done proof).
link: $(ELF_FILE)

$(ELF_FILE): objects
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(ASSERT_FP)
	@sh $(INIT_CHECK) $(NM) $(ELF_FILE) $(INIT_SYMBOLS)

# Create hex file (xc-dsc-bin2hex writes alongside the ELF).
# -mdfp= is REQUIRED here exactly as for nm/objdump below: bin2hex hard-
# requires DFP device info to resolve memory ranges/records, it just fails
# silently different from gcc/ld (which get it via $(ARCHFLAGS)) - omitting
# it made `make all` fail at this step for both flavors (CI's KNOWN GAP
# workaround is no longer needed once this is fixed; see PLAN.md).
$(HEX_FILE): $(ELF_FILE)
	$(BIN2HEX) -mdfp=$(DFP_XC16) $<

# Create raw binary. This toolchain's ELF is tagged `elf32-pic30` (`file`
# reports "ELF 32-bit LSB executable, Microchip dsPIC30F"), NOT one of
# plain objcopy's autodetected bfd targets - an unqualified `-O binary`
# fails with "Unable to recognise the format of the input file". The
# explicit `-I elf32-pic30` (confirmed via `xc-dsc-objcopy --info`, which
# lists elf32-pic30 as a real bfd target on this toolchain) fixes that;
# every other port's Makefile in this tree needs no such input-format hint
# because their arm-none-eabi-/riscv64-unknown-elf- objcopy builds
# autodetect a plain ELF32 just fine.
$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -I elf32-pic30 -O binary $< $@

# Create disassembly dump (objdump needs the DFP for SFR symbolization)
$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -mdfp=$(DFP_XC16) -Sxdstr $< >$@

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
	@echo "GRBL $(PLATFORM_NAME) Build System (Phase 6 rolling #2 - Steps 3-6 complete)"
	@echo ""
	@echo "Usage:"
	@echo "  make               - Build full ELF+hex (DEBUG, default)"
	@echo "  make BUILD=RELEASE - Build full ELF+hex, optimized"
	@echo "  make FP=SINGLE     - Build with AVR-template single-precision FP (default: DOUBLE)"
	@echo "  make link          - Linker-as-checklist: zero PORT_TODO_* expected"
	@echo "  make compdb        - Generate compile_commands.json for clangd/LSP"
	@echo "  make clean         - Clean current build"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform = $(PLATFORM_NAME)"
	@echo "  Board    = $(BOARD)"
	@echo "  CPU      = $(MCPU) (dsPIC33A 32-bit DSC)"
	@echo "  Clock    = $(CLOCK) Hz"
	@echo "  Toolchain= $(PREFIX)gcc"
	@echo "  DFP      = $(DFP_PATH)"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output directory = $(BUILD_DIR)"

.PHONY: all objects link clean clean-all help compdb

# Include dependencies
-include $(BUILD_DIR)/*.d
