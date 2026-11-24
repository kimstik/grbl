#!/usr/bin/env python3
"""Check raw cross-arm identity with directed changes to one real measured curve."""
import argparse
import copy
import re
import runpy
import subprocess
import sys
import tempfile
from pathlib import Path


def checksum(points):
    value = 2166136261
    for point in points:
        for word in point[:3]:
            for shift in (0, 8, 16, 24):
                value = ((value ^ ((word >> shift) & 255)) * 16777619) & 0xffffffff
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path, help='one completed headless artifact')
    args = parser.parse_args()
    checker = Path(__file__).with_name('check_loose.py')
    helpers = runpy.run_path(str(checker))
    source = args.directory.resolve()
    commands = [line[1:] for line in (source / 'corpus.txt').read_text().splitlines()
                if line.startswith('*')]
    all_groups = helpers['dump'](helpers['clean'](source / 'dump.txt'), commands, include_points=True)
    rows = helpers['bench'](helpers['clean'](source / 'bench.txt'), commands, False)
    command, measured = rows[0]
    points, summary = all_groups[0]
    assert len(points) > 3 and len(summary) == 18, 'control source'
    calibration = next(line for line in helpers['clean'](source / 'bench.txt')
                       if re.fullmatch(r'calib \d+', line))
    passed = 0
    with tempfile.TemporaryDirectory(prefix='identity-controls-', dir=source.parent) as directory:
        root = Path(directory)
        corpus, bench, dump, reference = (root / name for name in ('corpus.txt', 'bench.txt', 'dump.txt', 'reference.txt'))
        corpus.write_text('*' + command + '\n')

        def write_dump(path, group):
            targets, fields = group
            path.write_text('\n'.join([command, *('p ' + ' '.join(map(str, p)) for p in targets),
                                      ' '.join(map(str, fields)), 'done']) + '\n')

        def run(name, change=None, reference_change=None, accept=False, xy=False, options=None):
            nonlocal passed
            group, old = copy.deepcopy((points, summary)), copy.deepcopy((points, summary))
            if change:
                change(*group)
            if reference_change:
                reference_change(*old)
            for targets, fields in (group, old):
                fields[1], fields[9] = len(targets), checksum(targets)
            timing = measured[:]
            for field in (0, 1, 7, 8, 9):
                timing[field] = group[1][field]
            bench.write_text('\n'.join([calibration, command + ' ' + ' '.join(map(str, timing)), 'done']) + '\n')
            write_dump(dump, group)
            write_dump(reference, old)
            extra = ['--dump', str(dump), '--reference', str(reference)]
            if xy:
                extra.append('--xy-only')
            if options is not None:
                extra = options
            result = subprocess.run([sys.executable, '-I', str(checker), str(corpus), str(bench), *extra],
                                    capture_output=True, text=True, timeout=30)
            assert (result.returncode == 0) == accept, f'{name}: {result.stdout}\n{result.stderr}'
            if not accept and options is None:
                assert 'raw identity failed:' in result.stderr, f'{name}: not an identity rejection\n{result.stderr}'
            print(f'control {name}: pass')
            passed += 1

        run('full-identical', accept=True)
        run('XY-identical', xy=True, accept=True)
        for field, name in enumerate(('X', 'Y', 'Z', 'feed', 'condition')):
            def change(targets, fields, field=field):
                targets[1][field] ^= 1
            run('full-' + name, change=change)
            run('XY-' + name, change=change, xy=True, accept=field == 2)

        def trace(targets, fields):
            fields[10] += 1

        run('full-trace', change=trace)
        run('XY-trace', change=trace, xy=True, accept=True)
        run('full-count', change=lambda p, f: p.pop(1))
        run('XY-count', change=lambda p, f: p.pop(1), xy=True)
        run('reference-status', reference_change=lambda p, f: f.__setitem__(0, 1))
        run('reference-end', reference_change=lambda p, f: f.__setitem__(7, 0), xy=True)
        run('reference-nonfinite', reference_change=lambda p, f: f.__setitem__(8, 1), xy=True)
        run('reference-without-dump', options=['--reference', str(reference)])
        run('XY-without-reference', options=['--dump', str(dump), '--xy-only'])
    print(f'identity controls: {passed} passed; feed and condition remain required in XY-only comparisons')


if __name__ == '__main__':
    main()
