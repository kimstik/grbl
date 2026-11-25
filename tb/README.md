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

| ID | Test                                                            | Where                  | Status                                     |
|----|-----------------------------------------------------------------|------------------------|--------------------------------------------|
| 1  | Inflection on a probed midpoint does not hide the deviation     | host vector            | pass: 0.0029 mm with 276 segments          |
| 2  | Long handles stay within the tolerance                          | host vectors           | pass to 1e5; capped at 2000 segments       |
| 3  | L1 metric: rotated curve within tolerance                       | host vector            | pass                                       |
| 4  | Last segment bit-exact on the parser position under -ffast-math | avr `end exact`        | pass on all four compilers                 |
| 5  | Non-finite or overflowing values never reach the planner        | host vector, avr       | defect, same class as G1 X1e35             |
| 6  | G5/G5.1 without X/Y must not move to machine zero               | host vectors           | defect                                     |
| 7  | Negative P accepted                                             | host vectors           | defect (error:4)                           |
| 8  | Rejected line: nothing queued, parser state byte-identical      | host, every line       | defect: spline_pq written early            |
| 9  | Generation time and delay before the first target               | avr (2000 segments)    | measured per option, see tables            |
| 10 | Stack on ATmega328P: static chain and with interrupts           | avr, avr dynamic       | measured margin 25-65 bytes, see tables    |
| 11 | Planner starvation while streaming curves at speed              | avr dynamic            | base: none; $12 + length: stops            |
| 12 | Cusp: the planner stops at the reversal                         | host `junction`        | pass                                       |
| 13 | Smooth chain with implicit I/J: no corner at the joins          | host `set smooth`      | pass                                       |
| 14 | Handles on the chord: same as G1                                | host vectors           | pass                                       |
| 15 | G5.1 equals G5 with 2/3-rule handles                            | host `same`            | pass                                       |
| 16 | Quarter circle within the Bezier-circle error                   | host `circle`          | pass                                       |
| 17 | Translation by G91/G92, G20 vs G21: same segments               | host `same`            | pass                                       |
| 18 | Reversed curve within tolerance                                 | host vector            | pass                                       |
| 19 | Check mode, `$J=G5` rejection, mode changes before implicit I/J | host vectors           | pass                                       |
| 20 | Mutation testing                                                | host `mutate.sh`       | 94 of 94 killed, including options         |
| 21 | Random curves, failures shrunk to a minimal line                | host `--random`        | pass (negative P skipped, see 7)           |
| 22 | Host vs AVR: same segments                                      | CI simavr `= host`     | G5.1, [1] and G2 differ (see below)        |
| 23 | Compiler vs compiler: same segments                             | CI simavr per gcc      | G5.1, [1]: 7.3 differs from 15-17          |
| 24 | Denormal, near-zero and coincident handles                      | host vectors           | pass                                       |
| 25 | Command spelling; G5.1 rejected when disabled                   | host, `cubic_only.vec` | pass                                       |
| 26 | Number spelling: P.5, P+5, P5., P1E3, empty P                   | host vectors           | pass; P-.5 is defect 7                     |
| 27 | Forbidden combinations and unused words                         | host vectors           | pass                                       |
| 28 | `$N` startup line with G5                                       | code reading           | same path as any line (system.c:262)       |
| 29 | G93 needs F on every G5 block                                   | host vector            | pass                                       |
| 30 | Modal continuation without the G5 word                          | host vectors           | pass                                       |
| 31 | Same line from the same point: same segments                    | host `same`            | pass                                       |
| 32 | Machine settings: 1 and 1000 steps/mm, slow axes                | host `set`             | pass                                       |
| 33 | Tool length offset with G5                                      | host vector            | pass                                       |
| 34 | Realtime latency: worst gap between segments                    | avr `worst gap`        | measured per option; first pass separate   |
| 35 | Feed hold and resume mid-curve, exact final position            | avr dynamic            | pass: 0 steps off in 6 holds               |
| 36 | Soft reset, then the same line: same segments                   | host `reset`           | pass                                       |
| 37 | Differential against grblHAL G5                                 | one-off host run       | segments bit-identical, see below          |
| 38 | LinuxCNC word rules                                             | host vectors           | pass                                       |
| 39 | G93 nominal time on G5 multiplied by the segment count          | host vectors           | existing defect; exact-G93 option fixes it |
| 40 | Soft limits: curve leaves the envelope between inside endpoints | host vector            | defect: alarm after 11 segments            |
| 41 | K word rejected in G17                                          | host vector            | pass                                       |
| 42 | 40-digit literal read as inf                                    | host vector, avr       | defect                                     |
| 43 | Laser mode `$32=1`: G5/G5.1 burn at S like G1                   | host `power`           | defect: power 0 (gcode.c:992)              |
| 44 | Implicit I/J across G20/G21; G54+G92+G20 stacked                | host `same`            | pass                                       |
| 45 | Out-and-back spike: the tip is reached, nothing overshoots      | host `travel`          | pass                                       |
| 46 | Half-step boundary never steps; curve 60 m from origin          | host `travel`          | pass                                       |
| 47 | Series lifetime: G4, G28, G92, rejected line, reset, check mode | host vectors           | pass                                       |
| 48 | G4+G5 share P; G5.1 continuation rules; repeated Q; G93 F0      | host vectors           | pass                                       |
| 49 | AVR targets: tolerance/cap/grid allowances, exact end           | CI simavr `--dump`     | pass; non-finite input explicitly skipped  |
| 50 | Z word: G5/G5.1, units, offsets, continuation, exact end        | host `z.vec`, avr      | pass for both Z modes                      |
| 51 | Z by parameter vs polyline and model arc length                 | host `z.vec`, random   | measured errors, see option tables         |
| 52 | Float length sum up to 2000; tiny tail chords; monotone final Z | host `z.vec`, random   | pass with denominator reserve              |
| 53 | Zero-length, pure Z, closed and sub-step curves                 | host `z.vec`           | pass with enabled Z option                 |
| 54 | G93 one path feed; 3D length; no leak into G94                  | host `z.vec`, avr      | pass for exact-G93 option                  |
| 55 | Existing G93 G1 and G2 nominal times                            | host `g5.vec`          | G1 pass; G2 defect unchanged               |
| 56 | Runtime $12: coarse, fine and zero                              | host `g5.vec`          | pass; zero on AVR not verified             |
| 57 | Z by estimate: bracket gate, jump of pieces, segments summed    | host `z.vec`, random   | pass; error measured, gate no guarantee    |
| 58 | Z by estimate: steep Z summed, or left open if loose; the cap   | host `z.vec`, avr      | pass; loose is off by more than $12        |
| 59 | Z by estimate: early end, lost first chord, far from origin     | host `z.vec`           | pass: never past the target or backwards   |
| 60 | G93 by estimate: one feed, time off within the bracket          | host `z.vec`, avr      | pass; time off up to 3.1% in random curves |
| 61 | Z by length: the length summed or estimated ends at the target  | host `z.vec`, random   | pass; no allowance for the grid of XY      |
| 62 | Every line ends: no estimate goes on for ever                   | host, every line       | pass; a million rounds of realtime work    |
| 63 | BEZIER_Z_SIGMA: a tolerance of its own for Z by estimate        | host `z.vec`, random   | pass; over $12 by design, see below        |

## 10, 11, 35: motion under simavr

This section records run 44765744542 before mode 3 and the endpoint
fix. For the current reduced sweep with Z, see
[Current comparison: C1, C2 and C3](#current-comparison-c1-c2-and-c3).

`avr/dyn.c` runs the real `main()` and `protocol_main_loop()` with the
stepper interrupt live; it plays a send-and-wait-for-ok host inside
`serial_read()` at 115200 baud and injects feed hold and cycle start from
Timer2. simavr does not start the Timer1 CTC with OCR1A = 0, which Grbl
leaves until its first stepper interrupt, so dyn.c presets OCR1A.

- Stack: firmware with G5+G5.1 uses 1645 bytes of static RAM, leaving 403.
  The tables below subtract the deepest dyn watermark from those 403
  bytes, not from the instrumented bench's different data/bss. Measured
  margins are positive for every tested compiler/option, 52-65 bytes;
  this finite sweep is not a bound on every possible interrupt nesting.
  The single G5/G5.1 call site lets LTO share the gc_execute_line frame,
  as with mc_arc. An earlier adaptive walker used 446 bytes and overran
  into sys; these results belong to the current equal-step generator.
- Motion: 120 programs per option/compiler (40 G5, 40 G1 along the same
  chords, 40 G2; 2 and 5 mm; F1000-5000; 500 and 2000 mm/s^2; 2 and
  16 ms host latency). With 0.1 mm tolerance, base and both Z modes had
  no intermediate G5 stops. With $12 = 0.002, the by-length first pass
  delayed new blocks enough for stops; see the table below. G1/G2 also
  starve in parts of this sweep. All reported final XY positions were
  exact in steps. Ordinary sweep curves have no Z word; the hold programs
  add Z when that option is enabled.
- Feed hold at 60-1000 ms into a G5 chain at F3000, resume 400 ms later:
  six holds per option/compiler, all reported final XYZ step errors zero.
  These are simavr results, not measurements on physical hardware.
- `cut` counts stops while the planner still has a block; `cut_F` is that
  block's entry feed, not instantaneous ISR speed. That run reports
  cut_F = 0 for all such stops. It does not prove that no moving underflow
  is possible: instantaneous speed and a deliberate stalled host were
  not observed by this version of dyn.

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

## Optional tolerance, Z and G93: measured costs

Evidence: [CI run 44765744542](https://github.com/kimstik/grbl/actions/runs/44765744542),
firmware 6bff342, 37 successful jobs. With new options off, `cmp` of the
hex against 73c589e passes for G5 alone and G5+G5.1 on all four compilers.
The comparison-corpus infrastructure added later does not change firmware.

Option names used in CI and the tables:

- `base`: both spline commands, no new options; BEZIER_SIGMA = 0.1 mm.
- `tol`: `-DBEZIER_SIGMA=settings.arc_tolerance`; settings start at $12 = 0.002 mm.
- `zt`: `-DBEZIER_Z_LINEAR=1`, Z linear in parameter t.
- `zl`: `-DBEZIER_Z_LINEAR=2`, Z approximately linear in the XY polyline length.
- `g93` suffix: `-DBEZIER_EXACT_INVERSE_TIME`, requires zl in that run.
  Mode 3 supports an approximate conversion, described in its current comparison.

**Every numeric result in the eight tables is measured**, not estimated.
Flash is firmware text+data with G5+G5.1 and Makefile flags, delta against
base built by the same compiler. `gen/seg` is sum(gen)/sum(segments), rounded
to cycles, over finite accepted G5/G5.1 rows of avr/lines.txt with at least
one target. It includes parsing, probe bookkeeping, mc_line and both
passes, but excludes timed planner work. The accepted corpus differs when
Z words are enabled, so it is a workload average, not an isolated kernel
comparison. Stack is deepest dyn watermark / remaining firmware RAM;
all variants use 1645 bytes static RAM and have 403 free before stack.

Z errors are **host random measurements**, not AVR random measurements:
per curve, the maximum endpoint error divided by absolute Z travel, then
median/max over curves with Z travel. `len` compares with cumulative
emitted XY chord length; `arc` uses Simpson integration of model speed on
4000 intervals and a forward nearest-branch match. These are sampled
metrics, especially approximate near loops/cusps, not certified maxima.
Each host row gives generated cases / curves contributing Z statistics,
seed 1. A dash is not applicable; random Z distributions for the four
AVR compilers are **not verified**. All host runs in the tables had zero
failures. CI has 5000 cases for zt/zl/zl-g93, 1000 for tol/tol-zl-g93;
tol-zt and tol-zl were completed locally with 1000 each. Do not compare
maxima from different sample counts as if they covered the same corpus.

### base

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 30672 (+0)          | 5125           | 343 / 60              | -                | -                |
| avr-gcc 15.2.0            | 31152 (+0)          | 6282           | 338 / 65              | -                | -                |
| avr-gcc 16.2.0            | 30406 (+0)          | 6153           | 338 / 65              | -                | -                |
| avr-gcc 17-20261115       | 30388 (+0)          | 6159           | 338 / 65              | -                | -                |
| Host CI, 5000 / 0         | -                   | -              | -                     | Z rejected       | Z rejected       |

### tol

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 30700 (+28)         | 5116           | 343 / 60              | -                | -                |
| avr-gcc 15.2.0            | 31184 (+32)         | 6308           | 338 / 65              | -                | -                |
| avr-gcc 16.2.0            | 30438 (+32)         | 6177           | 338 / 65              | -                | -                |
| avr-gcc 17-20261115       | 30420 (+32)         | 6184           | 338 / 65              | -                | -                |
| Host CI, 1000 / 0         | -                   | -              | -                     | Z rejected       | Z rejected       |

### zt

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 30764 (+92)         | 5411           | 343 / 60              | -                | -                |
| avr-gcc 15.2.0            | 31228 (+76)         | 6524           | 338 / 65              | -                | -                |
| avr-gcc 16.2.0            | 30488 (+82)         | 6406           | 338 / 65              | -                | -                |
| avr-gcc 17-20261115       | 30468 (+80)         | 6411           | 338 / 65              | -                | -                |
| Host CI, 5000 / 2569      | -                   | -              | -                     | .15 / .45        | .14 / .42        |

### zl

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 31148 (+476)        | 11809          | 347 / 56              | -                | -                |
| avr-gcc 15.2.0            | 31708 (+556)        | 14397          | 342 / 61              | -                | -                |
| avr-gcc 16.2.0            | 30892 (+486)        | 13991          | 344 / 59              | -                | -                |
| avr-gcc 17-20261115       | 30872 (+484)        | 14000          | 348 / 55              | -                | -                |
| Host CI, 5000 / 2569      | -                   | -              | -                     | 9.4e-7 / 8.4e-4  | 5.0e-4 / .38     |

### zl-g93

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 31258 (+586)        | 11828          | 351 / 52              | -                | -                |
| avr-gcc 15.2.0            | 31802 (+650)        | 14357          | 344 / 59              | -                | -                |
| avr-gcc 16.2.0            | 31014 (+608)        | 14023          | 344 / 59              | -                | -                |
| avr-gcc 17-20261115       | 30982 (+594)        | 14077          | 344 / 59              | -                | -                |
| Host CI, 5000 / 2562      | -                   | -              | -                     | 9.5e-7 / 4.3e-4  | 4.3e-4 / .26     |

Exact G93 adds 110/94/122/110 flash bytes to zl on 7.3/15.2/16.2/17
(measured). For the same S+Z G93 line at $12 = 0.002, gen changes by
4114/-2025/3677/7131 cycles over 80 segments on those compilers; with
0.1 mm by 1518/661/1471/1922 cycles over 12. This is the measured whole
compiled line difference, including LTO layout effects, not a negative
cost arithmetic operation on 15.2. G93 time is nominal feed time before
acceleration and step rounding, not elapsed machine time.

### tol-zt

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 30792 (+120)        | 5386           | 343 / 60              | -                | -                |
| avr-gcc 15.2.0            | 31260 (+108)        | 6529           | 338 / 65              | -                | -                |
| avr-gcc 16.2.0            | 30520 (+114)        | 6411           | 338 / 65              | -                | -                |
| avr-gcc 17-20261115       | 30500 (+112)        | 6417           | 338 / 65              | -                | -                |
| Host local, 1000 / 524    | -                   | -              | -                     | .17 / .43        | .17 / .43        |

### tol-zl

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 31176 (+504)        | 11795          | 347 / 56              | -                | -                |
| avr-gcc 15.2.0            | 31740 (+588)        | 14419          | 342 / 61              | -                | -                |
| avr-gcc 16.2.0            | 30924 (+518)        | 14013          | 344 / 59              | -                | -                |
| avr-gcc 17-20261115       | 30904 (+516)        | 14022          | 348 / 55              | -                | -                |
| Host local, 1000 / 524    | -                   | -              | -                     | 2.5e-6 / 1.2e-3  | 4.3e-5 / .092    |

### tol-zl-g93

| Source                    | Flash bytes (delta) | gen/seg cycles | Stack used / margin B | Z len median/max | Z arc median/max |
|---------------------------|---------------------|----------------|-----------------------|------------------|------------------|
| avr-gcc 7.3.0             | 31286 (+614)        | 11808          | 351 / 52              | -                | -                |
| avr-gcc 15.2.0            | 31834 (+682)        | 14379          | 344 / 59              | -                | -                |
| avr-gcc 16.2.0            | 31048 (+642)        | 14045          | 344 / 59              | -                | -                |
| avr-gcc 17-20261115       | 31016 (+628)        | 14099          | 344 / 59              | -                | -                |
| Host CI, 1000 / 532       | -                   | -              | -                     | 2.3e-6 / 1.1e-3  | 4.1e-5 / .056    |

All eight options fit the 32256-byte bootloader limit on all compilers;
the tightest measured remaining flash is 422 bytes (15.2, tol-zl-g93).
All 32 simavr option/compiler jobs completed: 3840 motion programs,
192 holds, and 512 measured bench rows including G1/G2 and rejected lines.
Every reported final endpoint was exact; regular dump had 10 or 13
finite curves per job with zero failed. This does not mean every input
met the requested tolerance: cap allowances and skipped non-finite cases
are explicit below. A green job alone is not evidence of a geometric
guarantee; raw status, counts and waived checks matter.

Measured maximum finite G5 inter-target gap in microseconds (planner
excluded), compiler order 7.3 / 15.2 / 16.2 / 17:
base 252.69/350.00/341.88/342.31; tol 258.94/356.44/350.19/348.69;
zt 270.31/364.19/357.56/357.94; zl 362.12/454.56/440.38/440.81;
zl-g93 362.62/453.31/441.25/443.19; tol-zt 276.56/369.50/363.94/364.31;
tol-zl 364.19/461.44/447.12/447.56; tol-zl-g93 364.00/458.25/447.81/451.56.
This gap excludes the whole first pass, whose latency is separate below.

53/53 mutants were killed in CI. The new mutants cover ignored runtime
tolerance, Z formula/start/end/sign, float sum/replay, missing final chord,
extra first-pass output, the end reserve, and inverse-time length/flag/feed.
No mutant establishes responsiveness of pass 0: the host realtime stub
does not model interrupts. That was checked separately with live simavr
motion. Existing known-defect vectors remain XFAIL rather than being
silently removed; no unrelated firmware defect was changed.

### Tolerance, the cap, and what the tests allow

Analytical calculation (exact arithmetic, not a measured error bound):
with M the largest norm of a second control-polygon difference, Wang's
n = sqrt(0.8*M/sigma). At N = 2000 the cap is reached at M about
5e6*sigma: 500 m at 0.1 mm, 10 m at 0.002 mm, 0.5 m at 0.0001 mm.
The uncapped exact-arithmetic chord error bound is 0.75*M/N^2; capping
N loses the requested tolerance when that value is too large. Float
roundoff adds another error, especially far from the origin.

Measured: runtime $12 = .002/.1/.0001 gives 74/11/327 targets on
G5 X10 Y0 I3 J3 P3 Q3. On the supplied [1] S, .1/.002 gives 276/1950.
The 100000 mm handles line in avr/lines.txt hits 2000 with $12 = .002
and deviates 0.0500 mm on 7.3; the 1e7-handle line deviates 1.6368 mm.
Those are not .002 mm passes. The parser accepts $12 = 0; host tests
then produce 2000 targets even for zero-bend/zero-length curves. This
zero-tolerance behavior on AVR is **not verified**.

Normal host checks now follow the tolerance actually compiled into the
firmware instead of always assuming .1. By default they allow the larger
of that tolerance and the analytical cap bound, plus
4*FLT_EPSILON*largest-control-coordinate for float roundoff. The numeric
factor 4 is an empirical test allowance, not a proof. An explicit
`set tol` is absolute and bypasses those allowances; it keeps the existing
overflow and on-chord adversarial checks meaningful. Dump mode also
accepts a capped AVR result as close as the host (1.001*host + .0001 mm).
Non-finite AVR targets are reported and skipped in the regular dump,
not counted as successful finite curves. The strict comparison mode below
does not grant these allowances.

The cap policy has not changed. Choices for the owner, not silently
selected here: keep the cap and accept a documented tolerance loss;
raise the cap at greater time cost; reject an over-budget curve before
motion; or impose a minimum effective tolerance and expose that loss.
Raising the cap cannot cure float-grid errors. Rejecting a curve requires
a new error path and a policy for already queued motion; neither its
flash cost nor a safe implementation is verified here.

### First-pass latency and motion

All values in the following table are measured simavr `first` cycles
converted at 16 MHz to ms, tol-zl, with the single-pass tol reference.
The typical S is the 80-target G5I-5J5P5Q-5X-20Y0 from avr/lines.txt;
[1] has 1950, the 1e7-handle cap line 2000. These lines have no Z word:
zl currently pays for both passes even when Z travel is zero.

| Compiler       | S, tol reference ms | S, tol-zl ms | [1], tol-zl ms | Cap, tol-zl ms |
|----------------|---------------------|--------------|----------------|----------------|
| 7.3.0          | 1.022               | 25.116       | 630.732        | 632.318        |
| 15.2.0         | 1.130               | 31.590       | 797.386        | 787.229        |
| 16.2.0         | 1.118               | 30.685       | 775.667        | 764.952        |
| 17-20261115    | 1.100               | 30.684       | 776.019        | 765.315        |

Pass 0 emits no new blocks. It calls protocol_execute_realtime at every
point, allowing st_prep_buffer, holds and abort processing, but the
planner can finish the preceding motion before the first new target.
The largest first latency measured in this corpus is 797.386 ms, not
the historical pre-refill 608.887 ms result. Generation work at the cap
on 7.3 is 0.644 s for base versus 1.483 s for zl; total bench time
including planner is 1.996 s versus 2.835 s. Those are not first latency
or actual accelerated motion time.

Measured G5 motion rows, 40 programs per compiler/option; order in each
cell is 7.3 / 15.2 / 16.2 / 17. `Stops` excludes the expected final stop.

| Option     | Programs with stops | Total stops      | Stops with queued block | Max queued entry feed |
|------------|---------------------|------------------|-------------------------|-----------------------|
| base       | 0 / 0 / 0 / 0       | 0 / 0 / 0 / 0    | 0 / 0 / 0 / 0           | 0                     |
| zl         | 0 / 0 / 0 / 0       | 0 / 0 / 0 / 0    | 0 / 0 / 0 / 0           | 0                     |
| tol        | 2 / 2 / 2 / 2       | 2 / 2 / 2 / 2    | 2 / 2 / 0 / 1           | 0                     |
| tol-zl     | 9 / 13 / 10 / 11    | 57 / 86 / 90 / 93| 15 / 13 / 15 / 13       | 0                     |
| tol-zl-g93 | 8 / 10 / 11 / 10    | 57 / 81 / 93 / 91| 16 / 10 / 13 / 11       | 0                     |

In the tol-zl sweep the largest program-time increase over tol is
609/728/670/679 ms. Before adding realtime work to pass 0, a separate
local 7.3 short sweep had 10 stops with queued blocks at nonzero entry
feeds, e.g. F3000 on 5 mm curves. With the fix, those short programs had
no such nonzero-entry-feed events, but still had ordinary stops and some
zero-entry-feed cuts. Final steps were exact in both. This identifies a
real first-pass refill problem; `cut_F=0` is not proof about instantaneous
speed or every starvation path. Additional ISR-level observation belongs
to a separate instrumented test, not the production stack measurements.

### Accuracy and numerical findings

- The 99:1 straight-handle vector is 38% of Z travel off true arc length
  with zt. Making XY segments finer does not cure that parameter-speed
  mismatch. zl instead follows the travelled chords to float-sum accuracy.
- Float accumulation is tested, not assumed: the maximum random zl length
  error at .1 is 8.4e-4 of Z travel; at .002 the local 1000-case maximum
  is 1.2e-3. Tiny XY paths far from the origin amplify the difference
  between the first-pass Horner endpoint and the exact emitted endpoint.
  Thus the implementation is not exactly linear in the actual polyline
  in floating-point arithmetic. Short coarse curves also explain large
  model-arc errors: a chord can be much shorter than the original curve.
- When tiny tail chords vanish in the float sum, an interior share can
  reach 1 and fl(z0+dz) can pass the target, followed by a reverse final
  Z move. Four explicit long-handle vectors reproduce that without the
  fix; 5000 random curves had missed it. `length = s*1.0000002f` reserves
  two float ulps before the exact final Z; the new mutant removing the
  reserve is killed by those vectors. It intentionally adds a tiny
  systematic departure from exact length interpolation.
- G93 now uses one 3D path feed, sqrt(Lxy^2+dz^2)*F. The bench checks the
  nominal sum of segment times, step-rounded planner times, one feed,
  and no leak into G94/G1. End snapping and roundoff remain; acceleration
  is not included in the 1/F claim. A pure Z move is covered.
- Existing mc_arc behavior was verified, not copied as a timing model:
  G93 G1 X20 F2 takes .5 nominal minutes; a G2 half circle of radius 5
  at F4 takes .071391 instead of .25 (55 segments). mc_arc multiplies F
  by N and clears the inverse flag, so nominal time is L/(F*N), not 1/F.
  This is unchanged from origin/master and is recorded as XFAIL [55].
- An old random-test shrinker could alternate .05 and .1 forever, found
  by attaching to a two-hour run. Candidates now shrink strictly in
  magnitude. It was a bench hang, not a demonstrated firmware hang.

Two measured local 7.3 alternatives were left out of the firmware: skipping
pass 0 when dz=0 added 32 bytes to the early zl build (18 with exact G93),
and equal time per segment while keeping the inverse flag added 26 bytes
to base (46 over zt). These were scratch compile probes before the
realtime-refill fix, not current production costs or verified alternatives
with the full evidence suite. The cap/error/default choices remain open.

## Z by an estimate of the length ahead

### RMS selector: fewer square roots, larger firmware

[CI run 45542265482](https://github.com/kimstik/grbl/actions/runs/45542265482),
harness a9cbea0, is **failed**: native identity passes, while both AVR
jobs fail the boot-region fit gate. Frozen sources are parser scratch
210e4a4 and RMS c1e462a. The earlier run 45541202330 failed twice while
downloading the toolchain, before any AVR build. Bounded download retries
resolved that infrastructure failure without changing the pinned versions.

`BEZIER_Z_RMS`, together with `BEZIER_Z_SELECT` and parser scratch,
changes only the initial G94 eight/sixteen-piece choice. With squared
endpoint chord q and the existing Wang energy E, its model uses
`sigma*(q + E + sqrt(q*(q + 2*E)))` instead of
`sigma/2*(chord length + control polygon length)^2`. Two extreme chord
projections and the remaining middle projection replace three dot products.
The RMS polygon replacement is an upper value, so the test is more
permissive, **not a sufficient error condition**. Actual G93 retains
sixteen pieces, including constant Z. Turn splitting, exact short sums,
endpoint copies, coordinate-risk fallback and realtime order are unchanged.

Pinned avr-gcc 16.2.0 production builds give:

| Compile mode | Scratch flash | RMS flash | Added | RMS boot margin | RMS full margin | Static RAM |
| ------------ | ------------- | --------- | ----- | --------------- | --------------- | ---------- |
| G94          | 32932         | 33110     | 178   | -854            | -342            | 1670       |
| G93          | 33052         | 33230     | 178   | -974            | -462            | 1670       |

Boot and full regions are 32256 and 32768 bytes. All six normal links
fail; larger-region relinks are for static inspection only, with no HEX
or AVR execution. Independent verification checks ELF section sizes,
normal-link overflow messages and both complete reference/RMS-off ELF
identities. Free RAM before stack remains 378 bytes. The selector grows
from 514 to 692 bytes; the other named spline/parser functions keep their
sizes. Replacing four calls to an already shared distance helper with
one square root does not save flash here.

Each native variant emits 136 curves and 27528 targets. Independent
verification covers all 408 curves and 82584 targets, input/executable
hashes, every raw XYZ/feed/condition word, parsed start/control net and
all twelve summary words. RMS, RMS-off and reference are fully identical
on these corpora, under both actual G94 and G93. Thirty-two negative and
two positive identity controls pass. The raw Z maxima remain
0.00236027308 mm for ordinary/steep, 0.01222020580 mm for derived and
0.00009336692 mm for directed cases. The common **$12 = 0.002 mm** goal
and exact G93 remain unmet. General vector diagnostics are also unchanged,
not passing: `675 checks: 75 pass, 19 FAIL, 12 xfail, 0 XPASS`.

**Result:** this RMS replacement is not a flash-saving solution. No AVR
startup, stack or motion benefit was measured, and native identity is not
a scheduling test. This candidate is retained as a negative result; the
priority startup/non-backpressure-gap/motion problem remains open. No
winner, default or merge is chosen.

### Parser scratch: identical native outputs, still too large

[CI run 45530663881](https://github.com/kimstik/grbl/actions/runs/45530663881),
harness 92f8e08, is **failed**: native identity passes, while both AVR
jobs fail the boot-region fit gate. Frozen sources are selector 452c70d
and parser scratch 210e4a4. This bounded run checks storage and call
layout, not another length policy. The common goal remains
**$12 = 0.002 mm**; simulations and motion jobs are deliberately skipped.

`BEZIER_PARSER_SCRATCH` reuses consumed I,J and P,Q storage for the two
planar control points, after the implicit-G5 offsets have been saved.
It keeps the spline driver out of the parser frame and passes one local
control-point pointer array to the estimator. It adds no persistent
state. Arithmetic, endpoint copies, selector decisions, G93 conversion
and realtime service after each leaf returns are unchanged. Separate
nested frames are not evidence of a lower full-stack peak.

#### Production size and flag-off identity

Pinned avr-gcc 16.2.0, binutils 2.47 and avr-libc 2.3.2 use the actual
production Makefile options. Every normal link fails in the full
32768-byte flash region. The same objects are then relinked with a
larger region solely for static inspection. No HEX is produced and no
oversized or downloaded executable is run locally.

| Compile mode | Selector flash | Scratch flash | Saved | Scratch boot margin | Scratch full margin | Static RAM |
| ------------ | -------------- | ------------- | ----- | ------------------- | ------------------- | ---------- |
| G94          | 33310          | 32932         | 378   | -676                | -164                | 1670       |
| G93          | 33450          | 33052         | 398   | -796                | -284                | 1670       |

Boot margins use 32256 bytes; full margins use 32768. Free RAM before
stack is unchanged at 378 bytes. An independent data-only reader checks
all six ELF section sizes, the exact normal-link overflow messages and
both complete flag-off ELF identities against selector. The saving is
real, but neither enabled build fits even without a bootloader. Stack
high-water, startup, motion stops and AVR timing remain unmeasured.

#### Native parser identity and remaining error

Reference, scratch-off and scratch each emit 136 curves and 27528
targets: 33 ordinary/steep, 18 derived and 17 directed cases under each
of actual G94 and G93. Directed cases include G5.1, modal and implicit
I/J/P/Q handling, G20, G91, G92 and constant Z. Thirty-two negative
controls and two identity-mode positive controls pass.

Independent verification covers **408 curves and 82584 targets**,
including frozen revisions and input/executable hashes. Every raw XYZ,
feed and condition word, parsed start/control net and all twelve
summary words match selector. There is no XY-only or eight-piece
identity waiver for parser scratch. Native execution is headless, not
an ISR scheduling test.

| Corpus         | Curves per mode | Maximum raw Z error, mm | Curves above 0.002 | Maximum G93 relative time error |
| -------------- | --------------- | ----------------------- | ----------------- | ------------------------------- |
| Ordinary/steep | 33              | 0.00236027308           | 3                 | 0.000154632                     |
| Derived        | 18              | 0.01222020580           | 2                 | 0.000153383                     |
| Directed       | 17              | 0.00009336692           | 0                 | 0.000094527                     |

Z errors use the actual emitted XY chord lengths, without a rounding
allowance or cap waiver. These unchanged excesses and nonzero G93 time
errors are not acceptance of the common tolerance or exact inverse
time. All three general vector runs also retain the same failing
diagnostics, with exit status 1:
`675 checks: 75 pass, 19 FAIL, 12 xfail, 0 XPASS`.
Diagnostic identity is not an all-tests-pass result.

**Result:** parser storage reuse saves 378 / 398 flash bytes without
changing the checked native outputs. It does not make this selector
runnable on ATmega328P. Startup, non-backpressure gaps and ordinary-motion
recovery remain unresolved; no Pareto winner, default or merge is chosen.

### One-pass selector: native policy checks pass, AVR fit fails

[CI run 45517272539](https://github.com/kimstik/grbl/actions/runs/45517272539),
harness ee5c7ec, is **failed**, not accepted: native identity passes,
while both AVR jobs fail their boot-region fit gate. Frozen sources are
baseline 1f19d74, refill 8672b8f, seed fbea6f2 and selector 452c70d.
The common goal remains **$12 = 0.002 mm**. The legacy simulations and
motion jobs are deliberately skipped in this bounded run.

#### Policy and scope

The selector enables `BEZIER_Z_FIXED`, `BEZIER_Z_REFILL` and
`BEZIER_Z_SELECT`. It chooses approximately eight or sixteen initial
pieces before estimating length; it does not perform the seed's
trial-eight pass followed by a retry. Existing reversal splitting,
actual sums for short pieces and coordinate-risk fallback remain.
There is no mid-curve estimate. Realtime service remains in the caller,
after each leaf returns.

The choice uses the already computed Wang differences e0 and e1,
E = |e0|^2 + |e1|^2 + e0 dot e1, Lstar = (endpoint chord + control
polygon length)/2 and h8 = ceil(N/8)/N. It selects eight when
h8^2 E (|dz| + 2 sigma) <= 2 sigma Lstar^2 and the control-edge
projections onto the endpoint chord have signs positive, nonnegative,
positive. Otherwise it selects sixteen. The energy model and coordinate
fallback are **heuristics, not rounded-XY error bounds**.

Actual inverse-time commands always retain the refill sixteen-piece
policy, including constant Z: the retained length also determines G93
feed. This repairs the seed's cross-policy feed regression by avoiding
that policy change for G93; it does not make inverse-time conversion
exact.

#### Production size and macro-off identity

Pinned avr-gcc 16.2.0, binutils 2.47 and avr-libc 2.3.2 build the actual
production Makefile options for each compile mode. Both ordinary
selector links fail in the normal 32768-byte flash region. The same
objects are relinked with a larger region solely to inspect ELF size
and disassembly. Those inspection ELFs are **not valid 328P firmware**;
no selector HEX is produced and no downloaded or oversized executable
is run.

| Source   | Flash G94 | Flash G93 | G94 boot margin | G93 boot margin | Static RAM |
| -------- | --------- | --------- | --------------- | --------------- | ---------- |
| Baseline | 31850     | 31950     | 406             | 306             | 1670       |
| Refill   | 32558     | 32700     | -302            | -444            | 1670       |
| Selector | 33310     | 33450     | -1054           | -1194           | 1670       |

Boot margins use 32256 bytes, leaving 512 bytes for the bootloader.
Selector exceeds even the full 32768-byte flash by **542 / 682 bytes**
for G94/G93. Relative to refill it adds 752 / 750 bytes, with no static
RAM saving. Free RAM before stack is 378 bytes; selector stack high-water
is not measured. Smaller local frames are not a full-stack certificate.

All ten production/inspection ELF section sizes are independently
verified. Both macro-off images match the frozen baseline, and both
SELECT-off images match frozen refill, in HEX and ELF. These four
identities do not imply that the enabled selector fits.

#### Native parser outputs and accuracy

The portable exporter captures actual parser-generated XYZ, feed,
condition and all twelve summary words. Thirty-two negative controls
and two identity-mode positive controls pass. An independent data-only
reader checks all 408 curves: four sources, 33 ordinary/steep plus
18 derived curves, each under actual G94 and G93. Executable/input
hashes and frozen source revisions match the artifacts. Native runs
are headless; they do not measure AVR latency, queue slack or stops.

| G94 family | Curves | Chosen policy | Polygon / exact work | Maximum raw Z error, mm |
| ---------- | ------ | ------------- | -------------------- | ----------------------- |
| S2/Z-.2    | 12     | Eight         | 7 / 1                | 0.00009220102           |
| S5/Z-.2    | 12     | Eight         | 7 / 1                | 0.00005230098           |
| S10/Z-30   | 3      | Sixteen       | 16 / 0               | 0.00236027308           |
| S20/Z-10   | 3      | Sixteen       | 14 / 1               | 0.00045710073           |
| S60/Z-30   | 3      | Sixteen       | 15 / 0               | 0.00058521616           |

For the 24 ordinary G94 curves, every target/feed/condition word and
summary word except the final half-bracket diagnostic matches seed.
Seed measures that diagnostic; selector leaves it zero. The checker
explicitly requires selector half = 0 and finite nonnegative seed half;
it never excludes coordinate, feed or condition words. The earlier
scratch exporter omitted the three floating diagnostics, so its broad
G94 summary-identity claim did not cover this difference. All nine
steep G94 curves match refill in every target and summary word.

Actual G93 matches refill in all raw XYZ/feed/condition and all twelve
summary words for all 51 curves, including the no-Z case that failed
seed's identity contract. Maximum relative nominal-time error is still
0.000154632 for the 33 curves and 0.000153383 for the derived corpus,
not zero. On the 18 derived curves, maximum raw Z error remains
0.01222021 mm, with two above 0.002 mm. Three S10/Z-30 curves also
remain above the common goal. These excesses are reported, not waived.

**Result:** the one-pass choice works on the native controls and avoids
the measured retry pattern there, but its AVR implementation does not
fit. Startup, maximum non-backpressure gap and ordinary-motion recovery
are unverified for this candidate; seed's or refill's timings cannot be
assigned to it. No Pareto winner, production default or merge is chosen.

### Bounded initial seed: mixed motion results

[CI run 45486002886](https://github.com/kimstik/grbl/actions/runs/45486002886),
harness 7dae131, completes **14 of 14 jobs**. The frozen sources are
baseline 1f19d74, fixed a9b415f, refill 8672b8f and seed fbea6f2. Tools
remain avr-gcc 16.2.0, binutils 2.47, avr-libc 2.3.2 and the pinned
simavr revision. The common goal remains **$12 = 0.002 mm**.

Seed enables `BEZIER_Z_FIXED`, `BEZIER_Z_REFILL` and `BEZIER_Z_SEED`.
It starts with approximately eight length pieces, retries with sixteen
if the initial Z bracket is too wide, and retains the coordinate-risk
fallback to actual chord sums. Reversal splitting and exact short
pieces remain. The completed-pass gate is a separate leaf function;
realtime service stays outside its stack frame. Four bytes hold the
accumulated bracket width. No mid-curve estimate is introduced. Neither
the smooth bracket nor the coordinate heuristic certifies rounded XY.

#### Independent checks and fit

Eight production ELF sizes and eight macro-off comparisons pass. Two
REFILL-off images match fixed, and two SEED-off images match refill.
For every source and compile mode, the 18 derived curves, 18 original
timing probes, 40 ordinary programs, four steep-Z programs and six
hold/resume cases pass their integrity and endpoint checks. Raw excess
above the common Z goal remains reported, not waived. There is no new
random, mutation or hardware campaign, or separate check-mode/reset
runtime suite.

The read-only observer checks 12 live curves per source and compile
mode, including the seed's 29-byte state layout and register ABI.
Observed and blind runs of each ELF have identical UART bytes,
per-byte cycle hash and final cycle. Twenty-three directed controls
pass, including accepted 29-byte state, rejected truncated state and
rejected unknown layout. All live commands remain **G94**, including
when inverse-time conversion is compiled in.

| Source   | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Stack G94/G93 | Stack margin G94/G93 |
| -------- | --------- | --------- | --------------- | ---------- | ------------- | -------------------- |
| Baseline | 31850     | 31950     | 306             | 1670       | 334 / 334     | 44 / 44              |
| Fixed    | 32546     | 32688     | -432            | 1670       | 344 / 350     | 34 / 28              |
| Refill   | 32558     | 32700     | -444            | 1670       | 344 / 348     | 34 / 30              |
| Seed     | 32650     | 32754     | -498            | 1674       | 336 / 338     | 38 / 36              |

Seed fits the full 32768-byte flash by only 14 bytes with G93, **not the
32256-byte application region with a 512-byte bootloader**. Stack
values are measured ordinary/steep/hold watermarks, not universal bounds.

#### Motion and first-target delay

| Source   | Stops G94 | Queued G94 | Stops G93 option | Queued G93 option | Steep ms / stops |
| -------- | --------- | ---------- | ---------------- | ----------------- | ---------------- |
| Baseline | 4         | 3          | 9                | 5                 | 3013 / 4         |
| Fixed    | 50        | 16         | 46               | 15                | 2646 / 0         |
| Refill   | 30        | 7          | 31               | 5                 | 2655 / 0         |
| Seed     | 5         | 2          | 5                | 0                 | 2852 / 4         |

Ordinary totals cover 40 programs; the last column is the separate
20 mm/Z-10/F5000 steep-Z program. Seed largely recovers ordinary motion
relative to refill, but the four steep-case stops return. The sum of
ordinary G94 program times is 95994 ms, versus 95213 ms for baseline
and 100111 ms for refill. This is a sum over separate tests, not a
single continuous job. Queued-stop counts sample planner occupancy;
zero queued stops does not prove the absence of every abrupt stop.
All six hold/resume endpoints pass in both compile modes.

The following are largest first-target delays and target gaps, in
milliseconds, over each three-curve G94 live chain:

| Live chain     | Baseline first / gap | Refill first / gap | Seed first / gap |
| -------------- | -------------------- | ------------------ | ---------------- |
| S10/Z-30/F5000 | 87.260 / 11.023      | 43.793 / 10.954    | 65.400 / 10.953  |
| S20/Z-10/F5000 | 96.877 / 7.805       | 29.347 / 6.812     | 67.988 / 6.811   |
| S60/Z-30/F5000 | 115.280 / 144.258    | 36.640 / 9.876     | 55.793 / 9.901   |
| S60/Z-30/F1000 | 92.502 / 110.378     | 31.391 / 48.435    | 43.319 / 48.422  |

All twelve observed seed curves retry from eight to sixteen pieces
before emitting their first target. These cases pay for both passes;
first-target maxima worsen in all four chains relative to refill.
Headless S10/Z-3 similarly changes from 22.588 to 36.107 ms, while the
turning case improves from 27.139 to 19.096 ms. A large target gap is
not itself starvation: the separately traced 48.435 ms refill gap below
was full-planner backpressure. That diagnosis is not transferred to
other gaps or stops without a trace.

#### Accuracy and the inverse-time identity failure

On the 18 derived curves, seed's raw XYZ and condition sequences match
refill in both compile modes. G94 feeds also match. Maximum raw Z error
remains **0.01222021 mm**, with two curves above 0.002 mm. The live
maximum remains **0.00236027 mm**. Thus this corpus shows no Z-accuracy
improvement from the new initial policy.

The stronger planned headless XY/feed/condition identity **fails** for
G93 on the no-Z command `G5X10Y0I3J12P3Q-12F2`. All 124 feed values
change from 37.79473114 to 37.82238770 mm/min; no coordinate or condition
bits change. The retained coarse length is also used to convert G93
feed, even when Z is constant. Seed uses nine polygon pieces here,
versus sixteen for refill, so the feed changes by 0.073176%. Relative
nominal-time error rises from 0.015338% to 0.088449%, the maximum for
seed on this corpus. The independent verifier retains the identity
failure; the comparison is not weakened to hide it. Live G94 identity
checks cannot establish inverse-time feed identity.

[Artifact-only CI run 45492761255](https://github.com/kimstik/grbl/actions/runs/45492761255),
harness 34df820, adds the missing cross-arm acceptance check using the
unchanged artifacts from run 45486002886. It **fails on seed/G93**:
`feed differs at 124 targets; first 1: 1108815310 -> 1108822560`.
Refill matches fixed in XYZ/feed/condition/trace for both compile modes;
seed matches refill in XY/feed/condition for G94 only. Twenty-one directed
identity controls pass. The XY-only comparison excludes Z and estimate
trace, never feed or condition. Builds and simulations are skipped in
this artifact-only run. The earlier 14/14 result is an integrity result,
not acceptance of seed's planned identity contract.

**Result:** seed is a measured tradeoff, not a Pareto winner. It recovers
most ordinary stops but worsens steep-Z motion and first-target delay
where both passes are needed. Boot fit, loose Z excess and exact G93
remain unresolved. All candidates stay separate; no default or merge
is selected.

### Postqueue refill: partial motion recovery

[CI run 45470817521](https://github.com/kimstik/grbl/actions/runs/45470817521),
harness f54f943, completes **11 of 11 jobs**. Frozen sources are baseline
1f19d74, fixed a9b415f and refill 8672b8f, with the same avr-gcc 16.2.0
and common **$12 = 0.002 mm** goal. Refill enables `BEZIER_Z_FIXED` and
`BEZIER_Z_REFILL`; it changes scheduling, not the fixed length policy.

The added call services `protocol_execute_realtime()` after an
intermediate target has returned from `mc_line`, before calculating the
next target. The existing abort check remains before the new call, and
another follows it. All earlier prequeue, full-buffer and estimator
realtime calls remain. No ISR, planner, geometry or mode-2 code is
changed, and no state is added. This can prepare segments from the newly
queued block earlier; it cannot guarantee publication before every ISR
deadline or make the next curve's initial estimate free.

#### Independent checks and fit

Six production ELF sizes and six macro-off comparisons pass. Two
additional REFILL-off images match the fixed production images. For
both compile modes, all 18 headless curves have **bit-identical
XYZ/feed/condition and estimator accounting to fixed**. The original
18 timing probes, 40 ordinary programs, four steep-Z programs and six
hold/resume cases pass their integrity and endpoint checks. This is not
a separate runtime check-mode/reset suite or a worst-case safety proof.

The read-only live observer checks 12 curves per source and compile
mode. Refill matches fixed's full XYZ/feed/condition sequence, not only
XY. Observed and blind runs of each image have identical UART bytes,
per-byte cycle hash and final simulated cycle. Twenty directed controls
reject integrity defects, including a changed Z target in a full-identity
comparison, while retaining a monotone tolerance excess as data. No
new random, mutation or hardware campaign is claimed.

| Source   | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Stack G94/G93 | Stack margin G94/G93 |
| -------- | --------- | --------- | --------------- | ---------- | ------------- | -------------------- |
| Baseline | 31850     | 31950     | 306             | 1670       | 334 / 334     | 44 / 44              |
| Fixed    | 32546     | 32688     | -432            | 1670       | 344 / 350     | 34 / 28              |
| Refill   | 32558     | 32700     | -444            | 1670       | 344 / 348     | 34 / 30              |

Refill costs 12 bytes of flash and no static RAM over fixed. Both builds
fit 32768 bytes, **not the 32256-byte application region with a 512-byte
bootloader**. Stack values are observed ordinary/steep/hold watermarks,
not universal bounds. The headless raw Z maximum remains 0.01222021 mm,
with 2 of 18 curves over 0.002 mm. The live maximum remains 0.00236027 mm.
No tolerance improvement is implied by servicing realtime earlier.

#### Motion and target gaps

Ordinary 40-program totals are below. A queued stop is the benchmark's
sample of planner occupancy, not an ISR classification or measured
instantaneous stop speed. All these motion commands are **G94**, even
when G93 conversion is compiled in.

| Source   | Stops G94 | Queued G94 | Stops G93 option | Queued G93 option | Max queued entry feed |
| -------- | --------- | ---------- | ---------------- | ----------------- | --------------------- |
| Baseline | 4         | 3          | 9                | 5                 | 2664                  |
| Fixed    | 50        | 16         | 46               | 15                | 2664                  |
| Refill   | 30        | 7          | 31               | 5                 | 0                     |

Refill recovers part of the fixed policy's regression, but still stops
more often than baseline. Zero queued entry feed does not certify the
absence of every abrupt stop. The four steep-Z programs retain exact
ends and zero counted stops; S20/F5000 takes 2655 ms with refill versus
2646 ms with fixed and 3013 ms with baseline, without the G93 option.
All six hold/resume endpoints pass.

The table below gives largest target gaps in milliseconds over each
three-curve live chain, without the G93 option. First-target maxima for
refill are 43.793, 29.347, 36.640 and 31.391 ms respectively. These are
live scheduling measurements, not headless estimator costs.

| Live chain     | Baseline gap | Fixed gap | Refill gap |
| -------------- | ------------ | --------- | ---------- |
| S10/Z-30/F5000 | 11.023       | 10.981    | 10.954     |
| S20/Z-10/F5000 | 7.805        | 7.811     | 6.812      |
| S60/Z-30/F5000 | 144.258      | 9.866     | 9.876      |
| S60/Z-30/F1000 | 110.378      | 48.398    | 48.435     |

A bounded read-only trace classifies the 48.4351875 ms F1000 gap, between
points 12 and 13 of the last curve. Of its 774963 cycles, 739854 cycles
(46.240875 ms) wait for room in the full planner. The helper takes only
9540 cycles (0.59625 ms). Planner occupancy stays at 14-15 blocks, and
the segment ring at 4-5 slots. Five segments are published and consumed,
with no ISR empty event during the gap. This is producer backpressure,
not stepper starvation; a large target gap alone is not a motion defect.

The locally built observation ELF is byte-identical to the CI image.
Observed and blind runs also match the CI final cycle and UART timing
hash. The local simulator revision was not independently verified.
This classifies one gap, not every remaining stop. The extra realtime
call is not a general cure for the ordinary-motion regression.

A separate bounded local trace of the same refill source reaches the
end of ordinary program 27, 2 mm/F4000/acceleration 2000/latency 2 ms.
The earlier moving-queued empty is absent: the two ISR empties in that
program have no planner blocks queued and saved consumed end speed zero.
Counted stops change from three to one, and program time from 1747 to
1688 ms. Observed and blind controls are identical. However, the next
curve's initial estimate still permits a normal stop, and program 24
retains late-block queued empties with consumed end speed zero. This
classifies only the targeted events, not the complete motion sweep.

#### Initial estimates and already-published stops

A data-only classification of the existing ordinary-motion recordings
separates another cause from the earlier moving-queued empty. The locally
built baseline and refill G94 ELFs are byte-identical to their CI images;
each observed/blind pair has identical final cycle, UART bytes and
per-byte cycle hash. The baseline recording reaches program 27, and the
refill recording completes it and enters program 28. Neither recording
covers all 40 programs; the local simulator revision remains unverified.

Program 24 uses 2 mm curves, F2000, acceleration 2000 and 16 ms serial
latency. Each curve has 36 segments. Baseline needs 10 helper calls before
the first target, while refill needs 38: `ceil(36/16) = 3` triggers the
existing exact-short-piece path, so fixed evaluates all 36 chords. The
other two calls initialize the estimate and emit the first target.
Program time changes from 1722 to 2003 ms and counted stops from 0 to 7.
The trace finds eight intercurve ISR empties, plus the final program end;
these are not the same counter as the benchmark's next-target samples.

All nine empties in this program have **saved consumed end speed zero**.
For each intercurve empty, the stopping descriptor was published before
the first target of the next curve. Selected intervals below are elapsed
wall time in milliseconds, not pure estimator CPU cost. A negative last
column means the ring emptied before that first target arrived.

| Next curve | Previous last to next first | Before helper | Initial helper to first | Stop published before first | Empty after first |
| ---------- | --------------------------- | ------------- | ----------------------- | --------------------------- | ----------------- |
| 3          | 44.983                      | 23.411        | 21.572                  | 18.200                      | 0.612             |
| 5          | 44.956                      | 23.223        | 21.733                  | 17.782                      | 0.916             |
| 6          | 68.215                      | 24.265        | 43.950                  | 58.185                      | -25.531           |
| 7          | 42.508                      | 23.449        | 19.059                  | 24.221                      | 1.504             |
| 8          | 67.868                      | 23.854        | 44.013                  | 57.888                      | -25.205           |
| 10         | 45.435                      | 23.626        | 21.810                  | 18.380                      | 0.098             |
| 11         | 42.582                      | 23.412        | 19.170                  | 24.455                      | 1.286             |
| 12         | 67.830                      | 23.710        | 44.120                  | 57.833                      | -25.185           |

At the boundary into curve 3, the zero-end descriptor is published at
cycle 921188967 and loaded at 921346743. The first next-curve target
arrives at 921480160, and the ISR finds the ring empty at 921489944.
Arriving 0.6115 ms before the empty event cannot undo the stopping
trajectory that was already published 18.1995625 ms before the target.
`plan_get_exec_block_exit_speed_sqr()` returns zero without a successor
planner block; published segment descriptors are no longer replanned.
Servicing realtime during the estimate therefore keeps existing work
moving, but cannot provide the missing next-curve lookahead. Serial and
parser work before the estimate also contributes to this interval.

Over the recorded refill interval, all 36 ISR empties have saved end
speed zero, including three with a newly queued planner block. Baseline
has 26 zero-end empties and the previously classified moving-queued
empty. This does not prove the absence of every abrupt stop in the full
sweep. In particular, `st_go_idle()` can delay an interrupted helper by
the configured 25 ms idle-lock interval; the 44 ms helper intervals must
not be treated as 44 ms of floating-point work.

**Result:** earlier refill is a small, path-preserving partial improvement.
It does not close ordinary-motion regression, boot fit, loose Z error or
exact G93. Initial-estimate latency must be reduced without discarding
accuracy; another postqueue refill cannot cancel an already-published
stop. Fixed and refill remain comparison candidates, not selected
defaults; no merge is made.

### Fixed coarse pass: faster start, worse ordinary motion

[CI run 45464272357](https://github.com/kimstik/grbl/actions/runs/45464272357),
harness e82ec45, completes **8 of 8 jobs**. Frozen sources are baseline
1f19d74 and fixed a9b415f, `BEZIER_Z_FIXED`, on avr-gcc 16.2.0, binutils
2.47 and avr-libc 2.3.2. The common goal remains **$12 = 0.002 mm**.
Success verifies measurement integrity, not that the motion or error
requirements have been met.

The fixed source makes one initial pass with approximately sixteen
control-polygon pieces. A reversal test halves a piece; short pieces
sum actual segment lengths. A coordinate-risk heuristic can request a
full actual chord sum after that pass. It reuses the baseline point,
distance, remaining-Z update and realtime service between estimator
calls. There is no tolerance escalation or mid-curve re-estimate. The
smooth polygon and coordinate heuristic do not certify rounded XY.

Discrete Gauss quadrature was considered first, but its initial G94/G93
production images were 33808/33926 bytes and failed to link for the
328P in run 45458480422. Later local size-only refactors, including
Simpson's rule, still exceeded 32768 bytes. No oversized AVR image was
executed and no AVR timing is claimed for those alternatives. The fixed
polygon pass was tested instead of continuing to optimize their size.

#### Production fit and independent checks

| Source   | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Stack G94/G93 | Stack margin G94/G93 |
| -------- | --------- | --------- | --------------- | ---------- | ------------- | -------------------- |
| Baseline | 31850     | 31950     | 306             | 1670       | 334 / 334     | 44 / 44              |
| Fixed    | 32546     | 32688     | -432            | 1670       | 344 / 350     | 34 / 28              |

Flash is text+data independently decoded from production ELF sections;
boot margin is against 32256 bytes. Fixed fits 32768 bytes, **not the
application region with a 512-byte bootloader**. Stack is the largest
observed ordinary/steep/hold watermark, not a worst-case bound.

Four macro-off image comparisons pass. Independent checks cover all
four G94/G93 raw measurement sets: 18 constructed curves, the original
18 timing probes, 40 ordinary motion programs, four steep-Z programs
and six holds. Counts, hashes, finite exact ends, monotone Z, commanded
time and stack arithmetic pass. These are not new random or mutation
campaigns. The changed Z policy is compared against cumulative length
of its actual emitted XY polyline, without cap or float-grid waivers.

#### Headless startup, gaps and error

Milliseconds on a 16 MHz ATmega328P, without the G93 option. Each timing
cell is **baseline / fixed**. These images do not execute the stepper.

| Curve                     | First target    | Largest target gap | Fixed raw Z error mm |
| ------------------------- | --------------- | ------------------ | -------------------- |
| S10, Z-3                  | 61.605 / 22.588 | 0.482 / 0.486      | 0.00045325           |
| S10, Z-30                 | 61.607 / 22.590 | 0.482 / 0.484      | 0.00453056           |
| S20, Z-10                 | 82.666 / 21.709 | 0.485 / 0.486      | 0.00078820           |
| S1000, Z-500              | 80.948 / 21.789 | 81.628 / 0.486     | 0.01222021           |
| Collinear handles 99:1    | 38.992 / 20.701 | 0.446 / 0.446      | 0.00000381           |
| Turn, 256 segments, Z1000 | 81.115 / 27.139 | 9.185 / 0.480      | 0.00031743           |
| Cap, 2000 segments, Z50   | 82.674 / 21.761 | 82.297 / 0.493     | 0.00026054           |

The largest raw Z error is 0.01222021 mm, with **2 of 18 curves over
0.002 mm**, versus baseline 0.01323418 mm and 1 of 18. This improves the
turn but spends accuracy on the two S curves; it does not meet a strict
common tolerance. The sample is not a universal maximum. Translated
risk cases keep the baseline Z output by summing actual segments, but
can be slower: the translated axis example starts in 31.276 instead of
8.524 ms because it sums 41 segments twice. Pure-Z and no-Z paths also
pass. Largest relative commanded G93 time error is 0.000153383, versus
baseline 0.000583304; mode 3 still does not provide exact inverse time.

#### Read-only live observation and motion regression

The same-ELF observer and blind controls pass for both compile modes:
12 curves per source, identical parsed nets, XY/feed/condition bits and
finite exact ends, with monotone Z. Source, ELF hash, ABI/state layout,
UART bytes, per-byte cycle hash and final cycle are checked. The fixed
live raw Z maximum is 0.00236027 mm, versus baseline 0.000200194 mm.
No optional work or later estimate is performed by fixed. All live
commands are **G94**, even with G93 conversion compiled in.

Each timing cell below is **baseline / fixed**, maxima over a three-curve
chain, without the G93 option. Target gaps include work outside the
estimator; they are not synonymous with estimation pauses.

| Live chain     | First target     | Largest target gap |
| -------------- | ---------------- | ------------------ |
| S10/Z-30/F5000 | 87.260 / 44.689  | 11.023 / 10.981    |
| S20/Z-10/F5000 | 96.877 / 29.495  | 7.805 / 7.811      |
| S60/Z-30/F5000 | 115.280 / 36.656 | 144.258 / 9.866    |
| S60/Z-30/F1000 | 92.502 / 31.211  | 110.378 / 48.398   |

The ordinary 40-program sweep regresses substantially: **stops / stops
with planner blocks queued are 4 / 3 to 50 / 16** without the G93 option,
and **9 / 5 to 46 / 15** with it. Queued-block entry feed reaches 2664
mm/min; that field is not instantaneous stepper speed. Four steep-Z
programs improve: S20/F5000 changes from 3013 ms and four stops to
2646 ms and zero stops. All XYZ and hold endpoints pass, but endpoint
correctness does not make the ordinary-motion regression acceptable.

Fixed demonstrates a useful reduction in estimator startup and later
work, **not a production-ready alternative or a general motion win**.
It is retained for comparison. The next priority is timely stepper
segment publication, not further byte optimization. No merge or new
default is selected.

### First queued-stop diagnosis in the baseline

A bounded read-only local observation identifies the first queued stop
in the exact baseline image used above. The fresh local dyn ELF is
byte-identical to the CI baseline (SHA256
`54d1705300896448edaead779b68cd9ae8d6085f3bd9d8ad1e50cd17c3d5e35a`).
The downloaded image was read for comparison, not executed locally.
Observed and blind runs have identical UART bytes and per-byte cycles,
and end at cycle 963956879. No AVR instructions or state were injected.

The event is ordinary program 27, 2 mm / F4000 / acceleration 2000 /
latency 2 ms. Short planner chords end stepper segments before the
nominal segment duration. After the last refill, the remaining segment
buffer covers only 3.950313 ms, including the active segment remainder,
although the planner is not empty. Ordinary planning and the next point
helper take 2.940688 ms before the next `st_prep_buffer` call. That call
has started, but cannot publish its first segment in the remaining
1.009625 ms. The ISR sees empty at cycle 962356879 with **11 planner
blocks queued**, interrupting rate math in `__mulsf3x` before publication.

The consumed segment's saved planned end speed is 3319.86426 mm/min;
it belongs to that published slot, not the current global prep state
or the queued block's entry feed. The ISR then disables the timer
without another deceleration segment. The initial length estimator had
finished 55.135375 ms earlier. Most of the 31.424313 ms target gap is
after starvation: `st_go_idle` spends the configured 25 ms idle-lock
delay inside the ISR before foreground preparation can continue.

This proves one concrete missed-publication deadline. It neither
classifies all other queued stops nor proves the same cause for fixed,
A2 or hardware. No refill or ISR fix is validated by this observation.

### Compact A2: measured boot fit with ordered reserve reads

[CI run 45439717696](https://github.com/kimstik/grbl/actions/runs/45439717696),
harness c34d36f, completes **12 of 12 jobs**. The frozen sources are
baseline 1f19d74, A2 937229f and compact A2 3947b1b. The toolchain is
avr-gcc 16.2.0, binutils 2.47 and avr-libc 2.3.2, with the same firmware
flags and common **$12 = 0.002 mm** goal. No tolerance is widened.

The compact source keeps A2's policy: prefetch only the first pass for
an already scheduled suffix, and adopt it only at the old deadline.
It adds compiler barriers around the reserve descriptor reads, shares
the mandatory and optional nine-argument call site, and uses the old
outgoing Z as the disposable distance sum immediately before replacing
Z. The staged length sums, active remaining length and Z, partition,
float seed, escalation, initial estimate and G93 conversion are unchanged.

#### Production fit and independent checks

| Source     | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Measured stack | Stack margin |
| ---------- | --------- | --------- | --------------- | ---------- | -------------- | ------------ |
| Baseline   | 31850     | 31950     | 306             | 1670       | 334            | 44           |
| A2         | 32202     | 32292     | -36             | 1671       | 334            | 43           |
| Compact A2 | 32162     | 32252     | 4               | 1671       | 334            | 43           |

Flash is text+data, checked independently against the production ELF
sections. Compact A2 fits the **32256-byte** application region with
both options. Four bytes of G93 headroom is a fit for this exact build,
not a practical expansion budget or a promise about another toolchain.
Stack margins use the largest observed motion watermark, not a
worst-case stack proof. No hardware flash or motion run is claimed.

Six macro-off image comparisons pass. All six headless G94/G93 sets
pass raw-point, count, hash, finite/exact-end, monotone-Z and commanded-time
checks, plus the original 18 timing probes and 40 ordinary motion programs,
four steep-Z programs and six holds. XYZ endpoints and stack footer
arithmetic pass. Segment counts and raw Z errors match the baseline:
**0.01323418 mm maximum, 1 of 18 curves over 0.002 mm**. The largest
relative commanded G93 time error remains 0.000583304. This is a fit
and scheduling result, not a new accuracy bound or exact inverse time.

The native whole-driver controls check 20 curves, three reserve scripts
and three abort modes per source. XYZ/feed/condition/trace bits match;
compact and frozen A2 also retain the same realtime/planner/reserve event
sequences. These scripted tests cover partial and ready prefetch, but
do not measure actual stepper timing.

#### Observed benefit and limitations

The separate read-only live observer described below runs the same
four three-curve chains for all three sources, each with observation
on and off. In both compile modes, each prefetch source performs
**48 optional pieces**, completes **6 passes** and uses all six ready
passes at their original deadlines. All 12 curves have bit-identical
XYZ/feed/condition sequences to the baseline. The raw live Z maximum
is 0.000200194 mm. Per-ELF ABI, source, hash, complete counters, UART
bytes, per-byte cycle hash and final cycle agree with the blind control.
No partial pass reaches its deadline in this live workload.

All live commands are **G94**, even when G93 conversion is compiled in.
Milliseconds below are maxima over each three-curve chain, without the
G93 option; each cell is **baseline / compact A2**.

| Live chain     | Largest later estimate pause  | Largest target gap |
| -------------- | ----------------------------- | ------------------ |
| S60/Z-30/F5000 | 141.752 / 133.016             | 144.258 / 135.576  |
| S60/Z-30/F1000 | 108.218 / 96.537              | 110.378 / 98.784   |

With the G93 option, the corresponding later pauses are
141.769 / 133.031 and 108.259 / 96.575 ms. Initial delays are not
removed. In the no-reserve timing bench S10/Z-3 first target is
61.605 / 61.871 ms; S20/Z-10 is 82.666 / 83.034 ms. The live S10/S20
chains have no later checkpoint to prefetch. Subsequent escalation
and exact sums still run at their mandatory deadlines.

In the ordinary 40-program sweep, stops / stops with planner blocks
queued are baseline 4 / 3, A2 6 / 5, compact A2 9 / 7 without the
G93 option; with it they are 9 / 5, 4 / 2 and 4 / 2. These mixed
changes do not establish a general starvation improvement. Queued-block
entry feed is not instantaneous stepper velocity. The first baseline
queued stop is diagnosed above; other events remain unclassified.
All motion and hold endpoints pass.

Production disassembly confirms the compiler ordering correction in
both compact builds. For example, in G93 the first tail read at 0x5d46
precedes the descriptor loads at 0x5d6c..0x5d72 and product call at
0x5d74, followed by the second tail read at 0x5d78. The barriers do not
mask interrupts or establish WCET; the ISR can advance after the final
sample. The 5 ms snapshot gate remains a heuristic, not a guarantee
of enough foreground CPU time.

Compact A2 is a measured, boot-fitting scheduling alternative that
preserves the tested paths. Initial latency, substantial later pauses,
loose tolerance excess and approximate G93 remain open. No candidate
is selected as the production default or merged.

### Earlier A2: prefetch without early adoption

[CI run 45427709185](https://github.com/kimstik/grbl/actions/runs/45427709185),
harness 367a78b, completes **8 of 8 jobs** on avr-gcc 16.2.0. The sources
are baseline 1f19d74 and A2 937229f, `BEZIER_Z_PREFETCH`, both with the
common **$12 = 0.002 mm** goal. The preceding run 45426867384 failed two
host links: the shared no-stepper stub did not enable the prefetch symbol.
367a78b fixes that test stub only; the candidate source is unchanged.

A2 retains the baseline initial estimate, escalation, cost cutoff and
G93 conversion. During a forced planner-full wait it may compute one
piece of the first eight-piece pass for the next mandatory suffix.
That suffix's origin, partition, order and float seed are fixed exactly
as in the baseline. The staged sums do not change active remaining
length, Z, the deadline, or emitted points. At the original deadline,
a ready pass is consumed, or a partial pass is finished normally; only
then does the old gate use the current remaining Z. No new checkpoint
is created when the baseline has none. Exact segment sums are not
prefetched. The same 5 ms future-segment snapshot gate as A1 remains a
heuristic, not a WCET guarantee. No ISR is changed.

A separate production-disassembly review found an ordering limitation:
avr-gcc 16.2 moves the ordinary descriptor loads after the second volatile
tail check. The two tail reads therefore do not bracket the descriptor
read in this frozen binary. The descriptor is immutable without a
foreground refill, but an ISR can advance the tail after both checks;
a stable-after-scan time credit is not established. The successful live
workload is not a proof against that race. Ordering needs a separate
correction and code-generation check, not an undisclosed size change.

#### Fit and headless checks

| Source   | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Measured stack | Stack margin |
| -------- | --------- | --------- | --------------- | ---------- | -------------- | ------------ |
| Baseline | 31850     | 31950     | 306             | 1670       | 334            | 44           |
| A2       | 32202     | 32292     | -36             | 1671       | 334            | 43           |

Flash is text+data; boot margin is against 32256 bytes. A2 fits 32768
bytes, but its G93 build does not yet fit with the 512-byte bootloader.
These are production section sizes and observed full-dyn watermarks,
not a worst-case stack proof. Four macro-off images match the baseline.

All four headless measurement sets pass the independent raw-data
checks: 18 constructed curves, the original 18 timing probes, and the
40 ordinary motion programs plus four steep-Z programs and six holds.
Segment counts and raw Z errors match the baseline in both feed modes.
The largest raw Z error remains **0.01323418 mm**, on the constructed
256-segment turn: 1 of 18 curves exceeds 0.002 mm. A2 preserves that
loose error; it does not fix it. Largest relative commanded G93 time
error remains 0.000583304. The headless bench has no reserve, so it
cannot demonstrate the benefit of prefetch. For example, S10/Z-3 first
target delay slightly increases from 61.605 to 61.871 ms.

#### Read-only observation during motion

`avr/observe.c` observes entry and return PCs and SRAM from the host
simulator, without inserting AVR trace instructions. The per-ELF ABI,
state layout, source revision and ELF hash are checked. Each image also
runs blind: UART bytes, the hash including each byte's simulated cycle,
and the final simulated cycle must be identical with observation enabled
and disabled. Simulator revision is pinned. Eleven directed checker
controls reject damaged records and retain a monotone tolerance excess
as data. This avoids the UART-per-point traffic that would change the
opportunities being measured.

The separate `TB_DYN_OBSERVE` workload has four three-curve chains:
S10/Z-30/F5000, S20/Z-10/F5000, S60/Z-30/F5000 and S60/Z-30/F1000,
acceleration 2000 and serial latency 2 ms. All commands are **G94**;
G93-on/off below refers only to whether conversion is compiled in.
This workload supplements, not replaces, the ordinary motion sweep.

In each build A2 performs **48 optional pieces**, completes **6 passes**
and uses all six ready passes at their original deadlines. No partial
pass reaches a deadline in this live workload; partial completion is
covered by the separate deterministic state test, not claimed as live
coverage. All 12 curves have bit-identical XYZ/feed/condition sequences
to the baseline, finite exact ends and monotone Z. The independent raw
Z maximum is 0.000200194 mm for both sources. Observed stack is 334 bytes.

Each cell below is **baseline / A2**, milliseconds; maxima over the
three curves in that chain, without the G93 option.

| Live chain       | Largest later estimate pause | Largest target gap |
| ---------------- | ---------------------------- | ------------------ |
| S60/Z-30/F5000   | 141.752 / 133.016            | 144.258 / 135.575  |
| S60/Z-30/F1000   | 108.218 / 96.537             | 110.378 / 98.784   |

With the G93 option the later pauses are 141.769 / 133.030 and
108.259 / 96.575 ms respectively. S10/S20 already finish their initial
segment sum with no later checkpoint, so neither has an optional unit.
A2 does not remove their initial delay. It hides one future coarse pass,
not subsequent escalation or exact sums; substantial pauses remain.

On the ordinary 40-program sweep, stops / stops with planner blocks
queued change from 4 / 3 to 6 / 5 without the G93 option, and from 9 / 5
to 4 / 2 with it. All programs still issue G94. These mixed changes do
not establish a general starvation improvement. Queued-block entry feed
is not instantaneous stepper speed; the stop mechanism is unresolved.

A2 demonstrates a limited scheduling gain without changing the tested
path, not a new accuracy policy or a selected production default. The
G93 boot overflow, initial delay, remaining long gaps and pre-existing
loose error are still open. No candidate is merged.

### Matched loose experiments: scheduling, relative edges and global progress

[CI run 45408953688](https://github.com/kimstik/grbl/actions/runs/45408953688),
harness a77fa06, completes all **12 jobs**. Four frozen sources use the
same avr-gcc 16.2.0, binutils 2.47 and avr-libc 2.3.2, the firmware
compile flags, G5 and G5.1, and the common **$12 = 0.002 mm** target.
No extra tolerance or production default is selected.

The independent check covers eight production ELF section sizes, eight
macro-off image comparisons, and eight G94/G93 measurement sets. Each
set has 18 constructed curves with raw targets and a separate timed
image, the original 18 timing probes, 40 ordinary motion programs,
four steep-Z programs and six holds. Target counts and hashes, finite
exact ends, monotone Z, commanded G93 time, motion coverage and stack
footer arithmetic pass. Nine directed reporter controls check that
corrupt data fail while a monotone tolerance excess remains visible.
**Success here means measurement integrity, not compliance with $12.**
These are fixed hypotheses, not a random error-rate sample. No new
mutation score, hardware run or worst-case stack proof is claimed.

The sources are separate, not combined:

- **Baseline, 1f19d74:** the existing loose half-count re-estimates.
- **A1, 53f5e10, `BEZIER_Z_SCHEDULE`:** start with eight pieces, then
  refine one unit at a time only during a forced full-planner wait.
  Active remaining length and Z stay separate from staged sums. The
  last wholly future stepper segment provides a 5 ms snapshot gate;
  this is not a foreground WCET guarantee. No ISR is changed.
- **B2, ed67b00, `BEZIER_Z_EDGES`:** retain actual piece chords, but
  form the polygon from relative endpoint tangent edges and a closing
  middle edge. Four norms remain. This avoids some absolute-coordinate
  additions, not the cost of the norms or their float-grid limitation.
- **C1, f3beb53, `BEZIER_Z_GLOBAL`:** retain travelled XY length s and
  a global total T = s + estimated remainder. Each free demand is
  `|dz|*min(s/T, 1)`; a monotone governor keeps the largest demand already
  issued. Update deadlines use length uncertainty and s rather than
  only the remaining segment count. Doubling a missed deadline limits
  repeated work; it is a loose heuristic, not a tolerance certificate.

#### Fit and raw accuracy

Flash is text+data; boot margin is against 32256 bytes. All images fit
32768 bytes without a bootloader. Stack is the largest observed
reduced-dyn watermark, 334 bytes in these builds, not a universal bound.

| Source   | Flash G94 | Flash G93 | G93 boot margin | Static RAM | Measured stack margin | Largest raw Z error mm | Curves over 0.002 |
| -------- | --------- | --------- | --------------- | ---------- | --------------------- | ---------------------- | ----------------- |
| Baseline | 31850     | 31950     | 306             | 1670       | 44                    | 0.01323418             | 1 / 18            |
| A1       | 32108     | 32188     | 68              | 1680       | 34                    | 0.84835024             | 7 / 18            |
| B2       | 32160     | 32260     | -4              | 1670       | 44                    | 0.01323418             | 1 / 18            |
| C1       | 32432     | 32526     | -270            | 1674       | 40                    | 0.04307448             | 2 / 18            |

The accuracy columns are identical for G94 and G93. Raw Z is compared
with cumulative length of the actual emitted XY polyline, using double
arithmetic independently of the firmware bracket. No float-grid or
segment-cap allowance is subtracted. Sampled XY deviation is reported
separately, including cap excess; a small Z error is not an XY guarantee.

The headless timing and dump images do not run the stepper. A1 has no
compute reserve there, so its row measures the eight-piece seed without
optional refinement. That is an important no-reserve case, not evidence
of its accuracy when refinement actually runs. The live motion sweep
checks timing, endpoints and holds, but does not yet record that live
Z accuracy or the number of optional units completed.

#### First target and largest gap

Milliseconds on ATmega328P at 16 MHz; these are timed AVR measurements,
not counts multiplied by a cost model. Each cell is **first / gap**.
Commands and their resets are in `compare/loose.in`.

| Curve                          | Baseline        | A1              | B2              | C1              |
| ------------------------------ | --------------- | --------------- | --------------- | --------------- |
| S 10 mm, Z-3                   | 61.605 / 0.482  | 10.408 / 0.492  | 62.040 / 0.483  | 10.954 / 28.579 |
| S 10 mm, Z-30                  | 61.607 / 0.482  | 10.410 / 0.489  | 62.042 / 0.483  | 46.523 / 59.666 |
| S 20 mm, Z-10                  | 82.666 / 0.485  | 10.404 / 0.491  | 83.249 / 0.484  | 29.421 / 46.802 |
| S 1 m, Z-500                   | 80.948 / 81.628 | 10.514 / 0.493  | 81.082 / 81.076 | 47.691 / 83.221 |
| Collinear handles 99:1, Z10    | 38.992 / 0.446  | 9.476 / 0.453   | 39.473 / 0.446  | 9.973 / 9.082   |
| Turn, 256 segments, Z1000      | 81.115 / 9.185  | 10.445 / 0.486  | 81.403 / 9.278  | 28.938 / 9.477  |
| Cap, 2000 segments, Z50        | 82.674 / 82.297 | 10.431 / 0.499  | 82.820 / 82.266 | 10.972 / 83.972 |

A1 trades accuracy for the short seed in the no-reserve case: the
1 m S is off by 0.759844 mm and the turn by 0.848350 mm. B2 has no
useful general speed win on this toolchain and adds 310 bytes. C1
improves several first delays but does not bound later gaps or total
work: the long S uses 539 pieces instead of 234, with 1316 instead of
952 ms of generator work. A shorter start alone is not a Pareto win.

On the turn, C1 improves raw error from 0.01323418 to 0.00211364 mm
and uses 32 pieces instead of 80. On a translated diagonal, however,
`G0X60000Y60000Z0` followed by
`G5X59996Y59998Z1000I0J0P4Q2F1000`, it gives 0.04307448 mm instead
of the baseline's 0.00023078 mm. There are 43 segments; C1 starts at
11.251 ms, later pauses for 20.306 ms, and eventually sums 26 segments.
The smooth control polygon does not bound the length of the rounded
XY staircase: raw Z is already 0.00201678 mm ahead at point 6, while
the model allows only about 0.00011398 mm there. Checking a deadline
after emission also admits a point beyond its model deadline, but that
smaller effect does not explain the 0.04307448 mm error. A later sum
cannot retract an emitted point; subsequent XY travel can catch up to
the held Z demand. Neither the model deadline nor the monotone governor
certifies the rounded path.

B2's host float build previously measured 0.679152 mm on this same
diagonal because its smooth edges did not bound the interior rounded
staircase. That particular failure does **not** reproduce on AVR 16.2:
the AVR build chooses a 43-segment sum and matches the baseline Z error.
Compiler-dependent gate decisions do not establish a float certificate;
clamping a rounded negative polygon width to zero is not such a proof.

#### Live motion and inverse time

Ordinary 40-program sweep; each count cell is **stops / with planner
blocks queued**. These are event counts, not instantaneous speed
measurements. All live programs issue G94 commands. The two build
columns differ in whether G93 conversion is compiled in; neither
column measures live inverse-time motion.

| Source   | Without G93 option | With G93 option | S10 F5000 time ms | S20 F5000 time ms |
| -------- | ------------------ | --------------- | ----------------- | ----------------- |
| Baseline | 4 / 3              | 9 / 5           | 2665              | 3013              |
| A1       | 4 / 1              | 4 / 1           | 2439              | 2600              |
| B2       | 3 / 3              | 6 / 1           | 2666              | 3015              |
| C1       | 5 / 1              | 5 / 1           | 2847              | 3454              |

The last two columns use the build without the G93 option for six-curve
steep-Z chains, Z-30 per S10 curve and Z-10 per S20 curve. S20
intermediate stop counts are 4, 0,
4 and 5 respectively, with no planner blocks queued in any of those
steep-chain events. Exact XYZ and all six hold/resume endpoints pass.
A1's improved motion times do not prove its live Z accuracy; queued
stops in other programs remain unexplained.

Largest relative commanded G93 time error over these 18 fixed curves:
baseline and B2 0.000583304, A1 0.002932723, C1 0.002932631. The
baseline maximum is the short S without Z; A1/C1 maxima are the
inherited-lead example. Feed conversion still uses the first retained
length, while later Z correction can change the spatial path. These
modes remain approximate despite the option's historical name.

All three arms stay isolated. B2 has no measured speed advantage here;
A1 needs live refinement observation and an accuracy-preserving seed/
deadline design; C1 needs a before-emission error analysis and a smaller
implementation. None is merged or declared the finished solution.

### Earlier comparison: C1, C2 and C3 changes

Evidence: [CI run 45383191415](https://github.com/kimstik/grbl/actions/runs/45383191415),
firmware bd3dd5d, **40 of 40 jobs successful**. The run includes eleven
options on each of avr-gcc 7.3.0, 15.2.0 and 16.2.0, host vectors and
mutants, and the random comparison. All 33 bench/dump/dyn sets were also
checked independently: raw point hashes, command coverage, finite exact
ends, monotone Z, the 40 ordinary programs, four steep-Z programs where
Z is enabled, six holds, stack maxima and production RAM arithmetic.
All 33 production size rows match their ELF sections. The 54 hex
comparisons pass; all 94 mutants are killed.

The target of the comparison remains **$12 = 0.002 mm**. An occasional
larger Z error in return for useful latency is a tradeoff to measure, not
a reason to change $12. There is no new runtime or EEPROM setting for
G5. `BEZIER_Z_SIGMA` defaults to `BEZIER_SIGMA`; its 0.01 build below is
an experimental comparison with a different acceptance threshold, not
the proposed default or an implementation of the same 0.002 target.

The changes and their reasons:

- **C1, 37235f2:** the first pass of mode 2 ends at the actual target,
  not Horner's value near t = 1. Mode 3 sums segments with one point and
  one distance per call, reusing its existing state for the previous
  point. Mode 2 keeps its in-place loop: a common leaf for both passes
  measured larger, so sharing that helper was not retained.
- **C2, f4f8349:** the default mode 3 never emits using an open bracket.
  If pieces cannot vouch for the estimate, it sums the actual segments
  before emitting. A piece-count jump avoids trying every doubling.
  `BEZIER_Z_LOOSE` retains the alternative: use an open estimate at the
  piece cap and estimate again with half the segments remaining.
- **C3, 9e490ba:** a compile-time Z threshold can be varied independently
  for the experiment. Leaving it undefined is byte-identical to C2.
  bd3dd5d extends AVR CI to the 0.01 experiment and its G93 build, and
  to loose G93. No wider threshold is selected for ordinary use.

#### Analysis before measurements

There were two different length errors, not an unexplained random
failure rate. First, an estimate ended at Horner(about 1), while the
polyline ends at target. One coordinate step of length error is
magnified roughly by `|dz| / XY_length`. The constructed two-segment
vector [61] predicted 0.0122 mm of Z error and measured 0.0122 mm; using
target reduced it to 0.000011 mm. The same mismatch in mode 2 explains
its former random outliers; C1 removes it there too.

Second, a half-count re-estimation schedule does not enforce a Z budget.
It can spend too much of Z before another estimate is due. A constructed
collinear parabola with 256 segments and a reversal inside a piece
predicted 0.01336 mm of error at the halfway update and measured about
0.0132 mm. That is an open-bracket policy error, separate from endpoint
rounding. C2 either closes the bracket or sums the segments; loose
intentionally keeps this tradeoff.

In exact geometry, let C be the sum of piece chords, P the sum of
control-polygon lengths, `A = (P - C)/2` and `R = C + A`. The emitted
polyline length L lies in [C, P]. With ideal proportional Z updates,
no end reserve and no early completion, error at travelled length s is
`|dz| * s * |L - R| / (L * R)`, at most `|dz| * A/R`. The implemented
gate `A * (|u| + sigma) <= sigma * C` is conservative for this ideal
case. It is not a proof for rounded control points, float sums, the
small initial reserve or the early-completion threshold. The raw error
statistics below subtract no allowance; passing the bench with its
separate rounding allowance is not a universal float certificate.

An estimated piece costs about 1.12 ms and a segment summed about
0.415 ms on avr-gcc 16.2 at 16 MHz: ratio 2.7, hence the named
`BEZIER_Z_PIECE_COST = 3`. This is a measured cost heuristic, not an
identity for every geometry. A piece-count jump predicts a fourfold
narrowing per doubling, then checks the resulting bracket. It can
overshoot: on the collinear 99:1 line it jumps to 32 requested pieces
where 16 would suffice. This explains the measured latency regression;
it is not evidence against keeping the alternative.

#### Measured first-target delay

Milliseconds, ATmega328P at 16 MHz, avr-gcc 16.2. All columns use
XY tolerance 0.002. These are individual AVR measurements, not the
host work model below. Commands are the exact strings in `avr/lines.txt`.

| Curve with Z                    | zl      | za fallback | za loose | za Z=0.01 experiment |
| ------------------------------- | ------- | ----------- | -------- | -------------------- |
| S, 80 segments                  | 30.878  | 43.098      | 43.129   | 28.020               |
| Collinear handles 99:1          | 67.003  | 38.903      | 38.920   | 9.404                |
| [1], 1950 segments              | 778.082 | 11.039      | 11.045   | 11.038               |
| Large-handle cap, 2000 segments | 767.426 | 10.602      | 10.610   | 10.602               |

C2 changes the S delay from 58.400 to 43.098 ms, but the 99:1 line
from about 25.67 to 38.903 ms. There is no uniform latency win. The
0.01 experiment explains a different tradeoff, not an increase in the
required $12. Loose and fallback have similar times on these four
curves because none needs an open estimate here.

**Long first delays are not solved on every curve.** Where fallback
sums, it pays for the failed estimate as well as the full sum. Local
simavr probes, not the CI latency corpus, measured the following on
avr-gcc 16.2: S 10 mm with Z-30, 61.50 ms; S 1 m with Z-500, 523.77 ms;
a 2000-segment cap curve needing a sum, 852.89 ms. The corresponding
loose long-S probe emitted first at 80.88 ms, but then had an 81.63 ms
mid-curve gap. These probes show why neither policy is a finished
bounded-latency solution. Realtime is serviced between estimator calls;
using spare planner time to refine the estimate opportunistically is
not implemented.

#### Measured Z error and modeled work

Host random: 5000 cases per tolerance, seed 1, 2569 with Z. Error is
against cumulative length of the emitted XY polyline, not true Bezier
arc length. Maxima below are measured with no allowance deducted.
They are sample results, not bounds on all inputs or AVR distributions.

| Mode                 | XY target | Z gate | Over XY target | Over Z gate | Largest Z error mm |
| -------------------- | --------- | ------ | -------------- | ----------- | ------------------ |
| zl                   | 0.002     | n/a    | 0              | n/a         | 0.000067           |
| za fallback          | 0.002     | 0.002  | 0              | 0           | 0.001234           |
| za loose             | 0.002     | 0.002  | 0.1%           | 0.1%        | 0.0033             |
| za Z=0.01 experiment | 0.002     | 0.01   | 1.4%           | 0           | 0.006443           |

At 0.002, fallback accepts a bracket on 835 curves and sums on 1734;
none is open. Loose accepts 844, sums 1498 and leaves 227 open. The
loose policy therefore still performs full sums on many curves: the
short-piece cost cutoff applies to it too. Its small observed fraction
over 0.002 does not impose a 0.01 or 0.02 upper bound. At XY/Z gates
0.01 and 0.1, fallback has no observed excess, with maxima 0.00766 and
0.0492 mm; these are different target settings, not evidence for 0.002.

The following is a **work model**, not a measured AVR latency
distribution: trace piece counts times 1.12 ms plus summed-segment counts
times 0.415 ms, or 0.385 ms per segment for mode 2. It omits parsing
and scheduling variation. For loose it includes work after the first
point, so must not be called first-target delay.

| Mode at XY target 0.002 | Mean ms | Median ms | 99th percentile ms | Largest ms |
| ----------------------- | ------- | --------- | ------------------ | ---------- |
| zl                      | 92.3    | 25.0      | 756                | 770        |
| za fallback             | 51.2    | 25.1      | 567                | 839        |
| za loose                | 36.3    | 25.1      | 184                | 261        |
| za Z=0.01 experiment    | 30.5    | 9.0       | 406                | 839        |

The 0.01 experiment still sums on 53.2% of these Z curves. Neither
that threshold nor loose alone eliminates the slow cases.

#### Measured fit and motion

Production text+data, G5+G5.1. Left is against the 32256-byte limit with
a 512-byte bootloader. All mode-3 rows use 1670 bytes of static RAM,
leaving 378 before stack. Stack is the largest reduced-dyn watermark,
not a bound on every interrupt nesting.

| Option           | Flash 7.3 | Flash 15.2 | Flash 16.2 | Left 16.2 | Stack 16.2 | Stack margin 16.2 |
| ---------------- | --------- | ---------- | ---------- | --------- | ---------- | ----------------- |
| tol-za           | 32416     | 32538      | 31804      | 452       | 334        | 44                |
| tol-za-g93       | 32426     | 32654      | 31912      | 344       | 334        | 44                |
| tol-za-loose     | 32452     | 32556      | 31850      | 406       | 334        | 44                |
| tol-za-loose-g93 | 32458     | 32652      | 31950      | 306       | 334        | 44                |
| tol-za-zs        | 32396     | 32522      | 31796      | 460       | 334        | 44                |
| tol-za-zs-g93    | 32418     | 32638      | 31904      | 352       | 334        | 44                |

Every listed production image fits 32768 bytes without a bootloader;
the mode-3 7.3 and 15.2 images do not fit beside the 512-byte bootloader.
All mode-3 options have measured stack margins 25 / 44 / 44 bytes on
7.3 / 15.2 / 16.2. For reference, 16.2 zl / zl-g93 use 31006 / 31108
bytes, 1645 static RAM and a measured stack margin of 57 bytes.

Ordinary motion sweep, avr-gcc 16.2, 40 G5 programs with Z enabled:

| Option           | Intermediate stops | Of them with planner blocks queued |
| ---------------- | ------------------ | ---------------------------------- |
| tol-zl           | 59                 | 16                                 |
| tol-zl-g93       | 57                 | 6                                  |
| tol-za           | 5                  | 5                                  |
| tol-za-g93       | 9                  | 5                                  |
| tol-za-loose     | 6                  | 3                                  |
| tol-za-loose-g93 | 7                  | 4                                  |
| tol-za-zs        | 3                  | 3                                  |
| tol-za-zs-g93    | 7                  | 3                                  |

Mode-3 queued events include a block entry feed of 2664 mm/min. That
is not instantaneous stepper speed; the mechanism remains unresolved.
No claim of uninterrupted motion follows from green CI.

The four added steep-Z programs are 10 and 20 mm S chains, six curves
each, F1000/F5000, acceleration 2000, host latency 2 ms. All finish at
exact XYZ. On 16.2, fallback and loose have no intermediate stops in
the first three programs; the 20 mm F5000 program has four stops with
no queued blocks. The 0.01 experiment has the same stop counts. At
F5000 the 10 mm program takes 2665 ms with fallback or loose, versus
2481 ms with zl; the 20 mm program takes 3013 versus 2893 ms. The
0.01 experiment takes 2665 / 2923 ms. Thus the extra accuracy/latency
work also changes whole-chain motion time, not just startup delay.

#### G93 and remaining work

Mode 2 with the option converts one path to one 3D feed; after C1 its
host random nominal time error is at most 6.7e-7 at the coarse target
(969 curves) and 1.3e-6 at 0.002 (176 curves). These sample maxima are
not statements about acceleration or physical cycle time.

Mode 3 uses its first retained estimate or segment sum for the feed;
with loose that estimate may be open. It is approximate despite
`BEZIER_EXACT_INVERSE_TIME`. Host random at
0.002 measures maximum relative error 0.0025 for fallback and loose
(176 curves each), and 0.0042 for the 0.01 experiment (176 curves).
The AVR S+Z G93 example measures 8.33e-8 for fallback/loose and
4.35e-5 for the 0.01 experiment. There is no fixed relative-time target:
with zero Z, the Z-error gate cannot constrain relative length error.

The original 7.2% observation was not a reason to abandon the method:
analysis separated the endpoint mismatch from open-bracket error,
and targeted vectors confirmed both mechanisms. C1/C2/C3 and their
CI comparisons are complete, but bounded startup latency, spare-time
refinement, a universally justified float error allowance and the
queued-stop diagnosis are not. Random Z on AVR, physical hardware,
worst-case stack and G18/G19 remain unverified here.
No candidate or tolerance change is selected by these measurements.

### Earlier endpoint fix at 07ebf9a

[CI run 45257065299](https://github.com/kimstik/grbl/actions/runs/45257065299),
firmware 07ebf9a, completes all 28 jobs.

At ca85492 the last piece of an estimate ended at Horner's rule for
t = 1, while the polyline ends at the target itself. Under -ffast-math
the two are about one float step of the machine coordinate apart: the
third difference is regrouped into sums four times as large. The length
estimated was off by that step even with a piece a segment, and Z by
`|dz| * step / length`: more than 0.002 mm once the Z travel is 263 times
the XY length at X-100. The bench hid it under an empirical allowance
for the float grid of XY. What the section below calls the float-grid
limitation was this defect, not a property of the method.

The last piece now ends at the target. **Predicted** for the vector of
[61] (P0 = P1 = P2 at machine X-100, the end 1025 float steps away, two
segments, Z 100 mm): the middle point at 128/1024 of the travel instead
of 128/1025, 0.0122 mm off, and rounding only once fixed. **Measured**
on the host: 0.0122 mm, then 0.000011 mm. Host random, 5000 curves a
tolerance, seed 1, 2569 with Z, error against the emitted polyline with
no allowance, **measured** in CI runs 45219551226 and 45257065299:

| $12   | Curves over $12 before -> now | Largest error mm before -> now | Bracket passed | Of those over $12 before -> now | Predicted |
|-------|-------------------------------|--------------------------------|----------------|---------------------------------|-----------|
| 0.002 | 7.2% -> 1.6%                  | 0.0802 -> 0.0098               | 2169           | 147 -> 0                        | about 0   |
| 0.01  | 1.0% -> 0.04%                 | 0.1024 -> 0.0120               | 2454           | 25 -> 0                         | about 0   |
| 0.1   | 0 -> 0                        | 0.0770 -> 0.0770               | 2569           | 0 -> 0                          | 0         |

The 40 and 1 curves still over are those whose estimates stay open at
64 pieces. The largest error of a curve whose bracket passed is 0.00166
/ 0.00766 / 0.0770 mm.

The test allowance of mode 3 is now derived instead of calibrated: the
worst-case rounding of its running sums, `FLT_EPSILON * (2n + 2 +
min(n - 1, 3 * BEZIER_Z_PIECES_MAX) + 5.5 + zmax/|dz|) + 1e-6` of the Z
travel for n segments, see `z_check` in `host/tb.c`. It grows with n
because it takes every rounding the same way: 5.0e-4 of the travel for
2000 segments, where the 2000 updates of vector [61] measure 1.4e-6.
The G93 time check of mode 3 lost its fixed 1e-4 and its grid term the
same way. Under this bench the firmware of ca85492 fails vectors [59]
and [61]. 81 of 81 mutants are killed; the dump checks (15 curves) and
the strict shared corpus (8 with Z, G94 and G93) pass on all three
compilers.

**Measured** cost, production G5+G5.1. Stack is unchanged, the delays
before the first target are within 0.06 ms of the table below, and the
older modes remain byte-identical to 5601c12 (30 hex comparisons):

| Option     | avr-gcc | Flash before -> now | Left of 32256 | Stack / free | Margin |
|------------|---------|---------------------|---------------|--------------|--------|
| tol-za     | 7.3.0   | 32140 -> 32176      | 80            | 353 / 378    | +25    |
| tol-za     | 15.2.0  | 32352 -> 32388      | -132          | 334 / 378    | +44    |
| tol-za     | 16.2.0  | 31644 -> 31678      | 578           | 334 / 378    | +44    |
| tol-za-g93 | 7.3.0   | 32236 -> 32264      | -8            | 353 / 378    | +25    |
| tol-za-g93 | 15.2.0  | 32456 -> 32490      | -234          | 334 / 378    | +44    |
| tol-za-g93 | 16.2.0  | 31764 -> 31786      | 470           | 334 / 378    | +44    |

The two-pass mode 2 had the same mismatch in its first pass, which summed
the last chord up to Horner's rule at about 1. Its first pass ends at the
target as well since the commit after 07ebf9a.

### One piece at a call: measured fit

[CI run 45219551226](https://github.com/kimstik/grbl/actions/runs/45219551226),
firmware ca85492, completes all 28 jobs. The estimator now returns after
one piece, and the generator services realtime work between calls, with
none of the estimator frame under it. A piece's control points come from
its ends and slopes in the original net, not a de Casteljau copy. The
point helper is shared with emission, and only used by mode 3. Static
state is 25 bytes, 2 more than before; RAM left free is 378 bytes.

**All values in these tables are measured** in that run and in the
previous run 45190827894 (75f4d1c). Flash is production text+data with
G5+G5.1. Stack is the deepest reduced-dyn watermark against production
free RAM. The older modes remain byte-identical to 5601c12 on all three
compilers, for G5 alone and G5+G5.1: 30 hex comparisons.

| Option     | avr-gcc | Flash before -> now | Free now | Stack before -> now | Margin now | Left of 32256 |
|------------|---------|---------------------|----------|---------------------|------------|---------------|
| tol-za     | 7.3.0   | 32198 -> 32140      | 378      | 422 -> 353          | +25        | 116           |
| tol-za     | 15.2.0  | 32384 -> 32352      | 378      | 404 -> 334          | +44        | -96           |
| tol-za     | 16.2.0  | 31650 -> 31644      | 378      | 406 -> 334          | +44        | 612           |
| tol-za-g93 | 7.3.0   | 32368 -> 32236      | 378      | 426 -> 353          | +25        | 20            |
| tol-za-g93 | 15.2.0  | 32534 -> 32456      | 378      | 404 -> 334          | +44        | -200          |
| tol-za-g93 | 16.2.0  | 31766 -> 31764      | 378      | 406 -> 334          | +44        | 492           |

avr-gcc 16.2.0 is the main build for the comparison: za-g93 uses 31764
bytes, leaving 492 beside a 512-byte bootloader, and 334 bytes of stack
against 378 free, a measured margin of 44. za without the G93 conversion
uses 31644 bytes, leaving 612, with the same stack margin. The stack
blocker is removed in the measured sweep; this is not a hardware
qualification or a worst-case stack proof.

The 7.3.0 results are kept as a toolchain comparison: za-g93 fits with
only 20 bytes of flash and 25 bytes of measured stack margin. avr-gcc
15.2.0 still exceeds the bootloader flash limit by 96 / 200 bytes for
za / za-g93, despite its positive stack margin.

The new pieces cost more time. First-target delay, milliseconds at
16 MHz, tol-za, the same lines with Z as in the older table below:

| avr-gcc | S+Z before -> now | [1]+Z before -> now | Cap+Z before -> now | S without Z now | gen/seg no Z / with Z | Max gap us |
|---------|-------------------|---------------------|---------------------|-----------------|-----------------------|------------|
| 7.3.0   | 40.601 -> 56.882  | 8.106 -> 10.848     | 7.933 -> 10.444     | 1.134           | 6397 / 9377           | 510.88     |
| 15.2.0  | 40.559 -> 59.438  | 8.064 -> 11.215     | 7.888 -> 10.780     | 1.187           | 6680 / 9671           | 527.56     |
| 16.2.0  | 40.785 -> 58.283  | 8.093 -> 11.021     | 7.915 -> 10.586     | 1.179           | 6571 / 9484           | 518.69     |

With 16.2.0 and G93 conversion enabled, first-target delays are 58.461 ms
for S+Z, 11.029 ms for [1]+Z and 10.596 ms for cap+Z. The gain on the
long curves comes with the short-S regression shown above, not a uniform
latency improvement.

The gate, doubling and halving schedule are unchanged. No vector pin was
changed; the 26 rewritten mode-3 mutants and all 53 earlier ones are
killed in CI. All dump checks (15 finite curves with Z enabled, 5 with
nonzero Z) and the strict shared corpus (8 with Z, both G94 and G93)
pass on all three compilers. The reduced motion sweep has 40 programs
and 6 holds per job, every final XYZ exact.

There are still stops with blocks queued: tol-za has 1 / 1 / 3 such
stops on 7.3 / 15.2 / 16.2, with largest queued entry feed 2664 / 0 /
2664 mm/min; tol-za-g93 has 1 / 2 / 5, entry feed 0 / 0 / 2664. Entry
feed is not instantaneous speed. Local scratch instrumentation placed
one nonzero-entry event at block 23 of the first 2 mm curve, with 7
blocks queued. That curve has one completed estimate before its first
target, so this event was not a mid-curve estimate. A 31.45 ms gap was
seen between blocks 21 and 22; the responsible path inside
mc_line/realtime/planner is **not verified**. More instrumentation moves
or removes the event; the last bounded scratch sweep did not reproduce
it. No production motion code or ISR was changed to hide it.

Host random, 5000 curves per tolerance, seed 1 (2569 with Z), still
shows the float-grid limitation. At .002 / .01 / .1, za exceeds SIGMA
without allowance on 7.2% / 1.0% / 0 of curves; the largest errors are
.0802 / .1024 / .0770 mm. The bracket passes on 2169 / 2454 / 2569
curves, of which 147 / 25 / 0 exceed SIGMA, all with lead over 1. No
bracket-accepted curve with lead up to 1 exceeds it. Thus fitting the
stack does not turn the algebraic gate into a float-accuracy guarantee.
The random artifacts retain the full lead bands and the separate double
XY reference. Hardware and random Z distributions on AVR remain
**not verified**. The 147 / 25 curves were the end-point defect fixed in
07ebf9a, see above.

### Earlier estimator: negative result at 75f4d1c

The rest of this section records the earlier implementation and its
measurements, not the code now in this tree.

`za` is `-DBEZIER_Z_LINEAR=3`, tried as a way to have the Z of `zl` without
its first pass. **It does not fit an ATmega328P as it is**: in every
measured build the deepest stack is larger than the RAM left free, by 24
to 46 bytes. The measurements are kept as the record of the attempt.

Evidence: [CI run 45190827894](https://github.com/kimstik/grbl/actions/runs/45190827894),
firmware 75f4d1c on branch wip/z-aim. 22 of its 28 jobs succeed. The six
that fail are the simavr jobs of `tol-za` and `tol-za-g93` on the three
compilers, and each fails only at the stack margin test, after its other
steps have run. The workflow of that branch is a reduced one: avr-gcc
7.3.0, 15.2.0 and 16.2.0, the options base, tol, tol-zt, tol-zl,
tol-zl-g93, tol-za and tol-za-g93, and a reduced motion driver. The
sections above come from run 44765744542 and were not measured again.
The firmware of the five earlier options is unchanged: `cmp` of the hex
against 5601c12 passes for G5 alone and G5+G5.1 on each of the three
compilers, 30 builds.

How it works. Before the first target the length of the polyline is
estimated. De Casteljau cuts the curve into pieces of a whole number of
segments each; the chords of the pieces are no longer than the segments
they span, their control polygons no shorter than the curve, so the two
sums bracket the length. The estimate is halfway between them, the
fourth-order rule for a cubic, and exact when a piece is one segment.
Every segment then takes the share of the Z left that its chord is of the
length left. If half the bracket over the length, times the Z left, may
exceed BEZIER_SIGMA, the estimate is made again with twice the pieces,
from BEZIER_Z_PIECES (8) to BEZIER_Z_PIECES_MAX (64). If the bracket is
still too wide then, the estimate stays in force ("open") and the length
is estimated again when half of the segments are left. Without a Z word,
and without a G93 feed to convert, no estimate is made.

The gate is algebra, not a guarantee. In exact arithmetic a bracket that
passes keeps Z within BEZIER_SIGMA of the straight line through the
length of the polyline. The firmware works in floats, so the tables give
the error against the polyline actually emitted, with no allowance, and
against a double model of the same polyline. The pass criteria of the
vectors and of the dump check do add an allowance for the float grid of
XY, 4*sqrt(segments)*FLT_EPSILON*reach/length of the Z travel, whose
factor is calibrated, not derived.

**Every number in the tables of this section is measured** in that run.
Numbers marked local were measured with avr-gcc 7.3.0 and simavr on one
PC and are in no CI artifact.

### Sizes, cycles and stack of the prototype

Flash is firmware text+data with G5+G5.1, delta against base of the same
compiler; 32256 is the flash beside a 512-byte bootloader. `gen/seg` is
sum(gen)/sum(segments) over the 10 finite accepted rows of avr/lines.txt
without a Z word, and over the 4 with one in G94. Stack is the deepest
watermark of the reduced motion driver against the RAM the production
firmware leaves free: 403 bytes, and 380 with za, whose state is 23 bytes
of static RAM.

| Option     | avr-gcc | Flash bytes (delta) | Left of 32256 | RAM free | gen/seg no Z | gen/seg with Z | Stack used | Stack margin |
|------------|---------|---------------------|---------------|----------|--------------|----------------|------------|--------------|
| base       | 7.3.0   | 30672 (+0)          | 1584          | 403      | 5125         | -              | 343        | +60          |
| base       | 15.2.0  | 31152 (+0)          | 1104          | 403      | 6282         | -              | 338        | +65          |
| base       | 16.2.0  | 30406 (+0)          | 1850          | 403      | 6153         | -              | 338        | +65          |
| tol        | 7.3.0   | 30700 (+28)         | 1556          | 403      | 5116         | -              | 343        | +60          |
| tol        | 15.2.0  | 31184 (+32)         | 1072          | 403      | 6308         | -              | 338        | +65          |
| tol        | 16.2.0  | 30438 (+32)         | 1818          | 403      | 6178         | -              | 338        | +65          |
| tol-zt     | 7.3.0   | 30792 (+120)        | 1464          | 403      | 5398         | 5488           | 343        | +60          |
| tol-zt     | 15.2.0  | 31260 (+108)        | 996           | 403      | 6546         | 6615           | 338        | +65          |
| tol-zt     | 16.2.0  | 30520 (+114)        | 1736          | 403      | 6428         | 6497           | 338        | +65          |
| tol-zl     | 7.3.0   | 31176 (+504)        | 1080          | 403      | 11833        | 12034          | 347        | +56          |
| tol-zl     | 15.2.0  | 31740 (+588)        | 516           | 403      | 14469        | 14616          | 342        | +61          |
| tol-zl     | 16.2.0  | 30924 (+518)        | 1332          | 403      | 14063        | 14210          | 344        | +59          |
| tol-zl-g93 | 7.3.0   | 31286 (+614)        | 970           | 403      | 11846        | 12039          | 351        | +52          |
| tol-zl-g93 | 15.2.0  | 31834 (+682)        | 422           | 403      | 14429        | 14576          | 344        | +59          |
| tol-zl-g93 | 16.2.0  | 31048 (+642)        | 1208          | 403      | 14095        | 14242          | 344        | +59          |
| tol-za     | 7.3.0   | 32198 (+1526)       | 58            | 380      | 6089         | 8877           | 422        | -42          |
| tol-za     | 15.2.0  | 32384 (+1232)       | -128          | 380      | 6343         | 9106           | 404        | -24          |
| tol-za     | 16.2.0  | 31650 (+1244)       | 606           | 380      | 6218         | 8924           | 406        | -26          |
| tol-za-g93 | 7.3.0   | 32368 (+1696)       | -112          | 380      | 6089         | 8876           | 426        | -46          |
| tol-za-g93 | 15.2.0  | 32534 (+1382)       | -278          | 380      | 6343         | 9106           | 404        | -24          |
| tol-za-g93 | 16.2.0  | 31766 (+1360)       | 490           | 380      | 6218         | 8917           | 406        | -26          |

tol-za does not fit beside the bootloader with avr-gcc 15.2.0, tol-za-g93
neither with 7.3.0 nor with 15.2.0. Exact G93 costs 170 / 150 / 116 bytes
over za. Largest gap between two targets in microseconds, planner
excluded, 7.3 / 15.2 / 16.2: tol 258.94 / 356.44 / 350.19; tol-zt
277.38 / 369.50 / 363.94; tol-zl 373.19 / 461.44 / 447.12; tol-za
486.75 / 499.69 / 490.00. None of the bench lines leaves an estimate open,
so no estimate in the middle of a curve is in these gaps; see below.

### Delay before the first target

Milliseconds at 16 MHz from the start of the line to the first target.
S is `G5I-5J5P5Q-5X-20Y0`, the line `G5X0Y100I0J99P0Q1`, [1] and the cap
line as above; "with Z" is the same line with a Z word. Target counts
are for $12 = 0.002.

| Option | avr-gcc | S (80) | S with Z | Line with Z (197) | [1] (1950) | [1] with Z | Cap (2000) | Cap with Z |
|--------|---------|--------|----------|-------------------|------------|------------|------------|------------|
| tol    | 7.3.0   | 1.022  | -        | -                 | 1.273      | -          | 1.147      | -          |
| tol    | 15.2.0  | 1.130  | -        | -                 | 1.379      | -          | 1.213      | -          |
| tol    | 16.2.0  | 1.118  | -        | -                 | 1.365      | -          | 1.198      | -          |
| tol-zt | 7.3.0   | 1.039  | 1.125    | 1.044             | 1.290      | 1.379      | 1.167      | 1.253      |
| tol-zt | 15.2.0  | 1.141  | 1.228    | 1.139             | 1.391      | 1.478      | 1.226      | 1.314      |
| tol-zt | 16.2.0  | 1.133  | 1.218    | 1.127             | 1.380      | 1.470      | 1.213      | 1.302      |
| tol-zl | 7.3.0   | 25.116 | 25.206   | 54.900            | 630.732    | 630.822    | 632.318    | 632.406    |
| tol-zl | 15.2.0  | 31.590 | 31.680   | 68.973            | 797.386    | 797.478    | 787.229    | 787.320    |
| tol-zl | 16.2.0  | 30.685 | 30.775   | 66.764            | 775.667    | 775.761    | 764.952    | 765.044    |
| tol-za | 7.3.0   | 1.117  | 40.601   | 18.695            | 1.378      | 8.106      | 1.246      | 7.933      |
| tol-za | 15.2.0  | 1.168  | 40.559   | 18.533            | 1.417      | 8.064      | 1.251      | 7.888      |
| tol-za | 16.2.0  | 1.158  | 40.785   | 18.635            | 1.408      | 8.093      | 1.238      | 7.915      |

za makes 3 estimates for S with Z (8, 16 and 32 pieces), 2 for the line
and 1 for [1] and for the cap line. So it is 78 to 100 times sooner than
zl on the two long curves, and later than zl on the short one. In G93 the
S with Z waits 25.419 / 31.699 / 30.999 ms with zl and
40.501 / 40.720 / 39.834 ms with za.

Local: one estimate of 8 / 16 / 32 / 64 pieces delays the first target of
[1] with Z by 8.04 / 13.98 / 26.00 / 49.20 ms (BEZIER_Z_PIECES and
BEZIER_Z_PIECES_MAX both set to that number), about 12 thousand cycles a
piece with realtime work serviced after each. When all four tries are
needed (8+16+32+64 pieces) the wait is about 90 ms, and after an open
bracket it was measured again in the middle of the curve:
`G5X10Y0I3J12P3Q-12Z-3` (124 targets, 4 tries, passed) 89.8 ms before the
first target; the same with `Z-30` (8 tries, 1 left open) 89.8 ms and a
largest gap of 90.6 ms; `G5X1000Y0I300J1200P300Q-1200Z-500` (1238
targets, 14 tries, 3 left open) 90.8 ms and 93.4 ms. Nothing is queued
during an estimate.

### Z error of the three modes

Host bench in single precision, `--random 5000 1` for each tolerance
(`-DTB_ARC_TOLERANCE`), 2569 curves with Z travel. Per curve the largest
distance of Z from the straight line through the length travelled along
the emitted polyline, at the segment ends, in mm and as a share of the Z
travel. "Over" is the share of curves where that is more than
BEZIER_SIGMA, with no allowance. Lead is Z travel over XY length; the
random curves are adversarial there (0.1 to 100 mm of Z on 0.01 to 1000
mm of XY scale), hence the three bands. The last column is the same
error against a double model of the polyline.

| BEZIER_SIGMA | Mode | Over SIGMA | Largest mm | Median / max of Z travel | Lead to 0.1: over, mm | Lead 0.1 to 1: over, mm | Lead over 1: over, mm | Double model: over, mm |
|--------------|------|------------|------------|--------------------------|-----------------------|-------------------------|-----------------------|------------------------|
| 0.002        | zt   | 99.6%      | 31         | 1.7e-1 / 4.3e-1          | 99.9%, 23             | 100%, 28                | 99.1%, 31             | 99.6%, 31              |
| 0.002        | zl   | 4.9%       | 0.080      | 2.2e-6 / 1.7e-3          | 0, 0.000072           | 0, 0.000090             | 11.7%, 0.080          | 4.7%, 0.060            |
| 0.002        | za   | 6.6%       | 0.082      | 2.6e-5 / 9.5e-3          | 0, 0.0019             | 0.4%, 0.0033            | 15.4%, 0.082          | 8.2%, 0.062            |
| 0.01         | zt   | 96.8%      | 32         | 1.7e-1 / 4.5e-1          | 99.4%, 23             | 100%, 28                | 92.9%, 32             | 96.8%, 32              |
| 0.01         | zl   | 0.6%       | 0.10       | 1.8e-6 / 1.6e-3          | 0, 0.000062           | 0, 0.000074             | 1.4%, 0.10            | 0.5%, 0.10             |
| 0.01         | za   | 0.3%       | 0.032      | 3.6e-5 / 2.1e-2          | 0, 0.0077             | 0, 0.0074               | 0.7%, 0.032           | 0.5%, 0.027            |
| 0.1          | zt   | 62.4%      | 32         | 1.5e-1 / 4.5e-1          | 60.3%, 23             | 72.3%, 28               | 59.8%, 32             | 62.4%, 32              |
| 0.1          | zl   | 0          | 0.025      | 9.4e-7 / 8.4e-4          | 0, 0.000044           | 0, 0.000065             | 0, 0.025              | 0, 0.016               |
| 0.1          | za   | 0          | 0.077      | 1.6e-5 / 3.8e-2          | 0, 0.049              | 0, 0.077                | 0, 0.028              | 0, 0.077               |

With lead over 1 the curves over 0.002 mm are mostly tiny in XY (0.005
to 0.6 mm) with tens of mm of Z, 100 mm from the machine origin: there
the float grid of XY is in every chord, and zl, which sums the very
chords it travels, is off as well. So the two length-based modes are
alike there, and neither holds 0.002 mm.

The bracket gate of za, same runs:

| BEZIER_SIGMA | Gate passed          | Passed and over SIGMA     | Largest passed mm              | Open | Open and over SIGMA | Estimates mean / most | Early ends |
|--------------|----------------------|---------------------------|--------------------------------|------|---------------------|-----------------------|------------|
| 0.002        | 2168 of 2569 (84.4%) | 131, all with lead over 1 | 0.0819 (0.0013 with lead to 1) | 401  | 9.5%                | 3.17 / 16             | 15         |
| 0.01         | 2454 of 2569 (95.5%) | 7, all with lead over 1   | 0.0317 (0.0077 with lead to 1) | 115  | 0.9%                | 2.02 / 8              | 27         |
| 0.1          | 2569 of 2569         | 0                         | 0.0770                         | 0    | -                   | 1.12 / 4              | 26         |

A bracket that passed did not keep Z within BEZIER_SIGMA in 131 curves at
0.002 mm and 7 at 0.01 mm, all of them with lead over 1; with lead up to
1 none of the 1196 and 1395 that passed was over. Curves left open
have no bound from the gate at all; their measured errors are in the
table above.

On the AVR itself 13 curves with Z were checked on each of the three
compilers: the 5 of avr/lines.txt with `tb --dump`, and the 8 of the
shared core corpus with `Z-3`, BEZIER_SIGMA 0.004 and `tb --dump-strict`.
None failed. In the core corpus Z is off the emitted polyline by 0.00016
to 0.0020 mm after 1 to 4 estimates; in [1] with `Z-3` at 0.002 mm by
0.0013 mm after one estimate of 8 pieces, whose bracket allows 0.0020.
The three open curves above were checked locally with 7.3. The
distribution over random curves on the AVR is **not verified**.

G93 with za takes its feed from the first estimate that is not tried
again, and nothing gates the error of the time. Host random curves in
G93: the nominal time is off 1/F by at most 3.1% (median 1.7e-5, 969
curves) at 0.1 mm and 1.2% (176 curves) at 0.002 mm, against 0.16% and
0.018% with zl. In the core corpus on the AVR it is off by 5.6e-5 to
6.5e-4. BEZIER_EXACT_INVERSE_TIME is not exact with mode 3.

### Motion with the reduced driver

`-DTB_DYN_SPLINES_ONLY` leaves the G1 and G2 reference programs out of
dyn.c so that the image fits the flash with za: 40 G5 programs (2 and 5
mm curves, F1000 to F5000, 500 and 2000 mm/s2, host latency 2 and 16 ms)
and 6 feed holds, the same driver for every option, every curve with
`Z-0.2` when a Z option is on. `check_dyn.py` requires all 40 + 6 rows
and X, Y and Z of every end point exact: 840 runs and 126 holds, none off.
The firmware under test is the production code; the numbers are not
comparable with the full sweep of the sections above. Order in each cell
7.3 / 15.2 / 16.2; `Stops` excludes the expected final stop, as before.

| Option     | Programs with stops | Total stops  | Stops with queued block | Max queued entry feed |
|------------|---------------------|--------------|-------------------------|-----------------------|
| base       | 0 / 0 / 0           | 0 / 0 / 0    | 0 / 0 / 0               | 0 / 0 / 0             |
| tol        | 0 / 2 / 2           | 0 / 3 / 2    | 0 / 3 / 1               | 0 / 0 / 0             |
| tol-zt     | 2 / 2 / 1           | 11 / 4 / 1   | 1 / 0 / 0               | 0 / 0 / 0             |
| tol-zl     | 8 / 9 / 7           | 50 / 69 / 58 | 14 / 8 / 11             | 0 / 0 / 0             |
| tol-zl-g93 | 8 / 9 / 7           | 49 / 67 / 60 | 15 / 8 / 17             | 0 / 0 / 0             |
| tol-za     | 1 / 2 / 1           | 2 / 3 / 1    | 0 / 2 / 1               | 0 / 2413 / 0          |
| tol-za-g93 | 1 / 1 / 0           | 1 / 2 / 0    | 0 / 1 / 0               | 0 / 2413 / 0          |

za stops far less often than zl, which waits out its whole first pass.
But with avr-gcc 15.2.0 two of its stops came with a block still queued
whose entry feed was 2413 mm/min (2 mm curves, 2000 mm/s2, F4000 and
F5000); zl has no such stop at a nonzero entry feed in this sweep. Its
mechanism is **not verified**, and the entry feed of a block is not the
speed at the moment of the stop.

### What the prototype shows

- Stack. za needs 404 to 426 bytes where 380 are free. Local A/B with
  7.3: with protocol_execute_realtime called between whole estimates
  instead of after every piece the deepest stack is 353 bytes, a margin of
  27; but then 19 of 21 stops in the sweep come with a block queued, at
  entry feeds up to 3013 mm/min. So the frame of the estimator (the copy
  of the control net and the sums) under the realtime path is what does
  not fit, and taking the call out brings back the stops with a block
  queued at a nonzero entry feed. An estimator that keeps its state
  static and returns after every piece was not tried.
- Flash. 1200 to 1498 bytes over tol, where zl costs 476 to 556.
- Time. One estimate is cheap against a first pass over 2000 points, but
  the doubling makes a short curve with Z wait longer than zl does, and
  after an open bracket about 90 ms more were measured in the middle of
  the curve. Without a Z word za still costs 973 cycles a segment over
  tol with 7.3, and 35 and 40 with 15.2 and 16.2: every point goes through
  the step function, Z or no Z.
- Accuracy. Median error 12 to 20 times that of zl, largest error 6 to 45
  times, as shares of the Z travel; both modes far below zt. In mm a
  bracket that passed kept Z within BEZIER_SIGMA in every curve with lead
  up to 1, and not in every one with lead over 1.
- 73 of 73 mutants are killed, 20 of them in the code of mode 3: weights
  of the estimate, the polygon sum, the part already travelled, the exact
  case, the gate and its Z term, doubling, the next estimate, the early
  end, the reserve at the start, the chord, the sign, the exact end, and
  the G93 feed. One of them was first killed only by a counter; random
  curves on the mutant then gave the out-and-back vector of [59], where
  it takes Z 0.0165 mm past the target and back.
- Not verified: hardware; avr-gcc 17; random curves on the AVR; $12 = 0
  with za; whether a smaller estimator frame can be had without the flash
  it would cost.

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

This remains a sampled diagnostic, not a two-sided Hausdorff proof:
**dense curve to polyline, plus emitted vertices to dense curve**. The
model has TB_DENSE = 4000 parameter intervals; the reverse check does not
sample chord interiors, and curve Z is evaluated at segment ends. For a borderline or
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

| Point | Supplied exact-float reference         | Host parser net (9 significant digits) |
|-------|----------------------------------------|----------------------------------------|
| P0    | (0, 0)                                 | (0, 0)                                 |
| P1    | (-2361.66455078125, 614.281494140625)  | (-2361.66455, 614.281433)              |
| P2    | (-1883.6595458984375, 481.83642578125) | (-1883.65942, 481.836395)              |
| P3    | (-1973.58837890625, 498.7366638183594) | (-1973.58826, 498.736633)              |

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
