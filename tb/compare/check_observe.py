#!/usr/bin/env python3
"""Validate read-only live traces. Raw Z excess is data, not a waived failure."""
import argparse
import json
import math
import struct
from pathlib import Path


def floats(words):
    return [struct.unpack('<f', struct.pack('<I', int(word)))[0] for word in words]


def snapshot(text, size):
    raw = bytes.fromhex(text)
    assert len(raw) == size, 'state size'
    return dict(raw=raw, next=int.from_bytes(raw[20:22], 'little'),
                todo=int.from_bytes(raw[22:24], 'little'), pieces=raw[24],
                prefetch=raw[25] if size == 26 else None)


def read_trace(path, uart, blind=None, blind_uart=None):
    rows = [line.split() for line in path.read_text().splitlines()]
    assert rows and rows[0][0] == 'meta' and rows[-1][0] == 'end', 'trace framing'
    meta, end = list(map(int, rows[0][1:])), list(map(int, rows[-1][1:]))
    assert len(meta) == 9 and meta[:2] == [1, 16000000] and meta[-1] == 0, 'metadata'
    size = meta[5]
    assert size in (25, 26, 35), 'unknown state layout'
    assert len(end) == 9 and end[1] == 6 and end[-2:] == [0, 0], 'incomplete simulation'
    data = uart.read_bytes()
    assert end[2] == len(data), 'UART byte count'
    if blind:
        control = [line.split() for line in blind.read_text().splitlines()]
        assert len(control) == 2 and control[0][0] == 'meta' and control[1][0] == 'end', 'blind framing'
        bm, be = list(map(int, control[0][1:])), list(map(int, control[1][1:]))
        assert bm[:-1] == meta[:-1] and bm[-1] == 1, 'blind metadata'
        assert be[:4] == end[:4] and be[4:] == [0] * 5, 'observer changed cycle/state/UART timing'
        assert blind_uart.read_bytes() == data, 'observer changed UART bytes'

    curves, active, calls, points, last_cycle = [], None, 0, 0, 0
    for row in rows[1:-1]:
        kind = row[0]
        if kind == 'curve':
            assert active is None and len(row) == 16, 'overlapping curve or curve fields'
            ident, prog, pi, cycle, count = map(int, row[1:6])
            assert ident == len(curves) + 1 and 2 <= count <= 2000, 'curve index/count'
            net_bits = list(map(int, row[6:]))
            net = floats(net_bits)
            assert all(math.isfinite(x) for x in net), 'nonfinite control net'
            active = dict(id=ident, program=prog, line=pi, cycle=cycle, segments=count,
                          net=net, net_bits=net_bits, points=[], calls=[])
        elif kind == 'next':
            assert active is not None and len(row) == 10, 'helper outside curve or fields'
            ident, prog, cycle, duration, j, count, result = map(int, row[1:8])
            assert (ident, prog, count) == (active['id'], active['program'], active['segments']), 'helper identity'
            assert 0 <= j < count and result in (0, 1) and duration > 0, 'helper indices/result'
            before, after = snapshot(row[8], size), snapshot(row[9], size)
            if j == 0 and size == 26:
                assert before['raw'][4:12] == after['raw'][4:12], 'prefetch changed active rest/u'
                assert before['next'] == after['next'], 'prefetch changed deadline'
                assert before['pieces'] == after['pieces'], 'prefetch changed grid'
            active['calls'].append(dict(cycle=cycle, duration=duration, j=j,
                                        result=result, before=before, after=after))
            calls += 1
        elif kind == 'point':
            assert active is not None and len(row) == 10, 'point outside curve or fields'
            ident, prog, ordinal, cycle = map(int, row[1:5])
            assert (ident, prog, ordinal) == (active['id'], active['program'], len(active['points']) + 1), 'point order'
            bits = list(map(int, row[5:9]))
            values = floats(bits)
            condition = int(row[9])
            assert all(math.isfinite(x) for x in values) and values[3] > 0, 'nonfinite point or invalid feed'
            assert 0 <= condition <= 255 and not condition & 8, 'live workload must be G94'
            active['points'].append(dict(bits=bits, values=values, condition=condition, cycle=cycle))
            points += 1
        elif kind == 'curve_end':
            assert active is not None and len(row) == 3, 'curve end outside curve'
            ident, cycle = map(int, row[1:])
            assert ident == active['id'] and len(active['points']) == active['segments'], 'incomplete target sequence'
            assert active['points'][-1]['bits'][:3] == active['net_bits'][-3:], 'inexact endpoint'
            curves.append(active)
            active = None
        else:
            raise AssertionError(f'unknown record {kind}')
        assert cycle >= last_cycle, 'nonmonotone event cycles'
        last_cycle = cycle
    assert active is None and end[0] >= last_cycle, 'unfinished curve or invalid end cycle'
    assert end[4:7] == [len(curves), calls, points], 'trace counters'
    assert [(c['program'], c['line']) for c in curves] == [(p, line) for p in range(1, 5) for line in (2, 3, 4)], 'workload coverage'
    for curve in curves:
        size_mm = {1: 10, 2: 20, 3: 60, 4: 60}[curve['program']]
        dz = -10 if curve['program'] == 2 else -30
        x, z = -(curve['line'] - 2)*size_mm, (curve['line'] - 2)*dz
        expected = [x, 0, z, x - size_mm/2, size_mm/2,
                    x - size_mm/2, -size_mm/2, x - size_mm, 0, z + dz]
        assert curve['net'] == expected, 'control-net ABI or workload mismatch'

    text = data.decode('ascii')
    lines = text.splitlines()
    runs = [line.split() for line in lines if line.startswith('run ')]
    wanted = [(10000, 5000), (20000, 5000), (60000, 5000), (60000, 1000)]
    assert len(runs) == 4 and not any('timeout' in line for line in lines), 'live programs missing or timeout'
    for row, key in zip(runs, wanted):
        assert len(row) == 21 and row[1] == 'G5Z' and tuple(map(int, row[2:4])) == key, 'live program parameters'
        assert list(map(int, row[17:20])) == [0, 0, 0], 'live XYZ endpoint'
    stack = [line.split() for line in lines if line.startswith('stack ')]
    assert len(stack) == 1 and len(stack[0]) == 3 and int(stack[0][1]) == max(int(r[-1]) for r in runs), 'stack footer'
    assert lines.count('done') == 1, 'missing or duplicate UART done'
    return dict(size=size, end=end, curves=curves, runs=runs, stack=int(stack[0][1]))


def metrics(trace):
    results = []
    for curve in trace['curves']:
        start, target = curve['net'][:3], curve['net'][-3:]
        previous, length, lengths = start, 0.0, []
        for point in curve['points']:
            p = point['values']
            length += math.hypot(p[0] - previous[0], p[1] - previous[1])
            lengths.append(length)
            previous = p
        dz, previous_z = target[2] - start[2], start[2]
        error = 0.0
        for point, distance in zip(curve['points'], lengths):
            p = point['values']
            assert (p[2] - previous_z) * dz >= 0 and min(start[2], target[2]) <= p[2] <= max(start[2], target[2]), 'Z reversal/overshoot'
            expected = start[2] + dz * distance / length if length else target[2]
            error = max(error, abs(p[2] - expected))
            previous_z = p[2]
        optional = [c for c in curve['calls'] if c['j'] == 0]
        units = [c for c in optional if c['before']['raw'] != c['after']['raw']]
        completed = sum(c['after']['todo'] == 0 for c in units)
        rest_changed = sum(c['before']['raw'][4:8] != c['after']['raw'][4:8] for c in optional)
        ready_used = sum(c['j'] > 0 and c['before']['prefetch'] == 2 and c['after']['prefetch'] == 0 for c in curve['calls'])
        partial_at = {c['j'] for c in curve['calls'] if c['j'] > 0 and c['before']['prefetch'] == 1 and curve['segments'] + 1 - c['j'] == c['before']['next']}
        mandatory = {}
        for call in curve['calls']:
            if call['j'] and call['result']:
                group = mandatory.setdefault(call['j'], [call['cycle'], call['cycle']])
                group[1] = call['cycle'] + call['duration']
        pauses = [(j, (last - first) / 16000) for j, (first, last) in mandatory.items()]
        times = [p['cycle'] for p in curve['points']]
        results.append(dict(program=curve['program'], line=curve['line'], segments=curve['segments'],
                            z_mm=error, z_over=int(error > .002), xy_length=length,
                            first_helper_to_point_ms=(times[0] - curve['cycle']) / 16000,
                            largest_target_gap_ms=max((b - a) / 16000 for a, b in zip(times, times[1:])),
                            later_mandatory_pause_ms=max((t for j, t in pauses if j > 1), default=0),
                            optional_calls=len(optional), optional_units=len(units),
                            optional_passes_completed=completed, active_rest_changes=rest_changed,
                            ready_passes_used=ready_used, partial_deadlines=len(partial_at)))
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('trace', type=Path)
    parser.add_argument('uart', type=Path)
    parser.add_argument('--blind', type=Path)
    parser.add_argument('--blind-uart', type=Path)
    parser.add_argument('--baseline', type=Path)
    parser.add_argument('--baseline-uart', type=Path)
    parser.add_argument('--require-prefetch', action='store_true')
    parser.add_argument('--xy-only', action='store_true',
                        help='compare net/grid/XY and G94 feed; report changed Z independently')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    assert bool(args.blind) == bool(args.blind_uart), 'both blind files are required'
    assert bool(args.baseline) == bool(args.baseline_uart), 'both baseline files are required'
    assert not args.xy_only or args.baseline, 'XY comparison requires baseline'
    assert not (args.xy_only and args.require_prefetch), 'prefetch requires full target identity'
    trace = read_trace(args.trace, args.uart, args.blind, args.blind_uart)
    result = dict(state_bytes=trace['size'], stack=trace['stack'], curves=metrics(trace))
    if args.baseline:
        base = read_trace(args.baseline, args.baseline_uart)
        assert len(base['curves']) == len(trace['curves']), 'baseline curve count'
        for a, b in zip(base['curves'], trace['curves']):
            assert (a['program'], a['line'], a['segments'], a['net_bits']) == (b['program'], b['line'], b['segments'], b['net_bits']), 'baseline net/grid differs'
            if args.xy_only:
                assert [(p['bits'][:2], p['bits'][3], p['condition']) for p in a['points']] == [(p['bits'][:2], p['bits'][3], p['condition']) for p in b['points']], 'baseline XY/feed/condition bits differ'
            else:
                assert [(p['bits'], p['condition']) for p in a['points']] == [(p['bits'], p['condition']) for p in b['points']], 'prefetch changed XYZ/feed/condition bits'
        result['baseline_xy_feed_identical' if args.xy_only else 'baseline_targets_identical'] = True
    if args.require_prefetch:
        assert trace['size'] == 26, 'not the prefetch state'
        assert sum(c['optional_units'] for c in result['curves']) > 0, 'no live optional unit coverage'
        assert sum(c['ready_passes_used'] + c['partial_deadlines'] for c in result['curves']) > 0, 'no live prefetched deadline coverage'
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(f"observe: {len(result['curves'])} curves, finite/exact/monotone/feed/counters/XYZ checked; raw max Z {max(c['z_mm'] for c in result['curves']):.9g} mm")
    print(f"optional units {sum(c['optional_units'] for c in result['curves'])}, completed passes {sum(c['optional_passes_completed'] for c in result['curves'])}, ready used {sum(c['ready_passes_used'] for c in result['curves'])}, partial deadlines {sum(c['partial_deadlines'] for c in result['curves'])}")


if __name__ == '__main__':
    main()
