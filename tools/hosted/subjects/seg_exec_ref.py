#!/usr/bin/env python3
"""seg_exec_ref.py - reference SEGX/1 executor, registered as a conformance subject.

Part of Grbl / Intelligence assisted / License: MIT

This is a CANDIDATE, not the oracle. It consumes the same .gvec frame stream and
must reproduce the oracle's .gtrace byte for byte; where they disagree, the
oracle (grbl/stepper.c, run by tools/hosted/oracle.c) is right by definition.

It is written from SEGX/1 §3.3 - the contract text - in a different language,
against no shared code with the oracle beyond the vector file itself. That is
the entire point: a transliteration of stepper.c would agree with stepper.c for
the wrong reason. It is also the shape a real far-side executor takes (FPGA RTL,
RP2040 core1), so the things it gets wrong here are the things they get wrong in
silicon. Three of those were found by exactly this route and are called out
inline below, each marked PIPELINE / STALE / LOCK-AFTER.

usage: seg_exec_ref.py <vector.gvec>      -> trace on stdout
"""

import sys

SEGMENT_BUFFER_SIZE = 6
BLOCK_SLOTS = SEGMENT_BUFFER_SIZE - 1
N_AXIS = 3
STEP_BIT = (0, 1, 2)
DIR_BIT = (0, 1, 2)
DIRECTION_MASK = 0x07
SEGX_BLK_FLAG_PWM_RATE_ADJUSTED = 0x01


class Vector:
    def __init__(self):
        self.name = "(unnamed)"
        self.f_tick = 16000000
        self.pulse_ticks = 160
        self.pulse_us = 10
        self.step_invert = 0
        self.dir_invert = 0
        self.invert_st_enable = 0
        self.idle_lock = 25
        self.homing = 0
        self.homing_lock = 0
        self.probe_from_tick = 0
        self.pos0 = [0, 0, 0]
        self.max_ticks = 2000000
        self.blks = {}      # blk_gen -> dict
        self.segs = []


def parse(path):
    v = Vector()
    magic = False
    with open(path) as fh:
        for raw in fh:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            kw = parts[0]
            if kw == "gvec":
                if int(parts[1]) != 1:
                    sys.exit("seg_exec_ref: bad gvec version")
                magic = True
            elif kw == "name":
                v.name = " ".join(parts[1:])
            elif kw == "f_tick":
                v.f_tick = int(parts[1], 0)
            elif kw == "pulse_ticks":
                v.pulse_ticks = int(parts[1], 0)
            elif kw == "pulse_us":
                v.pulse_us = int(parts[1], 0)
            elif kw == "step_invert":
                v.step_invert = int(parts[1], 0)
            elif kw == "dir_invert":
                v.dir_invert = int(parts[1], 0)
            elif kw == "invert_st_enable":
                v.invert_st_enable = int(parts[1], 0)
            elif kw == "idle_lock":
                v.idle_lock = int(parts[1], 0)
            elif kw == "homing":
                v.homing = int(parts[1], 0)
            elif kw == "homing_lock":
                v.homing_lock = int(parts[1], 0)
            elif kw == "probe_from_tick":
                v.probe_from_tick = int(parts[1], 0)
            elif kw == "max_ticks":
                v.max_ticks = int(parts[1], 0)
            elif kw == "pos":
                v.pos0 = [int(x, 0) for x in parts[1:4]]
            elif kw == "blk":
                gen = int(parts[1], 0)
                v.blks[gen] = dict(
                    gen=gen,
                    steps=[int(parts[2], 0), int(parts[3], 0), int(parts[4], 0)],
                    sec=int(parts[5], 0),
                    dir_bits=int(parts[6], 0),
                    flags=int(parts[7], 0))
            elif kw == "seg":
                v.segs.append(dict(
                    n_step=int(parts[1], 0) & 0xffff,
                    cpt=int(parts[2], 0) & 0xffff,
                    gen=int(parts[3], 0) & 0xff,
                    amass=int(parts[4], 0) & 0xff,
                    pwm=int(parts[5], 0) & 0xff))
            else:
                sys.exit("seg_exec_ref: unknown keyword %r" % kw)
    if not magic:
        sys.exit("seg_exec_ref: missing 'gvec 1' header")
    return v


def pin_mask(axis_mask):
    """settings $2/$3 are AXIS bit masks; the port masks are pin positions.
    In the hosted/canonical map (SEGX/1 CONFIG) the two coincide, but the
    distinction is real on a board and is kept explicit here."""
    m = 0
    for axis in range(N_AXIS):
        if axis_mask & (1 << axis):
            m |= 1 << axis
    return m


def run(v, out):
    step_invert = pin_mask(v.step_invert)
    dir_invert = pin_mask(v.dir_invert)
    homing_lock = v.homing_lock if v.homing else 0xff

    # Ring, driven exactly as the host drives it: fill the slot head points at,
    # then move head to next_head. W=5 = the ring's usable depth, not a knob.
    ring = [None] * SEGMENT_BUFFER_SIZE
    blocks = {}
    head, tail, next_head, fill_slot = 0, 0, 1, 0
    pending = 0

    # Executor state (persists ACROSS segments within a block - §3.3).
    counter = [0, 0, 0]
    steps = [0, 0, 0]
    exec_slot = None          # last-seen block slot; None = "no block yet"
    exec_block = None
    exec_seg = None
    step_count = 0
    period = 0
    pwm = 0
    # PIPELINE: the port bits emitted at tick k are the ones COMPUTED at tick
    # k-1. st_wake_up() seeds step_outbits with the invert mask so the first
    # tick cannot pulse. An executor that emits its own tick's result is one
    # tick early on every edge in every trace.
    step_outbits = step_invert
    dir_outbits = dir_invert

    port_step = step_invert
    port_dir = dir_invert
    pos = list(v.pos0)
    probe_pos = [0, 0, 0]
    probe_armed = v.probe_from_tick != 0
    probe_tick = 0
    idle_called = 0

    out.append("# gtrace/1")
    out.append("V %s" % v.name)
    out.append("C f_tick=%d pulse_ticks=%d step_invert=0x%02x dir_invert=0x%02x "
               "rest_step=0x%02x rest_dir=0x%02x homing=%d homing_lock=0x%02x"
               % (v.f_tick, v.pulse_ticks, v.step_invert, v.dir_invert,
                  step_invert, dir_invert, v.homing, homing_lock))

    clk = 0
    tick = 0
    while True:
        while pending < len(v.segs) and tail != next_head:
            s = v.segs[pending]
            if s["gen"] not in blocks:
                b = v.blks[s["gen"]]
                blocks[s["gen"] % BLOCK_SLOTS] = b     # F1, and gen -> slot
                blocks[s["gen"]] = b
            ring[fill_slot] = s
            head = next_head
            fill_slot = next_head
            next_head = (next_head + 1) % SEGMENT_BUFFER_SIZE
            pending += 1

        if v.probe_from_tick and tick + 1 >= v.probe_from_tick:
            probe_pin = True
        else:
            probe_pin = False

        cycle_stop = False
        tick += 1

        # --- the tick ------------------------------------------------------
        port_dir = dir_outbits & DIRECTION_MASK
        port_step = step_outbits

        if exec_seg is None:
            if head != tail:
                exec_seg = ring[tail]
                period = exec_seg["cpt"]
                step_count = exec_seg["n_step"]
                slot = exec_seg["gen"] % BLOCK_SLOTS
                if exec_slot != slot:
                    exec_slot = slot
                    exec_block = blocks[slot]
                    init = exec_block["sec"] >> 1
                    counter = [init, init, init]
                dir_outbits = exec_block["dir_bits"] ^ dir_invert
                steps = [x >> exec_seg["amass"] for x in exec_block["steps"]]
                pwm = exec_seg["pwm"]
            else:
                # STALE: the drain path reads exec_block, which is whatever the
                # LAST block was - it is never cleared. Reproduce that, do not
                # "fix" it (stepper.c:404; the same read is a live NULL hazard
                # in stock before the first block, SEGMENT-RUNTIME-PLAN §3.5 R3).
                idle_called = 1
                if exec_block is not None and \
                   (exec_block["flags"] & SEGX_BLK_FLAG_PWM_RATE_ADJUSTED):
                    pwm = 0
                cycle_stop = True

        if not cycle_stop:
            if probe_armed and probe_pin:
                probe_armed = False
                probe_pos = list(pos)
                probe_tick = tick

            step_outbits = 0
            for axis in range(N_AXIS):
                counter[axis] += steps[axis]
                if counter[axis] > exec_block["sec"]:      # strict >, stepper.c:427
                    step_outbits |= 1 << STEP_BIT[axis]
                    counter[axis] -= exec_block["sec"]
                    if exec_block["dir_bits"] & (1 << DIR_BIT[axis]):
                        pos[axis] -= 1
                    else:
                        pos[axis] += 1

            # LOCK-AFTER: the homing lock gates the PULSE only, and only after
            # the counter/position update - locked axes keep counting (§3.3).
            if v.homing:
                step_outbits &= homing_lock

            step_count = (step_count - 1) & 0xffff
            if step_count == 0:
                exec_seg = None
                tail = (tail + 1) % SEGMENT_BUFFER_SIZE
            step_outbits ^= step_invert

        out.append("T %d %d %d 0x%02x 0x%02x %d %d %d %d"
                   % (tick, clk, period, port_dir, port_step, pwm,
                      pos[0], pos[1], pos[2]))
        if probe_tick == tick:
            out.append("X %d %d PROBE %d %d %d"
                       % (tick, clk, probe_pos[0], probe_pos[1], probe_pos[2]))
        if cycle_stop:
            out.append("X %d %d DRAIN pwm=%d idle=%d" % (tick, clk, pwm, idle_called))
            clk += period + 1
            break
        clk += period + 1
        if tick >= v.max_ticks:
            out.append("X %d %d TICK_LIMIT" % (tick, clk))
            break

    out.append("Z ticks=%d clk=%d pos=%d,%d,%d probe=%d,%d,%d probe_tick=%d"
               % (tick, clk, pos[0], pos[1], pos[2],
                  probe_pos[0], probe_pos[1], probe_pos[2], probe_tick))


def main(argv):
    if len(argv) != 2:
        sys.exit("usage: seg_exec_ref.py <vector.gvec>")
    v = parse(argv[1])
    out = []
    run(v, out)
    sys.stdout.write("\n".join(out) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
