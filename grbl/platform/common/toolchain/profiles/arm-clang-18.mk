#  profiles/arm-clang-18.mk - VERIFICATION-ONLY profile, ARM Cortex-M
#  Part of Grbl
#
#  Never produces artifacts/ or feeds a ratchet's canonical build (see
#  arm-gcc-13.2.mk, the only canonical ARM profile - CANONICAL-TOOLCHAIN
#  RULE, docs/TOOLCHAIN-VERSIONS.md §5: exactly one profile per unit owns
#  artifacts/, every other profile is verification-only). Re-verified
#  this session (docs/TOOLCHAIN-AXIS.md, 2026-07-26 correction) end-to-end
#  across every ARM target this tree ships (Cortex-M0+/M3/M4/M33): the
#  FP=SINGLE contract holds under this profile using
#  -cl-single-precision-constant (family/clang.mk) - assert_no_double.sh
#  PASSES on a real full stm32f411 build. Ubuntu clang 18.1.3 package
#  (system /usr/bin/clang, no separate install needed unlike the
#  version-axis GCC probes).
#
#  Sysroot: reuses the SAME apt arm-none-eabi-gcc install's headers/libs
#  the canonical gcc profile uses (clang's own multilib autodetection does
#  not know this layout, so a profile using this file must still point at
#  it explicitly - see the axis doc's exact -L/-sysroot invocation).
#
#  REACHABLE (2026-07-27) but link-incomplete through the Makefile path:
#  samd21/hc32f460/common/stm32/common.mk's `TC ?= arm-gcc-13.2` + `include
#  .../profiles/$(TC).mk` wiring means `make TC=arm-clang-18 BUILD=RELEASE`
#  now really selects this profile (CC/NM/OBJCOPY/OBJDUMP/SIZE and the
#  OPT/LTO/FP_SINGLE flags all come from this file), but every one of
#  those Makefiles still hardcodes `-specs=nano.specs -specs=nosys.specs`
#  (gcc-only spec files clang cannot parse), so a real link will fail
#  until that gets a per-TC_FAMILY answer - out of scope for the
#  byte-identity gate this session was held to. Proven correct
#  out-of-tree instead (axis doc has the full command transcript, working
#  around exactly this gap by hand with explicit -L/-lc_nano/-lnosys).

CLANG_TARGET := arm-none-eabi
TC_SYSROOT   := /usr/lib/arm-none-eabi
TC_VER       := 18.1

include $(dir $(lastword $(MAKEFILE_LIST)))../family/clang.mk
