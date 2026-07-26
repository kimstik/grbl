#  family/gcc.mk - GCC dialect layer for the toolchain axis (TC=gcc|clang)
#  Part of Grbl
#
#  See grbl/platform/docs/TOOLCHAIN-AXIS.md and docs/TOOLCHAIN-VERSIONS.md
#  for the design and the measurements this file encodes.
#
#  A profile (common/toolchain/profiles/<name>.mk) sets TC_PREFIX and
#  TC_VER, then does `include ../family/gcc.mk`. This file turns those two
#  facts into the actual tool names and flags a port's common.mk/Makefile
#  consumes: TC_CC, TC_NM, TC_OBJCOPY, TC_OBJDUMP, TC_SIZE, TC_OPT_FLAG,
#  TC_LTO_CFLAGS, TC_LTO_LDFLAGS, TC_FP_SINGLE_CFLAGS.
#
#  NOT wired into any port Makefile yet (2026-07-26) - see the toolchain-
#  axis doc's landing note for why (a concurrent session was auditing
#  ratchet invocation across every port Makefile at the same time this
#  landed; wiring this in was deferred one session rather than risk a
#  collision on the exact lines that invoke assert_no_double.sh/
#  init_check.sh/boot_check.sh). This file is complete and has been
#  proven correct against a real end-to-end build (see the axis doc) -
#  it is ready to be included the moment a port/common.mk opts in.

ifndef TC_PREFIX
$(error TC_PREFIX must be set by the including profile before family/gcc.mk)
endif
ifndef TC_VER
$(error TC_VER must be set by the including profile before family/gcc.mk (e.g. 13.2, 7.3, 16))
endif

TC_FAMILY := gcc

# --- tool names --------------------------------------------------------
TC_CC      := $(TC_PREFIX)gcc
TC_NM      := $(TC_PREFIX)nm
TC_OBJCOPY := $(TC_PREFIX)objcopy
TC_OBJDUMP := $(TC_PREFIX)objdump
TC_SIZE    := $(TC_PREFIX)size
TC_AR      := $(TC_PREFIX)ar

# --- size-optimization spelling -----------------------------------------
TC_OPT_FLAG := -Os

# --- LTO spelling --------------------------------------------------------
# gcc's real (non-thin) LTO. -fno-fat-lto-objects matches every port's
# existing RELEASE flag (no port ships fat LTO objects today).
TC_LTO_CFLAGS  := -flto -fno-fat-lto-objects
TC_LTO_LDFLAGS := -flto

# --- FP=SINGLE spelling (CONTRACTS.md #17) --------------------------------
# The flag every port already hardcodes today (samd21/ch32v006/ch570/
# stm32*/hc32f460 Makefiles all spell this literally). Provided here so a
# port that switches to including this file instead of hardcoding the flag
# gets the identical string - not a behavior change, a name for what
# already exists.
TC_FP_SINGLE_CFLAGS := -fsingle-precision-constant

# --- version gating (docs/TOOLCHAIN-VERSIONS.md §3/§4) --------------------
# TC_VER is load-bearing, not decorative: three analyzer-adjacent flags are
# hard errors ("unrecognized command line option", not a warning) below
# their minimum GCC version, so a profile targeting an old GCC must never
# see them in its CFLAGS. Measured directly against avr-gcc 7.3.0 (the
# canonical AVR compiler - it must never receive a flag it cannot parse):
# -fanalyzer needs >=10, -Wuse-after-free and -Wdangling-pointer need >=12.
# -Wnull-dereference/-Warray-bounds=2/-Wstringop-overflow/-Wshadow are
# already accepted on 7.3.0 (present since much older GCCs) and are NOT
# gated here.
#
# TC_VER is a plain decimal like 13.2, 7.3, 16, 16.1 - turn it into a
# comparable integer (major*100+minor, minor defaults to 0) so a numeric
# ifeq/ifneq ladder can compare it without a shell call per line.
_tc_ver_major := $(firstword $(subst ., ,$(TC_VER)))
_tc_ver_minor := $(word 2,$(subst ., ,$(TC_VER)))
ifeq ($(_tc_ver_minor),)
_tc_ver_minor := 0
endif
_tc_ver_num := $(shell expr $(_tc_ver_major) \* 100 + $(_tc_ver_minor))

TC_VER_GE_10 := $(shell [ $(_tc_ver_num) -ge 1000 ] && echo 1)
TC_VER_GE_12 := $(shell [ $(_tc_ver_num) -ge 1200 ] && echo 1)

# TC_ANALYZER_CFLAGS is empty by default (no port's real build passes
# -fanalyzer per-commit today - docs/TOOLCHAIN-VERSIONS.md §7 explicitly
# recommends AGAINST that, it's a weekly/manual audit flag only). A profile
# that wants the analyzer catalogue sets TC_WANT_ANALYZER=1 before this
# include; version gating still applies underneath that opt-in.
TC_ANALYZER_CFLAGS :=
ifeq ($(TC_WANT_ANALYZER),1)
  ifeq ($(TC_VER_GE_10),1)
    TC_ANALYZER_CFLAGS += -fanalyzer
    ifeq ($(TC_VER_GE_12),1)
      TC_ANALYZER_CFLAGS += -Wuse-after-free -Wdangling-pointer
    endif
  endif
endif
