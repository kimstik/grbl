#  profiles/riscv-gcc-13.2.mk - CANONICAL profile for the RISC-V family
#  Part of Grbl
#
#  Owns artifacts/{ch32v006,ch570,sg2002} and their ratchets - the
#  toolchain every one of those ports' Makefiles already uses by default
#  (apt's gcc-riscv64-unknown-elf, 13.2.0, with picolibc). Per-port
#  -march=/-mabi= (rv32ec_zicsr/ilp32e, rv32imc_zicsr/ilp32,
#  rv64imac_zicsr/lp64) stay a Layer-3 (target) concern in each port's own
#  Makefile, unaffected by this file - one toolchain profile serves all
#  three ISA variants the same way arm-gcc-13.2.mk serves four ARM ports
#  with differing -mcpu/-mfpu.
#
#  WIRED (2026-07-27): ch32v006/Makefile, ch570/Makefile, and
#  sg2002/Makefile all now have `TC ?= riscv-gcc-13.2` + `include
#  .../profiles/$(TC).mk` at the top - this is their default TC.
#  TOOLCHAIN_PATH keeps its existing meaning (a directory prefix ahead of
#  the resolved tool name). Byte-identity verified: RELEASE .bin
#  md5sum-identical to committed artifacts/ for all 3 units this profile
#  owns - see PLAN.md.

TC_PREFIX := riscv64-unknown-elf-
TC_VER    := 13.2

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
