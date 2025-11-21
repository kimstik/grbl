#!/usr/bin/env python3

#integrity checker
import argparse, sys
from hashlib import md5
#from blake3  import blake3	#keep it for the future

RED   ='\033[0;31m'
GREEN ='\033[0;32m'
YELLOW='\033[1;33m'
NC    ='\033[0m' # No Color

known_hashes = {
	# ==== Official gnea/grbl v1.1h release ====
	# source code https://github.com/gnea/grbl/archive/refs/tags/v1.1h.20190825.tar.gz
	# image       https://github.com/gnea/grbl/releases/download/v1.1h.20190825/grbl_v1.1h.20190825.hex
	'aec218a09666a4c3d79eafa5cc46f5a0'									:'(MD5) Golden image: 84163 bytes of grbl_v1.1h.20190825.hex'		,	# coreutils hashsum --md5   grbl_v1.1h.20190825.hex
	'681daa3a293b01f17107aea47c3f04e9'									:'(MD5) Golden image: 29920 bytes of grbl_v1.1h.20190825.bin'		,

	'8543dbc6ef76605486482cb0ec9ace316f19191dea357cb883287804394dc5a5'	:'(BLAKE3) Golden image: 84163 bytes of grbl_v1.1h.20190825.hex'	,	# coreutils hashsum --b3sum grbl_v1.1h.20190825.hex
	'c2169d2400ebc5c55eb9e1543bfafbe8aab0e76a2edc044315981958485f7a17'	:'(BLAKE3) Golden image: 29920 bytes of grbl_v1.1h.20190825.bin'	,

	# ==== kimstik/grbl master branch (vanilla) ====
	# Built from: https://github.com/kimstik/grbl commit eefe2bb (master)
	# Compiler: avr-gcc (GCC) 7.3.0 (Arduino toolchain)
	# Flags: -Wall -Os -DF_CPU=16000000 -mmcu=atmega328p -ffunction-sections -flto -Wl,--gc-sections
	# Build date: 2025-11-21
	# Archive: build/vanilla-grbl-gcc-7.3.0.tar.gz (60KB)
	'9cb869c15075d1adc9d37d1bcf614d06':'grbl.hex (vanilla master, gcc 7.3.0+LTO) 83656 bytes',
	'ce0b90457da3d01159ce435dd4f5336e':'grbl.bin (vanilla master, gcc 7.3.0+LTO) 29738 bytes',
	'87a85a47993a1381737cbbf83059bacc':'main.elf (vanilla master, gcc 7.3.0+LTO) 46388 bytes',

	# ==== Historical / other builds ====
	'7f14441d024bb6af43b547e435e598b8':'grbl.hex - gcc 15.2',

	'6134ac924a80e22a31ffb83643b5add1':'grbl.bin - 30640 - gcc 7.3.0 no LTO'	,
	'79af184e67b27defd27a39309ac53563':'grbl.hex - 86188 - gcc 7.3.0 no LTO'	,	# << working horse
}

if __name__ == "__main__":
	with open(sys.argv[1], "rb") as f:
		v = f.read()
		for h in ( md5(v).hexdigest(), ):	# blake3(v),  )
			if h in known_hashes:
				print(f'{GREEN}OK{NC}\t{known_hashes[h]}')
				sys.exit(0)
	print(f'{RED}FAIL{NC}')
	sys.exit(1)
