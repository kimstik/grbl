#!/usr/bin/env python3
"""Bounded C/AVR generator comparison on the common parser nets.

Builds fresh isolated generator images, not full firmware. Timed and dump images
are separate. All subprocesses have timeouts and run at idle priority. Host strict
checks are sampled diagnostics, not continuous Hausdorff certificates.
"""
import argparse
import json
import os
from pathlib import Path
import re
import struct
import subprocess


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("simavr", type=Path)
parser.add_argument("--out", type=Path, default=Path(".tmp/circle-fit/common"))
parser.add_argument("--tol", type=float, nargs="+", default=(0.002, 0.01, 0.1))
parser.add_argument("--audit", action="store_true", help="also bound both complete polylines with audit.py")
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
out = (root / args.out).resolve()
out.mkdir(parents=True, exist_ok=True)
env = os.environ.copy()
env["PATH"] = os.pathsep.join(("C:/Program Files (x86)/Arduino/hardware/tools/avr/bin",
                               "C:/msys64/mingw64/bin", env["PATH"]))


def run(argv, seconds=120, log=None):
    kw = dict(cwd=root, env=env, capture_output=True, text=True, timeout=seconds)
    if os.name == "nt":
        kw["creationflags"] = subprocess.IDLE_PRIORITY_CLASS
    else:
        argv = ["nice", "-n", "19", *argv]
    r = subprocess.run([str(x) for x in argv], **kw)
    text = re.sub(r"\x1b\[[0-9;]*m", "", r.stdout + r.stderr)
    text = re.sub(r"\.+$", "", text, flags=re.M)
    if log:
        Path(log).write_text(text, encoding="utf-8")
    if r.returncode:
        raise RuntimeError(f"exit {r.returncode}: {' '.join(str(x) for x in argv)}\n{text[-3000:]}")
    return text


def bits(x):
    return struct.unpack("<I", struct.pack("<f", float(x)))[0]


def literal(x):
    # Nine significant decimal digits reproduce a float32 round trip.
    return f"{float(x):.9e}f"


summary = []
for corpus in ("core", "stress"):
    lines = out / f"{corpus}.txt"
    run(["python", "-I", root / "tb/compare/render.py", root / f"tb/compare/{corpus}.in", lines])
    commands = [x[1:] for x in lines.read_text().splitlines() if x.startswith("*")]
    # Capture one canonical net, using the real host parser, once per corpus.
    build = f"build/capture-{corpus}"
    run(["make", "-s", "-C", "tb/host", f"BUILD={build}", "OPT=-DBEZIER_SIGMA=.004f -DTB_ARC_TOLERANCE=.002f -DTB_XY_BUDGET=.004f"])
    host = root / "tb/host" / build / "tb"
    dump = out / f"{corpus}-capture.txt"
    run([host, "--host-dump", lines], log=dump)
    captured = run([host, "--dump-strict", lines, dump], log=out / f"{corpus}-capture-check.txt")
    nets = []
    for row in captured.splitlines():
        if row.startswith("net "):
            pts = re.findall(r"\(([^,]+),([^\)]+)\)", row)
            nets.append([(float(x), float(y)) for x, y in pts])
    if len(nets) != len(commands):
        raise RuntimeError("missing actual parser net")
    if any(p[0] != (0.0, 0.0) for p in nets):
        raise RuntimeError("micro requires each common case to restart at origin")
    header = out / f"{corpus}-nets.h"
    header.write_text("static const float nets[][6] PROGMEM = {\n" + "\n".join(
        "  {" + ",".join(literal(v) for point in net[1:] for v in point) + "},"
        for net in nets) + "\n};\n", encoding="utf-8")
    for tol in args.tol:
        tag = f"{corpus}-{tol:g}"
        for gen in ("wang", "circle"):
            opt = f"-DBEZIER_SIGMA={2*tol:.9g}f" if gen == "wang" else "-DBEZIER_CIRCLE_FIT"
            defs = ("-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES " + opt +
                    f" -DTB_ARC_TOLERANCE={tol:.9g}f -DTB_XY_BUDGET={2*tol:.9g}f")
            hbuild = f"build/common-{tag}-{gen}"
            run(["make", "-s", "-C", "tb/host", f"BUILD={hbuild}", f"OPT={defs}"])
            hbin = root / "tb/host" / hbuild / "tb"
            hdump = out / f"{tag}-{gen}-host.txt"
            run([hbin, "--host-dump", lines], log=hdump)
            hcheck = run([hbin, "--dump-strict", lines, hdump], log=out / f"{tag}-{gen}-host-check.txt")
            herrors = [float(x) for x in re.findall(r" avr \d+ ([0-9.eE+-]+)", hcheck)]
            inc = f'-DTB_MICRO_NETS={header.as_posix()}'
            builds = {}
            for mode in ("timed", "dump"):
                b = f"build/common-{tag}-{gen}-{mode}"
                define = defs + " " + inc + (" -DTB_MICRO_DUMP" if mode == "dump" else "")
                buildlog = run(["make", "-s", "-C", "tb/avr", f"BUILD={b}", f"DEFS={define}", "micro"],
                               log=out / f"{tag}-{gen}-{mode}-build.txt")
                elf = root / "tb/avr" / b / "micro.elf"
                raw = run([args.simavr, "-m", "atmega328p", "-f", "16000000", elf], seconds=240,
                          log=out / f"{tag}-{gen}-{mode}.txt")
                if not re.search(r"^done$", raw, flags=re.M):
                    raise RuntimeError("simulator did not finish")
                builds[mode] = raw
            converted = []
            case = 0
            points = []
            timed = [list(map(int, row.split()[1:])) for row in builds["timed"].splitlines() if row.startswith("case ")]
            for row in builds["dump"].splitlines():
                if row.startswith("p "):
                    points.append(row)
                elif row.startswith("case "):
                    fields = list(map(int, row.split()[1:]))
                    if fields[0] != case or fields[2] != len(points):
                        raise RuntimeError("micro dump case/count mismatch")
                    # Preserve all setup lines in source order for the strict host parser.
                    case += 1
                    points = []
            if case != len(commands):
                raise RuntimeError("micro dump is incomplete")
            groups = []
            points = []
            for row in builds["dump"].splitlines():
                if row.startswith("p "):
                    points.append(row)
                elif row.startswith("case "):
                    groups.append((points, int(row.split()[2])))
                    points = []
            k = 0
            for line in lines.read_text().splitlines():
                if not line or line.startswith("#"):
                    continue
                measured = line.startswith("*")
                converted.append(line[1:] if measured else line)
                if measured:
                    pts, status = groups[k]
                    converted.extend(pts)
                    converted.append(f" {status}")
                    k += 1
            adump = out / f"{tag}-{gen}-avr.txt"
            adump.write_text("\n".join(converted) + "\n", encoding="utf-8")
            check_path = out / f"{tag}-{gen}-avr-check.txt"
            check = run([hbin, "--dump-strict", lines, adump], log=check_path)
            if args.audit:
                run(["python", "-I", root / "tb/compare/audit.py", adump, check_path,
                     "--budget", str(2*tol)], log=out / f"{tag}-{gen}-audit.txt")
            errors = [float(x) for x in re.findall(r" avr \d+ ([0-9.eE+-]+)", check)]
            if len(errors) != len(nets):
                raise RuntimeError("missing strict measured curve")
            summary.append(dict(corpus=corpus, tol=tol, generator=gen, nets=nets,
                                host_error=herrors, avr_error=errors, micro_columns="case status chords total dry first gap hash endpoint realtime untouched",
                                micro=timed))
            (out / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
            print(f"{tag} {gen}: {len(errors)} curves, max XY {max(errors)/tol:.5f} tol, "
                  f"chords {sum(x[2] for x in timed)}, cycles {sum(x[3] for x in timed)}", flush=True)
