#!/usr/bin/env python3

# integrity checker - TIERED, not a single golden value.
#
# Every entry in known_hashes carries a 'tier':
#   'canonical'      - THE byte-exact reference this project's `make validate`
#                       gates on. Exactly one hex + one bin entry carry this
#                       tier (the gcc 7.3.0, no-LTO "working horse" build).
#                       Matching it is the only thing that makes the golden
#                       gate PASS.
#   'known'          - recognised and reproducible (a documented toolchain/
#                       flag combination reliably produces this hash), but
#                       NOT the canonical reference. Includes the upstream
#                       gnea/grbl v1.1h release images (a different project's
#                       artifact, kept for comparison), the vanilla-master
#                       (pre-HAL) build, and every other-toolchain build this
#                       project has verified it can reproduce on demand.
#   'unreproducible' - recorded historically, but this session could not
#                       reproduce it after a real attempt (see the entry's
#                       own comment for what was tried, and CONTRACTS.md
#                       §chk-py-tiers for the full writeup). Kept, not
#                       deleted, so the gap stays visible instead of quietly
#                       looking verified.
#
# See grbl/platform/CONTRACTS.md §chk-py-tiers ("What the tiers mean, and
# which one gates") for the full rationale, and the root Makefile's
# `validate` target for the only consumer that passes --require-canonical.
import argparse, sys
from hashlib import md5
#from blake3  import blake3	#keep it for the future

RED    ='\033[0;31m'
GREEN  ='\033[0;32m'
YELLOW ='\033[1;33m'
NC     ='\033[0m' # No Color

known_hashes = {
	# ==== Official gnea/grbl v1.1h release (a DIFFERENT project's artifact -
	# recognised for comparison, never a candidate for this HAL's canonical
	# tier) ====
	# source code https://github.com/gnea/grbl/archive/refs/tags/v1.1h.20190825.tar.gz
	# image       https://github.com/gnea/grbl/releases/download/v1.1h.20190825/grbl_v1.1h.20190825.hex
	'aec218a09666a4c3d79eafa5cc46f5a0': {'tier': 'known',
		'desc': '(MD5) gnea/grbl v1.1h release image: 84163 bytes of grbl_v1.1h.20190825.hex'},	# coreutils hashsum --md5   grbl_v1.1h.20190825.hex
	'681daa3a293b01f17107aea47c3f04e9': {'tier': 'known',
		'desc': '(MD5) gnea/grbl v1.1h release image: 29920 bytes of grbl_v1.1h.20190825.bin'},

	'8543dbc6ef76605486482cb0ec9ace316f19191dea357cb883287804394dc5a5': {'tier': 'known',
		'desc': '(BLAKE3) gnea/grbl v1.1h release image: 84163 bytes of grbl_v1.1h.20190825.hex'},	# coreutils hashsum --b3sum grbl_v1.1h.20190825.hex
	'c2169d2400ebc5c55eb9e1543bfafbe8aab0e76a2edc044315981958485f7a17': {'tier': 'known',
		'desc': '(BLAKE3) gnea/grbl v1.1h release image: 29920 bytes of grbl_v1.1h.20190825.bin'},

	# ==== kimstik/grbl master branch (vanilla, pre-HAL source tree) ====
	# Built from: https://github.com/kimstik/grbl commit eefe2bb (master)
	# Compiler: avr-gcc (GCC) 7.3.0 (Arduino toolchain)
	# Flags: -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p -ffunction-sections -flto -Wl,--gc-sections
	# Build date: 2025-11-21
	# Archive: build/vanilla-grbl-gcc-7.3.0.tar.gz (60KB)
	'9cb869c15075d1adc9d37d1bcf614d06': {'tier': 'known',
		'desc': 'grbl.hex (vanilla master, gcc 7.3.0+LTO) 83656 bytes'},
	'ce0b90457da3d01159ce435dd4f5336e': {'tier': 'known',
		'desc': 'grbl.bin (vanilla master, gcc 7.3.0+LTO) 29738 bytes'},
	'87a85a47993a1381737cbbf83059bacc': {'tier': 'known',
		'desc': 'main.elf (vanilla master, gcc 7.3.0+LTO) 46388 bytes'},

	# ==== Historical / other builds ====

	# UNREPRODUCIBLE (marked 2026-07-27, not deleted - see CONTRACTS.md
	# §chk-py-tiers for the full record). Original entry carried no byte
	# count or exact flags, unlike every other row in this table - that gap
	# is itself evidence it was never captured with full provenance.
	# Reproduction attempted this session with avr-gcc 15.2.0 (ZakKemble
	# avr-gcc-build v15.2.0-1, /opt/avr-gcc-15) and 16.1.0 (/opt/avr-gcc-16)
	# across 8 combinations - two source trees (this repo's HAL `grbl/`
	# tree, and the pre-HAL vanilla `kimstik/grbl` commit eefe2bb tree) x
	# {-flto on, -flto off} x {avr-gcc 15.2.0, avr-gcc 16.1.0} - none
	# produced this hash:
	#   HAL,     no LTO, gcc15.2: 72b8300e1ace62cd751c56a7422fd430 (87195B)
	#   HAL,     +LTO,   gcc15.2: 7bf89a9875ca525727a595ecf74b5c90 (84585B)
	#   HAL,     no LTO, gcc16.1: e7c81dd66c8d5c36bc7c48ec97ee991c (85738B)
	#   HAL,     +LTO,   gcc16.1: ca8024b594c41f76a205f78ded47f399 (84020B)
	#   vanilla, no LTO, gcc15.2: 9e599d69e2a6ca0bfd05bb301fc0d9df (87195B)
	#   vanilla, +LTO,   gcc15.2: df5ec23ba1db48a8f1c739d41ffa4d05 (84585B)
	#   vanilla, no LTO, gcc16.1: 7132c77eed165cc838860a9dbafa1740 (85738B)
	#   vanilla, +LTO,   gcc16.1: ca8024b594c41f76a205f78ded47f399 (84020B)
	# Most likely explanation: the original build used a DIFFERENT avr-gcc
	# 15.2 distribution/patch level (e.g. a distro or Arduino-patched build)
	# than the ZakKemble upstream build available on this machine, and/or an
	# undocumented flag set. Left in the table, tier'd so it can never
	# print the same as a canonical or known match.
	'7f14441d024bb6af43b547e435e598b8': {'tier': 'unreproducible',
		'desc': 'grbl.hex - gcc 15.2 - UNREPRODUCIBLE (2026-07-27, see comment above this entry)'},

	# ==== avr-gcc 15.2.0 (ZakKemble/avr-gcc-build release v15.2.0-1,
	# /opt/avr-gcc-15 on this machine), THIS repo's HAL source, root
	# Makefile's own flags (-Os, no LTO) - reproduce with:
	#   make AVR_GCC_PATH=/opt/avr-gcc-15/bin grbl.hex
	# binutils 2.45, avr-libc 2.2.1 (per /opt/avr-gcc-15/README.txt).
	# Measured 2026-07-27. ====
	'72b8300e1ace62cd751c56a7422fd430': {'tier': 'known',
		'desc': 'grbl.hex - 87195 - gcc 15.2.0 (/opt/avr-gcc-15, ZakKemble v15.2.0-1) no LTO'},
	'a9660b62076a5059b4c9203d2eaa5953': {'tier': 'known',
		'desc': 'grbl.bin - 30994 - gcc 15.2.0 (/opt/avr-gcc-15, ZakKemble v15.2.0-1) no LTO'},

	# ==== avr-gcc 16.1.0 (ZakKemble/avr-gcc-build release v16.1.0-1,
	# /opt/avr-gcc-16), same source/flags as above - reproduce with:
	#   make AVR_GCC_PATH=/opt/avr-gcc-16/bin grbl.hex
	# binutils 2.46.1, avr-libc 2.3.2. Measured 2026-07-27. ====
	'e7c81dd66c8d5c36bc7c48ec97ee991c': {'tier': 'known',
		'desc': 'grbl.hex - 85738 - gcc 16.1.0 (/opt/avr-gcc-16, ZakKemble v16.1.0-1) no LTO'},
	'97fe13f55e7ab09db934e92e837134ea': {'tier': 'known',
		'desc': 'grbl.bin - 30480 - gcc 16.1.0 (/opt/avr-gcc-16, ZakKemble v16.1.0-1) no LTO'},

	# ==== avr-gcc 9.2.0 (modm-io/avr-gcc release v9.2.0, asset
	# avr-gcc.tar.bz2 - github.com/modm-io/avr-gcc/releases/download/v9.2.0/
	# avr-gcc.tar.bz2; NOT committed anywhere in this repo, downloaded to a
	# scratch dir only), THIS repo's HAL source, same -Os/no-LTO flags.
	# Reproduce (the tarball ships avr-gcc and avr-binutils as separate
	# trees that must be pointed at each other):
	#   mkdir -p /tmp/avr9 && cd /tmp/avr9 && \
	#     curl -L -o avr-gcc.tar.bz2 \
	#       https://github.com/modm-io/avr-gcc/releases/download/v9.2.0/avr-gcc.tar.bz2 && \
	#     tar xjf avr-gcc.tar.bz2 && \
	#     mkdir -p mergedbin && \
	#     ln -s $PWD/avr-gcc/bin/* $PWD/avr-gcc/avr-binutils/bin/* mergedbin/ && \
	#     COMPILER_PATH=$PWD/avr-gcc/avr-binutils/avr/bin \
	#       make -C <repo root> AVR_GCC_PATH=$PWD/mergedbin grbl.hex
	# (COMPILER_PATH is required: this tarball's avr-gcc looks for a plain
	# "as"/"ld" it does not ship in its own bin/, and its bundled avr/
	# under avr-gcc/ is avr-libc only, not binutils - avr-binutils/avr/bin
	# is where the plain-named assembler/linker actually live.)
	# text=36132 vs the canonical 30640 (+17.9%) - builds and links clean,
	# no errors, confirming the owner's "built fine on gcc 9" claim in the
	# sense of "compiles and links", but is NOT byte- or size-comparable to
	# the golden reference: a real, measured avr-gcc 8/9/10-era AVR code-
	# density regression (community-documented; 15.2.0/16.1.0 above do NOT
	# show it - they stay within ~1.2% of the gcc 7.3.0 baseline). Measured
	# 2026-07-27, confirmed reproducible across two independent clean
	# rebuilds (same hash both times).
	'bfc564e2f69ef9cfd3ddfb09f5bf9cb5': {'tier': 'known',
		'desc': 'grbl.hex - 101644 - gcc 9.2.0 (modm-io/avr-gcc v9.2.0) no LTO - +17.9% .text vs canonical, see comment above'},
	'157cea9c6acc3f62d74202fc4660cbef': {'tier': 'known',
		'desc': 'grbl.bin - 36132 - gcc 9.2.0 (modm-io/avr-gcc v9.2.0) no LTO - +17.9% .text vs canonical, see comment above'},

	# ==== THE canonical tier: gcc 7.3.0, no LTO ("working horse"). This is
	# the ONLY tier `make validate --require-canonical` (root Makefile's
	# `validate` target) accepts. Toolchain: apt gcc-avr
	# (1:7.3.0+Atmel3.7.0-1) / equivalent avr-gcc 7.3.0 on $PATH. Flags: see
	# root Makefile's COMPILE variable (-Wall -Os -DF_CPU=16000000
	# -mmcu=atmega328p -ffunction-sections, no -flto). ====
	'6134ac924a80e22a31ffb83643b5add1': {'tier': 'canonical',
		'desc': 'grbl.bin - 30640 - gcc 7.3.0 no LTO'},
	'79af184e67b27defd27a39309ac53563': {'tier': 'canonical',
		'desc': 'grbl.hex - 86188 - gcc 7.3.0 no LTO'},	# << working horse / golden gate
}


def check(path, require_canonical):
	with open(path, "rb") as f:
		v = f.read()
	h = md5(v).hexdigest()	# blake3(v) too, once the import above is uncommented
	entry = known_hashes.get(h)

	if entry is None:
		print(f'{RED}FAIL{NC}\tunrecognised hash ({h})')
		return 1

	tier, desc = entry['tier'], entry['desc']

	if tier == 'canonical':
		print(f'{GREEN}OK (canonical){NC}\t{desc}')
		return 0

	# 'known' or 'unreproducible': recognised, but NOT the golden
	# reference. Printed distinctly (YELLOW, different label) so this can
	# never look like a canonical PASS. --require-canonical (the gate's own
	# flag) fails the build in this case; a plain lookup does not.
	label = 'recognised (unreproducible entry matched anyway)' if tier == 'unreproducible' \
		else 'RECOGNISED (non-canonical)'
	print(f'{YELLOW}{label}{NC}\t{desc}')
	return 2 if require_canonical else 0


if __name__ == "__main__":
	ap = argparse.ArgumentParser(description="grbl HAL build-integrity checker (tiered known-hash table)")
	ap.add_argument("file", help="image file to hash (e.g. grbl.hex)")
	ap.add_argument("--require-canonical", action="store_true",
		help="exit non-zero unless the match is the canonical tier "
		     "(this is what `make validate` passes - the golden gate)")
	args = ap.parse_args()
	sys.exit(check(args.file, args.require_canonical))
