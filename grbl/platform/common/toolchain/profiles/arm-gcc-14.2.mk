#  profiles/arm-gcc-14.2.mk - VERIFICATION-ONLY profile, ARM Cortex-M
#  Part of Grbl
#
#  Never produces artifacts/ (see arm-gcc-13.2.mk, the only canonical ARM
#  profile). Measured this session (docs/TOOLCHAIN-VERSIONS.md): official
#  Arm GNU Toolchain 14.2.rel1, stm32f411 text 25752 vs canonical's 26228
#  (delta expected, different compiler - not gated, ARM has no golden-MD5
#  lock, only AVR does). Zero NEW frozen-core findings vs the 13.2
#  baseline (one already-known false positive, settings.c:208, reproduces
#  identically - see the doc). Set TOOLCHAIN_PATH=/opt/arm-gnu-14.2 before
#  using this profile.

TC_PREFIX := arm-none-eabi-
TC_VER    := 14.2

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
