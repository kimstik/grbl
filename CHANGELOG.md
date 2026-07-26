# Changelog

## [v0.x] — unreleased (release-notes draft, not tagged — tagging is an owner action)

This release turns a single-chip firmware into a multi-platform HAL while keeping the
original GRBL 1.1 core provably untouched. It is a **firmware-availability** release, not a
**hardware-validated** one — read the "What this release does NOT claim" section before
flashing anything.

### The thesis: this is still GRBL, byte-for-byte

The core `grbl/*.c`/`*.h` files are not a rewrite or a semantic fork. A same-toolchain,
same-flags build of this repo's `atmega328p` port and a fresh clone of `gnea/grbl` tag
`v1.1h.20190825` produce `.text` sections that differ by exactly **2 bytes** — the
`GRBL_VERSION_BUILD` date string (`"20190830"` here vs `"20190825"` upstream). Every other
byte of machine code is identical. This is enforced, not just claimed once:

- **Golden gate (blocking, every push)**: `make -C grbl/platform/atmega328p validate` checks
  the built `grbl.hex` MD5 against a pinned hash (`79af184e67b27defd27a39309ac53563`).
- **Provenance (weekly, report-only)**: a separate workflow clones live `gnea/grbl` fresh and
  byte-diffs `.text` against it, so the golden hash itself can't quietly drift from upstream.
  Expected/only drift: the 2-byte build-date string above.

### 8 platforms, 3 ISA families, RELEASE flash bodies

The AVR reference plus 7 new ports, spanning ARM (Cortex-M0+/M3/M4F/M33), RISC-V (rv32ec),
and dsPIC33 (a motor-control DSC core) — the sharpest portability stress test a compile-time,
macro-based HAL (no runtime function-pointer indirection) has been put through here:

| Platform | ISA | RELEASE text/data | In CI |
|---|---|---|---|
| atmega328p (reference) | AVR, 8-bit | 30640 / 0 | yes (golden gate) |
| stm32f103 (Blue Pill) | ARM Cortex-M3 | 28700 / 80 | yes |
| stm32h523 (Black Pill H5) | ARM Cortex-M33 | 25132 / 388 | yes |
| stm32f411 (Black Pill) | ARM Cortex-M4F | 25796 / 80 | yes |
| samd21 (megarm / generic) | ARM Cortex-M0+ | 31952 / 31940 | yes |
| ch32v006 | RISC-V rv32ec | 41072 / 0 | yes |
| hc32f460 | ARM Cortex-M4F | 25596 / 80 | yes |
| dsPIC33AK128MC102 | dsPIC33 DSC | ~41.8KB (approx.) | no — toolchain fetch unresolved |

**Four of the five ARM ports — stm32f103, stm32h523, stm32f411, and hc32f460 — are now smaller
than the 8-bit AVR reference build.** Only samd21 (Cortex-M0+) is larger, and that's an honest
architectural tax, not fat: it's the one Thumb-1 core in the set, lacking hardware divide/CLZ,
so soft-float and integer-division primitives cost 2-3x more instructions there than on the
Thumb-2 M3/M33/M4F parts. ch32v006 (RISC-V) is larger too, for the analogous reason on that ISA.
All numbers above are RELEASE-flavor `text`+`data`, re-measured today by clean builds against the
same toolchain versions CI uses, not carried forward from an old ledger entry.

### What is actually proven, and how

Every platform above builds, links with zero `PORT_TODO_*` placeholders, and passes every
mechanical gate this project has: the golden AVR MD5, a one-way warning ratchet, a post-link
boot-integrity check (catches a missing/garbage vector table), and an `assert_no_double.sh`
check (catches double-precision float code sneaking onto single-precision-only silicon).
**That is not the same claim as "it runs."**

- **samd21 is the only port that has ever executed anything, anywhere.** In Renode 1.16.1
  emulation it boots from a blank EEPROM, restores settings, prints the version banner,
  answers `$$` with a full settings dump over a real interrupt-driven serial path, and —
  the important part — **moves**: a `G2` arc command was traced end to end with the X-axis
  STEP pin (PA25) physically toggling on the emulated silicon, correct `MPos` tracking, and a
  negative control proving the test would have failed before the fix below existed.
- **Every other port — stm32f103/h523/f411, ch32v006, hc32f460, dsPIC33AK128MC102 — is
  build/link/contract-proven only.** No emulator model exists for any of them here. They have
  never executed a single instruction, emulated or on real silicon.
- **No port, including samd21, has run on physical hardware.** Zero exceptions. That is the
  community's and the owner's next step, not something this repository can claim for you.

### 21 bugs found and fixed

Numbered as they were found across the samd21 bring-up (#1-16) and the rest of the project
(#17-21). Full detail is in `git log` and `grbl/platform/CONTRACTS.md`. The two worth
understanding even if you skip the rest:

- **BUG #17 — the port that lied about moving.** Core `settings.c`'s pin-mask helpers
  (`get_step_pin_mask()` etc.) return `uint8_t`, but samd21's STEP/DIR pins sit above bit 7
  (e.g. bit 25). The mask silently truncated to zero: **no step pulse ever left the chip**,
  while `$H` reported homing success and `MPos` happily counted up in the status reports,
  because the position tracker runs off the *commanded* step count, not the pins. A Renode
  smoke test that only checked "does it boot and answer `$$`" could not have caught this —
  it took an actual motion test with pin-level assertions to find a firmware that moves on
  paper and stays dead on copper. Fixed by splitting "logical" step/dir bit numbers (0-2) from
  physical pin numbers everywhere, with a build-time assert that now makes "logical bit > 7"
  a compile failure on every port, not just a lesson learned on this one.
- **BUG #21 — RELEASE shipped with no vector table, at all.** All three STM32 ports built and
  looked fine in DEBUG. In RELEASE (`-Os -flto`), link-time optimization deleted the entire
  vector table before codegen because nothing in the retained call graph referenced it — the
  linker's `KEEP()` directive is powerless against this, because the section is gone before
  `KEEP()` ever gets a say. The resulting `.bin`'s first word was ordinary code, not a stack
  pointer: **this firmware cannot boot on real hardware**, though it built, linked, and would
  have passed every check that only looks at "did `make` exit 0." samd21 was immune purely by
  accident (an earlier, unrelated VTOR fix happened to give LTO a reason to keep the table).
  Fixed with an explicit `SCB->VTOR` write in `Reset_Handler` (a real code reference LTO's
  analysis can't optimize away) plus a new post-link `boot_check.sh` ratchet that fails the
  build if the first two words of the flash image don't look like a plausible stack
  pointer + reset vector — wired into every ARM port and `_template` so this class of bug
  cannot ship silently again.

The other 19: serial PMUX/clock/timer-enable mistakes, a UART baud-rate formula error, several
SYNCBUSY synchronization races, an interrupt-flag-never-cleared storm, an inline ISR wrapper
that generated no linkable symbol (so real interrupts silently fell through to
`Default_Handler`), missing memory barriers around flash writes and ring-buffer updates on
ARM's weak memory model, a missing realtime-command interception path (feed-hold/reset/status
bytes being treated as ordinary G-code input), and an NVMEM subsystem that LTO had stripped
entirely out of a RELEASE build (BUG #20 — the same "RELEASE silently different from DEBUG"
family as #21, just caught on a different port and subsystem first).

### What a contributor inherits

Porting to a new chip no longer means reverse-engineering an existing port:

- **`CONTRACTS.md`** (24 sections) — a written contract for every macro boundary (GPIO, timers,
  serial, NVMEM, critical sections, weak-memory obligations, FP-precision-is-a-declared-property,
  and the specific gaps each new ISA family exposed), with file:line citations, not prose.
- **`PORTING-CHECKLIST.md`** — an ordered bring-up sequence with a stated exit test per step.
- **`_template/`** — a real, copyable skeleton where every unimplemented macro is an undefined
  `PORT_TODO_<name>()` symbol. The port compiles immediately and links only when everything is
  wired up — the linker's undefined-symbol list *is* the punch list. It is deliberately excluded
  from CI (it isn't a shippable port, it's a checklist you copy).
- **Five one-way ratchets**, each targeting a bug class this project actually shipped once:
  golden AVR MD5 (byte-proof), per-platform warning baselines (new warnings fail CI), post-link
  boot integrity (catches BUG #21's whole class), a no-double-precision assert (catches DP float
  code on single-precision-only silicon), and a CONTRACTS.md numbering/cross-reference checker
  (`docs-integrity` CI job — catches parallel edits colliding on the same section number).

### Honest limitations — read this before trusting any of the above

- **No port has run on real silicon.** Every claim above is either a build/link/contract proof
  or, for samd21 alone, an emulator proof. Hardware bring-up is explicitly the community's and
  owner's next step.
- **hc32f460's register facts are largely UNVERIFIED.** No public register-level manual was
  available; the port is clean-room, cross-checked (not copied) against Klipper3d's real shipped
  firmware for this chip. Every unverified register fact is flagged at its own definition site in
  `hc32f460/regs.h`. Treat this port as "compiles and looks right" until someone with the real
  manual (or a scope) confirms it.
- **sg2002 is non-functional, on purpose, for now.** The existing source tree doesn't build and
  targets a macro namespace the core no longer calls. A real design exists for a rewrite
  (shared-memory-ring channel over the Linux `remoteproc` framework instead of a UART) but is
  intentionally deferred — implementation, not analysis, is what's missing.
- **dsPIC33AK128MC102 and CH570 are not in CI.** dsPIC33's toolchain (XC-DSC) works locally with
  an owner-approved EULA but has no unattended-CI-fetch story yet; its free/unlicensed compiler
  tier also silently caps optimization on `-Os` ("Options have been disabled due to restricted
  license") rather than failing loudly, so its RELEASE size figure above is an approximation, not
  an exact byte count. CH570 is recon'd and unblocked but porting hasn't started.
- **GitHub Actions is running** (78 CI + 67 Smoke runs on this branch as of this writing, one per
  push) — an earlier concern that it might be disabled on this fork was checked and is stale.
  Every gate described above has also been independently re-verified by fresh local builds today,
  which corroborates but is not a substitute for checking the Actions tab's own green/red status.

### Contributing a new platform

Copy `grbl/platform/_template/`, work through `PORTING-CHECKLIST.md` against the contracts in
`CONTRACTS.md`, add one CI matrix row per build flavor, and fold anything you discover back into
`CONTRACTS.md` — every port so far has strengthened the system for the next one.
