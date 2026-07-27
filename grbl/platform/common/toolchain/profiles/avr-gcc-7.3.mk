#  profiles/avr-gcc-7.3.mk - CANONICAL profile for atmega328p
#  Part of Grbl
#
#  Owns artifacts/atmega328p and the golden-MD5 ratchet. This is the ONLY
#  legal canonical profile for atmega328p - byte-identity to avr-gcc
#  7.3.0's exact codegen IS the spec (root Makefile's `validate` target),
#  not a preference among interchangeable compilers. No verification-only
#  profile changes this file's status; see avr-gcc-15.mk/avr-gcc-16.mk for
#  the verification side of this unit (docs/TOOLCHAIN-VERSIONS.md).
#
#  NOT wired into the root Makefile (2026-07-27, unchanged from landing):
#  atmega328p's real link stays in the golden-MD5-gated root Makefile,
#  which must remain byte-untouched - there is no TC wiring point there
#  and none was added (see family/gcc.mk's header for the full
#  explanation, and grbl/platform/atmega328p/Makefile's shim, which never
#  itself invokes a compiler). The root Makefile's existing AVR_GCC_PATH
#  variable already parameterizes the compiler path with zero code
#  change needed to point at a specific install (proven this session and
#  in docs/TOOLCHAIN-VERSIONS.md §4). Every OTHER canonical gcc profile
#  (arm-gcc-13.2.mk, riscv-gcc-13.2.mk) IS wired into its ports' real
#  Makefiles as of 2026-07-27 - this file is the one deliberate exception.

TC_PREFIX := avr-
TC_VER    := 7.3

include $(dir $(lastword $(MAKEFILE_LIST)))../family/gcc.mk
