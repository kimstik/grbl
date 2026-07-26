#  Makefile for GRBL on CH570 (RISC-V RV32IMC, QingKe V3C)
#  Part of Grbl
#
#  PLAN.md Phase 6 rolling #4 Part B. Modeled on ch32v006/Makefile (same
#  toolchain family) with the CH570-specific deltas: full I+M (real hw
#  multiply/divide, no rv32e register-file reduction), -mabi=ilp32 (not
#  ilp32e), and the vendor flash-algorithm object linked in (nvmem.c).
#
#  TOOLCHAIN: same apt packages as ch32v006 -
#    sudo apt-get install -y gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf
#  PLAN.md CH570 recon: "-march=rv32imc_zicsr -mabi=ilp32 (exact picolibc
#  multilib exists, unlike ch32v006's rv32ec case)" - verified: `gcc
#  -march=rv32imc_zicsr -mabi=ilp32 -print-multi-directory` resolves to
#  the real `rv32im/ilp32` multilib (picolibc ships it), so no custom
#  multilib build is needed, unlike some other RISC-V targets.

.DELETE_ON_ERROR:

# ============================================================================
# Chip identification
# ============================================================================

PLATFORM_NAME  = ch570
DEVICE         = CH570
# rv32i base + M (hw mul/div) + C (compressed) + Zicsr (csr* instructions -
# same ARCHFLAGS gap ch32v006's Makefile documents: Zicsr is NOT implied by
# the base ISA letters on this binutils, must be appended explicitly).
ARCH           = rv32imc_zicsr
ABI            = ilp32
# Verified system clock in Hz - feeds F_CPU (PORTING-CHECKLIST Step 1).
# platform.c's SystemClock_Config() targets CLK_SOURCE_HSE_PLL_60MHz
# (600MHz internal PLL / 10). UNVERIFIED end-to-end on real hardware (no
# CH570 emulator exists) - hardware validation item, same posture as
# every RISC-V port in this tree so far.
CLOCK          = 60000000

BOARD         ?= generic
BOARD_DIR      = boards/$(BOARD)

# common/dummy supplies the AVR compatibility stubs every non-AVR
# platform needs - reused as-is, never copied.
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
GDB        = $(PREFIX)gdb

GRBL_DIR   = ../..
BUILD_DIR  = ../../../build/$(PLATFORM_NAME)/$(BUILD)
OUTPUT_DIR = ../../../build
PLATFORM_DIR = .

# GRBL core sources. Excludes serial.c/nvmem.c/eeprom.c: TU-replacement
# route (CONTRACTS.md #0/#7/#10), same as ch32v006/samd21.
GRBL_SOURCES = main.c motion_control.c gcode.c spindle_control.c coolant_control.c   \
               protocol.c stepper.c settings.c planner.c nuts_bolts.c limits.c jog.c \
               print.c probe.c report.c system.c

PLATFORM_SOURCES = platform.c startup.c handlers.c serial.c nvmem.c

SOURCES = $(addprefix $(GRBL_DIR)/,$(GRBL_SOURCES)) \
          $(PLATFORM_SOURCES)

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

vpath %.c $(PLATFORM_DIR)
vpath %.c $(GRBL_DIR)

ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI)
CFLAGS  = $(ARCHFLAGS)
CFLAGS += -DPLATFORM_$(DEVICE) -DF_CPU=$(CLOCK)UL
CFLAGS += -D__$(DEVICE)__
CFLAGS += -Wall -Wextra
CFLAGS += -ffunction-sections -fdata-sections

# FP PRECISION KNOB (CONTRACTS.md #17). rv32imc has no F extension either
# (M gives hw mul/div, not hw float) - identical DP-soft-float leak class
# as ch32v006's rv32ec, same fix.
FP ?= SINGLE
ifeq ($(FP),SINGLE)
  CFLAGS += -fsingle-precision-constant -DGRBL_FP_SINGLE
  ASSERT_FP = ../../../tools/assert_no_double.sh $(PREFIX)nm $(ELF_FILE)
else ifeq ($(FP),DOUBLE)
  ASSERT_FP = @echo "FP=DOUBLE: declared-double port build, no-DP assert disarmed"
else
  $(error FP must be SINGLE or DOUBLE, got "$(FP)")
endif

# picolibc supplies libc/libm/startfiles; -nostartfiles because
# startup.c supplies its own _start/Reset_Handler.
CFLAGS += -specs=picolibc.specs

CFLAGS += $(CFLAGS_EXTRA) -I$(PLATFORM_DIR) -I$(GRBL_DIR)/platform -I$(GRBL_DIR)

BUILD ?= DEBUG
ifeq ($(BUILD),RELEASE)
  CFLAGS += -Os -g0
else
  CFLAGS += -Og -g3
  CFLAGS += -DDEBUG
endif

# --gc-sections is safe from the start on this port (unlike ch32v006's
# M1-M3 era): every vector is wired to a real handler from the first
# working build in this batch, so there is no PORT_TODO_*-reachability
# window where a stray --gc-sections could hide an incomplete linker-as-
# checklist result (CONTRACTS.md §14 item 3's lifecycle rule - the flip
# only matters if there WAS a bare-stub phase; this port never had one).
LDFLAGS  = $(ARCHFLAGS) -nostartfiles -specs=picolibc.specs
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(MAP_FILE)
LDFLAGS += -T script.ld

# vendor/ISP572.o - the ONE vendored binary in this project's tree
# (Apache-2.0, openwch/ch570): a real linked flash-program/erase driver,
# not a boot-ROM call - see vendor/ISP572.h's header for the full
# investigation (disassembly + the datasheet's own "we do not document
# this register protocol" statement) for why this is vendored rather than
# reimplemented. TRACKED explicitly: .gitignore's blanket `*.o` rule has
# a `!grbl/platform/ch570/vendor/ISP572.o` exception - verify with
# `git check-ignore -v` after touching .gitignore. Linked as a plain
# extra object, not a library, since it is the one function nvmem.c needs.
VENDOR_OBJECTS = vendor/ISP572.o

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
	$(CC) $(LDFLAGS) -o $(ELF_FILE) $(OBJECTS) $(VENDOR_OBJECTS) $(LIBS)
	$(SIZE) --format=berkeley $(ELF_FILE)
	$(ASSERT_FP)

$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# BOOT INTEGRITY (BUG #21 ratchet, CONTRACTS.md §18) - RISC-V form: no
# SP-in-word0 convention (ch32v006/Makefile precedent, identical here -
# same core family, same reasoning). _start must be linked at the flash
# base or -flto (unused here, but the check stays cheap insurance) could
# in principle relocate/eliminate it.
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

-include $(BUILD_DIR)/*.d
