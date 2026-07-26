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

# ============================================================================
# BOOT-INIT REACHABILITY RATCHET (BUG #23, CONTRACTS.md
# #boot-init-unreachable)
#
# The check itself rides each port's OWN Makefile at link time, right after
# the no-DP assert and alongside boot_check.sh - same wiring point, same
# blast radius, no CI change needed to cover a new port. What lives here is
# the aggregate entry point and the pure-logic selftest.
#
# atmega328p's leg is in grbl/platform/atmega328p/Makefile (its real link
# happens in the golden-MD5-gated root Makefile, which stays untouched, so
# the check hangs off the shim CI already invokes).
check: ## boot-init reachability ratchet, AVR reference leg (BUG #23)
	@echo "==== BOOT-INIT reachability: atmega328p (golden reference) ===="
	$(MAKE) -C atmega328p validate

# Pure-logic unit tests for the ratchet itself - no compiler invoked,
# matches tools/assert_no_double.sh --selftest / ci/warn_ratchet.py
# --selftest / tools/build_artifacts.py --selftest.
init-check-selftest:
	sh common/init_check.sh --selftest

# ============================================================================
# TRACKED BUILD ARTIFACTS (PLAN.md "build artifacts tracked in git for
# observability" batch; CONTRACTS.md #build-artifacts-tracked)
#
# Placed HERE (not a subdirectory Makefile, not the AVR root Makefile) on
# purpose: this file is already the one place that knows about every
# non-AVR platform as a unit (the $(READY_PLATFORMS)/all dispatch above),
# and the artifact tooling needs to drive ALL platforms including AVR from
# one entry point - a per-platform target would just mean ten near-
# identical copy-pasted stanzas, and the root (AVR) Makefile is golden-MD5
# gated, so it stays untouched rather than gaining unrelated targets.
# tools/build_artifacts.py is the actual orchestrator (build truth still
# lives in each platform's own Makefile - this is a thin invoker, same
# division of labor as .github/actions/build-platform).
# ============================================================================

# Ordinary refresh: bin/hex/syms only. .elf is deliberately EXCLUDED here
# ("Эльф на тегах" owner directive - ELF tracked only at release-tag time,
# see artifacts/README.md's "Tagging a release" section) - it's the
# largest artifact class and git can't delta binaries, so tracking it on
# every refresh (as this used to) roughly doubled the growth cost of
# every push that touched a port for a file most refreshes don't need.
artifacts:
	python3 ../../tools/build_artifacts.py build

# Tag-time only: same as `artifacts` but ALSO copies+hashes .elf. Follow
# with `git add -f artifacts/*/*.elf` (NOT `git add -A` - .elf is
# deliberately .gitignore'd between tags, and -A silently skips ignored
# paths; see artifacts/README.md).
artifacts-tag:
	python3 ../../tools/build_artifacts.py build --with-elf

artifacts-check:
	python3 ../../tools/build_artifacts.py check

artifacts-selftest:
	python3 ../../tools/build_artifacts.py --selftest

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
	@echo "Build artifacts (scratch, ../../build/ - not tracked in git):"
	@echo "  All .elf, .hex, .bin, .dump files go to ../../build/"
	@echo "  Object files (.o) go to ../../build/<platform>/"
	@echo ""
	@echo "File naming convention:"
	@echo "  Release: grbl_<platform>.bin"
	@echo "  Debug:   grbl_<platform>_dbg.bin"
	@echo ""
	@echo "Tracked artifacts (../../artifacts/ - committed to git, see"
	@echo "../../artifacts/README.md):"
	@echo "  make artifacts          - Rebuild every port RELEASE, commit"
	@echo "                            elf/bin/hex + symbol map + MANIFEST.sha256"
	@echo "  make artifacts-check    - Fail if committed artifacts are stale"
	@echo "                            relative to a fresh build (the 6th ratchet)"
	@echo "  make artifacts-selftest - Pure-logic unit tests, no compiler invoked"
	@echo ""
	@echo "Boot-init reachability ratchet (BUG #23):"
	@echo "  make check               - AVR reference leg (every other port"
	@echo "                             runs common/init_check.sh from its own"
	@echo "                             Makefile at link time)"
	@echo "  make init-check-selftest - Pure-logic unit tests for the ratchet"

.PHONY: all $(READY_PLATFORMS) check init-check-selftest clean clean-all help \
        artifacts artifacts-tag artifacts-check artifacts-selftest
