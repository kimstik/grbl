# GRBL HAL — Development Plan & Orchestration Ledger

**Purpose**: Single source of truth for project direction. Every session starts by
reading this file and ends by updating it. Plans live here, not in chat history.

**Core philosophy** (do not violate):
- GRBL core is a proven structural template — byte-for-byte integrity on AVR is the invariant
- Minimal intrusion: inject only what is strictly necessary, nothing more
- Macros + `-include` virtualization, weak symbols; no runtime indirection
- Static analysis + CI over manual verification; each new port must strengthen the system
- Breakage surface stays isolated: timers, I/O, clocks — never the core

**Working rules** (anti-90/90 mechanics):
1. Research is timeboxed and must end in a committed artifact (doc/test/decision here)
2. Ratchet: a bugfix is not done until a CI check exists that would have caught it
3. Two-strike: second rework of the same spot → stop, write the contract/test first

---

## Phase 0 — CI Foundation (the ratchet)          [NEXT]

The single highest-leverage phase. Converts manual review marathons into automation.

- [ ] CI pipeline: build ALL platforms on every push (atmega328p, stm32f103, stm32h523, samd21)
- [ ] **Byte-diff gate**: atmega328p `.text` section compared against reference GRBL 1.1h
      build. Mechanizes the core non-intrusion principle forever.
- [ ] `-Werror` for platform/ layer (core files get a frozen warning baseline, not edits)
- [ ] `compile_commands.json` make target (fixes LSP navigation through `-include` injection)

**Exit criterion**: green pipeline on push; byte-diff gate proves core integrity.

## Phase 1 — Injection Canon (prelude refactor)

Agreed design: one `-include $(BOARD)/prelude.h` per platform instead of four flags;
prelude explicitly chains config.h → platform.h → gpio.h with comments (order documented
in one readable file). Kill the dual channel (`grbl.h` → `platform/hal.h` vs `-include`).

- [ ] `prelude.h` for samd21 (megarm + generic boards), collapse 4 `-include` flags to 1
- [ ] Resolve dual-canon: `-include` becomes THE mechanism; eliminate redefinition warnings
      (currently: `HAL_GPIO_IRQ_HANDLER` redefined, `EEPROM_SIZE` redefined)
- [ ] Loud-failure guard: `#error` in hal.h if prelude marker missing
- [ ] Roll prelude pattern to stm32f103 / stm32h523 / atmega328p
- [ ] Finish naming migration: one canon for IRQ handler macros (HAL_GPIO_* vs new short names)
- [ ] Truth-update PLATFORM_ROADMAP.md (currently claims SAMD21 at 40% — it is ~95%)

**Exit criterion**: zero warnings in platform layer; one injection mechanism; docs match reality.

## Phase 2 — Macro Interface Contracts

The macro boundary isolates code but cannot express contracts. Write them down.
Lesson source: STP_TMR_PRESCALER_SET is a silent no-op on SAMD21; BUG #12 (atomicity
assumptions); BUG #4 (baud arithmetic) — none catchable without stated contracts.

- [ ] Contract doc per macro family (extend timer.md): pre/post-conditions, atomicity and
      memory-ordering obligations, whether no-op implementations are permitted
- [ ] Weak-memory porting checklist (ARM/RISC-V): ring buffers, volatile-is-not-atomic,
      ISR flag clearing, SYNCBUSY-class synchronization
- [ ] `_Static_assert` where contracts are expressible in code

**Exit criterion**: a new platform can be ported from contracts + checklist alone,
without reverse-engineering an existing port.

## Phase 3 — SAMD21 Closure

- [ ] **Known open gap**: `_delay_us()` / `_delay_ms()` are empty stubs in platform.c —
      real functional bug (homing, stepper enable delays, spindle ramp depend on them)
- [ ] Renode smoke test in CI: boot binary → assert banner `Grbl 1.1h ['$' for help]` →
      `$$` settings dump → jog command ack. CI-native hardware substitute; catches the
      "compiles but dead" class (TC4-no-clock, wrong baud) that static analysis cannot.
- [ ] Mark SAMD21 "ready for hardware validation" in roadmap; community does hardware.

**Exit criterion**: Renode boot test green in CI.

## Phase 4 — Fresh Port by the New Rules (ch32v006)

Cheapest silicon, sharpest differentiation, and RISC-V stresses the abstraction on a new
axis. Port strictly from Phase-2 contracts. Count every contract gap discovered and fold
it back into the docs — this is "each port strengthens the system" made operational.

- [ ] ch32v006 port from contracts + checklist only
- [ ] Contract amendments merged from discovered gaps
- [ ] Platform added to CI matrix (build + smoke where emulation exists)

**Exit criterion**: builds in CI; contract docs measurably improved (gaps logged → fixed).

## Phase 5 — Positioning & Release

- [ ] README section: what this project is vs grblHAL/FluidNC (pristine core, byte-proven
      non-intrusion, minimal-silicon niche, GRBL 1.1 sender compatibility)
- [ ] Tag v0.x; invite hardware testers per platform

---

## Orchestration Protocol

**Roles**: owner holds the canon (naming, taste, architectural forks — decisions recorded
below). Executor (AI sessions) proposes, implements, reviews; routine work is autonomous,
only genuine forks go to the owner.

**Session template**: ~10% load state (read this file + TODO.md), ~70% execute current
phase items, ~20% review + commit + update this ledger. Never end a session with
uncommitted exploration.

**Unit of work**: one checkbox → one commit (or small commit series) → green CI.

## Decision Log

- 2025-11: `-include` injection is THE canon; obviousness restored via single prelude.h
  per platform + compile_commands.json, not by abandoning virtualization
- 2025-11: no architectural redesign — three surgical corrections only (prelude canon,
  contracts, CI ratchet)
- 2025-11: hardware validation delegated to community post-Renode; CI-first philosophy

## Current State (update each session)

- **Phase**: 0 (not started) — next action: CI pipeline skeleton
- SAMD21: all 16 review bugs fixed (fc490a6), builds clean at 59876 bytes, never executed;
  known open gap: empty `_delay_us`/`_delay_ms` stubs (Phase 3)
- stm32f103 production; stm32h523 ready for testing; atmega328p is the reference
