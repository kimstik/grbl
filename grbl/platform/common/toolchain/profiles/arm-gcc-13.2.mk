#  profiles/arm-gcc-13.2.mk - CANONICAL profile for the ARM Cortex-M family
#  Part of Grbl
#
#  Owns artifacts/{stm32f103,stm32f411,stm32h523,hc32f460} and the
#  warn-ratchet/FP=SINGLE/boot/init checks for all four - this is the
#  toolchain every one of those ports' Makefiles already uses by default
#  (apt's arm-none-eabi-gcc, 13.2.1). No verification-only profile changes
#  this status (docs/TOOLCHAIN-VERSIONS.md §5, "canonical-toolchain rule").
#
#  NOT wired into any port Makefile yet - see family/gcc.mk's header
#  comment (deferred to avoid a collision with a concurrent
#  ratchet-invocation audit touching the same Makefiles this session).
#  common/stm32/common.mk's existing TOOLCHAIN_PATH variable already
#  parameterizes the compiler path with zero code change needed.

TC_PREFIX := arm-none-eabi-
TC_VER    := 13.2

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
