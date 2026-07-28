# Segment-Runtime Extension Plan (`EXT=seg-*`) — seam, contract, stages, prototype

Status: **PLAN, not landed.** Synthesized 2026-07-28 from three independent
design passes over the verified segment-boundary analysis (forward wire
format compiled-probe-verified on all 5 ABI families; reverse channel
exhaustively inventoried from the ISR call tree; injection/#ifndef
discipline measured live; ch32v006+FPGA and RP2040 feasibility studies).
This document is executable by an agent that has not seen those sessions:
every load-bearing line number below was re-verified against this tree at
the time of writing. Where the three designs disagreed, the decision and
the reason are recorded in §7.

Owner directives this plan implements verbatim: the segment runtime is an
**extension**, not a platform — it changes the geometry of the periphery,
not the silicon answer; injection is a second `-include` ordered **before**
the board prelude; CI stays a **sum** (every platform bare + each extension
on one representative platform); and nothing may poison the project: with
`EXT` empty every unit's RELEASE binary stays byte-identical to
`artifacts/` and `grbl.hex` MD5 stays `79af184e67b27defd27a39309ac53563`.

Prerequisite reading for the implementer: `grbl/platform/PLAN.md`,
`grbl/platform/CONTRACTS.md` §0 (injection), §3 (stepper timer), §4 (pulse
reset), §5 (ISR wiring), §36 (F_CPU width). Never renumber CONTRACTS.md;
new sections in §6 below are marked `## §NEW.` with slug anchors and the
integrator assigns numbers.

## 0. The boundary, in one paragraph (established facts)

Producer (`st_prep_buffer()`, main loop) → consumer (`ISR_STEP`) crosses
one lock-free SPSC seam in `grbl/stepper.c` with two payload channels:
HOT `segment_t segment_buffer[6]` (stepper.c:97; one ~8 B entry per
DT_SEGMENT = 10 ms nominal) and COLD `st_block_t st_block_buffer[5]`
(stepper.c:78; ~20 B per planner block, referenced by index from segments).
One index owned per side: `segment_buffer_tail` (stepper.c:129, ISR-only
writer), `segment_buffer_head` (stepper.c:130, main-only writer);
`segment_next_head` (stepper.c:131) is producer-private. Publication is a
single strobe store, **stepper.c:1049**
(`segment_buffer_head = segment_next_head;`), with **no barrier** between
the payload stores (segment slot fill, and the strobe-less block fill at
:700-747) and the strobe. Correct on one core by program order; silently
fatal across any bus/core boundary. The frozen core cannot be patched to
add a fence — so the seam macro below must **own the instant of
publication**, which either carries the fence (shared-memory transport) or
dissolves the problem into framing (message transport, where the frame
boundary is the strobe).

## 1. The core seam: two touch points, byte-identity proven not asserted

Exactly two textual hunks in `grbl/stepper.c`. Nothing else in the frozen
core changes, ever, for any `seg-*` extension.

**Hunk 1 — the publish strobe.** stepper.c:1049

```c
// before
    segment_buffer_head = segment_next_head;
// after
    GRBL_SEG_PUBLISH();
```

with the default supplied in the same file, immediately after the ring
statics block (after stepper.c:131):

```c
// Extension seam (docs/SEGMENT-RUNTIME-PLAN.md §1). Default expands to the
// original statement, token for token. Overridable only by predefinition
// (extension prelude via -include, which precedes all TU content).
#ifndef GRBL_SEG_PUBLISH
#define GRBL_SEG_PUBLISH() segment_buffer_head = segment_next_head
#endif
```

**Hunk 2 — the TU export hook.** Last line of stepper.c:

```c
GRBL_STEPPER_TU_EXPORTS
```

with its default in the same guard block as hunk 1:

```c
#ifndef GRBL_STEPPER_TU_EXPORTS
#define GRBL_STEPPER_TU_EXPORTS
#endif
```

The default expands to **zero tokens** — literally nothing reaches the
compiler. An extension overrides it with *function definitions* that are
compiled inside stepper.c's TU and therefore have legitimate,
compiler-blessed access to the file statics and the private
`segment_t`/`st_block_t` types. The canonical accessor set an override
must provide (declared in the extension's own header; definitions expand
here):

```c
uint8_t grbl_seg_head_get(void);
uint8_t grbl_seg_tail_get(void);
void    grbl_seg_tail_advance(uint8_t n);   // credit pump, mod SEGMENT_BUFFER_SIZE
void    grbl_seg_read(uint8_t idx, grbl_seg_frame_t *out);  // field-copies into
void    grbl_blk_read(uint8_t idx, grbl_blk_frame_t *out);  // canonical frames (§3.2)
```

The accessors copy **fields**, not structs: the extension never mirrors
the private struct layouts, so there is no duplicated-truth drift risk and
no dependence on the compile-option-sensitive in-memory ABI (segment_t is
7 B on AVR / 8 B on 32-bit; st_block_t 18/20 B; layout reshapes with
VARIABLE_SPINDLE/AMASS/dual — measured by compiled probes on all 5 ABI
families). The wire format is the canonical frame (§3.2), never the
compiler's struct image.

**Why these two and only these two.** The publish strobe is the one
statement in the frozen core that no macro, no linker trick, and no
attribute can otherwise reach (file-static ring, no existing seam macro at
the site), and it is the only place a barrier/serialization hook is
semantically correct — program order already guarantees the COLD block
fill (:700-747) completes before the first referencing segment's publish,
so one hook fences/ships **both** payload classes. The export hook is what
makes the reverse path (credit pump writing `segment_buffer_tail` from a
link IRQ, trace tap reading slots) possible without changing any storage
class: bare builds keep `static` linkage and identical codegen. Everything
else the extension needs already sits on the existing injection axis:
`ISR_STEP`/`ISR_STEP_RESET` wiring, `STP_TMR_INT_ENA/DIS`,
`STP_TMR_PERIOD_SET`, `STP_PULSE_RESET_*`, `GPIO_MWO/MRD`,
`HAL_CRITICAL_SECTION_BEGIN/END`, plus public symbols (`sys_position`,
`sys_probe_state`, `sys_probe_position`, `sys.homing_axis_lock`,
`system_set_exec_state_flag`, `st_go_idle`, `st_wake_up`,
`spindle_set_speed`).

**Byte-identity argument.** With no extension, `GRBL_SEG_PUBLISH()`
expands to the exact original token sequence and `GRBL_STEPPER_TU_EXPORTS`
expands to nothing; the `#ifndef` blocks contribute zero tokens to code.
Identical post-preprocessing token stream ⇒ identical TU ⇒ identical
codegen on every toolchain — no appeal to optimizer behavior. `.hex`/`.bin`
carry no line info, so line-number shift is irrelevant to every gate.

**Proof procedure (run at the stage-2 gate, and continuously thereafter —
no new machinery needed):**
1. `make -C grbl/platform/atmega328p validate` → golden MD5
   `79af184e67b27defd27a39309ac53563` unchanged. (AVR takes the seam too:
   the defaults are in-file, so stepper.c is self-contained — no reliance
   on `-include` reaching AVR.)
2. `tools/build_artifacts.py check` → every committed RELEASE blob for all
   11 units byte-identical.
3. `ci/warn_ratchet.py` per port → identical TU emits identical
   diagnostics; baselines untouched.
4. Remaining ratchets (boot, init, no-DP, numbering, pinmap) unchanged by
   construction.

The one **policy decision** this hangs on: relaxing the byte-for-byte
*source* freeze of stepper.c by two hunks while the *binary* freeze stays
ratcheted. Gate #1's own wording ("seam macros must expand to
byte-identical code by default") presupposes exactly this; it still needs
explicit owner sign-off in stage 0, and the plan is void without it. The
zero-source-edit alternatives were examined and rejected: TU-replacing
stepper.c forks ~1000 lines of prep logic (poison); `objcopy
--globalize-symbol` / two-pass linking is LTO-fragile, invisible to
review, and — decisively — cannot inject an ordering operation between the
payload stores and the strobe.

## 2. Extension mechanism: layout, plumbing, discipline

### 2.1 Directory layout

```
grbl/platform/extensions/<kebab-name>/
    prelude.h    # macro injection; header guard; defines GRBL_EXT_<NAME>
    ext.mk       # source add/exclude, knob validation, hard $(error) on conflict
    ext.md       # per-extension contract doc (platform.md precedent)
    *.c *.h      # implementation TUs
```

Rules, each load-bearing:
- **No file named `platform.h` at the extension root** —
  `ci/pinmap_overlap_check.py` discovers ports as `grbl/platform/*/` dirs
  containing a root `platform.h` and would adopt the extension as a
  phantom port.
- `prelude.h` defines `GRBL_EXT_<NAME>` and **never** `GRBL_PRELUDE` —
  hal.h:34's lost-prelude `#error` is the proven backstop against a
  dropped board prelude and must not be masked.
- `ext.mk` contributes `EXT_SOURCES` and may `filter-out` core TUs; if an
  extension and the platform both supply the same TU that is a hard
  `$(error)`, never a link-order accident.

### 2.2 EXT= plumbing and include ordering

In each participating port Makefile (ch32v006 first; the pattern is the
owner's directive verbatim):

```make
EXT ?=
CFLAGS += $(foreach e,$(EXT),-include ../extensions/$(e)/prelude.h)
CFLAGS += -include $(BOARD_DIR)/prelude.h        # existing line, stays last
$(foreach e,$(EXT),$(eval include ../extensions/$(e)/ext.mk))
```

Command-line `-include` flags run before any TU content for **both**
prelude shapes in the tree (4-step chain and the stm32/hc32f460 2-step
chain, where platform.h arrives even later via `grbl.h → hal.h`), so an
extension prelude is textually first everywhere. With `EXT` empty the
`$(foreach)` contributes zero flags — command lines are identical, byte
identity holds by construction and is proven by the artifacts check.
(Already demonstrated live once: a no-op EXT prelude injected before the
ch32v006 board prelude produced a `.bin` md5-identical to the committed
artifact.)

`BUILD_DIR` and `BINARY_NAME` **must key on the EXT set** (e.g.
`grbl_ch32v006+seg-trace.bin` in a `+`-suffixed build dir). The tree was
bitten three times by un-keyed knobs relinking stale objects (BUILD twice,
BOARD once — two-strike rule, ch32v006/Makefile:95-108); an EXT build
overwriting the canonical `build/` output would repeat both mistakes.
`+` is unambiguous: no existing port/board name contains it. Unit naming
`<port>+<ext>` is used uniformly for CI rows, warn baselines
(`ci/warn_baseline_<port>+<ext>.txt`), and `tools/build_artifacts.py`
UNITS entries (`artifact_dir "<port>+<ext>"` — the samd21
two-units-one-port precedent). Extension warnings are **never** unioned
into a bare platform baseline (that is the falsified-baseline class
Phase 1(e) recorded). `EXT` never applies to atmega328p (golden-gated,
prelude-canon exempt).

### 2.3 The #ifndef-discipline prerequisite (measured, not assumed)

Measured state of the tree: first-definition-wins discipline exists in
exactly one file (`common/gpio.h`, 23 `#if !defined` guards); every
prelude's single `#ifndef` is its header guard; platform
gpio.h/config.h/platform.h/timer.h define essentially everything
unconditionally. Proven live: an extension prelude predefining an existing
platform name loses silently (the later platform definition wins), emits
`"X" redefined` warnings, and fails only via the warn ratchet.

The fix is **not** blanket guarding (collides with the deliberate
`#undef PLATFORM_NAME` pattern and the BUG#25 single-owner posture). It is
a **declared extension-override surface**: a CONTRACTS `§NEW.` section
(§6.2 below) enumerating exactly which macro names extensions may claim,
with **only those names** converted to `#if !defined(...)` in the
participating platforms' headers. Initial surface, scoped to what the
`seg-*` family needs:

```
GRBL_SEG_PUBLISH  GRBL_STEPPER_TU_EXPORTS            (new names; no conversion needed)
STP_TMR_INT_ENA  STP_TMR_INT_DIS                     (timer.h of participating ports)
STP_TMR_PERIOD_SET  STP_TMR_PRESCALER_SET/RESET      (Profile F semantic substitution)
STP_PULSE_RESET_COUNT_SET  STP_PULSE_RESET_START     (Profile F / PIO substitution)
HAL_CRITICAL_SECTION_BEGIN  HAL_CRITICAL_SECTION_END (Profile M spinlock)
```

Conversion lands only in the platforms that take an EXT row (ch32v006 now,
rp2040 when it exists), is byte-inert when nothing predefines the names
(same token-identity argument), and is proven per unit by the artifacts
check. The warn ratchet remains the loud tripwire for any *undeclared*
collision — including the libm pin macros in every board prelude, which
extensions must never touch. Two-extension composition claiming the same
name is out of scope for this pass; the dual-claim checker is noted in
§6.2 as future work.

## 3. The contract: SEGX/1 (segment-executor boundary, version 1)

This section **is** the specification; on landing (stage 4) it is copied
verbatim into `extensions/seg-link/ext.md` and referenced from CONTRACTS
`§NEW.` (§6.3). Normative words: MUST/NEVER as in CONTRACTS.md.

### 3.1 Roles, profiles, session

HOST = frozen GRBL core (planner + `st_prep_buffer`) plus extension glue
on the same MCU. EXECUTOR = segment consumer (FPGA fabric, second core,
external chip). Two transport profiles bind the same contract:
- **Profile F** (framed): ordered, reliable, CRC-protected, full-duplex
  byte link; every structure serialized little-endian; the frame boundary
  is the validity strobe. First instantiation: ch32v006 + iCE40 over SPI.
- **Profile M** (memory): executor shares host RAM; the native rings ARE
  the channel; `GRBL_SEG_PUBLISH` carries a release fence, the executor's
  ISR wrapper an acquire fence. First instantiation: RP2040 core1
  (deferred; §5, §7f).

Session: before the first WAKE, HELLO/CONFIG. CONFIG carries: protocol
version; a **config-tuple hash** over {N_AXIS=3, SEGMENT_BUFFER_SIZE=6,
AMASS on + MAX_AMASS_LEVEL=3, VARIABLE_SPINDLE on, ENABLE_DUAL_AXIS off}
— mismatch MUST be refused with FAULT, never best-effort (the layout and
semantics silently reshape with the tuple; e.g. AMASS-off changes byte 5
of the segment from shift count to divider select); **F_TICK as u64 Hz**
— the denomination of `cycles_per_tick` (contractually the stepper-timer
tick rate, not the CPU clock; sg2002 already exploits the distinction;
the §36 ULL-width trap applies to any plumbing of it); $0 pulse width in
µs (min 3), $1 idle-lock ms (255=never), $2 step-invert mask, $3
dir-invert mask, $6 probe invert; the **pin-position map** needed to
decode `direction_bits` (they are cpu_map pin positions, not axis
indices); admission window W (default 5, §3.4). CONFIG_UPDATE is re-sent
at every WAKE — `st_wake_up` re-derives pulse timing after settings
writes, so hooking WAKE covers runtime `$`-changes for free.

### 3.2 Forward frames (canonical, little-endian; CRC + seq per frame in Profile F)

**SEG (8 bytes)**
| off | field | type | semantics |
|---|---|---|---|
| 0 | n_step | u16 | ISR **ticks** to execute, MUST be 1..65535. Physical dominant-axis steps = n_step >> amass_level. n_step==0 is a host protocol violation; the executor MUST trap to FAULT, never reproduce the stock uint16 wrap (declared divergence, §3.6). |
| 2 | cycles_per_tick | u16 | tick period = (value+1) F_TICK clocks, AVR-CTC semantics; a new value takes effect at the arriving segment's FIRST tick without stopping the counter (CONTRACTS §3). 0xffff = clamp sentinel: the segment legally executes faster than planned; position stays exact. |
| 4 | blk_gen | u8 | block reference: 8-bit generation counter, +1 per planner block (replaces the mod-5 ring index on the wire; inequality-triggers-reinit preserved, wrap-drops detectable). |
| 5 | amass_level | u8 | 0..3, tick-rate multiplier log2; per-segment steps_i = blk.steps[i] >> amass_level. |
| 6 | spindle_pwm | u8 | 0=OFF (gates enable logic), 1..255 duty; applied ONCE at segment load, before the segment's first tick. |
| 7 | seq | u8 | Profile F sequence number (Profile M: absent). |

**BLK (~19 bytes + tag)** — MUST be delivered/visible before the first SEG
referencing it (invariant F1):
| field | type | semantics |
|---|---|---|
| blk_gen | u8 | generation tag |
| steps[3] | u32×3 | pre-multiplied ×8 (= <<MAX_AMASS_LEVEL, stepper.c:719-720) |
| step_event_count | u32 | max axis steps, ×8 |
| direction_bits | u8 | pin-position encoded per CONFIG map; 1 = negative |
| flags | u8 | bit0 = is_pwm_rate_adjusted |

**CMD verbs**: WAKE{epoch, sampled homing flag + axis-lock mask, probe
arm state} · IDLE{lock_ms} · HALT_FLUSH (synchronous, §3.5-R6) ·
POS_SET{3×i32; legal only HALTED/IDLE, executor FAULTs otherwise} ·
LOCK{homing_axis_lock delta} · PROBE_ARM(polarity)/PROBE_DISARM ·
EVT_ACK(mask) · CONFIG/CONFIG_UPDATE.

**Ordering invariants.** F1: BLK before first referencing SEG — free, by
program order through the single publish hook. F2: a SEG becomes visible
only via the publish (head store / frame); slot contents are immutable
from publish until credited. F3: the executor executes SEGs strictly in
order, never skipping, never merging.

### 3.3 Executor semantics (bit-exact replication of stepper.c:326-482 — normative)

- Tick period (cycles_per_tick+1) F_TICK clocks; new period effective at
  the popped segment's first tick, no counter reset.
- Bresenham counters initialize to step_event_count>>1 **only on blk_gen
  change** and **persist across segments within a block** (the executor is
  stateful across FIFO entries; stepper.c:375-382).
- Per tick, per axis: counter_i += steps[i]>>amass_level; if counter_i
  **>** step_event_count (strict, :427): emit step, counter_i −=
  step_event_count, position_i ±1 per direction bit.
- DIR lines settle before the step pulse; pulse width = $0 µs; invert
  masks ($2/$3) XOR at output — they are applied ISR-side in stock
  (:477, :385) and therefore MUST live executor-side.
- Homing lock masks the **pulse only**, applied **after** the
  position/counter update (:463-468): locked axes keep counting.
  Replicate exactly; harmless (homing rewrites position afterward).
- On drain after an is_pwm_rate_adjusted block: force spindle PWM off
  (:402-405).
- Reset convention: executor expects the first blk_gen to differ from its
  reset value so counters initialize on the very first block (stock: exec
  index 0, first block claims 1; with the gen counter, WAKE(epoch) resets
  the executor's last-seen gen to a reserved "none" value).

### 3.4 Flow control

Credit-based, window **W = 5** un-credited SEGs outstanding, credits
returned **on completion** (not admission), as cumulative counters. W=5 is
not arbitrary: credits reconstruct `segment_buffer_tail` on the host
(CREDIT==tail identity), which (a) keeps the frozen zero-margin block-slot
pigeonhole proof valid verbatim (5 slots, ≤4 live refs at claim, gated by
the ring-full check at stepper.c:672), and (b) pins committed motion to
stock's ~50 ms, preserving feed-hold/override/parking latency semantics
untouched. FIFO deepening is FORBIDDEN by default; a deep-FIFO variant is
a declared profile option, out of scope here.

### 3.5 Reverse channels (the complete inventory — nothing else in the frozen core flows executor→main)

Governing principles: **(P1)** all reverse state is absolute/cumulative
(positions, retire counts), never deltas — a dropped frame heals at the
next one, no retransmit protocol. **(P2)** events are executor-latched
with explicit ack-clear; delivery may be late, never lost (every stock
consumer polls: protocol.c:240 checkpoints, homing loop limits.c:318,
probe wait motion_control.c:288 — no executor→host IRQ is architecturally
required; one is RECOMMENDED for latency: PB6/EXTI6 on ch32v006). **(P3)
the reverse strobe rule**, mirror of the forward landmine: reverse payload
MUST be committed to host-visible memory before the event bit licensing
its read becomes visible — final position before CYCLE_STOP (jog-cancel
re-syncs gc/planner from sys_position immediately, protocol.c:385-390);
probe snapshot before MOTION_CANCEL. One release barrier in extension code
enforces it; it is a stated, testable obligation of every transport.

**R1 CREDIT/STATUS** — one frame per segment **completion**:
{consumed_seq cumulative, state flags (RUNNING/IDLE/FAULT + raw probe-pin
mirror for the `Pn:P` report), position[3] i32 snapshot}. Host link-IRQ:
verify seq contiguity (gap ⇒ FAULT→alarm), advance `segment_buffer_tail`
by the delta via `grbl_seg_tail_advance()` (single-writer discipline
transfers intact: in Profile F the local ISR never runs, so the link IRQ
is the one consumer-side writer), memcpy position into the sys_position
mirror. Freshness budget: well under DT_SEGMENT=10 ms; cumulative seq lets
credits coalesce under n_step==1 bursts (segments can retire in tens of
µs). The sharpest new failure mode is credit staleness → drain → spurious
EXEC_CYCLE_STOP → protocol flips IDLE → auto-cycle-start re-wakes →
stop/start stutter that silently destroys the velocity profile with zero
lost steps. Mandatory telemetry: an executor underrun counter
(drained-while-host-had-uncredited-capacity); bring-up and CI treat
nonzero as failure.

**R2 POSITION** — dual-authority with explicit transfer. RUN: executor is
sole writer; host `sys_position` is an eventually-consistent mirror
(≤1 segment ≈ 10 ms stale), sufficient because the only motion-time
readers are the 5-20 Hz status report memcpy (report.c:466-472, already
unsynchronized upstream) and the optional dual-axis homing check
(excluded this pass). HALTED/IDLE: host owns position (homing set, init);
the exactness rule: whenever the executor reports HALTED or has raised
DRAINED, its last published position is EXACT and stable — precisely when
every stock re-planning reader runs (plan_sync_position, gc_sync_position,
parking capture, probe-fail, homing all read only when stopped). Transfer
host→executor at WAKE: the `STP_TMR_INT_ENA` override uploads sys_position
(POS_SET) before WAKE — covers every stock main-side position write by
construction, since stock writes position only while halted.

**R3 EVENTS** — executor-owned latched register, ack-clear:
{DRAINED, PROBE_TRIGGERED, FAULT(code: crc, seq-gap, n_step==0,
cfg-mismatch, credit-overflow, halt-timeout)}. This replaces the ISR's two
writes into `sys_rt_exec_state` — a multi-master RMW byte that is
impossible to share naively over a bus and is therefore **never shared**:
the host applies events from its link IRQ on the same core as all other
masters, under the existing cli/sei discipline. DRAINED handler replays
the frozen drain path in order (P3): commit final position; `st_go_idle()`
(public — runs $1 idle-lock and STEPPERS_DISABLE on the MCU, which keeps
the enable pin; the overridden STP_TMR_INT_DIS inside it is an idempotent
no-op when already parked); `spindle_set_speed(OFF)` if the last-shipped
block was pwm-rate-adjusted (tracked at serialization — never touches
`st.exec_block`, eliminating the known stale/NULL read at stepper.c:404,
which is dead code in Profile F); then
`system_set_exec_state_flag(EXEC_CYCLE_STOP)`. Behaviorally equivalent to
stepper.c:399-407.

**R4 PROBE** — exactness lives at the source; delivery latency is
tolerated by stock's own design (the machine decelerates after trigger
regardless; only the measurement is tick-exact). The probe pin MUST
physically terminate at the executor (Profile F). While armed, the
executor samples the ($6-inverted) pin once per tick **before** that
tick's Bresenham updates (probe_state_monitor's call position,
stepper.c:413 precedes :421 — off-by-one-step class if violated); on
trigger it latches all three 32-bit counters in that same tick,
self-disarms, latches PROBE_TRIGGERED, and continues executing queued
segments (stock behavior). Host: copy latch → sys_probe_position;
sys_probe_state = PROBE_OFF; then EXEC_MOTION_CANCEL (order per P3).
Arming is race-free without polling: mc_probe_cycle sets PROBE_ACTIVE
before cycle start and WAKE carries armed+invert — armed strictly before
the first step.

**R5 LIMITS/HOMING** — deliberately NOT reverse-channel items. Topology
T1 (mandated default): limit switches stay host-wired on EXTI; limits.c
hard-limit and homing logic run untouched. Homing's loop crosses the seam
**forward**: a 1 kHz extension soft-timer snapshots
{sys.state==STATE_HOMING, homing_axis_lock} and ships LOCK deltas — ≤1 ms
propagation = ≤8.3 µm overshoot at 500 mm/min seek, 0.4 µm at 25 mm/min
locate; a bounded, documented semantics delta (zero in Profile M).
STATE_HOMING is set before st_wake_up (system.c:182, limits.c:257-265),
so WAKE-carries-config preserves stock write-before-wake ordering free.
Hard-limit/reset kill: stock kills the timer within interrupt latency; a
dedicated host→executor **KILL line** (one freed GPIO; combinationally
gates step generation in fabric) is the REQUIRED default for Profile F
boards, asserted first inside the STP_TMR_INT_DIS override; mailbox-only
kill (~8 µm/ms at seek) is a declared degraded conformance level needing
owner sign-off. Position is declared lost after a hard-limit kill in stock
anyway. T2 (executor-wired limits) is a declared future profile, out of
scope.

**R6 MID-FLIGHT CANCEL — HALT_FLUSH transaction.** Negative result first,
load-bearing: **feed hold needs nothing new** — it cancels nothing in
flight; `st_update_plan_block_parameters` mutates only producer-side prep
state, queued segments execute unchanged, the decel ramp arrives as
ordinary forward SEGs planned from prep.current_speed, and completion is
DRAINED→CYCLE_STOP. The W bound is the only hold obligation. True cancel
exists in stock only as `st_reset()` (jog cancel, probe end, homing phase
ends, mc_reset, init), whose danger is main writing the consumer-owned
tail (stepper.c:552) — legal today only because STP_TMR_INT_DIS at
st_go_idle:257 precedes it on one core. The transaction, carried entirely
inside the `STP_TMR_INT_DIS` override (so stock call order is preserved):
(i) host asserts KILL-class stop request / sends HALT_FLUSH; (ii) executor
completes any in-progress pulse to full $0 width (never truncates), stops
between ticks (mid-segment abandonment is legal — stock INT_DIS has
identical semantics), discards FIFO + block store, freezes and publishes
EXACT position, enters HALTED, acks {position, consumed_seq}; (iii) host
spins inside the macro with a bounded timeout (2× max tick period + link
RTT; timeout ⇒ EXEC_ALARM + hardware KILL, position declared lost — stock
hard-limit class, documented as the recovery contract so nobody
"improves" it into a silent retry); (iv) the override writes the acked
position into sys_position **before returning** (P3 — jog-cancel's
gc_sync_position/plan_sync_position read it immediately); (v) st_reset's
subsequent tail/head zeroing is now safe (executor quiesced; the extension
resyncs its ship cursor := tail at the next WAKE). **Epoch rule**: every
HALT_FLUSH increments an epoch; credit/event/position frames tagged with a
stale epoch are discarded — kills the race of in-flight reverse frames
crossing a flush and re-corrupting tail. Profile M instantiation of the
same override: clear peripheral INTE via atomic alias, then if
CPUID != executor-core, spin until the executor's not-in-ISR flag clears
(CPUID branch prevents self-deadlock when st_go_idle runs on the executor
core from the drain path, stepper.c:401).

**R7 SELF-IDLE SIDE EFFECTS.** On drain the executor stops its tick clock
and latches DRAINED. Profile F default: STEPPERS_DISABLE stays a host MCU
pin; stock `st_go_idle` runs host-side in the DRAINED handler (same
delay_ms-in-interrupt-context shape as stock's ISR call on AVR — each
platform's delay_ms must be IRQ-safe or the extension defers idle-lock to
its soft timer; recorded per platform in ext.md). Executor ownership of
the enable pin is an optional CONFIG item.

### 3.6 Declared divergences from stock (each needs owner sign-off at stage 4)

1. n_step==0: executor FAULTs; stock would wrap uint16 to a 65535-tick
   ghost segment. Producer-side reasoning says a zero is never published
   outside the non-publishing hold bail (stepper.c:991-1000), but the
   stale ISR comment (:372) contradicts the header contract (:321) —
   close with an instrumented hosted-oracle trace (stage 3) before
   freezing the trap.
2. Homing lock propagation 1 kHz-polled in Profile F (≤8.3 µm/ms bound).
3. Hard-limit kill via KILL line (µs) or mailbox (ms, degraded level).
4. Spindle PWM pin moves executor-side in Profile F for laser-exact
   per-segment sync; main-side spindle_set_state calls become commands.
5. `cycles_per_tick` stays u16 (frozen-producer fidelity); the
   F_TICK-scaled 0xffff minimum-speed floor is inherited and documented,
   not fixed (it is a pre-existing, tree-wide, undocumented defect class —
   gets its own CONTRACTS `§NEW.` note independent of this extension).

## 4. Staged implementation, smallest-verifiable-step first

Each stage lands alone, gates green, before the next starts. Gates are
the existing 8 ratchets plus (from stage 3) the new ninth.

**Stage 0 — policy + contracts. No code.**
Deliverables: owner sign-off on the two-hunk source-freeze relaxation
(§1); the three CONTRACTS `§NEW.` sections drafted per §6 (extension
axis, override surface, segment-runtime boundary), integrator assigns
numbers; artifacts/README.md sg2002 staleness fixed in passing (the
"intentionally absent" note contradicts the tree).
Gate: `tools/check_contracts_numbering.py` green; no binary changes.

**Stage 1 — EXT plumbing, empty.**
Deliverables: `EXT ?=` + foreach-include + foreach-ext.mk in
ch32v006/Makefile; BUILD_DIR/BINARY_NAME keyed on EXT;
`grbl/platform/extensions/` created with a README stub only.
Gate: `EXT` empty ⇒ `tools/build_artifacts.py check` all-units
byte-identical; all ratchets green; one manual proof build with a no-op
EXT prelude ⇒ `.bin` still md5-identical to the committed artifact
(bring-up check, not a new ratchet).

**Stage 2 — the core seam.**
Deliverables: the two hunks of §1 in grbl/stepper.c, defaults in-file; the
override-surface `#if !defined` conversion in ch32v006 timer.h/platform.h
for the §2.3 name list.
Gate: golden MD5 `79af184e…` via `make -C grbl/platform/atmega328p
validate`; `tools/build_artifacts.py check` all 11 units; warn ratchet all
ports; boot/init/no-DP unchanged. This stage is deliberately tiny and
lands with zero extensions existing — the seam is proven inert before
anything uses it.

**Stage 3 — seg-trace + hosted oracle + conformance ratchet. THE PROTOTYPE (part 1).**
Deliverables:
- `extensions/seg-trace/`: overrides `GRBL_SEG_PUBLISH` to tee canonical
  frames (§3.2) to a capture sink and `GRBL_STEPPER_TU_EXPORTS` for ring
  introspection; representative unit **ch32v006+seg-trace** (new CI row,
  own warn baseline, own artifacts unit).
- `tools/hosted/`: frozen stepper.c compiled for x86 with a recording stub
  HAL (defaults untouched — the in-file seam defaults make stepper.c
  self-contained, no `-include` needed). Replays committed vector streams
  through the frozen consumer (`__isr_step_impl` in virtual time; the
  consumer path is integer-only ⇒ bit-exact on any host) to derive golden
  tick traces {tick#, elapsed clocks, step/dir bits post-invert,
  position[3], pwm, probe-latch}.
- Committed corpus: `*.gvec` vectors (frame streams from canonical g-code
  covering all 4 AMASS levels, mid-stream block boundaries, n_step==1
  bursts, 0xffff clamp, hold decel tails, probe trigger, homing lock,
  invert masks) + `*.gtrace` goldens + adversarial vectors the producer
  never emits (n_step==0, bad CRC, seq gap, unknown blk_gen) pinning FAULT
  behavior. Vectors are committed artifacts, regenerated only
  deliberately — vector *generation* touches float producer code and must
  never run in CI (x86 float divergence churn); CI only replays.
- **Ninth ratchet** `ci/seg_conformance.py`, one-way: (a) staleness gate —
  regenerated traces from the frozen-consumer replay must equal committed
  goldens; (b) subject gate — any registered far-side implementation must
  match bit-exactly on step/dir sequence, per-tick clock counts, final and
  probe-latched positions, event ordering; (c) corpus count may only grow.
- Instrumented answer to the n_step==0 open question (§3.6.1).
Gate: conformance staleness gate green in CI; ch32v006+seg-trace row
green; all bare units still byte-identical. Key property: wire format ==
vector format == trace format — capture, conformance, and production
traffic can never drift apart.

**Stage 4 — SEGX/1 host side (seg-link) on ch32v006.**
Deliverables: `extensions/seg-link/` — the §3 spec frozen into ext.md;
shipper (publish-hook serializer, ship cursor between tail and head,
zero-copy DMA legal because credits preserve slot-stable-until-freed);
reverse engine (credit pump via `grbl_seg_tail_advance`, event pump, 1 kHz
soft timer); STP_TMR_INT_ENA→POS_SET+CONFIG+WAKE(epoch) and
STP_TMR_INT_DIS→HALT_FLUSH overrides; SPI1 remap 011 (NSS/PB0, SCK/PB1,
MISO/PB2, MOSI/PC0 — conflict-free precisely because the offload frees
PC0-PC5), DMA1 ch2/ch3, PB6/EXTI6 event IRQ, PC4 MCO exporting 48 MHz
(F_TICK shared by construction), one freed pin as KILL; boards/fpga config
variant (also re-pins around the documented SWIO/SWCK/RST paper-map
collisions). The frozen ISR body still compiles (dead, ~1-2 KB against
~22 KB flash headroom); it is never armed. Loopback validation: the
shipper's serialized frames, replayed through the stage-3 oracle, must
reproduce the golden traces — host side proven correct with no FPGA in
existence.
Gate: unit ch32v006+seg-link builds, own baseline/artifacts; loopback
replay green under `ci/seg_conformance.py`; bare units untouched.

**Stage 5 — FPGA executor in simulation. THE PROTOTYPE (part 2).**
Deliverables: RTL executor (segment FIFO + 5-entry block store in 2-3 EBR,
3×32-bit Bresenham, tick + $0 pulse timers, position/probe latches, event
register, SPI slave + CRC; target iCE40UP5K, HX8K fallback if 48 MHz
timing misses — the fallback choice changes cycle bookkeeping and must be
made **before** goldens freeze) + Verilator testbench registered as a
conformance subject.
Gate: subject gate bit-exact over the full corpus including adversarial
vectors. No hardware required; this closes the executor-correctness risk
entirely in CI.

**Stage 6 — beyond this plan (listed for sequencing only):** bench
bring-up (ch32v006 + iCE40 board; measure worst-case credit burst and
ratchet the freshness budget from measurement; UP5K timing closure);
RP2040 bare port (boot2, PWM-slice stepper timer, SysTick pulse-reset,
SRAM-shadow boot, bootrom-flash NVMEM); `seg-core1` Profile M extension
(recursive-spinlock critical sections, quiesce INT_DIS, probe.c:65
closure); optional PIO pulse-shaping knob.

## 5. The prototype: what, and why this one

The owner asked for a prototype, carefully, without poisoning the project.
The owner named ch32v006+external-FPGA and RP2040 soft-HLS. Plainly: **the
cheapest convincing prototype is not silicon.** It is stages 3-5 — the
seg-trace recorder proving the seam and byte-identity end-to-end in CI,
the hosted oracle turning the frozen core itself into the executable
specification, and a Verilated RTL executor passing a bit-exact
conformance corpus derived from that oracle. That combination proves, per
unit of risk:
- the seam is inert (golden MD5 + 11-unit byte-compare, continuously);
- the extension mechanism composes (a real EXT row with its own baseline
  and artifacts unit);
- the wire format is complete and sufficient (the oracle consumes only
  frames and reproduces stock tick traces);
- the executor semantics are replicable bit-exactly (Verilator subject
  gate), including the failure semantics stock never exercises.

Zero hardware, zero irreversible decisions, and every artifact of the
prototype (vectors, goldens, ratchet) is permanent infrastructure, not
throwaway — the same corpus later gates the physical FPGA and any future
executor (RP2040 core1, other fabrics).

Between the two named silicon targets, **ch32v006+FPGA is the first
instantiation and RP2040 is deferred**: (a) ch32v006 is already a green
unit; RP2040 requires an entire new bare port before its extension can
even start — that is a port project, not an extension proof; (b) Profile F
exercises the FULL framed bidirectional contract (the hard, novel part),
while Profile M collapses most of it to native shared memory and would
validate little beyond the fence and the spinlock; (c) the ch32v006 is the
strongest demonstrator of the owner's thesis — its binding constraint is
the ISR itself (48 MHz RV32EC, no hardware multiply, full-spill
interrupts, no nesting), which the offload deletes, while the producer
side idles at 100 segments/s. Honest limit, stated up front: the FPGA
raises the step-rate ceiling, not the block-rate ceiling — curve-dense
g-code remains bound by soft-float planning on the host.

## 6. CONTRACTS.md additions (drafts; integrator assigns numbers, never renumber)

### 6.1
```
<a id="extension-axis"></a>
## §NEW. The extension axis (EXT=)
```
Content: extensions answer "where is the edge" as platforms answer "which
silicon"; directory shape `grbl/platform/extensions/<name>/`
{prelude.h, ext.mk, ext.md}; injection ordered before the board prelude;
prelude defines `GRBL_EXT_<NAME>`, never `GRBL_PRELUDE`; no root
`platform.h`; BUILD_DIR/BINARY_NAME keyed on EXT; unit naming
`<port>+<ext>`; per-unit warn baselines, additive artifacts units; CI is a
sum (platforms + extensions), never a product; `EXT` empty MUST be
byte-identical on every unit (proven by the artifacts check); EXT never
applies to atmega328p. Note the constitutive-vs-optional distinction: a
channel a port cannot function without (sg2002 shm-serial) is library
extraction, not an EXT knob — owner decision recorded here when taken.

### 6.2
```
<a id="extension-override-surface"></a>
## §NEW. Extension-override surface (first-definition-wins names)
```
Content: the enumerated macro list of §2.3; only these names are
`#if !defined`-guarded in platform layers, and only in platforms that take
EXT rows; everything else remains single-owner (BUG#25 posture) with the
warn ratchet as the collision tripwire; libm pins and `GRBL_PRELUDE` are
explicitly never claimable; dual-claim checking across multiple EXT
entries is declared future work.

### 6.3
```
<a id="segment-runtime-boundary"></a>
## §NEW. Segment-runtime boundary (GRBL_SEG_PUBLISH / GRBL_STEPPER_TU_EXPORTS, SEGX/1)
```
Content: the two seam macros, their default expansions, the token-identity
rule and its proof procedure (§1); the obligation that any override of
GRBL_SEG_PUBLISH orders/ships BOTH payload classes (the forward strobe
rule) and that any transport observes P1/P2/P3 (§3.5); pointer to the
SEGX/1 spec; the declared divergences list (§3.6); the ILLEGAL-no-op law
applies — a silent no-op override of either macro is forbidden.

### 6.4
```
<a id="amass-clamp-floor"></a>
## §NEW. The 0xffff cycles_per_tick clamp scales the minimum-speed floor with F_CPU
```
Content: independent of the extension — documents the inherited defect
(≈30.5 steps/s floor at 16 MHz vs ≈477 at 250 MHz; velocity fidelity
silently abandoned below the floor, position exact); no fix in this pass.

## 7. Decision log (where the three designs disagreed)

a. **Seam shape: two touch points with a TU-exports hook**, over (i) a
   five-line storage-class change (`static` → injectable token on the four
   ring declarations) and (ii) a single publish macro alone. Against (i):
   externalizing the statics forces the extension to mirror the private
   struct typedefs (duplicated truth, drift risk) and changes bare-build
   linkage semantics for no gain; the exports hook compiles accessors
   inside the TU with zero-token default and field-copy semantics.
   Against (ii): the reverse credit pump must write `segment_buffer_tail`
   and the trace tap must read slots — one publish macro cannot reach
   them; two hunks is the minimum that works.
b. **Defaults live in stepper.c itself**, not in `common/gpio.h`: the
   hosted oracle (stage 3) compiles stepper.c standalone, and a
   self-contained file cannot be broken by include-chain drift. The
   `#ifndef` respects a prior `-include` definition, so extension
   preludes still win.
c. **blk_gen u8 generation counter on the wire**, not the mod-5 ring
   index: same inequality-triggers-reinit semantics, plus wrap-drop
   detectability; the executor's block store stays 5 deep regardless
   (W=5 pins liveness).
d. **Credits on completion (CREDIT==tail identity)**, not on admission:
   admission credits would double effective in-flight depth, silently
   stretching feed-hold/override/parking latency and voiding the frozen
   pigeonhole proof. The negative result that feed hold needs *nothing
   else* is the single most valuable reverse-contract fact; this choice
   preserves it.
e. **n_step==0 traps loudly** (all three designs converged after
   analysis); the stage-3 oracle closes the residual doubt before the
   trap semantics freeze.
f. **Simulation-first prototype; ch32v006+FPGA first silicon; RP2040
   deferred** — reasons in §5. One design argued core1-first as cheapest
   seam validation; rejected because the rp2040 bare port is a larger
   prerequisite than the entire seg-trace+oracle+Verilator chain, which
   validates strictly more of the contract.
g. **KILL line is the required default for Profile F** (one design had it
   merely recommended); mailbox-only kill is a declared degraded level
   needing explicit owner sign-off, because it is a semantics change even
   if physically small.
h. **Override-surface conversion scoped to participating platforms
   only**, not all 10 layers: smaller diff, byte-inert per the artifacts
   check, and the warn ratchet already makes undeclared collisions loud
   everywhere else.

## 8. Out of scope for this first pass

- RP2040 in any form: the bare port, `seg-core1` (Profile M
  instantiation), PIO pulse shaping, and the probe.c:65 cross-core RMW
  closure that only Profile M needs.
- ENABLE_DUAL_AXIS (widens both wire and reverse contract; the live
  mid-motion sys_position read needs its own analysis) and the non-AMASS
  prescaler profile (defined in SEGX/1 for completeness, not in the
  conformance corpus).
- Physical hardware: board spin, iCE40 timing closure, bench measurement
  of the credit-burst budget (stage 6; the plan's gates are all
  simulation/CI).
- Widening `cycles_per_tick` / fixing the 0xffff floor (documented as
  §6.4, deliberately not changed — frozen-producer fidelity).
- Deep-FIFO (W>5) profile, T2 executor-wired limits, executor-owned
  STEPPERS_DISABLE, MCU-TIM1 laser-sync alternative.
- shm-serial extraction from sg2002 (separate work; only the
  constitutive-vs-optional framing note lands in §6.1).
- Multi-extension composition (EXT lists of length >1) and the dual-claim
  checker.
- compdb/Renode plumbing for EXT units (extension rows ship without
  emulator smoke until the smoke lane grows a representative).
