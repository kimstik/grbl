#  profiles/avr-gcc-16.mk - VERIFICATION-ONLY profile, AVR (weekly analyzer job)
#  Part of Grbl
#
#  Never produces artifacts/ or feeds a ratchet's canonical build (see
#  avr-gcc-7.3.mk, the only canonical AVR profile). Measured this session
#  (docs/TOOLCHAIN-VERSIONS.md): avr-gcc 16.1.0
#  (github.com/ZakKemble/avr-gcc-build v16.1.0-1), text 30480 vs
#  canonical's 30640 (-160, expected). Zero -fanalyzer findings on frozen
#  core at this version (the settings.c:208 false positive present at
#  15.2 does not reproduce here). This is the recommended profile for the
#  weekly analyzer job (docs/TOOLCHAIN-VERSIONS.md §7) - NOT avr-gcc-15,
#  which the same doc found to be a strict analyzer-precision subset of
#  this version for this codebase (running both doubles CI cost for zero
#  extra finding coverage). Set TOOLCHAIN_PATH=/opt/avr-gcc-16 before
#  using this profile.

TC_PREFIX := avr-
TC_VER    := 16

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
