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

## Shared comparison corpus

`compare/core.in` is eight finite curves, each restarted at machine (0,0,0):
S, closed loop, cusp, collinear backtracking, nearly straight, quadratic,
tight global counterexample, and a straight curve with unequal parameter
speed. `stress.in` holds the supplied tall S. `cap.in` holds the 100000 mm
handles; run it both with the normal cap and with a test-only cap of 20000.
`invalid.in` is separate: non-finite input is not a performance sample.
Do not put the extra corpus into the normal AVR bench: its string literals
would change the flash headroom of that benchmark.

Use identical rendered G-code, start, settings, Z mode and inverse-time mode
for each implementation. The comparison uses a **final XY budget of 2*tol**,
with tol = 0.002, 0.01 and 0.1 mm. Direct Wang and adaptive lines get
BEZIER_SIGMA = 2*tol; a circle fit gets tol for fitting and tol for arc
chording, with a line fallback bounded by 2*tol. Stage-only measurements at
tol are useful, but must be labelled separately from this final-budget
comparison. These are comparison settings, not a new firmware default.

One smoke slice at tol = 0.002 mm, direct Wang, XY only, G94 (from the
repository root, with avr-gcc and simavr in PATH):

```sh
python -I tb/compare/render.py tb/compare/core.in .tmp/compare-core.txt
opts='-DENABLE_CUBIC_SPLINES -DENABLE_QUADRATIC_SPLINES -DTB_ARC_TOLERANCE=.002f -DBEZIER_SIGMA=.004f -DTB_XY_BUDGET=.004f'
timeout 240 nice -n 19 make -s -C tb/avr BUILD=build/compare LINES=../../.tmp/compare-core.txt DEFS="$opts" all dump
timeout 120 nice -n 19 make -s -C tb/host BUILD=build/compare OPT="$opts"
timeout 180 nice -n 19 simavr -m atmega328p -f 16000000 tb/avr/build/compare/dump.elf 2>&1 |
  sed 's/\x1b\[[0-9;]*m//g; s/\.*$//' > .tmp/compare-dump.txt
timeout 120 nice -n 19 tb/host/build/compare/tb --dump-strict .tmp/compare-core.txt .tmp/compare-dump.txt
```

Run `bench.elf` separately for cycles; dumping targets includes UART time
and its cycle counts are not comparable. `LINES` is relative to `tb/avr`.
Use a fresh BUILD directory for every source/flags/corpus combination: Make
does not track changes to command-line options. For tol = 0.01 or 0.1,
replace the three numeric test definitions with .01/.02/.02 or .1/.2/.2.
For circle fitting use BEZIER_SIGMA = tol, keeping TB_XY_BUDGET = 2*tol.
Use numeric definitions: an expression used as BEZIER_SIGMA needs outer
parentheses, since the current generator divides by that macro.

`render.py --z` adds the same Z-3 word to every curve; `--mode G93` uses
G93 and F2 instead of G94 and F1000. Build all implementations with the
same Z option, and with the exact inverse-time option for the exact-G93
comparison. Adaptive implementations must not reuse the equal-t Z check
as evidence that their own t values are correct. Keep XY-only, Z by-t,
Z by-length, and Z by-length plus exact G93 as distinct rows.

`TB_ARC_TOLERANCE` changes only bench settings, not firmware defaults.
`--dump-strict` fails on a measured rejected line, missing/overflowing
output, a non-finite target, a wrong endpoint, or sampled deviation above
TB_XY_BUDGET. Unlike `--dump`, it grants neither a segment-cap nor a
float-grid exemption. It prints the host float control net captured at
the real mc_cubic_b_spline call. All implementations must see the same
net; this is not evidence that every AVR compiler rounded intermediate
parser arithmetic identically. The usual Z and enabled exact-G93 checks
also run. A cap hit alone is reported, not rejected: it fails if it misses
the final budget. Measure capped and uncapped performance separately.

This remains a sampled diagnostic, not a Hausdorff proof: the model has
TB_DENSE = 4000 parameter intervals, the reverse check samples emitted
vertices, and curve Z is evaluated at segment ends. For a borderline or
large-coordinate result repeat the host check with a fresh BUILD and
`-DTB_DENSE=16000`, then use a certified bound before claiming a guarantee.
Do not count a timeout as acceptable fallback or silently discard it.
For cycles, aggregate gen/segment only over finite, accepted measured
curves with at least one segment; report each curve's `first` and `gap`,
all fallback/trial counters, peak stack, and firmware flash separately.
The timed `gen` includes parsing, probe bookkeeping and mc_line overhead;
it is not an isolated arithmetic kernel.

### Decimal words and the tight reference

`read_float` keeps at most eight significant digits. Long exact binary32
decimals also exceed the 80-byte serial line buffer. The corpus fixes a
short common G-code instead; do not compare one algorithm on the original
exact net and another on this parser-rounded net. The following numbers
are measured on the host build of this corpus, except the supplied exact
reference (input data). Coordinates are mm:

| Point | Supplied exact-float reference                 | Host parser net, printed to 9 significant digits |
|-------|-----------------------------------------------|-------------------------------------------------|
| P0    | (0, 0)                                        | (0, 0)                                          |
| P1    | (-2361.66455078125, 614.281494140625)            | (-2361.66455, 614.281433)                         |
| P2    | (-1883.6595458984375, 481.83642578125)           | (-1883.65942, 481.836395)                         |
| P3    | (-1973.58837890625, 498.7366638183594)           | (-1973.58826, 498.736633)                         |

A direct mc_cubic_b_spline call with the exact-float reference is a useful
separate numeric test, not a serial/parser case. The supplied tall S is
P0=(0,0), P1=(-3.3333,16.6667), P2=(-6.6667,-466.667), P3=(-10,8550);
its G-code is fixed in stress.in and is rounded by the same parser.

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
