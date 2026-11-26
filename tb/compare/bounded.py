#!/usr/bin/env python3
"""Four-case raw AVR audit; chord Z, true line geometry and nominal time stay separate."""
import argparse
import json
import math
from pathlib import Path
import re
import struct

CASES = ('short_s', 'long_s', 'translated_line', 'origin_line')


def require(value, message):
    if not value:
        raise ValueError(message)


def decode(path):
    groups, active = [], None
    start = (0., 0., 0.)
    for number, line in enumerate(path.read_text().splitlines(), 1):
        line = line.strip()
        if re.match(r'^G\d', line):
            if active:
                groups.append(active)
                if active['points']:
                    start = active['points'][-1][:3]
            active = dict(command=line, start=start, points=[], words=[], rows=[], summary=None)
        elif line.startswith('p '):
            words = tuple(map(int, line.split()[1:]))
            require(len(words) == 5, 'point fields')
            values = struct.unpack('<4f', struct.pack('<4I', *words[:4]))
            active['points'].append((*values, words[4]))
            active['words'].append(words)
            active['rows'].append(number)
        elif active and re.match(r'^\d+(?: \d+){9}(?: |$)', line):
            active['summary'] = tuple(map(int, line.split()))
    if active:
        groups.append(active)
    return [g for g in groups if g['command'].startswith('G5')]


def timed(path):
    text = path.read_text()
    require(text.splitlines().count('done') == 1, 'bench completion')
    calib = re.search(r'^calib (\d+)$', text, re.M)
    require(calib and 1000000 <= int(calib[1]) <= 1001000, 'timer calibration')
    rows = {}
    for line in text.splitlines():
        words = line.split()
        if line.startswith('G5'):
            require(len(words) == 11, 'timed fields')
            rows[words[0]] = tuple(map(int, words[1:]))
    require(len(rows) == 4, 'four timed cases')
    stack = re.search(r'^stack (\d+)$', text, re.M)
    require(stack is not None, 'stack watermark')
    return rows, int(stack[1])


def metrics(g, case, mode):
    points, start, summary = g['points'], g['start'], g['summary']
    require(summary and len(summary) == 18, 'dump summary and trace')
    require(summary[0] == 0 and summary[1] == len(points) and summary[7:9] == (1, 0), 'status/count/end/finite')
    h = 2166136261
    for words in g['words']:
        for byte in struct.pack('<3I', *words[:3]):
            h = ((h ^ byte) * 16777619) & 0xffffffff
    require(h == summary[9], 'raw target hash')
    chords, spatial = [], []
    previous = start
    for p in points:
        require(all(math.isfinite(x) for x in p[:4]) and p[3] > 0, 'finite targets/feed')
        chords.append(math.hypot(p[0]-previous[0], p[1]-previous[1]))
        spatial.append(math.dist(p[:3], previous[:3]))
        previous = p
    length = math.fsum(chords)
    dz = points[-1][2] - start[2]
    errors, cumulative = [], 0.
    previous = start[2]
    for p, d in zip(points, chords):
        cumulative += d
        require((p[2]-previous)*dz >= 0, 'monotone Z')
        errors.append(p[2] - (start[2] + dz*cumulative/length))
        previous = p[2]
    at = max(range(len(errors)), key=lambda i: abs(errors[i]))
    result = dict(case=case, command=g['command'], segments=len(points), xy_chord_length_mm=length,
                  chord_z_mm=abs(errors[at]), chord_z_signed_mm=errors[at], worst_chord_vertex=at+1,
                  penultimate_chord_z_signed_mm=errors[-2], true_line_3d_mm=None,
                  nominal_g93_relative_error=None, trace=dict(zip(
                      ('estimates', 'sums', 'open', 'ends', 'pieces', 'summed'), summary[10:16])))
    if mode == 'g93':
        require(all(not (p[4] & 8) for p in points), 'G93 converted to path feed')
        minutes = math.fsum(d/p[3] for p, d in zip(points, spatial))
        result['nominal_g93_relative_error'] = abs(2*minutes - 1)
    if case.endswith('_line'):
        expected = (60000., 60000., 0.) if case.startswith('translated') else (0., 0., 0.)
        require(start == expected, 'line start')
        v = tuple(points[-1][i]-start[i] for i in range(3))
        require(v == (-4., -2., 1000.), 'line endpoint')
        vv = math.fsum(x*x for x in v)
        distances = []
        projected_z = []
        for p in points:
            u = max(0., min(1., math.fsum((p[i]-start[i])*v[i] for i in range(3))/vv))
            distances.append(math.sqrt(math.fsum((p[i]-start[i]-u*v[i])**2 for i in range(3))))
            xy_u = ((p[0]-start[0])*v[0] + (p[1]-start[1])*v[1])/20
            projected_z.append(p[2]-(start[2]+1000*xy_u))
        k = max(range(len(points)), key=lambda i: distances[i])
        result.update(true_xy_arc_length_mm=math.sqrt(20), true_line_3d_mm=distances[k],
                      true_line_over_002=distances[k] > .002, worst_3d_vertex=k+1,
                      worst_3d_dump_row=g['rows'][k], worst_3d_xyz=points[k][:3],
                      xy_projected_z_mm=max(map(abs, projected_z)))
    return result


def report(root, mode):
    rows, untouched = timed(root/'bench.txt')
    dump = (root/'dump.txt').read_text()
    require(dump.splitlines().count('done') == 1, 'dump completion')
    groups = decode(root/'dump.txt')
    exact = 'TB_Z_EXACT_CHORDS' in (root/'options.txt').read_text()
    require(len(groups) == 4, 'four dump cases')
    if exact:
        require(all(g['summary'][14] == 0 and g['summary'][15] == len(g['points'])
                    for g in groups), 'exact arm sums every emitted chord, no coarse pieces')
    results = []
    for g, case in zip(groups, CASES):
        t = rows[g['command']]
        require(t[0] == 0 and t[1] == len(g['points']) and t[7:9] == (1, 0), 'timed integrity')
        require(t[9] == g['summary'][9], 'timed/dump target identity')
        m = metrics(g, case, mode)
        m.update(first_ms=t[5]/16000, gap_ms=t[6]/16000, generator_ms=t[4]/16000)
        results.append(m)
    # bench.c reports untouched bytes, not stack use. Linker symbols locate the painted span.
    symbols = dict((name, int(address, 16)) for address, kind, name in
                   (s.split() for s in (root/'bench-symbols.txt').read_text().splitlines() if len(s.split()) == 3))
    heap = symbols['__heap_start'] & 0xffff
    bench_used = 0x900 - heap - untouched
    require(0 <= bench_used < 2048, 'bench watermark range')
    return dict(mode=mode, cases=results, bench_untouched_bytes=untouched,
                bench_stack_used_bytes=bench_used, bench_heap_address=heap,
                stack_scope='Timed bench + Timer1/UART ISR; not production stepper ISR or motion stack')


def control():
    # Exact straight-line oracle must reject the audited blind spot without curve sampling.
    a = (60000., 60000., 0.)
    v = (-4., -2., 1000.)
    p = (59999.75390625, 59999.875, 62.38275146484375)
    u = math.fsum((p[i]-a[i])*v[i] for i in range(3))/math.fsum(x*x for x in v)
    d = math.sqrt(math.fsum((p[i]-a[i]-u*v[i])**2 for i in range(3)))
    require(abs(d - .0034452199295751567) < 1e-12 and d > .002, 'true line control')
    print('control: exact line counterexample rejected')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path, nargs='?')
    parser.add_argument('--mode', choices=('g94', 'g93'))
    parser.add_argument('--control', action='store_true')
    args = parser.parse_args()
    if args.control:
        control()
    else:
        require(args.root is not None and args.mode is not None, 'root/mode required')
        output = report(args.root, args.mode)
        (args.root/'metrics.json').write_text(json.dumps(output, indent=2)+'\n')
        print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
