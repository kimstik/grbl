# `seg-trace` — capture the segment stream at the publish strobe

Records every published SEGX/1 frame into a RAM ring, in the canonical wire
layout, for offline replay through `tools/hosted/`. It is the observability half
of the segment-runtime work: no hardware, no protocol, no far side — just an
answer to *what did the producer actually publish*.

Build: `make -C grbl/platform/ch32v006 EXT=seg-trace`
Unit name: `ch32v006+seg-trace`. Outputs land at
`build/grbl_ch32v006+seg-trace{,_dbg}.{elf,hex,bin}` and objects under
`build/ch32v006/<board>/<BUILD>+seg-trace/` — the canonical `grbl_ch32v006.*`
is never touched by an EXT build (verified: after a full `EXT=seg-trace` RELEASE
build, `build/grbl_ch32v006.bin` still hashes to the committed artifact).

## Seam claimed

| macro | override |
|---|---|
| `GRBL_SEG_PUBLISH()` | original store **first**, unchanged, then `seg_trace_publish_hook()` |
| `GRBL_STEPPER_TU_EXPORTS` | `SEG_TAP_READERS` only |

The publish override never suppresses the store, and the export set is
read-only: `SEG_TAP_LOADERS` (which writes ring slots) is test infrastructure
and is deliberately absent from this and every other firmware build — nothing
but the frozen producer may write a slot.

## Record stream

```
[0]      tag  0x42 'B' = BLK (1 + 19 bytes) | 0x53 'S' = SEG (1 + 8 bytes)
[1..]    the canonical frame, little-endian (extensions/common/segframe.h)
```

A BLK record is emitted immediately before the first SEG that references it,
which satisfies SEGX/1 invariant F1 for free: the tee runs at the publish point,
and program order in `st_prep_buffer()` already completes the block fill before
the first referencing segment publishes.

`blk_gen` on the wire is a **generation counter**, not the mod-5 ring index the
slot carries; the hook lifts one to the other (+1 per change). That is what makes
a wrap-drop detectable downstream — a stream carrying the raw index cannot tell
generation 1 from generation 6.

## Costs and limits, stated

- **RAM**: measured on ch32v006 RELEASE, `.bss` 2752 → 3432, i.e. **+680 B** for
  the default 32 records (32 × 20 B bodies + 32 B of lengths + indices). Sized
  for the ch32v006's 8 KB. `make ... EXT=seg-trace SEG_TRACE_RECORDS=n`;
  `ext.mk` refuses n < 4 (a ring of 1–3 is degenerate).
- **Flash**: measured on ch32v006 RELEASE, `.text` 39224 → 39760, i.e. **+536 B**.
- **The ring is `volatile`, and that is not decoration.** Its reader is outside
  the program (a debugger dumping RAM, before any drain transport is wired), so
  without `volatile` RELEASE LTO deletes the arrays and every store into them —
  measured, not hypothesised: the first RELEASE build of this extension linked
  cleanly, passed every existing ratchet, and captured nothing.
  `live_check.sh` runs at link time and fails if the ring is missing or short;
  it was verified by removing `volatile` and confirming the build stops.
- **Time in the producer path**: two frame encodes and a memcpy-sized copy per
  segment, i.e. per `DT_SEGMENT` = 10 ms. Not in the ISR.
- **Overrun is counted, never silent** (`seg_trace_overruns()`). A capture with a
  non-zero overrun count is not a valid conformance vector; the count is the
  proof that it isn't.
- **Config tuple**: `N_AXIS 3`, AMASS on, `VARIABLE_SPINDLE` on. The first two
  are enforced structurally at compile time (see `common/seg_tap.h`).
  `ENABLE_DUAL_AXIS` is the one element with no structural tell — the wire does
  not carry the dual pins, so a dual-axis build would capture an incomplete
  stream. Out of scope this pass; do not enable both.
- **No drain transport ships here.** `seg_trace_drain()` is the API; wiring it to
  a `$`-command or a spare UART is a board decision, deliberately not made for
  you.

## CI

No permanent CI row yet. Adding one means a `ci/warn_baseline_ch32v006+seg-trace.txt`
and an additive `artifacts/` unit (~1.4 MB of tracked blobs) — an integrator
decision, not something to slip in. The extension is exercised today by building
it, and the frames it emits are exercised on every run of `ci/seg_conformance.py`
because the oracle shares `segframe.h` with it byte for byte.
