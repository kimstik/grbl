# GRBL on the Sophgo SG2002 — C906L runtime core

> **STATUS: builds and links clean, ZERO `PORT_TODO_*`, both flavors. NOT
> validated on hardware, and NOT "ready for hardware validation" in the sense
> the other ports use that phrase.** No public TRM exists for SG2002 or its
> CV1800B sibling, and no emulator models this SoC, so every peripheral fact
> here is community-sourced and unverified. Every such site in the code
> carries an `UNVERIFIED:` banner naming what the claim rests on and what a
> bring-up engineer must confirm first. Read `sg2002.h` before touching
> hardware.

## What this port is

A **bare-metal blob for the little core**, not a Linux program.

SG2002 is asymmetric: a big Linux-hosting core (C906 RISC-V **or** Cortex-A53
ARM, mutually exclusive by boot strap) plus a little **C906L** — RV64, no MMU,
machine mode only, ~700 MHz. The RISC-V-vs-ARM choice applies **only to the
big core**. The C906L is present and is RISC-V on *every* SG2002
configuration, so there is exactly one port to write, and the big core's ISA
is a compatibility axis to test against rather than a second implementation.

Linux side is **out of scope** beyond the ABI this document specifies.

### Lifecycle

Upstream's `sophgo,cv1800b-c906l` remoteproc driver, used as-is:

```sh
cp grbl_sg2002.elf /lib/firmware/
echo grbl_sg2002.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start          > /sys/class/remoteproc/remoteproc0/state
echo stop           > /sys/class/remoteproc/remoteproc0/state
```

The driver copies each `PT_LOAD` segment to its `p_paddr` inside a device-tree
`reserved-memory` carve-out and releases the core at the ELF entry point. No
new kernel code is needed for load/start/stop/restart.

### One carve-out, three regions

`script.ld` splits a single 2 MiB carve-out. **These addresses and the device
tree must agree** — remoteproc honours `p_paddr` without validating it.

| Region | Address | Size | Contents |
|---|---|---|---|
| CODE | `0x8FE00000` | 1 MiB | `.init` `.text` `.rodata` + `.data`'s load image |
| DATA | `0x8FF00000` | 768 KiB | `.data` `.bss` `.stack` at run time |
| SHM  | `0x8FFC0000` | 256 KiB | cross-core window (`shm.h`) |

The SHM region **has no ELF section** — its address is a linker `PROVIDE`
symbol only. Nothing in the image covers it, so no `PT_LOAD` includes it and
remoteproc never writes it. That is what makes the rings and the settings
image survive a firmware stop/start.

## Build

```sh
make -C grbl/platform/sg2002 BUILD=RELEASE
make -C grbl/platform/sg2002 BUILD=DEBUG
```

Toolchain: `gcc-riscv64-unknown-elf` + `picolibc-riscv64-unknown-elf` — the
same two apt packages ch32v006 and ch570 use.

| Knob | Default | Meaning |
|---|---|---|
| `BUILD` | `DEBUG` | `DEBUG` = `-Og -g3`, `RELEASE` = `-Os` |
| `BOARD` | `generic` | selects `boards/<board>/{config.h,prelude.h}` |
| `FP` | `SINGLE` | AVR-faithful `double==float` (CONTRACTS §17) |
| `SHM_COHERENCY` | `CMO` | `CMO` or `NONCACHEABLE` — see below |
| `PLIC_CONTEXT` | `2` | PLIC context index for this core's M-mode view |
| `CLOCK` | `25000000` | **the APB timer clock**, not the CPU clock |

### `F_CPU` is the stepper timer's clock, not the CPU frequency

Core uses `F_CPU` as the tick rate of the stepper timer
(`TICKS_PER_MICROSECOND`, the AMASS cutoffs, and the step-pulse arithmetic).
Declaring 700 MHz here would overflow CONTRACTS §4's 8-bit pulse-width
horizon for every realistic setting — `((pulse_us-2) * 700) >> 3` does not fit
a `uint8_t` at all. `platform.h` carries static asserts that fail the build if
`CLOCK` is raised past the point where a 30 µs pulse stops fitting.

The CPU frequency is a separate constant used for nothing timing-critical;
delays come from the CLINT `mtime` counter, not a calibrated busy loop.

### ARCH/ABI: `rv64imac_zicsr` / `lp64` (soft float)

Not `rv64gc`, for two independent reasons:

1. **`rv64gc/lp64d` is not buildable on this toolchain.** It resolves to the
   `rv64imafdc/lp64d` multilib, which picolibc does not ship — its rv64 set
   stops at `rv64imafc/lp64f`.
2. **The "L" in C906L is undocumented.** Nothing states whether F/D survive
   the cut-down core. `rv64imafc/lp64f` *does* have a multilib, but an lp64f
   binary traps on its first `FLW` if F is absent. `rv64imac` is a strict
   subset of every C906 variant.

Reversible in two lines if F is ever confirmed. `_zicsr` is explicit because
this binutils generation does not imply it from the base ISA letters
(CONTRACTS §14 item 1).

`-mcmodel=medany` is **required**, not tuning: the default `medlow` addresses
globals as a signed 32-bit offset from zero and cannot reach `0x8FE00000`.

## The serial channel: CONTRACTS §7 over shared memory

There is no UART. §7 binds serial *semantics*, not a peripheral, so it is
implemented over two byte rings in the carve-out (`shm.h` owns the ABI):

| §7 concept | Realisation |
|---|---|
| `RX_PENDING` | `h2r.head != h2r.tail` |
| `HAL_SERIAL_RX_ISR` | the mailbox doorbell IRQ |
| `HAL_SERIAL_READ_DATA` | pop one byte from `h2r` |
| `HAL_SERIAL_WRITE_DATA` | push one byte into `r2h` |

TU-replacement route: core `grbl/serial.c` is excluded, `serial.c` here
provides `serial.h`'s API.

**One deliberate cardinality change:** a doorbell fires once per *burst*, so
the handler drain-loops — orders of magnitude fewer interrupt entries than a
byte-at-a-time UART. §7's table binds semantics, not one-IRQ-per-byte, so this
is contract-legal. **The invariant that keeps it safe:** the drain loop runs
the per-byte classify exactly as many times as N separate byte interrupts
would, so BUG #19's realtime-command interception (`?`, `~`, `!`, ctrl-X, the
override set) is inherited *verbatim* and unchanged. A "fast path" that
memcpy'd a run of bytes past that switch would compile, link, pass every gate
here, and silently break the reset key.

**TX backpressure** — flagged as an open point in the design pass — is closed
by construction: `serial_write()` spins on the host's tail index with
interrupts **enabled**, so the stepper and pulse-reset interrupts keep running
while a full ring drains. Liveness needs only that the host consumes bytes,
never a host→runtime doorbell.

### Host-side ABI (what a bridge must do)

1. Wait for `magic == "GRBL"`, a `version` it understands, and `rt_ready == 1`
   before touching any index. The runtime core initialises the whole window
   and sets `rt_ready` last.
2. Own `h2r.head` and `r2h.tail`; never write `h2r.tail` or `r2h.head`.
3. Apply the same coherency discipline from its side: writeback after
   producing, invalidate before consuming, doorbell strictly last.
4. Deliver the doorbell IRQ with **counting** semantics — the stock
   `uio_pdrv_genirq` driver's `read()` returns an accumulated interrupt count,
   so a doorbell landing between the host's emptiness check and its blocking
   read still wakes it. This port coalesces doorbells (rings only on the
   idle→busy transition), which is safe under counting delivery and **not**
   safe under level-sampled delivery.
5. Persist the 1 KiB `nvmem` slot when `nvmem_dirty` is set, clear the flag,
   and restore it before starting the firmware. Skipping this is legal and
   degrades gracefully — see below.

A host that merely *polls* the rings, with no mailbox at all, is a fully
functional peer. That is deliberate: the mailbox is the least-documented block
on the chip, so it was kept off the correctness-critical path.

## Coherency: the decision

The two cores have separate, non-coherent L1 D-caches
([CONTRACTS](../CONTRACTS.md#cross-core-cache-coherency)). Fences order *this*
core's accesses; they say nothing about the other core's cache. That document
names a non-cacheable mapping as the preferred simplification "where the SoC's
PMA/MMU configuration allows it".

**This port defaults to explicit cache maintenance (`SHM_COHERENCY=CMO`)** and
offers the non-cacheable window as a declared alternative. Why:

1. **The preferred route is not reachable here, and the doc's own precondition
   says so.** The C906L has **no MMU**. T-Head's documented way to mark memory
   non-cacheable is the extended attribute bits in a PTE — and there are no
   PTEs without an MMU. What remains is the SoC's PMA, fixed in fabric and
   undocumented. A simplification you cannot program is not a simplification.
2. **It is what the vendor's own C906L firmware does** — cvitek RTOS images
   for this core reach Linux-shared buffers through explicit cache ops.
3. **The alternative is built, not dismissed.** If an integrator *confirms*
   the window is non-cacheable, `SHM_COHERENCY=NONCACHEABLE` removes every
   cache op and keeps the fences. Measured cost of the safe default: **472
   bytes of text** (37156 vs 36684, RELEASE).

Neither setting is a no-op — under `NONCACHEABLE` the ordering fences remain,
because ordering is still an obligation. An unrecognised value is a hard
`$(error)`.

The cache ops are T-Head `XTheadCmo` (`th.dcache.cva` / `th.dcache.iva`),
emitted as `.insn` words so the vendor extension does not have to be stamped
into every object's ISA attribute. The encodings were **verified against this
toolchain by disassembly**, not taken from documentation — CONTRACTS §19
Lesson 1's rule.

**Cache-line separation is load-bearing.** Cache ops act on lines, not
variables: two indices sharing a 64-byte line means writing back the one you
own also writes back your stale copy of the one the *other* core owns,
silently reverting its progress. Every independently-written word in `shm.h`
sits on its own line, pinned by `_Static_assert`.

## Settings storage (CONTRACTS §10)

No flash on this core's side. NVMEM is a 1 KiB slot in the shared window, with
two tiers of durability:

- **Tier 1 — survives a firmware restart, with no host cooperation.** The
  window is outside every `PT_LOAD`, so remoteproc stop/start leaves it
  intact. `$100=123.456` → restart → `$$` shows the value.
- **Tier 2 — survives a power cycle, with host cooperation.** DDR does not.
  The firmware sets `nvmem_dirty` and rings the doorbell after every change;
  persisting and restoring the slot is the host bridge's job. A host that
  ignores it gets tier-1 durability and settings that revert to defaults after
  a power cycle — visible and diagnosable, not silent corruption.

An uninitialised window is recognised by its magic and presented as `0xFF`
(erased-flash semantics), so core's existing "checksum failed, load defaults"
path works unchanged.

## Peripheral map

| Role | Block | Notes |
|---|---|---|
| Stepper timer | DesignWare APB timer ch 0 | no hardware prescaler — the /1,/8,/64 divisor is a software multiplier applied in `PERIOD_SET` |
| Pulse-reset timer | DesignWare APB timer ch 1 | no /8 tick — `START()` loads `(256 - val) * 8`, reproducing both the pulse width and core's 8-bit horizon exactly |
| Delayed step | DesignWare APB timer ch 2 | supported (see caveat below) |
| GPIO | DesignWare apb_gpio, 4 banks | no atomic set/clear → every DR/DDR RMW is critical-sectioned (§1.2) |
| GPIO pulls | SoC pad-control block | DW GPIO has none; the board config supplies the per-pad register mapping |
| Limit/control IRQ | one PLIC line per bank | shared-vector dispatch (§2.5); any-edge emulated by flipping `INT_POLARITY` in the ISR (§2.6) |
| Spindle PWM | cvitek PWM block 0 | duty ratio exact — `HLPERIOD` and `PERIOD` carry the same scale factor |
| Interrupts | PLIC + `mtvec` **direct** mode | one trap entry, `mcause` + PLIC claim dispatch |
| Delays | CLINT `mtime` | a real monotonic counter, not a cycle-counted loop |

### Interrupt nesting — this port nests, the other RISC-V ports do not

CONTRACTS §5.2 wants the pulse-reset interrupt to preempt `ISR_STEP` (core
calls `sei()` mid-body — the AVR origin semantic). ch32v006 and ch570 both
*defer* instead, which §5.2 accepts.

This port nests for real. The blocker on a plain `__attribute__((interrupt))`
handler is that GCC saves GPRs but **not** `mepc`/`mstatus`, so a nested trap
destroys the outer trap's return address. `sg2002_trap_entry()` saves and
restores both CSRs around its dispatch. `mstatus` is restored (MIE clear, as
on entry) *before* `mepc`, so nothing can be taken between the restore and the
compiler's `mret`.

That also discharges the second half of §12.7. A PLIC has no preemption
levels — priorities only order simultaneous claims — so "serial must not
starve the stepper" cannot be solved with priorities. It is solved where it
can be: the doorbell handler re-enables interrupts around its drain loop, the
same way `ISR_STEP` does, so the stepper pair preempts it freely. It cannot
recurse into itself, because the PLIC will not re-deliver a claimed source.

### `STEP_PULSE_DELAY` caveat

The timer side supports it (channel 2 is free). The **GPIO** side does not on
the generic board: core's `ISR_STEP_DELAY` body stores a *logical* port image
straight into the step register (`stepper.c:513`), which cannot go through
this board's L2P shift. `handlers.c` carries a `_Static_assert` that fails the
build loudly if the option is enabled without an identity STEP map — §4's
conditional rule, not a silent wrong-pin write.

## Contract conformance

| Contract | Status |
|---|---|
| §1 GPIO data/dir/pull | pull-ups are real pad-block writes; RMW critical-sectioned; input groups in bits 0-7 |
| §1 BUG #17 L2P/P2L | exercised for real — STEP on bits 8-10, DIRECTION on 11-13 |
| §2 GPIO interrupts | `GPIO_INT_ON/OFF` gate delivery at the pin at runtime; shared-vector dispatch; any-edge emulation; flags cleared first |
| §3 stepper timer | `PRESCALER_SET/RESET` implemented (software multiplier), never a no-op |
| §4 pulse timer | pulse width **and** 8-bit horizon both exact |
| §5 ISR macros | flag-clear-first; real nesting |
| §6 spindle PWM | `MAX_VALUE` 255, duty ratio exact, `PWM_DISABLE` drives inactive |
| §7 serial | shared-memory ring, BUG #19 verbatim, BUG #12 barriers |
| §8 critical sections | `mstatus` save/restore, never blind enable |
| §9 watchdog | deliberately undefined (a no-op would be illegal) |
| §10 NVMEM | four functions, wear guard, one checksum function both paths |
| §11 `sei`/`cli` | `csrsi`/`csrci` with `"memory"` clobber |
| §12 weak memory | fences on every publish; **plus** the cross-core cache class |
| §17 FP=SINGLE | post-link assert PASSED |
| §18 boot integrity | RISC-V form — `_start` must link at the carve-out base |
| §19 `.DELETE_ON_ERROR:` | present |

## Sizes (RELEASE, `FP=SINGLE`, `SHM_COHERENCY=CMO`)

```
   text    data     bss
  37156       8   18056   grbl_sg2002.elf     (RELEASE)
  41180       8   18056   grbl_sg2002_dbg.elf (DEBUG, -Og)
```

## Before you power a machine with this

In rough order of "how badly it bites":

1. **Reconcile every peripheral with the Linux device tree.** Two drivers on
   one block is silent corruption, not a compile error.
2. **Measure the APB timer clock** and set `CLOCK`. Wrong here = every
   feedrate off by a constant factor, invisible to every gate in this repo.
3. **Confirm `PLIC_CONTEXT`.** Wrong = no interrupt is ever delivered; the
   firmware boots, prints its banner, and never steps.
4. **Confirm the carve-out addresses** against the DT, in `script.ld` *and*
   the Makefile's `BOOT_ENTRY_ADDR`.
5. **Confirm the pad pull-up register mapping.** Wrong = floating limit/probe
   inputs and spurious ALARMs.
6. **Confirm the mailbox offsets.** Wrong costs liveness only — a polling host
   works regardless.
7. **Confirm `XTheadCmo` is implemented on the C906L.** If not, the ops trap as
   illegal instructions — loud, which is the acceptable direction.
