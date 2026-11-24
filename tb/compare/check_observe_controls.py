#!/usr/bin/env python3
"""Directed integrity controls of the live observer checker, using a real trace."""
import argparse
import json
import struct
import subprocess
import sys
import tempfile
from pathlib import Path


def word(value):
    return str(struct.unpack('<I', struct.pack('<f', value))[0])


def number(value):
    return struct.unpack('<f', struct.pack('<I', int(value)))[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path, help='baseline observed/blind trace directory')
    args = parser.parse_args()
    source = args.directory.resolve()
    checker = Path(__file__).with_name('check_observe.py')
    rows = [line.split() for line in (source / 'observed.txt').read_text().splitlines()]
    blind = [line.split() for line in (source / 'blind.txt').read_text().splitlines()]
    first = next(i for i, row in enumerate(rows) if row[0] == 'point')
    second = next(i for i, row in enumerate(rows) if row[0] == 'point' and row[3] == '2')
    last = next(i for i, row in enumerate(rows) if row[0] == 'curve_end') - 1
    with tempfile.TemporaryDirectory(dir=source.parent, prefix='observe-controls-') as directory:
        root = Path(directory)

        def run(name, change=None, blind_change=None, accept=False, extra=(), excess=False):
            events = [row[:] for row in rows]
            control = [row[:] for row in blind]
            if change:
                change(events)
            if blind_change:
                blind_change(control)
            path, blind_path = root / 'events.txt', root / 'blind.txt'
            path.write_text('\n'.join(' '.join(row) for row in events) + '\n')
            blind_path.write_text('\n'.join(' '.join(row) for row in control) + '\n')
            output = root / 'metrics.json'
            command = [sys.executable, '-I', str(checker), str(path), str(source / 'observed-uart.txt'),
                       '--blind', str(blind_path), '--blind-uart', str(source / 'blind-uart.txt'),
                       '--output', str(output), *extra]
            result = subprocess.run(command, capture_output=True, text=True, timeout=60)
            assert (result.returncode == 0) == accept, f'{name}: {result.stdout}\n{result.stderr}'
            if excess:
                assert any(c['z_over'] for c in json.loads(output.read_text())['curves']), 'raw excess concealed'
            print(f'control {name}: pass')

        run('baseline', accept=True)
        run('blind-cycle', blind_change=lambda r: r[-1].__setitem__(1, str(int(r[-1][1]) + 1)))
        run('wrong-end', change=lambda r: r[last].__setitem__(5, word(number(r[last][5]) + 1)))
        run('nonfinite', change=lambda r: r[first].__setitem__(5, str(0x7fc00000)))
        run('Z-reversal', change=lambda r: r[second].__setitem__(7, word(1)))
        run('zero-feed', change=lambda r: r[first].__setitem__(8, word(0)))
        run('bad-counter', change=lambda r: r[-1].__setitem__(7, str(int(r[-1][7]) + 1)))
        run('missing-point', change=lambda r: r.pop(first))
        run('no-prefetch-coverage', extra=('--require-prefetch',))
        run('baseline-target-mismatch', change=lambda r: r[first].__setitem__(8, word(number(r[first][8])*2)),
            extra=('--baseline', str(source / 'observed.txt'), '--baseline-uart', str(source / 'observed-uart.txt')))

        def monotone_excess(events):
            start = end = count = None
            for row in events:
                if row[0] == 'curve':
                    start, end, count = number(row[8]), number(row[15]), int(row[5])
                elif row[0] == 'point':
                    i = int(row[3])
                    row[7] = word(start + (end - start)*(i/count)**2)
                    if i == count:
                        row[7] = word(end)

        run('monotone-excess', change=monotone_excess, accept=True, excess=True)
        xy = ('--baseline', str(source / 'observed.txt'),
              '--baseline-uart', str(source / 'observed-uart.txt'), '--xy-only')
        run('XY-only-baseline', accept=True, extra=xy)
        run('XY-only-X-mismatch', change=lambda r: r[first].__setitem__(5, word(number(r[first][5]) + 1)), extra=xy)
        run('XY-only-feed-mismatch', change=lambda r: r[first].__setitem__(8, word(number(r[first][8])*2)), extra=xy)
        run('XY-only-condition-mismatch', change=lambda r: r[first].__setitem__(9, str(int(r[first][9]) ^ 16)), extra=xy)
        run('XY-only-monotone-excess', change=monotone_excess, accept=True, excess=True, extra=xy)
        run('XY-only-without-baseline', extra=('--xy-only',))
        run('XY-only-with-prefetch', extra=(*xy, '--require-prefetch'))
    print('observe controls: 18 passed; integrity defects rejected, raw excess retained')


if __name__ == '__main__':
    main()
