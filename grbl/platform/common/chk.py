#!/usr/bin/env python3

#integrity checker
import argparse, sys
from hashlib import md5
#from blake3  import blake3	#keep it for the future

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

known_hashes = {
	# source code https://github.com/gnea/grbl/archive/refs/tags/v1.1h.20190825.tar.gz
	# image       https://github.com/gnea/grbl/releases/download/v1.1h.20190825/grbl_v1.1h.20190825.hex
	'aec218a09666a4c3d79eafa5cc46f5a0':'(MD5) Golden image: 84163 bytes of grbl_v1.1h.20190825.hex'	, 
	'7f14441d024bb6af43b547e435e598b8':'grbl.hex - gcc 15.2'										,
	'6134ac924a80e22a31ffb83643b5add1':'grbl.bin - gcc 7   '			  							,
	'79af184e67b27defd27a39309ac53563':'grbl.hex - gcc 7   '										,

}

if __name__ == "__main__":
	with open(sys.argv[1], "rb") as f:
		v = f.read()
		for h in ( md5(v).hexdigest(), ):	# blake3(v),  )
			if h in known_hashes:
				print(f'OK\t{known_hashes[h]}')
				sys.exit(0)
	print('FAIL')
	sys.exit(1)
