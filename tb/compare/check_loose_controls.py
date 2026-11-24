#!/usr/bin/env python3
"""Exercise the raw reporter with one real dump and directed corruptions."""
import argparse
import re
import struct
import subprocess
import tempfile
from pathlib import Path


def bits(value):
    return struct.unpack('<I', struct.pack('<f', value))[0]


def number(word):
    return struct.unpack('<f', struct.pack('<I', word))[0]


def checksum(points):
    result = 2166136261
    for point in points:
        for word in point[:3]:
            for shift in (0, 8, 16, 24):
                result = ((result ^ ((word >> shift) & 255)) * 16777619) & 0xffffffff
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tb', type=Path)
    parser.add_argument('dump', type=Path)
    parser.add_argument('--command', default='G5X10Y0Z-3I3J12P3Q-12F1000')
    args = parser.parse_args()
    command = args.command
    rows = [re.sub(r'\x1b\[[0-9;]*m', '', line).rstrip('.')
            for line in args.dump.read_text().splitlines()]
    index = rows.index(command) + 1
    original = []
    while rows[index].startswith('p '):
        original.append(list(map(int, rows[index].split()[1:])))
        index += 1
    summary = list(map(int, rows[index].split()))
    assert len(original) > 3 and len(summary) in (10, 18), 'control source'
    assert summary[1] == len(original) and summary[9] == checksum(original), 'control integrity'
    prefix = ['G21G17G90G94F1000', 'G0X0Y0Z0', command]
    with tempfile.TemporaryDirectory(dir=args.dump.resolve().parent, prefix='loose-controls-') as directory:
        root = Path(directory)
        lines = root / 'lines.txt'
        lines.write_text('\n'.join(prefix[:-1] + ['*' + command]) + '\n')

        def run(name, change=None, accept=False, excess=False, missing=False):
            points = [point[:] for point in original]
            fields = summary[:]
            if change:
                change(points, fields)
            if name != 'bad-hash':
                fields[9] = checksum(points)
            text = prefix + ['p ' + ' '.join(map(str, point)) for point in points]
            if not missing:
                text.append(' ' + ' '.join(map(str, fields)))
            text.append('done')
            output = root / (name + '.txt')
            output.write_text('\n'.join(text) + '\n')
            result = subprocess.run([str(args.tb.resolve()), '--dump-report', str(lines), str(output)],
                                    capture_output=True, text=True, timeout=60)
            assert (result.returncode == 0) == accept, f'{name}: exit {result.returncode}\n{result.stdout}\n{result.stderr}'
            if excess:
                assert 'z_over 1' in result.stdout and '0 failed' in result.stdout, result.stdout
            print(f'control {name}: pass')

        run('baseline', accept=True)
        run('wrong-end', lambda p, f: p[-1].__setitem__(0, bits(number(p[-1][0]) + 1)))
        run('nonfinite', lambda p, f: p[1].__setitem__(0, 0x7fc00000))
        run('Z-reversal', lambda p, f: p[1].__setitem__(2, bits(1)))
        run('zero-feed', lambda p, f: p[1].__setitem__(3, bits(0)))
        run('missing-summary', missing=True)
        run('bad-count', lambda p, f: f.__setitem__(1, len(p) + 1))
        run('bad-hash', lambda p, f: f.__setitem__(9, f[9] ^ 1))

        def monotone_excess(points, fields):
            end = points[-1][2]
            for i, point in enumerate(points, 1):
                point[2] = bits(number(end) * (i / len(points))**2)
            points[-1][2] = end

        run('monotone-excess', monotone_excess, accept=True, excess=True)
    print('report controls: 9 passed; raw excess reported, integrity defects rejected')


if __name__ == '__main__':
    main()
