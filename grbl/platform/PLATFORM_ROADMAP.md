# GRBL HAL Platform Roadmap

**Date**: 2026-07-26 (truth-updated against the tree by fresh clean builds of every buildable
port, not inspection — supersedes the 2026-07-24 status below, which had already gone stale on
stm32f103/stm32h523/ch32v006/dsPIC while this file waited its turn; see PLAN.md's "Truth-update
PLATFORM_ROADMAP.md" checkbox)
**Status**: 8 platforms across 3 ISA families now build clean (zero `PORT_TODO_*` where that
mechanism applies) and pass every mechanical gate (golden AVR MD5, warning ratchet, boot
integrity, no-DP assert). **Exactly one of the eight — samd21 — has ever executed, and only in
Renode emulation** (boots, talks, and moves a real arc with STEP-pin evidence); every other port
is build/link/contract-proven only. **No port has run on physical hardware.**
**[PLAN.md](PLAN.md) is the live orchestration ledger** (single source of truth for phase-by-phase
status and the canonical RELEASE size table); this file is the platform-facing overview and gets
synced against it periodically, not the other way around.

This document outlines the platform ports and their implementation status.

---

## ARM Platforms (STM32 family) — all three build clean

All three were, at different points in this project's history, claimed "100% Complete / Production
Ready" or shipped with the same "docs say done, was never compiled" disease later found in
ch32v006/hc32f460/sg2002 too. All three now build both flavors from a clean tree, gated by the
golden AVR MD5, the warning ratchet, and (after BUG #21 below) a post-link boot-integrity check
that fails the build if the vector table or reset SP look wrong.

### STM32F103C8 (Blue Pill)
- **Status**: 🟢 Builds clean, both flavors, zero regressions in golden/sibling gates
- **Architecture**: ARM Cortex-M3, 72MHz
- **Memory**: 20KB RAM, 64KB Flash
- **RELEASE flash body** (re-measured 2026-07-26, `text`/`data`): **28700 / 80** — smaller than
  the AVR golden reference (30640/0). DEBUG: 43120/80.
- **History**: was build-broken (undeclared spindle macros, `PLATFORM_NAME`/`sei`/`cli`
  redefinitions, a `LIMIT_DDR` self-collision) until PLAN.md Phase 1 fixed it, then briefly shipped
  a RELEASE binary with NO vector table at all (BUG #21, LTO ate it) until the fix landed
  2026-07-25. Both classes of defect are now covered by a CI gate (build + boot-integrity check)
  so they cannot silently recur.
- **Proof level**: build/link/contract-proven. No emulator model exists for this MCU family here;
  never executed, emulated or real.

### STM32H523CBT6 (Black Pill H5)
- **Status**: 🟢 Builds clean, both flavors
- **Architecture**: ARM Cortex-M33, 250MHz
- **Memory**: 32KB RAM, 128KB Flash
- **RELEASE flash body**: **25132 / 388** — the smallest port in the whole matrix, smaller than
  both the AVR golden reference and every ARM sibling. DEBUG: 41508/388.
- **History**: was build-broken (Makefile never set `CFLAGS_EXTRA`, missing `-I../common/dummy`)
  until Phase 1; also hit BUG #21 (RELEASE shipped without a vector table) and BUG #20 (NVMEM
  window sized past its own cache buffer, fully dead in RELEASE until fixed) — both now covered by
  CI gates.
- **Proof level**: build/link/contract-proven. Never executed, emulated or real.

### STM32F411CEU6 ("Black Pill", ARM Cortex-M4F) — Phase 6 rolling port #1
- **Status**: 🟢 Builds clean, zero `PORT_TODO_*`
- **Architecture**: ARM Cortex-M4F, 96MHz (HSE 25MHz -> PLL, PLLM=25/PLLN=192/PLLP=2)
- **Memory**: 128KB RAM, 512KB Flash
- **FPU**: `-mfpu=fpv4-sp-d16 -mfloat-abi=hard`, `FP=SINGLE` — real `vsqrt.f32`/`vmul.f32`
  instructions confirmed in disassembly, zero `__aeabi_d*` soft-float call sites remaining
  (CONTRACTS.md section 15 item 5 justifies hard vs softfp)
- **Code reuse**: GPIO/clock-config shape from stm32h523 (F4-style MODER/OTYPER/PUPDR/AFR); EXTI
  dispatch and USART SR/DR shape from stm32f103 (F411 is NOT H5 on either of those two axes,
  despite sharing H5's GPIO model — see CONTRACTS.md section 15 items 1-3); flash.c is new
  (F4 sector erase, distinct from both F1/H5 page erase — section 15 item 4).
- **RELEASE flash body**: **25796 / 80** (of 512KB flash / 128KB RAM) — smaller than the AVR
  golden reference. DEBUG: 41644/80.
- **Proof level**: build/link/contract-proven. Never executed, emulated or real (no emulator model
  exists for this chip here).
- **CI**: two matrix rows (`stm32f411` × `{DEBUG, RELEASE}`), warning baseline from real build logs.

---

## In Progress Platforms

### SAMD21G18A (Arduino Zero / MKR) - HIGH PRIORITY
- **Status**: 🟢 COMPLETE and the only port in this matrix with runtime evidence — boots, talks
  ($$ dump over serial RX/TX interrupts), and **moves** in Renode 1.16.1 (a real `G2` arc traced
  with STEP-pin (PA25) toggling and correct MPos tracking, no phantom motion). Still never run on
  physical hardware, same as every other port here.
- **Priority**: **HIGH** - Custom rSamba bootloader integration
- **Architecture**: ARM Cortex-M0+, 48MHz
- **Vendor**: Microchip (formerly Atmel)
- **Memory**: 32KB RAM, 256KB Flash
- **Bootloader**: rSamba (512 bytes) - https://github.com/kimstik/rSamba
- **Target boards**: Arduino Zero, MKR series, Adafruit Feather M0
- **Unique features**:
  - **DIVAS** - Division and Square Root Accelerator (1-3 cycles)
  - **rSamba** - Ultra-compact bootloader (maximum app space)
  - Native USB 2.0 Full Speed
  - 6x SERCOM (UART/SPI/I2C configurable)
  - 3x TCC timers with advanced PWM
  - 12-channel DMA
  - Popular Arduino ecosystem
- **Implemented** (all of the following build and are verified line-by-line against the SAMD21 family datasheet — GCLK pp.114-132, TC3/TC4 pp.582-620, TCC0 pp.647-697, EIC pp.338-356, SERCOM3 pp.432-454, NVMCTRL pp.355-376):
  - ✅ Build system, startup code, vector table (44 IRQs), linker script, pin mapping (Arduino Zero compatible)
  - ✅ rSamba bootloader integration (app starts at 0x00000200)
  - ✅ GCLK clock tree (DFLL48M generic clock generators)
  - ✅ GPIO (PORT direct read/write) + EIC external interrupts (limits, controls)
  - ✅ TC3 stepper timer / TC4 pulse-reset timer (SYNCBUSY-correct)
  - ✅ TCC0 PWM for spindle speed
  - ✅ SERCOM3 UART (115200 baud, arithmetic-mode formula)
  - ✅ NVMCTRL flash-emulated EEPROM (page erase/write)
  - ✅ `_delay_us()` / `_delay_ms()` (landed 2026-07-24: calibrated 3-cycle asm loop + `hal_millis()` poll with a busy-wait fallback for handler-mode/PRIMASK/unconfigured-SysTick cases; disasm-verified). These were empty stubs until this commit — homing and spindle dwell delays would previously not have worked at all.
- **Bug-fix history**: 16 numbered bugs (BUG #1 - #16) found and fixed across six review passes: two "deep code review" sweeps (#1-3 serial PMUX/clock/timer-enable; #4-6 UART baud formula + TCC0 SYNCBUSY bits), a SYNCBUSY-synchronization sweep (#7-9, "third expert review pass"), an ISR-correctness pass (#10 catastrophic — interrupt flags never cleared, causing an interrupt storm; #11 critical — inline ISR wrappers generated no symbol, so hardware interrupts silently fell through to `Default_Handler`), a memory-ordering/race-condition pass (#12-13 — unordered ring-buffer updates on ARM's weak memory model, missing `__DSB()` around Flash writes and `.data`/`.bss` init), and a final line-by-line datasheet-verification pass (#14-16 — TC4 was clocked from the wrong GCLK ID and had no clock signal at all, plus two low-severity findings). Full detail in the `SAMD21:` commits in `git log`.
- **Build** (re-measured 2026-07-26, board=megarm): DEBUG `text`/`data` = 48112/296 (bss 6160).
  RELEASE = **31952/296** (12.5% of 256KB flash). board=generic: DEBUG 48028/296, RELEASE 31940/296.
  AVR golden checksum unaffected (`make -C grbl/platform/atmega328p validate` → PASSED).
- **Closure history** (PLAN.md Phase 3, COMPLETE 2026-07-23 — all items below landed, kept here
  for the record rather than as an open list):
  - `SysTick_Config()` wired from startup — the 1 kHz timebase drives `hal_millis()`/`hal_micros()`.
  - **BUG #17 (CRITICAL, found here)**: core `settings.c`'s pin-mask helpers return `uint8_t`, but
    SAMD21 STEP/DIR bits go above bit 7 (e.g. bit 25) — silently truncated to 0, meaning **zero
    step output ever**, while `$H`/status still reported success (a position lie: MPos moved,
    pins stayed dead). Fixed via a logical-bit/physical-pin split (CONTRACTS.md §1); a
    `_Static_assert` now makes "logical bit > 7" a build-time failure everywhere, not just here.
  - Renode smoke test landed in CI (`ci/renode/`, `.github/workflows/smoke.yml`): boot → banner →
    `$$` dump → `ok`. Extended with a motion stage: `G2` arc traced with real STEP-pin (PA25)
    toggling and correct MPos, plus a negative control (the pre-#17-fix tree fails the motion
    stage, proving the test would have caught it).
  - Still **no hardware validation** — this port has never run on a physical chip. It is the only
    port with any execution evidence at all (Renode), which is why PLAN.md calls it "ready for
    hardware validation" rather than the build/link/contract-proven-only bar every other port
    in this matrix is held to.
- **Target use case**: Arduino-compatible CNC, educational, maker projects
- **See**: [SAMD21_PLAN.md](samd21/SAMD21_PLAN.md) (itself stale — treat [PLAN.md](PLAN.md) Phase 3 as authoritative over it), [PLAN.md](PLAN.md)

### SG2002 (Sophgo RISC-V)
- **Status**: ❌ NON-FUNCTIONAL — never compiled (relabeled 2026-07-26; was
  previously, incorrectly, described as "Work In Progress"/"partial").
  Verified by direct build attempt: this is the FOURTH platform port found
  in this state — (1) the Makefile never passes `--specs=picolibc.specs`,
  so the first file fails on `math.h: No such file or directory`; (2) the
  apt `picolibc-riscv64-unknown-elf` package has no `rv64imafdc`/`lp64d`
  multilib, so there is no `crt0.o` for the ARCH/ABI this Makefile
  requests even once the flag is fixed; (3) fatally, `platform.h` defines
  a private `HAL_*` macro namespace (`HAL_GPIO_SET_OUTPUT`,
  `HAL_TIMER_STEPPER_INIT`, ...) that core `stepper.c` has not called
  since the Nov-2025 HAL_-strip refactor — this platform layer never
  reaches `stepper.c` at all. See `sg2002/README.md`'s status banner for
  full detail. Recommendation: restart from `_template`, do not repair in
  place.
- **Architecture**: RISC-V C906, 700MHz (RV64IMAFDC)
- **Vendor**: Sophgo
- **Memory**: 256MB DDR3
- **Target board**: LicheeRV Nano
- **Unique features**:
  - Dual-core: big core (C906 RISC-V or Cortex-A53 ARM, mutually exclusive
    boot-strap, runs Linux) + little C906L (RISC-V, no MMU, M-mode,
    ALWAYS present regardless of big-core ISA — this is the actual
    runtime-core target; see PLAN.md `sg2002` entry, fact-corrected
    2026-07-26)
  - Linux-capable on the big core only; the runtime core we target is
    bare-metal
  - PLIC interrupt controller
  - High performance for complex G-code
- **Current status**: NON-FUNCTIONAL source tree as described above,
  unchanged pending a `_template` restart. Separately, PLAN.md now carries
  a DESIGN-COMPLETE / IMPLEMENTATION-DEFERRED runtime-core channel design
  (remoteproc lifecycle + shared-memory ring replacing UART for CONTRACTS
  §7, cross-core cache-maintenance obligations per [CONTRACTS §23](CONTRACTS.md#cross-core-cache-coherency)) — that
  design targets a rewrite of this platform, not a fix to the current
  source. Not in the CI build matrix.
- **Target use case**: High-end CNC, complex multi-axis systems

---

## Continuous Integration

There was no CI when this roadmap was first written; there is now (landed 2026-07-23, `.github/workflows/`):

- **Build matrix** (`ci.yml`, 15 rows in the shared apt-toolchain matrix, re-verified 2026-07-26 by
  rebuilding every row locally): atmega328p (RELEASE only, 1), stm32f103 × {DEBUG, RELEASE} (2),
  stm32h523 × {DEBUG, RELEASE} (2), stm32f411 × {DEBUG, RELEASE} (2), samd21 × {megarm, generic} ×
  {DEBUG, RELEASE} (4), ch32v006 × {DEBUG, RELEASE} (2), hc32f460 × {DEBUG, RELEASE} (2).
  **dsPIC33AK128MC102 landed in CI 2026-07-26** too, as its own dedicated `build-dspic33ak128mc102`
  job (2 legs, DEBUG/RELEASE) rather than a matrix row — the shared composite action is apt-only and
  XC-DSC's fetch/cache/SHA-256-verify/unattended-install shape doesn't fit it (see the job's header
  comment in `ci.yml`). Still not in any matrix: sg2002 (non-functional, deferred by design),
  `_template` (intentionally excluded — it's a checklist, not a shippable port), ch570 (not yet
  landed — see its own entry below). It's a thin invoker: the platform Makefiles remain the actual
  build authority, CI just calls `make`.
- **`docs-integrity` job**: `tools/check_contracts_numbering.py` fails the build on any
  CONTRACTS.md numbering/anchor/cross-reference inconsistency (24 sections today, all consistent).
- **CI is confirmed running on this fork (corrected 2026-07-26)**: PLAN.md's Current State
  previously recorded "the GitHub Actions API shows no runs for the branch yet (Actions possibly
  disabled on fork)" and Phase 0's exit criterion still literally reads "PENDING first GitHub
  Actions run" — both stale. `github.com/kimstik/grbl/actions` on this branch shows **78 CI runs
  and 67 Smoke (Renode) runs**, matching this branch's own commit history one-for-one (run #78 is
  this tree's current HEAD commit). Pass/fail conclusions per run were not independently
  re-confirmed in this pass (icon-based status doesn't survive the fetch method used) — an owner
  or contributor with normal browser access to the Actions tab can confirm green/red at a glance.
  Every gate in this file has also been separately re-verified by fresh local builds today, so the
  two checks (CI history existing, and this file's numbers) corroborate rather than substitute for
  each other.
- **Golden gate (BLOCKING)**: `make -C grbl/platform/atmega328p validate` runs on every push and fails the pipeline if the built `grbl.hex` MD5 drifts from the pinned golden hash (`79af184e67b27defd27a39309ac53563`, `grbl/platform/common/chk.py`). Verified locally in this worktree: **PASSED**, text=30640 bytes. This is the one gate that never gets waived — AVR byte-for-byte integrity is the project's core invariant.
- **Warning ratchet**: `ci/warn_ratchet.py` plus one `ci/warn_baseline_<platform>.txt` per platform. One-way ratchet (new warnings not already in the baseline fail CI) rather than a blanket `-Werror`, since the ARM baselines are still partly inspection-derived pending a first real CI run.
- **compile_commands.json**: `make compdb` (samd21) via `tools/gen_compile_commands.py`, preserving the `-include` injection chain so IDEs/clangd see what the build actually sees.
- **Provenance (weekly, report-only)**: `provenance.yml` clones live `gnea/grbl` tag `v1.1h.20190825` fresh and rebuilds both trees with the same toolchain/flags in one job, then byte-diffs `.text`. **Empirical result** (same avr-gcc 7.3.0, no LTO): the two `.text` sections differ by exactly **2 bytes** — the `GRBL_VERSION_BUILD` date string (`"20190825"` upstream vs `"20190830"` in `grbl/grbl.h` here). Every other byte of machine code is identical. This job doesn't gate CI (the golden-hash check above does); it's an ongoing proof that the golden hashes themselves stay upstream-derived instead of silently drifting into an undocumented fork.

---

## Planned Platforms

### 1. STM32F411CEU6 ("Black Pill", ARM Cortex-M4F) — ✅ DONE (Phase 6 rolling port #1)
- **Priority**: HIGH — first item in PLAN.md's Phase 6 rolling-ports queue; toolchain already in CI and large reuse expected via stm32_common
- **Architecture**: ARM Cortex-M4F, 96MHz (see status entry above — 100MHz would need PLLP=/1 with a
  different PLLN, but 96MHz is the standard Black Pill config that also yields a clean 48MHz USB
  clock on PLLQ, so this port uses the community-standard value rather than the datasheet's
  absolute maximum)
- **Memory**: 128KB RAM, 512KB Flash
- **Current status**: full port complete — see the "STM32F411CEU6" status entry earlier in this
  file. Builds clean, zero `PORT_TODO_*`, CI matrix rows added, ready for hardware validation.
- **Target use case**: high-performance CNC on cheap, widely available hardware

### 2. dsPIC33AK128MC102 (motor-control DSC — third ISA family)
- **Priority**: HIGH — owner-requested 2026-07-23; second item in PLAN.md's Phase 6 queue
- **Architecture**: dsPIC33 DSC core, 200MHz, dual-precision (single + double) hardware FPU
- **Vendor**: Microchip
- **Package**: 28-pin, chosen specifically as the modern heir to the ATmega328p DIP-28 form factor
- **Unique features**:
  - Dual-precision hardware FPU — none of the other ports have this
  - Motor-control PWM (SCCP/MCCP) purpose-built for spindle/motor drive
  - Peripheral Pin Select (PPS) eases the pin budget on a 28-pin part
  - MPLAB XC-DSC compiler is now free including optimizations, removing what used to be a licensing barrier to porting here
  - Community hardware reference: MC106 Curiosity board
- **Why it matters**: this would be the third distinct ISA family in the platform matrix, after ARM and RISC-V — the sharpest portability stress test yet for the macro/contract abstraction, since dsPIC's instruction set and toolchain conventions diverge furthest from AVR/ARM/RISC-V.
- **Toolchain note**: XC-DSC isn't apt-installable; verified unattended-install recipe (URL, SHA-256, the undocumented `--netservername ""` flag, Apache-2.0 DFP) lives in `dspic33ak128mc102/platform.md` and PLAN.md's Decision Log. EULA owner-approved 2026-07-24; **CI wiring landed 2026-07-26** as a dedicated `build-dspic33ak128mc102` job (cached+SHA-256-verified installer/DFP, 2 legs) — see PLAN.md Decision Log entry and `ci.yml` for the details, including two bugs found and fixed/worked-around along the way (a Makefile `bin2hex` gap and a shell `set -e` foot-gun).
- **Current status**: **COMPLETE (Steps 3-6 landed 2026-07-26)** — both `make BUILD=DEBUG` and
  `make BUILD=RELEASE` build and link the full ELF with **zero `PORT_TODO_*`** (confirmed via
  `nm | grep PORT_TODO`, empty on both). T1 stepper timer, SCCP1 pulse-reset, SCCP2 spindle PWM,
  a freshly-mined UART1 register model, and flash-based NVMEM (ROW PROGRAM into a linker-reserved
  window) are all real, not stubs. `FP ?= DOUBLE` is this port's own declared default (native DP
  FPU). RELEASE code size is approximately 41.8KB / DEBUG approximately 53.2KB (of 128KB flash) —
  reported as approximate because the free tier of this Microchip compiler prints "Options have
  been disabled due to restricted license" on `-Os` and no `size` utility ships with the toolchain,
  so an exact byte count needs a licensed build to fully trust. Clock tree (200 MHz FRC→PLL1) and
  several SCCP timer encodings remain UNVERIFIED on silicon — no dsPIC33A emulator exists anywhere.
  Gap log in CONTRACTS.md §16 (20 items — third-ISA holes ARM/RISC-V never hit: linker-synthesized
  IVT, compiler-won't-emit-bset atomicity, no-barrier ISA, -O1/-Og ICE, TRIS/ANSEL traps, config
  words, PPS output muxing with no DFP value-groups).
- **Target use case**: CNC/motor-control applications wanting a hardware FPU and purpose-built motor PWM in a 328p-sized footprint

### 3. CH32V006 (RISC-V Microcontroller) — ✅ DONE (Phase 4, "fresh port by the new rules")
- **Priority**: was HIGH; now COMPLETE — this was the first port built strictly from the `_template` skeleton + written macro contracts, and it closed PLAN.md Phase 4.
- **Architecture**: RISC-V rv32ec_zicsr, 48MHz
- **Vendor**: WCH (Nanjing Qinheng Microelectronics)
- **Target board**: `boards/generic`
- **Memory**: 8KB RAM, 62KB Flash (per `ch32v006/script.ld`; an older draft of this entry said
  "2KB RAM, 16KB Flash" — that was the smaller CH32V003-class part first considered, not the
  CH32V006-class part the landed port actually targets)
- **Current status**: COMPLETE — zero `PORT_TODO_*` at link, both flavors. RELEASE `text`/`data` =
  **41072/0** (re-measured 2026-07-26 after the `FP=SINGLE` diet, was 55560 before, fits the 61K
  usable flash window with room to spare); DEBUG = 46988/0. Boot-integrity (RISC-V variant:
  `_start` at flash base) passes. CI: two matrix rows.
  Build/link/contract-proven only — no Renode/QingKe emulator model exists here, never executed.
- **Unique features**:
  - First RISC-V port of GRBL
  - Ultra low-cost silicon family
  - 32-bit RISC-V core
  - Built-in USB and UART bootloader
- **Challenges (encountered and resolved during the port; kept for history)**:
  - RISC-V toolchain setup — solved via apt (`gcc-riscv64-unknown-elf`, `picolibc-riscv64-unknown-elf`)
  - PFIC interrupt controller (WCH-specific, not CLINT/PLIC) — clean-room headers, verified
  - No FPU — `FP=SINGLE` diet + `assert_no_double.sh` keep it off the soft-float DP path
- **Target use case**: Ultra-low-cost CNC controllers, educational projects

### 4. HC32F460JETA (High-Performance ARM) — ✅ built (Phase 6 rolling port #3)
- **Status**: 🟢 Builds clean, zero `PORT_TODO_*`, ready for hardware validation (register facts
  are clean-room + honestly UNVERIFIED-flagged — see below, hardware bring-up gates real trust)
- **Architecture**: ARM Cortex-M4F, up to 200MHz
- **Vendor**: HDSC / XHSC (Huada Semiconductor) — first HDSC/vendor-exotic chip in this tree;
  no donor port shares this vendor's peripheral IP at all (TIMER0/TIMERA, GPIO PORT model, INTC
  event router, EFM flash, PWC/CMU clock tree)
- **Target board**: generic reference pin map (no specific commercial board), same posture as
  ch32v006's `boards/generic`
- **Memory (this port's linker script)**: 128KB RAM (conservative subset of the "up to 192KB" max
  variant-dependent spec), 512KB Flash
- **Previous status was fiction**: the directory before this port had a `platform.h` skeleton
  (marketing-comment blocks, `#include "hc32_ddl.h"` pointing at a vendor SDK never vendored into
  this tree) and nothing else — no Makefile/gpio.h/timer.h/regs.h/startup.c/platform.c/handlers.c/
  script.ld. It never built. Same "trust only builds" lesson as stm32f103/stm32h523/stm32f411.
- **Verification methodology (see `regs.h` file header for full detail)**: no permissively-licensed
  vendor SDK could be confirmed this session (HDSC's own `hc32f4a0_ddl` exists on GitHub but no
  LICENSE file was found — unlike the dsPIC33AK DFP's Apache-2.0 or ch32v006's Zephyr dtsi
  cross-check), so this port is clean-room register headers per PORTING-CHECKLIST's
  vendor-SDK-only-if-permissive rule. Klipper3d/klipper's real shipped `src/hc32f460` firmware
  (GPL-3.0, license-compatible with this GPLv3 core) was used as an independent factual
  cross-check — NOT copied — for GPIO data-path register names, the INTC event-router mechanism,
  and USART/TIMERA existence. Every other register offset/bit-field/base-address is an explicitly
  flagged UNVERIFIED placeholder pending the real HC32F460 register-level manual.
- **Unique architecture fact**: this chip has NO fixed per-peripheral NVIC vector table. Every
  peripheral interrupt source routes through an INTC event router onto a shared pool of 32
  identically-named vectors (`Int000_IRQn`..`Int031_IRQn`) — a materially different shape from
  every STM32/SAMD21 donor in this tree, confirmed via Klipper's real interrupts.c.
- **Sizes (this session, real `arm-none-eabi-gcc` 13.2.1 build)**: RELEASE `.text` 25596B / `.data`
  80B (of 512KB flash); DEBUG `.text` 41220B. Both link with **zero `PORT_TODO_*`** and zero
  undefined symbols. `FP=SINGLE` (default) `assert_no_double.sh` PASSED on both flavors;
  disassembly confirms `vsqrt.f32` (real FPU instruction, not `__aeabi_d*` soft-float) and 82
  `vmul.f32` instances — same FPU win class as stm32f411/stm32h523.
- **Challenges (confirmed, not resolved this session — hardware bring-up items)**:
  - Register-level manual not reachable this session (only the datasheet's feature/electrical
    chapters, not the full register reference)
  - Non-standard peripheral library, register definitions not in CMSIS standard format
  - PCONR per-pin GPIO config bit layout, EFM flash controller bit fields, TIMER0/TIMERA control
    register layouts, and the INTC base address are all placeholder values needing hardware
    confirmation
- **Target use case**: High-performance CNC, multi-axis systems, industrial applications

### 5. ATSAMC21E18A (Microchip ARM)
- **Priority**: MEDIUM
- **Tracking note**: **not currently in PLAN.md's Phase 6 queue, and no directory exists yet** — this entry is aspirational/unscheduled, kept here as an idea rather than a commitment. If it's still wanted, it needs to be added to PLAN.md Phase 6 to actually happen.
- **Architecture**: ARM Cortex-M0+, 48MHz
- **Vendor**: Microchip (formerly Atmel)
- **Target board**: SAM C21 Xplained Pro
- **Memory**: 32KB RAM, 256KB Flash
- **Unique features**:
  - 5V tolerant I/O pins
  - CAN-FD support
  - Hardware CRC and AES encryption
  - Configurable Custom Logic (CCL)
  - Event System for autonomous peripheral operation
- **Challenges**:
  - M0+ has limited instruction set (no division, no FPU)
  - Atmel/Microchip register naming conventions differ from STM32
  - SERCOM peripheral requires more complex configuration
  - Different clock system (GCLK, generic clock generators)
- **Estimated code size**: ~26KB (M0+ has good code density)
- **Target use case**: Automotive, industrial with 5V legacy peripherals

---

## Implementation Priority

Per [PLAN.md](PLAN.md) (the authoritative queue — this list is kept in sync with it, not the other way around):

1. **CH32V006** (RISC-V) — ✅ DONE. Dedicated Phase 4 milestone, first port built strictly from `_template` + written contracts.
2. **Phase 6 rolling-ports queue** thereafter, revised as hardware/toolchain reality dictates:
   1. STM32F411 (ARM M4F) — ✅ DONE, see above
   2. dsPIC33AK128MC102 (third ISA family) — ✅ DONE (build/link), ✅ CI wiring landed 2026-07-26
   3. HC32F460 (ARM M4F, vendor-exotic — tests contract completeness) — ✅ DONE, see above
   4. SG2002 (RISC-V64 runtime core, Linux-adjacent) — scope DECIDED 2026-07-26: bare-metal blob
      only, Linux side out of scope; design DESIGN-COMPLETE/IMPLEMENTATION-DEFERRED per PLAN.md,
      current source tree is NON-FUNCTIONAL and needs a `_template` restart first
   5. CH570 (WCH RISC-V, QingKe V3C) — recon DONE, unblocked for porting, not yet started;
      cheaper than ch32v006 but shares only ~15-20% of its code (different peripheral IP
      entirely — see CONTRACTS.md and PLAN.md's ch570 entry)
   6. any new platform directory that appears

ATSAMC21E18A is not currently scheduled — see its tracking note above.

**Toolchain-gated, not in CI today**: CH570 hasn't landed as a port yet (no `grbl/platform/ch570/`
on `origin` as of 2026-07-26 — its toolchain story is unstarted, so no CI row is guessed for it;
see `ci.yml`'s marked TODO). dsPIC33AK128MC102 is no longer in this bucket — its CI wiring landed
2026-07-26 (dedicated job, cached+SHA-256-verified XC-DSC installer + DFP, EULA owner-approved for
unattended CI use); see PLAN.md Decision Log for the full writeup.

---

## Shared Code Reuse Strategy

Proven pattern so far is the STM32 family's `grbl/platform/common/stm32/` (not the `hal/common/*_common.c` naming this section previously described, which doesn't exist in the tree):

### Common Modules (platform-agnostic, STM32 family today):
- `common/stm32/stm32_timing.c` - timing abstraction shared across stm32f103/h523/f411
- `common/stm32/stm32_nvmem.c` + `stm32_flash.h` - Flash-based EEPROM emulation
- `common/stm32/stm32_watchdog.c` - Watchdog timer abstraction
- `common/stm32/common.mk` - shared Makefile rules

SAMD21 does not yet share code this way (its NVMEM/timing implementations are platform-local, `nvmem.c`/`platform.c`); folding common patterns across architectures (not just within the STM32 family) is PLAN.md Phase 2's `_template` platform effort.

### Platform-Specific Modules:
- `config.h` - Pin mappings, clock frequencies, peripheral assignments
- `platform.c` - HAL implementation (GPIO, interrupts, clocks)
- `regs.h` - Minimal register definitions
- `startup.c` - Vector table and reset handler
- `handlers.c` - Interrupt handlers
- `flash.c` - Flash programming for NVMEM
- `script.ld` - Linker script
- `Makefile` - Build configuration

### Code Reuse (measured, not estimated, for every port that is actually built):
- CH32V006: DONE. RISC-V — no ARM/AVR donor code shared; only `common/` GPIO helper patterns.
- HC32F460: ~0% code reuse in practice — no peripheral IP shared with any donor port; only the
  ARM Cortex-M startup/VTOR/FP=SINGLE *mechanisms* (not code) transferred. Clean-room
  `regs.h`/`gpio.h`/`timer.h`/`platform.c`.
- STM32F411: high, via existing stm32_common (same family as stm32f103/h523)
- dsPIC33AK128MC102: low — new ISA family, mostly new code plus the macro contract layer

---

## Next Steps

See [PLAN.md](PLAN.md) for the authoritative, continuously-updated phase list. Phases 0-4 are
CLOSED (CI foundation, injection canon, macro contracts + `_template`, SAMD21 closure incl. Renode
motion proof, CH32V006 as the first template-built port). Phase 5's positioning items are landed
(README "Why this fork", this truth-update); its one remaining checkbox is tagging v0.x itself —
an owner action, not something this repo can do for you. Phase 6 (rolling ports) is a standing
loop, not a closeable phase: STM32F411/dsPIC33AK128MC102/HC32F460/CH32V006 are done, SG2002 is
deferred by design, CH570 is recon'd and queued, and any new platform directory joins the same
loop as it appears.

---

**See detailed implementation plans:**
- [CH32V006_PLAN.md](ch32v006/CH32V006_PLAN.md)
- HC32F460_PLAN.md — not written as a separate file; port status is tracked in this file's
  own HC32F460JETA entry above plus PLAN.md's Phase 6 rolling-ports section and `hc32f460/
  platform.md` (per-port notes, same pattern as stm32f411/platform.md)
- ATSAMC21_PLAN.md — not written yet (no directory exists)
- [SAMD21_PLAN.md](samd21/SAMD21_PLAN.md) — exists but stale; PLAN.md Phase 3 is authoritative over it
- [PLAN.md](PLAN.md) — the live orchestration ledger; authoritative for phase status and the current queue
