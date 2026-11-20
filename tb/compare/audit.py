#!/usr/bin/env python3
"""Independent continuous-polyline audit of emitted G5 XY targets.

Unlike the inexpensive host oracle's reverse vertex test, this checks chord
interiors in both directions. A double de Casteljau reference has a capsule
flatness bound; BVH nearest-segment queries and Lipschitz/convex upper bounds
then enclose the distance between two entire polylines. All arithmetic is
ordinary Python binary64, not outward-rounded interval arithmetic. The result
is a numerical enclosure for these captured controls/targets, not a universal
float32 firmware proof or a physical step-path guarantee.

Usage: audit.py DUMP STRICT_CHECK --budget 0.004
       audit.py --self-test
STRICT_CHECK is the output of tb --dump-strict; it supplies the printed actual
host-parser nets. DUMP is the corresponding raw simavr dump. Their nets must
belong to the same commands. Cross-compiler parser equality is not assumed.
"""
import argparse
import heapq
import math
import pathlib
import re
import struct


def dist2(p, a, b):
    vx, vy = b[0] - a[0], b[1] - a[1]
    den = vx * vx + vy * vy
    t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vy) / den)) if den else 0.0
    return (p[0] - a[0] - t * vx) ** 2 + (p[1] - a[1] - t * vy) ** 2


def mid(a, b):
    return ((a[0] + b[0]) * 0.5, (a[1] + b[1]) * 0.5)


def reference(control, epsilon, limit=100000):
    points = [control[0]]
    pending = [(tuple(control), 0)]
    while pending:
        c, depth = pending.pop()
        if max(dist2(c[1], c[0], c[3]), dist2(c[2], c[0], c[3])) <= epsilon * epsilon:
            points.append(c[3])
            if len(points) > limit:
                raise ValueError("reference subdivision limit reached")
            continue
        if depth == 40:
            raise ValueError("reference depth limit reached")
        p, q, r = mid(c[0], c[1]), mid(c[1], c[2]), mid(c[2], c[3])
        s, t = mid(p, q), mid(q, r)
        u = mid(s, t)
        pending.append(((u, t, r, c[3]), depth + 1))
        pending.append(((c[0], p, s, u), depth + 1))
    return points


class Segments:
    def __init__(self, points):
        if len(points) < 2:
            raise ValueError("polyline needs two points")
        self.lines = list(zip(points, points[1:]))
        self.nodes = []
        self.root = self.build(list(range(len(self.lines))))

    def build(self, ids):
        endpoints = [p for i in ids for p in self.lines[i]]
        box = (min(p[0] for p in endpoints), min(p[1] for p in endpoints),
               max(p[0] for p in endpoints), max(p[1] for p in endpoints))
        index = len(self.nodes)
        self.nodes.append(None)
        if len(ids) <= 8:
            self.nodes[index] = (box, ids, None, None)
        else:
            axis = int(box[3] - box[1] > box[2] - box[0])
            ids.sort(key=lambda i: self.lines[i][0][axis] + self.lines[i][1][axis])
            at = len(ids) // 2
            left, right = self.build(ids[:at]), self.build(ids[at:])
            self.nodes[index] = (box, None, left, right)
        return index

    def near(self, p):
        best, which = float("inf"), 0
        pending = [(0.0, self.root)]
        while pending:
            bound, i = heapq.heappop(pending)
            if bound >= best:
                continue
            box, ids, left, right = self.nodes[i]
            if ids is not None:
                for j in ids:
                    d = dist2(p, *self.lines[j])
                    if d < best:
                        best, which = d, j
            else:
                for child in (left, right):
                    b = self.nodes[child][0]
                    dx = max(b[0] - p[0], 0.0, p[0] - b[2])
                    dy = max(b[1] - p[1], 0.0, p[1] - b[3])
                    d = dx * dx + dy * dy
                    if d < best:
                        heapq.heappush(pending, (d, child))
        return math.sqrt(best), which


def directed(source, target, epsilon, limit=200000):
    tree = Segments(target)
    heap = []
    serial = 0
    lower = 0.0
    queries = 0

    def add(a, b, qa=None, qb=None):
        nonlocal lower, serial, queries
        if qa is None:
            qa = tree.near(a)
            queries += 1
        if qb is None:
            qb = tree.near(b)
            queries += 1
        m = mid(a, b)
        qm = tree.near(m)
        queries += 1
        low = max(qa[0], qb[0], qm[0])
        lower = max(lower, low)
        # Every point is within one quarter of the chord length of a sample.
        upper = low + math.hypot(b[0] - a[0], b[1] - a[1]) * 0.25
        # Distance to one convex target segment is convex on this source chord.
        # Any chosen target segment therefore gives a second valid upper bound.
        for j in {qa[1], qb[1], qm[1]}:
            line = tree.lines[j]
            upper = min(upper, math.sqrt(max(dist2(a, *line), dist2(b, *line))))
        upper = max(upper, low)  # Protect heap invariants against binary64 noise.
        serial += 1
        heapq.heappush(heap, (-upper, serial, a, b, qa, qb, qm))

    for a, b in zip(source, source[1:]):
        add(a, b)
    iterations = 0
    while heap and -heap[0][0] > lower + epsilon:
        if iterations == limit:
            raise ValueError("distance refinement limit reached")
        _, _, a, b, qa, qb, qm = heapq.heappop(heap)
        m = mid(a, b)
        if m == a or m == b:
            raise ValueError("distance refinement stopped making numerical progress")
        add(a, m, qa, qm)
        add(m, b, qm, qb)
        iterations += 1
    return lower, max(lower, -heap[0][0]), queries


def audit(control, points, budget):
    if len(control) != 4 or not points or not all(math.isfinite(v) for p in (*control, *points) for v in p):
        raise ValueError("missing or non-finite controls/targets")
    eps = budget / 128.0
    # No reliance on the firmware's Horner coefficients, segment count or t list.
    ref = reference(control, eps)
    actual = [control[0], *points]
    forward = directed(ref, actual, eps)
    reverse = directed(actual, ref, eps)
    lower = max(0.0, max(forward[0], reverse[0]) - eps)
    upper = max(forward[1], reverse[1]) + eps
    return lower, upper, len(ref) - 1, forward[2] + reverse[2]


def clean(text):
    text = re.sub(r"\x1b\[[0-9;]*m", "", text)
    return [line.strip().rstrip(".") for line in text.splitlines()]


def inputs(dump, check):
    nets = {}
    net = None
    footer = None
    for line in clean(pathlib.Path(check).read_text(errors="replace")):
        match = re.fullmatch(r"dump: (\d+) curves, (\d+) failed", line)
        if match:
            footer = tuple(map(int, match.groups()))
        if line.startswith("net "):
            # %.9g round-trips a binary32 value; restore that exact value before
            # converting it to binary64, instead of retaining its decimal print.
            net = [tuple(struct.unpack("<f", struct.pack("<f", float(v)))[0] for v in pair)
                   for pair in re.findall(r"\(([^,()]+),([^,()]+)\)", line)]
            if len(net) != 4:
                raise ValueError("malformed captured control net")
        elif " host " in line and net is not None:
            name = line.split(" host ", 1)[0]
            if name in nets:
                raise ValueError("duplicate command in strict check")
            nets[name] = net
            net = None
    points = {}
    current = None
    for line in clean(pathlib.Path(dump).read_text(errors="replace")):
        if line in nets:
            if line in points:
                raise ValueError("duplicate command in dump")
            current = line
            points[current] = []
        elif line.startswith("p ") and current is not None:
            words = line.split()
            if len(words) < 4:
                raise ValueError("malformed target record")
            values = [struct.unpack("<f", struct.pack("<I", int(v)))[0] for v in words[1:4]]
            if not all(math.isfinite(v) for v in values):
                raise ValueError("non-finite target")
            points[current].append(tuple(values[:2]))
        elif line.startswith("G"):
            current = None
    if not nets or nets.keys() != points.keys():
        raise ValueError("strict check and dump do not name the same curves")
    if footer != (len(nets), 0):
        raise ValueError("strict check is incomplete or contains failed curves")
    for name, net in nets.items():
        yield name, net, points[name]


def self_test():
    straight = [(0.0, 0.0), (0.25, 0.0), (0.75, 0.0), (1.0, 0.0)]
    lo, hi, _, _ = audit(straight, [(1.0, 0.0)], 0.01)
    assert lo == 0 and hi < 0.001, (lo, hi)
    lo, hi, _ = directed([(0.0, 0.0), (1.0, 0.0)], [(0.0, 0.2), (1.0, 0.2)], 1e-5)
    assert abs(lo - 0.2) < 1e-12 and abs(hi - 0.2) < 1e-12, (lo, hi)
    # Every chord endpoint lies on the target polyline, but the chord shortcuts
    # across its interior. A reverse-vertices-only test would return zero.
    lo, hi, _ = directed([(0.0, 0.0), (2.0, 0.0)],
                         [(0.0, 0.0), (1.0, 1.0), (2.0, 0.0)], 1e-5)
    assert abs(lo - math.sqrt(0.5)) < 1e-5 and hi - lo <= 1e-5, (lo, hi)
    cusp = [(0.0, 0.0), (10.0, 0.0), (10.0, 0.0), (0.0, 0.0)]
    ref = reference(cusp, 1e-4)
    assert max(p[0] for p in ref) == 7.5
    bowed = [(0.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, 0.0)]
    lo, hi, _, _ = audit(bowed, [(1.0, 0.0)], 0.01)
    assert lo > 0.74 and hi < 0.76, (lo, hi)
    point = [(2.0, 3.0)] * 4
    lo, hi, _, _ = audit(point, [(2.0, 3.0)], 0.01)
    assert lo == 0 and hi < 0.001, (lo, hi)
    print("polyline audit: 6 self-tests passed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", nargs="?")
    parser.add_argument("check", nargs="?")
    parser.add_argument("--budget", type=float)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.dump or not args.check or not args.budget or not math.isfinite(args.budget) or args.budget <= 0:
        parser.error("DUMP, STRICT_CHECK and a positive finite --budget are required")
    failed = 0
    count = 0
    try:
        for name, control, points in inputs(args.dump, args.check):
            lower, upper, nref, queries = audit(control, points, args.budget)
            state = "PASS" if upper <= args.budget else "FAIL" if lower > args.budget else "UNRESOLVED"
            failed += state != "PASS"
            count += 1
            print("%s lower %.9g upper %.9g budget %.9g ref %d queries %d %s" % (
                name, lower, upper, args.budget, nref, queries, state))
    except ValueError as error:
        raise SystemExit("audit: " + str(error))
    print("audit: %d curves, %d not passed (ordinary double enclosure, not interval proof)" % (count, failed))
    raise SystemExit(bool(failed) or not count)


if __name__ == "__main__":
    main()
