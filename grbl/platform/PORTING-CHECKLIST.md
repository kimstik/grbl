# GRBL Porting Checklist

Ordered steps for bringing up a new platform. Every step names its exit test.
Contracts for each macro family: `CONTRACTS.md` (section numbers cited as §N).
Do steps in order — each layer's exit test depends on the previous layer.

Ground rules (PLAN.md, standing laws):
- Copy the `_template` skeleton (planned) (or the closest existing port) —
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
- [ ] Flash wait states before raising the clock (samd21/startup.c:138).

Exit: LED-blink or busy-loop binary runs at verified speed (scope a GPIO
toggle, or emulator cycle count).

## Step 2 — GPIO

- [ ] Board config: `*_PORT/_BIT/_MASK` for STEP, DIRECTION, STEPPERS_DISABLE,
      LIMIT, CONTROL, PROBE, SPINDLE_*, COOLANT_* (megarm/config.h as model).
      **Input groups (LIMIT/CONTROL/PROBE) must land in bits 0-7** or be
      remapped in accessors — core truncates reads to uint8_t (§1.3).
- [ ] Register accessors `GPIO_OREG/IREG/DREG/PREG` if platform layout differs
      from AVR naming (samd21/gpio.h:15-18). Pull-up accessor must actually
      enable pull-ups (§1.4 — SAMD21 got this wrong).
- [ ] Audit `GPIO_MWO`/`GPIO_BSET` RMW atomicity for registers shared between
      mainline and ISR writers; use hardware set/clear registers if needed (§1.2).

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
4. **Ratchet clean**: `ci/warn_ratchet.py` passes against a committed
   `ci/warn_baseline_<name>.txt`; baseline may only shrink.
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
