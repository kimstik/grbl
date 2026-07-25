# GRBL HAL Platform Roadmap

**Date**: 2026-07-24 (truth-updated against the tree; supersedes the 2025-11-19 estimates below, several of which had gone stale or were never true)
**Status**: Active development - multiple platforms in progress. **[PLAN.md](PLAN.md) is the live orchestration ledger** (single source of truth for phase-by-phase status); this file is the platform-facing overview and gets synced against it periodically, not the other way around.

This document outlines the planned platform ports and their implementation roadmaps.

---

## ARM Platforms (STM32) — ⚠️ builds currently broken

These were previously listed as "100% Complete / Production Ready". That was never actually verified by compiling the platforms — doing so now (and per the empirical Phase-1 recon in [PLAN.md](PLAN.md)) shows both fail to build. Tracked as the top of PLAN.md Phase 1.

### STM32F103C8 (Blue Pill)
- **Status**: 🔴 Build broken
- **Architecture**: ARM Cortex-M3, 72MHz
- **Memory**: 20KB RAM, 64KB Flash
- **Code reuse**: ~60% via stm32_common
- **What's broken**: `spindle_control.c` calls `PWM_SET`/`PWM_ENABLE`/`PWM_DISABLE`/`GPIO_BCLR`/`GPIO_BSET` on `SPINDLE_PWM`/`SPINDLE_DIRECTION`, none of which `platform.h` defines (it only defines `SPINDLE_PWM_PORT`/`_PIN`/`_TIMER`/etc. and `SPINDLE_DIRECTION_BIT`) — fails at `spindle_control.c:244: 'SPINDLE_DIRECTION' undeclared`. Also has `PLATFORM_NAME`/`sei`/`cli` redefinitions and a `LIMIT_DDR` self-collision (per PLAN.md Phase 1 recon).
- **Fix tracked**: [PLAN.md](PLAN.md) Phase 1

### STM32H523CBT6 (Black Pill H5)
- **Status**: 🔴 Build broken
- **Architecture**: ARM Cortex-M33, 250MHz
- **Memory**: 32KB RAM, 128KB Flash
- **Code reuse**: ~60% via stm32_common
- **What's broken**: the platform Makefile never sets `CFLAGS_EXTRA` (a copy/paste omission — stm32f103's Makefile does), so `-I../common/dummy` never lands on the command line and the very first file fails: `main.c: fatal error: avr/pgmspace.h: No such file or directory`.
- **Fix tracked**: [PLAN.md](PLAN.md) Phase 1

---

## In Progress Platforms

### SAMD21G18A (Arduino Zero / MKR) - HIGH PRIORITY
- **Status**: 🚧 ~95% complete — all peripherals implemented and datasheet-verified; never run on hardware yet
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
- **Build**: DEBUG (-O0 -g3) = 60,172 bytes text / 296 bytes data / 6,160 bytes bss. RELEASE (-Os -flto) = 39,184 bytes text (15.3% of 256KB flash). AVR golden checksum unaffected (`make -C grbl/platform/atmega328p validate` → PASSED).
- **Remaining before "ready for hardware"** (tracked as PLAN.md Phase 3, "SAMD21 Closure"):
  - ✅ `SysTick_Config()` is now called from startup (samd21/startup.c:211, landed) — the 1 kHz timebase drives `hal_millis()`/`hal_micros()` instead of leaving them frozen at 0.
  - ⏳ Suspected real ARM bug under investigation: core `settings.c`'s `get_step_pin_mask()` / `get_direction_pin_mask()` / `get_limit_pin_mask()` return `uint8_t`, but SAMD21 pin bit positions go above bit 7 (e.g. bit 25) — the masks truncate to 0 on this platform. Consumers and homing/limits impact not yet assessed.
  - ⏳ No Renode (or other) smoke test in CI yet — the "compiles but was FIRST EXECUTION PASSED in Renode 1.16.1 (boot -> banner -> $$ -> ok; ci/renode/, 2eb9429)" gap. Planned: boot binary → assert `Grbl 1.1h ['$' for help]` banner → `$$` settings dump → jog command ack.
  - ⏳ No hardware validation — this port has never been run on a physical chip. Once the Renode smoke test is green, this roadmap will mark it "ready for hardware validation" and hand off to the community.
- **Target use case**: Arduino-compatible CNC, educational, maker projects
- **See**: [SAMD21_PLAN.md](samd21/SAMD21_PLAN.md) (itself stale — treat [PLAN.md](PLAN.md) Phase 3 as authoritative over it), [PLAN.md](PLAN.md)

### SG2002 (Sophgo RISC-V)
- **Status**: 🚧 Work In Progress
- **Architecture**: RISC-V C906, 700MHz (RV64IMAFDC)
- **Vendor**: Sophgo
- **Memory**: 256MB DDR3
- **Target board**: LicheeRV Nano
- **Unique features**:
  - Dual-core: C906 (big) + C906 (little)
  - Linux-capable RISC-V
  - PLIC interrupt controller
  - High performance for complex G-code
- **Current status**: Platform structure ready (Makefile, startup.c, platform.c, handlers.c, regs.h, script.ld, avr shim all present); not in the CI build matrix yet — deferred to PLAN.md Phase 6 pending a RISC-V64 toolchain decision.
- **Target use case**: High-end CNC, complex multi-axis systems

---

## Continuous Integration

There was no CI when this roadmap was first written; there is now (landed 2026-07-23, `.github/workflows/`):

- **Build matrix** (`ci.yml`): one row per platform/board/build-flavor via a composite action (`.github/actions/build-platform`) — atmega328p (RELEASE only), stm32f103 × {DEBUG, RELEASE}, stm32h523 × {DEBUG, RELEASE}, samd21 × {megarm, generic} × {DEBUG, RELEASE} = 9 rows. It's a thin invoker: the platform Makefiles remain the actual build authority, CI just calls `make`. (The stm32f103/stm32h523 rows currently fail per the broken-build section above — that's expected until PLAN.md Phase 1 lands.)
- **Golden gate (BLOCKING)**: `make -C grbl/platform/atmega328p validate` runs on every push and fails the pipeline if the built `grbl.hex` MD5 drifts from the pinned golden hash (`79af184e67b27defd27a39309ac53563`, `grbl/platform/common/chk.py`). Verified locally in this worktree: **PASSED**, text=30640 bytes. This is the one gate that never gets waived — AVR byte-for-byte integrity is the project's core invariant.
- **Warning ratchet**: `ci/warn_ratchet.py` plus one `ci/warn_baseline_<platform>.txt` per platform. One-way ratchet (new warnings not already in the baseline fail CI) rather than a blanket `-Werror`, since the ARM baselines are still partly inspection-derived pending a first real CI run.
- **compile_commands.json**: `make compdb` (samd21) via `tools/gen_compile_commands.py`, preserving the `-include` injection chain so IDEs/clangd see what the build actually sees.
- **Provenance (weekly, report-only)**: `provenance.yml` clones live `gnea/grbl` tag `v1.1h.20190825` fresh and rebuilds both trees with the same toolchain/flags in one job, then byte-diffs `.text`. **Empirical result** (same avr-gcc 7.3.0, no LTO): the two `.text` sections differ by exactly **2 bytes** — the `GRBL_VERSION_BUILD` date string (`"20190825"` upstream vs `"20190830"` in `grbl/grbl.h` here). Every other byte of machine code is identical. This job doesn't gate CI (the golden-hash check above does); it's an ongoing proof that the golden hashes themselves stay upstream-derived instead of silently drifting into an undocumented fork.

---

## Planned Platforms

### 1. STM32F411CEU6 ("Black Pill", ARM Cortex-M4F)
- **Priority**: HIGH — first item in PLAN.md's Phase 6 rolling-ports queue; toolchain already in CI and large reuse expected via stm32_common
- **Architecture**: ARM Cortex-M4F, 100MHz
- **Memory**: 128KB RAM, 512KB Flash
- **Current status**: directory scaffolded (`avr/` shim + a `platform.h` skeleton) — no Makefile, startup.c, or platform.c yet; not a real port
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
- **Toolchain note**: XC-DSC isn't apt-installable; CI plan is a cached Microchip silent-mode installer, falling back to build-only-local with a ledger note if that doesn't pan out (same pattern already used for CH32V006).
- **Current status**: chip selected, nothing built yet — no directory exists
- **Target use case**: CNC/motor-control applications wanting a hardware FPU and purpose-built motor PWM in a 328p-sized footprint

### 3. CH32V006 (RISC-V Microcontroller)
- **Priority**: HIGH — has its own dedicated milestone, PLAN.md **Phase 4** ("fresh port by the new rules"), which runs *before* the Phase 6 rolling-ports queue above. It's the first port meant to be built strictly from the `_template` skeleton + written macro contracts (PLAN.md Phase 2), once those exist.
- **Architecture**: RISC-V RV32EC, 48MHz
- **Vendor**: WCH (Nanjing Qinheng Microelectronics)
- **Target board**: CH32V003F4P6 development board
- **Memory**: 2KB RAM, 16KB Flash
- **Current status**: directory scaffolded (`CH32V006_PLAN.md`, `avr/io.h` shim, a `platform.h` skeleton) — no Makefile, startup.c, or platform.c yet; not a real port
- **Unique features**:
  - First RISC-V port of GRBL
  - Ultra low-cost ($0.10 in volume)
  - 32-bit RISC-V core in 8-pin package
  - Built-in USB and UART bootloader
- **Challenges**:
  - RISC-V toolchain setup (riscv-none-elf-gcc)
  - Different interrupt model (ECLIC vs NVIC)
  - Very limited RAM (2KB) - requires careful memory optimization
  - No FPU (emulated floating point)
- **Estimated code size**: ~20KB (fits in 16KB with LTO optimization)
- **Target use case**: Ultra-low-cost CNC controllers, educational projects

### 4. HC32F460JETA (High-Performance ARM)
- **Priority**: MEDIUM — third item in PLAN.md's Phase 6 queue
- **Architecture**: ARM Cortex-M4F, 200MHz
- **Vendor**: HDSC (Huada Semiconductor)
- **Target board**: Small System HC32F460 development board
- **Memory**: 192KB RAM, 512KB Flash
- **Current status**: directory scaffolded (`avr/` shim + a `platform.h` skeleton) — no Makefile, startup.c, or platform.c yet; not a real port
- **Unique features**:
  - High RAM (192KB) - largest of all current platforms
  - Hardware FPU (single precision)
  - Advanced motor control peripherals
  - CAN-FD support
  - 12-bit ADC with up to 24 channels
- **Challenges**:
  - Limited documentation (mostly Chinese)
  - Less common toolchain
  - Non-standard peripheral library
  - Register definitions not in CMSIS standard format
- **Estimated code size**: ~28KB
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

1. **CH32V006** (RISC-V) — dedicated Phase 4 milestone, comes right after Phases 0-3 (CI foundation, injection canon, macro contracts, SAMD21 closure) finish
2. **Phase 6 rolling-ports queue** thereafter, revised as hardware/toolchain reality dictates:
   1. STM32F411 (ARM M4F, toolchain already in CI, large stm32_common reuse expected)
   2. dsPIC33AK128MC102 (third ISA family, XC-DSC toolchain now free)
   3. HC32F460 (ARM M4F, vendor-exotic — tests contract completeness)
   4. SG2002 (RISC-V64, Linux-class — bare-metal vs. Linux userspace scope still to be decided)
   5. any new platform directory that appears

ATSAMC21E18A is not currently scheduled — see its tracking note above.

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

### Expected Code Reuse (unbuilt platforms — estimates, not measured):
- CH32V006: 40% (RISC-V architecture different)
- HC32F460: 50% (ARM but different vendor)
- STM32F411: high, via existing stm32_common (same family as stm32f103/h523)
- dsPIC33AK128MC102: low — new ISA family, expect mostly new code plus the macro contract layer

---

## Next Steps

See [PLAN.md](PLAN.md) for the authoritative, continuously-updated phase list. Current top items:

1. **Phase 1** — collapse the four `-include` flags into one `prelude.h` per platform; fix the stm32f103/stm32h523 build breaks documented above
2. **Phase 2** — write down macro interface contracts (pre/post-conditions, atomicity, memory-ordering) and materialize them as a `_template` platform skeleton
3. **Phase 3** — close out SAMD21: wire up SysTick, investigate the pin-mask truncation, add a Renode smoke test, then mark it ready for community hardware validation
4. **Phase 4** — port CH32V006 from `_template` + contracts alone, as the first real test of the new process
5. **Phase 5** — positioning/release (README "Why this fork" section already landed; tag a v0.x once Phases 1-4 close)
6. **Phase 6** — rolling ports thereafter: STM32F411, dsPIC33AK128MC102, HC32F460, SG2002, and any new platform directory that appears

---

**See detailed implementation plans:**
- [CH32V006_PLAN.md](ch32v006/CH32V006_PLAN.md)
- HC32F460_PLAN.md — not written yet (directory only has a `platform.h` skeleton)
- ATSAMC21_PLAN.md — not written yet (no directory exists)
- [SAMD21_PLAN.md](samd21/SAMD21_PLAN.md) — exists but stale; PLAN.md Phase 3 is authoritative over it
- [PLAN.md](PLAN.md) — the live orchestration ledger; authoritative for phase status and the current queue
