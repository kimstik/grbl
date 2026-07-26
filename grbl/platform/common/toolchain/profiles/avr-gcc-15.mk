#  profiles/avr-gcc-15.mk - VERIFICATION-ONLY profile, AVR
#  Part of Grbl
#
#  Never produces artifacts/ or feeds a ratchet's canonical build (see
#  avr-gcc-7.3.mk, the only canonical AVR profile). Measured this session
#  (docs/TOOLCHAIN-VERSIONS.md): avr-gcc 15.2.0
#  (github.com/ZakKemble/avr-gcc-build v15.2.0-1), text 30994 vs
#  canonical's 30640 (+354, expected: different compiler, not a
#  regression). One real analyzer false positive found at this version
#  (settings.c:208, CWE-787, absent under 16.1) - not a code defect, see
#  the doc's §2 catalogue. Set TOOLCHAIN_PATH=/opt/avr-gcc-15 (or
#  wherever this install lives) before using this profile - it is not
#  auto-discovered.

TC_PREFIX := avr-
TC_VER    := 15.2

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
