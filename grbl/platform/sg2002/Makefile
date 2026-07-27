#  Makefile for GRBL on the Sophgo SG2002 C906L runtime core
#  Part of Grbl
#
#  Modeled on ch570/Makefile (same toolchain family) with the SG2002
#  deltas: RV64 instead of RV32, a DDR carve-out instead of flash, and the
#  cross-core coherency knob this port introduces.
#
#  TOOLCHAIN: the same two apt packages every other RISC-V port here uses -
#    sudo apt-get install -y gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf
#
#  ===========================================================================
#  ARCH/ABI: rv64imafc_zicsr / lp64f - HARDWARE SINGLE-PRECISION FLOAT
#  ===========================================================================
#  Previously rv64imac/lp64 (soft float) on the reasoning that whether F/D
#  survive the cut-down "L" core was undocumented community guesswork and an
#  lp64f binary traps on its first FLW if F is actually absent. That
#  uncertainty is now RESOLVED by a primary source stronger than community
#  inference: Milk-V/Sophgo's own shipped FreeRTOS SDK for this EXACT core -
#  github.com/milkv-duo/milkv-duo-smallcore-freertos (the small-core runtime,
#  same C906L / "C906-NOMMU" silicon this port targets, same chip family
#  CV1800B/SG2002 share) - builds with
#  `cvitek/scripts/toolchain-riscv64-elf.cmake`:
#    -march=rv64imafdc -mabi=lp64d -mcmodel=medany
#  That is the VENDOR compiling real, shipped, hardware-run firmware for this
#  silicon with hardware DOUBLE-precision float. F is therefore not merely
#  present - a core implementing D structurally must implement F too - so
#  targeting rv64imafc/lp64f (single precision only) is a strict, safe SUBSET
#  of what the vendor itself proves the hardware executes.
#
#  This project stays on SINGLE, not double, by its own project-wide FP
#  policy (CONTRACTS.md #17's default, `tools/assert_no_double.sh`), not
#  because double is unavailable here - unlike dspic33ak128mc102, which
#  affirmatively chose FP=DOUBLE as ITS default because ITS FPU is native DP
#  and its port author wanted that. sg2002 keeps the tree-wide SINGLE default.
#
#  Toolchain multilib CONFIRMED (not merely requested) on the installed tree:
#  `riscv64-unknown-elf-gcc -march=rv64imafc_zicsr -mabi=lp64f
#  -print-multi-directory` answers `rv64imafc/lp64f`, and
#  `/usr/lib/picolibc/riscv64-unknown-elf/lib/rv64imafc/lp64f/` ships
#  crt0.o/libc.a/libm.a. Measured effect on this port's own real objects, not
#  a synthetic test TU: see the RELEASE/DEBUG size table in PLAN.md's
#  sg2002 hardware-float entry.
#
#  `_zicsr` is appended explicitly for the reason CONTRACTS.md §14 item 1
#  records: this binutils generation treats Zicsr as unbundled from the base
#  ISA letters, so every `csr*` instruction (critical sections, mtvec, mie)
#  fails to assemble without it.

.DELETE_ON_ERROR:

# ============================================================================
# Chip identification
# ============================================================================

PLATFORM_NAME  = sg2002
DEVICE         = SG2002
ARCH           = rv64imafc_zicsr
ABI            = lp64f

# ---------------------------------------------------------------------------
# CLOCK -> F_CPU. THIS IS THE APB TIMER'S INPUT CLOCK, NOT THE CPU CLOCK.
#
# F_CPU is what core treats as the STEPPER TIMER's tick rate (nuts_bolts.h
# TICKS_PER_MICROSECOND, stepper.c's AMASS cutoffs). Declaring the ~700 MHz
# CPU frequency here would overflow the 8-bit pulse-width horizon of
# CONTRACTS.md §4 for every realistic pulse setting - platform.h's static
# asserts enforce that and will fail the build if this is raised too far.
#
# UNVERIFIED: 25 MHz is the community-reported cv18xx APB reference. A
# bring-up engineer MUST MEASURE the real rate and correct this line; a wrong
# value is invisible to every gate in this project and scales every feedrate
# by a constant factor.
# ---------------------------------------------------------------------------
CLOCK          = 25000000

# ---------------------------------------------------------------------------
# PLIC context for this core in machine mode (sg2002.h explains why this is
# a knob rather than a constant: it is the single most likely fact in the
# port to be wrong, and its failure mode - no interrupt ever delivered - is
# distinctive).
# ---------------------------------------------------------------------------
PLIC_CONTEXT  ?= 2

# ---------------------------------------------------------------------------
# SHM_COHERENCY - declared port property (CONTRACTS.md cross-core-cache-
# coherency). Full justification in shm.h's header.
#   CMO (default)  explicit T-Head cache maintenance around every cross-core
#                  access. Correct whether or not the window is cacheable.
#   NONCACHEABLE   integrator has CONFIRMED the carve-out is non-cacheable on
#                  this core. Cache ops removed; ordering fences KEPT.
# Neither is a no-op. Anything else is a hard error, never a quiet default.
# ---------------------------------------------------------------------------
SHM_COHERENCY ?= CMO

BOARD         ?= generic
BOARD_DIR      = boards/$(BOARD)

# common/dummy supplies the AVR compatibility stubs every non-AVR platform
# needs - reused as-is, never copied.
CFLAGS_EXTRA   = -I. -I../common/dummy -I$(BOARD_DIR)
CFLAGS_EXTRA  += -include $(BOARD_DIR)/prelude.h

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
NM         = $(PREFIX)nm
GDB        = $(PREFIX)gdb

GRBL_DIR   = ../..
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources. Excludes serial.c/nvmem.c/eeprom.c: TU-replacement route
# (CONTRACTS.md #0/#7/#10), same as ch570/ch32v006/samd21.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

PLATFORM_SOURCES = platform.c startup.c handlers.c serial.c nvmem.c

SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI) -mcmodel=medany
CFLAGS  = $(ARCHFLAGS)
# CONTRACTS.md #36 (clock-constant-width): ULL, not UL - required regardless
# of whether today's CLOCK value happens to fit under 32 bits (it does, at
# 25 MHz, but a future board's APB reference need not). unsigned long is
# 32-bit even under this port's own lp64 ABI (long is 64-bit under LP64, but
# the rule is ABI-independent by design - see clock_width.h's _Static_assert,
# included from boards/$(BOARD)/prelude.h).
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)ULL
CFLAGS += -D__$(DEVICE)__
CFLAGS += -DSG2002_PLIC_CONTEXT=$(PLIC_CONTEXT)u
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# Build-path independence for DEBUG's DWARF info (CONTRACTS.md
# #build-artifacts-tracked "DEBUG .elf manifest hashes are build-path
# dependent" - adversarial review finding). See common/stm32/common.mk's
# matching comment for the full rationale.
CFLAGS += -ffile-prefix-map=$(CURDIR)=/grbl-src

# -mcmodel=medany is REQUIRED, not a tuning choice: the default medlow model
# addresses globals with a signed 32-bit offset from ZERO, which cannot reach
# this image's link address (0x8FE00000 and up) at all. medany makes every
# such reference PC-relative.

# ---------------------------------------------------------------------------
# SHM_COHERENCY -> the compile-time declaration platform.h/shm.h validate.
# ---------------------------------------------------------------------------
ifeq ($(SHM_COHERENCY),CMO)
  CFLAGS += -DSG2002_SHM_COHERENCY_CMO=1
else ifeq ($(SHM_COHERENCY),NONCACHEABLE)
  CFLAGS += -DSG2002_SHM_COHERENCY_NONCACHEABLE=1
else
  $(error SHM_COHERENCY must be CMO or NONCACHEABLE, got "$(SHM_COHERENCY)")
endif

# ---------------------------------------------------------------------------
# FP PRECISION KNOB (CONTRACTS.md #17). rv64imafc has F (hardware single
# precision) but deliberately not D - a `double` anywhere in port code would
# be DP-soft-float, unlike ch32v006's rv32ec/ch570's rv32imc which have
# neither F nor D. Same leak class, same fix (FP=SINGLE keeps all arithmetic
# in float), same post-link proof (assert_no_double.sh).
# ---------------------------------------------------------------------------
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(NM) $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# picolibc supplies libc/libm; -nostartfiles because startup.c supplies its
# own _start.
CFLAGS += -specs=picolibc.specs

# BOOT-INIT REACHABILITY (BUG #23, CONTRACTS.md #boot-init-unreachable): the
# post-link proof that Reset_Handler's pre-main chain is still reachable, not
# silently dropped. RELEASE now builds with -flto (see LDFLAGS below), so this
# is a LIVE check, not "cheap insurance" - GRBL_BOOT_INIT/`used` are what keep
# SystemClock_Config/sg2002_plic_init/Reset_Handler from being IPA-deleted as
# apparently-uncalled (LTO's whole-program analysis never parses the asm text
# inside _start that calls Reset_Handler - CONTRACTS.md gap log, same
# mechanism ch32v006/ch570 already document for their own Reset_Handler).
INIT_SYMBOLS ?= Reset_Handler,SystemClock_Config,sg2002_plic_init
INIT_CHECK = ../common/init_check.sh

CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
  # LTO: RELEASE only (house style, matches samd21/stm32*/hc32f460/ch32v006/
  # ch570). DEBUG stays plain -Og for debuggability. `_start` needs no `used`
  # (unlike Reset_Handler): it is this image's linker ENTRY() point, which ld
  # requires resolved independent of any C-visible caller, so LTO's IPA
  # cannot treat it as dead the way it can an ordinary internally-referenced
  # function - same reasoning already holds for ch32v006/ch570's own `_start`,
  # neither of which carries `used` either. Reset_Handler/SystemClock_Config/
  # sg2002_plic_init DO need it/GRBL_BOOT_INIT - see the INIT_SYMBOLS comment
  # above - and init_check.sh proves it below, not just by assertion.
  CFLAGS += -flto -fno-fat-lto-objects
else
  CFLAGS += -Og -g3
  CFLAGS += -DDEBUG
endif

# --gc-sections from the start. CONTRACTS.md §14 item 3's porting-time
# `--no-gc-sections` posture exists only to keep the linker-as-checklist
# honest while PORT_TODO_* stubs remain; this port had no such phase (every
# interrupt source is wired to a real handler in the first working build), and
# both preconditions for the flip hold: `_start` has an independent KEEP()
# anchor in script.ld, and nothing else in the image is reached only by
# address. The shared window is not a section at all, so section-reachability
# analysis cannot touch it either.
LDFLAGS  = $(ARCHFLAGS) -nostartfiles -specs=picolibc.specs
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(MAP_FILE)
LDFLAGS += -T script.ld

# LTO for RELEASE (house style, matches ch32v006/ch570/samd21/stm32*/
# hc32f460): -flto must be present at link time too, not just in CFLAGS,
# for the linker's LTO plugin to drive the whole-program IR.
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

# ============================================================================
# TARGETS
# ============================================================================

all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE) warn_check

objects: $(BUILD_DIR) $(OUTPUT_DIR) $(OBJECTS)

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

$(BUILD_DIR)/serial.o: serial.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/nvmem.o: nvmem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

link: $(ELF_FILE)

$(ELF_FILE): objects
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)
	$(ASSERT_FP)
	@sh $(INIT_CHECK) $(NM) $(ELF_FILE) $(INIT_SYMBOLS)

$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# ============================================================================
# BOOT INTEGRITY (BUG #21 ratchet, CONTRACTS.md §18) - RISC-V form.
#
# RISC-V has no SP-in-word0 convention, so the architecture-appropriate
# invariant (ch32v006/ch570 precedent) is that `_start` links at the image
# base. It carries EXTRA weight here: this image is loaded by a Linux
# remoteproc driver that copies PT_LOAD segments to their p_paddr and then
# starts the core at the ELF entry - an entry that drifted off the carve-out
# base would be started at an address nothing was written to.
#
# MUST MATCH script.ld's MEMORY{CODE} ORIGIN. 64-bit nm prints 16 hex digits.
# ============================================================================
BOOT_ENTRY_ADDR = 000000008fe00000

$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@
	@start=$$($(NM) $(ELF_FILE) | grep ' _start$$' | cut -d' ' -f1); \
	 if [ "$$start" != "$(BOOT_ENTRY_ADDR)" ]; then \
	   echo ""; \
	   echo "====================================================================="; \
	   echo "BOOT INTEGRITY: FAIL - _start is not at the carve-out base"; \
	   echo "  _start   = 0x$${start:-<missing>}"; \
	   echo "  expected = 0x$(BOOT_ENTRY_ADDR) (script.ld MEMORY{CODE} ORIGIN)"; \
	   echo "  first 16 bytes of $@:"; \
	   od -An -tx4 -N16 $@; \
	   echo "  See CONTRACTS.md §18 / BUG #21."; \
	   echo "====================================================================="; \
	   exit 1; \
	 fi; \
	 echo "BOOT INTEGRITY: OK  _start=0x$$start  ($@)"

$(DUMP_FILE): $(ELF_FILE)
	$(OBJDUMP) -Sxdstr $< >$@

# WARNING RATCHET (ci/warn_ratchet.py) wired at build time - CONTRACTS.md
# #warn-ratchet-build-time-wiring. See common/warn_check.sh's header for the
# full soundness rationale: forces its own from-scratch build in a scratch
# directory (never the developer's own $(BUILD_DIR)) so the captured log
# can never be an incomplete/incremental one, and proves that happened
# (object-count check) rather than trusting it.
#
# The recursive $(MAKE) targets the scratch ELF path directly (never `all`/
# `warn_check`) to avoid a `warn_check -> rebuild -> all -> warn_check ->
# ...` infinite recursion, since `all` above lists `warn_check` as its own
# prerequisite. BUILD_DIR/OUTPUT_DIR are overridden to two DISTINCT scratch
# subdirectories (obj/ vs out/) - overriding both to the same path collides
# this Makefile's own directory-creation rules ("overriding recipe for
# target", a real warning the ratchet then correctly fails on). This port
# has no vendored pre-built object (unlike ch570's vendor/ISP572.o), so
# $(words $(OBJECTS)) (every compiled source) is exactly the right count.
WARN_SCRATCH     = $(OUTPUT_DIR)/.warncheck/$(PLATFORM_NAME)/$(BOARD)/$(BUILD)
WARN_SCRATCH_OBJ = $(WARN_SCRATCH)/obj
WARN_SCRATCH_OUT = $(WARN_SCRATCH)/out
WARN_LOG         = $(WARN_SCRATCH)/build.log
WARN_BASELINE    = ../../../ci/warn_baseline_$(PLATFORM_NAME).txt
WARN_RATCHET     = ../../../ci/warn_ratchet.py
WARN_CHECK       = ../common/warn_check.sh

warn_check:
	@mkdir -p $(WARN_SCRATCH_OBJ) $(WARN_SCRATCH_OUT)
	@sh $(WARN_CHECK) $(WARN_SCRATCH_OBJ) $(words $(OBJECTS)) $(WARN_LOG) \
	    $(WARN_BASELINE) $(WARN_RATCHET) -- \
	    $(MAKE) --no-print-directory BUILD=$(BUILD) BOARD=$(BOARD) FP=$(FP) \
	      SHM_COHERENCY=$(SHM_COHERENCY) PLIC_CONTEXT=$(PLIC_CONTEXT) \
	      BUILD_DIR=$(WARN_SCRATCH_OBJ) OUTPUT_DIR=$(WARN_SCRATCH_OUT) \
	      $(WARN_SCRATCH_OUT)/$(BINARY_NAME).elf

debug: $(ELF_FILE)
	$(GDB) $<

compdb:
	$(GRBL_DIR)/../tools/gen_compile_commands.py $(PLATFORM_NAME) --board $(BOARD) --build $(BUILD)

clean:
	rm -f $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.elf \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.hex \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.bin \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.dump \
	      $(OUTPUT_DIR)/grbl_$(PLATFORM_NAME)*.map
	rm -rf $(BUILD_DIR)
	rm -rf $(OUTPUT_DIR)/.warncheck/$(PLATFORM_NAME)

clean-all:
	rm -rf $(OUTPUT_DIR)

help:
	@echo "GRBL $(PLATFORM_NAME) Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make                        - Full build: ELF + hex + bin (DEBUG, default)"
	@echo "  make BUILD=RELEASE          - Full build, optimized"
	@echo "  make link                   - Link only (must show zero PORT_TODO_*)"
	@echo "  make FP=SINGLE              - AVR-faithful double==float semantics (default)"
	@echo "  make FP=DOUBLE              - declared-double deviation, no-DP assert disarmed"
	@echo "  make SHM_COHERENCY=CMO      - explicit cross-core cache maintenance (default)"
	@echo "  make SHM_COHERENCY=NONCACHEABLE - declared non-cacheable shared window"
	@echo "  make PLIC_CONTEXT=n         - PLIC context for this core's M-mode view"
	@echo "  make compdb                 - Generate compile_commands.json for clangd/LSP"
	@echo "  make clean                  - Clean current build"
	@echo "  make clean-all              - Clean all builds"
	@echo ""
	@echo "Build configuration:"
	@echo "  Platform      = $(PLATFORM_NAME)  (C906L runtime core)"
	@echo "  Board         = $(BOARD)"
	@echo "  Arch          = $(ARCH) / $(ABI)"
	@echo "  Timer clock   = $(CLOCK) Hz  (F_CPU - NOT the CPU frequency)"
	@echo "  PLIC context  = $(PLIC_CONTEXT)"
	@echo "  SHM coherency = $(SHM_COHERENCY)"
	@echo "  Current BUILD = $(BUILD)"
	@echo "  Output dir    = $(BUILD_DIR)"

.PHONY: all objects link clean clean-all debug help compdb warn_check

-include $(BUILD_DIR)/*.d
