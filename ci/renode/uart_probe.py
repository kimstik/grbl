#!/usr/bin/env python3
"""uart_probe.py - drive the GRBL SAMD21 Renode smoke test over TCP.

Connects to the socket terminal Renode exposes for SERCOM3, waits for the
GRBL banner, then (unless --banner-only) sends "$$" and waits for the
settings dump. On banner timeout it interrogates the Renode monitor for the
hang PC and nearest symbol so CI logs capture WHERE the boot stalled.

With --motion, additionally proves the port MOVES: sends G91 + G0 X1 and
polls '?' realtime status reports, asserting MPos X advances from 0.000 and
reaches 1.000 with the machine back in Idle. Position feedback is
sys_position, which only the TC3 stepper ISR increments - X advancing IS
step generation.

With --arc (implies --motion), runs the FP-precision arbiter stage that
CONTRACTS #17 needs: a real G2 arc plus a fractional-second dwell. Arcs are
the heaviest floating-point path in GRBL - mc_arc() calls atan2/sqrt for the
arc geometry and cos/sin for the per-segment rotation matrix, with a full
trig re-correction every N_ARC_CORRECTION segments - so if the FP=SINGLE
libm pin (sqrtf/atan2f/sinf/cosf substituted at the call sites) broke
semantics, this is where it shows up as NaN in the report, a hang, or
position drift. `G4 P0.5` additionally exercises the float-seconds dwell
path (delay_sec -> _delay_ms), which is the only remaining double-typed ABI
boundary in the port.

  G91 (relative) + G2 X2 I1 F200 from (1,0,0): centre (2,0,0), radius 1,
  a clockwise semicircle bulging through (2,+1,0) and ending at (3,0,0).
  Asserted: no NaN/inf anywhere in the reports, Y actually leaves 0 and
  peaks near +1.000 (the arc is really interpolated, not a straight line),
  X ends at 3.000 and Y returns to 0.000, machine back in Idle.

Exit codes:
  0 - all requested stages passed
  1 - banner never appeared (hang analysis printed if monitor reachable)
  2 - banner seen but "$$" produced no settings output
  4 - motion stage failed (no status reports, or MPos X frozen/incomplete)
  5 - arc/dwell stage failed (NaN, no arc interpolation, wrong endpoint,
      or never returned to Idle)
"""

import argparse
import re
import socket
import sys
import time

BANNER_RE = re.compile(rb"Grbl \d+\.\d+\w*")
# $$ output ends with the last numbered setting; $132 is max-travel Z in 1.1h.
SETTINGS_RE = re.compile(rb"\$132=")
# grbl 1.1 realtime report: <Idle|MPos:0.000,0.000,0.000|FS:0,0>
STATUS_RE = re.compile(rb"<(\w+)[^>]*\|MPos:([-0-9.]+),([-0-9.]+),([-0-9.]+)")
OK_RE = re.compile(rb"ok\r?\n")
# A single-precision arc that went wrong prints its wreckage: glibc-style
# "nan"/"-inf" from printFloat, or GRBL's own error/ALARM lines.
NAN_RE = re.compile(rb"(?i)\b(nan|-?inf(inity)?)\b")
ERROR_RE = re.compile(rb"(?i)\b(error:\d+|ALARM:\d+)")


def connect_retry(port, deadline, name):
    while time.monotonic() < deadline:
        try:
            s = socket.create_connection(("127.0.0.1", port), timeout=2)
            s.settimeout(0.25)
            return s
        except OSError:
            time.sleep(0.5)
    print(f"FAIL: could not connect to {name} on port {port}", flush=True)
    return None


def read_until(sock, pattern, deadline, sink):
    """Read from sock into sink (bytearray) until pattern matches or timeout."""
    while time.monotonic() < deadline:
        try:
            chunk = sock.recv(4096)
            if not chunk:
                time.sleep(0.1)
                continue
            sink.extend(chunk)
            if pattern.search(sink):
                return True
        except socket.timeout:
            if pattern.search(sink):
                return True
    return pattern.search(sink) is not None


def monitor_cmd(sock, cmd, wait=1.0):
    sock.sendall(cmd.encode() + b"\n")
    time.sleep(wait)
    out = bytearray()
    try:
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            out.extend(chunk)
    except socket.timeout:
        pass
    # Strip ANSI escapes and telnet control bytes for readable CI logs.
    text = re.sub(rb"\x1b\[[0-9;]*[A-Za-z]", b"", bytes(out))
    text = bytes(b for b in text if b == 10 or b == 13 or 32 <= b < 127)
    return text.decode(errors="replace")


def hang_analysis(mon_port):
    print("--- hang analysis via Renode monitor ---", flush=True)
    deadline = time.monotonic() + 10
    mon = connect_retry(mon_port, deadline, "renode monitor")
    if mon is None:
        return
    with mon:
        mon.settimeout(0.5)
        try:
            mon.recv(4096)  # drain prompt/banner
        except socket.timeout:
            pass
        monitor_cmd(mon, "pause")
        pc_txt = monitor_cmd(mon, "sysbus.cpu PC")
        print("cpu PC =>", pc_txt.strip(), flush=True)
        m = re.search(r"0x[0-9A-Fa-f]+", pc_txt)
        if m:
            sym = monitor_cmd(mon, f"sysbus FindSymbolAt {m.group(0)}")
            print(f"symbol at {m.group(0)} =>", sym.strip(), flush=True)
        regs = monitor_cmd(mon, "sysbus.cpu GetRegistersValues", wait=2.0)
        print(regs, flush=True)


def send_and_wait_ok(sock, line, transcript, timeout):
    """Send one g-code line and wait for a fresh 'ok' after it."""
    mark = len(transcript)
    sock.sendall(line + b"\n")
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            chunk = sock.recv(4096)
            if chunk:
                transcript.extend(chunk)
        except socket.timeout:
            pass
        if OK_RE.search(transcript, mark):
            return True
    return False


def motion_stage(sock, transcript, timeout):
    """G91 + G0 X1 (250 steps at $100=250), then poll '?' until X reaches
    1.000 in Idle. Returns (ok, samples)."""
    if not send_and_wait_ok(sock, b"G91", transcript, 10):
        print("FAIL: no 'ok' for G91", flush=True)
        return False, []
    mark = len(transcript)
    sock.sendall(b"G0 X1\n")

    samples = []          # (state, x) in arrival order, deduplicated
    reached = False
    scan_pos = mark       # parse each report exactly once
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        sock.sendall(b"?")             # realtime command, no newline needed
        time.sleep(0.05)
        try:
            chunk = sock.recv(65536)
            if chunk:
                transcript.extend(chunk)
        except socket.timeout:
            pass
        last = None
        for m in STATUS_RE.finditer(transcript, scan_pos):
            last = m
            state = m.group(1).decode()
            x = float(m.group(2))
            if not samples or samples[-1] != (state, x):
                samples.append((state, x))
        if last is not None:
            scan_pos = last.end()
            state = last.group(1).decode()
            x = float(last.group(2))
            if state == "Idle" and abs(x - 1.0) < 0.0005:
                reached = True
                break

    xs = [x for _, x in samples]
    print("motion samples (state, MPos X):", samples, flush=True)
    if not samples:
        print("FAIL: '?' produced no status reports", flush=True)
        return False, samples
    advanced = any(0.0 < x < 1.0 for x in xs) or (reached and max(xs) >= 1.0)
    monotonic = all(b >= a - 1e-9 for a, b in zip(xs, xs[1:]))
    print(f"motion: reached={reached} advanced={advanced} "
          f"monotonic={monotonic} max_x={max(xs):.3f}", flush=True)
    return reached and advanced and monotonic, samples


def poll_until_idle(sock, transcript, timeout, scan_pos):
    """Send '?' repeatedly, collecting (state, x, y, z) until Idle or timeout.
    Returns (samples, reached_idle, new_scan_pos)."""
    samples = []
    reached_idle = False
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        sock.sendall(b"?")
        time.sleep(0.05)
        try:
            chunk = sock.recv(65536)
            if chunk:
                transcript.extend(chunk)
        except socket.timeout:
            pass
        last = None
        for m in STATUS_RE.finditer(transcript, scan_pos):
            last = m
            sample = (m.group(1).decode(), float(m.group(2)),
                      float(m.group(3)), float(m.group(4)))
            if not samples or samples[-1] != sample:
                samples.append(sample)
        if last is not None:
            scan_pos = last.end()
            if samples and samples[-1][0] == "Idle":
                reached_idle = True
                break
    return samples, reached_idle, scan_pos


def arc_stage(sock, transcript, timeout):
    """THE FP=SINGLE RUNTIME ARBITER (CONTRACTS #17).

    Assumes G91 and the machine parked at (1,0,0) by motion_stage(). Runs
    `G2 X2 I1 F200` - a CW semicircle of radius 1 centred at (2,0,0) - then
    `G4 P0.5`. Arcs are the only core path that touches atan2/sqrt/cos/sin,
    so this is where an incorrect SP libm substitution surfaces.
    """
    mark = len(transcript)
    sock.sendall(b"G2 X2 I1 F200\n")
    samples, idle, scan_pos = poll_until_idle(sock, transcript, timeout, mark)

    print("arc samples (state, X, Y, Z):", samples, flush=True)
    if not samples:
        print("FAIL: arc - '?' produced no status reports", flush=True)
        return False

    tail = bytes(transcript[mark:])
    if NAN_RE.search(tail):
        print("FAIL: arc - NaN/inf in status reports (SP libm produced a "
              "non-finite coordinate)", flush=True)
        return False
    if ERROR_RE.search(tail):
        print("FAIL: arc - GRBL reported error/ALARM: "
              f"{ERROR_RE.search(tail).group(0)!r}", flush=True)
        return False

    xs = [s[1] for s in samples]
    ys = [s[2] for s in samples]
    zs = [s[3] for s in samples]
    x_end, y_end, z_end = samples[-1][1], samples[-1][2], samples[-1][3]

    # Geometry, not just "it finished": Y must actually bulge (a broken
    # rotation matrix would degenerate the arc into the X-only chord) and
    # the peak must sit near the true radius of 1.000.
    y_peak = max(ys)
    interpolated = y_peak > 0.100
    # 0.02 mm = 5 microsteps at $100=250 steps/mm; the arc tolerance
    # ($12=0.002) plus one segment of chord error lives well inside this.
    radius_ok = abs(y_peak - 1.000) < 0.020
    endpoint_ok = (abs(x_end - 3.000) < 0.0005 and
                   abs(y_end - 0.000) < 0.0005 and
                   abs(z_end - 0.000) < 0.0005)
    x_monotonic = all(b >= a - 1e-9 for a, b in zip(xs, xs[1:]))

    print(f"arc: idle={idle} interpolated={interpolated} "
          f"y_peak={y_peak:.3f} (radius_ok={radius_ok}) "
          f"endpoint=({x_end:.3f},{y_end:.3f},{z_end:.3f}) "
          f"endpoint_ok={endpoint_ok} x_monotonic={x_monotonic}", flush=True)
    if not (idle and interpolated and radius_ok and endpoint_ok
            and x_monotonic):
        print("FAIL: arc stage", flush=True)
        return False
    print("PASS: arc - G2 X2 I1 F200 interpolated through Y peak "
          f"{y_peak:.3f} and landed on (3.000,0.000,0.000), Idle",
          flush=True)

    # Float-seconds dwell: delay_sec(0.5) -> _delay_ms across the last
    # double-typed ABI boundary in the port. Must return 'ok', not hang.
    t0 = time.monotonic()
    if not send_and_wait_ok(sock, b"G4 P0.5", transcript, 30):
        print("FAIL: dwell - no 'ok' for G4 P0.5 (float-seconds dwell path "
              "hung)", flush=True)
        return False
    print(f"PASS: dwell - G4 P0.5 acknowledged in "
          f"{time.monotonic() - t0:.2f}s wall", flush=True)

    dwell_samples, dwell_idle, _ = poll_until_idle(sock, transcript, 20,
                                                   len(transcript))
    if not dwell_idle:
        print("FAIL: dwell - machine did not return to Idle", flush=True)
        return False
    print(f"PASS: post-dwell state {dwell_samples[-1]}", flush=True)
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--uart-port", type=int, default=3456)
    ap.add_argument("--monitor-port", type=int, default=3457)
    ap.add_argument("--banner-timeout", type=float, default=90.0)
    ap.add_argument("--settings-timeout", type=float, default=60.0)
    ap.add_argument("--banner-only", action="store_true")
    ap.add_argument("--motion", action="store_true",
                    help="after $$, run the G91/G0 X1 motion stage")
    ap.add_argument("--motion-timeout", type=float, default=60.0)
    ap.add_argument("--arc", action="store_true",
                    help="after the motion stage, run the G2 arc + G4 dwell "
                         "FP-precision arbiter stage (implies --motion)")
    ap.add_argument("--arc-timeout", type=float, default=120.0)
    ap.add_argument("--transcript", default=None,
                    help="write raw UART transcript to this file")
    args = ap.parse_args()
    if args.arc:
        args.motion = True

    transcript = bytearray()
    rc = 1
    uart = connect_retry(args.uart_port,
                         time.monotonic() + 30, "UART socket terminal")
    if uart is None:
        hang_analysis(args.monitor_port)
        return 1

    with uart:
        got_banner = read_until(uart, BANNER_RE,
                                time.monotonic() + args.banner_timeout,
                                transcript)
        if got_banner:
            print("PASS: GRBL banner detected on SERCOM3 UART", flush=True)
            rc = 0
            if not args.banner_only:
                uart.sendall(b"$$\n")
                got_settings = read_until(
                    uart, SETTINGS_RE,
                    time.monotonic() + args.settings_timeout, transcript)
                if got_settings:
                    # allow trailing bytes ("ok") to arrive
                    read_until(uart, re.compile(rb"\$132=.*?ok", re.S),
                               time.monotonic() + 5, transcript)
                    print("PASS: '$$' settings dump received", flush=True)
                    if args.motion:
                        moved, _ = motion_stage(uart, transcript,
                                                args.motion_timeout)
                        if moved:
                            print("PASS: motion - MPos X advanced 0 -> "
                                  "1.000, Idle", flush=True)
                            if args.arc and not arc_stage(
                                    uart, transcript, args.arc_timeout):
                                rc = 5
                        else:
                            print("FAIL: motion stage", flush=True)
                            rc = 4
                else:
                    print("FAIL: no settings output after '$$'", flush=True)
                    rc = 2
        else:
            print("FAIL: GRBL banner not seen within "
                  f"{args.banner_timeout}s", flush=True)

    print("--- UART transcript ({} bytes) ---".format(len(transcript)),
          flush=True)
    sys.stdout.write(transcript.decode(errors="replace"))
    sys.stdout.write("\n--- end transcript ---\n")
    sys.stdout.flush()

    if args.transcript:
        with open(args.transcript, "wb") as f:
            f.write(transcript)

    if rc == 1:
        hang_analysis(args.monitor_port)
    return rc


if __name__ == "__main__":
    sys.exit(main())
