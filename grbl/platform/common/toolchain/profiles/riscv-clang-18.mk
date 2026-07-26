#  profiles/riscv-clang-18.mk - VERIFICATION-ONLY profile, RISC-V
#  Part of Grbl
#
#  Never produces artifacts/ or feeds a ratchet's canonical build (see
#  riscv-gcc-13.2.mk, the only canonical RISC-V profile). Re-verified
#  this session (docs/TOOLCHAIN-AXIS.md, 2026-07-26 correction) across all
#  three RISC-V ISA variants this tree ships (rv32ec_zicsr/ilp32e,
#  rv32imc_zicsr/ilp32, rv64imac_zicsr/lp64): -cl-single-precision-constant
#  eliminates every __adddf3/__muldf3/__subdf3/__extendsfdf2/__gtdf2-class
#  double-precision libcall at the object-file level, matching real
#  riscv64-unknown-elf-gcc -fsingle-precision-constant symbol-for-symbol
#  on the same test input. NOT yet verified against a full port link on
#  this ISA family the way arm-clang-18.mk was (stm32f411 end-to-end) -
#  that is the next step before this profile could ever be promoted past
#  "measured at the object level."
#
#  CLANG_TARGET/TC_SYSROOT must be set per port before including this file
#  (rv32 vs rv64 are different clang targets on this ISA, unlike ARM where
#  one --target=arm-none-eabi covers M0+ through M33). Ubuntu's picolibc
#  packages provide the sysroot at
#  /usr/lib/picolibc/riscv64-unknown-elf (confirmed: has math.h; used for
#  all three ISA variants in this session's recon, since picolibc itself
#  is ISA-generic and the ISA-specific bits are only -march=/-mabi= on the
#  compile line, not baked into the sysroot path).
#
#  NOT wired into any port Makefile yet - see family/gcc.mk's header
#  comment.

TC_SYSROOT := /usr/lib/picolibc/riscv64-unknown-elf
TC_VER     := 18.1
# CLANG_TARGET left unset here - a port sets riscv32-unknown-elf or
# riscv64-unknown-elf before including this file, matching its own
# ARCH's word width (rv32* ports need riscv32-unknown-elf; sg2002's
# rv64imac_zicsr needs riscv64-unknown-elf).

include $(dir $(lastword $(MAKEFILE_LIST)))../family/clang.mk
