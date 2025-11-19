#  Makefile - Unified build system for all GRBL platforms
#  Part of Grbl
#
#  Copyright (c) 2025 kimstik
#  Intelligence assisted
#  License: MIT
#
#  This Makefile provides a unified interface to build all non-AVR platforms.
#  All build artifacts go to ../../build/ directory.
#
#  Usage:
#    make                    - Build all ready platforms (DEBUG)
#    make BUILD=RELEASE      - Build all platforms in RELEASE mode
#    make stm32f103          - Build specific platform
#    make stm32f103 BUILD=RELEASE - Build specific platform in RELEASE mode
#    make clean              - Clean all platforms
#    make help               - Show help

# List of ready platforms (platforms with working build systems)
READY_PLATFORMS = stm32f103 stm32h523 sg2002

# Default build type
BUILD ?= DEBUG

# ============================================================================
# TARGETS
# ============================================================================

# Default target: build all ready platforms
all: $(READY_PLATFORMS)

# Build individual platforms
stm32f103:
	@echo "==== Building STM32F103 (BUILD=$(BUILD)) ===="
	$(MAKE) -C stm32f103 BUILD=$(BUILD)

stm32h523:
	@echo "==== Building STM32H523 (BUILD=$(BUILD)) ===="
	$(MAKE) -C stm32h523 BUILD=$(BUILD)

sg2002:
	@echo "==== Building SG2002 (BUILD=$(BUILD)) ===="
	$(MAKE) -C sg2002 BUILD=$(BUILD)

# Clean all platforms
clean:
	@echo "Cleaning all platforms..."
	@for platform in $(READY_PLATFORMS); do \
		echo "Cleaning $$platform..."; \
		$(MAKE) -C $$platform clean; \
	done

# Clean everything including build directory
clean-all:
	@echo "Removing all build artifacts..."
	rm -rf ../../build

# Help
help:
	@echo "GRBL Platform Build System"
	@echo ""
	@echo "Ready platforms: $(READY_PLATFORMS)"
	@echo ""
	@echo "Usage:"
	@echo "  make                     - Build all platforms (DEBUG)"
	@echo "  make BUILD=RELEASE       - Build all platforms (RELEASE)"
	@echo "  make <platform>          - Build specific platform (DEBUG)"
	@echo "  make <platform> BUILD=RELEASE - Build specific platform (RELEASE)"
	@echo ""
	@echo "Available platforms:"
	@echo "  stm32f103  - STM32F103 (Blue Pill, Cortex-M3, 72MHz)"
	@echo "  stm32h523  - STM32H523 (Black Pill H5, Cortex-M33, 250MHz)"
	@echo "  sg2002     - Sophgo SG2002 (RISC-V C906)"
	@echo ""
	@echo "Other targets:"
	@echo "  make clean     - Clean all platform builds"
	@echo "  make clean-all - Remove entire build directory"
	@echo ""
	@echo "Build artifacts:"
	@echo "  All .elf, .hex, .bin, .dump files go to ../../build/"
	@echo "  Object files (.o) go to ../../build/<platform>/"
	@echo ""
	@echo "File naming convention:"
	@echo "  Release: grbl_<platform>.bin"
	@echo "  Debug:   grbl_<platform>_dbg.bin"

.PHONY: all $(READY_PLATFORMS) clean clean-all help
