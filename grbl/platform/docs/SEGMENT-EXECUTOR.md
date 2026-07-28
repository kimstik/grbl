# The segment executor prototype: what runs, what does not, and what hardware needs next

Status: **landed.** Implements stages 4 (`seg-link`, host side) and 5 (Verilated
FPGA executor) of `SEGMENT-RUNTIME-PLAN.md`, on top of the stage 1–3 work in
`SEGMENT-CONFORMANCE.md`. Nothing here is in any default build path; with `EXT`
empty not one byte of any shipped binary moves.

The one-sentence version: **a far-side segment executor now exists as
synthesisable RTL, is driven by bytes the real firmware shipper produced from
the real frozen ring, reproduces the frozen ISR's tick trace bit for bit over
the whole committed corpus, and place-and-routes on a real iCE40 part at a
measured clock rate.**

## The chain, end to end

```
committed vector
   │
   ├─► oracle.c ── grbl/stepper.c compiled from the tree ─► golden .gtrace
   │                    (the frozen ISR IS the specification)
   │
   ├─► seg_exec_ref.py ──────────────────────────────────► must equal golden
   │
   ├─► tb_segx ─► segx_rx.v ─► segx_exec.v ──────────────► must equal golden
   │      (testbench builds the frames)
   │
   └─► frozen ring ─► seg_link.c ─► SOF/TAG/LEN/CRC bytes
                          │           (the firmware shipper, verbatim)
                          └─► tb_segx --wire ─► segx_rx ─► segx_exec
                                                      └─► must equal golden
```

Three registered subjects, thirteen vectors, one gate:
`ci/seg_conformance.py`. All three run in CI.

```
seg_conformance: OK - 13 vector(s), 3/3 subject(s) run, 2 declared divergence(s);
goldens fresh, subjects bit-exact.
```

## What is new here

| | path |
|---|---|
| Profile F framing | `grbl/platform/extensions/common/segwire.h` |
| host shipper | `grbl/platform/extensions/seg-link/` (`EXT=seg-link`) |
| shipper driver + byte dump | `tools/hosted/wire_dump.c` → `build/hosted/seg_wire` |
| RTL executor | `tools/hosted/subjects/rtl/segx_{top,exec,rx,slot,crc8}.v` |
| Verilator testbench | `tools/hosted/subjects/rtl/tb_segx.cpp` |
| iCE40 synthesis | `tools/hosted/subjects/rtl/ice40/` |
| ratchet extensions | `ci/seg_conformance.py`, `ci/seg_corpus_baseline.txt` |

## Nothing moved

- `grbl.hex` MD5 **`79af184e67b27defd27a39309ac53563`**, unchanged.
- `tools/build_artifacts.py check`: **OK — 62 file(s) verified fresh across 11
  unit(s)**, zero modified `.bin`/`.hex`/`.syms`/`.elf`.
- All eight pre-existing ratchets green, plus the ninth.
- The one file this work added inside `grbl/` is a header
  (`extensions/common/segwire.h`) that no firmware TU includes unless
  `EXT=seg-link` is asked for. `grbl/stepper.c` was not touched at all —
  stage 2's two seam hunks were already enough.

`ch32v006+seg-link` and `ch32v006+seg-trace` are still **not** CI rows, for the
reason stage 2 gave: a row means a new warn baseline and an additive
`artifacts/` unit (~1.4 MB per refresh). That remains an integrator decision.

## The executor

`segx_exec.v` is written from the SEGX/1 §3.3 contract text, not transliterated
from `stepper.c` — a transliteration would agree with `stepper.c` for the wrong
reason. It replicates, and the corpus pins, every ordering an implementer is
likely to get wrong:

- the **one-tick pipeline**: the port bits emitted at tick *k* are the ones
  computed at tick *k−1*, because stock writes the port at the top of the ISR
  from the previous ISR's result;
- **strict `>`** in the Bresenham compare, with 32-bit wrapping adds;
- counters initialise **only on a block change** and persist across segments
  within a block;
- the **homing lock gates the pulse only, after** the position update, so locked
  axes keep counting;
- the probe samples **before** that tick's Bresenham updates;
- AMASS shift applied to the block's pre-multiplied steps at segment load;
- a new `cycles_per_tick` takes effect on the arriving segment's **first** tick,
  without stopping the counter.

Twelve of thirteen vectors matched on the very first run. The thirteenth is the
declared `n_step == 0` divergence.

### Two divergences from stock, both declared and enforced

1. **`n_step == 0` FAULTs** (SEGX/1 §3.6.1). Stock wraps to a 65536-tick ghost
   segment that never retires — established with a committed trace in stage 3,
   not argued from a comment.
2. **`cycles_per_tick >= 3`.** The executor's pipeline is three clocks deep; a
   shorter tick raises `SEGX_FAULT_TOO_FAST` rather than silently skipping work.
   At 48 MHz this caps the step rate at 12 MHz. Stock has no such limit.

Divergence (1) is machine-checked through `divergences.txt` + `expected/`.
Divergence (2) is unreachable by any physical g-code and is enforced in fabric.

## Timing: the measurement the plan asked for, and the negative result behind it

`SEGMENT-RUNTIME-PLAN` §4 stage 5 said the UP5K-vs-HX8K choice "changes cycle
bookkeeping and must be made **before** goldens freeze". The goldens are frozen,
so it had to be measured, not assumed.

**First attempt failed.** The obvious shape — one tick, one clock, three 32-bit
Bresenham lanes — placed at **11.9 MHz on UP5K and 30.4 MHz on HX8K**, against a
48 MHz target. nextpnr named the path: `q_rd` → FIFO mux → `gen % 5` →
block-store mux → AMASS shift → 32-bit add → 32-bit compare/subtract, unbroken.

Nothing in that chain is needed until the *next* tick, which is thousands of
clocks away, so it was split into a 3-clock head prefetch, a
register-to-register tick edge, and two Bresenham phases of one carry chain
each. After:

| part | LCs | BRAM | Fmax | at 48 MHz | at 16 MHz |
|---|---|---|---|---|---|
| iCE40HX8K-CT256 | 3437 / 7680 (44 %) | 0 / 32 | 59.9 MHz | **PASS** | PASS |
| iCE40UP5K-SG48 | 3437 / 5280 (65 %) | 0 / 30 | 24.6 MHz | FAIL | **PASS** |

(yosys 0.33, nextpnr-ice40 0.6, `--placer heap --seed 1`.)

**The answer, and it does not move the goldens.** HX8K runs the ch32v006's
48 MHz MCO directly. UP5K needs F_TICK at or below ~20 MHz — which costs
nothing, because `cycles_per_tick` is contractually denominated in the
stepper-timer tick rate and not the CPU clock (§3.1), F_TICK is a session CONFIG
field, and the committed corpus already runs at 16 MHz, the AVR reference rate.
A UP5K board simply configures a lower F_TICK and the same goldens apply.

Cheaper still, if UP5K at 48 MHz is wanted: the design has 65 % LC occupancy and
zero BRAM, so the block store could move into an EBR and the prefetch absorb the
read latency. That is a real option, not speculation — but it is not needed for
either named target.

## Two physical findings the golden trace cannot express

**The step pulse can be longer than the tick.** On `04-nstep1-burst`
(`cycles_per_tick = 99`, 100 clocks per tick) with `$0` = 160 clocks:

```
tb_segx: nstep1-burst cycles=1419 frames=14 credit=10 underrun=0
         pulses=3 width_ok=2 truncated=6 min_dir_setup=0
```

Seven ticks, three rising edges. The step line never returns low, so a driver
sees three steps where the firmware counted seven. This is **inherited, not
introduced** — stock AVR does the same thing, its pulse-reset ISR simply fires
after the next step ISR — but on stock nothing counts it. Here it is a number on
every run. A real board must clamp `$0` against the maximum step rate; that
clamp does not exist in stock and is not added here.

**DIR gets zero setup time in stock.** Several vectors measure
`min_dir_setup=0`: a direction change lands on the same edge as a pulse rise.
The executor has a `dir_settle` parameter; `--dir-settle 8` raises the measured
minimum to 8 clocks (167 ns at 48 MHz) and **every trace stays bit-identical**,
because the trace records the latched register, not the pin. The iCE40 wrapper
sets it to 8. This is the one place the executor is deliberately better than the
thing it replicates.

## Every new gate was broken to prove it fires

Six new failure modes, each exercised.

### (e) An RTL defect the oracle does not share

`sum0 > cur_sec` → `>=` in one Bresenham lane:

```
   02-amass-levels.gvec: subject rtl (verilated) != oracle
     --- oracle
     +++ rtl (verilated)
      T 4 6000 1999 0x00 0x07 0 4 4 4
     -T 5 8000 999 0x00 0x07 0 4 4 4
     +T 5 8000 999 0x00 0x07 0 5 4 4
exit=1     (8 subject-vector pairs flagged)
```

### (f) The tick divider off by one — caught by measurement, not by the trace

`tickdiv <= period` → `period - 1`:

```
   rtl (verilated) exited 3 on 01-basic-xy-diagonal.gvec
     tb_segx: tick 2 clock mismatch: measured 999, model 1000
   rtl (verilated) exited 3 on 05-clamp-0xffff.gvec
     tb_segx: tick 2 clock mismatch: measured 65535, model 65536
```

The trace's `clk` column comes from counting simulated clock edges; the
arithmetic model is computed in parallel and compared at every tick, so the two
cannot both be wrong in the same way.

### (g) A declared divergence deleted from the manifest

```
  - 13-adversarial-nstep0.gvec: subject rtl (verilated) diverges from the oracle
  - declared divergences: 0 present, baseline says 1 (edit ci/seg_corpus_baseline.txt
    deliberately, with owner sign-off per SEGMENT-RUNTIME-PLAN §3.6)
```

### (h) A declared divergence that does not actually diverge

The expected trace replaced by the oracle's golden:

```
  - 13-adversarial-nstep0.gvec: subject rtl (verilated) declares a divergence (§3.6.1)
    whose expected trace is IDENTICAL to the oracle - declare nothing, or diverge
```

This is the fence that stops the divergence mechanism becoming a way to launder
a passing subject.

### (i) The subject's toolchain missing

```
$ PATH=<no verilator> ci/seg_conformance.py --require-rtl
  - subject rtl (verilated): toolchain missing and --require-rtl was given
```

and without the flag, on a developer machine:

```
seg_conformance: SKIP subject rtl (verilated) - its toolchain is not installed on
this machine. CI runs it with --require-rtl, where this is a failure.
seg_conformance: OK - 13 vector(s), 1/2 subject(s) run, ...
```

The CI job installs verilator and always passes `--require-rtl`.

### (j)–(l) Shipper defects — and one that found a real hole

Three defects injected into `seg_link.c`:

- **drop the BLK frame**: 12 vectors fail;
- **do not advance the sequence number**: 11 vectors fail, caught by the
  receiver's sequence check rather than by the trace;
- **ship the ring slot where the generation counter belongs**: **PASSED.**

That third one is the interesting one. It passed because the executor's only use
of `blk_gen` was `gen % 5`, and for slots 0–4 that is the identity. So the 8-bit
generation the wire format carries *specifically* so that wrap-drops are
detectable (§3.2) was **decorative**, and a stream of raw ring indices was
indistinguishable from a correct one.

Fixed where it belongs — in the executor. Generations must advance by exactly
one per block; anything else is `SEGX_FAULT_GEN_GAP`. The same injected defect
now fails on `12-blkgen-wrap`, the vector written for exactly this, at the
4 → 0 slot wrap:

```
     -X 25 12000 DRAIN pwm=0 idle=1
     -Z ticks=25 clk=12500 pos=2,3,3 probe=0,0,0 probe_tick=0
     +X 13 6000 FAULT code=9 gen_gap
     +Z ticks=12 clk=6000 pos=2,4,3 probe=0,0,0 probe_tick=0
exit=1
```

### (m) The transport sink elided

`EXT=seg-link` RELEASE with `volatile` removed from the null transport's
mailbox:

```
seg-link live_check: FAIL - seg_link_null_mailbox is not in .../grbl_ch32v006+seg-link.elf.
  The transport sink was optimized away, which means the shipper's
  stores went with it: the extension is linked but inert.
make: *** [Makefile:364: ../../../build/grbl_ch32v006+seg-link.elf] Error 1
```

and with it restored:

```
seg-link live_check: OK  seg_link_null_mailbox = 00000032 bytes (>= 32) in
.../grbl_ch32v006+seg-link.elf
```

This is the same failure seg-trace shipped once for real: LTO deletes a sink
nothing reads, then the stores, then transitively the whole shipper, and every
other ratchet still passes. The guard asserts **storage**, not a function
symbol — an elided mailbox still leaves `seg_link_tx` in the image.

## Cost on the ch32v006

`riscv64-unknown-elf-size`, RELEASE:

| | text | bss |
|---|---|---|
| bare | 39224 | 2752 |
| `+seg-link` | 39764 | 2800 |
| delta | **+540 B** | **+48 B** |

The whole SEGX/1 shipper, CRC included. The frozen ISR is still compiled in and
is dead in Profile F; reclaiming it is a later optimisation, not a correctness
question.

## What is NOT proven

Stated plainly, because everything above is simulation.

- **No hardware.** Nothing has run on a ch32v006, an iCE40, or a wire. Every
  number is Verilator, yosys or nextpnr.
- **No bitstream.** `synth.sh` stops at nextpnr — no `icepack`, no PCF, no
  board, no I/O timing constraints.
- **No reverse link.** The executor's credit, position, probe latch, events and
  fault code are exposed as *ports* and read directly by the testbench. Nothing
  serialises them onto a return wire, and nothing on the host deserialises them.
  `seg_link_credit()` exists and is correct; nobody calls it from an IRQ.
- **No board transport at all.** SPI1+DMA, PB6/EXTI6, PC4 MCO, the KILL pin, and
  the `STP_TMR_INT_ENA` / `STP_TMR_INT_DIS` overrides carrying WAKE and the
  HALT_FLUSH transaction (§3.5 R6) are unwritten. `EXT=seg-link` links a
  volatile mailbox instead.
- **No producer.** `st_prep_buffer` is linked into both hosted binaries and
  never called. Its float path is out of scope by design; ring contents come
  from committed vectors.
- **Nothing about `ENABLE_DUAL_AXIS`**, the non-AMASS prescaler profile, `W > 5`,
  or topology T2 (executor-wired limits).
- **Nothing about metastability** beyond the two-flop synchronisers in
  `ice40/segx_ice40.v`.
- **Nothing about RP2040 / Profile M.** Deferred exactly as §5 argued: its bare
  port is a larger prerequisite than this entire simulation chain, and Profile M
  collapses most of the contract into shared memory.
- **The `--credit-latency` stress is a probe, not a gate.** At
  `--byte-gap 32 --credit-latency 480`, `04-nstep1-burst` drains early and the
  testbench fails loudly with the exact §3.5 R1 stutter signature. That number
  is a *simulated* budget; the real one comes from a bench.

## What a person with the hardware does next

In order. Each step has a check that fails visibly if skipped.

1. **Pick the part.** HX8K if F_TICK is to be 48 MHz. UP5K is fine if F_TICK is
   ≤ 20 MHz — set it in CONFIG and the same goldens apply, no RTL change. Run
   `ice40/synth.sh <part> <MHz>` first and read the PASS/FAIL line.

2. **Get a bitstream.** Write the PCF for the chosen board, add `icepack` to
   `synth.sh`, and constrain the SPI pins. Nothing above did this.

3. **Wire the clock, not two clocks.** PC4 (MCO) on the ch32v006 feeds the
   FPGA's `clk_48`. Host and executor must share one oscillator — the whole
   timing model assumes zero drift, and there is no resynchronisation anywhere
   in SEGX/1.

4. **Write `seg_link_tx()` for the board** (SPI1 remap 011 + DMA1 ch2/ch3),
   replacing `seg_link_null.c`, and set `SEG_LINK_TRANSPORT`. The post-link
   guard will need to move to whatever storage the real transport owns; do not
   just delete it.

5. **Bring up forward-only first.** Send CFG + BLK + SEG + WAKE by hand, with
   the KILL line asserted, and scope the step pins. `segx_rx`'s `frames_ok`
   counter and `fault` register tell you whether the link or the executor is
   the problem. A CRC mismatch or a sequence gap is a wiring/clocking problem,
   not a contract problem.

6. **Then the reverse path**, which is the largest remaining piece of work:
   serialise `{consumed_seq, state, position[3], events, fault}` out of the
   fabric, deserialise on the host, and call `seg_link_credit()` from the link
   IRQ. Until this exists the host's tail never advances and motion stops after
   five segments — which is a *safe* failure and a good first milestone.

7. **Measure the credit round trip on the bench** and ratchet it. The stress
   knobs exist for exactly this: `tb_segx --byte-gap N --credit-latency M` over
   the corpus reproduces the drain-early failure at the measured numbers, so the
   bench result becomes a simulated regression instead of a note.

8. **The KILL line before any motion that can hit a limit.** It is the required
   Profile F default (§3.5 R5) and it gates the step pins combinationally in
   `segx_ice40.v`. Mailbox-only kill is a declared degraded level needing owner
   sign-off.

9. **`STP_TMR_INT_DIS` → HALT_FLUSH last.** It is the only place the host and
   executor need a synchronous transaction, and it is what makes jog cancel,
   probe end and `mc_reset` safe. Everything before it can be tested with the
   machine free-running.

10. **`$0` against the top step rate.** See the merged-pulse finding above:
    stock's `$0` semantics are unchecked and at high step rates the pulse
    swallows the gap. The executor reports it; nothing enforces it.

## Open items for the owner

- **Sign off the two declared divergences** (§3.6), or reject them:
  `n_step == 0` → FAULT, and `cycles_per_tick >= 3`.
- **Decide on CI rows** for `ch32v006+seg-trace` and `ch32v006+seg-link`. Each
  costs a warn baseline and an additive `artifacts/` unit.
- **Decide the part**, because it is the only remaining thing that could move a
  golden — and per the table above, neither choice does.
