# G5/G5.1 test benches

Two benches, both built from the real firmware sources, no copies:

- `host/` - correctness on the PC. `gcode.c`, `motion_control.c`, `planner.c`,
  `nuts_bolts.c` compiled for x86 in single precision with -ffast-math; every
  segment that reaches `plan_buffer_line` is checked against an independent
  double model. `make -C tb/host test`, `tb/host/mutate.sh`.
- `avr/` - the same sources for ATmega328P with the firmware flags, run under
  simavr in CI for every compiler of the matrix: cycle counts, stack use, and
  whether the AVR emits the same segments as the host (`lines.txt`). The
  `dump` build prints every AVR segment target, `tb --dump` checks them
  against the host model.

Expectations are the specification (LinuxCNC G5/G5.1 semantics plus the
decisions below), not what the current code does. A test that fails on a
known open defect is tagged `@bug` and reported as XFAIL; when it starts to
pass it is reported as XPASS so the tag gets removed. Keep `@bug` tests
minimal: every failure inside one is expected, so an unrelated regression in
the same test goes unseen (mutation testing found exactly that once).

Decisions that tests encode:
- Only I or only J on a continuation G5: the missing one is 0 (permissive,
  like G1/G2/G3; the LinuxCNC rule requiring both is not adopted).
- Implicit I/J of a continuation are the negated P/Q of the previous G5, as
  in LinuxCNC. grblHAL negates the P/Q of the current block instead.
  As in LinuxCNC, non-motion lines (G4, G28, G92, rejected lines) do not end
  the series; soft reset does.

## Catalog

| ID | Test                                                                   | Where                 | Status                                  |
|----|------------------------------------------------------------------------|-----------------------|-----------------------------------------|
| 1  | Inflection on a probed midpoint does not hide the deviation            | host vector           | pass: 0.0029 mm with 276 segments       |
| 2  | Long handles stay within the tolerance                                 | host vectors          | pass to 1e5; capped at 2000 segments    |
| 3  | L1 metric: rotated curve within tolerance                              | host vector           | pass                                    |
| 4  | Last segment bit-exact on the parser position under -ffast-math        | avr `end exact`       | pass on all four compilers              |
| 5  | Non-finite or overflowing values never reach the planner               | host vector, avr      | defect, same class as G1 X1e35          |
| 6  | G5/G5.1 without X/Y must not move to machine zero                      | host vectors          | defect                                  |
| 7  | Negative P accepted                                                     | host vectors          | defect (error:4)                        |
| 8  | Rejected line: nothing queued, parser state byte-identical            | host, every line      | defect: spline_pq written early         |
| 9  | Worst-case generation time                                              | avr (2000 segments)   | 2.0 s at the cap of 2000 segments       |
| 10 | Stack on ATmega328P: static chain and with interrupts                   | avr, avr dynamic      | pass: 343 of 403 bytes (7.3)            |
| 11 | Planner starvation while streaming curves at speed                     | avr dynamic           | pass: G5 never starves; G1/G2 do        |
| 12 | Cusp: the planner stops at the reversal                                | host `junction`       | pass                                    |
| 13 | Smooth chain with implicit I/J: no corner at the joins                 | host `set smooth`     | pass                                    |
| 14 | Handles on the chord: same as G1                                        | host vectors          | pass                                    |
| 15 | G5.1 equals G5 with 2/3-rule handles                                    | host `same`           | pass                                    |
| 16 | Quarter circle within the Bezier-circle error                          | host `circle`         | pass                                    |
| 17 | Translation by G91/G92, G20 vs G21: same segments                      | host `same`           | pass                                    |
| 18 | Reversed curve within tolerance                                         | host vector           | pass                                    |
| 19 | Check mode, `$J=G5` rejection, mode changes before implicit I/J        | host vectors          | pass                                    |
| 20 | Mutation testing                                                        | host `mutate.sh`      | 32 of 32 killed                         |
| 21 | Random curves, failures shrunk to a minimal line                       | host `--random`       | pass (negative P skipped, see 7)        |
| 22 | Host vs AVR: same segments                                              | CI simavr `= host`    | G5.1, [1] and G2 differ (see below)     |
| 23 | Compiler vs compiler: same segments                                     | CI simavr per gcc     | G5.1, [1]: 7.3 differs from 15-17       |
| 24 | Denormal, near-zero and coincident handles                             | host vectors          | pass                                    |
| 25 | Command spelling; G5.1 rejected when disabled                          | host, `cubic_only.vec`| pass                                    |
| 26 | Number spelling: P.5, P+5, P5., P1E3, empty P                          | host vectors          | pass; P-.5 is defect 7                  |
| 27 | Forbidden combinations and unused words                                | host vectors          | pass                                    |
| 28 | `$N` startup line with G5                                               | code reading          | same path as any line (system.c:262)    |
| 29 | G93 needs F on every G5 block                                           | host vector           | pass                                    |
| 30 | Modal continuation without the G5 word                                  | host vectors          | pass                                    |
| 31 | Same line from the same point: same segments                           | host `same`           | pass                                    |
| 32 | Machine settings: 1 and 1000 steps/mm, slow axes                       | host `set`            | pass                                    |
| 33 | Tool length offset with G5                                              | host vector           | pass                                    |
| 34 | Realtime latency: worst gap between segments                           | avr `worst gap`       | G5 up to 4.1k cycles (0.26 ms)          |
| 35 | Feed hold and resume mid-curve, exact final position                   | avr dynamic           | pass: 0 steps off in 6 holds            |
| 36 | Soft reset, then the same line: same segments                          | host `reset`          | pass                                    |
| 37 | Differential against grblHAL G5                                         | one-off host run      | segments bit-identical, see below       |
| 38 | LinuxCNC word rules                                                     | host vectors          | pass                                    |
| 39 | G93 time on G5 multiplied by the segment count                         | host vectors          | defect (5.5 min for 0.5)                |
| 40 | Soft limits: curve leaves the envelope between inside endpoints        | host vector           | defect: alarm after 11 segments         |
| 41 | K word rejected in G17                                                  | host vector           | pass                                    |
| 42 | 40-digit literal read as inf                                            | host vector, avr      | defect                                  |
| 43 | Laser mode `$32=1`: G5/G5.1 burn at S like G1                           | host `power`          | defect: power 0 (gcode.c:992)           |
| 44 | Implicit I/J across G20/G21; G54+G92+G20 stacked                        | host `same`           | pass                                    |
| 45 | Out-and-back spike: the tip is reached, nothing overshoots              | host `travel`         | pass                                    |
| 46 | Half-step boundary never steps; curve 60 m from origin                  | host `travel`         | pass                                    |
| 47 | Series lifetime: G4, G28, G92, rejected line, reset, check mode         | host vectors          | pass                                    |
| 48 | G4+G5 share P; G5.1 continuation rules; repeated Q; G93 F0              | host vectors          | pass                                    |
| 49 | AVR segment targets within the tolerance, exact end                    | CI simavr `--dump`    | pass (cap line: as close as the host)   |

## 10, 11, 35: motion under simavr

`avr/dyn.c` runs the real `main()` and `protocol_main_loop()` with the
stepper interrupt live; it plays a send-and-wait-for-ok host inside
`serial_read()` at 115200 baud and injects feed hold and cycle start from
Timer2. simavr does not start the Timer1 CTC with OCR1A = 0, which Grbl
leaves until its first stepper interrupt, so dyn.c presets OCR1A.

- Stack: the firmware with G5+G5.1 has 403 bytes of free RAM. The deepest
  stack is 343 bytes with avr-gcc 7.3 (G5 341, G1 343, G2 343), 338 with
  15.2, 16.2 and 17. It was 446
  for G5 with the adaptive walker, which overran into `sys` at the top of
  .bss; early dyn builds with 416-434 free bytes showed exactly that:
  spurious resets, lost F (error:22), ALARM. The generator now has one call
  site, so it is inlined into `gc_execute_line` like `mc_arc` and shares its
  frame. The static bench: the G5 chain leaves 212 bytes of 574 untouched
  (107 with the walker; 80 of them its own line buffer, which is static in
  the firmware) before any interrupt frame.
- Starvation: 120 programs (G5, G1 along the same chords, G2; 2 and 5 mm;
  F1000-5000; 500 and 2000 mm/s^2; 2 and 16 ms host latency). G5 keeps
  13-14 blocks queued; its speed is limited by chord geometry, not by
  generation. G1 starves at 16 ms latency, G2 on 2 mm arcs from F3000-4000.
  Final position exact in all runs.
- Feed hold at 60-1000 ms into a G5 chain at F3000, resume 400 ms later:
  final position 0 steps off in all six.

## 22, 23: same segments

Every G5 line of `avr/lines.txt` gives the same segments on the host and on
the four compilers, except two: G5.1 and the [1] curve. -ffast-math lets
each compiler reassociate the inlined control point and Horner arithmetic
in its own way (host experiments: dropping -ffast-math or tree vectorization
each moves one of the two hashes onto the avr-gcc 7.3 one). Segment count and the
exact end point are the same everywhere. G2 differs because sin/cos do.
Test 49 checks the differing points themselves: with avr-gcc 7.3 (local
simavr) G5.1 deviates 0.0826 mm and [1] 0.0029 mm, the same as the host to
four decimals.

## 37: grblHAL

grblHAL core 3161cea. Its `mc_cubic_b_spline` is the adaptive walker this
code used before the equal-step generator replaced it (defects 1 and 2 are
that walker's). Before the replacement, extracted unchanged and fed the
control points our parser passes for `host/vectors/g5.vec`, `avr/lines.txt`
and `tb --random 5000 1` (3290 curves), it queued the same segments bit for
bit, compiled with or without -ffast-math.

The parsers differ:
- Implicit I/J, see the decision above. On `g5.vec` 4 of 5 implicit
  continuations get another start control point (up to 6 mm away) and the
  paths separate by up to 2.5 mm.
- grblHAL takes implicit I/J before P/Q are converted from inches, so under
  G20 they are 25.4 times too short.
- Negative P is accepted by grblHAL; defect 7 is ours only.
- Plane other than G17, and G5.1 with I=J=0: grblHAL error:42 and error:39,
  ours error:33.

Shared with grblHAL: defects 6, 8 and 39. Defect 8 has no effect there,
since grblHAL never reads the stored P/Q on the next line.
