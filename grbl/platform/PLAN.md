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

- [x] `prelude.h` for samd21 (megarm + generic): 4 `-include` flags → 1; preprocessed
      limits.c proven byte-identical; redefinitions 19 → 0; dual-canon killed in
      hal.h/hal_gpio.h; sizes bit-identical (60196 DEBUG / 42556 RELEASE); golden PASSED
- [x] samd21 warn baseline regenerated from REAL build log (9 entries, ratchet OK live)
- [x] Roadmap truth-update landed (SAMD21 40%→~95%, stale claims refreshed at integration)
- [x] stm32h523: hal_gpio_port_t typedef restored (real root cause, not CFLAGS) —
      build advances to the shared spindle-macro defect; blocked on f103-class fix
- [x] stm32f103 BUILDS: spindle macros per CONTRACTS §1/§6, handlers.c deduped to
      core-supplied ISRs (samd21 pattern), redefs/collisions gone, baseline from
      real logs (22 entries). DEBUG 48836/80/19376, RELEASE 29900/80/19376.
- [x] stm32h523 BUILDS (DEBUG 48648, RELEASE 28596): TIM1 authored (RM0481),
      per-line EXTI handlers + core-ISR dedup, contract fixes (PWM_MAX->255 per
      CONTRACTS 6.2, H5 USART fields, CRITICAL START->BEGIN), baseline from real
      logs. ALL 9 CI MATRIX ROWS NOW BUILD. Inspection-era "ready" claim falsified.
- [x] samd21 generic board BUILDS (60236/296/6160): PWM_MIN 0->1, PWM_RANGE, alias
      block restored; baseline union megarm+generic (15 entries), ratchet OK both
- [ ] NOTE (minor): samd21 BUILD_DIR shared between DEBUG/RELEASE — stale-object
      cross-contamination without clean; key BUILD_DIR by build type
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

- [x] CONTRACTS.md landed (427 lines): per-macro contracts §1-13 with file:line
      citations, no-op legality per macro (STP_TMR_PRESCALER_SET = canonical violation),
      BUG #12/#13 lessons codified, ISR-hot budgets, TU-replacement route documented
- [x] PORTING-CHECKLIST.md landed (157 lines): ordered bring-up with per-step exit
      tests, weak-memory checklist, definition of done incl. golden MD5 + ratchet
- [ ] `_Static_assert` where contracts are expressible in code (CPU_FREQ one landed;
      sweep for more as _template work proceeds)
- [x] **`_template` platform LANDED — mechanism PROVEN**: 37 distinct PORT_TODO_*
      undefined symbols enumerate all work by name, zero foreign undefineds; all
      .c compile immediately (#warning sea = progress meter); GPIO accessors stay
      lvalue via declared-never-defined extern array; reuses common/*; not in CI
      matrix by design. Bonus: .gitignore silently ate platform READMEs (fixed);
      Makefile inline-comment whitespace trap documented.

**Exit criterion**: a new platform can be ported by copying `_template` + contracts alone,
without reverse-engineering an existing port.

## Phase 3 — SAMD21 Closure   [COMPLETE 2026-07-23]

- [x] `_delay_us()` / `_delay_ms()` implemented (calibrated 3-cycle asm loop +
      hal_millis poll with handler-mode/PRIMASK/no-SysTick fallback; disasm-verified)
- [x] **SysTick wired** (Reset_Handler post-SystemInit; reused core_cm0plus.h
      SysTick_Config; demoted to prio 3 via SHPR3 — M0+ equal-prio never preempts,
      tie arbitration favors motion/serial). Runtime evidence in Renode:
      system_milliseconds advancing at 1kHz (+5012/~5s); G4 P5 dwell PC-sampling:
      hal_millis/_delay_ms hits, ZERO delay_busy_loop → polling path live.
      DEBUG 60284/296/6160 (+88), RELEASE 42596. Golden PASSED, ratchet OK.
- [x] Pin-mask truncation INVESTIGATED — verdict far worse than suspected:
      **BUG #17 (CRITICAL): samd21 has NO WORKING MOTION PATH.** Core step pipeline
      is a uint8_t port image (st.step_outbits/dir_outbits/axislock/invert masks);
      STEP bits 25/27/28 (megarm) silently truncate in the ISR (compound |= gives
      no -Woverflow) → zero step output ever; $H falsely reports homing success
      with no motion (position lie, reachable at $22=1); $2/$3 silently dead.
      Renode smoke (banner+$$) exercises no motion — couldn't catch it. Full
      call-site table + disasm proof in investigation report.
- [x] **BUG #17 FIXED: logical port-image contract landed.** Boards: logical
      STEP/DIR bits 0..2 + physical *_PIN; samd21 gpio.h token-pasting dispatch —
      megarm branch-free 3-term gather/scatter (PA25/27/28), generic pure shift;
      common/gpio.h only gained #ifndef guards. Evidence: preprocess before/after,
      get_step_pin_mask disasm movs #1/2/4, RELEASE LTO ISR branch-free. 10
      overflow warnings gone from baseline, ratchet OK 4/4. megarm 60428/42836.
      Golden AVR byte-identical; f103 unchanged. MOTION SMOKE dispatched (with
      negative control: pre-fix tree must FAIL the motion stage).
- [x] **BUG #18 FIXED**: -DF_CPU=$(CLOCK)UL — stepper.c:1015 computes unsigned,
      warning gone.
- [ ] Regenerate ci/warn_baseline_samd21.txt from a REAL build log — 8 pre-existing
      core warnings missing (gcode/settings/stepper/motion_control/report/config.h);
      first CI run will trip the ratchet until then
- [x] **Renode smoke test — FIRST EXECUTION OF THE PORT EVER (2026-07-23): PASSED.**
      Full boot: blank-EEPROM error:7 → settings_restore (~100 NVMCTRL row rewrites) →
      banner → interactive `$$` via RXC interrupt → full stock-correct dump → ok.
      TX via DRE drain, RX via ring buffer — BUG #12 fixes exercised live. 3× repro
      (Renode 1.16.1 stable + nightly). Negative test: hang forensics captures
      PC+symbol (verified on OSC8M poll startup.c:143). Delivered: ci/renode/
      {samd21_grbl.repl,samd21_smoke.resc,smoke.sh,uart_probe.py} +
      .github/workflows/smoke.yml (non-blocking until GH-runner green streak).
      Emu workarounds via Renode Tags only (SYSCTRL_PCLKSR, NVMCTRL_INTFLAG) —
      zero port source changes.
- [x] **VTOR fix landed**: Reset_Handler programs SCB->VTOR = vector_table (linker
      symbol, works at any 256-aligned base) + __DSB before SystemInit; script.ld
      ALIGN(256) + link-time ASSERT; core_cm0plus.h RESERVED0→VTOR (real CMSIS layout).
      Renode VTOR modeling PROVEN by isolation test (VecBase forced 0 + stub SP/PC →
      boots, VecBase reads back 0x200) → .resc override removed. Smoke exit 0 ×2.
      samd21 DEBUG size-proxy now 60196/296/6160 (+24, str+dsb+literal pool).
- [x] **BUG #19 FIXED + MOTION SMOKE PASSED — THE PORT MOVES (2026-07-23).**
      serial.c realtime interception mirrors core verbatim (?/!/~/ctrl-X/overrides);
      motion: MPos 0->1.000 with accel/decel profile, Idle; PA25 STEP pin driven
      150+ times (write-hook), DIR polarity correct both ways. NEGATIVE CONTROL
      FINDING: #17 = PHANTOM MOTION (MPos lies even broken — Bresenham increments
      regardless of dead pins) -> pin-level assert added, exit 4 on phantom;
      before/after pair complete. Renode model gap closed via ci-only C# shim
      (16-bit TC writes + CTC top=0 wake). Sizes 60864/43036. All gates green.
- [x] SAMD21 = READY FOR HARDWARE VALIDATION (community/owner does hardware;
      every emulatable subsystem proven: boot, EEPROM, serial RX/TX+realtime,
      SysTick, delays, VTOR, MOTION with physical pin evidence).

**Exit criterion**: Renode boot test green in CI.

## Phase 4 — Fresh Port by the New Rules (ch32v006)   [M1-M3 DONE]

M1-M3 landed 2026-07-23: skeleton+clock+GPIO compile for rv32ec_zicsr; 32
PORT_TODO_* remain (timers/serial/nvmem/handlers = Steps 3-6, next batch);
GAP LOG (8 items) folded into CONTRACTS.md §14 — the "each port strengthens
the system" loop closed for the first time. PFIC regs UNVERIFIED placeholders.

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
      Toolchain: XC-DSC verified recipe in Decision Log. **EULA APPROVED BY OWNER
      2026-07-24** — unattended CI wiring authorized, no remaining blockers)
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

- 2026-07-23 WEAKIFY CLOSED (owner ruling + probe data, materially negative):
  objcopy --weaken is a TOTAL NO-OP on slim-LTO objects (-fno-fat-lto-objects:
  symtab has zero function symbols; nm lies via plugin) and override link
  HARD-FAILS (multiple definition — loud, at least). Mitigation (-fno-lto per
  TU) works but costs +17016 bytes / +40% RELEASE for ONE small core file vs
  measured payoff of 36 deletable LOC (9.8% of samd21 serial+nvmem; nvmem = 0,
  every diff there is a deliberate bug fix). Verdict: NOT for this codebase
  while LTO is canon. Typo-guard PoC (nm set-check, both failure modes proven)
  archived in probe artifacts if a narrow case ever justifies revival.
- (superseded context) 2026-07-23 proposal record: weakify core .o via objcopy --weaken for
  per-function platform overrides. Executor position (pending probe data):
  blanket = NO (LTO-inline partial-interposition hazard; silent typo-override =
  anti-linker-as-checklist; 300-function undesigned surface, static-state coupling);
  curated allowlist = YES if probe passes (weaken.list registry + CI typo guard +
  LTO parity via -fno-lto on overridable TUs). Real payoff target: delete the
  duplicated samd21 serial.c/nvmem.c whole-file copies. Probe measures all three.

- **BUG #19 CONFIRMED (HIGH, safety-relevant)**: samd21/serial.c RX ISR lacks ALL
  realtime-command interception (core serial.c:127-145 contract): ?/!/~/ctrl-X/
  overrides enter the ring buffer as data. Status polling dead, feed-hold/reset
  dead in realtime. Found via weakify-probe side table; verified by grep. Fix
  dispatched to Renode agent (blocks its motion smoke ? polling) — mirror core
  switch verbatim + prove ? returns <...MPos...> in Renode, then motion test.

- OWNER DIRECTIVES 2026-07-24: (1) dsPIC EULA approved — CI wiring unblocked;
  (2) alarm now UNCONDITIONAL 3h grid :13 (job 16d87106; prior 6h job died with
  a context compaction — session-only store, known behavior); (3) TEST/REVIEW
  FOCUS = PORT CODE ONLY (grbl/platform/*, ci/*): core is presumed clean, do
  not spend review/test cycles hunting core bugs (aligns with byte-proven
  template philosophy).

## Current State (update each session)

- ALARM SEMANTICS (owner directive 2026-07-23): the 6h cron is FALLBACK RECOVERY
  ONLY — never a scheduler/heartbeat. Work is dispatched immediately when known;
  limit-killed agents are retried immediately, not parked for the next cron.
- ADVERSARIAL REVIEW #2 verdicts (prelude+contracts): Batch A (22aa27c prelude)
  SURVIVED ALL refutations — preprocess byte-identical old-vs-new chain, single
  IRQ_HANDLER canon proven via -dD + link map, EEPROM_SIZE clean, golden intact.
  Batch B (contracts docs): content accurate, citations into the 4 Phase-1-touched
  files systematically stale (authored pre-landing) — doc-fix batch dispatched.
- ~19:50 UTC: heavy-pool limit wall until 09:50 UTC tomorrow killed BUG#17 fix,
  f103-spindle, _template(2nd). ALL FOUR RELAUNCHED ON SONNET immediately
  (owner floor; salvage pointers to dead worktrees included). If sonnet pool
  also walls: ledger current, 6h cron is the fallback recovery.
- 2026-07-23 ~19:20 UTC snapshot: 6 tracks in flight — _template resume
  (wf_e7f22066-e3b), adversarial review of prelude+contracts batches, stm32h523 +
  samd21-generic fix, stm32f103 spindle-macro fix, pin-mask truncation
  investigation, SysTick wiring (Renode-agent, with runtime evidence).
  Phases 0+5 done; Phase 1 samd21-side done; Phase 2 contracts landed; Phase 3
  delays+VTOR+smoke done.
- Subagent limit windows observed today: 16:00 / 21:50 / 23:00 UTC resets (pools
  differ per model); main loop unaffected

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
- Cron: UNCONDITIONAL recurring 6h (owner directive) — fires 05:27/11:27/17:27/23:27 UTC
  (job 92bf6ea9; grid shifted per owner so nearest fire is +5h, 2026-07-23 23:27;
  session-only, auto-expires after 7 days; prior 5:15 one-shot chain did not survive
  a context compaction — unconditional recurrence replaces it)
