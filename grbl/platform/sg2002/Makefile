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
#  ARCH/ABI: rv64imac_zicsr / lp64 - AND WHY IT IS NOT rv64gc
#  ===========================================================================
#  The C906 family nominally implements rv64gc, so rv64gc/lp64d looks like
#  the obvious choice. It is not buildable here, and it is not clearly
#  correct either:
#
#   1. NO MULTILIB. `riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d
#      -print-multi-directory` answers `rv64imafdc/lp64d`, and
#      picolibc-riscv64-unknown-elf ships no such directory - its rv64 set
#      stops at `rv64imafc/lp64f` (verified against the installed tree, not
#      assumed from documentation). A double-ABI build has no libc to link.
#   2. THE "L" IN C906L IS UNDOCUMENTED. The cut-down runtime core is
#      community-described as a C906 minus the MMU and minus some
#      extensions; nothing states whether F/D survive. `rv64imafc/lp64f` DOES
#      have a multilib and would suit this project's FP=SINGLE posture
#      perfectly - but an lp64f binary traps on its first FLW if F is absent.
#      rv64imac is a strict subset of every C906 variant and runs regardless.
#
#  Reversible in two lines if F is ever confirmed: set ARCH/ABI to
#  rv64imafc_zicsr / lp64f. The FP knob and the post-link no-double assert
#  cover that case unchanged.
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
ARCH           = rv64imac_zicsr
ABI            = lp64

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
# FP PRECISION KNOB (CONTRACTS.md #17). rv64imac has no F extension - the
# identical DP-soft-float leak class as ch32v006's rv32ec and ch570's rv32imc,
# same fix, same post-link proof.
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
# silently dropped. This port has no -flto today (see LDFLAGS below), so the
# check is currently "cheap insurance" rather than catching a live LTO
# deletion - same posture ch570/_template document for the same reason - but
# it still catches symbol-renamed/dropped regressions and stands ready the
# day this port's RELEASE flavor turns LTO on.
INIT_SYMBOLS ?= Reset_Handler,SystemClock_Config,sg2002_plic_init
INIT_CHECK = ../common/init_check.sh

CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
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

all: $(BUILD_DIR) $(OUTPUT_DIR) $(HEX_FILE) $(BIN_FILE)

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

.PHONY: all objects link clean clean-all debug help compdb

-include $(BUILD_DIR)/*.d
