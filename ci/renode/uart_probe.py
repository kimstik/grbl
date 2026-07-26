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

With --spindle, runs the BUG #22 register-observability stage: sends a
handful of M3 S-words chosen STRICTLY INSIDE the linear part of the port's
own $30 (rpm_max)/$31 (rpm_min) range (never at/above the rpm_max clamp -
that clamp is exactly what let BUG #22 hide behind the original probe's
M3 S1000, which never touched pwm_gradient), then reads TCC0's CC[0]
register back over the Renode monitor (ci/renode/SAMD21_TCC.cs makes that
register observable; it used to be an unmodeled Tag that always read 0).
The expected duty for each S-word is computed independently in Python from
spindle_control.c's own formula (see expected_pwm_value()), fed by the
live $30/$31 values read back from "$$", the board's own
SPINDLE_PWM_MIN_VALUE #define (grbl/platform/samd21/<board>/config.h), and
- deliberately NOT the board's SPINDLE_PWM_MAX_VALUE #define, since a wrong
value there *was* BUG #22 and trusting it would make the oracle agree with
a still-broken build - TCC0's own PER register read back live (fixed to
0xFF by PWM_INIT() regardless of what a board declares). Nothing here is a
hardcoded magic duty number. A BUG #22-class regression (wrong
SPINDLE_PWM_MAX_VALUE feeding pwm_gradient) makes firmware's CC[0] diverge
from the PER-anchored expectation.

Exit codes:
  0 - all requested stages passed
  1 - banner never appeared (hang analysis printed if monitor reachable)
  2 - banner seen but "$$" produced no settings output
  4 - motion stage failed (no status reports, or MPos X frozen/incomplete)
  5 - arc/dwell stage failed (NaN, no arc interpolation, wrong endpoint,
      or never returned to Idle)
  6 - spindle stage failed (CC[0] didn't match the computed expected duty
      for at least one S-word)
"""

import argparse
import math
import re
import socket
import struct
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
# $30 (rpm_max) / $31 (rpm_min) lines in a "$$" settings dump.
RPM_MAX_RE = re.compile(rb"\$30=([0-9.]+)")
RPM_MIN_RE = re.compile(rb"\$31=([0-9.]+)")

# TCC0 register offsets, matching grbl/platform/samd21/samd21.h's Tcc struct
# (also ci/renode/SAMD21_TCC.cs, which backs sysbus.tcc0).
TCC0_PER_OFFSET = 0x4C
TCC0_CC0_OFFSET = 0x50


def f32(x):
    """Round a Python (double) float down to IEEE-754 single precision,
    matching the port's GRBL_FP_SINGLE build (floor -> floorf, float
    settings.rpm_max/rpm_min, float pwm_gradient - see
    grbl/platform/samd21/megarm/prelude.h and spindle_control.c)."""
    return struct.unpack("<f", struct.pack("<f", float(x)))[0]


def expected_pwm_value(rpm, rpm_max, rpm_min, pwm_max_value, pwm_min_value):
    """Bit-for-bit port of spindle_control.c's spindle_compute_pwm_value(),
    single-precision arithmetic throughout (f32 at each step, mirroring
    floorf/float ops), so the SPINDLE stage's expectation comes from the
    firmware's own formula rather than a hardcoded duty number. Assumes the
    default 100% spindle_speed_ovr (rpm *= 0.010*ovr collapses to rpm).

    spindle_speed_ovr multiplier and the uint8_t assignment's mod-256
    truncation are both reproduced (the latter is what a BUG #22-class
    huge pwm_gradient wraps through - see pwm_sim.c in the BUG #22
    investigation for the same wraparound model)."""
    rpm_max = f32(rpm_max)
    rpm_min = f32(rpm_min)
    if rpm_min >= rpm_max or rpm >= rpm_max:
        return pwm_max_value & 0xFF
    if rpm <= rpm_min:
        return 0 if rpm == 0.0 else (pwm_min_value & 0xFF)
    pwm_range = f32(pwm_max_value - pwm_min_value)
    gradient = f32(pwm_range / f32(rpm_max - rpm_min))
    diff = f32(rpm - rpm_min)
    term = f32(diff * gradient)
    value = math.floor(term) + pwm_min_value
    return int(value) & 0xFF


def parse_define(text, name):
    m = re.search(r"#define\s+" + re.escape(name) + r"\s+(\d+)", text)
    if not m:
        raise RuntimeError(f"{name} not found in board config.h")
    return int(m.group(1))


def read_double_word(mon, peripheral, offset, wait=0.3):
    """Read a 32-bit register from a peripheral over the Renode monitor
    (e.g. 'sysbus.tcc0'). Assumes the emulation is currently paused."""
    text = monitor_cmd(mon, f"{peripheral} ReadDoubleWord {offset}", wait=wait)
    matches = re.findall(r"0x[0-9A-Fa-f]+", text)
    if not matches:
        raise RuntimeError(
            f"no value returned reading {peripheral}+{offset:#x}: {text!r}")
    # The command echo itself contains the offset (e.g. "0x50"); the actual
    # register value is whatever the monitor prints last.
    return int(matches[-1], 16)


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


def spindle_stage(uart, mon, transcript, timeout, board_config_path):
    """THE BUG #22 REGISTER-OBSERVABILITY STAGE.

    Deliberately does NOT trust the board's SPINDLE_PWM_MAX_VALUE #define
    for the expected-duty computation: that #define declaring the wrong
    value (65535 instead of 255) *was* BUG #22, so an oracle built from the
    same header would trivially "match" a build that still has the bug -
    firmware and test would both compute pwm_gradient from the same wrong
    constant and agree with each other while being wrong together. Instead,
    the oracle's full-scale value is TCC0's own PER register, read back
    live over the Renode monitor before any spindle command - PER is set
    unconditionally to 0xFF by PWM_INIT() (samd21/timer.h) regardless of
    what SPINDLE_PWM_MAX_VALUE a board declares, so it is the actual
    hardware duty domain, independent of the bug. SPINDLE_PWM_MIN_VALUE
    IS read from the board's config.h - it was never the wrong value in
    BUG #22 (every samd21 board consistently declares 1) and has no
    register-level equivalent to observe instead.

    The live $30 (rpm_max)/$31 (rpm_min) come out of the "$$" dump already
    sitting in `transcript`. For a handful of S-words chosen STRICTLY
    inside (rpm_min, rpm_max) - never at/above the rpm_max clamp, which is
    what let the original BUG #22 probe (M3 S1000) miss the bug entirely -
    this sends M3 S<word>, pauses the emulation, reads TCC0 CC[0] back over
    the Renode monitor, and compares it against expected_pwm_value()'s
    independent re-derivation of spindle_control.c's own formula. Returns
    (ok, rows) where rows is a list of (s_word, expected, observed) for the
    report table.
    """
    with open(board_config_path, "r") as f:
        config_text = f.read()
    pwm_min_value = parse_define(config_text, "SPINDLE_PWM_MIN_VALUE")

    monitor_cmd(mon, "pause", wait=0.3)
    pwm_max_value = read_double_word(mon, "sysbus.tcc0", TCC0_PER_OFFSET)
    monitor_cmd(mon, "start", wait=0.3)

    m_max = RPM_MAX_RE.search(transcript)
    m_min = RPM_MIN_RE.search(transcript)
    if not m_max or not m_min:
        print("FAIL: spindle - could not find $30/$31 in the '$$' dump",
              flush=True)
        return False, []
    rpm_max = float(m_max.group(1))
    rpm_min = float(m_min.group(1))
    print(f"spindle: hardware TCC0 PER (full-scale oracle)={pwm_max_value} "
          f"board config {board_config_path} -> "
          f"SPINDLE_PWM_MIN_VALUE={pwm_min_value}; live $30={rpm_max} "
          f"$31={rpm_min}", flush=True)

    # Fractions strictly inside (0, 1) of the rpm_min..rpm_max span - never
    # at or above rpm_max, so pwm_gradient is always actually exercised
    # (the rpm>=rpm_max clamp branch, which never touches pwm_gradient, is
    # exactly what hid BUG #22 from the original M3 S1000 probe).
    fractions = [0.10, 0.25, 0.50, 0.75, 0.90]
    rows = []
    ok = True
    for frac in fractions:
        s_word = rpm_min + frac * (rpm_max - rpm_min)
        s_word = round(s_word)
        expected = expected_pwm_value(float(s_word), rpm_max, rpm_min,
                                       pwm_max_value, pwm_min_value)

        if not send_and_wait_ok(uart, f"M3 S{s_word}".encode(), transcript,
                                 timeout):
            print(f"FAIL: spindle - no 'ok' for M3 S{s_word}", flush=True)
            return False, rows

        monitor_cmd(mon, "pause", wait=0.3)
        observed = read_double_word(mon, "sysbus.tcc0", TCC0_CC0_OFFSET)
        per = read_double_word(mon, "sysbus.tcc0", TCC0_PER_OFFSET)
        monitor_cmd(mon, "start", wait=0.3)

        match = observed == expected
        ok = ok and match
        rows.append((s_word, expected, observed))
        status = "match" if match else "MISMATCH"
        print(f"spindle: S{s_word:<6.0f} expected CC[0]={expected:3d} "
              f"observed CC[0]={observed:3d} PER={per} [{status}]",
              flush=True)

    if not send_and_wait_ok(uart, b"M5", transcript, timeout):
        print("FAIL: spindle - no 'ok' for M5", flush=True)
        return False, rows

    if ok:
        print("PASS: spindle - CC[0] matched the computed expected duty "
              "for every S-word", flush=True)
    else:
        print("FAIL: spindle - CC[0] did not match the computed expected "
              "duty for at least one S-word (BUG #22 class)", flush=True)
    return ok, rows


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
    ap.add_argument("--spindle", action="store_true",
                    help="after $$, run the BUG #22 register-observability "
                         "stage: M3 S-words inside the linear rpm range, "
                         "TCC0 CC[0] checked against spindle_control.c's "
                         "own formula")
    ap.add_argument("--spindle-timeout", type=float, default=30.0)
    ap.add_argument("--board", default="megarm",
                    help="samd21 board directory to read "
                         "SPINDLE_PWM_MAX_VALUE/MIN_VALUE from "
                         "(grbl/platform/samd21/<board>/config.h)")
    ap.add_argument("--board-config", default=None,
                    help="explicit path to the board config.h, overrides "
                         "--board")
    ap.add_argument("--transcript", default=None,
                    help="write raw UART transcript to this file")
    args = ap.parse_args()
    if args.arc:
        args.motion = True
    board_config_path = (args.board_config or
                          f"grbl/platform/samd21/{args.board}/config.h")

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
                    if args.spindle:
                        mon = connect_retry(args.monitor_port,
                                             time.monotonic() + 30,
                                             "renode monitor")
                        if mon is None:
                            print("FAIL: spindle - could not reach Renode "
                                  "monitor", flush=True)
                            rc = 6
                        else:
                            mon.settimeout(1.0)
                            try:
                                mon.recv(4096)  # drain banner/prompt
                            except socket.timeout:
                                pass
                            spindle_ok, _ = spindle_stage(
                                uart, mon, transcript,
                                args.spindle_timeout, board_config_path)
                            mon.close()
                            if not spindle_ok:
                                rc = 6
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
