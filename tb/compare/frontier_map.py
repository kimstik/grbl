#!/usr/bin/env python3
"""Fail closed on ELF call-site and source-layout mismatches."""
import json
import re
import subprocess
import sys
from pathlib import Path

elf, output = map(Path, sys.argv[1:])
nm = subprocess.check_output(['avr-nm', '-n', '-S', str(elf)], text=True)
dis = subprocess.check_output(['avr-objdump', '-d', str(elf)], text=True)
output.with_suffix('.symbols.txt').write_text(nm)
output.with_suffix('.disassembly.txt').write_text(dis)
symbols = {}
for line in nm.splitlines():
    row = line.split()
    if len(row) == 4:
        addr, size, kind, name = row
        if name in symbols and not name.startswith(('.', 'L0^')):
            raise AssertionError(f'ambiguous {name}')
        symbols[name] = (int(addr, 16), int(size, 16), kind)
for name, size in [('segment_buffer', 42), ('prep', 48), ('st', 35),
                   ('sys', 17), ('block_buffer', 800), ('pi', 2), ('lp', 2),
                   ('segment_buffer_head', 1), ('segment_buffer_tail', 1)]:
    assert symbols[name][1] == size, (name, symbols[name], size)
start, size, _ = symbols['__vector_11']
idle = symbols['st_go_idle'][0]
insns = []
for line in dis.splitlines():
    match = re.match(r'\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*(\S+)\s*(.*)', line)
    if match:
        pc, op, args = match.groups()
        insns.append((int(pc, 16), op, args, line))
calls = [x for x in insns if start <= x[0] < start+size
         and x[1] in ('call', 'rcall') and '<st_go_idle>' in x[2]]
assert len(calls) == 1, calls
pc = calls[0][0]
assert f'<st_go_idle>' in calls[0][2]
# Only preparation and reset may publish a head change. Source layout is
# independently compiled with static assertions by the workflow.
prep_start, prep_size, _ = symbols['st_prep_buffer']
head = symbols['segment_buffer_head'][0] - 0x800000
stores = [x for x in insns if x[1] == 'sts' and
          re.match(rf'0x0*{head:x},', x[2], re.I)]
assert len([x for x in stores if prep_start <= x[0] < prep_start+prep_size]) == 1, stores
output.write_text(f'{pc:x}\n')
output.with_suffix('.mapping.json').write_text(json.dumps(dict(
    empty_call=pc, idle_entry=idle, isr=[start, size],
    publication_stores=[x[3] for x in stores],
    empty_window=[x[3] for x in insns if pc-48 <= x[0] <= pc+16],
    model='head transition publishes old slot; tail transition consumes old slot; no helper argument decoding'), indent=2))
print(output.with_suffix('.mapping.json').read_text())
