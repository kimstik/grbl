# Segment-boundary conformance: what landed, and the proof it can fail

Status: **landed.** Implements stage 2 (core seam) and stage 3 (seg-trace +
hosted oracle + ninth ratchet) of `SEGMENT-RUNTIME-PLAN.md`, plus the stage-1
`EXT=` plumbing the plan sequenced first. Stages 4 (seg-link) and 5 (Verilated
executor) are untouched.

The one-sentence version: **the frozen ISR is now an executable specification,
replayable on any host, with a ratchet that fails when it changes and a slot
where a candidate executor plugs in.**

## What exists now

| thing | path | role |
|---|---|---|
| the seam | `grbl/stepper.c` (2 touch points + a 17-line `#ifndef` block) | the only edit to the frozen core |
| accessor set | `grbl/platform/extensions/common/seg_tap.h` | `GRBL_STEPPER_TU_EXPORTS` bodies, readers / loaders |
| wire format | `grbl/platform/extensions/common/segframe.h` | SEGX/1 §3.2 frames + LE codec |
| the oracle | `tools/hosted/` | frozen `stepper.c` on x86, in virtual time |
| the corpus | `tools/hosted/corpus/*.gvec` + `*.gtrace` | 13 vectors, committed goldens |
| a subject | `tools/hosted/subjects/seg_exec_ref.py` | independent executor, bit-exact |
| the ratchet | `ci/seg_conformance.py` | ninth ratchet, 3 gates |
| the tap | `grbl/platform/extensions/seg-trace/` | on-target capture, `EXT=seg-trace` |

## The seam, and why the binaries did not move

Two touch points, `#ifndef` defaults in-file:

```c
#ifndef GRBL_SEG_PUBLISH
  #define GRBL_SEG_PUBLISH() segment_buffer_head = segment_next_head
#endif
#ifndef GRBL_STEPPER_TU_EXPORTS
  #define GRBL_STEPPER_TU_EXPORTS
#endif
```

`GRBL_SEG_PUBLISH()` replaces the strobe at what was stepper.c:1049;
`GRBL_STEPPER_TU_EXPORTS` sits alone on the last line. Both defaults produce a
token stream identical to the original, so codegen cannot move — and that was
verified, not argued:

- `grbl.hex` MD5 **`79af184e67b27defd27a39309ac53563`**, unchanged.
- `tools/build_artifacts.py build` regenerated every artifact from a clean
  rebuild of all 11 units, and `git` reported **zero** modified `.bin`, `.hex` or
  `.syms` files.
- Section-by-section `readelf -x` on the ch32v006 DEBUG `.elf` built from both
  sources: `.text`, `.symtab`, `.strtab`, `.data`, `.bss`, `.srodata`, `.init`,
  `.riscv.attributes` byte-identical; only `.debug_abbrev`, `.debug_aranges`,
  `.debug_info`, `.debug_line`, `.debug_macro`, `.debug_str` differ.

That last bullet is the whole delta: DWARF records line numbers, and the seam
adds lines. Nine DEBUG `.elf` hashes in `artifacts/MANIFEST.sha256` were
refreshed for that reason and no other; `artifacts/README.md` documents the
shape so the diff can never be mistaken for codegen drift.

## The three gates, and the proof each can fire

This project has shipped guards that could not fire twice (`assert_no_double.sh`
once checked for libgcc symbol names ARM never emits; `-fanalyzer` is inert under
`-fsyntax-only`). So each gate below was verified by breaking the thing it
guards. Verbatim output follows.

### (a) Staleness gate — the frozen consumer changed

Injected defect: `st.counter_y > step_event_count` → `>=` in the Bresenham Y
comparison (stepper.c:439).

```
seg_conformance: building hosted oracle (frozen grbl/stepper.c on x86)
   02-amass-levels.gvec: frozen-consumer replay != golden
     --- golden
     +++ replay
     @@ -7,26 +7,26 @@
      T 4 6000 1999 0x00 0x07 0 4 4 4
     -T 5 8000 999 0x00 0x07 0 4 4 4
     -T 6 9000 999 0x00 0x00 0 5 5 5
     ...
  - 02-amass-levels.gvec: replay differs from committed golden
  - 03-block-boundary.gvec: replay differs from committed golden
  - 06-decel-tail.gvec: replay differs from committed golden
  - 07-invert-masks.gvec: replay differs from committed golden
  - 12-blkgen-wrap.gvec: replay differs from committed golden
  - 02-amass-levels.gvec: subject seg_exec_ref.py diverges from the oracle
  - 03-block-boundary.gvec: subject seg_exec_ref.py diverges from the oracle
  - 06-decel-tail.gvec: subject seg_exec_ref.py diverges from the oracle
  - 07-invert-masks.gvec: subject seg_exec_ref.py diverges from the oracle
  - 12-blkgen-wrap.gvec: subject seg_exec_ref.py diverges from the oracle

If the frozen consumer legitimately changed, re-read the golden MD5 gate first.
Only then: ci/seg_conformance.py --regen
exit=1
```

5 of 13 vectors caught a one-character change to a comparison operator.

### (a′) Staleness gate — a golden was hand-edited

One position field changed in `05-clamp-0xffff.gtrace`:

```
   05-clamp-0xffff.gvec: frozen-consumer replay != golden
     --- golden
     +++ replay
     @@ -6,3 +6,3 @@
      T 3 131072 65535 0x00 0x01 0 3 0 0
     -T 4 196608 200 0x00 0x01 0 4 1 0
     +T 4 196608 200 0x00 0x01 0 4 0 0
      T 5 196809 200 0x00 0x01 0 5 0 0

  - 05-clamp-0xffff.gvec: replay differs from committed golden
EXIT=1
```

### (b) Subject gate — a defect the oracle does not share

Injected into `seg_exec_ref.py` only: drop the homing axis lock.

```
     -T 2 1000 999 0x00 0x01 0 2 2 2
     ...
     +T 2 1000 999 0x00 0x07 0 2 2 2
     ...
      X 9 8000 DRAIN pwm=0 idle=1

  - 08-homing-lock.gvec: subject seg_exec_ref.py diverges from the oracle
EXIT=1
```

The oracle was untouched, so only the subject gate fired — which is the point:
the two gates are independent.

### (c) Corpus monotonicity — vectors removed

```
seg_conformance: building hosted oracle (frozen grbl/stepper.c on x86)

  - corpus shrank: 11 vector(s) present, ratchet says 13
EXIT=1
```

### (d) The extension's own guard — a tap that taps nothing

Not a conformance gate, but the same discipline, and it caught a real defect the
first time it ran rather than in a drill. The initial RELEASE build of
`seg-trace` linked cleanly and passed all eight existing ratchets while
capturing nothing: LTO correctly proved no code in the image reads the capture
ring and deleted both arrays and every store into them. `nm` on that build:

```
$ riscv64-unknown-elf-nm --print-size build/grbl_ch32v006+seg-trace.elf | grep seg_trace
2000069f 00000001 b seg_trace_head
200006a3 00000001 b seg_trace_last_blk
2000069c 00000002 b seg_trace_overrun
200006a4 00000001 b seg_trace_primed
0000186a 0000003a t seg_trace_push
2000069e 00000001 b seg_trace_tail
                                    <- seg_trace_buf and seg_trace_len: gone
```

Fix: the ring is `volatile` (its reader is outside the program — a debugger
dumping RAM, before any drain transport is wired), and `live_check.sh` runs at
link time. Verified by removing `volatile` again:

```
seg-trace live_check: FAIL - seg_trace_buf is not in ../../../build/grbl_ch32v006+seg-trace.elf.
  The capture ring was optimized away; the tap records nothing.
  (This is what happens without the volatile qualifier - see seg_trace.c.)
make: *** [Makefile:364: ../../../build/grbl_ch32v006+seg-trace.elf] Error 1
```

and green with it restored:

```
seg-trace live_check: OK  seg_trace_buf = 00000640 bytes (>= 640) in ../../../build/grbl_ch32v006+seg-trace.elf
```

The check deliberately asserts **storage**, not a function symbol: an elided ring
still leaves `seg_trace_publish_hook` in the image, so checking the hook would
have been a guard that cannot fire.

## What the corpus establishes about the frozen consumer

Beyond regression detection, three goldens answer questions the plan left open
or that a far-side implementer would otherwise get wrong.

**`13-adversarial-nstep0` closes SEGMENT-RUNTIME-PLAN §3.6.1 with evidence.** The
plan flagged that the stale ISR comment at stepper.c:372 ("Can sometimes be
zero") contradicts the header contract at :321 ("expects at least one step per
segment"), and asked for an instrumented trace before freezing the `n_step == 0`
FAULT. Here it is: stock sets `st.step_count = 0`, the unconditional
post-decrement at :471 wraps it to 65535, and the segment becomes a 65536-tick
ghost that never retires — the trace runs to `TICK_LIMIT` with position still
climbing and no `DRAIN`. So the divergence in §3.6.1 is not "executor is stricter
than stock"; it is "stock has no defined behaviour here at all". Trapping is
right, and it is now backed by a committed trace instead of by reasoning about a
comment.

**`02-amass-levels` pins the AMASS invariant numerically.** Four segments in one
block at levels 0..3 produce 4 physical steps each, in 4/8/16/32 ticks at
periods 1999/999/499/249 — 8000 virtual clocks per level, identically. Same
distance, same wall time, different ISR overdrive. A shift applied to the wrong
operand or at the wrong moment breaks the clock column, not just the step column.

**`08-homing-lock` and `09-probe-trigger` pin the two orderings an executor is
most likely to invert.** The homing lock masks the pulse *after* the position
update, so locked axes keep counting (Y and Z advance 1→8 while only bit 0 ever
pulses). The probe samples *before* that tick's Bresenham updates, so the latch
at tick 5 reads `4,4,0` while the position at tick 5 is `5,5,0` — one step, and
exactly the step a probe measurement is about.

## Deviations from the plan, with reasons

1. **Stage 1 (`EXT=` plumbing) landed here too**, because the stage that was to
   produce it returned nothing and stage 3 cannot exist without it.

2. **`seg_tap.h` does not `#ifdef` on the config tuple; it fails to compile.**
   The plan assumed the accessor macros could branch on `ADAPTIVE_MULTI_AXIS_
   STEP_SMOOTHING` / `VARIABLE_SPINDLE`. They cannot: an extension prelude is
   injected *before* the board prelude, i.e. before `config.h` has decided
   anything, while the macro bodies expand at the *end* of stepper.c where the
   tuple is decided. Branching at include time would silently pick the wrong
   fields. So the header does not branch — it is written for the one tuple
   SEGX/1 §3.1 fixes, and a build with a different tuple fails by member name.
   This is strictly better: it is the same refusal SEGX/1 demands of an executor
   on a CONFIG mismatch, moved to compile time and impossible to fake.

3. **The hosted oracle substitutes for `hal.h` by predefining `GRBL_HAL_H`**
   rather than gaining a `PLATFORM_HOSTED` branch there. A branch in `hal.h`
   would shift line numbers in a header every port compiles, churning nine DEBUG
   `.elf` hashes for a file no firmware build reads.

4. **`ch32v006+seg-trace` is not a CI row.** A row means a
   `ci/warn_baseline_ch32v006+seg-trace.txt` and an additive `artifacts/` unit
   (~1.4 MB of tracked blobs on every refresh). That is an integrator decision
   about repo growth, not something to slip into this batch. The extension
   builds, passes no-DP / boot-init / boot-integrity / warn ratchet, and its
   frames are exercised on every `seg_conformance.py` run because the oracle
   shares `segframe.h` with it byte for byte.

5. **No `--regen` in CI, ever.** `seg_conformance.py --regen` rewrites goldens
   and raises the corpus ratchet. It is a deliberate act; the failure message
   says to re-read the golden MD5 gate first.

## What this does not prove

- Nothing about a real transport: no CRC, no sequence numbers on a wire, no
  credit pump, no reverse channel. SEGX/1 §3.4–§3.6 are specified, not built.
- Nothing about the producer. `st_prep_buffer` is linked into the oracle and
  never called; its float path is out of scope by design.
- Nothing about `ENABLE_DUAL_AXIS`, the non-AMASS prescaler profile, or `W > 5`.
- Nothing on hardware. Every gate here is simulation and CI.
