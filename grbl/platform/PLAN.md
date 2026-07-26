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
- [x] **`_Static_assert` sweep (2026-07-26)**: beyond the landed CPU_FREQ example,
      four more contract classes now fail the build instead of the field:
      (1) **SPINDLE_PWM_MAX_VALUE <= 255** (duty-cap-twins class, CONTRACTS.md
      #6.2 — the exact bug h523 and f103 both shipped: PWM_MAX=1000 against a
      uint8_t core duty) added to stm32f103/h523/f411, ch32v006, dspic33ak128mc102,
      `_template` (6 ports). samd21 (megarm+generic) DELIBERATELY EXCLUDED — it
      is the one port that still genuinely violates this (65535, a documented
      pre-existing gap, CONTRACTS.md #6.2), so adding the assert there would
      convert a known runtime bug into an unrelated build break; a comment at
      each board's config.h says so and the actual PWM-range fix is left for
      its own Renode-verified batch. (2) **NVMEM window <= cache size**
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
      * [ ] CI wiring: cached XC-DSC installer or fetch step + 2 matrix rows +
        warn baseline from real logs
- [ ] hc32f460 (ARM M4, vendor-exotic — tests contract completeness)
- [ ] sg2002 (RISC-V 64, linux-class — decide scope first: bare-metal vs linux userspace)
- [ ] **ch570** RECON DONE (matrix in recon report): QingKe V3C RV32IMBC (full
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
      ch32v006. Companion trap this recon surfaced, see CONTRACTS §20: the
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

## Current State (update each session)

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
  | dspic33ak128mc102 | N/A — FP=DOUBLE is this port's declared default (native DP FPU), never carried the SINGLE rollout | ~41.8KB code | — | — |

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
