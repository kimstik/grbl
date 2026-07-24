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

- [x] CI pipeline: 9-row matrix via composite action (atmega328p; stm32f103/h523 ×D/R;
      samd21 megarm/generic ×D/R). Thin invoker — build truth stays in Makefiles.
      sg2002 row deferred to Phase 6 (riscv toolchain decision).
- [x] **Golden gate (BLOCKING)**: `make validate` vs golden MD5 on every push.
      Provenance dual-build vs live upstream v1.1h → weekly workflow (provenance.yml,
      report-only; expected drift = 2 bytes VERSION_BUILD date).
- [x] Warning ratchet (chosen over -Werror: one-way baseline per platform,
      ci/warn_ratchet.py selftest 12/12). ARM baselines inspection-derived —
      first real CI run may need recalibration (expected, not a defect).
- [x] `compile_commands.json`: tools/gen_compile_commands.py + `make compdb` (samd21),
      -include flags preserved verbatim, 21 entries verified locally.

**Exit criterion**: green pipeline on push — PENDING first GitHub Actions run
(verify at next cron session; recalibrate ARM warn baselines if needed).

## Phase 1 — Injection Canon (prelude refactor)

Agreed design: one `-include $(BOARD)/prelude.h` per platform instead of four flags;
prelude explicitly chains config.h → platform.h → gpio.h with comments (order documented
in one readable file). Kill the dual channel (`grbl.h` → `platform/hal.h` vs `-include`).

GROUND TRUTH from Phase-1 recon (wf_42380eec-412, empirical builds, full injection map
in its journal): (a) atmega328p clean — zero redefinitions, golden PASSED; (b) samd21:
hal_gpio.h:129 silently OVERWRITES platform.h:172's HAL_GPIO_IRQ_HANDLER — the macro in
effect at limits.c/system.c is the `_IRQHandler` variant (matches handlers.c externs);
(c) **stm32f103 DOES NOT BUILD** — spindle_control.c: SPINDLE_PWM/GPIO_DIR_OUT/PWM_*
undeclared (pre-existing defect; roadmap's "production ready" is false); also
PLATFORM_NAME + sei/cli redefinitions, LIMIT_DDR self-collisions in platform.h;
(d) **stm32h523 DOES NOT BUILD** — Makefile never sets CFLAGS_EXTRA (missing
-I../common/dummy → avr/pgmspace.h not found), copy/paste omission;
(e) ci/warn_baseline_stm32f103.txt entry for HAL_GPIO_IRQ_HANDLER is FALSIFIED by real
build (warning does not occur there); (f) generic BOARD of samd21 has pre-existing
config error (SPINDLE_PWM_MIN_VALUE must be > 0).

- [ ] `prelude.h` for samd21 (megarm + generic boards), collapse 4 `-include` flags to 1
- [ ] stm32h523: restore CFLAGS_EXTRA (-I. -I../common/dummy) — build currently broken
- [ ] stm32f103: fix spindle macro naming defect (SPINDLE_PWM/PWM_* undeclared) — build
      currently broken; fix PLATFORM_NAME/sei/cli redefinitions + LIMIT_DDR self-collision
- [ ] Correct falsified baseline entries (stm32f103) from real CI logs
- [ ] samd21 generic board: fix SPINDLE_PWM_MIN_VALUE config error
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

- [x] `_delay_us()` / `_delay_ms()` implemented (calibrated 3-cycle asm loop +
      hal_millis poll with handler-mode/PRIMASK/no-SysTick fallback; disasm-verified)
- [ ] **Wire SysTick_Config(48e6/1000) into startup** — discovered during delay work:
      SysTick is NEVER configured in this port, so SysTick_Handler never fires and
      hal_millis() is frozen at 0 (delay fallback keeps things functional meanwhile)
- [ ] **Investigate pin-mask uint8_t truncation** (suspected REAL ARM bug): settings.c
      get_step_pin_mask/get_direction_pin_mask/get_limit_pin_mask return uint8_t;
      samd21 pin bits are >7 (e.g. bit 25) → -Woverflow shows masks truncate to 0.
      Find consumers (limits.c homing per-axis?), assess impact, fix in PLATFORM layer
      (core stays pristine — golden gate arbitrates any core-side proposal)
- [ ] Regenerate ci/warn_baseline_samd21.txt from a REAL build log — 8 pre-existing
      core warnings missing (gcode/settings/stepper/motion_control/report/config.h);
      first CI run will trip the ratchet until then
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

- [x] README section "Why this fork" (landed early via parallel track): byte-proof
      thesis, grblHAL/FluidNC contrast, platform matrix, CI gate links
- [ ] Tag v0.x; invite hardware testers per platform (END of plan, after phases 1-4)

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

**Parallel doctrine** (owner directive 2026-07-23): authoring runs CONCURRENTLY across
phases whenever file overlap is small — worktrees make even overlapping authoring safe.
Serialization lives at exactly one point: integration into the branch, done by the
orchestrator batch-by-batch, each batch passing the gates (AVR golden `make validate`,
samd21 size-proxy, zero new ratchet warnings) before the next lands.
Integration order when batches queue up: lower phase number first.

**Review doctrine** (owner directive 2026-07-23): every landed batch ALSO gets an
adversarial reviewer agent (>= sonnet; fable for ISR/asm/memory-ordering content) —
prompt: REFUTE the batch (wrong cycle math? contract violated? claim not backed by
repo?). Findings → fix batch or ledger entry. Mechanical gates catch regressions;
the reviewer catches plausible-but-wrong. A batch is DONE only after both.

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
- 2026-07-23 TOOLCHAIN RECON (verified live end-to-end, full transcripts in recon agent):
  * ch32v006: **CI-ready via apt today** — `apt install gcc-riscv64-unknown-elf
    picolibc-riscv64-unknown-elf` (GCC 13.2.0; rv32e multilibs present; flags
    `-march=rv32ec -mabi=ilp32e -specs=picolibc.specs`; E-extension enforcement
    verified by codegen — no a6/a7 usage; full -lm link works). Write clean-room
    register headers from TRM (ch32fun precedent) — do NOT vendor WCH headers.
    PFIC (custom fast-interrupt, not CLINT/PLIC) needs its own vector handling.
  * dsPIC33AK: CI-ready via custom fetch, verified: XC-DSC v3.30 unattended install
    (`--mode unattended --unattendedmodeui none --LicenseType FreeMode
    --netservername ""` — last flag required but undocumented), 83MB from
    ww1.microchip.com (SHA-256 0df20c1a...) + SEPARATE DFP
    Microchip.dsPIC33AK-MC_DFP.1.5.263.atpack (Apache-2.0, has 33AK128MC102);
    compile needs `-mcpu=33AK128MC102 -mdfp=<dfp>/xc16` AND explicit
    `-Wl,--script=<dfp>/.../p33AK128MC102.gld` (default ldscript is 30F-era).
    ⚠ EULA "single computer" clause with no CI carve-out — OWNER REVIEW required
    before wiring XC-DSC into shared CI (one of the few genuine owner touchpoints).
- 2026-07-23 (FINAL MANDATE): owner fully hands off ("умываю руки до конца") —
  execute everything through end of plan autonomously. Parallel doctrine active,
  6 tracks in flight. GitHub Actions API shows no runs for the branch yet
  (Actions possibly disabled on fork — VERIFY at cron sessions; if permanently
  disabled, local gates remain authoritative and note it here).

## Current State (update each session)

- **Phase**: 0 DONE (pending first-CI-run confirmation) → **Phase 1 launched**
  (prelude canon workflow running; roadmap truth-update in same batch)
- Phase 0 landed: c3c42b6 (pipeline+ratchet+compdb+AVR shim) + follow-up (golden gate
  blocking, provenance weekly). Local: make validate PASSED, ratchet selftest 12/12,
  compdb 21 entries. NEXT CRON SESSION: check GitHub Actions result of these pushes;
  recalibrate ci/warn_baseline_{stm32f103,stm32h523,samd21}.txt from real logs if red.
- Makefile self-sufficiency fixes DONE via atmega328p shim (root Makefile untouched)
- Local container: avr-gcc 7.3.0 OK; gcc-arm-none-eabi apt install running in background
  (if it lands, ARM platforms verifiable locally; else CI-only)
- Phase 1 constraint (HARD): AVR golden bytes must NOT change — every prelude/naming
  edit gets `make validate` in the authoring worktree; a changed golden = rejected edit
- SAMD21: 16 bugs fixed, builds 59876 bytes, never executed; `_delay_us/_delay_ms`
  stubs empty (Phase 3)
- Cron: one-shot 22:57 UTC armed (eaa096cc), prompt self-re-arms +5:15
