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
| 10 | Stack on ATmega328P: static chain and with interrupts           | avr, avr dynamic       | margin 52-65 bytes; Z estimate: negative   |
| 11 | Planner starvation while streaming curves at speed              | avr dynamic            | base: none; $12 + length: stops            |
| 12 | Cusp: the planner stops at the reversal                         | host `junction`        | pass                                       |
| 13 | Smooth chain with implicit I/J: no corner at the joins          | host `set smooth`      | pass                                       |
| 14 | Handles on the chord: same as G1                                | host vectors           | pass                                       |
| 15 | G5.1 equals G5 with 2/3-rule handles                            | host `same`            | pass                                       |
| 16 | Quarter circle within the Bezier-circle error                   | host `circle`          | pass                                       |
| 17 | Translation by G91/G92, G20 vs G21: same segments               | host `same`            | pass                                       |
| 18 | Reversed curve within tolerance                                 | host vector            | pass                                       |
| 19 | Check mode, `$J=G5` rejection, mode changes before implicit I/J | host vectors           | pass                                       |
| 20 | Mutation testing                                                | host `mutate.sh`       | 73 of 73 killed, including options         |
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
| 57 | Z by estimate: bracket gate, pins, exact with a piece a segment | host `z.vec`, random   | pass; error measured, gate no guarantee    |
| 58 | Z by estimate: open brackets estimated again; segment cap       | host `z.vec`, avr      | pass                                       |
| 59 | Z by estimate: early end, lost first chord, far from origin     | host `z.vec`           | pass: never past the target or backwards   |
| 60 | G93 by estimate: one feed, time off within the bracket          | host `z.vec`, avr      | pass; time off up to 3.1% in random curves |

## 10, 11, 35: motion under simavr

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
  block's entry feed, not instantaneous ISR speed. Current CI reports
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
- `g93` suffix: `-DBEZIER_EXACT_INVERSE_TIME`, requires zl.

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

## Z by an estimate of the length ahead: prototype, negative result

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
