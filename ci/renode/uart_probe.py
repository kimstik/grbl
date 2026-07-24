#!/usr/bin/env python3
"""uart_probe.py - drive the GRBL SAMD21 Renode smoke test over TCP.

Connects to the socket terminal Renode exposes for SERCOM3, waits for the
GRBL banner, then (unless --banner-only) sends "$$" and waits for the
settings dump. On banner timeout it interrogates the Renode monitor for the
hang PC and nearest symbol so CI logs capture WHERE the boot stalled.

Exit codes:
  0 - banner seen (and settings seen, unless --banner-only)
  1 - banner never appeared (hang analysis printed if monitor reachable)
  2 - banner seen but "$$" produced no settings output
"""

import argparse
import re
import socket
import sys
import time

BANNER_RE = re.compile(rb"Grbl \d+\.\d+\w*")
# $$ output ends with the last numbered setting; $132 is max-travel Z in 1.1h.
SETTINGS_RE = re.compile(rb"\$132=")


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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--uart-port", type=int, default=3456)
    ap.add_argument("--monitor-port", type=int, default=3457)
    ap.add_argument("--banner-timeout", type=float, default=90.0)
    ap.add_argument("--settings-timeout", type=float, default=60.0)
    ap.add_argument("--banner-only", action="store_true")
    ap.add_argument("--transcript", default=None,
                    help="write raw UART transcript to this file")
    args = ap.parse_args()

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
