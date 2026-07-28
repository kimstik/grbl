# `seg-link` — ship the segment stream over a SEGX/1 Profile F link

The host half of the segment boundary. It reads the frozen SPSC ring through
the seam's TU exports at the publish strobe, serialises canonical SEGX/1 frames
into a CRC-protected byte stream, and pumps the reverse credit count back into
`segment_buffer_tail`. Nothing in it knows about SPI, DMA, or any silicon: the
transport is one function, `seg_link_tx()`.

Build: `make -C grbl/platform/ch32v006 EXT=seg-link`
Unit name: `ch32v006+seg-link`. Outputs land at
`build/grbl_ch32v006+seg-link{,_dbg}.{elf,hex,bin}`; the canonical
`grbl_ch32v006.*` is never touched by an EXT build.

## Seam claimed

| macro | override |
|---|---|
| `GRBL_SEG_PUBLISH()` | original store **first**, unchanged, then `seg_link_publish_hook()` |
| `GRBL_STEPPER_TU_EXPORTS` | `SEG_TAP_READERS` (readers **and** `grbl_seg_tail_advance`) |

The publish override never suppresses the store. `SEG_TAP_LOADERS` — the only
fragment that writes ring slots — is test infrastructure and is absent here, as
in every firmware build.

## The one piece of real reconstruction: `blk_gen`

`segment_t::st_block_index` is a mod-5 ring slot. The wire carries an 8-bit
**generation counter**, because a slot index cannot distinguish block 1 from
block 6 and "inequality triggers Bresenham reinit" would miss the wrap.

The shipper recovers the generation by counting. `st_next_block_index()`
pre-increments from 0, so blocks claim slots 1,2,3,4,0,1,… while generations run
1,2,3,4,5,6,… — that is exactly `gen % 5 == slot`, which is
`SEGX_GEN_TO_SLOT()`, which is what the executor applies in reverse. So the
shipper needs no state from the producer: every slot change it observes is one
new block.

This is gated, not asserted. `ci/seg_conformance.py`'s `rtl via seg-link wire`
subject runs this exact file over the real ring, captures the bytes, and replays
them through the Verilated executor. Shipping the raw slot where the generation
belongs faults `12-blkgen-wrap` at the 4 → 0 wrap with `FAULT code=9 gen_gap`.

## Wire

`extensions/common/segwire.h`. `SOF(0xa5) TAG LEN PAYLOAD[LEN] CRC8`, CRC-8/ATM
over TAG+LEN+PAYLOAD. Tags: `0x01` SEG (8 B), `0x02` BLK (19 B), `0x03` CFG
(19 B), `0x04` WAKE (1 B). The frame boundary **is** the validity strobe, which
is how Profile F dissolves the missing barrier at `stepper.c`'s publish store:
there is no window in which payload and strobe can be reordered, because the
strobe is the last byte of the payload.

Ordering: CFG (carrying `$0`/`$2`/`$3`/`$6`, the homing lock, and POS_SET), then
BLK-before-first-referencing-SEG, then WAKE once the ring has filled — stock
fills the segment buffer and *then* calls `st_wake_up()`, and a replayed stream
has to be a valid in-order session rather than a batch.

Measured stream sizes over the committed corpus: 63–238 bytes per vector,
12 bytes per segment plus 23 per block.

## Flow control

Credit-based, window W = 5, credits returned on **completion** as a cumulative
count. `seg_link_credit()` takes the absolute count and advances the tail by the
delta through `grbl_seg_tail_advance()` — the seam's single sanctioned writer of
the consumer-owned index. Absolute, never a delta on the wire (SEGX/1 §3.5 P1):
a dropped reverse frame heals at the next one, with no retransmit protocol.

W = 5 is not a knob. It keeps the frozen block-slot pigeonhole proof valid
verbatim and pins committed motion to stock's ~50 ms, which is what preserves
feed-hold / override / parking latency semantics.

## Cost, measured

ch32v006 RELEASE, `riscv64-unknown-elf-size`:

| | text | bss |
|---|---|---|
| `grbl_ch32v006.elf` (bare) | 39224 | 2752 |
| `grbl_ch32v006+seg-link.elf` | 39764 | 2800 |
| delta | **+540 B** | **+48 B** |

That is the whole shipper including the CRC. The frozen ISR is still compiled
into the image and is dead in Profile F (it is never armed); reclaiming it is a
later optimisation, not a correctness question.

## What is NOT here

The board transport. Named explicitly because "it builds" must not be mistaken
for "it works":

- SPI1 remap 011 (NSS/PB0, SCK/PB1, MISO/PB2, MOSI/PC0) + DMA1 ch2/ch3
- PB6/EXTI6 executor→host event line
- PC4 MCO exporting the clock, so host and executor share one oscillator
- a KILL pin, combinationally gating step generation in fabric (§3.5 R5)
- the `STP_TMR_INT_ENA` override (POS_SET + CONFIG + WAKE(epoch)) and the
  `STP_TMR_INT_DIS` override (the HALT_FLUSH transaction, §3.5 R6)
- the reverse *deserialiser*: `seg_link_credit()` exists and is proven, but
  nothing yet parses credit/event/position frames off a wire to call it

Until a board supplies `seg_link_tx()`, `SEG_LINK_TRANSPORT=null` links
`seg_link_null.c`: a **volatile** mailbox plus byte/frame counters, with a
post-link guard on the storage. Without the volatile, RELEASE LTO deletes the
mailbox, the stores, and transitively the entire shipper — and every other
ratchet still passes. `live_check.sh` was verified by removing the qualifier and
confirming it fires.

## Config tuple

`seg_tap.h` is written for the one tuple SEGX/1 §3.1 fixes — N_AXIS 3,
SEGMENT_BUFFER_SIZE 6, AMASS on with MAX_AMASS_LEVEL 3, VARIABLE_SPINDLE on,
ENABLE_DUAL_AXIS off. A build with a different tuple fails to compile by member
name. `ENABLE_DUAL_AXIS` is the one element with no structural tell: the wire
does not carry the dual pins, so a dual-axis board must not use this extension
until SEGX/2 defines them.
