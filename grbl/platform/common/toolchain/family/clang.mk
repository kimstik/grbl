#  family/clang.mk - clang dialect layer for the toolchain axis (TC=gcc|clang)
#  Part of Grbl
#
#  See grbl/platform/docs/TOOLCHAIN-AXIS.md for the recon this file
#  encodes, and its 2026-07-26 correction: clang DOES have a working
#  equivalent to gcc's -fsingle-precision-constant (-cl-single-precision-
#  constant, undocumented for plain C but unconditionally forwarded to
#  -cc1 - verified end-to-end against a real port build in that doc, not
#  just an isolated test file). This is a VERIFICATION-only family: no
#  profile using this file may ever own artifacts/ or a project ratchet's
#  canonical build (docs/TOOLCHAIN-AXIS.md §NEW "artifacts stays keyed to
#  one canonical toolchain").
#
#  REACHABLE (2026-07-27): every gcc-family port now has `TC ?=
#  <canonical>` + `include .../profiles/$(TC).mk` wiring (see
#  family/gcc.mk's header), so `make TC=arm-clang-18` (or
#  TC=riscv-clang-18) on those ports DOES route CC/NM/OBJCOPY/OBJDUMP/
#  SIZE and the OPT/LTO/FP_SINGLE flags through this file for real now -
#  the include mechanism itself is no longer out-of-tree-only. What
#  remains unverified through the Makefile path specifically (as opposed
#  to the axis doc's manual out-of-tree build, which DID prove it end-to-
#  end for stm32f411): the -specs=nano.specs/-specs=nosys.specs library
#  selection every gcc-family common.mk/Makefile still hardcodes is a
#  gcc-specific spec file clang cannot parse, so a real `make
#  TC=arm-clang-18 BUILD=RELEASE` will still fail at link time on those
#  ports until something threads clang's -L/-lc_nano/-lnosys equivalent
#  through per TC_FAMILY - out of scope for the byte-identity gate this
#  session was held to (verification-only profiles never owned
#  artifacts/, and no canonical default was touched).

ifndef TC_VER
$(error TC_VER must be set by the including profile before family/clang.mk (e.g. 18.1))
endif
ifndef CLANG_TARGET
$(error CLANG_TARGET must be set by the including profile before family/clang.mk (e.g. arm-none-eabi, riscv32-unknown-elf, riscv64-unknown-elf))
endif

TC_FAMILY := clang

# --- tool names --------------------------------------------------------
# clang's own tools, not the gcc-prefixed ones - llvm-nm/llvm-objcopy/
# llvm-objdump/llvm-size read gcc-built ELFs fine too (confirmed in the
# recon session) but the reverse direction (GNU tools on a clang/lld ELF)
# was not tested and is not relied on here; always pair clang's own image
# with llvm's own tools.
TC_CC      := clang --target=$(CLANG_TARGET)
TC_NM      := llvm-nm
TC_OBJCOPY := llvm-objcopy
TC_OBJDUMP := llvm-objdump
TC_SIZE    := llvm-size
TC_AR      := llvm-ar
TC_LD      := ld.lld

# clang needs an explicit sysroot for the target's headers - it does not
# autodetect an arm-none-eabi-gcc/riscv64-unknown-elf-gcc install's layout.
# A profile sets TC_SYSROOT to the right one for its target; empty is legal
# for host-native targets (not used by any port in this tree today).
TC_SYSROOT ?=
ifneq ($(TC_SYSROOT),)
  TC_CC += --sysroot=$(TC_SYSROOT)
endif

# --- size-optimization spelling -----------------------------------------
# -Os is the gcc-parity choice (byte-comparable size class). clang's -Oz
# (smaller-but-slower) is a real, documented alternative worth trying if
# this axis ever needs to shrink further, but it is NOT the default here -
# changing the size class is an explicit, separate decision from landing
# the axis, not a hidden side effect of turning TC=clang on.
TC_OPT_FLAG := -Os

# --- LTO spelling --------------------------------------------------------
# clang's LTO is ThinLTO by default terminology; -flto=thin is the
# explicit, unambiguous spelling (plain -flto also works on clang but
# means "full LTO", a different, slower, more memory-hungry mode - thin is
# the one this project's recon actually measured).
TC_LTO_CFLAGS  := -flto=thin
TC_LTO_LDFLAGS := -flto=thin -fuse-ld=lld

# --- FP=SINGLE spelling (CONTRACTS.md #17) --------------------------------
# THE flag this axis was killed over and un-killed for (docs/
# TOOLCHAIN-AXIS.md, 2026-07-26 correction). Undocumented for plain C
# (clang --help calls it OpenCL-only) but verified: `clang
# -cl-single-precision-constant -### -c x.c` shows it forwarded to -cc1
# unconditionally, no -x cl/-x c gating; IR dumps show literal typing
# changes from `double` to `float`; a real ARM cross-build's llvm-nm
# output goes from 6+ __aeabi_d*/__aeabi_f2d symbols to zero, byte-
# identical in symbol-set shape to real arm-none-eabi-gcc
# -fsingle-precision-constant on the same test file. Re-verified this
# session across every real target this tree ships (ARM Cortex-M0+/M3/M4/
# M33, RISC-V rv32ec_zicsr/rv32imc_zicsr/rv64imac_zicsr) - the DP-elimination
# effect is uniform, not ARM-specific.
TC_FP_SINGLE_CFLAGS := -cl-single-precision-constant

# --- version gating --------------------------------------------------------
# Only one clang version has been measured against this tree (18.1.3,
# Ubuntu package) - no cross-version gating ladder exists yet because
# there is only one data point. Add one here (mirroring family/gcc.mk's
# TC_VER_GE_* pattern) the day a second clang version is measured and
# found to differ; until then TC_VER is accepted but only used for
# labeling (profile name, warn-baseline filename), not for flag gating.

# -Wunused-command-line-argument is deliberately NOT added by default:
# TC_FP_SINGLE_CFLAGS above is accepted silently on every target measured
# this session (confirmed: `-Wall -Wunused-command-line-argument` still
# produced zero diagnostic for -cl-single-precision-constant on the ARM
# cross-build). If a future target rejects it, that becomes a per-profile
# TOOLCHAINS_SUPPORTED exclusion (docs/TOOLCHAIN-AXIS.md §9 rule 3), not a
# reason to silently swallow the warning here.
