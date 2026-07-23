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
- [ ] **`_template` platform** — contracts materialized as a stub skeleton
      (`grbl/platform/_template/`): full canonical port structure (prelude.h, platform.h,
      gpio.h, timer.h, serial.c, nvmem.c, handlers.c, startup.c, Makefile, boards/generic/).
      Design: KISS, linker-as-checklist — unimplemented macros expand to calls to
      undeclared `PORT_TODO_<name>()` so every file compiles immediately but the port
      links only when complete, and undefined symbols enumerate remaining work by name;
      file-level `#warning PORT-TODO` marks progress. NO silent no-op stubs (that is the
      STP_TMR_PRESCALER_SET trap). Each stub carries its contract as a docstring.
      Reuse: fold common/dummy into the template; dedupe with stm32 common.mk where free.

**Exit criterion**: a new platform can be ported by copying `_template` + contracts alone,
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
axis. Port strictly by copying `_template` + Phase-2 contracts. Count every contract gap
discovered and fold it back into docs/template — "each port strengthens the system"
made operational.

- [ ] ch32v006 port from `_template` + contracts only
- [ ] Contract amendments merged from discovered gaps
- [ ] Platform added to CI matrix (build + smoke where emulation exists)

**Exit criterion**: builds in CI; contract docs measurably improved (gaps logged → fixed).

## Phase 5 — Positioning & Release

- [ ] README section: what this project is vs grblHAL/FluidNC (pristine core, byte-proven
      non-intrusion, minimal-silicon niche, GRBL 1.1 sender compatibility)
- [ ] Tag v0.x; invite hardware testers per platform

## Phase 6 — Rolling Ports (standing autopilot loop)

Owner mandate: after Phases 0-5, keep porting while unimplemented platforms remain.
Loop per platform: copy `_template` → implement → warning-ratchet baseline → CI matrix
entry (one line, composite action) → fold discovered contract gaps back into
Phase-2 docs + `_template` → commit, push, tick here, update Current State.

Priority order (revise as hardware/toolchain reality dictates):
- [ ] stm32f411 (ARM M4, toolchain already in CI, likely large reuse via stm32 common)
- [ ] **dsPIC33AK128MC102** (owner-requested 2026-07-23; chip chosen by executor:
      28-pin = ATmega328p DIP-28 heir, 200 MHz, DP-FPU, motor-control PWM + SCCP/MCCP,
      PPS pin remap eases 28-pin budget; MC106 Curiosity = community hardware variant.
      Third ISA family (non-ARM, non-RISC-V) — hardest portability stress test.
      Toolchain: MPLAB XC-DSC, recently free incl. optimizations; NOT apt-installable —
      CI via cached Microchip installer silent-mode, fallback build-only-local with
      ledger note, same pattern as ch32v006)
- [ ] hc32f460 (ARM M4, vendor-exotic — tests contract completeness)
- [ ] sg2002 (RISC-V 64, linux-class — decide scope first: bare-metal vs linux userspace)
- [ ] any new platform dir that appears — same loop

Standing laws for every port: reuse before write (stm32 common.mk pattern, common/
helpers); duplication is a defect; KISS; models >= sonnet; all mutation via worktree
agents; golden AVR checksums untouchable.

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
- 2026-07-23: FULL AUTOPILOT mandate from owner: execute entire plan + Phase 6 rolling
  ports without stopping for questions; only merge-to-master/PR and physical hardware
  remain owner touchpoints. Agent model floor: sonnet. ALL file mutation via worktree
  agents. 5:15 cron cadence, self-re-arming.
- 2026-07-23: CI is a THIN INVOKER (owner: "Makefile самодостаточный, не изобретай
  велосипед") — build knowledge lives in Makefiles only; integrity gate = existing
  verify_hal_avr.sh called as-is; golden checksums are sacred.
- 2026-07-23: EMPIRICAL PROVENANCE ESTABLISHED: fork .text vs upstream gnea v1.1h
  (same avr-gcc 7.3.0, -flto stripped for parity) differ by exactly 2 bytes =
  GRBL_VERSION_BUILD date string "20190825"→"20190830"; ALL machine code byte-identical.
  Golden checksums (30640 / hex 79af184e... / .text 6134ac92...) reproduce on gcc 7.3.0,
  not only 9.x. Dual-build-vs-upstream = rare provenance job, NOT the gate.
- 2026-07-23: `_template` platform design: linker-as-checklist (PORT_TODO_* undefined
  symbols enumerate unfinished work), file-level #warning progress markers, NO silent
  no-op stubs; template is Phase-2 contracts materialized as code.

## Current State (update each session)

- **Phase**: 0 IN PROGRESS — workflow wf_739a839e-97f (recon + 2 worktree authors:
  ci-pipeline, compdb) running; on return: trim per thin-invoker law, apply, verify, commit
- Empirical ground truth captured (see Decision Log 2026-07-23 provenance entry);
  scratch notes: phase0_ground_truth.md (scratchpad, must be folded into repo docs)
- Makefile self-sufficiency fixes queued for worktree agent: (a) `build/` dir not created
  on fresh clone (first -MMD write fails), (b) AVR_GCC_PATH default points to
  nonexistent ~/avr-toolchain — fall back to PATH
- Local container: avr-gcc 7.3.0 installed (apt); arm-none-eabi ABSENT here (ARM builds
  verified in CI only); upstream v1.1h clone in scratchpad
- SAMD21: all 16 review bugs fixed (fc490a6), builds clean at 59876 bytes, never executed;
  known open gap: empty `_delay_us`/`_delay_ms` stubs (Phase 3)
- stm32f103 production; stm32h523 ready for testing; atmega328p is the reference
- Cron: one-shot 22:57 UTC armed (eaa096cc), prompt self-re-arms +5:15
