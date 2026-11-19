# GRBL Porting Checklist

Ordered steps for bringing up a new platform. Every step names its exit test.
Contracts for each macro family: `CONTRACTS.md` (section numbers cited as §N).
Do steps in order — each layer's exit test depends on the previous layer.

Ground rules (PLAN.md, standing laws):
- Copy the `_template` skeleton (landed, PORT_TODO_*-driven) (or the closest existing port) —
  never start from a blank directory. Reuse `common/` and
  `common/stm32/common.mk`-style sharing before writing anything new.
- NO silent no-op stubs. Unimplemented macro = call to undeclared
  `PORT_TODO_<name>()` so the port compiles immediately but links only when
  complete (linker-as-checklist).
- Core files in `grbl/*.c|h` are untouchable. All porting lives in
  `grbl/platform/<name>/`.

## Step 0 — Skeleton and build plumbing

- [ ] `grbl/platform/<name>/`: Makefile, platform.h, gpio.h, timer.h,
      startup/vector code, linker script, `<board>/config.h`.
- [ ] **Check `common/` before writing any of these from scratch** — several
      pieces are already shared and byte-identity-proven across ports
      (CONTRACTS.md
      [§cross-arch-dedup-byte-invariance](CONTRACTS.md#cross-arch-dedup-byte-invariance)):
      `common/cortexm/cortexm_critical.h` (Cortex-M `sei`/`cli` +
      `HAL_CRITICAL_SECTION_*`, include it from your `prelude.h`),
      `common/wch/wch_critical.h` (QingKe RISC-V equivalent),
      `common/stm32/stm32_timer.h` (the whole `timer.h` for an STM32 port),
      `common/serial_ring_accessors.h` and `common/nvmem_checksum.h` (the
      chip-agnostic halves of a TU-replacement `serial.c`/`nvmem.c`).
      **Do not create a `<port>/avr/io.h`** — the shared
      `common/dummy/avr/io.h` is enough once your prelude defines `sei`/`cli`
      before `grbl.h`; a local copy exists only to win an `-I` race and is
      exactly the invisible duplication that batch removed.
- [ ] Makefile follows the samd21 pattern (samd21/Makefile): core sources
      listed explicitly; a single `-include $(BOARD)/prelude.h`
      (samd21/Makefile:30) — the injection order is documented inside
      `prelude.h` itself, not the Makefile. Decide per subsystem: macro route
      vs TU-replacement route (CONTRACTS.md §0) and set GRBL_SOURCES
      accordingly.
- [ ] `make BUILD=DEBUG` and `make BUILD=RELEASE` compile all objects
      (link may still fail on PORT_TODO symbols — that is the checklist).

Exit: object files build; undefined `PORT_TODO_*` symbols enumerate the
remaining work by name.

**Non-ARM core?** `_template/startup.c`'s vector table is ARM Cortex-M
hardware-vector-fetch specific (CONTRACTS.md #14, added after the
ch32v006/RISC-V port) - it does not transfer to RISC-V or any other ISA
without hardware SP/PC autoload from a data table. Read
`ch32v006/startup.c` for a worked non-ARM alternative and CONTRACTS.md
#14 for the full gap list (toolchain flags, `-specs=picolibc.specs`
silently re-enabling `--gc-sections` and defeating the "just omit it"
strategy below, the GPIO 4-bit-packed-config-register pattern, etc).

## Step 1 — Clock

- [ ] Startup code: vector table, `.data` copy, `.bss` zero — with `__DSB()`
      between phases on ARM (samd21/startup.c:184-194).
- [ ] System clock to the frequency you pass as `F_CPU` in the Makefile.
      `F_CPU` feeds `TICKS_PER_MICROSECOND` (nuts_bolts.h:47) and all stepper
      timing math — a lie here breaks every later step invisibly.
- [ ] **`-DF_CPU=$(CLOCK)ULL` — always `ULL`, never `UL` or unsuffixed,
      regardless of how low your `CLOCK` is today** (CONTRACTS.md
      [§clock-constant-width](CONTRACTS.md#clock-constant-width), BUG #18
      class). `stepper.c:1015` folds `TICKS_PER_MICROSECOND*1000000*60` at
      compile time, in F_CPU's own type; `unsigned long` (`UL`) is 32-bit on
      every ILP32 target this tree ships for and wraps **silently** above
      ~71.58 MHz — unsigned overflow is well-defined wraparound, so
      `-Woverflow` never fires, and there is no other diagnostic. `UL` at a
      48 MHz launch clock looks correct and stays correct only until the
      next board revision (a different crystal, a faster silicon variant)
      raises `CLOCK` past the threshold — do not reason "my clock is low, so
      UL is fine": that reasoning is exactly what BUG #18 recurred from once
      already. `grbl/platform/common/clock_width.h`, included from every
      port's `prelude.h`, `_Static_assert`s the WIDTH of the `F_CPU` token
      (`sizeof(F_CPU) >= 8`) — it will catch a stray `UL` at compile time,
      but the rule exists so you never need it to.
- [ ] Flash wait states before raising the clock (samd21/startup.c:138).

Exit: LED-blink or busy-loop binary runs at verified speed (scope a GPIO
toggle, or emulator cycle count).

## Step 2 — GPIO

- [ ] Board config: `*_PORT/_BIT/_MASK` for STEP, DIRECTION, STEPPERS_DISABLE,
      LIMIT, CONTROL, PROBE, SPINDLE_*, COOLANT_* (megarm/config.h as model).
      **Input groups (LIMIT/CONTROL/PROBE) must land in bits 0-7** or be
      remapped in accessors — core truncates reads to uint8_t (§1.3).
- [ ] **Exactly one file owns each pin's `_PORT`/`_PIN`/`_BIT`/`_MASK`
      number** (BUG #25 — CONTRACTS.md anchor `gpio-pin-map-single-owner`;
      not linked here as a real markdown link for the same `§NEW`-pending-
      renumbering reason as the BUG #24 item below). If your chip has
      exactly one board (the stm32f103/f411/h523 shape, CONTRACTS.md
      [§boundary-wiring](CONTRACTS.md#boundary-wiring)), that owner is
      `platform.h` — do not also give `config.h` a copy of the same pin
      numbers "for reference" or "to customize per project": an unguarded
      second `#define` of the same macro name compiles silently (C allows
      redefinition; GCC only warns when the two token sequences actually
      differ), and if the two ever disagree, **which one wins depends on
      per-translation-unit `#include` order**, not on which file a human
      reads last. This shipped for real: `stm32f103`/`stm32h523` had
      `SPINDLE_ENABLE_PIN` defined 7 in `config.h`, 12 in `platform.h` —
      `platform.c` (which includes `platform.h` then `config.h`) configured
      pin 7 as an output; every core `.c` file (which reaches `platform.h`
      last through `grbl.h`) drove pin 12 via `GPIO_BSET`/`GPIO_BCLR` —
      neither pin ever worked. If your chip genuinely has more than one
      board (or will), the correct shape is a per-board `boards/<name>/
      config.h` selected via that board's own `prelude.h`, chained
      `gpio.h -> common/gpio.h -> config.h -> platform.h`
      (samd21/ch32v006/ch570 are the reference) — not a second file living
      beside a single-board `platform.h`. Verify with the real preprocessor,
      not by reading the `#include` order and reasoning about it:
      `<cc> -E -dM <file>.c | grep <PIN_MACRO>` on both `platform.c` and one
      core `.c` file (e.g. `spindle_control.c`) must print the SAME value.

      **STEP, DIRECTION, LIMIT, CONTROL and PROBE are the five truncation-risk
      groups — every one of their `*_BIT` constants must land in bits 0-7**
      (core narrows each to `uint8_t`: the ISR port image for STEP/DIRECTION,
      `GPIO_MRD(name, IREG)` for LIMIT/CONTROL/PROBE, PLUS `settings.c`'s
      `get_limit_pin_mask()` as a second, easy-to-miss LIMIT consumer — §1.3,
      [§limit-bit-width-second-consumer](CONTRACTS.md#limit-bit-width-second-consumer)).
      SPINDLE_*/COOLANT_*/STEPPERS_DISABLE are NOT in this class (single-bit
      `GPIO_BSET/BCLR/BGETOUT` ops on the native register width — never
      narrowed; don't spend an assert on them). **Answer width per GROUP, not
      per port**: if a group's physical pins already fit bits 0-7, add a
      `_Static_assert(<name>_BIT <= 7, ...)` next to the pin defines (zero
      cost, every port in this tree does this today). If they don't — and you
      cannot just move the pin (a fixed header layout, a shared physical pin
      with another signal, etc. — check first: BUG #26 shows a free low bit is
      often the simpler fix when nothing is soldered yet) — reach for
      `common/gpio_logical.h`'s `GPIO_LOGICAL_DISPATCH_*`/`GPIO_LOGICAL_PASSTHRU_*`
      macros: define that group's `_L2P`/`_P2L`/`_MASK_PHYS` and a
      `GPIO_..._<NAME>()` override, following samd21/gpio.h or ch570/gpio.h as
      a model (the latter also shows the trap when the SAME group's mask
      feeds a real hardware interrupt-arm call, not just a core-visible
      compare — see [§logical-contract-vs-constraint-cure](CONTRACTS.md#logical-contract-vs-constraint-cure)
      for the full worked example before you copy either pattern blindly).
- [ ] Register accessors `GPIO_OREG/IREG/DREG/PREG` if platform layout differs
      from AVR naming (samd21/gpio.h:15-18). Pull-up accessor must actually
      enable pull-ups (§1.4 — SAMD21 got this wrong).
- [ ] Audit `GPIO_MWO`/`GPIO_BSET` RMW atomicity for registers shared between
      mainline and ISR writers; use hardware set/clear registers if needed (§1.2).
- [ ] **Every port your board's `*_PORT` macros name has its bus clock
      enabled before first use** (BUG #24 — see CONTRACTS.md's
      "A configured, wired GPIO pin still does nothing if its PORT's bus
      clock was never gated on" section, anchor `gpio-port-clock-gating`;
      not linked here as a real markdown link because its heading is
      still `§NEW` pending integrator renumbering, and
      `check_contracts_numbering.py` does not register a `§NEW` section's
      anchor as a valid cross-file link target until then) — on
      every ARM/RISC-V family here, a GPIO port sits behind its own bit in
      a peripheral clock-enable register (STM32 `RCC->APB2ENR`/`AHBxENR`
      IOPxEN/GPIOxEN, CH32V00x `RCC->PB2PCENR` IOPxEN), and a gated port
      reads back zero and ignores every write regardless of how correctly
      the rest of the GPIO code is written. `ch32v006` shipped with STEP/
      DIRECTION/STEPPERS_DISABLE/COOLANT (GPIOC) and CONTROL (GPIOB) wired
      and configured correctly but never clock-gated — dead pins on real
      silicon, invisible to every other gate (link, golden AVR, warning
      ratchet, `assert_no_double.sh`, even BUG #23's `init_check.sh`, which
      proves your clock/GPIO bring-up function *runs*, not which bits it
      sets). Derive the enable mask from the same `*_PORT` macros the pin-
      config code already consumes (a small pointer-dispatch helper, see
      `ch32v006/platform.c`'s `gpio_port_clken()`) rather than a hand-typed
      literal — a literal silently goes stale the moment a re-pin adds a
      port nobody remembers to add to it. This is NOT `_Static_assert`-able
      (`*_PORT` are runtime pointer values, not preprocessor tokens); do
      the derivation as real code and prove it ran via
      `common/init_check.sh` (tag the enabling function `GRBL_BOOT_INIT`,
      add it to `INIT_SYMBOLS`) — that proves reachability, not mask
      completeness, so re-check this box by hand on every re-pin.

Exit: test main() drives STEP/DIR pins, reads a jumpered LIMIT pin high/low
with pull-up on/off.

## Step 3 — Timers (stepper, pulse-reset, PWM)

- [ ] Verify every candidate timer HAS an interrupt line before allocating
      it — "general purpose timer" does not imply one (CH32V006's TIM3 is
      compare-only, no IRQ; its pulse-reset timer is the SysTick-class
      counter instead — CONTRACTS.md §14.11).
- [ ] `STP_TMR_*` per §3. `STP_TMR_PRESCALER_SET/RESET`: implement, or
      `#error` on non-AMASS builds — never empty (§3, the cautionary tale).
- [ ] `STP_PULSE_RESET_*` per §4. Honor the 8-bit overflow horizon and the
      F_CPU/8 tick: pulse width must equal `settings.pulse_microseconds`.
- [ ] `ISR_STEP/ISR_STEP_RESET/ISR_STEP_DELAY` wrappers: clear INTFLAG first,
      then call body (§5, handlers.c:30-47). Pulse-reset IRQ priority above
      stepper IRQ where the NVIC allows (§5.2).
- [ ] `PWM_*` per §6; `SPINDLE_PWM_MAX_VALUE` <= 255 (core duty is uint8_t).

Exit: scope/emulator shows step pulses of configured width at commanded rate,
including a slow (<250 Hz) rate with AMASS disabled — the prescaler test.
PWM duty 0/half/full measured.

## Step 4 — Serial

- [ ] Macro route (grbl/serial.c) or TU replacement (samd21/serial.c) per §7.
- [ ] Baud divisor verified at 115200 against the datasheet (BUG #4 class).
- [ ] Ring-buffer ordering: DMB or interrupt-mask bracket on every
      producer-side head publish (§7, BUG #12).
- [ ] RX ISR consumes the data register (clears the flag); TX ISR self-disables
      when the buffer drains.

Exit: echo test; then `Grbl 1.1h ['$' for help]` banner and `$$` settings dump
over the real UART (or Renode).

## Step 5 — NVMEM

- [ ] Four-function API per §10 (usually TU replacement; AVR-style true EEPROM
      may use core nvmem.c).
- [ ] `__DSB()` between page-buffer fill and commit command; poll READY after
      every erase/write (§10.5, BUG #13).
- [ ] Skip-write-if-equal wear guard (§10.3).
- [ ] Same checksum function in write and read paths (§10.4); do not import
      the AVR `||` quirk into new code, and never fix it on AVR.

Exit: `$100=123.456`, power-cycle (or emulator reset), `$$` shows the value;
corrupt one byte, boot reports checksum failure and loads defaults.

## Step 6 — Handlers and integration

- [ ] `HAL_GPIO_IRQ_HANDLER` wiring: core bodies (limits.c:107, system.c:64)
      reached from your vector; flags cleared first; shared-vector dispatch
      hits both groups (§2).
- [ ] `GPIO_INT_ON/OFF` functional at runtime — homing must actually silence
      the hard-limit interrupt (§2.1).
- [ ] `HAL_CRITICAL_SECTION_BEGIN/END`: save/restore implementation, never
      empty (§8).
- [ ] `sei`/`cli` with memory clobber (§11).
- [ ] `_delay_us/_delay_ms` real implementations (samd21/platform.c:169-214
      is the reference; the earlier empty stubs broke homing/spindle ramp
      silently — the "compiles but dead" class).
- [ ] `HAL_WATCHDOG_*`: leave undefined unless implementing
      ENABLE_SOFTWARE_DEBOUNCE properly (§9).

Exit: full grbl binary: jog moves, limit pin triggers ALARM, control pins
(feed hold / cycle start / reset) act, `?` status reports sane positions.

## Weak-memory checklist (ARM / RISC-V — run before calling any step done)

From CONTRACTS.md §12; every box is a shipped-bug class:

- [ ] Every ring-buffer head publish preceded by DMB/release or bracketed by
      masking the consumer interrupt (BUG #12; samd21/serial.c:96-105,172)
- [ ] No `volatile` RMW shared with an ISR outside a critical section
- [ ] Every ISR wrapper clears its own INTFLAG bit (write-1-to-clear: only
      that bit) BEFORE calling the core body
- [ ] `__DSB()` before every flash/NVM commit command and between startup
      init phases (BUG #13)
- [ ] Every SYNCBUSY-class wait has its peripheral clock verifiably running
      (else: infinite hang, "compiles but dead")
- [ ] Interrupt enable/disable asm carries `"memory"` clobber
- [ ] IRQ priorities set explicitly: pulse-reset >= stepper; serial must not
      starve the stepper pair

## Definition of done

All of the following, in this order:

1. **Builds**: `make BUILD=DEBUG` and `make BUILD=RELEASE` succeed in
   `grbl/platform/<name>/`.
2. **Links**: zero `PORT_TODO_*` undefined symbols; no silent no-op remains
   (grep the platform headers for empty macro bodies of contract macros).
3. **Golden AVR untouched**: `make validate` at repo root passes — grbl.hex
   MD5 `79af184e67b27defd27a39309ac53563` (Makefile:109-121). Any port change
   that shifts this is rejected, full stop.
4. **Ratchet clean**: `.github/ci/warn_ratchet.py` passes against a committed
   `.github/ci/warn_baseline_<name>.txt`; baseline may only shrink.
4a. **Boot-init reachability declared**: your Makefile sets `INIT_SYMBOLS`
   (comma-separated) and runs `../common/init_check.sh $(PREFIX)nm $@
   $(INIT_SYMBOLS)` right after the no-DP assert in the link rule — the STM32
   family gets a working default from `common/stm32/common.mk`, everyone else
   declares their own. List every function that must run before `main()`:
   your `Reset_Handler` (or the toolchain's crt0 entry), and each clock/GPIO
   bring-up function it reaches. Tag each of those `GRBL_BOOT_INIT`
   (`common/boot_init.h`) at BOTH the declaration and the definition.
   **This is not paperwork**: four landed ports shipped a complete bring-up
   chain that nothing called, LTO deleted all of it, and they booted on the
   reset-default clock with unconfigured GPIO — every other gate passed. See
   CONTRACTS.md [§27](CONTRACTS.md#boot-init-unreachable) / PLAN.md BUG #23.
   Core `grbl/main.c` will never call your init; the call must come from
   your `Reset_Handler`, before `main()`.
5. **CI matrix row added**: one `include:` row per build flavor in
   `.github/workflows/ci.yml` (platform/board/build/toolchain-packages —
   existing rows are the template). CI is a thin invoker; all build knowledge
   stays in your Makefile.
6. **Contract feedback folded back**: every gap you discovered while porting
   is a diff to CONTRACTS.md / `_template`, committed with the port
   (PLAN.md Phase 4 law: each port strengthens the system).
7. Smoke test where emulation exists (Renode class): boot banner + `$$` + jog
   ack. Hardware validation is delegated to the community; mark the port
   "ready for hardware validation" in PLATFORM_ROADMAP.md.
8. **Artifact baseline reviewed**: run `python3 tools/build_artifacts.py check
   --platforms <name>` (both `samd21-megarm,samd21-generic` for that port).
   Review generated outputs and update affected hashes in
   `.github/ci/artifacts.sha256` only for intentional code-generation changes.
   See [the artifact contract](CONTRACTS.md#build-artifacts-tracked).

## Artifact refresh policy

`artifacts/` is ignored scratch output, generated by the existing build tool
and uploaded by Actions, not committed. `build` generates outputs without
changing the expected baseline; `check` generates them and fails on hash
drift. Both support `--platforms` and `--skip-debug`; use `--with-elf` to
include RELEASE ELF for downloads (Actions does this on every RELEASE row).

When accepting a source/toolchain change, review the generated files and
copy the affected RELEASE/DEBUG entries from `artifacts/MANIFEST.sha256` to
`.github/ci/artifacts.sha256`. Preserve all other units' entries. Do not
refresh hashes for documentation-only changes. No generated binary or ELF
is committed at tag time; release builds use the same generated downloads.
