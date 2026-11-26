"""Before execution, check ELF section sizes and frozen local production hashes."""
import hashlib
import json
import struct
import sys
from pathlib import Path

EXPECTED = {
    'g94': ('482c6d098adeeaf4db536b959296b5da3a08a49b2a95ae3fa2f05c1415a00e29',
            '0e747a0c99cea41fe033ac93920de5a6a2ad2cc540b1ceedd8848c0d75ca8c11'),
    'g93': ('d0dea7dbd009bed535e54835441528ffdd75be67068e2969b9638cf99950deef',
            '10139a3d17e4b75409f6ba2c560b7ad09bb1a5e43695020404b8a85b97ddb137'),
}

def elf(path, boot=False, expected=None):
    data = path.read_bytes()
    assert data[:7] == b'\x7fELF\x01\x01\x01', (path, 'ELF32 little endian')
    assert struct.unpack_from('<H', data, 18)[0] == 83, (path, 'AVR machine')
    offset = struct.unpack_from('<I', data, 32)[0]
    size, count, strings = struct.unpack_from('<3H', data, 46)
    assert size == 40 and strings < count
    sections = [struct.unpack_from('<10I', data, offset+i*size) for i in range(count)]
    st = sections[strings]
    names = data[st[4]:st[4]+st[5]]
    sizes = {}
    for section in sections:
        name = names[section[0]:].split(b'\0', 1)[0].decode('ascii')
        sizes[name] = section[5]
    flash = sizes['.text'] + sizes.get('.data', 0)
    assert flash <= 32768, (path, 'full flash', flash)
    if boot:
        assert flash <= 32256, (path, 'boot application', flash)
        assert sizes.get('.data', 0)+sizes.get('.bss', 0) == 1670
    digest = hashlib.sha256(data).hexdigest()
    if expected:
        assert digest == expected, (path, 'frozen local hash', digest, expected)
    return dict(sha256=digest, flash=flash, data=sizes.get('.data', 0),
                bss=sizes.get('.bss', 0), full_margin=32768-flash,
                boot_margin=32256-flash if boot else None)

root, mode = Path(sys.argv[1]), sys.argv[2]
result = {}
for index, arm in enumerate(('control', 'candidate')):
    result[arm] = {image: elf(root/arm/(image+'.elf'), image == 'production',
                             EXPECTED[mode][index] if image == 'production' else None)
                   for image in ('production', 'bench', 'dump')}
    result[arm]['off'] = elf(root/arm/'off/main.elf', True, EXPECTED[mode][0])
print(json.dumps(result, indent=2))
