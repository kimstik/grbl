# Stepper shutdown observation

`make -C tb/avr observe` builds `build/observe.elf`, a test-only variant of the
real dynamic bench. It does not change any production source. `observe.py`
generates a copy of `grbl/stepper.c` and refuses to build if one of its insertion
anchors is absent or no longer unique.

This is an additional diagnosis, not a replacement for `dyn.elf`:

- The regular dynamic bench is compiled without any observation code.
- The observed build adds per-ring-slot snapshots, RAM, instructions and stack.
  Do not use its depth or throughput as the production firmware measurement.
- The geometry, planner, segment preparation, timer ISR, host pacing and
  realtime protocol still execute as actual firmware, not a numerical model.

## Meaning of the records

The existing `run` and `hold` columns are unchanged. Each is followed by:

```text
observe program empty queued moving max_exit_milli cycles amass
```

| Field            | Meaning                                                      |
|------------------|--------------------------------------------------------------|
| program          | Program number, starting at 1                                |
| empty            | Shutdowns at the empty step-segment branch inside the ISR     |
| queued           | Those shutdowns with a current planner block still present    |
| moving           | Those shutdowns with a nonzero last-segment endpoint speed    |
| max_exit_milli   | Largest such planned endpoint speed, in 0.001 mm/min          |
| cycles           | Timer ticks per ISR in that segment                          |
| amass            | Its AMASS level, or 0 when AMASS is disabled                  |

The observation stores `prep.current_speed` in a separate array **before** the
corresponding `segment_buffer_head` is published. When the ISR finds the ring
empty, the previous tail slot describes the last consumed segment, not the
planner block currently being prepared. Timer period and AMASS level accompany
that snapshot; the period is a segment-average step schedule, not an endpoint
velocity measurement.

A planned end, normal deceleration or completed hold also reaches an empty
buffer. Therefore `empty > 0` is expected. `queued > 0` alone does not establish
the speed at the interruption. `moving > 0` identifies a shutdown whose last
consumed segment was **planned** to finish at nonzero speed. It does not measure
physical motor speed, nor does `moving == 0` prove all individual step pulse
intervals or the mechanical stop are safe. The old `cut_F` remains a planner
block's entry speed, not instantaneous stepper speed.

## Bounded positive and negative controls

Use separate build directories whenever flags change. Examples on a system
with AVR GCC, Python 3.9+ and simavr in PATH:

```sh
make -C tb/avr observe BUILD=build/obs \
  OBSERVE_DEFS=-DTB_OBSERVE_QUICK
simavr -m atmega328p -f 16000000 tb/avr/build/obs/observe.elf > normal.txt 2>&1
python3 tb/avr/check-observe.py normal.txt --no-moving

make -C tb/avr observe BUILD=build/stall \
  OBSERVE_DEFS='-DTB_OBSERVE_QUICK -DTB_OBSERVE_STALL_MS=100'
simavr -m atmega328p -f 16000000 tb/avr/build/stall/observe.elf > stall.txt 2>&1
python3 tb/avr/check-observe.py stall.txt --expect-moving
```

The quick mode runs three programs (G5, G1, G2), 5 mm, F3000, acceleration
2000 mm/s^2, 2 ms host latency, no holds. The stall option waits 100 ms in the
foreground once per program when cycling with at least four planner blocks
queued. ISRs remain enabled, but segment preparation does not run during the
wait. A G1 program may never build up four blocks, so it need not inject a
stall; the positive control requires detection somewhere, not in every program.
A checker failure is not proof of a firmware fault if the control was not
injected; inspect the complete records.

For a full sweep omit `TB_OBSERVE_QUICK`. The normal checker validates complete
records and final XY/hold XYZ positions without assuming no moving shutdowns.
The stronger `--no-moving` assertion must be selected explicitly. Neither a
truncated log nor a missing `done` marker passes the checker.

Local verification on AVR GCC 7.3, ATmega328P/simavr, `$12=0.002`, G5+G5.1 and
Z-by-length enabled:

- Without a stall: all three quick programs have one final ISR shutdown,
  zero `queued`, zero `moving`, final XY error zero steps.
- With the 100 ms stall: G5 and G2 each show one moving shutdown with planner
  blocks queued, planned endpoint speed 3000 mm/min. All final XY errors are
  zero steps, illustrating why the endpoint check alone misses this fault.
- The positive-control assertion rejects the no-stall log.
- The unobserved `dyn.elf` is byte-identical to the same build from `6bff342`.

These are simulator measurements, not hardware results or a proof for arbitrary
curves, settings or interrupt loads.
