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

**Exit criterion**: green pipeline on push — CONFIRMED RUNNING 2026-07-26 (see Current State):
`github.com/kimstik/grbl/actions` shows 78 CI runs + 67 Smoke runs on this branch, one per push,
matching this branch's commit history. **Provenance caveat (2026-07-26, added on review): this run
count is single-sourced** — one agent's single GitHub web-UI fetch, not corroborated via `gh api`
(both the orchestrator's and a reviewer's API access to this repo returned 403 on re-check). Treat
"Actions is enabled and running" as solid and the exact 78/67 counts as an unverified UI snapshot.
Per-run pass/fail was not re-confirmed pixel-by-pixel in that pass (fetch method loses status
icons) — check the Actions tab directly for green/red.

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
- [x] BUILD_DIR flavor contamination FIXED repo-wide (two-strike rule after 3rd
      bite): BUILD_DIR/$(BUILD) in samd21, stm32 common.mk, ch32v006, sg2002,
      _template; no-clean flavor-switch proof landed; CI/smoke/compdb unaffected
- [x] **Resolve dual-canon — VERIFIED STALE, closed on evidence (2026-07-26).**
      Re-checked from scratch rather than trusted: `grep -rn
      "HAL_GPIO_IRQ_HANDLER|EEPROM_SIZE" ci/warn_baseline_*.txt` — zero hits
      in any of the 6 baselines (samd21's baseline even carries its own
      comment noting both redefinition classes died with the Phase-1 prelude
      canon). Then a FRESH clean build of all 7 ports, both flavors where
      applicable (atmega328p `validate`; stm32f103/h523/f411, samd21
      megarm+generic, ch32v006 DEBUG+RELEASE; dspic33ak128mc102 DEBUG+RELEASE
      via the real `xc-dsc-gcc` toolchain at `/opt/xc-dsc`) — grepping all 13
      resulting logs for either string: zero matches. `EEPROM_SIZE` today is
      owned once per port inside that port's own `nvmem.c` (single-owner
      comment at samd21/nvmem.c:19-20); `platform.h` files only ever define
      the differently-named `HAL_EEPROM_SIZE` capability flag — no collision
      possible by construction. `HAL_GPIO_IRQ_HANDLER` is `#ifndef`-guarded
      once in hal_gpio.h:139-140 (CONTRACTS.md #2.2) and every port's
      platform.h explicitly comments "deliberately NOT defined here". The
      checkbox was stale, not aspirational: the work landed in Phase 1
      (22aa27c) and nobody ticked it. All 7 ports' warning ratchets stayed
      green (`ci/warn_ratchet.py` against every `ci/warn_baseline_*.txt`,
      0 new warnings anywhere) and AVR golden `make validate` PASSED
      (MD5 79af184e67b27defd27a39309ac53563) throughout.
- [x] **Loud-failure guard — ALREADY LANDED (Phase 1, 22aa27c), PROVEN LIVE
      this session.** `hal.h:49-51`: `#if !defined(__AVR__) &&
      !defined(GRBL_PRELUDE)` / `#error "No build prelude injected - build
      via the platform Makefile..."`. AVR is excluded by the `__AVR__` guard
      (its own injection is the root Makefile's single `-include
      grbl/platform/common/gpio.h`, no prelude — see the AVR-exemption
      Decision Log entry below) so this cannot break the golden build.
      Every one of the 7 non-AVR ports' `prelude.h` defines `GRBL_PRELUDE`
      (grep across `grbl/platform/*/prelude.h`, `grbl/platform/*/boards/*/
      prelude.h` — 7/7). PROVEN, not just inspected: temporarily deleted
      ` -include prelude.h` from `stm32f103/Makefile`'s `CFLAGS_EXTRA`,
      rebuilt — first TU fails with
      `hal.h:50:4: error: "No build prelude injected - build via the
      platform Makefile (it passes -include <board>/prelude.h); see
      grbl/platform/ARCHITECTURE.md"`, `make` exit 2. Restored the flag,
      rebuilt clean (`BOOT INTEGRITY: OK`, ratchet OK). `git diff` on the
      Makefile is empty after restore — no residue.
- [x] **Roll prelude pattern to stm32f103 / stm32h523 / atmega328p — ALREADY
      ROLLED to every non-AVR port, atmega328p DECIDED EXEMPT.** Verified
      live via `grep -rn -- '-include' grbl/platform/*/Makefile`: stm32f103,
      stm32h523, stm32f411, sg2002 each have exactly one
      `-include prelude.h`; samd21, ch32v006, dspic33ak128mc102, `_template`
      each have exactly one `-include $(BOARD_DIR)/prelude.h` — no port has
      a second `-include` flag anywhere. atmega328p: the canon does NOT
      apply, by deliberate decision, not oversight — see the new Decision
      Log entry "AVR prelude-canon exemption" below (single already-minimal
      `-include`, zero redefinition hazard on that path, and the golden-MD5
      gate makes touching it a pure liability). ARCHITECTURE.md's own
      "Build Prelude" section had gone stale (listed only samd21/stm32f103/
      stm32h523/sg2002, missing stm32f411/ch32v006/dspic33ak128mc102/
      `_template`, all of which had already landed the identical shape in
      earlier batches) — corrected in this batch along with the explicit
      AVR-exemption rationale.
- [x] **Finish naming migration: IRQ handler macro canon — HAL_GPIO_IRQ_HANDLER
      confirmed as THE canon, two genuinely dead "short name" aliases
      removed.** CONTRACTS.md #2 and every core use site (grbl/limits.c,
      grbl/system.c) and every landed port's platform.h/handlers.c comments
      already spelled `HAL_GPIO_IRQ_HANDLER` consistently — that was never
      in doubt. What was NOT resolved: two alternate "short name" macro sets
      sitting unused since they were written. Grepped core + all 7 ports for
      call sites of each — zero, in both cases:
      (1) `GPIO_ISR(name)` in hal_gpio.h (an alias to `HAL_GPIO_IRQ_HANDLER`
      that nothing ever called); (2) `GPIO_INT_ENA`/`GPIO_INT_DIS`/
      `IRQ_HANDLER` in atmega328p/platform.h, explicitly commented "for
      future use - not yet in base code" since they were added — that future
      never arrived. Removed both (not kept as "compatibility aliases":
      nothing is compatible with a name it never used), each replaced with a
      comment explaining what was removed and why, and an invitation to
      reintroduce with a real caller if one ever appears. atmega328p's edit
      is inside a macro-only, AVR-only header with no expansion anywhere in
      the golden build — confirmed with a rebuild: `make -C
      grbl/platform/atmega328p validate` still PASSED, MD5 unchanged.
- [x] Truth-update PLATFORM_ROADMAP.md — CLOSED 2026-07-26 (release-readiness truth audit,
      see Current State): full pass, not just the SAMD21 percentage — every platform section,
      the CI row count, and the Next Steps/Implementation Priority lists were stale and are now
      corrected against fresh builds.

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
- [x] **`_Static_assert` sweep (2026-07-26)**: beyond the landed CPU_FREQ example,
      four more contract classes now fail the build instead of the field:
      (1) **SPINDLE_PWM_MAX_VALUE <= 255** (duty-cap-twins class, CONTRACTS.md
      #6.2 — the exact bug h523 and f103 both shipped: PWM_MAX=1000 against a
      uint8_t core duty) added to stm32f103/h523/f411, ch32v006, dspic33ak128mc102,
      `_template` (6 ports). samd21 (megarm+generic) DELIBERATELY EXCLUDED at the
      time — it was the one port that still genuinely violated this (65535, a
      documented pre-existing gap, CONTRACTS.md #6.2), so adding the assert then
      would have converted a known runtime bug into an unrelated build break; a
      comment at each board's config.h said so and left the actual PWM-range fix
      for its own Renode-verified batch. **CLOSED 2026-07-26** (see the dated
      entry near the end of this file, "samd21 duty-cap-twins closure"): both
      boards now declare `SPINDLE_PWM_MAX_VALUE 255` and carry the same
      `_Static_assert` as the other 6 ports — the class has no exception left on
      any port. (2) **NVMEM window <= cache size**
      (BUG #20 class) already existed on stm32h523/stm32f411; stm32f103 was
      missing it (never violated it — 1024×2=2048 <= the 4096 default — but
      had no guard against a future regression) — added, matching the
      existing two ports' wording. samd21/ch32v006/dspic33ak128mc102 don't
      need the equivalent: their staging buffers are sized directly from the
      same macro as the erase unit (`page_buffer[NVMEM_PAGE_SIZE]` etc, no
      independent Makefile-supplied override to drift against) — checked, not
      assumed. (3) **STEP/DIR logical bits <= 7** (BUG #17 class,
      CONTRACTS.md #1) added to all 7 non-AVR ports' bit-map headers/configs
      (stm32f103/h523/f411, ch32v006, dspic33ak128mc102, samd21 megarm+generic,
      `_template`) — codifies the exact invariant BUG #17's fix established so
      a future re-pin can't silently regress into the same truncation.
      atmega328p/grbl/cpu_map.h intentionally untouched (core file, golden
      byte gate, out of the port-code review scope). (4) **RX/TX buffer size
      vs uint8_t ring index** (BUG #12 class) added to the three TU-replacement
      `serial.c` files (samd21, ch32v006, dspic33ak128mc102) whose head/tail
      are `uint8_t` and wrap via plain `+1` — `RX_BUFFER_SIZE`/`TX_BUFFER_SIZE`
      must be <= 255 or the ring math overruns the index type; codifies the
      `(1-254)` limit `grbl/config.h`'s own commented-out override already
      states in prose. All are one-line `_Static_assert`s at the point the
      contract's inputs become known, no new machinery. GATES: all 7 ports
      rebuilt both flavors where applicable clean (0 assert failures except
      the deliberately-excluded samd21 PWM case, which was never attempted);
      sizes byte-identical to the canonical table (f103 28700/80, h523
      25132/388, f411 25796/80, ch32v006 41072/0, samd21 megarm 31952/296);
      all warning ratchets stayed green (0 new warnings, verified per-port
      via `ci/warn_ratchet.py` against every `ci/warn_baseline_*.txt`); AVR
      golden `make validate` PASSED throughout (untouched by this batch —
      no platform/atmega328p or grbl/ core file in this sweep).
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

## Phase 4 — Fresh Port by the New Rules (ch32v006)   [COMPLETE 2026-07-24]

M1-M3 landed 2026-07-23: skeleton+clock+GPIO compile for rv32ec_zicsr; 32
PORT_TODO_* remain (timers/serial/nvmem/handlers = Steps 3-6, next batch);
GAP LOG (8 items) folded into CONTRACTS.md §14 — the "each port strengthens
the system" loop closed for the first time. PFIC regs UNVERIFIED placeholders.

Cheapest silicon, sharpest differentiation, and RISC-V stresses the abstraction on a new
axis. Port strictly by copying `_template` + Phase-2 contracts. Count every contract gap
discovered and fold it back into docs/template — "each port strengthens the system"
made operational.

- [x] ch32v006 port COMPLETE: zero PORT_TODO at link (both flavors), RELEASE
      55560 fits 61K window; RM-mining caught 3 silicon bugs pre-write (PFIC
      offsets, HPRE /3 trap, 2WS); TIM3-no-IRQ -> STK HCLK/8 == AVR F_CPU/8;
      all BUG#12/13/17/19 lessons applied; 2 CI rows + baseline added
- [x] Contract amendments: §14 items 2/7/8 closed (TRM cites), 6 upgraded, NEW 9-13
- [x] Platform in CI matrix (2 rows); emulation smoke: Renode has no QingKe model — hardware/community item

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
- [x] stm32f411 COMPLETE (rolling #1): zero PORT_TODO both flavors (D 48472 /
      R 28644), 13-row CI matrix, baseline real-log (14). Old dir was fiction
      (never built, duty-cap twin inside). CONTRACTS §15: 7 family-mix traps
      (F4 = H5-GPIO + F1-EXTI/USART hybrid; TIM1@0x40010000 else SDIO hit).
- [x] **dsPIC33AK128MC102 COMPLETE** (rolling #2, THE THIRD ISA): Steps 3-6
      LANDED 2026-07-26 — `make BUILD=DEBUG` and `make BUILD=RELEASE` both
      build the FULL ELF+hex and LINK with **zero `PORT_TODO_*`** (verified:
      `nm | grep PORT_TODO` empty on both finished ELFs — `all` target flipped
      from objects-only to full ELF+hex per the M1-M3-era comment's own
      instruction). T1=stepper, SCCP1=pulse-reset (software x8 rescale instead
      of a hardware /8, since TMRPS doesn't offer it), SCCP2=spindle PWM
      (SPINDLE_PWM_MAX_VALUE=255 single canon — no duty-cap-twins bug on this
      board, config.h already had it right). UART1 real register model (fresh
      DFP mining, NOT classic UxMODE/UxSTA shape — no donor port existed).
      NVMEM: page-batched RMW using ROW PROGRAM (NVMOP=0x2, atdf-VERIFIED, not
      RM-only like most of this port) into a `__attribute__((address(...)))`-
      reserved window — link-tested to place cleanly against the *unmodified*
      vendor `.gld`, no port-authored linker script. FP knob wired
      `FP ?= DOUBLE` (this port's OWN default — native DP FPU, CONTRACTS §17
      item 7 new) with `assert_no_double.sh` disarmed and `FP=SINGLE` still
      available (bidirectional knob, unexercised). Sizes: RELEASE ~41.8KB
      code / DEBUG ~53.2KB code (of 128KB flash), RAM ~3.8KB RELEASE (of 16KB).
      Gates re-run (not just inspected): golden AVR MD5 PASSED (79af184e…,
      text 30640); samd21 megarm RELEASE 31952/296 (exact); stm32f411 RELEASE
      32660/80/129968, boot-integrity OK; ch32v006 generic RELEASE 54904/0/2749,
      boot-integrity OK. CONTRACTS §16 grew from 11 to 20 items (new: PPS
      input-vs-output verification split, NVM controller mostly atdf-verified
      — a rare case where the vendored pack DOES answer the question —, no
      PSVPAG on this core, real `__delay32`/`libpic30.h` delay mechanism, CN
      edge-style assumption). Still NOT in CI (unattended XC-DSC fetch remains
      a separate item, unchanged from M1-M3). Previous entry below (M1-M3,
      2026-07-25) preserved for history:
      NO CI rows yet — XC-DSC fetch-in-CI = separate item. NOTE: agent pushed
      directly (protocol deviation, prompt omission) — post-hoc gates ALL
      GREEN (golden, samd21 60864, h523 48644); accepted. Future briefs
      re-state: NEVER push, return diffs.
      (original entry: owner-requested 2026-07-23; chip chosen by executor:
      28-pin = ATmega328p DIP-28 heir, 200 MHz, DP-FPU, motor-control PWM + SCCP/MCCP,
      PPS pin remap eases 28-pin budget; MC106 Curiosity = community hardware variant.
      Third ISA family (non-ARM, non-RISC-V) — hardest portability stress test.
      Toolchain: XC-DSC verified recipe in Decision Log. **EULA APPROVED BY OWNER
      2026-07-24** — unattended CI wiring authorized, no remaining blockers)
      * [x] **M1-M3 LANDED 2026-07-25**: toolchain reinstalled per recipe end-to-end
        (xc-dsc-gcc 8.3.1 / XC-DSC v3.30, SHA-256 match; DFP 1.5.263 unzipped to
        /opt); skeleton+clock+GPIO real, all 20 objects compile both flavors,
        `make link` = exactly 33 PORT_TODO_* (timers/serial/nvmem/handlers,
        Steps 3-6), nm-vs-link diff proves list complete. NO startup.c by design
        (toolchain crt0 + linker-synthesized IVT + user_init clock hook — see
        platform.c banner). 200 MHz FRC->PLL1 from Microchip's own docs,
        UNVERIFIED on silicon (no dsPIC33A emulator exists — hardware item).
        Gap log: CONTRACTS.md NEW §16, 11 items (3rd-ISA holes: linker-owned IVT,
        compiler-won't-emit-bset atomicity, barrier-free ISA, xc-dsc -O1/-Og ICE
        on gcode.c -> DEBUG=-O0, TRIS/ANSEL double trap, config-word WDT,
        19-vs-20 pin budget via AVR's own PWM/enable share precedent, DFP
        Apache-2.0 headers over clean-room). Gates: golden AVR MD5 PASSED,
        sibling RELEASE sizes byte-identical (ch32 55560, samd21 43036,
        f103 29900). **NO CI ROWS YET — unattended XC-DSC fetch in CI is a
        separate item** (installer is 83 MB from ww1.microchip.com; needs a
        cache strategy decision). Warn baseline: deferred with the CI row.
      * [x] **Steps 3-6 LANDED 2026-07-26**: T1 stepper timer + SCCP1
        pulse-reset + SCCP2 PWM + UART1 + NVM flash window (row-program,
        atdf-verified page/row sizes) + CN interrupts (edge-style, ASSUMED)
        + real delays (`__delay32`/`libpic30.h`). The CLKGEN-feeds-
        peripherals question (§16.10) and the SCCP MOD/CLKSEL/TMRPS
        encodings (§16.13 new) remain UNVERIFIED — genuinely RM-only, no
        amount of DFP grepping resolves them — loudly flagged in
        timer.h/platform.c, does not block the zero-PORT_TODO_* build
        goal. IPCx priorities set explicitly: CCT1IP=5 > T1IP=4
        (pulse-reset preempts stepper — dsPIC33A nests by priority
        natively, the first port that can honor this AVR sei()-nesting
        semantic for real). FP knob: `FP ?= DOUBLE` declared default
        (native DP FPU, CONTRACTS §17 item 7).
      * [x] **CI wiring LANDED 2026-07-26**: dedicated `build-dspic33ak128mc102`
        job (NOT a `build` matrix row - the shared composite action is
        apt-only; see the job's own header comment in `ci.yml` for the
        justification), 2 matrix legs (DEBUG/RELEASE). Installer + DFP each
        cached via `actions/cache`, keyed on version+SHA-256 (not just
        version), verified with `sha256sum -c` every run (cache hit AND
        miss) before install/unzip. Re-verified end-to-end this session,
        for real, not re-quoted from the recon entry below: fresh 83 MB
        installer download, SHA-256 MATCHED
        (0df20c1a552bf0ce08aa139b9cb1efd71bf65b9d9f37e3982763f4f8738bfa11);
        fresh unattended install to a clean prefix (~19-23s, no network);
        fresh 15 MB DFP download, SHA-256
        811360fb86d92e3d4519dab3948bf895e8468b37ab7203a7d5ca2bfac2b07bbb —
        NEW this session (the original recon below only recorded the
        installer's hash), cross-checked against the download server's own
        `x-amz-meta-sha256` header, independent match; `make BUILD=DEBUG
        link` and `make BUILD=RELEASE link` both succeed (~3-5s each),
        zero `PORT_TODO_*` in both ELFs (nm-verified). Warn baseline
        (`ci/warn_baseline_dspic33ak128mc102.txt`) generated from these
        real logs: identical 4-warning core-only class every other port's
        baseline has (gcode.c/motion_control.c/report.c/system.c).
        TWO real gaps found and handled, neither a port-source fix (gate:
        no port sources touched):
        (1) [x] **FIXED 2026-07-26** (see Decision Log "dsPIC `make all`
        HEX-STEP FOLLOW-UP CLOSED" entry below for the full proof): the
        landed Makefile's `$(HEX_FILE)` rule calls `$(BIN2HEX) $<`
        without `-mdfp=`, but bin2hex hard-requires it (confirmed: same
        command + `-mdfp=` succeeds) — `make ... all` therefore used to
        fail at the hex step for both flavors. Was worked around at the
        workflow level (`make ... link` + a workflow-level `bin2hex
        -mdfp=...` step) instead of patching the Makefile; now patched at
        the source (Makefile passes `-mdfp=$(DFP_XC16)`), `ci.yml`
        simplified back to `all`, workaround step removed.
        (2) a shell bug caught in this job's OWN first draft, not the
        port: `elf="...$( [ "$X" = Y ] && echo z )..."` silently kills a
        `run:` step under GitHub Actions' default `bash -eo pipefail` the
        moment the test is false (no `echo` runs to absorb the nonzero) —
        would have broken the RELEASE leg's hex/assert steps specifically,
        every time, silently. Fixed to plain `if/then` before landing.
        RELEASE caveat carried into the workflow (`::notice::` + comment,
        not asserted): XC-DSC FreeMode prints "Options have been disabled
        due to restricted license" on every `-Os` TU (confirmed: 20/20
        RELEASE compiles this session). **Settled later (see the CANONICAL
        RELEASE SIZE TABLE / dsPIC size note): this is FreeMode silently
        substituting `-O2` codegen for `-Os`, not a source of numeric
        doubt — the RELEASE byte count itself is exact and reproducible**
        (confirmed by a byte-identical whole-firmware rebuild with an
        explicit `-O2`), it just isn't true `-Os` codegen.
        Gates re-run: golden AVR MD5 PASSED (79af184e…) — untouched by
        this session, CI-wiring-only. ch570: not landed on origin as of
        this session (`grbl/platform/ch570/` absent, checked via
        `git ls-tree` against this branch and `origin/master`) — a
        clearly-marked TODO left in `ci.yml` instead of a guessed row.
- [x] **hc32f460 COMPLETE** (rolling #3, first HDSC/Huada vendor-exotic chip):
      `make BUILD=DEBUG`/`BUILD=RELEASE` both build all objects and LINK with
      **zero `PORT_TODO_*`**, zero undefined symbols (`nm -u` empty both
      flavors). Sizes: DEBUG 41220/80, RELEASE 25596/80 (of 512KB flash/128KB
      RAM). Old directory was fiction (platform.h doc-skeleton only,
      `#include "hc32_ddl.h"` never vendored, no Makefile/startup.c/
      platform.c/anything else) — never built, same class as the
      stm32f103/h523/f411 predecessors. No donor port in this tree shares
      this vendor's peripheral IP AT ALL (TIMER0/TIMERA, GPIO PORT model,
      INTC event router, EFM flash, PWC/CMU clock tree) — the first port
      where "reuse a donor's shape" had literally nothing to reuse.
      Verification: no permissively-licensed vendor SDK confirmed (HDSC's
      own `hc32f4a0_ddl` exists publicly but no LICENSE file found — unlike
      dsPIC33AK's Apache-2.0 DFP or ch32v006's Apache-2.0 Zephyr dtsi), so
      this port is clean-room per PORTING-CHECKLIST's stated fallback,
      cross-checked (not copied) against Klipper3d/klipper's real shipped
      GPL-3.0 firmware for this exact chip (GPIO register names, the INTC
      routing mechanism, TIMERA-as-PWM, three real CMU clock addresses from
      a real bootloader). Every other register fact is an explicitly
      UNVERIFIED placeholder flagged at its own definition site in `regs.h`
      — the port is NOT claimed "ready for hardware validation" in the
      unqualified sense stm32f411 was; see `hc32f460/platform.md` and
      [CONTRACTS.md section 22](CONTRACTS.md#hc32f460-gaps) (new, 9 items: no-donor-IP-at-all,
      vendor-SDK-license-came-back-negative for the first time, Klipper-as-
      real-firmware-cross-check as a new source class, the INTC event-router
      as a 4th interrupt-architecture family, split USART RX/TX interrupt
      sources, per-pin (not per-port) GPIO config register, the
      every-UNVERIFIED-flagged-at-definition-site methodology, FPU verdict,
      gate re-run). FP=SINGLE (default): `assert_no_double.sh` PASSED both
      flavors; disassembly confirms `vsqrt.f32` (1) + 82 `vmul.f32` + 161
      combined vadd/vsub/vdiv.f32, **zero** `__aeabi_d*`/DP soft-float
      symbols anywhere (cleaner than stm32f411's one tolerated `__aeabi_d2f`).
      Boot-integrity (`common/boot_check.sh`) PASSED both flavors. Gates
      re-run (not just inspected): golden AVR MD5 PASSED (79af184e…, text
      30640); samd21 megarm RELEASE 31952/296; stm32f103 RELEASE 28700/80;
      stm32h523 RELEASE 25132/388; stm32f411 RELEASE 25796/80; ch32v006
      generic RELEASE 41072/0 — all six siblings byte-identical, confirming
      this port touched only `grbl/platform/hc32f460/`, CONTRACTS.md,
      PLAN.md, PLATFORM_ROADMAP.md, `ci/warn_baseline_hc32f460.txt`, and
      `.github/workflows/ci.yml`. CI: 2 matrix rows added
      (`hc32f460` × `{DEBUG, RELEASE}`), warn baseline generated from real
      build logs. Not smoke-tested (no HC32F460 emulator exists) — marked
      "gaps require hardware bring-up" rather than "ready for hardware
      validation" in PLATFORM_ROADMAP.md, reflecting the UNVERIFIED register
      facts honestly.
- [ ] sg2002 (RISC-V 64, linux-class — decide scope first: bare-metal vs linux userspace)
- [ ] hc32f460 (ARM M4, vendor-exotic — tests contract completeness)
- [ ] **sg2002** DESIGN-COMPLETE / IMPLEMENTATION-DEFERRED (2026-07-26 runtime-core
      design batch; owner's scope ruling below, executor's recommendation to defer
      actual coding, owner may overrule in one line):
      * **Scope ruling (owner)**: Linux side is OUT OF SCOPE. The deliverable is a
        bare-metal blob for the runtime core only — loadable and restartable from
        Linux, not a Linux-side driver or userspace daemon we author from scratch
        beyond the small bridge below.
      * **FACT CORRECTION to the owner's model** (stated plainly, as requested):
        the RISC-V-vs-ARM choice does NOT apply to the core this project targets.
        That choice belongs to the BIG, Linux-hosting core (C906 or Cortex-A53,
        mutually exclusive, selected by a boot-time strap — SG2002 ships as either
        variant, never both). The runtime core this port actually targets is a
        C906L (RISC-V, 700MHz, no MMU, M-mode) on EVERY SG2002 configuration —
        there is never a free ARM core to target instead. So "both ISA variants"
        collapses to ONE port, not two: the Linux-side ISA becomes a
        COMPATIBILITY AXIS to test against (the mailbox, reset controller, and
        DDR carve-out all hang off shared SoC fabric, so the same runtime-core
        blob should work unmodified under either big-core ISA), not a second
        implementation to write.
      * **Lifecycle**: reuse the upstream remoteproc driver
        `sophgo,cv1800b-c906l` as-is — load/start/stop/restart via the standard
        `/sys/class/remoteproc/.../state` sysfs interface, ELF segment loading
        into a device-tree `reserved-memory` region, no new kernel code needed
        for lifecycle. Its mailbox IPC half was explicitly deferred upstream
        ("added in a separate patch" per the upstream commit) — the data channel
        is ours to design and build. Use ONE carve-out: the same reserved-memory
        region backs both the firmware image and the shared-memory rings, no
        second region to coordinate.
      * **Channel design**: implement CONTRACTS §7 (`HAL_SERIAL_*`) over a
        shared-memory ring instead of a UART. `RX_PENDING` becomes `head != tail`
        on the ring. The mailbox-doorbell IRQ IS `HAL_SERIAL_RX_ISR()` — but it
        must DRAIN-LOOP inside the handler, because a doorbell fires once per
        burst, not once per byte. That is a deliberate, contract-legal
        cardinality change (§7's table binds semantics, not a 1-IRQ-per-byte
        cardinality) and a genuine overhead win: orders of magnitude fewer IRQ
        entries than a byte-at-a-time UART. Critically, BUG #19's realtime-command
        interception (mc_reset/status/feed-hold/cycle-start byte-sniffing) lives
        in core serial.c's RX-ISR body, not in the platform macros — so it is
        INHERITED UNCHANGED as long as the doorbell ISR calls
        `HAL_SERIAL_READ_DATA()` the same number of times it would for N
        individual bytes. That call-count invariant is the one thing a future
        implementer must not violate when writing the drain loop. New cross-core
        cache-maintenance obligation for this ring: [CONTRACTS §23](CONTRACTS.md#cross-core-cache-coherency) (writeback
        before doorbell, invalidate before read, or map the window non-cacheable
        and skip the whole class).
        Linux side needs NO custom kernel module: `mmap()` the ring out of the
        existing reserved-memory carve-out (exposed via the stock upstream
        `uio_pdrv_genirq` driver — a devicetree binding change, not new C code —
        to deliver the doorbell IRQ to userspace), and bridge ring<->PTY in
        roughly 200 lines of userspace, with the PTY end symlinked to
        `/dev/ttyGRBL` so unmodified senders (any GRBL sender talking to a serial
        device) work without changes.
      * **Open point, not hand-waved away**: TX backpressure. GRBL's TX path
        assumes a hardware TX-empty IRQ; a shared-memory ring instead needs the
        Linux-side bridge to doorbell BACK when it drains ring space, or the
        runtime core has nothing to interrupt on. Generous ring sizing makes the
        condition rarely bind in practice, but this is NOT fully solved by this
        design pass — flagged for whoever implements, not silently assumed away.
      * **Why deferred (executor's recommendation)**: no public TRM exists for
        SG2002 — every peripheral/IRQ/cache fact in this entry and in
        [CONTRACTS §23](CONTRACTS.md#cross-core-cache-coherency) is community-sourced (kernel patches, SDK headers, board-support
        repos), not vendor documentation. And — a first for this project — there
        is NO emulator model available for pre-hardware verification of a
        correctness-critical class (the cache-coherency work of
        [§23](CONTRACTS.md#cross-core-cache-coherency) specifically
        needs real silicon or a cycle-accurate multi-core model neither Renode
        nor QEMU provide here). Cheaper, unblocked queue items (ch570, fully
        recon'd and ready) and in-flight work (hc32f460) should land first;
        owner may overrule this ordering in one line.
- [x] **ch570 COMPLETE** (rolling #4, second WCH chip, first shared-code
      extraction): Part A extracted `common/wch/{wch_pfic.h,wch_critical.h,
      wch_vectors.h}` out of ch32v006's ALREADY-LANDED PFIC struct/
      enable-disable, mstatus critical-section/sei/cli/fence, and mtvec
      vectored-mode write — HARD GATE PASSED: ch32v006's RELEASE `.bin`
      MD5 identical before/after (`075d79ced3a3f7e9324e93f6936bec54`),
      both flavors' `text/data` unchanged (41072/0 RELEASE, 46988/0
      DEBUG), zero new ratchet warnings. Part B ported CH570 consuming it
      plus a from-scratch chip layer (GPIO/UART/timers/flash are entirely
      different IP, per the recon below): `make BUILD=DEBUG`/`BUILD=RELEASE`
      both LINK with **zero `PORT_TODO_*`** (verified via `nm | grep
      PORT_TODO`, empty both flavors) and **zero compiler warnings on
      platform files** (baseline holds only the same 4 core-file warnings
      ch32v006's baseline already has). Key facts closed during the port
      (CONTRACTS.md new gap-log section, full detail there): (1) the
      vendor SDK's own `core_riscv.h` interrupt-enable helper uses a
      DIFFERENT CSR (raw 0x800) than the named `mstatus` (0x300)
      `wch_critical.h` extracted from ch32v006 — resolved by finding TWO
      independent, hardware-facing sources (WCH's own official
      `startup_CH572.S` boot assembly, and cnlohr/ch32fun's MIT,
      hardware-exercised, cross-generation codebase) both use `mstatus`
      under a mainline toolchain, confirming the extraction was right and
      the vendor C helper is the outlier, not reproduced. (2) That same
      vendor startup file ACTIVELY SETS INTSYSCR=0x3 (both HWSTKEN and
      INESTEN) during boot — the opposite of what this project's plain
      `interrupt` attribute needs — so CH570's startup.c explicitly WRITES
      INTSYSCR=0 (`wch_intsyscr_clear()`, new in `wch_vectors.h`, NOT
      called by ch32v006 so its byte-identity gate holds) instead of just
      trusting the documented reset-0 value. (3) TMR0 (the only
      FIFO/DMA-capable timer) has no hardware clock prescaler — folded
      into a software multiplier so `STP_TMR_PRESCALER_SET` stays a real
      semantic, not a silent no-op. (4) GPIO interrupt hardware is
      single-polarity edge-select only — closed via a new edge-flip
      technique (arm one polarity, XOR it after each fire) that reproduces
      CONTRACTS §2.6 "any pin CHANGE" semantics without hardware support
      for it. (5) The flash program/erase algorithm is vendored as a real
      linked binary object (`vendor/ISP572.o`, Apache-2.0, openwch/ch570) —
      **the first vendored BINARY in this project's tree**, flagged
      plainly for the owner: NOT a "boot-ROM call" (corrected after
      integration review — it is an ordinary linked function, disassembly
      confirms every internal call stays inside the same object) and NOT
      avoidable by calling a documented entry point ourselves — the
      CH572/CH570 Datasheet V1.1 states outright that it "does not
      provide the introductions to FlashROM word data registers and
      FlashROM control registers" and directs implementers to "call
      related subprograms." Disassembly (~1.3KB of real control flow:
      PFIC interrupt masking around the operation, address-range bounds
      checking, an 8-command dispatcher, a real erase block-size-
      selection loop) confirms it is not a thin trampoline either -
      reimplementing it would mean hand-transcribing undocumented vendor
      logic from disassembly (strictly riskier than linking the tested
      object, for no legal gain since Apache-2.0 already permits
      vendoring outright). Full investigation + the disassembly evidence
      is in CONTRACTS.md's gap-log item 6.
      **INTEGRATION REVIEW (post-batch, both blockers now closed):**
      (a) `.gitignore`'s blanket `*.o` rule was silently swallowing
      `vendor/ISP572.o` from every `git add -A` (same class of trap as
      the README.md rule during `_template` work) — fixed with an
      explicit `!grbl/platform/ch570/vendor/ISP572.o` exception, verified
      three ways: `git check-ignore -v` (negation confirmed active),
      `git add -A` (file now stages as `A`, not silently skipped), and a
      genuine simulated fresh checkout (`git archive` of a
      `git stash create` snapshot — a dangling commit object that touches
      no branch/ref/HEAD — extracted to a clean directory and rebuilt:
      identical RELEASE 40674/4/6849, `assert_no_double.sh` PASSED, boot
      integrity OK). (b) A second, independent correction from the same
      review: `nvmem.c`'s region-write-enable bracket originally claimed
      "least privilege" (narrower `RB_ROM_CODE_WE` grant before calling
      the vendor function); `readelf -r vendor/ISP572.o` shows both
      `FLASH_CMD_ROM_WRITE`/`FLASH_CMD_ROM_ERASE` call `FLASH_START`
      first, which unconditionally re-widens that same register to full
      access — so the narrower grant only protects the margins around
      the call, not the operation itself. Comments corrected to say so
      honestly rather than repeat the overclaim.
      Gates re-run (not just inspected): golden AVR MD5 PASSED
      (79af184e…, text 30640); samd21 megarm RELEASE 31952/296; stm32f103
      RELEASE 28700/80; stm32h523 RELEASE 25132/388; stm32f411 RELEASE
      25796/80; hc32f460 RELEASE 25596/80 — every sibling byte-identical.
      FP=SINGLE (default) `assert_no_double.sh` PASSED both flavors (zero
      DP machinery, third RISC-V target confirmed — this one has hardware
      M-extension multiply/divide but still no FPU, same leak class as
      ch32v006's rv32ec). Boot-integrity (RISC-V `_start`-at-flash-base
      form) PASSED both flavors. `mret` (opcode `0x30200073`)
      disassembly-confirmed in all four real vector bodies. Sizes: DEBUG
      46830/4/6850, RELEASE 40674/4/6849 (of 236KB usable flash / 12KB
      RAM — 4KB reserved for NVMEM). CI: 2 matrix rows added
      (`ch570` generic × `{DEBUG, RELEASE}`), warn baseline from real
      build logs. NOT marked ready for hardware validation (no CH570
      emulator exists, same posture as every RISC-V port so far) —
      `boards/generic/config.h` is an explicit PLACEHOLDER pin map that
      exceeds this chip's real 12-pin GPIO budget (datasheet-confirmed),
      flagged loudly in its own file header, same class of honesty
      ch32v006's and dsPIC33AK's own generic boards already established.
      Previous recon entry preserved below for history:
- [ ] ~~ch570 RECON DONE~~ (superseded by COMPLETE above): QingKe V3C RV32IMBC (full
      I+M — hw mul/div!, exact rv32im/ilp32 picolibc multilib exists), 240K user
      flash + 12K RAM (owner claim confirmed, ~$0.10 — cheaper than V006).
      SURPRISE: peripherals are ENTIRELY different IP vs V006 (16550-style UART,
      AVR-style discrete-reg GPIO with per-port vectors, FIFO/DMA timers ALL with
      IRQs, 4KB-sector flash w/ RWA unlock) -> honest common/wch reuse = 15-20%,
      NOT stm32's 60%: extract only wch_pfic.h (layout byte-identical, 2 indep
      sources), wch_critical.h (mstatus/fence), wch_vectors.h (mtvec MODE 1/1).
      Friendlier chip overall: no E-quirks, no EXTI collision class, no dead
      timers. openwch/ch570 SDK is Apache-2.0 — headers vendorable (unlike CH32V
      EVT). ✅ BLOCKER RESOLVED: QingKe V3C's HWSTKEN is CSR-gated (INTSYSCR,
      CSR 0x804) and RESETS TO 0 — primary source CH572/CH570 Datasheet V1.1
      §3.4.2, shipped in openwch/ch570 (Apache-2.0) — identical semantics to
      V2C (CONTRACTS §14 item 2). NOT unconditional hw stacking; plain GCC
      `__attribute__((interrupt))` at reset-default INTSYSCR is safe, same as
      ch32v006. Companion trap this recon surfaced, see [CONTRACTS §20](CONTRACTS.md#wch-isr-attribute): the
      vendor's own `"WCH-Interrupt-fast"` attribute silently no-ops on this
      toolchain — do not copy it. **CH570 is unblocked for porting.**
      Confirmed facts for whoever writes the port: (1) PFIC register offsets
      are byte-identical to ch32v006's verified V2C layout (CONTRACTS §14
      item 7) — confirms the wch_pfic.h extraction plan above; mtvec
      MODE0/MODE1 semantics identical too (confirms wch_vectors.h). (2) The
      shareable set GREW by one item: the interrupt-entry strategy itself
      (INTSYSCR=0 + plain `interrupt` attribute) transfers, not just the
      register primitives. (3) Flash is materially DIFFERENT from ch32v006 —
      4096-byte erase blocks, and write/erase go through a boot-ROM call
      [CORRECTION, landed batch: not a boot-ROM call - an ordinary linked
      function, see the COMPLETE entry above and CONTRACTS.md gap-log
      item 6 - preserved verbatim below as the recon's own words at the
      time, not edited retroactively]
      `FLASH_EEPROM_CMD()` gated by a "safe access" unlock (write 0x57 then
      0xA8 to `R8_SAFE_ACCESS_SIG`, ~112-cycle window) plus `R8_GLOB_ROM_CFG`
      region write-enable — NOT a KEYR-style unlock, so ch32v006's
      flash/nvmem code is not reusable there. (4) STK (systick analog) at
      0xE000F000: CTRL bit0 STE, bit1 STIE, bit2 STCLK, bit3 STRE, bit4
      MODE, bit31 SWIE; SR bit0 CNTIF is write-0-to-clear — the same
      inverted-polarity trap already flagged for ch32v006 (CONTRACTS §14
      item 7). Slot: after dsPIC Steps 3-6.
      Side-note for docs-truth backlog: common/stm32/ARCHITECTURE.md is
      marketing-toned ("A+ 97%" self-grading, 60%/2hr claims) — needs the
      evidence-first rewrite treatment eventually.
- [ ] any new platform dir that appears — same loop

Standing laws for every port: reuse before write (stm32 common.mk pattern, common/
helpers); duplication is a defect; KISS; models >= sonnet; all mutation via worktree
agents; golden AVR checksums untouchable.

---

## Orchestration Protocol

**Roles**: owner holds the canon (naming, taste, architectural forks — decisions recorded
below). Split is now strict:

- ORCHESTRATOR (main loop): mechanics with ZERO authorship — git integration of
  agent-authored bytes (fetch/apply/cherry-pick/cp from worktrees), running gates/
  verification commands, commit/push, reading. NEVER authors file content, including
  the ledger.
- AGENTS: every authored byte — code, docs, baselines, AND ledger updates: each batch
  agent updates this file's relevant entries (its checkboxes, Current State delta,
  Decision Log if a decision was made) INSIDE its own worktree as part of its batch;
  standalone cross-batch ledger notes go through a scribe agent.

Owner correction 2026-07-24 ("Сам? Ты же оркестратор!!") after the orchestrator was
caught authoring ledger edits/baseline merges/roadmap refreshes inline — the early
"ledger = orchestrator bookkeeping" exception is REVOKED.

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

**LIMIT-RECOVERY PROCEDURE** (mandatory, unprompted — owner correction 2026-07-24,
"Далее не жди пинка. Восстановление после лимитов подразумевает восстановление
ворктри. Логично??": the orchestrator runs this the moment any limit/kill is
observed, without waiting for the owner):

1. INVENTORY the whole front, do not just retry the one agent that reported: list
   `.claude/worktrees/*` and cross-check against dispatched agents. Transcript
   file size and `git status --porcelain` diffs are LAGGING indicators, NOT a
   liveness test — an agent doing a long tool call (a download, a clean
   rebuild, an emulator run) legitimately produces zero transcript growth and
   zero worktree diff for many minutes while very much alive. Death is proven
   ONLY by (a) an explicit failure/kill notification, or (b) silence far
   exceeding the batch's plausible runtime — hours, not minutes. NEVER declare
   an agent dead on silence alone, and NEVER `git worktree remove` a worktree
   whose agent has not reported terminal status; pruning is for worktrees
   whose bytes are already in origin, full stop. (Observed 2026-07-25: two
   agents sat at a 115-byte stub transcript with zero worktree changes for
   6+ minutes; the orchestrator declared them dead, relaunched duplicates, and
   ordered `git worktree remove --force` on both. Both were alive — one was
   downloading a 102MB emulator, the other probing builds — and both later
   completed successfully with full evidence (the FP=SINGLE arbitration and
   the BUG #21 fix). The worktrees survived only because git refused to
   remove directories still in use; a duplicate pair of agents was spawned for
   work that was already in progress.)
2. SALVAGE before relaunch: a killed agent's worktree may hold real work (partial
   diffs) or expensive assets (an extracted datasheet, a downloaded emulator, a
   reference commit). Inspect it, and pass its path to the replacement agent so
   the work is reused, not redone.
3. RELAUNCH the dead ones immediately with the same brief plus the salvage
   pointer. Do not park work for the cron alarm — the alarm is fallback recovery
   for the orchestrator's own death, never a scheduler.
4. PRUNE only worktrees whose bytes are already in origin, or that hold zero
   changes. Never delete an unlanded worktree.
5. VERIFY the relaunch actually started (transcript growth), then continue.

**GIT APPLY CAUTION** (same incident, 2026-07-25): `git apply` is ATOMIC — a
conflict in any one file rolls back the WHOLE patch, and the per-file "Applied
cleanly" lines it prints before hitting the failing file are misleading
survivors of that rollback, not evidence of a partial apply. Never truncate its
output with `head`; always check `git status` afterward to confirm what
actually landed, and prefer `--3way` so a conflict surfaces as resolvable
markers in the tree instead of a silent no-op.

**CONTRACTS.md NUMBERING IS THE INTEGRATOR'S JOB, NOT A SHARED COUNTER**
(owner-visible failure, 2026-07-26: section 20 collided three ways, section
21 twice, requiring manual renumbering at integration FOUR times in one
day). Root cause: `CONTRACTS.md`'s sections are numbered `## N.`, and every
parallel agent appending a new section reads the current file, finds the
current highest N, and appends `N+1`. Two or three agents authoring at once
all read the SAME highest N (their worktrees forked before any of them
landed) and all compute the SAME N+1 — a shared mutable counter with no
synchronization, the classic concurrent-increment race, just done by
sub-agents instead of threads. Renumbering at integration doesn't just cost
orchestrator time: it silently invalidates every `§N`/`section N`
cross-reference an EARLIER agent already wrote into a DIFFERENT file
(PLAN.md, PLATFORM_ROADMAP.md, a port's own platform.md/README.md) pointing
at whatever used to live in that slot — those references now silently point
at the wrong section, and nothing fails to compile or build when that
happens.

**Fix, structural not procedural** (a reminder to re-brief, not just a
one-time cleanup): numbering a shared, append-only, human-readable list is
not a job parallel agents can coordinate on without a lock they don't have —
so don't ask them to. The integrator (this loop) is the only writer that
sees the whole queue at merge time, so numbering moved there:
- Authors append their new section at the end with a placeholder heading
  (`## §NEW. Title`) instead of guessing a number; the integrator assigns
  the real N when the batch lands — a rename-only edit that never collides
  because only one agent (the integrator) ever performs it.
- Every section gets a permanent slug anchor (`<a id="topic-slug"></a>`
  directly above its `## N.` heading) that never changes even when the
  integrator renumbers it. Authors cite each other BY SLUG
  (`[§N](#that-sections-slug)`), never by bare number — a slug link survives
  a renumbering; a bare `§N`/`section N` reference does not and fails
  silently (no build error, no broken link, just prose pointing at the
  wrong thing).
- `tools/check_contracts_numbering.py` (wired into CI as the `docs-integrity`
  job) fails the build on duplicate or non-sequential `## N.` numbers, a
  heading with no matching anchor, or a `#slug` link anywhere in the repo
  whose target anchor doesn't exist — the mechanical version of "verify the
  count isn't racing" that no individual agent could see on its own.
- The instruction lives at the TOP of `CONTRACTS.md` itself (right after the
  cautionary-tale paragraph, before section 0) specifically so an agent that
  reads only the top of the file before appending — which is the realistic
  failure mode, not an agent reading this ledger entry — still gets it.

**General lesson for any future shared append-only ledger this project
grows** (not just this file): if two or more agents can be authoring the
same document concurrently, any property that requires seeing "the current
state of the whole document" to compute correctly (the next number, the
next ID, a running total) MUST be assigned by whichever single agent
integrates the batch, never computed by the authoring agents themselves —
they should each author content plus a stable, collision-proof identifier
they can invent unilaterally (a descriptive slug, a UUID, their own
worktree-scoped name), and leave anything ordinal or cross-referencing that
identity to integration time.

## Decision Log

- 2026-07-26 **AVR prelude-canon exemption** (Phase 1 "roll prelude pattern"
  closure): atmega328p does NOT get a `prelude.h` and never will, by decision,
  not oversight. Reasoning: (1) it already has exactly one `-include`
  (`grbl/platform/common/gpio.h`, root Makefile) — the multi-`-include`
  disease the prelude canon was invented to cure never existed on this port;
  (2) it has zero of the redefinition hazards the canon closes elsewhere
  (`HAL_GPIO_IRQ_HANDLER`/`EEPROM_SIZE` dual-canon) — confirmed empirically,
  not assumed, by a fresh build + baseline grep this session; (3) the golden
  MD5 gate makes any speculative refactor of this path a pure liability: it
  can only ever cost bytes (if it changes anything) or nothing (if it
  doesn't), with no possible upside, since there is no bug here to fix. The
  `#error` guard in hal.h (`#if !defined(__AVR__) && !defined(GRBL_PRELUDE)`)
  encodes this exemption directly in the mechanism it partially bypasses,
  rather than as a side-channel special case — AVR is excluded from the
  check by the same condition that would otherwise demand a marker it has no
  reason to define. Revisit only if AVR ever needs a second `-include` (it
  hasn't in the project's whole history) or gains a redefinition class of its
  own (none found).
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

- REVIEW #3 verdicts (motion/#19 + h523 + ch32 M1-M3, port-code scope):
  motion batch SOUND (realtime switch verbatim vs core, __DMB intact, exit
  contract consistent); A3 NEEDS-EVIDENCE: Renode timer-shim kick may double-
  fire on idle/wake pre-first-segment (CI model only) -> hardening dispatched
  to Renode agent w/ repro-first mandate. B3 CONFIRMED-DEFECT: h523 spindle
  duty capped 25.5% (config.h:105 PWM_MAX=1000 overrides contract 255,
  ARR=1000 vs CCR1<=255) -> fix agent dispatched. C1: UNVERIFIED-constants
  dependency list forwarded mid-flight to ch32 Steps 3-6 agent (PLL shape
  verify-FIRST — poisons clocks/baud downstream). C2: ch32 DIRECTION physical
  bits confirmed contract-shape violation, §14-item-8 closure now MANDATORY
  in the in-flight batch.

- A3 CLOSED (Renode shim): reviewer hypothesis empirically REFUTED (0 firmware-
  reachable double-fires; bus-level N->N bounded, self-recovering); proposed
  lifetime-latch rejected (would deadlock captured sequence); REAL adjacent gap
  fixed instead: cc0Mirror now resets on machine Reset/SWRST (was: motion
  deadlock on emulated reboot). Smoke+negative control re-verified, elf
  byte-identical (CI-only). B3 h523 landed; f103 twin fix in flight.

- ~13:50 UTC 2026-07-24: limit wave (resets 15:00) killed ch32 Steps 3-6 (had
  CH32V006 RM extracted in worktree — asset preserved) and f103 twin duty-fix
  (mechanism confirmed, pre-disasm). BOTH resumed immediately via SendMessage
  (context+worktrees intact). If resumes die again: 15:13 cron recovers with
  this note. Owner directive active: "аккуратно развиваем прогресс по плану".

- REVIEW #4 (ch32v006 final): ALL 6 items REFUTED — independent rebuild, mret+
  full-spill disasm, disjoint EXTI masks, HPRE/2WS verified, 11-row matrix clean.
  Item 2 (STK semantics) self-consistent; final arbiter = silicon (hardware item).
  Incidental: BUILD_DIR flavor contamination bit a THIRD time -> two-strike rule
  invoked, uniform fix dispatched (all platform Makefiles + _template + common.mk).
- Worktree hygiene: all landed worktrees removed, Renode asset kept.
- PHASE 6 ROLLING STARTED: stm32f411 port dispatched (f103+common donors, F4
  specifics briefed: PLL/FPU/MODER/SR-DR, all contract lessons enumerated).
  Next in queue after f411: dsPIC33AK128MC102 (EULA approved, recipe verified).

- BUG #20 FIXED+LANDED: h523 NVMEM was FULLY DEAD (LTO stripped it in RELEASE
  — bss +8192 = subsystem alive first time). NVMEM_WINDOW_SIZE parametrized,
  _Static_assert guards the class in h523+f411 (force-fail proven). 8KB window
  is H523 minimum erase sector — unshrinkable, so parametrize was the only fix.
  dsPIC33AK M1-M3 in flight (third ISA; §16 gap-log expected).

- REPORTING DOCTRINE (owner 2026-07-24): owner-facing size metric = RELEASE
  flash body (text+data) per port; DEBUG sizes are internal gate proxies only.
  Numbers as of this doctrine's authoring (2026-07-24, since superseded twice
  — see the CANONICAL RELEASE SIZE TABLE further below for current figures):
  h523 28692 / f411 28724 / f103 29980 / AVR 30640(golden) /
  samd21 43332 / ch32v006 55560. COMPACTNESS drive dispatched: (1) ch32 diet —
  --no-gc-sections is now unjustified (port complete, PORT_TODO gone; lifecycle
  rule: no-gc during porting, gc after zero-PORT_TODO -> to _template+§14.3);
  (2) samd21 autopsy (report-first): decompose +44% vs f103 into Thumb-1/soft-div
  tax vs cold zones; DIVAS savings estimate WITHOUT implementing (runtime change
  = own batch + Renode motion re-verify). NEVER-push clause restored in briefs.

- SAMD21 AUTOPSY verdict: 82% of +44% vs f103 = structural Thumb-1 tax (soft-
  float primitives 2-3x wider; M0+ lacks SDIV/CLZ) — honest, not fat. DIVAS
  estimate ~650-700B only (deferred, behavior-change class). newlib-nano = red
  herring (0B text, killed empirically). No cold zones, KEEP() minimal-correct.
  main() 4.7x anomaly (2292B) = LTO inlining divergence, fix candidates known.
  ⚠ SIDE-FINDING ESCALATED: f103 binary shows ZERO traceable callers of
  gc_execute_line (G-code path possibly SEVERED — potential BUG #21 CRITICAL).
  Reachability investigation dispatched — GATES all further stm32 work.
  NOTE: FP knob (in-flight probe) doubles as samd21 size lever: DP-arithmetic
  subset of the tax bucket vanishes under FP=SINGLE + Renode runtime arbiter.

- **BUG #21 CONFIRMED (CRITICAL — biggest catch of the project): all three STM32
  RELEASE binaries ship WITHOUT A VECTOR TABLE** — LTO deletes unreferenced
  vector_table[] before codegen (KEEP() powerless: ltrans never emits the
  section); cascade: no ISRs -> serial RX dead -> LTO const-props empty buffer
  -> gc_execute_line path eliminated; .bin word0 = code bytes, not SP -> CANNOT
  BOOT on hardware. DEBUG (no LTO) innocent-looking — the signature is
  DEBUG-works/RELEASE-bricks. samd21 immune BY ACCIDENT: the VTOR fix (d5a2227)
  created the IR anchor — it unknowingly saved the port. f103's "small" 29900
  was missing 4KB of ISRs; honest size ~33916. Fix dispatched (used-attr +
  VTOR-set all three + post-link BOOT-INTEGRITY check in common.mk/_template
  per ratchet rule) + CONTRACTS §18. Size table to be re-canonicalized after.
  **-> FIXED AND VERIFIED 2026-07-25** (evidence + new size table in Current
  State; CONTRACTS §18 landed; boot_check.sh ratchet landed on all ARM ports +
  _template, RISC-V variant on ch32v006).
- FP twin (samd21) re-dispatched to fresh agent (Renode-agent pool walled to
  20:50; harness is landed in ci/renode — any agent can drive it now).

- ORCHESTRATOR-PURITY CORRECTION 2026-07-24 (owner: "Сам? Ты же оркестратор!!"):
  orchestrator was caught authoring ledger edits/baseline merges/roadmap refreshes
  inline instead of dispatching them as agent batches. Roles tightened in
  Orchestration Protocol: orchestrator = git mechanics + gates + commit/push only,
  ZERO authorship, ever; agents author every byte including their own PLAN.md
  deltas (checkboxes, Current State, Decision Log) inside their batch worktree;
  cross-batch ledger notes go through a scribe agent. Prior "ledger = orchestrator
  bookkeeping" exception REVOKED.

- LIMIT-RECOVERY CORRECTION 2026-07-24 (owner: "Далее не жди пинка. Восстановление
  после лимитов подразумевает восстановление ворктри. Логично??"): recovery from a
  limit/kill = inventory the whole front by FACTS (transcript growth + git status),
  not just the one agent that reported, salvage worktree assets before relaunch, and
  relaunch immediately — never wait for the owner or park it for the cron. Procedure
  codified in Orchestration Protocol.

- LIMIT-RECOVERY CORRECTION 2026-07-25 (near-miss, no data lost): the 2026-07-24
  liveness test itself was wrong — two live agents (downloading an emulator,
  probing builds) were declared dead on transcript/worktree silence alone and a
  `git worktree remove --force` was ordered on both; only git's in-use refusal
  saved them. Liveness now requires a failure notification or hours of silence,
  never minutes. Same incident: `git apply` is atomic (one file's conflict rolls
  back the whole patch, pre-failure "Applied cleanly" lines are misleading) —
  always check `git status` after, use `--3way`, never `head`-truncate its output.

- 2026-07-26 **dsPIC33AK128MC102 CI WIRING** (closes the last "toolchain fetch,
  not the port" item — see rolling-port entry above for the full writeup):
  dedicated `ci.yml` job, not a `build` matrix row (justification in the job's
  own header comment — the shared composite action is apt-only, dsPIC's fetch/
  cache/verify/unattended-install shape doesn't fit it without smuggling that
  ceremony into every future apt-based port's action file). `actions/cache`
  keyed on version+SHA-256 for both the installer and the DFP; SHA-256
  verified with `sha256sum -c` unconditionally (cache hit or miss) before
  either file is touched — a stale/poisoned cache entry fails loudly here
  instead of "installing" quietly. DFP SHA-256
  (811360fb86d92e3d4519dab3948bf895e8468b37ab7203a7d5ca2bfac2b07bbb) is NEW
  this session — the original TOOLCHAIN RECON entry below only ever recorded
  the installer's hash; cross-checked against the CDN's own
  `x-amz-meta-sha256` response header as an independent second source, same
  value both ways. Two real, unrelated bugs found and NOT silently papered
  over: (1) the Makefile's `$(HEX_FILE)` rule omits `-mdfp=` on the
  `bin2hex` call it needs (bin2hex/nm/objdump all hard-require it, unlike
  gcc/ld which get it via `$(ARCHFLAGS)`) — `make all` currently fails at
  the hex step for both flavors; worked around at the workflow level
  (`make link` + a workflow-level `bin2hex -mdfp=` step), NOT by patching
  the Makefile (CI-wiring-only gate) — left as a Makefile follow-up, not
  fixed here; (2) this job's own first-draft shell had
  `elf="...$( [ "$X" = Y ] && echo z )..."`, which silently kills a `run:`
  step under GitHub Actions' default `bash -eo pipefail` whenever the test
  is false — would have broken the RELEASE leg specifically, every time,
  with no useful error. Caught locally before landing (see the executor's
  returned proof log for both bugs' repro) and fixed to plain `if/then`.
  Everything else re-verified for real this session, not re-quoted: fresh
  installer download (SHA-256 match), fresh unattended install to a clean
  prefix (~19-23s, no network), fresh DFP download+unzip, `make BUILD=DEBUG
  link` and `make BUILD=RELEASE link` both succeed (~3-5s each) with zero
  `PORT_TODO_*` (nm-verified both ELFs), warn baseline generated from these
  real logs (same 4-warning core-only class as every sibling port). RELEASE
  size caveat (FreeMode disables `-Os` silently — 20/20 TUs this session)
  carried into the workflow as a `::notice::`, not asserted, matching
  platform.md's existing wording. Gates re-run: golden AVR MD5 PASSED
  (79af184e…), untouched (CI-wiring-only, no port sources touched). ch570:
  confirmed NOT landed on origin this session (`grbl/platform/ch570/`
  absent — checked this branch and `origin/master` via `git ls-tree`); a
  clearly-marked TODO was left in `ci.yml` rather than a guessed row/recipe.

- 2026-07-26 **dsPIC RELEASE-size dispute SETTLED by codegen comparison, not by
  re-reading the compiler's message text**: free-tier `xc-dsc-gcc` v3.30 silently
  substitutes `-O2` codegen for `-O3` and `-Os` (prints "Options have been
  disabled due to restricted license" on every TU at those levels, no message at
  `-O2`). Per-TU probe: `-O0` 1604B, `-O1` 900B, `-O2` 872B (no message), `-O3`
  872B byte-identical disassembly to `-O2` (message printed anyway), `-Os` 876B
  (message printed). Whole-firmware proof: the RELEASE build (`-Os`) and a
  rebuild with an explicit `-O2` produce a BYTE-IDENTICAL 41816 B image, but the
  `-O2` build prints zero restriction messages. Conclusion, settled in both
  directions — the earlier "install-flags caused it" hypothesis is WRONG
  (FreeMode is the installer's own default; `--LicenseType` offers
  `WorkstationMode`/`NetworkMode` too, but both need an account-bound activated
  license file, not a flag, so no install-recipe change would have avoided this),
  and the "so the size is only approximate" conclusion drawn from it was ALSO
  WRONG (41816 B / ~41.8KB RELEASE and 53220 B / ~53.2KB DEBUG are exact and
  reproducible; the free tier just silently gives `-O2`-equivalent codegen
  instead of true `-Os`, per Microchip's own bundled manual — "the basic amount
  of code optimization" on free, "increased levels" on PRO). A 60-day free PRO
  evaluation exists but is account-bound, interactive, time-limited, and NOT
  CI-scriptable — not a path out of this for automated builds, so don't
  re-investigate it. This closes the question: every "approximate"/"caps
  optimization on `-Os`" wording elsewhere in this file, `CHANGELOG.md`,
  `dspic33ak128mc102/platform.md`, its `Makefile`, and `ci.yml`'s `::notice::`
  has been corrected to match.
- 2026-07-26 **dsPIC `make all` HEX-STEP FOLLOW-UP CLOSED, ch570 CI TODO
  STALE-CLEANED**: two items handed down from the dsPIC CI-wiring session
  above.
  (1) **Makefile fix**: `grbl/platform/dspic33ak128mc102/Makefile`'s
  `$(HEX_FILE)` rule now passes `-mdfp=$(DFP_XC16)` to `$(BIN2HEX)`, same
  as every other tool invocation that needs DFP device info. Proved, not
  just compiled: with the real xc-dsc-gcc 8.3.1 + DFP 1.5.263 already
  present in this environment (`/opt/xc-dsc`, `/opt/Microchip.dsPIC33AK-
  MC_DFP.1.5.263` — matches the Makefile's own `TOOLCHAIN_PATH`/`DFP_PATH`
  defaults), `make BUILD=DEBUG all` and `make BUILD=RELEASE all` both now
  complete end to end (previously failed at the hex step for both). Hex
  sanity-checked, not just "exit 0": every record's checksum verified in
  Python (2676 RELEASE / 3396 DEBUG records, zero bad), record-type
  histogram is 00 (data)/01 (EOF, exactly one)/04 (extended linear
  address) only — no junk record types — and the `:04` address bases
  (0x0000/0x0080/0x007F) match the ELF's own section addresses
  (`.reset`/`.text` at 0x800000-region, `.data` at 0x4000-region, config
  fuses at 0x7F3xxx) and the DFP linker script's `program` region
  (origin 0x800004, length 0x1FFFC → end 0x820000 = 128 KB), i.e. the
  hex's extent is the real 128 KB flash window, not an artifact. Zero
  `PORT_TODO_*` both flavors (nm-verified). Also exercised every other
  target while in there: `clean` (removes both flavors' output artifacts +
  the invoked flavor's object dir — same shape as ch32v006's `clean`, not
  a defect), `clean-all`, `link` (both flavors, standalone), `compdb`
  (20 entries, matches 16 grbl-core + 4 platform sources) — none hid the
  same class of missing-flag defect. `ci.yml`'s dsPIC job simplified to
  match: builds `all` directly instead of `link` + a workflow-level
  `bin2hex -mdfp=` workaround step (the workaround's own justifying
  comment is now removed as it no longer applies). Golden AVR MD5 PASSED
  (79af184e…), untouched — only this port's own Makefile and `ci.yml`
  touched, no other port sources.
  (2) **ch570 CI TODO was already stale, not actually missing**: re-checking
  `ci.yml` this session found the `ch570` matrix rows (generic ×
  DEBUG/RELEASE, `gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf` —
  same shape as `ch32v006`'s rows) were in fact already landed in the same
  commit that landed the CH570 port itself (d4c5245), which ran in
  parallel with (and merged before) the dsPIC CI-wiring session above — so
  the "ch570 not landed, TODO left" note in that session's own entry was
  true at the time it was written but stale by the time both branches
  merged. The dangling `# ch570: TODO - not landed...` comment block at
  the bottom of `ci.yml`, contradicting the real rows already present
  above it, is removed. `ci/warn_baseline_ch570.txt` confirmed present and
  re-verified against fresh local build logs for both flavors (`warn_
  ratchet: OK - 4 distinct warning(s), all in baseline` both times — same
  core-file class as ch32v006's baseline, exactly as its own header
  states). Vendor object clean-checkout proof re-run: `git archive HEAD |
  tar -t | grep ISP572.o` finds it; extracting that archive to a directory
  outside the working tree and running `make -C grbl/platform/ch570
  BOARD=generic BUILD=RELEASE` there links clean (`.text`/`.data` 40674/4,
  matching the port's own landing numbers byte-for-byte) — a real,
  isolated fresh-checkout build, not a re-use of the working tree's build
  directory. `ci.yml` parses (`python3 -c "import yaml; ..."` — 3 jobs, 17
  `build`-matrix rows covering exactly the 8 apt-based landed ports +
  ch570, plus the dedicated `build-dspic33ak128mc102` job = every landed
  port; `sg2002` correctly absent, still DESIGN-COMPLETE/IMPLEMENTATION-
  DEFERRED, not a real port). `tools/check_contracts_numbering.py` OK (25
  sections/slugs, 8 cross-file links, all consistent) since `PLAN.md` was
  touched. No port sources touched for this item — `ci.yml` and this file
  only.

## Current State (update each session)

- **[x] BUILD ARTIFACTS TRACKED IN GIT FOR OBSERVABILITY (2026-07-26,
  owner directive)** — new `artifacts/<port>/` tree (RELEASE
  elf/bin/hex + a `nm --print-size --size-sort --demangle` symbol map per
  port) plus `artifacts/MANIFEST.sha256` (sha256 of every artifact of
  every port AND flavor, DEBUG included though DEBUG binaries are never
  committed) so every port's CURRENT byte-level state is diffable over
  time, closing the gap where only atmega328p's golden MD5 had any build
  history and the other 8-9 ports could only be compared now-vs-now.
  Ten units tracked (nine ports; samd21 counted per board -
  `samd21-megarm`/`samd21-generic`, distinct directories since the
  toolchain names both boards' ELF identically): atmega328p, stm32f103,
  stm32h523, stm32f411, samd21×2, ch32v006, ch570, hc32f460,
  dspic33ak128mc102 (xc-dsc toolchain WAS present in this environment, so
  built for real rather than only wiring plumbing). sg2002 correctly
  absent (§23 scope ruling: design-complete/implementation-deferred, no
  binary exists). New sixth ratchet: `tools/build_artifacts.py check`
  rebuilds every port fresh into the ordinary scratch `build/` dir (never
  touching `artifacts/`) and fails, naming every drifted/missing file, if
  a commit landed without refreshing its artifacts - `--selftest` (pure
  manifest-format/hash-compare logic, no compiler) matches the style of
  the other four ratchet scripts. `make artifacts`/`make
  artifacts-check`/`make artifacts-selftest` added to
  `grbl/platform/Makefile` (chosen over per-platform targets or the
  golden-gated AVR root Makefile - see CONTRACTS.md
  [§build-artifacts-tracked](CONTRACTS.md#build-artifacts-tracked) for the
  full "why here" reasoning). `.gitignore` gained THREE more
  negation exceptions for the SAME recurring trap first caught on
  `tools/README.md` and again on `grbl/platform/ch570/vendor/ISP572.o`:
  blanket `*.elf`/`*.hex`/`README.md` rules were silently swallowing
  `artifacts/**/*.elf`, `artifacts/**/*.hex`, and `artifacts/README.md` -
  caught via `git check-ignore -v` BEFORE it could bite a future `git add
  -A`, not after. Growth cost stated plainly (not discovered later as a
  repo-size surprise): ~2.7MB for this one full snapshot, git does not
  delta binaries usefully across recompiles, every subsequent *content*
  refresh costs roughly that much again - full table in
  `artifacts/README.md`.
  **Real bug found and fixed building the tool itself** (kept as a
  documented lesson, not just squashed into a clean commit): the two
  samd21 boards' DEBUG artifacts share one toolchain-chosen path
  (`build/grbl_samd21_dbg.elf` - `BINARY_NAME` doesn't encode `BOARD`),
  so an unnamespaced manifest label let one board's hash silently
  overwrite the other's under one dict key, and `check` false-positived
  on the surviving board. Fixed by namespacing DEBUG labels with each
  unit's `artifact_dir`; regression-guarded in `--selftest`, not just a
  one-off manual repro.
  **A second, independent finding surfaced only by actually running two
  back-to-back builds** (not something the brief anticipated): dsPIC33AK's
  `xc-dsc-gcc` restricted/Free license tier is NOT byte-reproducible -
  measured ~15% of an identical-source RELEASE ELF's bytes differing
  between two consecutive clean builds (almost certainly deliberate
  anti-tamper/watermarking, not a flag or ordering bug here). Its symbol
  map IS stable across the same two builds (diff empty), so this port's
  elf/bin/hex are tracked for archival value but excluded from the
  hash-based staleness gate (`nondeterministic_binary=True` in the
  `UNITS` table), while its `.syms` stays fully gated - documented in
  CONTRACTS.md, `artifacts/README.md`, and inline in the script.
  Refresh policy written where a contributor will see it:
  `PORTING-CHECKLIST.md` gained Definition-of-Done item 8 plus a
  standalone "Refresh policy" section (refresh-and-commit on port
  *content* change, not on every push - most pushes are docs and move
  zero binary bytes); `artifacts/README.md` restates it and cross-links
  back.
  GATES (all re-run, not inspected): golden AVR `make validate` PASSED
  (MD5 `79af184e67b27defd27a39309ac53563`) via the SAME `build_avr_unit()`
  path the tool uses (reuses ratchet #1 as a side effect of `build`/
  `check`, doesn't duplicate it); all 10 units built clean both flavors
  where applicable; `python3 tools/build_artifacts.py check` clean (61
  files verified) after a full rebuild; negative test performed twice
  (before AND after the samd21-label-collision fix) - injected a one-`nop`
  asm mutation into `ch32v006/platform.c`'s delay loop, `check
  --platforms ch32v006` FAILED naming all 7 drifted files (RELEASE
  elf/hex/bin/syms + all 3 DEBUG hashes), reverted, `check` clean again,
  `git diff` on that file empty; `tools/check_contracts_numbering.py` OK
  (26 sections/slugs now, 9 cross-file links, new §25 placeholder -
  slugged `build-artifacts-tracked`, integrator assigns the final number);
  every pre-existing ratchet's own `--selftest` still PASSED
  (`ci/warn_ratchet.py`, `tools/assert_no_double.sh`,
  `tools/check_contracts_numbering.py`) - none of this batch's edits
  touched their logic, only added a sixth alongside them. Also fixed
  along the way (needed for the "hex+bin, not just elf" requirement to be
  achievable at all on this port): `dspic33ak128mc102/Makefile`'s
  `bin2hex` recipe was missing the `-mdfp=` flag it needs on this
  toolchain layout (failed outright, not silently), and had no `.bin`
  target whatsoever - both added (`xc-dsc-objcopy` needs an explicit
  `-I elf32-pic30` since this toolchain's ELF variant isn't one plain
  objcopy autodetects); zero other port's Makefile touched.

- **[x] ELF TRACKED ONLY AT RELEASE TAGS, NOT EVERY REFRESH (2026-07-26,
  owner directive — "Эльф на тегах") — same-day follow-up to the batch
  above.** Reason: measured cost. The batch above's snapshot was 2.6MB
  (2,612,919 bytes, 42 tracked files); a subsequent ordinary artifact
  refresh (the "regenerate against current HEAD" commit) grew the repo's
  `.git` from 12MB to 14MB in one step — git does not delta binaries, so
  every refresh pays close to the full snapshot cost again. `.elf` is the
  largest artifact class (48-166KB/unit) vs. `.bin` (25-95KB), `.hex`
  (72-116KB), `.syms` (a few KB) — routinely 46-58% of a unit's tracked
  bytes. `bin`/`hex`/`syms` stay tracked continuously exactly as before;
  only `.elf`'s cadence changed.
  **`tools/build_artifacts.py`**: default `build` no longer copies `.elf`
  into `artifacts/<port>/` and actively deletes any stale `.elf` left over
  from a prior tag build (so a plain refresh can't leave a mismatched ELF
  sitting next to fresh bin/hex/syms); new `build --with-elf` flag is the
  explicit, tag-time-only mode that does copy+hash it. `check` requires
  `bin`/`hex`/`syms` as before but verifies `.elf` only when present — its
  absence between tags is expected, not a failure. `release_extensions()`
  factored out as the single source of truth for which extensions a build
  copies, covered by `--selftest` (now 26 checks, up from prior count: new
  assertions on `release_extensions(True/False)` and on `build_arg_parser()`
  parsing `--with-elf` and defaulting it to `False`).
  **10 currently-tracked `.elf` files removed** (`git rm`) — one per unit
  (atmega328p, stm32f103, stm32h523, stm32f411, samd21×2, ch32v006, ch570,
  hc32f460, dspic33ak128mc102); `MANIFEST.sha256` regenerated via a full
  `build` (no `--with-elf`) afterward, 30 RELEASE + 24 DEBUG entries, no
  `.elf` lines.
  **`.gitignore`**: the `!artifacts/**/*.elf` negation exception added by
  the prior batch is REMOVED — deliberately, not an oversight. That prior
  batch needed the negation because ELF was tracked continuously and a
  blanket ignore would have silently dropped it from `git add -A` (the
  same trap already hit twice before, on `tools/README.md` and
  `ch570/vendor/ISP572.o`). This batch reverses the policy, so the
  negation is now the wrong tool — leaving `.elf` under `artifacts/`
  covered by the pre-existing blanket `*.elf` rule is what makes it
  "ignorable by default" again. The corresponding risk (`git add -A`
  silently skipping an ignored file — same trap, opposite direction) is
  closed by the tag-time procedure never using `-A`: `git add -f
  artifacts/*/*.elf` by explicit path either succeeds or fails loudly,
  never silently. `!artifacts/**/*.hex` and `!artifacts/README.md` are
  untouched. Proven with `git check-ignore -v
  artifacts/<port>/grbl_<port>.elf` in both states: reports the blanket
  `*.elf` rule as the match regardless of whether the file is currently
  committed (default/between-tags state); `git add -f` on the same path
  succeeds once `build --with-elf` has produced it (tag-time state).
  **Docs**: `artifacts/README.md` (file-table annotated per-extension with
  refresh cadence, new "Tagging a release" section with the exact
  `--with-elf` + `git add -f` command, Growth cost table gained a
  "tracked" column and before/after numbers), CONTRACTS.md
  [§build-artifacts-tracked](CONTRACTS.md#build-artifacts-tracked) (new
  subsection spelling out the mechanism/`.gitignore` reasoning/numbers,
  dsPIC33AK subsection corrected — it no longer says elf/hex/bin are
  "still committed" continuously), `PORTING-CHECKLIST.md` (Definition-of-
  Done item 8 now says bin/hex/syms only; new "ELF is tag-time only, not
  part of this cadence" subsection under Refresh policy), and this entry.
  **Numbers after this change**: `artifacts/` dropped from 2,612,919 bytes
  / 42 tracked files to **1,389,988 bytes / 32 tracked files** (~47%
  smaller; 10 files / 1,221,872 bytes removed). Every subsequent full
  10-unit refresh now costs **at most ~1.37MB** (worst case, all units
  touched) instead of ~2.6-2.7MB; a partial refresh (the common case) is
  proportionally cheaper since `.elf` was the majority of most units'
  tracked bytes.
  **GATES** (all re-run, not inspected): golden AVR `make validate` PASSED
  (MD5 `79af184e67b27defd27a39309ac53563`, unchanged from the batch above);
  all 10 units rebuilt clean via a full `build` (no `--with-elf`) after the
  `git rm`, confirming `bin`/`hex`/`syms`/`MANIFEST.sha256` describe HEAD
  with `.elf` correctly absent; `python3 tools/build_artifacts.py check`
  clean (52 files verified across 10 units, `.elf` absence caused no
  failure); `python3 tools/build_artifacts.py --selftest` PASS (26 checks);
  `python3 tools/check_contracts_numbering.py` OK (26 sections/slugs, 10
  cross-file links, unchanged count — no new section added, only prose
  inside the existing §25).

- **[x] RELEASE-READINESS TRUTH AUDIT (2026-07-26)** — Phase 5's last item prep (tag v0.x).
  Fresh clean builds of every buildable port re-verified against this file's own canonical size
  table: all match exactly (atmega328p golden MD5 unchanged; stm32f103/h523/f411, samd21
  megarm+generic, ch32v006, hc32f460 all byte-identical to the table; dspic33ak128mc102 builds
  DEBUG+RELEASE with zero PORT_TODO_* using the real xc-dsc-gcc 8.3.1 + DFP 1.5.263 already
  present in this environment — NEW FINDING (later SETTLED, see the dsPIC size note below): its
  RELEASE (`-Os`) compile prints "Options have been disabled due to restricted license" from the
  free-tier compiler on every TU, but the resulting RELEASE size is exact and reproducible, not
  approximate — the free tier silently substitutes `-O2` codegen for `-O3`/`-Os` rather than
  producing a fuzzy result; a rebuild with an explicit `-O2` in place of `-Os` is byte-identical to
  the `-Os` RELEASE image). Provenance thesis independently
  re-verified from a fresh live clone of `gnea/grbl` v1.1h.20190825 (not reused from a prior
  claim): `.text` differs by exactly 2 bytes, the `GRBL_VERSION_BUILD` date string. CI matrix
  (15 rows) and all three workflow YAMLs re-checked (valid YAML; matrix covers exactly
  atmega328p/stm32f103/h523/f411/samd21×2boards/ch32v006/hc32f460, no dspic/ch570/_template rows,
  matching intent). **CI-status finding, corrects a stale claim in this file**: GitHub Actions IS
  running on this fork — `github.com/kimstik/grbl/actions` shows 78 CI + 67 Smoke runs on this
  branch, one per push (run #78 = this tree's HEAD commit), not "no runs yet / possibly disabled"
  as this file previously recorded (Phase 0 exit criterion corrected above; that entry now also
  carries the single-source/403-API provenance caveat for this exact run count — see there,
  Phase 0). Docs truth-audited
  and corrected: README.md's platform matrix (was 2 platforms "green," rest "in repair" — now a
  full 8-platform table with honest proof-level column); PLATFORM_ROADMAP.md (was badly stale —
  stm32f103/h523 still described as build-broken, ch32v006 as "not a real port, no Makefile",
  dsPIC as "M1-M3 only" — all corrected to current reality, this file's own long-open "Truth-update
  PLATFORM_ROADMAP.md" checkbox is now closed); ARCHITECTURE.md (directory structure/memory
  usage/future-platforms sections dated from the single-platform 2025-11-18 design, corrected;
  Build Prelude section was already current); PORTING-CHECKLIST.md (`_template` mislabeled
  "planned"); per-port `platform.md`/`README.md` for stm32f103 (was "Production Ready 100%"),
  stm32h523 (was "Ready for Hardware Testing"), stm32f411 (stale pre-optimization sizes), samd21
  (was severely UNDERSTATED — "WIP ~40%" when it's actually the most-verified port in the tree),
  dspic33ak128mc102 (added the restricted-license caveat above), samd21/SAMD21_PLAN.md (stale WIP
  header). hc32f460/platform.md, sg2002/README.md, `_template`/README.md were already accurate,
  verified not edited. A `CHANGELOG.md` release-notes draft was authored at repo root covering
  the thesis, the 8-platform matrix, proof levels (samd21 = Renode-proven, everyone else =
  build/link/contract-proven only, NOBODY hardware-validated), the 21 numbered bugs (#17 phantom
  motion, #21 vanished vector table called out), the contributor machinery (CONTRACTS.md 24
  sections, PORTING-CHECKLIST, `_template`, 5 ratchets), and honest limitations — not tagged,
  tagging is an owner action. **Golden AVR MD5 unchanged throughout** (`79af184e67b27defd27a39309ac53563`,
  re-verified after every doc batch); `tools/check_contracts_numbering.py` still OK (24
  sections/slugs, 8 cross-file links). No core `grbl/*.c`/`*.h` file touched — this was a
  docs-and-release-notes batch only.

- **[x] PHASE 1/2 CLOSURE BATCH (2026-07-26)** — closed the 4 remaining Phase 1
  checkboxes + the Phase 2 `_Static_assert` sweep. Verdict per item: (1)
  dual-canon resolve = STALE, already fixed in Phase 1 (22aa27c) — verified
  by fresh build + baseline grep across all 7 ports, zero hits; (2)
  loud-failure guard = ALREADY LANDED, proven live this session (dropped
  stm32f103's `-include prelude.h`, reproduced the `#error`, restored,
  rebuilt clean); (3) prelude rollout = ALREADY DONE on all non-AVR ports
  (verified: exactly one `-include .../prelude.h` per Makefile, no
  stragglers), atmega328p DECIDED EXEMPT (Decision Log); ARCHITECTURE.md's
  stale port list corrected. (4) naming migration = HAL_GPIO_IRQ_HANDLER
  confirmed canon (matches CONTRACTS.md #2 and every port); two dead "short
  name" alias sets removed (`GPIO_ISR` in hal_gpio.h, `GPIO_INT_ENA`/
  `GPIO_INT_DIS`/`IRQ_HANDLER` in atmega328p/platform.h) — zero call sites
  for either, ever, confirmed by grep across core + all 7 ports. (5) static
  assert sweep: 4 new contract classes codified (SPINDLE_PWM_MAX_VALUE<=255
  duty-cap-twins on 6 ports, samd21 deliberately excluded with a documented
  reason; NVMEM window<=cache on the one stm32 sibling missing it; STEP/DIR
  logical bits<=7 on all 7 non-AVR ports; RX/TX buffer size vs uint8_t index
  on the 3 TU-replacement serial.c files) — all one-liners at the point each
  contract's inputs are known.
  GATES (all re-run this session, not inspected): AVR golden `make -C
  grbl/platform/atmega328p validate` PASSED (MD5
  `79af184e67b27defd27a39309ac53563`, unchanged) after every edit batch;
  all 7 ports rebuilt both flavors where applicable (atmega328p single-flavor;
  stm32f103/h523/f411 D+R; samd21 megarm+generic D+R; ch32v006 D+R;
  dspic33ak128mc102 D+R via the real `/opt/xc-dsc` toolchain) — 0 failures;
  every `ci/warn_baseline_*.txt` ratchet re-run against the fresh logs — 0
  new warnings anywhere; sizes byte-identical to the CANONICAL RELEASE SIZE
  TABLE (f103 28700/80, h523 25132/388, f411 25796/80, ch32v006 41072/0,
  samd21 megarm 31952/296) — the `_Static_assert`/doc-only edits added zero
  bytes, as expected. Touched files: `grbl/platform/hal_gpio.h`,
  `grbl/platform/atmega328p/platform.h` (macro removal only, golden-safe —
  re-validated), `grbl/platform/ARCHITECTURE.md`, `grbl/platform/stm32f103/
  {platform.c,platform.h}`, `grbl/platform/stm32h523/platform.h`,
  `grbl/platform/stm32f411/platform.h`, `grbl/platform/ch32v006/boards/
  generic/config.h`, `grbl/platform/dspic33ak128mc102/boards/generic/
  config.h`, `grbl/platform/_template/boards/generic/config.h`,
  `grbl/platform/samd21/{megarm,generic}/config.h`, `grbl/platform/{samd21,
  ch32v006,dspic33ak128mc102}/serial.c`, this file, and CONTRACTS.md (no
  core `grbl/*.c`/`grbl/*.h` file touched). Not closed (out of scope for
  this batch, left for their own owners): PLATFORM_ROADMAP.md truth-update
  (Phase 1's 5th checkbox — a docs-only item unrelated to the 4 requested);
  samd21's actual SPINDLE_PWM_MAX_VALUE=65535 bug (CONTRACTS.md #6.2 —
  needs its own Renode-verified fix, not a config edit riding along with an
  unrelated contracts sweep).

- **[x] GUARD HARDENING (2026-07-26) — adversarial review of §17/§18's guards
  found both weaker than they looked, with WORKING exploits. All four
  findings fixed; see CONTRACTS.md §19 for the two lessons in full.**
  1. **`assert_no_double.sh` was blind on every target this project ships.**
     Its denylist matched only generic libgcc names (`__adddf3`...); ARM's
     libgcc renames DP soft-float ops to `__aeabi_*` (AAPCS), which the
     script never checked. Demonstrated: a hand-built object doing plain
     `double` arithmetic links `__aeabi_dadd/dsub/dmul/ddiv`, zero generic
     names, and the old script printed `PASSED: no DP machinery`, exit 0.
     Fixed: denylist now covers both families plus `__muldc3`/`__divdc3`
     (complex double) and `__floatdidf`; only `__aeabi_d2f` stays tolerated
     (verified via `nm` on the landed samd21 ELF — it is still the only
     conversion present, at the `_delay_ms(double)` boundary). Added
     `--selftest` (8 checks, `ci/warn_ratchet.py`-style: positive + negative
     + end-to-end through a fake `nm`) — `PASS (8 checks)`. Re-run on real
     builds: samd21 FP=SINGLE RELEASE still `31952/296/6160`, assert PASSES
     honestly (confirmed via `nm`, only `__aeabi_d2f`); an FP=DOUBLE build
     (43020 text, real double arithmetic pulled in by dropping the SP pins)
     correctly FAILS, listing both `__aeabi_dcmp*`/`__aeabi_cdcmp*` and
     generic `__gedf2`/`__ltdf2`-family offenders together.
  2. **No `.DELETE_ON_ERROR:` anywhere** — a failed recipe left its
     half-built target on disk with a fresh mtime, so the next `make` saw
     it as up to date and skipped the recipe (and the guard inside it).
     Demonstrated live on samd21: injected genuine `volatile double`
     arithmetic into `platform.c` (untouched by `-fsingle-precision-constant`,
     which only pins unsuffixed *constants*), built without the fix — first
     `make` correctly FAILED (assert caught it) but left the poisoned ELF on
     disk; second `make` exited 0, ran `objcopy`/hex/bin/dump straight off
     the stale poisoned ELF, no relink, no re-assert. Fixed: `.DELETE_ON_ERROR:`
     added (one line each, near the top) to `common/stm32/common.mk`,
     `samd21/Makefile`, `ch32v006/Makefile`, `_template/Makefile`,
     `dspic33ak128mc102/Makefile`, `sg2002/Makefile`. Re-ran the same repro
     with the fix in place: first `make` fails and GNU Make prints
     `Deleting file '.../grbl_samd21.elf'` (confirmed gone via `ls`); second
     `make` reruns the full chain and fails again, honestly — no stale
     artifact served either time. Exploit repro code (the injected
     `dp_leak_*` symbols in `platform.c`) was reverted after verification;
     `platform.c` diffs clean against HEAD.
  3. **BUG #21 "both mechanisms load-bearing" wording was not empirically
     true.** Re-tested on stm32f103 (GCC 13.2.1, `-Os -flto`): disabling the
     `used` attribute while keeping the VTOR write still passes
     `boot_check.sh`; disabling the VTOR write while keeping `used` also
     passes. Either alone suffices on this toolchain. CONTRACTS.md §18 and
     the three STM32 `startup.c` comments reworded to "two independently-
     sufficient, defense-in-depth mechanisms" (kept for cross-compiler/
     cross-opt-level robustness) rather than "both required"; the
     post-link BOOT INTEGRITY check remains the one truly mandatory layer.
  4. **Vector-count comments were off by one.** Real `vector_table[]` sizes,
     counted from the actual arrays: f103/f411 59 entries / 236 B (not 60 /
     240), h523 77 entries / 308 B (not 78 / 312) — PLAN.md's own BUG #21
     entry below already had h523 right (77/308B) but the three `script.ld`
     files and CONTRACTS.md ~line 1045 said 60/240 and 78/312. Corrected in
     all three `script.ld` files + CONTRACTS.md; `ALIGN(256/256/512)` values
     themselves were already correct (next-power-of-two headroom absorbs
     the off-by-one either way) and were left untouched.
  GATES after all four fixes: AVR golden `make -C grbl/platform/atmega328p
  validate` PASSED (MD5 79af184e67b27defd27a39309ac53563, unchanged);
  samd21 RELEASE still `31952/296/6160`, assert PASSING, DEBUG also PASSING;
  all three STM32 (f103/f411/h523) RELEASE build clean with
  `BOOT INTEGRITY: OK`. Concurrency note: another agent was adding the FP
  knob to ch32v006/stm32f103/stm32f411/stm32h523 Makefiles at the same
  time — the `.DELETE_ON_ERROR:` insertions were kept to one line each,
  placed away from the CFLAGS/FP region, to keep any 3-way merge trivial.
- **[x] dsPIC33AK128MC102 Steps 3-6 COMPLETE (2026-07-26)** — Phase 6
  rolling #2 finished. Real toolchain (xc-dsc-gcc 8.3.1) + real DFP
  (1.5.263), both already installed at `/opt` from the M1-M3 session, used
  end to end. `make BUILD=DEBUG` and `make BUILD=RELEASE` both build the
  full ELF+hex and link with zero `PORT_TODO_*` (`nm | grep PORT_TODO`
  empty both flavors — confirmed by grep, not inspection). T1 stepper
  timer, SCCP1 pulse-reset (a genuinely new 8-bit-overflow-horizon shape:
  software x8 rescale on a real period-compare register instead of
  fighting a non-/8 hardware prescaler), SCCP2 spindle PWM, a freshly-
  mined UART1 register model (no donor port — first UART for this ISA),
  and flash-based NVMEM via ROW PROGRAM into a linker-reserved fixed-
  address window (`__attribute__((address(0x81F800)))`, link-tested
  clean against the *unmodified* vendor `.gld` — no port-authored linker
  script needed). FP knob wired `FP ?= DOUBLE` as this port's own default
  (native DP FPU — CONTRACTS §17 item 7, the chip §17.3 was written for),
  `assert_no_double.sh` disarmed, `FP=SINGLE` still available via the
  same shim pattern as samd21 (bidirectional knob, unexercised this
  session). Sizes: RELEASE ~41.8KB / DEBUG ~53.2KB code (128KB flash
  budget), RAM ~3.8KB RELEASE (16KB budget). CONTRACTS.md §16 grew 11→20
  items — two verification classes stand out: (a) NVM controller facts
  are MOSTLY atdf-verified (a rare case where the vendored pack answers
  the question, unlike almost everything else in this port), (b) PPS
  input muxing is fully verified (field = literal RPn number) while PPS
  OUTPUT muxing has zero value-groups anywhere in the DFP (genuinely
  RM-only, best-effort placeholder codes used, loudly flagged). Gates
  RE-RUN this session (not just inspected): golden AVR MD5 PASSED
  (`79af184e67b27defd27a39309ac53563`, text 30640, `AVR_GCC_PATH=/usr`
  override needed — no toolchain at the Makefile's default `$(HOME)/
  avr-toolchain` path in this environment); samd21 megarm RELEASE
  31952/296 (exact match, `TOOLCHAIN_PATH=/usr/bin`); stm32f411 RELEASE
  25796/80, boot-integrity OK; ch32v006 generic RELEASE 41072/0,
  boot-integrity OK (all three needed the same `TOOLCHAIN_PATH=/usr/bin`
  override — no code regressions, dsPIC work touched only its own
  directory + CONTRACTS.md + this file). f411/ch32v006 figures
  re-verified at integration against current HEAD — this batch's
  authoring worktree branched before the FP=SINGLE rollout landed on
  those two ports, so the numbers first drafted here (32660/80 f411,
  54904/0 ch32v006) were pre-rollout; the CANONICAL RELEASE SIZE TABLE
  below is the authority these were checked against. Still NOT in CI
  (unattended XC-DSC fetch remains a separate ledger item).

- **[x] BUG #21 FIXED (2026-07-25) — vector table restored on all three STM32
  ports.** Mechanism re-verified before fixing, not taken on faith: baseline
  f103 RELEASE `.bin` word0 = `0x785a4b08` (code bytes, not an SP), `.isr_vector`
  ABSENT from `objdump -h` entirely, `nm | grep -c Handler` = **1**, no
  `serial_rx_buffer_head` symbol at all, exactly **1** `bl` site to
  `gc_execute_line` (the G-code dispatch path from `protocol.c` was gone).
  f411/h523 identical (`0x785a4b08` / `0x785a4b07`, 1 handler each).
  Fix, all three `startup.c`: `SCB->VTOR = (uint32_t)vector_table;` as the first
  statement of `Reset_Handler` (the real code reference LTO's IPA cannot ignore
  — this is exactly what made samd21 immune by accident via d5a2227) PLUS
  `__attribute__((used))` on the table. Minimal 3-register `SCB` typedef added
  to each `regs.h` (none of the three had one; reuse-before-write found nothing
  to reuse). `script.ld`: `. = ALIGN(256)` f103/f411, `ALIGN(512)` h523, before
  `KEEP(*(.isr_vector))`, each with a matching alignment `ASSERT`.
  After: word0/word1 = `20001458 0800461d` (f103), `20001c60 080045f5` (f411),
  `20008000 080046a5` (h523); handler counts 1 -> **51 / 45 / 68**;
  `serial_rx_buffer`, `_head` and `_tail` all present in BSS; 4 `bl` sites to
  `gc_execute_line` on each; `vector_table` at `0x08000000` on all three
  (h523 `.isr_vector` = 0x134 = 308 B = 77 entries, in FLASH).
- **RATCHET shipped with the fix**: new `grbl/platform/common/boot_check.sh`
  runs after every `objcopy` and fails the build unless `.bin` word0 is a
  plausible initial SP (`0x2xxxxxxx`, aligned) and word1 a Thumb reset vector
  inside the image's flash window. Wired into `common/stm32/common.mk` (all
  three STM32 ports inherit), `samd21/Makefile` (passes immediately, as
  predicted) and `_template/Makefile` (future ports inherit the guard, with a
  PORT-TODO telling non-ARM ports to translate it, not delete it). ch32v006
  gets the RISC-V-appropriate form — asserts `_start` links at the flash base —
  with a Makefile comment on why the word0 convention is N/A there.
  NEGATIVE TEST RUN: f103 fix reverted -> `BOOT INTEGRITY: FAIL` printing
  `word0 = 0x785a4b08`, make exit 2; fix restored -> OK.
  ⚠ FINDING WORTH KEEPING: the linker `ASSERT` is NOT a second line of defence.
  With the fix reverted, `ld` resolved the undefined `vector_table` to 0 and
  `(0 & 0xFF) == 0` PASSED. The ASSERT guards alignment only; the post-link
  check is the sole thing that catches a vanished table. Comments in all three
  `script.ld` files corrected to say so.
- **SIZE TABLE MUST BE RE-CANONICALIZED** (superseded — see the CANONICAL
  RELEASE SIZE TABLE further below, re-measured 2026-07-26 post-FP=SINGLE;
  numbers here are the BUG#21-fix snapshot, kept as evidence, not current) —
  the old STM32 numbers were measuring
  binaries with the ISRs and G-code path missing. New honest RELEASE flash body
  (text+data), owner-facing metric per the 2026-07-24 reporting doctrine:

  | port      | old (dishonest) | new (honest) | delta |
  |-----------|-----------------|--------------|-------|
  | h523      | 28692           | **32836**    | +4144 |
  | f411      | 28724           | **32740**    | +4016 |
  | f103      | 29980           | **34004**    | +4024 |
  | AVR       | 30640 (golden)  | 30640        | 0     |
  | samd21    | 43332           | 43332        | 0     |
  | ch32v006  | 55560           | 54904        | -656  |

  The +4K on each STM32 is the vector table plus ~40-70 ISRs plus the serial RX
  path plus the G-code dispatch path — i.e. the firmware that was supposed to be
  there all along. f103 is no longer the "compact" port; it never was.
  samd21 and AVR are byte-identical (gate). ch32v006's -656 is NOT from this
  batch (Makefile-only change here, post-objcopy): 55560 predates the ch32
  `--gc-sections` diet that has since landed — re-measured at HEAD for accuracy.
  DEBUG sizes moved +16 bytes on each STM32 (48836->48852 f103, 48472->48488
  f411, 48644->48660 h523) — that is the single VTOR store, nothing else.
- **CANONICAL RELEASE SIZE TABLE, re-measured 2026-07-26 after the FP=SINGLE
  rollout to every remaining port** (ch32v006, stm32f103, stm32h523, stm32f411 —
  samd21 already carried the knob; see the 2026-07-25 entry above). All numbers
  are `text`/`data` from `arm-none-eabi-size`/`riscv64-unknown-elf-size
  --format=berkeley` on a clean `make BUILD=RELEASE` (default board where
  applicable), `tools/assert_no_double.sh` armed and PASSING on every row
  except AVR (mechanism is a no-op there, no prelude injected):

  | port      | pre-FP=SINGLE text/data | post-FP=SINGLE text/data | Δtext  | Δ%     |
  |-----------|-------------------------|--------------------------|--------|--------|
  | AVR (golden) | 30640 / 0            | 30640 / 0 (untouched)    | 0      | 0%     |
  | samd21    | 31952 / 296 (already landed) | 31952 / 296 (unchanged, sibling check) | 0 | 0% |
  | ch32v006  | 54904 / 0               | **41072** / 0            | -13832 | -25.2% |
  | stm32f103 | 33924 / 80              | **28700** / 80           | -5224  | -15.4% |
  | stm32h523 | 32448 / 388             | **25132** / 388          | -7316  | -22.5% |
  | stm32f411 | 32660 / 80              | **25796** / 80           | -6864  | -21.0% |
  | dspic33ak128mc102 | N/A — FP=DOUBLE is this port's declared default (native DP FPU), never carried the SINGLE rollout | 41816 B (~41.8KB), exact — `-O2`-equivalent codegen, not true `-Os` (free-tier xc-dsc-gcc substitution, see dsPIC size note) | — | — |
  | hc32f460  | N/A (new port, rolling #3, `FP=SINGLE` from day one) | **25596** / 80 | N/A | N/A |
  | ch570     | N/A (new port, rolling #4, `FP=SINGLE` from day one) | **40674** / 4  | N/A | N/A |

  RULE: any sibling size quoted in a ledger entry must be re-verified against
  this table at integration time, not copied from the entry's own drafting —
  agent worktrees branch from whatever HEAD existed when they started, and
  sibling ports keep moving underneath them (see the dsPIC entry above for
  the failure mode this guards against).

  DEBUG sizes (all assert-PASSING, all boot-integrity-PASSING): ch32v006 60648
  -> 46988; stm32f103 48852 -> 43120; stm32h523 48660 -> 41508; stm32f411
  48488 -> 41644.
  ch32v006 was the ORIGINAL PROBE CHIP (-13712 bytes measured there first) whose
  knob never landed because the probe lived in a throwaway worktree — this batch
  re-applies it for real, from the landed samd21 pattern, faithfully (Makefile
  `FP ?= SINGLE` block, `boards/generic/prelude.h` SP libm shim,
  `assert_no_double.sh` wired post-link).
  stm32f103/h523/f411 share one `common/stm32/common.mk` — the knob, the assert
  hookup, and the help text were added THERE ONCE, not duplicated three times;
  each port's own `prelude.h` (no `boards/` subdir on any of the three — one
  prelude per port) got its own copy of the SP libm call-site shim, because
  CONTRACTS.md #17 requires the shim live in every board/prelude that could be
  selected, not a shared header the Makefile might bypass.
  SAME TRAP HIT AGAIN, SAME FIX: ch32v006's `_delay_ms()` had the identical
  samd21-class leak — sub-ms remainder computed in `double`
  (`__ms - (double)ms`, `rem * 1000.0`) behind an already-"narrowed" entry
  point. Fixed with the same `delay_us_f()` float-worker pattern (one
  `(float)` narrowing at each public entry, arithmetic never widens back).
  The three STM32 ports did NOT have this leak: their `_delay_ms(double ms)`
  was already a bare `(uint32_t)ms` truncation with no remainder arithmetic at
  all, so `assert_no_double.sh` PASSED on the very first build for all three —
  no platform.c changes needed there, checked and confirmed empirically (not
  assumed).
  **stm32f411 FPU FINDING (the interesting case, Cortex-M4F with a real
  fpv4-sp-d16 single-precision FPU):** disassembly of the RELEASE ELF before
  vs. after — before: `sqrt()` resolved to `__ieee754_sqrt` (software DP),
  287 `bl __aeabi_d*` soft-float call sites, 0 `vsqrt.f32`, 42 `vmul.f32`/22
  `vadd.f32` (from code that was already float-typed); after: `sqrtf()`
  compiles to ONE instruction, `vsqrt.f32 s0,s0` (verified in the .dump), 82
  `vmul.f32` (+40) and 161 combined `vadd/vsub/vdiv.f32` (+139), and **0**
  `bl __aeabi_d*`/`bl sqrt` sites — the entire soft-float call population
  moved onto real FPU instructions. This is a genuine SIZE+SPEED win, not
  just size: the FPU was already present and paid for, it was simply being
  starved by DP promotion. stm32h523 (Cortex-M33, fpv5-sp-d16, also
  SP-only) gets the identical class of win; not separately disassembled this
  batch but the size delta (-22.5%) is consistent with the same mechanism.
  Full build sweep after the rollout: golden AVR MD5 `79af184e67b27defd27a39309ac53563`
  unchanged; samd21 (both boards, both flavors) unchanged at 31952/296; all
  four converted ports build both DEBUG and RELEASE, assert PASSES on all 8
  images, STM32 boot-integrity check (BUG #21 ratchet) PASSES on all 6 STM32
  images, ch32v006's RISC-V `_start`-at-flash-base check PASSES on both.
- BUG #21 gates: AVR golden `make -C grbl/platform/atmega328p validate` PASSED
  (MD5 79af184e67b27defd27a39309ac53563). Warning ratchet clean on all of
  stm32f103 (21 warns) / stm32f411 (14) / stm32h523 (18) / samd21 (0) — no new
  entries against any `ci/warn_baseline_*`. CONTRACTS.md §18 authored.

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
- In-flight agents (BUG#21 stm32 vector fix, samd21 FP twin arbiter) were briefed
  before the 2026-07-24 orchestrator-purity correction — their PLAN.md deltas will
  be authored by follow-up/scribe until new briefs embed the rule.
- **2026-07-25 — samd21 FP=SINGLE knob applied AND runtime-arbitrated. Verdict:
  SP-RUNTIME-PROVEN.** (agent-authored entry, per orchestrator-purity doctrine)
  - Applied faithfully from the ch32v006 reference (89aa691): `FP ?= SINGLE`
    Makefile knob (SINGLE|DOUBLE, applied to BOTH build flavors), the SP libm
    prelude shim in **both** boards' preludes (`megarm/`, `generic/` — boards
    are selected by which prelude is injected, so one-board-only would silently
    opt the other out), and `tools/assert_no_double.sh` wired as a post-link
    step on `$(ELF_FILE)`.
  - **NEW CANONICAL RELEASE SIZE: 31952 text** (was 43036) — **−11084 bytes,
    −25.8%**, 296 data / 6160 bss unchanged. 43 defined DP symbols vanished
    (`__aeabi_dadd/dsub/dmul/ddiv`, the `__aeabi_dcmp*`/`__*df2` compare set,
    `__ieee754_atan2/sqrt/rem_pio2`, `__kernel_sin/cos/rem_pio2`, `atan`,
    `sin`, `cos`, `sqrt`, `floor`, `ceil`, `round`, `lround`, `trunc`, `fabs`,
    `scalbn`, …). Exactly ONE tolerated conversion symbol remains in the whole
    image: `__aeabi_d2f`. DEBUG (megarm): 48112 text. `FP=DOUBLE` still builds
    (43020 text) with the assert disarmed, and the assert run by hand against
    that ELF correctly lists 21 offenders and exits 1 — both directions proven.
  - **The assert caught a real leak the ch32 experience predicted.** Flags +
    shim alone landed at 35892 text with the assert RED: `_delay_ms()`'s
    sub-millisecond remainder (`__ms - (double)ms`, `rem > 0.0`,
    `rem * 1000.0`) was still genuine DP **arithmetic** sitting behind a
    boundary that already "narrowed at entry" (dd5c5e7). Narrowing at entry is
    necessary, not sufficient. Fix (platform.c): float worker `delay_us_f()`;
    `_delay_us`/`_delay_ms` narrow exactly once via `__aeabi_d2f` and stay in
    float/uint32 forever. That recovered the remaining 3940 bytes.
  - **RUNTIME ARBITRATION (the point of the batch).** Renode 1.16.1 portable,
    `ci/renode/smoke.sh` reused as-is and extended with a new arc stage
    (`--arc` / `SMOKE_ARC=1` in smoke.sh; `arc_stage()` in `uart_probe.py`,
    new exit code 5). On the FP=SINGLE megarm DEBUG image: banner + `$$`
    (through `$132=`) + `G91`/`G0 X1` (MPos 0→1.000, Idle) + **`G2 X2 I1 F200`
    — the only core path touching atan2/sqrt/cos/sin — traced a true
    semicircle: Y peaked at exactly 1.000 (radius 1.000), no NaN/inf, no
    error:/ALARM:, landed on (3.000, 0.000, 0.000) Idle with zero drift** +
    `G4 P0.5` float-seconds dwell `ok` in 0.44 s + X STEP (PA25) driven high
    410 times. Exit 0. Reproduced; arc/dwell also green on a BOARD=generic
    image.
  - CONTRACTS §17 authored here and marked **RUNTIME-PROVEN** (was
    PROBE-VERIFIED-COMPILE-ONLY on the ch32 branch) — the compile-only embargo
    on other ports shipping `FP=SINGLE` pins is lifted, with
    `assert_no_double.sh` PASSING as the bar.
  - Gates: AVR golden `make -C grbl/platform/atmega328p validate` **PASSED**
    (text 30640, MD5 79af184e67b27defd27a39309ac53563); warn ratchet vs
    `ci/warn_baseline_samd21.txt` **OK** across all 4 megarm/generic ×
    DEBUG/RELEASE combos (5 distinct warnings, all baselined, 0 new); sibling
    platforms untouched (diff is samd21/, ci/renode/, tools/ only).
  - Watch-out recorded for future smoke runs: sweeping `BOARD=generic` builds
    overwrite `build/grbl_samd21_dbg.elf`, and the PA25 STEP assertion is
    megarm-specific — always rebuild megarm DEBUG immediately before the smoke
    or the pin check reads as a false phantom-motion FAIL.

- **2026-07-26 — BUG #22 FIXED: samd21 duty-cap-twins closure — LAST tracked
  `SPINDLE_PWM_MAX_VALUE<=255` exception removed, class now closed on every
  port.** (agent-authored entry) Follow-up to the `_Static_assert` sweep
  above, which deliberately left samd21 (megarm+generic) excluded because it
  was declaring `SPINDLE_PWM_MAX_VALUE 65535` — a live, tracked violation, not
  a stale doc.
  **RECLASSIFIED 2026-07-26 (adversarial review): this commit's own "post-fix
  disassembly is byte-identical" / "behaviour-preserving by construction"
  claims below are FALSE for the build as a whole and are corrected in place
  rather than left standing — see the new bullet after "Fix" for the actual
  functional bug (BUG #22) this commit silently repaired.**
  - **Truth established before touching anything** (per the brief — do not
    assume the accident, verify it): rebuilt samd21/megarm DEBUG and captured
    the exact compiler diagnostic: `megarm/config.h:188:32: warning: unsigned
    conversion from 'int' to 'uint8_t' changes value from '65535' to '255'
    [-Woverflow]`, attributed to `spindle_compute_pwm_value` in
    spindle_control.c (GCC points macro-expansion diagnostics at the macro's
    definition site, not the use site — this is why the warning reads
    "config.h" not "spindle_control.c"). Disassembled
    `build/samd21/DEBUG/spindle_control.o`: the assignment compiles straight
    to `movs r2, #255` / `strb r2, [r3, #0]` — the compiler folds 65535 into
    255 at compile time and the byte store proves core's duty really is
    `uint8_t`. `samd21/timer.h:109` confirms `TCC0->PER = 0xFF` (255) is the
    hardware's actual full scale. All three legs of the bug (65535 declared,
    255 truncated by construction, PER=255 the real ceiling) confirmed by
    instrument, not assumption.
  - **Fix**: `SPINDLE_PWM_MAX_VALUE` changed from `65535` to `255` in both
    `samd21/megarm/config.h` and `samd21/generic/config.h` — full scale now
    equals `PER` exactly, correct by construction instead of by accidental
    truncation. Added the same `_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
    ...)` wording the other 6 ports already carry (CONTRACTS.md #6.2,
    duty-cap-twins class) to both files. Post-fix disassembly of
    `spindle_compute_pwm_value()` alone is byte-identical (`movs r2, #255`
    still there) for its one `uint8_t` assignment site — **but that is not
    the whole picture** (see BUG #22 below): the disassembly check at
    landing time covered only that one function.
  - **BUG #22 (CORRECTION, adversarial review, 2026-07-26): this was a real
    spindle-output bug, not a no-op.** `SPINDLE_PWM_RANGE` (`=MAX-MIN`) has a
    SECOND use site the original disassembly check missed:
    `spindle_control.c:45`, `pwm_gradient = SPINDLE_PWM_RANGE/(settings.
    rpm_max-settings.rpm_min)`, inside `spindle_init()`. That expression is
    evaluated entirely in `float` — no `uint8_t` truncation applies there,
    unlike the assignment site checked above. Reproduced from scratch:
    full RELEASE `objdump -Sxdstr` diff of `022e50c~1` vs `022e50c`, both
    boards (generic + megarm), rebuilt in this session — exactly one word
    differs anywhere in either binary, at `spindle_init()+0x84` (file
    offset `0x34c`): `0x477ffe00` vs `0x437e0000`, i.e. the float literal
    `65534.0f` (the old `SPINDLE_PWM_RANGE`) became `254.0f` (the new one).
    Everything else, byte for byte, is identical — so the commit's
    "disassembly byte-identical" claim is falsified by one word, and that
    one word is exactly where the bug lived.
    Quantified with a standalone host rebuild of the unmodified
    `spindle_compute_pwm_value()` body against samd21's actual shipped
    defaults (`DEFAULTS_GENERIC`, `grbl/defaults.h:44-45`: `$30`/`rpm_max` =
    1000, `$31`/`rpm_min` = 0): `pwm_gradient` was `65.534` pre-fix vs
    `0.254` post-fix (a 258x error), and the resulting `uint8_t` PWM
    register value for representative commanded speeds (pre-fix ->
    post-fix): `S100` 154->26, `S500` 255->128, `S900` 101->229, `S999`
    189->254 — before the fix, the spindle PWM duty for nearly every
    commanded RPM below `rpm_max` was an arbitrary, unrelated value (the
    linear term wrapped mod 256), not the requested duty. `S1000`,
    `S12000`, `S24000` all resolve to `255` on both sides of the fix,
    because `DEFAULTS_GENERIC`'s `rpm_max=1000` puts each of them on the
    `rpm >= settings.rpm_max` saturation branch, which returns
    `SPINDLE_PWM_MAX_VALUE` directly and never touches `pwm_gradient` — this
    is also why the commit's own Renode probe (`M3 S1000`) could not have
    caught the bug: it happened to land exactly on the one branch immune to
    it. The fix (`MAX_VALUE 65535`->`255`) is still correct and sufficient
    (it makes `SPINDLE_PWM_RANGE` right in both the float and uint8_t
    contexts) — what was wrong was the commit's characterization of the
    prior state as behaviour-preserving/cosmetic. This bug shipped, silently,
    for the entire period samd21 declared `SPINDLE_PWM_MAX_VALUE 65535`.
  - **Per-port RANGE audit (2026-07-26)**: re-verified rather than assumed
    that no sibling port carries the same latent bug. atmega328p (AVR
    origin) `PER`=255 fixed by hardware; stm32f103/f411/h523 `TIM1->ARR`=255;
    hc32f460 `TMRA_1->PERAR`=255; ch32v006 `ATRLR`=255; dspic33ak128mc102
    `CCP2PR`=255; ch570 fixed 256-step hardware PWM cycle (`RB_PWM_CYC_256`)
    matching `MAX_VALUE=255` exactly — every one of these declares
    `SPINDLE_PWM_MAX_VALUE=255`/`RANGE=254` and is sane against its own PER;
    none reproduces this bug. sg2002 defines no `SPINDLE_PWM_*` at all (no
    variable-spindle support yet, out of scope). hc32f460 and
    dspic33ak128mc102 both predate 022e50c in history (confirmed via `git
    merge-base --is-ancestor`); ch570 landed after it (d4c5245) and was
    authored with `MAX_VALUE=255` and the `_Static_assert` from its first
    commit. samd21 was the only port that ever carried the wrong value.
  - **Ratchet**: removed the now-dead `config.h: ... -Woverflow ...` line from
    `ci/warn_baseline_samd21.txt` (one-way ratchet, removal-on-real-fix
    direction). Confirmed gone from fresh build logs across all 4 combos
    (megarm/generic × DEBUG/RELEASE); `ci/warn_ratchet.py` OK against the
    trimmed baseline on all 4 (4 distinct warnings each, all baselined, 0 new).
  - **Gates**: AVR golden `make validate` PASSED (text 30640, data 0, bss
    1633, MD5 79af184e67b27defd27a39309ac53563, `AVR_GCC_PATH=/usr/bin` in
    this environment). samd21 megarm RELEASE **31952/296/6160 — byte-identical
    to canon, delta 0** (DEBUG 48112/296/6160, also unchanged). generic
    RELEASE 31940/296/6160 and DEBUG 48028/296/6160, both unchanged pre- vs
    post-fix (verified via `git stash`/rebuild/`stash pop` A-B comparison —
    the constant-fold means the fix is size-neutral, as expected). All 6
    sibling ports rebuilt and confirmed byte-identical to the canonical table:
    f103 28700/80, h523 25132/388, f411 25796/80, hc32f460 25596/80, ch32v006
    41072/0 (dsPIC not in this environment's toolchain roster; untouched by
    the diff regardless — `git diff --stat` shows only
    `ci/warn_baseline_samd21.txt` and the two samd21 board config.h files).
  - **Runtime proof (Renode)**: `ci/renode/smoke.sh --arc` on a freshly
    rebuilt megarm DEBUG image — banner, `$$`, motion (MPos 0→1.000, Idle),
    arc (`G2 X2 I1 F200`, Y peak 1.000, endpoint (3,0,0), Idle), dwell (`G4
    P0.5` ok in 0.49s) all PASS, PA25 X STEP driven high 427 times, **exit
    0**. Additionally drove the actual spindle path live over the UART
    socket: `M3 S1000` → `ok`, `?` → `<Idle|MPos:0.000,0.000,0.000|FS:0,1000|
    Pn:XYZ|WCO:0.000,0.000,0.000>` (spindle speed 1000 accepted and reported),
    `M5` → `ok` — no error/ALARM, no hang, the exact code path this fix
    touches (`spindle_compute_pwm_value`/`spindle_set_speed`) runs clean.
  - **Renode monitor caveat, recorded rather than glossed over**: attempted to
    read `TCC0->PER`/`CC[0]` back live via the monitor
    (`sysbus ReadDoubleWord 0x4200204C`/`0x42002050`) to show the duty
    register taking the new value directly. `samd21_grbl.repl` models TCC0 as
    a plain `Tag` (by design — the smoke harness doesn't need real PWM
    timing), which has no backing store: `peripherals` doesn't list it, reads
    always return the tag's constant 0 regardless of what firmware wrote, and
    `SetHookBeforePeripheralWrite` (which works fine on named peripherals like
    `portA` — that's how the PA25 STEP-pin evidence above is captured)
    rejects Tag ranges because they aren't a bindable `IBusPeripheral`. Making
    TCC0 register-accurate is a platform-model extension, out of scope for a
    duty-cap-domain fix; the compile-time/disassembly proof above plus the
    live M3/M5 execution is the evidence this environment can produce.
  - **Docs**: this closes the samd21 exception noted in the `_Static_assert`
    sweep item above; CONTRACTS.md static-assert-sweep section (slug
    `static-assert-sweep`) and §6.2 (slug `spindle-pwm`) updated to match —
    "Known gap" language for the PWM range replaced with closure text, no
    exceptions remaining. **Both sections further corrected 2026-07-26** to
    replace the "behaviour-preserving by construction"/"disassembly
    byte-identical" wording with the BUG #22 reproduction above — the
    adversarial review's finding that this was a significant, previously
    live spindle-output bug, not a cosmetic no-op, is accepted and recorded
    here rather than argued with.

- **[x] `-flto` ENABLED ON ch32v006/ch570 RELEASE (2026-07-26)** — a
  compactness audit measured, by real rebuild, that turning on
  `-flto -fno-fat-lto-objects`/`-flto -Os` (RELEASE only, BUILD-gated,
  matching the samd21/stm32*/hc32f460/sg2002 house style already in every
  ARM port's Makefile) shrinks both RISC-V ports' RELEASE binaries:
  - **ch32v006**: text 41072 → **39012 B (−2060, −5.0%)**.
  - **ch570**: text 40674 → **38422 B (−2252, −5.5%)**.
  Both numbers re-measured live in this batch (not projected from the
  audit) and matched exactly.
  - **Precondition the audit hit before either number was real**: naive
    `-flto` breaks the boot path on both ports. `Reset_Handler` is reached
    from exactly one place — `_start`'s raw inline asm (`jal
    Reset_Handler`), invisible to LTO's whole-program IPA (it never parses
    asm strings for symbol references). With no visible C-level caller,
    IPA for an executable link concludes `Reset_Handler` is dead and
    deletes its definition before codegen, and the link fails loudly:
    `undefined reference to 'Reset_Handler'`. This is **BUG #21's exact
    mechanism** (`KEEP()`/table-reachability cannot save a symbol IPA
    already erased) on an ISA where the ARM ports' usual defense
    (`Reset_Handler` address-taken from a C-visible `vector_table[]`) does
    not apply, because RISC-V reset is entered by hand-written assembly,
    not a hardware-loaded pointer table. Fix: `__attribute__((used))` on
    `Reset_Handler` in both `ch32v006/startup.c` and `ch570/startup.c` —
    nothing else needed pinning. `PFIC_Vector[]` and every ISR it addresses
    were already `used`/address-taken from the earlier `--gc-sections`
    lifecycle fix (CONTRACTS.md §14 item 3) and needed no change. Full
    writeup, slug `lto-asm-only-reachable-symbols`, appended to
    CONTRACTS.md as a new placeholder-numbered gap-log section (integrator
    assigns the final `## N.`).
  - **Symbol-survival proof (not assumed)**: post-`-flto` `nm` on both
    RELEASE ELFs confirms `_start`, `Reset_Handler`, `PFIC_Vector`, and
    every real ISR body present by name (`Default_Handler`,
    `SysTick_Handler`, `TIM2_IRQHandler`, `EXTI7_0_IRQHandler`,
    `USART1_IRQHandler` on ch32v006; `Default_Handler`, `SysTick_Handler`,
    `TMR_IRQHandler`, `GPIOA_IRQHandler`, `UART_IRQHandler` on ch570).
    Disassembly of two ISR bodies per port confirms `mret` (opcode
    `0x30200073`) is still the last instruction emitted
    (`TIM2_IRQHandler`/`USART1_IRQHandler` on ch32v006,
    `TMR_IRQHandler`/`UART_IRQHandler` on ch570) — CONTRACTS.md §20's
    trap-return contract holds under LTO.
  - **DEBUG unaffected, by design**: `-flto` gated on `BUILD==RELEASE`
    only, same as every ARM port. DEBUG stays `-Og -g3` on both RISC-V
    ports — confirmed byte-for-byte unchanged (`used` is inert without
    `-flto`): ch32v006 DEBUG 46988/0, ch570 DEBUG 46830/4, both matching
    the pre-batch recorded figures exactly.
  - **Gates re-run this batch**: golden AVR `make -C
    grbl/platform/atmega328p validate` **PASSED** (MD5
    `79af184e67b27defd27a39309ac53563`, text 30640); RISC-V boot-integrity
    check (Makefile's `_start`-at-flash-base assertion, the RISC-V form of
    BUG #21's ratchet) **OK** all four builds (`_start=0x00000000`);
    `tools/assert_no_double.sh` FP=SINGLE post-link assert **PASSED** all
    four builds; `ci/warn_ratchet.py` **OK** against
    `ci/warn_baseline_ch32v006.txt`/`ci/warn_baseline_ch570.txt` for all
    four build logs (ch570 RELEASE additionally reported 4 baseline
    warnings no longer observed — left in the baseline per the one-way
    ratchet rule, not removed); zero `PORT_TODO_*` in all four ELFs.
  - **Artifacts refreshed** (both ports' binaries legitimately shrank):
    `tools/build_artifacts.py build` regenerated
    `artifacts/ch32v006/{grbl_ch32v006.bin,.hex,.syms}`,
    `artifacts/ch570/{grbl_ch570.bin,.hex,.syms}`, and
    `artifacts/MANIFEST.sha256`. `tools/build_artifacts.py check` **OK**
    across all 10 buildable units afterward — the other 8 units (all 7
    untouched sibling ports plus dsPIC's own non-byte-reproducible
    exemption) rebuilt byte-identical to their already-committed
    artifacts, confirmed via `git diff --stat` showing zero changed bytes
    outside `ch32v006/`, `ch570/`, and `MANIFEST.sha256` — this batch is
    scoped to exactly the two ports it targets, verified rather than
    assumed. `tools/build_artifacts.py --selftest`,
    `tools/assert_no_double.sh --selftest`, `ci/warn_ratchet.py
    --selftest`, and `tools/check_contracts_numbering.py` all still PASS
    unchanged.
  - **Files touched**: `grbl/platform/ch32v006/{Makefile,startup.c}`,
    `grbl/platform/ch570/{Makefile,startup.c}`,
    `artifacts/{ch32v006,ch570}/*`, `artifacts/MANIFEST.sha256`,
    `CONTRACTS.md`, `PLAN.md`. No other platform's source, Makefile, or CI
    config touched.
