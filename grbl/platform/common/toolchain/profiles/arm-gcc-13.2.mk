#  profiles/arm-gcc-13.2.mk - CANONICAL profile for the ARM Cortex-M family
#  Part of Grbl
#
#  Owns artifacts/{stm32f103,stm32f411,stm32h523,hc32f460} and the
#  warn-ratchet/FP=SINGLE/boot/init checks for all four - this is the
#  toolchain every one of those ports' Makefiles already uses by default
#  (apt's arm-none-eabi-gcc, 13.2.1). No verification-only profile changes
#  this status (docs/TOOLCHAIN-VERSIONS.md §5, "canonical-toolchain rule").
#
#  WIRED (2026-07-27): samd21/Makefile, hc32f460/Makefile, and
#  common/stm32/common.mk (stm32f103/f411/h523's shared build rules) all
#  now have `TC ?= arm-gcc-13.2` + `include .../profiles/$(TC).mk` at the
#  top - this is their default TC. TOOLCHAIN_PATH keeps its existing
#  meaning (a directory prefix ahead of the resolved tool name).
#  Byte-identity verified: RELEASE .bin md5sum-identical to committed
#  artifacts/ for all 6 units this profile owns (samd21 x2 boards,
#  hc32f460, stm32f103, stm32f411, stm32h523) - see PLAN.md.

TC_PREFIX := arm-none-eabi-
TC_VER    := 13.2

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
