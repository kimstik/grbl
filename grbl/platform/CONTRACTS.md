# GRBL Platform Macro Contracts

Definitive interface contract for every macro the GRBL core consumes across the
platform boundary. Facts below are derived from the actual sources; every claim
carries a `file:line` citation. Name mapping history (HAL_TIMER_* -> STP_*/PWM_*)
lives in `common/timer.md` — not repeated here.

Reference implementations cited per macro:
- **AVR** = semantic origin, `atmega328p/` (+ root `Makefile` golden build)
- **SAMD21** = ARM Cortex-M0+ adaptation, `samd21/`

Legend for the **Context** field:
- `init` — called once from mainline before `sei()` (main.c:42-48)
- `main` — mainline, interrupts enabled
- `ISR` — called from interrupt context
- `ISR-hot` — inside the stepper ISR path; budget is the 33.3 us tick at 30 kHz
  (stepper.c:318-320). No unbounded waits. Short bounded hardware sync
  (SYNCBUSY-class, a few peripheral-clock cycles) is acceptable.

Legend for **No-op**:
- `ILLEGAL` — an empty expansion compiles but silently breaks machine behavior
- `conditional` — legal only under the stated condition, and then only if the
  build fails loudly when the condition does not hold (`#error`/`_Static_assert`)

**The cautionary tale** (why this file exists): `STP_TMR_PRESCALER_SET` on SAMD21
is an empty comment macro (samd21/timer.h:68). It compiles, links, and destroys
the AVR semantic "prescaler change takes effect for the next segment" — slow
segments would run 8-64x too fast in a non-AMASS build. No silent no-op stubs,
ever. A port that cannot implement a macro must fail at link time
(`PORT_TODO_<name>()` pattern, PLAN.md Phase 2), not at the machine.

---

> **APPENDING A NEW SECTION? READ THIS FIRST — numbering collisions have
> bitten this file four times.** Parallel agents each read the current
> highest `## N.` and pick "the next number" — when more than one agent is
> authoring at once, they all compute the same N and the integrator has to
> renumber by hand at merge time, which silently breaks anyone else's
> `§N`/`section N` cross-reference into the section that got moved.
>
> **The fix: numbering is the integrator's job, not yours.**
> 1. Append your new section at the very end of the file, heading it
>    `## §NEW. Your Title` (the literal placeholder text `§NEW`, not a
>    guessed number). The integrator renumbers it to the real next N at
>    merge time — that is a rename-only edit and never collides.
> 2. Give it a stable slug anchor right above the heading:
>    `<a id="your-topic-slug"></a>` on its own line, then `## §NEW. Your
>    Title` on the next. Pick a short kebab-case slug describing the
>    *topic*, not the number (e.g. `cross-core-cache-coherency`, not
>    `section-23`) — the slug is permanent even when the number moves.
> 3. When you need to cite another section, cite it by slug, not by
>    number — write a real markdown link whose target is that section's
>    anchor id (e.g. a link reading "§N" whose href is
>    "hash-mark-that-sections-slug"). Copy the slug from that section's
>    `<a id="...">` line right above its heading. A bare `§N` or
>    `section N` with no slug link is a latent bug the moment anything
>    gets renumbered — it silently points at whatever the integrator moved
>    into that slot.
> 4. Before you cite a section, `grep '<a id="' CONTRACTS.md` to get the
>    real slug — do not guess it from the title.
> 5. `tools/check_contracts_numbering.py` (wired into CI) fails the build
>    on duplicate/non-sequential `## N.` numbers, a heading missing its
>    anchor, or a link whose slug has no matching anchor anywhere in the
>    file — run it before you open a PR that touches this file.

---

<a id="boundary-wiring"></a>
## 0. How the boundary is wired

Phase 1 landed: every platform now injects its whole macro chain via ONE
`-include`, not a hand-maintained flag list.

- AVR: root Makefile `-include grbl/platform/common/gpio.h` (Makefile:53);
  `grbl.h:49` includes `platform/hal.h`, which pulls `atmega328p/platform.h`
  (hal.h:168-169) and `atmega328p/timer.h` (platform.h:14). Pin names come from
  `cpu_map.h` (grbl.h:53).
- SAMD21: `samd21/Makefile:30` injects a single
  `-include $(BOARD)/prelude.h`. `prelude.h` chains, in this load-bearing
  order (`$(BOARD)/prelude.h:36-39`): platform `gpio.h` -> `common/gpio.h` ->
  `config.h` -> `platform.h`. Platform accessor overrides MUST precede
  `common/gpio.h` (its defaults are `#ifndef`-guarded, common/gpio.h:32-50).
  ch32v006, ch570, dspic33ak128mc102 and `_template` all follow this same
  4-step shape (a per-board `prelude.h` chaining gpio.h -> common/gpio.h ->
  config.h -> platform.h) because those platforms have more than one board
  (or are designed to, in `_template`'s case) and `config.h` is the
  per-board pin map that has to be selectable independently of the chip's
  own `platform.h`.

- **stm32f103 / stm32f411 / stm32h523 / hc32f460: a legitimate 2-step
  chain, not a broken 4-step one.** `stm32f103/Makefile` (and its f411/h523/
  hc32f460 siblings) inject a single `-include prelude.h` same as SAMD21,
  but that `prelude.h` chains only `gpio.h -> ../common/gpio.h`
  (`stm32f103/prelude.h:31-32`, `hc32f460/prelude.h:30-31`) - it does NOT
  also chain a `config.h`/`platform.h` pair. These four platforms have
  exactly ONE board each (no per-board pin-map selection to inject), so
  `platform.h` (which already `#include`s the pin map directly, e.g.
  `stm32f103/platform.h`'s own board section) arrives through the
  ORDINARY, un-injected include chain instead: `grbl.h` -> `platform/hal.h`
  -> `stm32f103/platform.h` (hal.h's `PLATFORM_STM32F103` branch, same
  routing every platform uses for its own `platform.h`). The single
  `-include prelude.h` here exists ONLY to get `gpio.h`/`common/gpio.h`
  ordering right before any core `.c` file's own includes run - the same
  load-bearing reason SAMD21's prelude puts `gpio.h` first, just with two
  fewer links in the chain because there is no per-board `config.h` to
  select. If you are auditing one of these four ports against the 4-step
  description above and it looks incomplete, it isn't - check which shape
  applies before flagging a gap.

Two compliance routes per subsystem:
- **Macro route**: core .c file is compiled; platform supplies macros (AVR serial).
- **TU-replacement route**: core .c file is excluded from the build and the
  platform supplies the whole translation unit honoring the core header API
  (SAMD21 `serial.c` and `nvmem.c`; samd21/Makefile:55-60 omits core `serial.c`,
  `nvmem.c`, `eeprom.c`). Both routes are legal; the contract then attaches to
  the header API and the concurrency semantics, not to macro names.

**Golden invariant**: on AVR every macro must expand to byte-identical original
code. `make validate` checks `grbl.hex` MD5 `79af184e67b27defd27a39309ac53563`
(Makefile:109-121). Any AVR-visible change to these macros is rejected.

---

<a id="gpio-data"></a>
## 1. GPIO — data / direction / pull-up (`GPIO_M*`, `GPIO_B*`, `GPIO_DIR_*`)

Defined in `common/gpio.h`. Composition: macros take a NAME (e.g. `LIMIT`,
`STEP`, `COOLANT_FLOOD`) and paste `name##_PORT/_BIT/_MASK` plus register
accessors `GPIO_OREG/IREG/DREG/PREG(name)` (common/gpio.h:36-50, redefinable
per platform — SAMD21: samd21/gpio.h:15-18 maps to `PORT->Group[...].OUT/IN/DIR/CTRL`).

| Macro | Semantics | Context | Core use sites |
|---|---|---|---|
| `GPIO_MWO(name, val)` | `OREG = (OREG & ~name##_MASK) \| val` — write masked group, other bits preserved (common/gpio.h:66-67) | **ISR-hot** | stepper.c:331,333,343,345 (ISR_STEP); 499,501 (ISR_STEP_RESET); 561-567 (st_reset); limits/probe: none |
| `GPIO_MRD(name, reg)` | `reg & name##_MASK`, expression (common/gpio.h:68) | ISR-hot + main | stepper.c:338,340 (OREG); limits.c:77, probe.c:54, system.c:43 (IREG) |
| `GPIO_MDIR_OUT/INP(name)` | set/clear MASK bits in direction reg (common/gpio.h:104-109) | init | stepper.c:576-582; limits.c:44; probe.c:32; system.c:27 |
| `GPIO_MPULLUP_EN/DIS(name)` | enable/disable input pull-ups for MASK bits (common/gpio.h:112-117) | init | limits.c:47,49; probe.c:34,36; system.c:29,31 |
| `GPIO_BSET/BCLR(name)` | set/clear single bit `name##_BIT` in OREG (common/gpio.h:75-80) | main + ISR (st_go_idle from ISR_STEP) | stepper.c:229,231,271,273; spindle_control.c:104-264; coolant_control.c:64-111 |
| `GPIO_DIR_OUT(name)` | single-bit direction out (common/gpio.h:87) | init | stepper.c:577; spindle_control.c:36-49; coolant_control.c:27,29 |
| `GPIO_BGETOUT(name)` | expression: nonzero iff OREG bit set — read back *commanded output* state, not pin level (common/gpio.h:124) | main | coolant_control.c:40-50; spindle_control.c:72,86 |
| `GPIO_OREG(name) = v` | raw whole-register store; used directly only under `STEP_PULSE_DELAY` | ISR-hot | stepper.c:513,515 |
| `GPIO_BGET`, `GPIO_BTGL`, `GPIO_PULLUP_EN/DIS`, `GPIO_MWV` | defined (common/gpio.h:66,75-99,120) but **no core use site** — do not burn effort porting until consumed |

Contracts:

1. **Preservation**: `GPIO_MWO` must not disturb bits outside `name##_MASK`
   (serial pins share PORTD with STEP on AVR: cpu_map.h:37-42).
2. **Atomicity**: `GPIO_MWO`/`GPIO_BSET` are read-modify-write. Core's writer
   discipline: STEP and DIRECTION groups are written only from stepper ISRs and
   from init/reset paths with stepper interrupts off; STEPPERS_DISABLE /
   SPINDLE / COOLANT bits are written from mainline and from `st_go_idle()`
   which also runs inside ISR_STEP (stepper.c:401). If any two writers of the
   *same physical output register* can preempt each other on your platform, the
   implementation must use hardware atomic set/clear registers (OUTSET/OUTCLR,
   BSRR) or a critical section. On AVR, `PORTB |= ...` is a single interrupt-
   atomic SBI when mask is one bit — that is the origin semantic.
   SAMD21 currently uses plain RMW on `OUT` (samd21/gpio.h:15) — the shared-
   register hazard is real there (STEPPERS_DISABLE PA3, SPINDLE PA6/8/9,
   COOLANT PA17 all on GROUPA OUT, written from both main and ISR_STEP).
3. **Width truncation**: core stores `GPIO_MRD(name, IREG)` into `uint8_t`
   (limits.c:77, system.c:43, probe.c:54) and tests it against `name##_MASK`
   and `(1<<name##_*_BIT)`. **Input-group bits must land in bits 0-7** (or the
   platform must remap in its accessors). **CLOSED** (2026-07-26, see
   [§logical-contract-vs-constraint-cure](#logical-contract-vs-constraint-cure)
   for the full audit): SAMD21 megarm CONTROL bits were 14/15/16 and PROBE
   was 19 — both truncated to a constant 0 at system.c:43/probe.c:54 as
   shipped; SAMD21 generic's CONTROL (partially) and PROBE were the same,
   previously undocumented. Both boards now translate CONTROL/PROBE through
   the same logical-port-image dispatch STEP/DIRECTION already used
   (BUG #17), promoted to `common/gpio_logical.h`.
   **A THIRD consumer of this exact contract, easy to miss because it isn't
   a `GPIO_MRD` call site**: `grbl/settings.c`'s `get_limit_pin_mask(uint8_t
   axis_idx)` returns `(1<<Z_LIMIT_BIT)` (etc.) from a function declared to
   return `uint8_t` — this truncates independently of, and in addition to,
   the `GPIO_MRD` group-read truncation above. BUG #26 (stm32f103/f411/h523,
   2026-07-26): all three shared `Z_LIMIT_BIT=10`; a review comment on one
   of them reasoned correctly about the `GPIO_MRD`/limits.c consumer and
   concluded the port was safe, without checking this second one — it
   wasn't. **Lesson for future audits: enumerate every core call site of a
   `*_BIT` constant before declaring bits 0-7 satisfied "because I checked
   the read path" — a single traced consumer is not a proof.** See
   [§NEW below](#limit-bit-width-second-consumer) for the full incident.
4. **Pull-up semantics**: after `GPIO_MDIR_INP` + `GPIO_MPULLUP_EN`, the pin
   must read logic 1 when the switch is open (AVR PORTx-on-input = pull-up,
   cpu_map.h wiring assumption throughout limits/probe/control). No-op is
   `conditional`: legal only for boards with external pull hardware, and the
   board config must say so. SAMD21 maps `GPIO_PREG` to `PORT...CTRL`
   (samd21/gpio.h:18) — the sampling-control register, not `PINCFG.PULLEN`:
   pull-ups are NOT actually enabled on that port as written. Known gap.
5. **No-op**: ILLEGAL for everything except the pull-up pair per (4).

<a id="gpio-interrupts"></a>
## 2. GPIO interrupts (`GPIO_INT_ON/OFF`, `HAL_GPIO_IRQ_HANDLER`)

| Macro | Semantics | Context | Core use sites |
|---|---|---|---|
| `GPIO_INT_ON(pcmsk, int, mask)` | arm pin-change interrupt for all `mask` bits (hal_gpio.h:184 -> `HAL_GPIO_INTERRUPT_ENABLE`) | init + main | limits.c:53 (limits_init, re-run on every `$` settings write); system.c:33 |
| `GPIO_INT_OFF(pcmsk, int, mask)` | disarm (hal_gpio.h:185) | main | limits.c:67 (`limits_disable()` — called before homing) |
| `HAL_GPIO_IRQ_HANDLER(name)` | function-definition macro: core supplies the handler *body* | defines ISR | limits.c:107,131; system.c:64 |

References: AVR atmega328p/platform.h:130-132 (`PCMSK |= mask, PCICR |= bit` /
`ISR(name##_vect)`); SAMD21 EIC macro set samd21/platform.h:129-177,
dispatch wrapper handlers.c:76-92, channel setup platform.c:217-241.

Contracts:

1. `GPIO_INT_ON`/`OFF` are called **repeatedly at runtime**, not just at boot:
   homing disables hard limits and settings writes re-enable them. Both must be
   cheap, idempotent, and actually gate delivery. A "handled at init" no-op for
   `GPIO_INT_OFF` is ILLEGAL — homing would trip a hard-limit alarm on its own
   switches (limits.c:102-105 note). SAMD21 currently defines both as empty
   comments (samd21/platform.h:175-176) and its EIC channel arming function
   `hal_gpio_interrupt_init()` (platform.c:217) **has no caller** in the build —
   limit/control interrupts are never armed at runtime. Known gap.
2. `HAL_GPIO_IRQ_HANDLER(name)` effective non-AVR expansion is
   `void name##_IRQHandler(void)` — hal_gpio.h:139-140 is its single owner,
   guarded by `#ifndef HAL_GPIO_IRQ_HANDLER` so any platform override must be
   explicit (the prior unguarded-redefine hazard, "HAL_GPIO_IRQ_HANDLER
   redefined", was closed in Phase 1). SAMD21 `platform.h` deliberately
   defines nothing here (samd21/platform.h:178-183 comment). SAMD21
   `EIC_Handler` matches that: it calls
   `LIMIT_INT_IRQHandler()`/`CONTROL_INT_IRQHandler()` (handlers.c:61-92).
3. **Flag clearing (INTFLAG lesson)**: on ARM the platform wrapper must clear
   the peripheral interrupt flag BEFORE invoking the core body
   (handlers.c:80-81 clears all pending `EIC->INTFLAG` first). Clearing after
   the body loses edges that arrive during the body and, for level-ish sources,
   re-enters forever. On AVR the flag is cleared by hardware vector entry —
   that is the origin semantic the wrapper must reproduce.
4. Handler bodies call `mc_reset()` / `system_set_exec_alarm()`
   (limits.c:119-124) — those must be safe in the platform's ISR context.
5. Shared-vector platforms (one EIC/EXTI line for many pins) must dispatch to
   *both* core handlers when both groups are pending (handlers.c:84-91).
6. Debounce filtering is permitted (EIC FILTEN, samd21/platform.h:162); the
   contract is edge detection on both edges — core treats *any* change as a
   trigger (limits.c:95-101).

<a id="stepper-timer"></a>
## 3. Stepper timer (`STP_TMR_*`)

Semantic origin: AVR Timer1 CTC (atmega328p/timer.h:42-54).
ARM reference: TC3 MFRQ (samd21/timer.h:54-69).

| Macro | Signature / domain | Semantics | Context | Use site | No-op |
|---|---|---|---|---|---|
| `STP_TMR_INIT()` | statement | periodic compare timer in CTC-class mode, compare interrupt masked, no PWM output routing. On AVR, INIT does not touch the clock-select bits (timer.h:42-48); the /1 run state is established afterward by `STP_TMR_PRESCALER_RESET()` inside `st_go_idle()`, reached via `st_reset()` at main.c:95 before `sei()`. A port whose INIT also starts the counter at /1 (samd21/timer.h:60) is conformant — INIT+RESET together must yield: running, /1, interrupt masked | init | stepper.c:586 | ILLEGAL |
| `STP_TMR_INT_ENA()` | statement | unmask compare interrupt; next match runs `ISR_STEP()` | main (st_wake_up) | stepper.c:249 | ILLEGAL |
| `STP_TMR_INT_DIS()` | statement | mask it; no further `ISR_STEP()` fires | **ISR** — st_go_idle runs inside ISR_STEP (stepper.c:401) | stepper.c:257 | ILLEGAL |
| `STP_TMR_PERIOD_SET(cycles)` | `uint16_t` (stepper.c:86), unit = timer ticks at current prescale | period of the NEXT step tick takes effect without stopping/resetting the counter mid-count (AVR OCR1A write, timer.h:52) | **ISR-hot** | stepper.c:371 | ILLEGAL |
| `STP_TMR_PRESCALER_SET(v)` | `v` in {1,2,3} = divide by 1/8/64 (encoding fixed by stepper.c:1032-1044) | new prescale effective for the segment being loaded | **ISR-hot** | stepper.c:367 — compiled only `#ifndef ADAPTIVE_MULTI_AXIS_STEP_SMOOTHING` | conditional: legal ONLY in AMASS builds (config.h:304 default-on), and must `#error` in non-AMASS builds. SAMD21 silent no-op (samd21/timer.h:68) is the canonical violation |
| `STP_TMR_PRESCALER_RESET()` | statement | restore /1 (AVR timer.h:54) | ISR (st_go_idle) | stepper.c:258 | same conditional as above |

Timing: `ISR_STEP` total budget < 33.3 us (stepper.c:318-320); PERIOD_SET runs
inside it every tick. Bounded sync waits allowed (samd21/timer.h:67 waits
TC3 SYNCBUSY); unbounded loops are not.

<a id="pulse-reset-timer"></a>
## 4. Pulse-reset timer (`STP_PULSE_RESET_*`, `STP_PULSE_DELAY_INIT`)

Semantic origin: AVR Timer0, 8-bit, prescale /8 baked into START
(atmega328p/timer.h:57-72). This family generates the step pulse *width*.

| Macro | Semantics | Context | Use site | No-op |
|---|---|---|---|---|
| `STP_PULSE_RESET_INIT()` | overflow interrupt source enabled, timer STOPPED (AVR: TIMSK0 TOIE0 set, TCCR0B=0) | init | stepper.c:589 | ILLEGAL |
| `STP_PULSE_RESET_COUNT_SET(val)` | preload counter; `val` is `uint8_t` two's-complement negative count (st.step_pulse_time, stepper.c:110,240,245) | **ISR-hot** | stepper.c:351 | ILLEGAL |
| `STP_PULSE_RESET_START()` | start counting; overflow ISR (`ISR_STEP_RESET`) must fire after exactly `(256 - val)` ticks of **F_CPU/8** | **ISR-hot** | stepper.c:352 | ILLEGAL |
| `STP_PULSE_RESET_STOP()` | halt counting; no further overflow | ISR (inside ISR_STEP_RESET) | stepper.c:503 | ILLEGAL |
| `STP_PULSE_RESET_COMPARE_SET(val)` | compare point for delayed-step ISR; only under `STEP_PULSE_DELAY` (config.h:425, default off) | main (st_wake_up) | stepper.c:242 | conditional: absent when STEP_PULSE_DELAY off |
| `STP_PULSE_DELAY_INIT()` | enable compare interrupt (`ISR_STEP_DELAY`) | init | stepper.c:591 | same conditional |

**The 8-bit horizon contract**: core computes
`step_pulse_time = -((pulse_us - 2) * TICKS_PER_MICROSECOND >> 3)` into a
`uint8_t` (stepper.c:245, nuts_bolts.h:47). The pulse width equals
`(256 - val) * 8 / F_CPU`. An implementation on a wider counter must reproduce
the 256-count overflow horizon (use 8-bit mode, or bias: `COUNT = 0x10000 - 256 + val`,
or set TOP=255). SAMD21 loads the raw 8-bit value into 16-bit `TC4->COUNT`
in COUNT16 mode (samd21/timer.h:81,89): overflow at 65536, giving ~ms-scale
pulses instead of `pulse_us`. Known gap — a port is not done until pulse width
is measured (scope or Renode) at `settings.pulse_microseconds`.

Also: prescale. AVR START uses /8 (timer.h:65 `TCCR0B = 1<<CS01`) and the `>>3`
in core compensates. A port clocking this timer at F_CPU/1 must divide by 8 in
hardware or rescale — the core arithmetic is untouchable.

<a id="isr-definition-macros"></a>
## 5. Timer ISR definition macros (`ISR_STEP`, `ISR_STEP_RESET`, `ISR_STEP_DELAY`)

Core defines the bodies: stepper.c:326, 496, 511. AVR expands directly to
vectors (atmega328p/timer.h:37-39). ARM route: expand to named plain functions
(samd21/timer.h:45-47) and provide vector wrappers that **clear INTFLAG first,
then call the body** (handlers.c:30-47).

Contracts:
1. Flag-clear-first, same rationale as [section 2.3](#gpio-interrupts). `ISR_STEP_RESET` stops the
   timer inside the body (stepper.c:503); clearing the flag after that write
   can ghost or drop the final overflow.
2. `ISR_STEP` re-enables global interrupts mid-body (`sei()`, stepper.c:355) so
   the pulse-reset ISR can preempt it. The platform interrupt model must allow
   the pulse-reset interrupt to run while `ISR_STEP` is still executing:
   on AVR that is `sei()` inside the ISR; on Cortex-M assign the pulse-reset
   IRQ a **higher preemption priority** than the stepper IRQ (M0+ has no
   priority config in the current samd21 port — both default: no preemption,
   pulse reset waits for ISR_STEP exit; acceptable only because ISR_STEP's
   tail is short, but set priorities explicitly in new ports).
3. Reentry of `ISR_STEP` is guarded by core (`busy` flag, stepper.c:328); the
   platform must not add its own reentry masking that defeats `sei()`.
4. `ISR_STEP_DELAY` writes the whole OREG via `GPIO_OREG(STEP) = st.step_bits`
   (stepper.c:513) — see GPIO preservation contract; `st.step_bits` was
   captured with the non-STEP bits included (stepper.c:338).

<a id="spindle-pwm"></a>
## 6. Spindle PWM (`PWM_*`)

Only compiled under `VARIABLE_SPINDLE` (spindle_control.c guards). AVR origin:
Timer2 fast-PWM (atmega328p/timer.h:75-82). ARM reference: TCC0
(samd21/timer.h:100-120).

| Macro | Semantics | Context | Use site | No-op |
|---|---|---|---|---|
| `PWM_INIT()` | configure PWM mode + prescale; output NOT yet routed/enabled | init | spindle_control.c:37 | ILLEGAL (in VARIABLE_SPINDLE builds) |
| `PWM_ENABLE()` | connect PWM to the pin; duty from last `PWM_SET` | main + **ISR-hot** | spindle_control.c:129,140 | ILLEGAL |
| `PWM_DISABLE()` | disconnect; pin returns to GPIO level (low) | main + **ISR-hot** | spindle_control.c:101,138 | ILLEGAL |
| `PWM_IS_ENABLED()` | expression, nonzero iff output currently connected | main | spindle_control.c:68 | ILLEGAL |
| `PWM_SET(duty)` | duty register write; `duty` is `uint8_t` — core API is `spindle_set_speed(uint8_t)` (spindle_control.c:122) | **ISR-hot** | spindle_control.c:124 | ILLEGAL |

Contracts:
1. **ISR-hot is not optional**: `spindle_set_speed()` is called from `ISR_STEP`
   (stepper.c:396,404). SET/ENABLE/DISABLE must be bounded-time.
2. **Duty domain**: full scale = `SPINDLE_PWM_MAX_VALUE`, defined by
   cpu_map/board config, and it must fit `uint8_t` because the core plumbs
   duty as `uint8_t` end-to-end (spindle_control.c:122). AVR fixes it at 255
   (cpu_map.h:131). **Closed 2026-07-26 — BUG #22** (was: SAMD21
   megarm/generic declared 65535 against `PER = 0xFF`, samd21/timer.h:109.
   This was NOT the harmless accident it was first reported as: the
   `uint8_t pwm_value = SPINDLE_PWM_MAX_VALUE` assignment site DID truncate
   65535->255 silently at compile time and was fine, but
   `spindle_control.c:45`'s `pwm_gradient = SPINDLE_PWM_RANGE/(rpm_max-
   rpm_min)` consumes `SPINDLE_PWM_RANGE` in a float context with no such
   truncation, so `pwm_gradient` was computed ~258x too large and
   `spindle_compute_pwm_value()` returned effectively-wrapped garbage
   `uint8_t` duty values for nearly the entire commanded-RPM range below
   `rpm_max` — a real, silent spindle-speed defect on every samd21 board.
   See the static-assert-sweep entry below for the before/after disassembly
   proof and reproduction numbers). Both samd21 boards now declare
   `SPINDLE_PWM_MAX_VALUE 255`, matching `PER` exactly — no port violates
   this contract any longer.
3. `PWM_SET(x); PWM_ENABLE()` in either order must yield duty `x` — core does
   SET before ENABLE (spindle_control.c:124-129).
4. `PWM_DISABLE()` must drive the spindle pin inactive, not float it
   (SPINDLE_PWM_MIN_VALUE comment, megarm/config.h:140).

<a id="serial"></a>
## 7. Serial (`HAL_SERIAL_*`)

AVR macro route: grbl/serial.c compiled; macros at atmega328p/platform.h:215-251.
SAMD21 TU-replacement route: grbl/serial.c excluded, samd21/serial.c provides
the serial.h API (samd21/Makefile:55-60). Both are compliant.

Macro-route contract table (use sites in grbl/serial.c):

| Macro | Semantics | Context | Use site | No-op |
|---|---|---|---|---|
| `HAL_SERIAL_INIT()` | UART at `BAUD_RATE`, 8N1, RX interrupt enabled, TX (DRE) interrupt disabled | init | serial.c:68 | ILLEGAL |
| `HAL_SERIAL_RX_ISR()` | function-def macro: body is the RX handler | defines ISR | serial.c:130 | ILLEGAL |
| `HAL_SERIAL_TX_ISR()` | function-def macro: body is the TX-register-empty handler | defines ISR | serial.c:94 | ILLEGAL |
| `HAL_SERIAL_READ_DATA()` | expression: pop received byte; reading must clear the RX flag (AVR UDR0 read, platform.h:245) | ISR | serial.c:132 | ILLEGAL |
| `HAL_SERIAL_WRITE_DATA(b)` | push byte to transmit register (must clear DRE condition) | ISR | serial.c:99 | ILLEGAL |
| `HAL_SERIAL_TX_INTERRUPT_ENABLE()` | unmask DRE interrupt; if TX register already empty the ISR must fire promptly | main | serial.c:89 | ILLEGAL |
| `HAL_SERIAL_TX_INTERRUPT_DISABLE()` | mask DRE interrupt | ISR (TX ISR tail) | serial.c:108 | ILLEGAL |

Baud arithmetic is a proven bug source (BUG #4, PLAN.md:77): AVR reference
rounds via `((F_CPU/(4L*BAUD_RATE))-1)/2` with U2X (platform.h:223-241);
verify your divisor formula against the datasheet at 115200, not just 9600.

**Ring-buffer memory ordering (BUG #12 lesson)** — binds BOTH routes:
- Producer publishes: *data store first, then index store*. On weakly-ordered
  cores (ARM, RISC-V) a compiler/CPU may reorder those plain stores. `volatile`
  on the index does NOT order the data store. Required: `__DMB()` (or release
  store) between `buffer[head] = data` and `head = next_head`
  (samd21/serial.c:171-173), or make the pair atomic by masking the consuming
  interrupt around it (samd21/serial.c:96-105, INTENCLR/INTENSET bracket in
  `serial_write`).
- The AVR original needs neither: single in-order core; index is `uint8_t`
  (atomic by width) and `volatile` suffices (serial.c:29-34). That is why the
  core file has no barriers — the obligation moves INTO the platform layer.
- Consumer side (core, serial.c:96-108,115-123) reads index once into a local —
  preserve that pattern in TU replacements.

<a id="critical-sections"></a>
## 8. Critical sections (`HAL_CRITICAL_SECTION_BEGIN/END`)

Use sites: system.c:357-401 (all eight `sys_rt_exec_*` RMW helpers) and
serial.c:153-155 (DEBUG path, inside the RX ISR).

Contract:
1. BEGIN...END must make the enclosed read-modify-write of a `volatile uint8_t`
   flag atomic against **every ISR that touches the same flag** (stepper,
   serial RX, EIC/pin-change, watchdog debounce all set exec flags).
2. Must be **save/restore**, not blind disable/enable: the pair runs inside the
   RX ISR (serial.c:153) — an END that unconditionally re-enables interrupts
   would corrupt AVR ISR semantics. AVR origin: `SREG` save + `cli()`, restore
   (atmega328p/platform.h:262-266). Cortex-M equivalent: PRIMASK save/restore —
   reference exists at samd21/platform.c:24-33.
3. BEGIN may declare a local (AVR does); core only uses the pair at block scope.
   Nesting is not required by core (all uses are flat pairs in leaf functions).
4. No-op: ILLEGAL. SAMD21 currently defines both empty (samd21/platform.h:209-210)
   while `hal_critical_enter/exit` sit unused in platform.c — lost-update races
   on `sys_rt_exec_state` between mainline and EIC/SERCOM ISRs. Known gap.

<a id="watchdog-debounce"></a>
## 9. Watchdog debounce (`HAL_WATCHDOG_*`)

Compiled only under `ENABLE_SOFTWARE_DEBOUNCE` (config.h:472, default off).
Use sites, which ARE the specification:

- `HAL_WATCHDOG_INIT(32)` — limits.c:59: configure watchdog in
  *interrupt-only* mode, timeout ~= the argument in ms. No reset action.
- `HAL_GPIO_IRQ_HANDLER(LIMIT_INT) { HAL_WATCHDOG_ENABLE_INTERRUPT(); }` —
  limits.c:131: arm a one-shot delayed callback from within the pin ISR.
- `HAL_WATCHDOG_ISR()` — limits.c:132: function-def macro, body checks the
  (now settled) limit pins.
- `HAL_WATCHDOG_DISABLE_INTERRUPT()` — limits.c:134: first statement of the
  body; the callback must be one-shot.

Current state: **no platform implements this family**. atmega328p/platform.h:269
defines only a zero-arg `HAL_WATCHDOG_INIT()` (wrong arity for limits.c:59) and
`HAL_WATCHDOG_RESET()`. Enabling `ENABLE_SOFTWARE_DEBOUNCE` today fails to
compile everywhere — which is the correct loud failure mode. No-op: ILLEGAL
when the option is on (debounce would silently vanish and the raw ISR path is
compiled out); leave the macros undefined instead.

<a id="nvmem-eeprom"></a>
## 10. NVMEM / EEPROM (link-level API)

Not macros — four functions, declared in eeprom.h:24-27 and nvmem.h:31-36
(`memcpy_*_eeprom_*` aliases map to `*_nvmem_*`, nvmem.h:35-36):

```
unsigned char eeprom_get_char(unsigned int addr);
void          eeprom_put_char(unsigned int addr, unsigned char v);
void          memcpy_to_nvmem_with_checksum(unsigned int dst, char *src, unsigned int n);
int           memcpy_from_nvmem_with_checksum(char *dst, unsigned int src, unsigned int n);
```

Consumers: settings.c:70-182 (settings, startup lines, build info, coord data);
version byte at address 0 (settings.c:98,179).

Provisioning routes: AVR compiles core nvmem.c (its `#ifdef __AVR__` section,
nvmem.c:29-109, root Makefile:34-36); a flash-emulation port excludes core
nvmem.c and provides all four functions (samd21/nvmem.c, samd21/Makefile:55-60).
Legacy grbl/eeprom.c is in **no** build — do not port it.

Contracts:
1. **Context**: mainline only, interrupts enabled; never called from ISR.
   Blocking is allowed (AVR put_char busy-waits EEPE, nvmem.c:49,62). But note
   AVR `eeprom_put_char` ends with an unconditional `sei()` (nvmem.c:60,106) —
   origin quirk; callers are all in mainline so it is harmless there. Flash-
   emulation ports stalling the CPU during row erase stall the stepper ISR too:
   writes happen during `$` commands (IDLE/ALARM), which is why this is
   tolerated. Do not add background/deferred writes — `settings_read` may
   follow immediately.
2. **Address space**: at least 1 KB flat, byte-addressable, address 0 valid
   (AVR HAL_EEPROM_SIZE 1024, atmega328p/platform.h:41).
3. **Wear**: `eeprom_put_char` should skip writes when the stored byte already
   matches (samd21/nvmem.c:88-90; AVR hardware does erase/write selectively,
   nvmem.c:71-104).
4. **Checksum fidelity**: core AVR checksum uses `(checksum << 1) ||
   (checksum >> 7)` — **logical** OR, an upstream-grbl quirk preserved for
   byte-golden AVR (nvmem.c:127,149). SAMD21 uses bitwise `|`
   (samd21/nvmem.c:145,160). Contract: write and read paths on ONE platform
   must use the SAME function (each is self-consistent today). Cross-platform
   NVMEM image portability is a non-goal. Never "fix" the AVR `||`.
5. **Flash page ordering (BUG #13 lesson)**: on ARM, page-buffer fills are
   plain memory stores; the NVM controller command that commits them is an
   MMIO write that can be issued before the stores complete. `__DSB()` is
   REQUIRED between filling the page buffer and issuing the write command
   (samd21/nvmem.c:60-65). Same class: `__DSB()` between .data/.bss init loops
   in startup (samd21/startup.c:184-194). Wait for controller READY/busy flags
   after every erase/write command (samd21/nvmem.c:25-27,39-40).
6. Out-of-range reads return 0xFF, writes are dropped (samd21/nvmem.c:69-81) —
   matches erased-flash semantics; core never reads out of range in practice.

<a id="interrupt-global-control"></a>
## 11. Interrupt global control (`sei`/`cli`)

Core calls bare `sei()` (main.c:48, stepper.c:355). AVR: native. Non-AVR must
define both (samd21/platform.h:206-207: `cpsie i`/`cpsid i` with `"memory"`
clobber — the clobber is mandatory: it is the compiler barrier that keeps
stores from floating across the interrupt-enable boundary).

---

<a id="weak-memory-obligations"></a>
## 12. Weak-memory obligations — consolidated

Every ARM/RISC-V implementation must be audited against this list; the AVR
origin needed none of it, so nothing in core will remind you:

1. **Ring buffers**: data store -> `__DMB()`/release -> index publish
   (BUG #12; samd21/serial.c:172). Consumer: index read -> `__DMB()`/acquire ->
   data read if the consumer can race a concurrent producer slot reuse.
2. **volatile != atomic**: `volatile uint8_t` gives width-atomicity of the
   single access only. Any RMW (`|=`, `&=~`) shared with an ISR needs
   `HAL_CRITICAL_SECTION_*` or interrupt masking ([section 8](#critical-sections)).
3. **ISR INTFLAG**: clear peripheral flag BEFORE running the core handler body
   (handlers.c:31,37,44,81). Write-1-to-clear registers: write ONLY the bit you
   are handling (`TC3->INTFLAG = TC_INTFLAG_MC0`, not `= 0xFF`).
4. **MMIO command vs memory data**: `__DSB()` before NVM/flash commit commands
   (BUG #13; samd21/nvmem.c:62) and between startup init phases
   (samd21/startup.c:185,194).
5. **SYNCBUSY-class sync**: peripherals in a different clock domain need their
   busy flag polled after register writes (samd21/timer.h:67,87-90;
   samd21/platform.c:90). These waits are bounded and ISR-legal; but audit each
   one — a SYNCBUSY wait on a peripheral whose clock is not running hangs
   forever (the "compiles but dead" class, PLAN.md Phase 3).
6. **Interrupt-enable boundaries**: `sei`/`cli`/PRIMASK asm needs `"memory"`
   clobber (samd21/platform.h:206-207).
7. **NVIC preemption priority ordering, where a port assigns explicit
   priorities** (recommended by [§5.2](#isr-definition-macros) rather than relying on default
   equal-priority no-nesting): the pulse-reset timer IRQ gets the
   numerically lowest value (highest preemption priority), so it can
   interrupt the stepper ISR per [§5.2](#isr-definition-macros)'s AVR-nesting semantic; the stepper
   timer IRQ is next; any interrupt whose body can run long relative to
   the 33.3us ISR-hot budget — in practice, serial RX/TX — gets a
   numerically higher value (lower preemption priority) so it cannot
   starve the stepper/pulse-reset pair. Reference implementation:
   stm32f411/platform.c:248,260,300 and hc32f460/platform.c (pulse-reset=0,
   stepper=1, USART=3).

<a id="samd21-known-gaps"></a>
## 13. Known contract gaps in the SAMD21 reference (do not copy blindly)

The SAMD21 port is the ARM *adaptation reference*, not a compliance gold
standard. Open violations, all cited above: prescaler silent no-op ([§3](#stepper-timer)),
empty critical sections ([§8](#critical-sections)),
pull-up accessor mapped to PORT CTRL ([§1.4](#gpio-data)), pulse-width 16-bit overflow
horizon ([§4](#pulse-reset-timer)), EIC arming never called ([§2.1](#gpio-interrupts)). Each is a
Phase-3 closure item; each future port must clear this whole file instead.

Closed: CONTROL/PROBE input bits above bit 7 on both boards ([§1.3](#gpio-data),
[§logical-contract-vs-constraint-cure](#logical-contract-vs-constraint-cure)) —
2026-07-26, same logical-port-image dispatch STEP/DIRECTION already used for
BUG #17, now covering all five truncation-risk groups on both samd21 boards.

Closed: PWM range 65535 vs `PER=0xFF` vs core `uint8_t`, BUG #22
([§6.2](#spindle-pwm)) — both boards now declare `SPINDLE_PWM_MAX_VALUE 255`,
matching `PER` exactly (2026-07-26, see the static-assert-sweep closure entry
for the reproduction: this was a real garbage-duty spindle-output defect, not
a cosmetic no-op).

Closed: `_delay_us/_delay_ms` empty stubs — real calibrated busy-wait
implementations landed (samd21/platform.c:169-214, commit dd5c5e7). The
lesson stands: empty delay stubs compile and break homing debounce and
spindle ramp silently.

<a id="ch32v006-riscv-gaps"></a>
## 14. RISC-V gaps found porting ch32v006 (Phase 4 M1-M3, first non-ARM port)

PLAN.md Phase 4 law: "each port strengthens the system" — every gap below
is something `_template`/this file/PORTING-CHECKLIST.md failed to answer
when a real RISC-V chip hit it. All found empirically this session
(toolchain evidence: `riscv64-unknown-elf-gcc` 13.2.0 + picolibc, real
`make`/`make link` runs in `grbl/platform/ch32v006/`) — not theoretical.

1. **Toolchain recipe incomplete**: PLAN.md's Decision Log records
   `-march=rv32ec -mabi=ilp32e` as the verified flag set. That is
   sufficient to compile plain C, but ANY `csr*` instruction (interrupt
   enable/disable, critical sections — i.e. most of a real platform.h)
   fails to assemble: `Error: unrecognized opcode 'csrw mtvec,a5',
   extension 'zicsr' required`. This binutils treats Zicsr as unbundled
   from the base ISA (post-20191213 ISA-string convention) rather than
   implied by `_zicsr`-less `rv32ec`. Fix: `-march=rv32ec_zicsr`. Every
   future RISC-V port on this toolchain generation needs this appended;
   PLAN.md's recipe should be read as amended.
2. **`_template`'s entire startup.c/script.ld model is ARM-only and does
   not transfer**: the template's vector table is literally
   `void (* const vector_table[])(void)` with slot 0 = initial SP and
   slot 1 = Reset_Handler, loaded by ARM Cortex-M hardware automatically
   on reset. RISC-V has no equivalent mechanism at all — not even
   standard RV, let alone QingKe's PFIC. A RISC-V port needs, from
   scratch: (a) a `naked` `_start` that sets `sp` itself before calling
   any C function (no hardware SP autoload — ch32v006/startup.c's `_start`
   is the reference now), (b) an `mtvec`-based trap entry written with
   `__attribute__((interrupt))` so GCC emits correct register
   save/restore + `mret` (verified by disassembly:
   `csrw mtvec,a5` / opcode `0x30200073` = `mret`), (c) a decision between
   RISC-V standard direct mode (mtvec mode=00, one trap entry, `mcause`
   dispatch in C — spec-portable on any RV32/64 core) and a vendor
   vectored/absolute-address mode (WCH's PFIC reportedly supports one,
   per public ch32fun-class references) that could NOT be verified
   against a real CH32V006 TRM this session. ch32v006/startup.c uses
   direct mode for exactly this reason and documents the vectored-mode
   question as open for Step 3+ (real peripheral IRQs). **Template
   action item**: `_template/startup.c`'s header comment should say
   outright "this file's vector-table model is ARM-specific" instead of
   presenting itself as architecture-neutral — a RISC-V porter copying it
   verbatim will write code that cannot work at all (no hardware SP
   autoload, and a data-pointer array is not a valid `mtvec` target in
   direct mode).
   **Steps 3-6 UPDATE — vectored-mode question CLOSED with TRM facts**
   (CH32V00X RM V1.5, 6.5.3.2): QingKe `mtvec` has MODE0 (bit 0,
   1 = entry address = BASE + irq#*4) and MODE1 (bit 1, 1 = table
   entries are ABSOLUTE ADDRESSES — i.e. a plain C array of function
   pointers IS a valid vector table). ch32v006 now runs MODE0=MODE1=1
   (startup.c `PFIC_Vector[41]`, `mtvec = table|0x3`), handlers are
   standard `__attribute__((interrupt))` functions. The vendor "HPE"
   hardware prologue = `INTSYSCR` (CSR 0x804) bit 0 HWSTKEN, and
   2-level nesting = bit 1 INESTEN; BOTH reset to 0 and are LEFT 0
   (documented choice, startup.c): HWSTKEN=0 matches GCC's software
   save/restore frame exactly, INESTEN=0 gives the same no-preemption
   posture as the SAMD21 M0+ reference ([§5.2](#isr-definition-macros)) and avoids the nested-trap
   mepc/mstatus clobber hazard (GCC's interrupt attribute saves GPRs
   only). Consequence: core's `sei()` inside ISR_STEP defers, not nests,
   the pulse-reset IRQ — acceptable per [§5.2](#isr-definition-macros)'s existing precedent.
3. **`-specs=picolibc.specs` silently re-enables `--gc-sections`,
   defeating `_template`'s stated Makefile strategy of "just don't pass
   --gc-sections"**: picolibc's own linker spec (`*link:` rule, visible
   via `-dumpspecs`) unconditionally appends `--gc-sections` to the link
   line regardless of what the platform Makefile itself passes. Proven
   concretely: with only "omit --gc-sections" (the `_template` posture),
   `make link` reported an INCOMPLETE PORT_TODO_* list — 6 real undefined
   references inside `handlers.c` (confirmed present via `nm -u` on the
   object file) silently vanished from the linker's error output because
   `--gc-sections` discarded their whole functions as unreached before
   symbol resolution ever ran, and `_template`'s own documented insurance
   against this (`static ... __keep_alive[] __attribute__((used))`) was
   NOT sufficient by itself to stop it on this toolchain/version.
   Fix: `-Wl,--no-gc-sections` explicitly in LDFLAGS. **Any future
   picolibc-based port must do the same while it still has PORT_TODO_*
   stubs**, or `make link`'s PORT_TODO_* list is silently incomplete — a
   correct-looking but false "fewer things left to do" reading, exactly
   the kind of silent failure this whole design exists to prevent.
   **LIFECYCLE (compactness-drive update, post Phase 4 completion)**:
   `--no-gc-sections`/omission is a PORTING-TIME posture, not a permanent
   one — it exists solely to keep the linker-as-checklist mechanism
   honest while PORT_TODO_* stubs are still being replaced. Once a port
   reaches zero PORT_TODO_* (every dispatcher genuinely wired into a real
   vector table, not just kept alive by an override flag), the
   reachability hazard this item describes no longer applies, and
   `--gc-sections` should be RE-ENABLED — every picolibc-based release
   binary is otherwise permanently paying for dead/unreached code with no
   corresponding benefit. ch32v006/Makefile made this flip after Phase 4
   (zero PORT_TODO_* at link): `-Wl,--no-gc-sections` → `-Wl,--gc-sections`,
   in both BUILD flavors (RELEASE and DEBUG share one LDFLAGS block — no
   reason for DEBUG to keep unreached code once completeness holds).
   RELEASE went 55560 → 54904 bytes .text (656 B, ~1.2%); DEBUG went
   61360 → 60648 bytes .text (712 B, ~1.2%) (see CH32V006_PLAN.md /
   PLAN.md compactness-drive entry for the full map-diff killed-list).
   Verified safe: the vector table survives gc-sections regardless of
   reachability, because it's protected structurally, not by luck —
   `PFIC_Vector` is `__attribute__((used, section(".vectors")))` and
   `ch32v006/script.ld`'s `.init` output section does `KEEP(*(.init))
   KEEP(*(.vectors))` explicitly (`KEEP()` overrides `--gc-sections`
   unconditionally, by design — that's what it's for). Confirmed via
   `nm`/`readelf` before/after: `_start` stays at `0x0`, `PFIC_Vector`
   stays at `0xc`, `.init` section identical offset/size, zero foreign
   undefined symbols at link. The NVMEM window is unaffected either way —
   it's addressed directly by physical address in `nvmem.c`, never placed
   via a linker input section, so section-reachability analysis never
   touches it. **General rule for any picolibc-based port**: flip
   `--no-gc-sections` → `--gc-sections` the same session `make link`
   first reports zero PORT_TODO_*, provided (a) the vector table has an
   independent `KEEP()` anchor (not just `__attribute__((used))` alone —
   proven insufficient by itself, see above) and (b) nothing else in the
   image is reached only by address rather than by call graph. Do not
   leave `--no-gc-sections` in place indefinitely "to be safe" once those
   two conditions hold — it is not free.
4. **`_template/script.ld`'s blanket `/DISCARD/ { libc.a(*) libm.a(*)
   libgcc.a(*) }` is a latent bug for any chip without hardware
   multiply/float**: harmless in the template only because its link
   never gets far enough to need a pulled-in libgcc routine. rv32ec has
   no M (multiply/divide) or F (float) extension, and core grbl uses
   floating point throughout (planner/gcode/motion_control) — a real
   future link on this chip WILL need real libgcc/libm code, which the
   inherited DISCARD block would silently strip to nothing rather than
   erroring loudly. ch32v006/script.ld does not reproduce this DISCARD
   block; other non-FPU/non-multiply ports (and any ARM port without a
   hardware FPU) should audit their own copy of this script.ld pattern.
5. **GPIO direction/pull-up cannot be a `GPIO_DREG`/`GPIO_PREG` bit-op
   macro on this chip** — CFGLR/CFGHR pack 4 bits (CNF+MODE) per pin, so
   a single-bit OR/AND (common/gpio.h's default `GPIO_BWR`/`GPIO_MWR`
   formula) would corrupt neighboring pins' nibbles. Not a new
   discovery — stm32f103 solved the identical problem (its CRL/CRH is the
   same shape) by making direction/pull-up real function calls instead
   of macros; ch32v006/gpio.h reuses that pattern rather than
   reinventing it. Worth stating explicitly in `_template/gpio.h`'s own
   comment (currently only mentions the RMW-atomicity axis of GPIO
   design, not the "4-bit-packed config register" axis) since this will
   recur on every WCH/ST-family chip, not just these two.
6. **Memory-barrier semantics for QingKe — partially resolved**:
   `__DSB()`/`__DMB()` stay real `fence rw,rw` (ch32v006/platform.h);
   whether QingKe V2C reorders ordinary loads/stores remains unstated by
   the TRM (correctness-first stance kept). NEW, TRM-CONFIRMED (RM 6.5.2
   note): "When using the PFIC_IENRx register to mask any interrupt or
   the CSR register to mask global interrupts, add a 'fence.i'
   instruction for synchronization between the core control state and
   the interrupt enable state" — i.e. a mask-then-assume-no-ISR pattern
   needs `fence.i`, a DIFFERENT instruction from the data fences.
   Implemented in `PFIC_DisableIRQ` (ch32v006.h); deliberately NOT added
   to `cli()`/critical sections (hot path; vendor SDK practice omits it
   there too) — flagged, not fully discharged.
7. **CLOSED (Steps 3-6): PFIC/STK/vector facts verified** against the
   public CH32V00X RM V1.5 (+ Zephyr's Apache-2.0 ch32v006.dtsi as an
   independent cross-check). ch32v006.h now carries the real PFIC layout
   (ISR/IPR@0x00/0x20, ITHRESDR@0x40, IENR@0x100, IRER@0x180, IPRR@0x280,
   IACTR@0x300, IPRIOR@0x400, SCTLR@0xD10 — the M1-M3 placeholder struct
   had IENR at 0x70, i.e. WRONG; `_Static_assert(offsetof(...))` guards
   the corrected layout), the full 41-entry vector table (SysTick=12,
   EXTI7_0=20, USART1=32, TIM1_UP=35, TIM2=38, USART2=39, OPCM=40) and
   the STK register set (CNTL@0x08, CMPLR@0x10; SR.CNTIF is
   WRITE-0-TO-CLEAR — inverted polarity vs every W1C flag nearby, an
   easy trap). Lesson for the loop: struct-shaped "best-effort" register
   layouts are worse than absent ones — the offsets compiled fine and
   read plausibly; only the RM register list exposed them.
8. **CLOSED (Steps 3-6): DIRECTION logical<->physical translation
   landed** — ch32v006/gpio.h now carries the samd21-style
   `GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT` per-NAME dispatch and
   boards/generic/config.h defines logical `*_BIT` 0,1,2 + physical
   `*_PIN` + `STEP_/DIRECTION_MASK_PHYS`/`L2P`/`P2L` (pure shifts).
   BUG #17 cannot recur on this port.

Items 9-13 below were found during Steps 3-6 (timers/serial/nvmem/
handlers) — same session discipline: every one is empirical, from the
RM or a failing build, not theory.

9. **Two "F_CPU lie"-class clock traps on CH32V00x** (both fixed in
   platform.c SystemClock_Config, both would pass every compile/link
   gate and run 3x slow / crash at speed on silicon):
   (a) `RCC_CFGR0.HPRE[3:0]` RESETS TO 0b0010 = SYSCLK/3 (RM 3.4.2) —
   NOT /1 like STM32F1. Any port that only switches SW to PLL without
   CLEARING HPRE gets HCLK = F_CPU/3: stepper timing, STK tick and
   USART baud all silently 3x off. (b) flash wait states: LATENCY must
   be 0b10 (2 waits) for 24 < SYSCLK <= 48 MHz (RM 18.3.1) — the
   F1-habit "1 wait" guess is only legal to 24 MHz. Checklist addition:
   Step 1's "F_CPU feeds everything" warning now has a concrete
   non-ARM reproducer.
10. **V00x GPIO is NOT F1 GPIO despite the family resemblance**
   (RM 7.3.1): ports are 8 pins wide (no CFGHR — offset 0x04 reserved;
   GPIOB has only 7 pins bonded), and the per-pin nibble is
   CNF[3:2] | reserved | MODE[0] with MODE a SINGLE bit (1 = output
   30 MHz) — F1's 2-bit speed field is gone. Practical consequence:
   alternate-function push-pull is nibble 0x9, not F1's 0xB; blind
   F1-value reuse configures CNF=10 correctly by luck but sets the
   reserved bit on other values. Pull direction is still ODR-selected
   (1 = up), same as F1.
11. **"Second timer" may not exist: audit IRQ capability, not timer
   count** — CH32V006's TIM3 is a "streamlined" compare-only timer with
   NO interrupt output at all (RM 13; it paces TIM1/ADC/DMA). The
   pulse-reset role ([§4](#pulse-reset-timer)) moved to the QingKe STK, which is actually the
   BETTER fit: its STCLK=0 mode ticks at HCLK/8 — bit-identical to the
   AVR Timer0 F_CPU/8 prescale, so core's `>>3` arithmetic transfers
   with no rescaling; CMPLR is fixed at 256 and COUNT_SET preloads the
   8-bit value (the [§4](#pulse-reset-timer) overflow-horizon contract on a 32-bit counter).
   Cost: the STK has ONE compare — `STEP_PULSE_DELAY` is unsupported
   and `#error`s loudly (legal per [§4](#pulse-reset-timer) conditional rule). Checklist
   lesson: PORTING-CHECKLIST Step 3 must ask "does the candidate timer
   HAVE an interrupt line" before allocating it.
12. **EXTI line/port collision is a board-design constraint** on every
   F1/CH32-class EXTI (one port per line number via AFIO_EXTICR):
   LIMIT and CONTROL groups must not use the same pin NUMBERS on
   different ports or one group's interrupts are unroutable. The M1-M3
   placeholder board had exactly this bug (LIMIT PD0-2 + CONTROL
   PA0-2); CONTROL moved to PB3-5. On V00x additionally ALL lines 0-7
   share the single EXTI7_0 vector — the [§2.5](#gpio-interrupts) shared-vector dispatch
   rule applies to the whole GPIO interrupt space, and per-group
   disable ([§2.1](#gpio-interrupts)) works because the two groups own disjoint INTENR
   bits.
13. **`-O0` debug builds do not fit small-flash parts**: soft-float
   rv32ec grbl at -O0 is ~77 KB of .text vs 61 KB available (62 K minus
   the 1 KB NVMEM window). ch32v006 DEBUG uses `-Og -g3` instead —
   fitting the part beats stepping through unoptimized spills. Any port
   below ~96 KB flash should expect the same decision; RELEASE (-Os)
   text here is ~55.5 KB, so headroom exists but not at -O0.

<a id="stm32f411-gaps"></a>
## 15. Gaps found porting stm32f411 (Phase 6 rolling port #1, first ARM
Cortex-M4F port with a real FPU and the first "same family, different
memory map" stress test — F411 is ST's F4 line, not F1 or H5, and looks
close enough to both that copy-paste-without-verification is the live
hazard here, not an unfamiliar architecture. Found empirically this
session: real `arm-none-eabi-gcc` 13.2.1 builds (`make BUILD=DEBUG` and
`BUILD=RELEASE`, both link with zero `PORT_TODO_*` and zero undefined
symbols in `grbl/platform/stm32f411/`), plus targeted web verification of
register facts no CMSIS pack was vendored to check locally (RM0383 citations
inline in `stm32f411/regs.h`'s file header).

1. **"Family resemblance" GPIO/timer-shape reuse does NOT imply identical
   peripheral base addresses**: stm32f411 borrowed stm32h523's MODER/OTYPER/
   PUPDR/AFR GPIO model (both are F4-style) and stm32f103/h523's TIM
   register shape (CR1/DIER/SR/EGR/PSC/ARR/CCR1/BDTR is byte-identical
   across F1/F4/H5) — but TIM1's BASE ADDRESS is 0x40010000 on F4, not
   F1/H5's 0x40012C00 (that address is SDIO on F4). Blindly reusing the F1/H5
   constant would have compiled, linked, and silently driven every
   `SPINDLE_PWM`/`STP_TMR`-adjacent register write into the wrong
   peripheral's address space — exactly the "compiles, links, destroys the
   machine at runtime" class the top-of-file cautionary tale warns about,
   just relocated from a macro no-op to a base-address typo. Lesson for the
   loop: when reusing a donor port's register *shape*, re-derive every base
   address from that specific family's own memory map — never carry a donor
   family's address forward just because the struct layout matched.
2. **EXTI pending-register model does not follow the GPIO model split**:
   F411 GPIO is F4-style (matches H5's MODER/OTYPER), but F411's EXTI is the
   classic single write-1-to-clear `PR` register (matches F1's shape) — NOT
   H5's split `RPR1`/`FPR1` rising/falling pending pair. `stm32f411/
   handlers.c` therefore reuses stm32f103's shared-vector dispatch shape
   (`EXTI9_5_IRQHandler`/`EXTI15_10_IRQHandler` dispatching to both core
   handlers per [§2.5](#gpio-interrupts)) rather than stm32h523's per-line vectors. Two "same
   family" axes (GPIO model, EXTI model) do not travel together across
   STM32 generations; each needs its own donor-port check.
3. **USART register model also splits independently of the GPIO model**:
   F411 USART is the classic `SR`/`DR` pair (matches F1) — NOT H5's
   `ISR`/`RDR`/`TDR` split, despite F411 sharing H5's GPIO shape. A third
   independent axis confirms the general lesson: verify every peripheral
   family's register shape against the *specific* target chip, not against
   whichever donor port happens to share the most recently-checked
   peripheral's shape.
4. **Sector-erase flash (F4) vs page-erase (F1/H5) forces a NVMEM
   logical-window/physical-erase-granularity split that avoids a latent
   overflow bug found in the existing stm32h523 port**: F411's flash erase
   granularity is a 128 KB SECTOR (SNB field, `FLASH_CR` bits 3-6), not a
   1-8 KB PAGE like F1/H5. `common/stm32/stm32_nvmem.c`'s cache is a single
   hardcoded `static uint8_t cache_buffer[4096]` shared by every STM32 port,
   sized from `stm32_config.flash_page_size * stm32_config.flash_num_pages`.
   stm32h523's config sets that product to 8192 (2x the buffer) — every call
   to `stm32_nvmem_init()` on stm32h523 therefore fails its own
   `STM32_VALIDATE_PARAM(nvmem_size <= sizeof(cache_buffer))` check and
   returns an error that stm32h523/platform.c's `hal_nvmem_read_byte`/
   `hal_nvmem_write_byte` do not check, silently degrading every NVMEM read
   to the erased-flash value (0xFF) with no build or link error — the
   textbook "compiles but dead" class this whole document exists to
   prevent. **Not fixed on stm32h523** (out of scope — this port's gate is
   "stm32h523 untouched, sizes per ledger" — a source change would be
   size-visible even if behavior-only). stm32f411 avoids reproducing the
   defect by keeping its *logical* NVMEM window at 4096 bytes (fits the
   shared cache buffer exactly) while `stm32f411/flash.c`'s
   `stm32_flash_erase_page()` still erases the full physical 128 KB sector
   underneath it (F4 has no finer erase granularity) — the extra ~124 KB of
   now-erased-but-unused sector tail is harmless. Checklist lesson: any
   future STM32 port must size `flash_page_size * flash_num_pages` against
   `common/stm32/stm32_nvmem.c`'s actual `cache_buffer` capacity, not
   against the chip's real erase granularity, and should not assume a
   sibling port already got this right.
5. **FPU ABI choice, documented and justified (Step 1 FPU note this port's
   Makefile added to PORTING-CHECKLIST.md)**: `-mfpu=fpv4-sp-d16
   -mfloat-abi=hard` was chosen over `softfp` because (a) core grbl is
   float-heavy throughout planner/gcode/motion_control, so register-based
   float argument passing is the entire performance point of porting to an
   FPU-bearing chip, and (b) this toolchain's arm-none-eabi multilib
   provides a matching hard-float `fpv4-sp-d16` libc/libm/libgcc variant
   (confirmed by a clean link with no ABI-mismatch errors), unlike
   ch32v006's rv32ec case where no hardware F/D extension exists at all
   ([§14.4](#ch32v006-riscv-gaps)) and the choice was forced rather than optional. stm32h523 already
   set this precedent one FPU generation up (`fpv5-sp-d16`); this port
   follows it rather than falling back to softfp by default.
6. **HPRE already resets to /1 on F4 (no CH32-class trap here), but the
   [§14.9](#ch32v006-riscv-gaps) lesson is still followed defensively**: unlike CH32V00x's
   `RCC_CFGR0.HPRE` reset value of SYSCLK/3 ([§14.9](#ch32v006-riscv-gaps)(a)), STM32F4's
   `RCC_CFGR.HPRE` reset value genuinely is 0000 = SYSCLK/1 (RM0383) — so
   this port's clock config would have worked even without touching HPRE.
   `hal_clock_config()` clears/sets it explicitly anyway, on the principle
   that "verified correct by inspection of the reset value" is exactly the
   failure mode [§14.9](#ch32v006-riscv-gaps) exists to warn against generalizing from — a future
   F4-family variant's errata or a copy-paste onto a chip with a different
   reset value should not silently inherit an implicit assumption.
7. **Golden AVR gate, and the samd21/stm32f103/stm32h523/ch32v006 sibling
   builds, were re-run (not just inspected) as part of this port's gate
   check**: `make -C grbl/platform/atmega328p validate` still reports MD5
   `79af184e67b27defd27a39309ac53563`; `stm32f103`, `stm32h523`, `samd21`
   (board=megarm), and `ch32v006` (board=generic) each still build
   BUILD=RELEASE cleanly with no source changes in their directories —
   confirming this port touched only `grbl/platform/stm32f411/`,
   `grbl/platform/CONTRACTS.md`, `grbl/platform/PLATFORM_ROADMAP.md`,
   `ci/warn_baseline_stm32f411.txt`, and `.github/workflows/ci.yml`.

<a id="dspic33ak128mc102-gaps"></a>
## 16. Gaps found porting dsPIC33AK128MC102 (Phase 6 rolling port #2 —
THE THIRD ISA FAMILY: dsPIC33A 32-bit DSC, neither ARM nor RISC-V. This
is the port the `_template`/contract system was supposed to be stressed
by, and it found holes on axes no ARM or RISC-V chip could. Everything
below is empirical from this session: real `xc-dsc-gcc` 8.3.1 (XC-DSC
v3.30) builds in `grbl/platform/dspic33ak128mc102/` (M1–M3: both flavors
compile all 20 objects; `make link` lists exactly 33 undefined symbols,
all `PORT_TODO_*`), DFP 1.5.263 header/gld/atdf mining, and toolchain
disassembly. RM-only facts that could not be locally verified are marked.

1. **A third startup/IVT model exists and neither donor transfers**:
   dsPIC33A reset is a fixed-location ADDRESS slot (`.gld` places
   `LONG(ABSOLUTE(__reset))` at 0x800000 — not ARM's SP+PC hardware
   fetch, not RISC-V's naked `_start`), and the interrupt vector table
   is SYNTHESIZED BY THE LINKER (section `__ivt_0`, 286 address entries)
   from canonical ISR symbol names (`__attribute__((interrupt))
   _T1Interrupt` …), relocatable at runtime via the IVTBASE SFR (this
   replaces classic-dsPIC AIVT — no alternate-table config-word dance on
   33A). Consequence: a port-authored `vector_table[]` array — the thing
   BOTH existing template models teach — would FIGHT the toolchain.
   Correct move: no `startup.c` at all; use the toolchain crt0
   (disasm-verified: sets W15/SPLIM, programs IVTBASE, runs `__data_init`
   over `.dinit`, calls `__attribute__((user_init))` functions, then
   `main`) and hang pre-main clock config on `user_init`
   (dspic33ak128mc102/platform.c banner is the worked example).
2. **"The chip has atomic bit-ops" does not mean the COMPILER emits
   them**: dsPIC33A has single-instruction `bset/bclr` on SFR memory
   (interrupt-atomic, the AVR-SBI analog), and xc-dsc even uses them for
   its own interrupt builtins — but `LATB |= (1u<<3)` compiles to a
   THREE-instruction load/modify/store at `-Og` AND `-Os`
   (disasm-proven), and dsPIC33A has no LATxSET/LATxCLR alias registers
   (grepped the DFP header). So the [§1.2](#gpio-data) mixed-writer hazard
   (STEPPERS_DISABLE/SPINDLE/COOLANT from mainline + `st_go_idle()`
   inside ISR_STEP) is REAL on a chip whose ISA looks AVR-safe on paper.
   Fix shape: GPIO_BSET/BCLR wrapped in the save/restore critical
   section (gpio.h); GPIO_MWO stays bare RMW under the ISR-only writer
   discipline. `_template/gpio.h`'s [§1.2](#gpio-data) audit box now has its first
   "ISA has the instruction, codegen won't promise it" reproducer.
3. **"What barriers exist?" can legitimately answer NONE**: the dsPIC33A
   instruction set has no fence/DSB/DMB-class instruction. Single core,
   single bus master (DMA unused), no cache, in-order pipeline — the
   compiler is the only reordering agent, so `__DSB()/__DMB()` are
   compiler barriers (`asm volatile("":::"memory")`), which is exactly
   what [§12.1](#weak-memory-obligations)/[§12.4](#weak-memory-obligations) need here. SFR read-after-write pipeline hazards are
   the COMPILER's job (xc-dsc inserts visible `neop` padding after SFR
   stores). UNVERIFIED residue for Step 5: whether NVMCON command
   sequencing wants the classic-PIC SFR-readback idiom — the RM is not
   vendored; do not trust store order into the NVM controller until
   checked.
4. **Toolchain ICE is a porting-surface item, not a footnote**:
   xc-dsc-gcc 8.3.1 ICEs (`insn does not satisfy its constraints …
   movfpsf_32 … postreload`, gcode.c:1133 — an FPU float-store-to-static
   pattern) at `-O1` and `-Og` but is clean at `-O0/-O2/-O3/-Os`
   (probed all six on gcode.c). DEBUG therefore uses `-O0 -g3` (128 KB
   flash absorbs it; contrast [§14.13](#ch32v006-riscv-gaps) where small flash forced the
   opposite call). Checklist lesson: on a niche-vendor GCC fork, probe
   the optimization matrix against the float-heaviest core file (gcode.c)
   BEFORE writing any port code. Also: XC-DSC v3.30 is GCC 8.3.1 —
   C11/`_Static_assert` fine, but pin `-std=gnu11` explicitly.
5. **TRIS polarity + analog-default is a double GPIO trap**: dsPIC TRIS
   is 1 = INPUT (inverted vs AVR DDR — common/gpio.h's DREG defaults
   would set every direction BACKWARDS, silently), and analog-capable
   pins RESET TO ANALOG (digital reads stuck at 0 until ANSELx is
   cleared; ANSEL exists only for ports A/B on this device). Both folded
   into function-call direction helpers that clear ANSEL unconditionally
   (stm32f103/ch32v006 function-call precedent, new reason). CNPUx is a
   real bit-per-pin pull-up register — [§1.4](#gpio-data) satisfied by construction,
   first port where the pull-up contract cost zero thought.
6. **The [§14.3](#ch32v006-riscv-gaps) gc-sections hazard is ABSENT here, and the check method
   is now proven**: xc-dsc specs contain no gc-sections rule
   (`-dumpspecs` grepped), and the M3 link's 33-symbol PORT_TODO list
   was diffed IDENTICAL against `nm -u` over all 20 objects — the
   linker-as-checklist is complete by construction on this toolchain.
   Every future port should run that same nm-vs-link diff once before
   trusting its M3 list.
7. **dsPIC33A interrupt model upgrades on classic dsPIC in ways that
   matter to [§5.2](#isr-definition-macros)**: INTCON1 has a real GIE bit (global enable — classic
   16-bit dsPIC had only IPL games), `__builtin_get_isr_state/
   set_isr_state/disable_interrupts` map to SR.IPL + GIE save/restore
   with a single atomic `bclr` for disable (all disasm-verified → sei/
   cli/critical sections are real code, zero PORT_TODO). Priority
   nesting is native (NSTDIS=0 at reset): core's `sei()` inside ISR_STEP
   can genuinely nest the pulse-reset IRQ if Step 3 gives it a higher
   IPC priority — the first port that can honor the AVR preemption
   semantic properly instead of the M0+ "defer, don't nest" posture.
8. **Device config words join the "compiles but dead" surface**: an
   unprogrammed/default FWDT can leave the hardware watchdog running and
   reset GRBL mid-job with zero build-time signal. Minimal safe set
   (`#pragma config WDTEN = SW`, `JTAGEN = OFF`) lives in platform.c;
   the DFP's own `xc16/docs/config_docs/<device>.html` is the field
   reference. Non-Microchip analogs (option bytes, fuses) deserve the
   same Step-0 question on any future port.
9. **Pin-budget arithmetic is a contract input**: 28-pin MC102 = 19 GPIO
   (counted from the DFP atdf) vs GRBL's 20 signals; resolved by the
   AVR Uno's own precedent (cpu_map.h:110-152 — SPINDLE_ENABLE and
   SPINDLE_PWM share a pin under VARIABLE_SPINDLE), and ENABLE_M7
   `#error`s instead of silently vanishing. Boards that cannot fit a
   signal must fail loudly at compile, not drop it.
10. **Separate peripheral clock generators = a new "F_CPU lie" vector**
   ([§14.9](#ch32v006-riscv-gaps)'s class, third variant): on dsPIC33A the CPU clock (CLKGEN1)
   and peripheral clocks are independent clock generators; which CLKGEN
   feeds Timer1/SCCP/UART and at what ratio is RM-only and NOT yet
   verified. Flagged loudly in platform.h/timer.h: Step 3 must re-derive
   the stepper-timer tick from the RM before any period math — F_CPU
   describing the CPU does not describe the timers here. Also open for
   Step 1-on-silicon: the 200 MHz PLL sequence is encoded verbatim from
   Microchip's own dsPIC33A clock documentation (developerhelp), but no
   emulator exists for dsPIC33A — first hardware run must scope-verify
   the clock before anything else is trusted.
11. **DFP headers over clean-room, decided and justified**: the
   dsPIC33AK-MC DFP is Apache-2.0 (LICENSE.txt in the .atpack) — unlike
   the proprietary Atmel/ASF headers that forced samd21's clean-room
   route — AND the DFP is the compiler's own `-mdfp` source of device
   truth, so vendoring against it removes a whole transcription-error
   class instead of adding one. Precedent: license-check the vendor
   pack FIRST; clean-room is the fallback, not the default.

Items 12-18 below were found completing Steps 3-6 (timers/serial/nvmem/
handlers) — same discipline: the real toolchain (xc-dsc-gcc 8.3.1) and
the real DFP (1.5.263) were used end to end this session (both were
already installed at `/opt` from the M1-M3 session), not simulated.
`make BUILD=DEBUG` and `make BUILD=RELEASE` both compile all objects and
LINK with **zero `PORT_TODO_*`** (verified: `nm | grep PORT_TODO` on both
finished ELFs returns nothing) — Steps 3-6 are COMPLETE, not a next-batch
item anymore. Every register FACT below is cited to either the DFP
header (`p33AK128MC102.h`) or the `.atdf` (which, unlike the header,
sometimes has named `value-group`s for a field's legal values — a
stronger source than the header alone, checked per-field this session).
Two specific field classes have NO value-group in either file — grepped
exhaustively, confirmed absent — and are RM-only tables this session had
no access to; those are called out explicitly below rather than silently
guessed.

12. **Timer/vector allocation, IRQ-audited (the #14.11 lesson applied
   before allocating, not after)**: DFP's own vector table doc
   (`xc16/docs/vector_docs/PIC33AK128MC102.html`) confirms all three
   candidates have real vectors: Timer1 = stepper (`_T1Interrupt`, IRQ
   48), SCCP1 = pulse-reset (`_CCT1Interrupt`, IRQ 49), SCCP2 = spindle
   PWM (output-only, no ISR needed). No "TIM3-has-no-IRQ"-class trap
   found on this device — unlike ch32v006 (#14.11), every candidate here
   really does have an interrupt line.
13. **SCCP MOD/CLKSEL/TMRPS field encodings are RM-only — NOT in the
   vendored DFP/.atdf at all** (grepped: zero value-groups for any
   `CCPxCON1` field, unlike e.g. `NVMCON_CON__NVMOP` which does have
   one). `timer.h`/`platform.c` use MOD=0b0001 ("16-bit Timer", CCP1) and
   MOD=0b1001 ("Edge-Aligned PWM", CCP2) based on the well-established
   Microchip SCCP/MCCP family convention reused across dsPIC33CK/CH —
   **UNVERIFIED against this specific device's RM** (not vendored, no
   dsPIC33A emulator exists either). Loudly flagged in both files;
   hardware bring-up must confirm before trusting pulse width or PWM
   waveform shape.
14. **The #4 8-bit overflow-horizon contract is met WITHOUT an exact
   hardware /8 prescale** — a genuinely new resolution shape versus every
   prior port. SCCP1 has a real period-compare register (`CCP1PR`), so
   `hal_timer_pulse_count_set()` computes `ticks_needed = 256 - val`
   (1..256) and multiplies by 8 IN SOFTWARE before loading `CCP1PR`,
   running the timer at its raw tick instead of fighting a 2-bit `TMRPS`
   field that (per the assumed family encoding) offers /1,/4,/16,/64 —
   none of which is /8. This is the "or rescale" branch [CONTRACTS.md #4](#pulse-reset-timer)
   already names, exercised for the first time.
15. **PPS is two different verification classes, not one**: RPn INPUT
   muxing (`RPINRx`) is FULLY VERIFIED — the field is literally the
   source pin's own RPn number (unchanged PIC24/dsPIC PPS convention for
   over a decade; used with confidence for `RPINR9.U1RXR = 5`). RPn
   OUTPUT muxing (`RPORx`) is the opposite direction — a numeric
   function-select code from a fixed per-device table — and that table
   has **NO value-group anywhere in the vendored `.atdf`** (grepped every
   `RPOR*_RP*R` bitfield; zero results). `PPS_RPOR_FN_U1TX_UNVERIFIED`/
   `PPS_RPOR_FN_CCP2_UNVERIFIED` (platform.h) are best-effort placeholders
   (1, 2) — structurally real code, numerically unverified. This is a
   sharper and more specific gap than "RM not vendored": half of one
   peripheral's config is externally checkable today, half genuinely
   is not, and the port is honest about exactly which half.
16. **NVM flash controller — MOSTLY atdf-verified, a real surprise
   versus every prior "RM required" assumption in this file**: unlike
   almost everything else in this port, the flash controller's key facts
   ARE in the vendored `.atdf` (`dsPIC33AK128MC102.atdf` "nvm" module),
   not RM-only: `FLASH_ERASE_PAGE_SIZE_IN_INSTRUCTIONS=1024`,
   `FLASH_WRITE_ROW_SIZE_IN_INSTRUCTIONS=128` (erase page = 2048 bytes,
   program row = 256 bytes — one "instruction" = 2 bytes of address
   space, cross-checked against the `.gld`'s byte-addressed program
   region), and `NVMCON_CON__NVMOP` names its three legal values (page
   erase=0x3, row program=0x2, word program=0x1). **No NVMKEY /
   unlock-sequence register exists on this device at all** (grepped the
   full header and atdf — confirmed absent, unlike classic PIC24/
   dsPIC33F/E's 0x55/0xAA dance) — `WREN` is the write-gate used instead.
   `NVMCON.LOCK`'s exact write protocol is the one piece left UNVERIFIED
   (RM-only) and deliberately untouched. Row-program (`NVMOP=0x2`,
   source=`NVMSRCADR` pointing at a RAM buffer) is the mechanism:
   `nvmem.c` stages a whole modified page in RAM then lets the controller
   copy it back 256 bytes at a time — the same page-batched-RMW shape as
   `samd21`/`stm32_nvmem.c`, just with the hardware doing the byte-copy.
17. **No PSVPAG / classic Harvard-PSV windowing exists on this core**
   (grepped: zero `PSVPAG` anywhere in the DFP) — flash reads are plain
   pointer dereferences, no windowing needed; `no_auto_psv` on the ISR
   attributes (handlers.c) is a compatibility knob for a feature this
   specific core doesn't have. **The NVMEM window reservation is
   link-tested, not theoretical**: `__attribute__((address(0x81F800)))`
   on a `static const` array places it at a fixed flash address and
   links CLEAN against the *unmodified* vendor `.gld` (verified this
   session with a minimal standalone test before writing `nvmem.c`
   proper: object placed exactly at the requested address, zero link
   errors). No port-authored linker script needed to reserve the window —
   a real gap the #16.1 note ("decide in Step 5") left open, now closed:
   any future code-size growth that collides with the window fails the
   link LOUDLY (`ld` error: overlapping/out-of-region), never silently
   corrupts, matching the contract's preferred failure mode everywhere
   else in this file.
18. **UART1 is a NEW register model, not the classic dsPIC UxMODE/UxSTA
   shape** — this device's UART (`U1CON`/`U1STAT`/`U1BRG`/`U1RXB`/
   `U1TXB`) was mined fresh from the DFP this session; there was no donor
   port to reuse (first UART for this ISA family). `U1BRG` is a 20-bit
   register (not the classic 16-bit `UxBRG`) with a `BRGS` high-speed
   mode bit; the divisor formula (`BRG = round(Fp/(4*baud)) - 1` under
   BRGS=1) is standard PIC-family arithmetic, but `U_CON__BRGS`'s atdf
   value-group only names "enabled/disabled", not the underlying divisor
   ratio — used with high but not RM-certain confidence. `U_CON__MODE`
   IS atdf-verified (`OPTION_9` = "Asynchronous 8-bit UART", value 0x0) —
   this one field's exact meaning is fully checkable, unlike most others
   in this section.
19. **Delay primitives use a real toolchain library mechanism, not a
   hand-rolled busy-loop**: `__delay32()`/`FCY` (from the shipped
   `libpic30.h`, confirmed present and link-tested this session with no
   extra Makefile flags) is XC-DSC's own calibrated cycle-count delay —
   `_delay_us/_delay_ms` (handlers.c) narrow to it directly. `FCY`
   (instruction-cycle frequency) is ASSUMED == `F_CPU`, consistent with a
   32-bit DSC's typical 1-cycle-per-instruction pipeline class but
   UNVERIFIED against this device's RM — the same open question as every
   other Fp-vs-F_CPU assumption in this port (#10 above).
20. **CN (Change Notification) edge-style is ASSUMED, not atdf-checkable**:
   `CNCONx.CNSTYLE`, `CNEN0x` (rising-edge enable) and `CNEN1x`
   (falling-edge enable) exist in the DFP header with no accompanying
   description; the port assumes the well-established enhanced-CN model
   (CNSTYLE=1 = edge-select style using both CNEN registers together for
   any-change detection, matching contract #2.6) used across PIC24/
   dsPIC33 for over a decade. Both LIMIT (port D) and CONTROL (port A)
   each own a dedicated port and vector (`_CNDInterrupt`/`_CNAInterrupt`)
   so the #14.12 EXTI-line-collision class does not apply here (already
   noted at #9 above, re-confirmed while implementing).


<a id="fp-precision"></a>
## 17. FP precision is a DECLARED port property (found dieting ch32v006 —
    **RUNTIME-PROVEN on samd21 under Renode, 2026-07-25**)

1. **The origin semantics**: avr-gcc has `double == float` (32-bit).
   Every unsuffixed double literal in core (`0.5*x`, `1.0-y`) and every
   unsuffixed libm call (`sqrt`, `atan2`, `sin`, `cos`, `floor`, `ceil`,
   `round`, `lround`, `trunc`, `fabs`) has therefore been SINGLE
   precision on the origin AVR since 2009. The AVR semantics ARE the
   template semantics — core is float-typed throughout and its authors
   never bought 64-bit math; the unsuffixed spellings are an avr-gcc
   idiom, not a precision request.
2. **What happens if a port ignores this**: on any target where double
   is a real 64-bit type, those same expressions promote for real.
   Measured on ch32v006 (rv32ec soft-float, RELEASE): ~13.5KB of text.
   Measured on samd21 (Cortex-M0+, no FPU, RELEASE, `-Os -flto`):
   **43036 → 31952 text, −11084 bytes (−25.8%)** — DP soft-float
   (`__aeabi_dadd/dsub/dmul/ddiv`, the `__aeabi_dcmp*`/`__*df2` compare
   set, `__aeabi_i2d/ui2d/f2d/d2iz/d2uiz`) plus DP libm
   (`__ieee754_atan2`, `__ieee754_sqrt`, `__ieee754_rem_pio2`,
   `__kernel_sin/cos/rem_pio2`, `atan`, `sin`, `cos`, `sqrt`, `floor`,
   `ceil`, `round`, `lround`, `trunc`, `fabs`, `scalbn`) — 43 defined
   DP symbols gone, all of it code the AVR binary never contained,
   computing precision core immediately truncates back to float. Two
   independent ports, two architectures, the same ~25%: this is not a
   ch32 quirk, it is what the promotion costs.
3. **The knob** (reference: ch32v006/Makefile + boards/generic/prelude.h,
   samd21/Makefile + {megarm,generic}/prelude.h; inherited pattern:
   `_template`): `FP ?= SINGLE`.
   - `FP=SINGLE` (default) = template-faithful AVR `double==float`
     semantics, pinned by two platform-side mechanisms (ZERO core
     edits): `-fsingle-precision-constant` (unsuffixed literals stay
     float) and a prelude libm mapping (`#include <math.h>` first, then
     function-like macros `#define sqrt(x) sqrtf(x)` ... — call-site
     rewriting only; prototypes and bare identifiers untouched; beats
     `-Wl,--wrap`, which would keep the double ABI at every call site
     plus pay for narrowing wrappers). The shim goes in EVERY board's
     prelude, not one of them — boards are selected by which prelude the
     Makefile injects, so a board without the shim silently opts out.
   - `FP=DOUBLE` = conscious deviation, MORE precise than the template,
     and must be declared in the port's docs. Intended for ports with a
     native DP FPU (dsPIC33AK class) where DP costs cycles, not
     kilobytes. The M0+/rv32ec class is exactly who should never use it.
   - There is NO libc-side escape hatch: picolibc/newlib on rv32/ARM
     have no 32-bit-double build option — double width is fixed by the
     ABI (`ilp32e`/AAPCS), confirmed on this toolchain. The knob is the
     mechanism.
4. **Enforcement — the linker is the truth**: under `FP=SINGLE`,
   `tools/assert_no_double.sh <nm> <elf>` runs post-link and FAILS the
   build listing offenders if any DP arithmetic/compare soft-float or
   DP libm symbol is DEFINED in the image. Pure format conversions
   (`__aeabi_d2f`, `__extendsfdf2`, `__truncdfsf2`, `__fix*dfsi`,
   `__float*df`) are deliberately tolerated: a conversion cannot
   compute, and they legitimately survive at legacy double-typed ABI
   boundaries. Under `FP=DOUBLE` the assert is disarmed — that's the
   declaration.
   **The assert earns its keep — samd21 proved it.** The compile flags
   alone left `__aeabi_dsub/dcmpgt/dmul` in the image (35892 text, assert
   RED) because `_delay_ms()` still did its sub-millisecond remainder in
   double (`__ms - (double)ms`, `rem > 0.0`, `rem * 1000.0`) *behind* a
   boundary that had already been "narrowed at entry". Narrowing at entry
   is necessary and NOT sufficient: what matters is that no DP
   **arithmetic** exists anywhere past the boundary. Fixing it (a float
   worker `delay_us_f()`; `_delay_us/_delay_ms` narrow once via
   `__aeabi_d2f` and never widen again) took the remaining 3940 bytes and
   left exactly ONE tolerated symbol in the whole image: `__aeabi_d2f`.
   Verified both directions this session: armed → PASS on the SINGLE
   ELF; the same script run against the `FP=DOUBLE` ELF (43020 text)
   correctly lists 21 offenders and exits 1.
5. **Accuracy is not a regression — NOW PROVEN AT RUNTIME, not just at
   compile time.** The samd21 twin is the arbiter for this change class
   because it has the Renode motion smoke, and the smoke was extended
   with the paths that hammer SP libm hardest. Evidence, `FP=SINGLE`
   DEBUG ELF on emulated ATSAMD21G18A (`ci/renode/smoke.sh --arc`,
   Renode 1.16.1):
   - boot + `Grbl 1.1h` banner on SERCOM3; `$$` settings dump complete
     through `$132=`;
   - linear stage `G91` + `G0 X1`: MPos 0.000 → 1.000, monotonic, Idle;
   - **arc stage `G2 X2 I1 F200`** — the only core path calling
     `atan2`/`sqrt` (arc geometry) and `cos`/`sin` (per-segment rotation
     matrix, re-corrected every `N_ARC_CORRECTION` segments). A CW
     semicircle from (1,0) about centre (2,0). Result across 40+ status
     samples: **no NaN/inf, no error:/ALARM:**, Y rose 0 → **peak exactly
     1.000** at X≈1.99 (true radius 1.000 — the arc was genuinely
     interpolated, not degenerated to its chord) and came back down to
     land on **(3.000, 0.000, 0.000), Idle** — the exact commanded
     endpoint, zero drift;
   - **dwell `G4 P0.5`** (float-seconds `delay_sec` → `_delay_ms`, the
     last double-typed ABI boundary): `ok` in 0.44 s wall, back to Idle;
   - physical step evidence throughout: X STEP (PA25) driven high **410
     times** (PORT-write hook in `samd21_smoke.resc`) — real pin toggles,
     not the BUG #17 phantom-motion class;
   - reproduced across runs, and the arc/dwell stages also passed on a
     `BOARD=generic` DEBUG image (only the PA25 pin assertion is
     megarm-specific) — both boards' prelude shims are exercised.
   Verdict: **SP-RUNTIME-PROVEN**. Single-precision arc/junction/stepper
   math is contract-faithful — it is what every AVR machine has run since
   2009, and it now demonstrably produces the same trajectory on a
   64-bit-double target. The compile-only embargo on other ports
   shipping `FP=SINGLE` pins is LIFTED; `assert_no_double.sh` PASSING is
   the bar, and any port whose motion smoke exists should still run it.
6. **AVR golden untouched by construction**: on avr-gcc the knob's
   mechanisms are no-ops (`double==float` regardless), and the AVR build
   doesn't include platform preludes anyway. Re-verified this session:
   text 30640 / grbl.hex MD5 79af184e67b27defd27a39309ac53563, exact
   golden match.
7. **ROLLOUT COMPLETE, 2026-07-26** — every remaining port now carries the
   knob: ch32v006, stm32f103, stm32h523, stm32f411 (samd21 was already
   landed; see point 5). Copied faithfully from the samd21 pattern, zero
   reinvention: `FP ?= SINGLE` Makefile block (`-fsingle-precision-constant`
   + `-DGRBL_FP_SINGLE`, both build flavors), the SP libm call-site shim in
   every board/prelude that can be selected, `tools/assert_no_double.sh`
   wired post-link on `$(ELF_FILE)`. Measured RELEASE deltas (text, `-Os
   -flto`): ch32v006 54904 → **41072** (−13832, −25.2%); stm32f103 33924 →
   **28700** (−5224, −15.4%); stm32h523 32448 → **25132** (−7316, −22.5%);
   stm32f411 32660 → **25796** (−6864, −21.0%). `assert_no_double.sh`
   PASSED on every RELEASE and DEBUG image, on the first build, for
   stm32f103/h523/f411 — those three ports' `_delay_ms(double)` was already
   a bare `(uint32_t)ms` truncation with no arithmetic behind the boundary,
   so there was no leak of the delay-remainder class to find. ch32v006 DID
   have the samd21-class leak: `_delay_ms()`'s sub-ms remainder was computed
   in `double` (`__ms - (double)ms`, `rem * 1000.0`) behind an
   already-narrowed entry point — this is the ORIGINAL PROBE CHIP where the
   ~13.5KB DP figure in point 2 was first measured, and its knob had never
   actually landed (the probe lived in a throwaway worktree). Fixed with
   the identical `delay_us_f()` float-worker pattern samd21 used: one
   `(float)` narrowing per public entry point, arithmetic never widens back
   to double. Confirms the general lesson from point 4/5 generalizes across
   both architectures this port family spans (rv32ec soft-float and ARM
   soft-float alike): narrowing at entry is necessary, not sufficient — the
   assert is what actually proves it, not the flags or the cast.
   shared-Makefile note: stm32f103/h523/f411 all include one
   `common/stm32/common.mk` — the `FP` knob, the `ASSERT_FP` hookup, and the
   help text were added there ONCE and apply to all three. The SP libm
   prelude shim is NOT shared the same way: CONTRACTS demands the shim live
   in every board/prelude the Makefile can inject (point 3), so each port's
   own `prelude.h` (none of the three has a `boards/` subdir — one prelude
   per port) got its own copy of the shim block, not a `#include` of a
   common one, so a future STM32 port added without copying the shim fails
   loud (assert RED) instead of silently inheriting it by accident.
   **stm32f411 FPU FINDING — the interesting case.** f411 is Cortex-M4F
   with a real `fpv4-sp-d16` single-precision-only hardware FPU
   (`-mfloat-abi=hard`, already the port's existing flag pre-rollout).
   Disassembly of the RELEASE ELF, before vs. after `FP=SINGLE`: BEFORE —
   `sqrt()` resolved to `__ieee754_sqrt` (software double-precision path),
   287 `bl __aeabi_d*` soft-float call sites, 0 `vsqrt.f32` instructions
   anywhere in the image (42 `vmul.f32`/22 `vadd.f32` already existed, from
   code that was float-typed on both sides of the operator and so never
   promoted). AFTER — `sqrtf()` compiles to exactly one instruction,
   `vsqrt.f32 s0, s0` (confirmed in `objdump -Sxdstr` output); `vmul.f32`
   count rose to 82 (+40), combined `vadd/vsub/vdiv.f32` rose to 161
   (+139); `bl __aeabi_d*` / `bl sqrt` call sites: **0**. The entire
   soft-float call population that fed arc/junction/trig math moved onto
   real FPU instructions. Verdict: on an FPU-bearing SP-only chip this knob
   is a genuine SIZE **and** SPEED win simultaneously — the hardware was
   already present and paid for in the BOM, it was being starved by DP
   promotion turning every `sqrt`/`atan2`/`sin`/`cos` call into a library
   call the FPU could not execute. stm32h523 (Cortex-M33, `fpv5-sp-d16`,
   also single-precision-only hardware) is architecturally the same case;
   its −22.5% RELEASE delta is consistent with the same mechanism but was
   not separately disassembled this batch.
   Gates: AVR golden `make -C grbl/platform/atmega328p validate` **PASSED**
   (MD5 `79af184e67b27defd27a39309ac53563`, text 30640, unchanged); samd21
   re-measured on both boards/both flavors, **unchanged** at 31952/296
   RELEASE (megarm and generic both assert-PASS); all four converted ports
   build and assert-PASS on both DEBUG and RELEASE (8 images); STM32
   boot-integrity check (BUG #21 ratchet, [§18](#vector-table-lto)) PASSED on all 6 STM32
   images; ch32v006's RISC-V `_start`-at-flash-base boot check PASSED on
   both flavors. `FP=DOUBLE` re-verified as a true no-op vs. pre-rollout
   HEAD on all four ports (byte-identical text to the pre-knob baseline)
   before switching each to the `FP=SINGLE` default.
7. **dsPIC33AK128MC102 IS the intended first conscious `FP=DOUBLE`
   consumer, landed (Steps 3-6, this session)** — [§17.3](#fp-precision)'s own framing
   named this chip class ("ports with a native DP FPU ... where DP costs
   cycles, not kilobytes") before this port existed to prove it; it now
   does. `Makefile` sets `FP ?= DOUBLE` (this port's own default, the
   opposite of every prior port), disarms `assert_no_double.sh`
   (`FP=DOUBLE: declared-double port property ... no-DP assert
   disarmed`, printed post-link both flavors), and documents WHY inline:
   the hardware DP FPU makes 64-bit float arithmetic a native operation
   rather than either free-because-identical (AVR) or tens-of-soft-float-
   instructions (every M0+/rv32ec port so far). `FP=SINGLE` remains wired
   (the knob stays bidirectional — `boards/generic/prelude.h` carries the
   same SP libm call-site shim as samd21's, guarded by `GRBL_FP_SINGLE`)
   but is not this port's declared default and has not been runtime-
   exercised (no dsPIC33A emulator exists, [CONTRACTS.md #16](#dspic33ak128mc102-gaps)). Both
   `FP=DOUBLE` flavors (the default) link with zero `PORT_TODO_*`: RELEASE
   ~41.8KB code / DEBUG ~53.2KB code (both well inside the 128KB budget) —
   see [CONTRACTS.md #16](#dspic33ak128mc102-gaps) items 12-20 for the Steps 3-6 register-fact
   writeup this build rests on.

<a id="vector-table-lto"></a>
## 18. KEEP() does not survive LTO: vector tables need a real code reference

*(Section number assigned by the BUG #21 work item; [§17](#fp-precision) is FP precision, landed
RUNTIME-PROVEN by the concurrent workstream.)*

Empirical, from BUG #21: stm32f103, stm32f411 and stm32h523 RELEASE
binaries shipped with **no vector table at all**. Not a corrupted table —
absent. The `.bin`'s first word was code, so the core loaded garbage into
SP and PC and the chip could not boot. Every one of those ports had the
supposedly-canonical guard in place:

```ld
KEEP(*(.isr_vector))    /* Vector table */
```

**Why the guard is not a guard.** `KEEP()` is a *link-time* instruction:
it tells `ld` not to garbage-collect an input section it can see. Under
`-flto` the deletion happens one stage earlier. GCC's whole-program IPA
runs over the LTO bytecode before codegen, sees that nothing in the
program reads `vector_table[]`, and drops the object. `ltrans` then never
emits a `.isr_vector` input section, so `KEEP()` matches zero sections
and has nothing to protect. The link succeeds. `--gc-sections` is happy.
`size` reports a plausible number.

**The cascade is worse than a missing table.** With no table, nothing
references the ISRs, so LTO deletes those too (`nm | grep -c Handler`
went from ~40-70 down to **1**). With the serial RX ISR gone, nothing
ever writes the RX ring buffer, so LTO const-propagates it empty and
deletes `serial_rx_buffer_head` outright. With the buffer provably empty,
the G-code dispatch path (`protocol.c:98-101` → `gc_execute_line`) is
unreachable and gets dead-path-eliminated. One missing reference silently
strips the interpreter out of a CNC firmware. On f103 that showed up as a
*smaller* binary — 29900 bytes of text where the honest figure is 33924.
**A RELEASE build that shrinks for no reason is a symptom, not a win.**

**Signature: DEBUG works / RELEASE bricks.** DEBUG builds have no `-flto`,
so IPA never runs, the table is emitted, `KEEP()` works, and everything
looks correct. Any bug report of this shape should be checked here first.

### Two defense-in-depth mechanisms, plus one mandatory check

1. **A real code reference.** `Reset_Handler` must write
   `SCB->VTOR = (uint32_t)vector_table;` as its first action. Taking the
   address in emitted code is what makes the table reachable to IPA. This
   is why samd21 was immune by accident (commit d5a2227 added the VTOR
   write for bootloader-offset reasons and anchored the table as a side
   effect). It also earns its keep: it makes the image robust to being
   entered from a bootloader whose VTOR still points at its own table.
2. **`__attribute__((used))` on the table.** Belt to the VTOR write's
   braces — states the liveness directly rather than relying on IPA
   tracing the address-taking.
3. **A post-link BOOT INTEGRITY check. Mandatory, not optional.** Every
   ARM port runs `grbl/platform/common/boot_check.sh` after `objcopy`:
   read word0/word1 of the finished `.bin`, require word0 to look like an
   initial SP (`0x2xxxxxxx`, 4-byte aligned) and word1 to look like a
   Thumb reset vector (odd, inside the image's flash window), fail the
   build printing the actual bytes otherwise. Wired into
   `common/stm32/common.mk` (all STM32 ports inherit it), `samd21/Makefile`
   and `_template/Makefile` (every future port inherits it).

**(1) and (2) are not both load-bearing on this toolchain — corrected.**
The original writeup for this fix claimed all three were jointly
required. Re-tested empirically on stm32f103 (GCC 13.2.1, `-Os -flto`)
by disabling each in turn while keeping the other: `used`-attribute alone
(VTOR write commented out) links a table that survives IPA and passes
`boot_check.sh` unchanged; VTOR-write alone (`used` removed from the
attribute) does the same. Either mechanism alone is sufficient on this
compiler at this optimization level. Both are kept anyway, as
**defense-in-depth across compilers and optimization levels**: (1) is
real codegen-visible address-taking, which some future IPA implementation
could in principle reason its way around if the store is provably
dead-store-eliminated elsewhere; (2) is an explicit liveness annotation
that doesn't depend on IPA tracing an address-of at all. They fail for
different reasons, so keeping both costs nothing and covers more ground
than either alone. (3), the boot-integrity check, is the only one of the
three that is actually mandatory — it is what notices when a future
change breaks (1), (2), or both.

### A linker ASSERT is NOT a substitute — verified, not assumed

`ASSERT((vector_table & 0xFF) == 0, ...)` does **not** catch a vanished
table. Tested by reverting the fix: `ld` resolves the now-undefined
`vector_table` to 0, and `(0 & 0xFF) == 0` passes. The ASSERT guards
alignment only. Keep it for that, and do not mistake it for the guard.

### VTOR alignment (ARMv7-M / ARMv8-M)

VTOR ignores bits [6:0], so the table needs **at least** 128-byte
alignment, and architecturally the next power of two ≥ `4 × vector_count`:
f103/f411 (59 vectors, 236 B) → 256; h523 (77 vectors, 308 B) → 512;
samd21 → 256. Each `script.ld` carries the matching `. = ALIGN(n)` before
`KEEP(*(.isr_vector))` plus an `ASSERT` on the resulting address. The
ALIGNs are no-ops at today's `FLASH ORIGIN` values — they exist so the
guarantee survives an ORIGIN move for a bootloader.

### Non-ARM ports

RISC-V has no SP-in-word0 convention: a QingKe RV32EC just begins
executing at the flash base and `_start` (naked, in `.init`) sets SP
itself, so word0 is an instruction by design. The *class* of failure is
still live, so ch32v006 asserts the architecture-appropriate invariant
instead — `_start` must link at the flash base — and its Makefile
documents why the word0 form is N/A. **A port may translate this check;
it may not drop it.**

<a id="guard-hardening"></a>
## 19. Guard hardening: two lessons from an adversarial review of §17/§18

An adversarial review of the FP=SINGLE assert ([§17](#fp-precision)) and the boot-integrity
ratchet ([§18](#vector-table-lto)) — the two newest guards at the time — found both were
weaker than they looked, with working exploits, not just theoretical
gaps. Both are fixed; the lessons are recorded here so the pattern is
recognized earlier next time.

### Lesson 1: a guard that checks the wrong symbol family is worse than no guard — it certifies

`tools/assert_no_double.sh` denied double-precision machinery by matching
the *generic* libgcc soft-float names: `__adddf3`, `__subdf3`, `__muldf3`,
`__divdf3`, the `__*df2` compares. Those are what a hosted (non-EABI)
libgcc emits. **Every target this project ships is ARM**, and
arm-none-eabi-gcc's libgcc renames every soft-float double libcall to the
`__aeabi_*` AAPCS family instead — `__aeabi_dadd`/`dsub`/`dmul`/`ddiv`,
never the generic names. The assert was checking a symbol family that
never appears in any object this repo produces.

Demonstrated exploit: an object doing plain `double a; ... (a+b)-(a*b)/(b-a);`
linked on this toolchain contains `__aeabi_dadd`, `__aeabi_dsub`,
`__aeabi_dmul`, `__aeabi_ddiv` and **zero** `__adddf3`-family symbols. The
pre-fix script reported `FP=SINGLE post-link assert PASSED: no DP
machinery`, exit 0, on a binary that had just linked real 64-bit
arithmetic. A green check that never fires is a missing check; a green
check that *actively reports clean on a poisoned build* is worse — it is
load-bearing evidence in the wrong direction, and everything downstream
(a reviewer, a CI dashboard, a future porter skimming the log) treats
"PASSED" as proof of the property it was supposed to verify. **A guard
that checks the wrong symbol family doesn't fail to protect — it
certifies the exact thing it exists to catch.**

Fix: the denylist now matches both families (generic and `__aeabi_*`),
plus `__muldc3`/`__divdc3` (complex double, genuine computation under
either naming scheme) and `__floatdidf` (64-bit int→double widening,
unlike its 32-bit sibling `__floatsidf` has no legitimate call site in
this codebase). A `--selftest` mode (style matched to
`ci/warn_ratchet.py --selftest`) builds a synthetic "pure `__aeabi_*`
arithmetic, zero generic names" symbol table — the exact shape of the
demonstrated exploit — and asserts the script catches it, end to end
through the real entry point with a fake `nm`, so this specific class of
blindness has a permanent regression test and cannot silently reappear
via some future "helpful" refactor of the regex.

**General takeaway:** when a guard is defined as a name/pattern denylist
or allowlist, the question to ask before trusting a PASS is not "does the
pattern look reasonable" but "did I verify the pattern against what THIS
toolchain, on THIS target, actually emits" — generic documentation for a
tool family (libgcc) is not evidence for a specific ABI (AAPCS/EABI) of
it. A regex that was correct for a different platform than the one
shipping is a guard in name only.

### Lesson 2: a guard is only as good as the build system's failure handling around it

`boot_check.sh` ([§18](#vector-table-lto)) and `assert_no_double.sh` ([§17](#fp-precision)) both run as a
recipe step *after* the artifact they inspect already exists on disk
(`objcopy` writes the `.bin` before `boot_check.sh` runs on it; `$(CC)`
writes the `.elf` before `$(ASSERT_FP)` runs on it). Neither guard failing
deletes what it just condemned. Without `.DELETE_ON_ERROR:` (a *make*
built-in, off by default), a failed recipe leaves its half-built target
sitting on disk with a fresh mtime — and the next invocation of `make`
compares that mtime against its prerequisites, sees the target is newer,
concludes "up to date", and skips the recipe **and the guard inside it**
entirely. The guard is real; the build system serves its own scar tissue
around it.

Demonstrated exploit (reproduced live on samd21, see PLAN.md): inject
genuine double-typed arithmetic into `platform.c` (a `volatile double`
pair that `-fsingle-precision-constant` cannot neutralize — the flag only
touches unsuffixed FP *constants*, not the type of already-double
variables) and build `FP=SINGLE` without `.DELETE_ON_ERROR:`. First
`make`: link succeeds (writes the ELF), `assert_no_double.sh` correctly
FAILS and lists the offenders, `make` exits 2 — but the poisoned ELF is
still on disk. Second `make`, no source changes: exit 0, `objcopy`/`hex`/
`bin`/`dump` all run straight off the stale DP-poisoned ELF, no relink, no
re-assert. A build that failed loudly once is served as a success forever
after, silently, until someone touches a source file.

Fix: `.DELETE_ON_ERROR:` added to every platform Makefile that didn't
have it (`grbl/platform/common/stm32/common.mk`, `samd21/Makefile`,
`ch32v006/Makefile`, `_template/Makefile`, `dspic33ak128mc102/Makefile`,
`sg2002/Makefile`). With it: the same first `make` still fails, but GNU
Make prints `Deleting file '.../grbl_samd21.elf'` and removes it; the
second `make` has no choice but to redo the full chain, and fails again,
honestly, every time, until the underlying defect is fixed.

**General takeaway:** a post-link/post-objcopy check is not a complete
guard by itself — it is a guard *plus an assumption* that a failed recipe
leaves nothing behind for the next invocation to trust. That assumption
is false in GNU Make unless `.DELETE_ON_ERROR:` is set. Any future
platform Makefile (copy-me template included) must carry this line from
day one, not bolt it on after the first bricked artifact is found
surviving in the wild.

<a id="wch-isr-attribute"></a>
## 20. Vendor ISR attribute silently ignored on mainline GCC: WCH's `"WCH-Interrupt-fast"` degrades to a plain function (CH570 recon)

Found while closing the QingKe V3C interrupt-entry question for the CH570
port (PLAN.md rolling-ports queue) — before writing any handler code, not
theoretical.

WCH's own SDK (`openwch/ch570`, Apache-2.0, `CH57x_common.h`) and the
independent `cnlohr/ch32fun` (MIT) both pair `INTSYSCR.HWSTKEN=1` with
`__attribute__((interrupt("WCH-Interrupt-fast")))` on every ISR. That
attribute-argument string is not a GCC RISC-V feature — it exists only in
WCH's own forked compiler (and the xPack build derived from it).

Empirically tested against the exact toolchain this project already uses
for ch32v006 (`riscv64-unknown-elf-gcc` 13.2.0, the apt
`gcc-riscv64-unknown-elf` package ch32v006/Makefile documents as its
build): compiling a function with
`__attribute__((interrupt("WCH-Interrupt-fast")))` produces only
`warning: argument to 'interrupt' attribute is not '"user"', '"supervisor"',
or '"machine"' [-Wattributes]` — no error, build succeeds — and the
compiler silently treats the function as ordinary code. Disassembly
confirms it: only `s0` is saved (the caller-used `a4`/`a5` registers get
NO interrupt-frame save), and the function ends in a plain `ret`, not
`mret`. `ret` pops `ra` and jumps; it does not restore `mepc`/`mstatus`.
An ISR built this way never correctly returns from a trap.

RULE for every WCH/QingKe port on this toolchain: leave `INTSYSCR` (CSR
0x804) at its reset value 0 — explicitly write 0 as defense-in-depth,
don't rely on reset state alone — and use the plain
`__attribute__((interrupt))`, machine mode, GCC's own default, verified
correct by disassembly in CONTRACTS [§14](#ch32v006-riscv-gaps) item 2 (`mret` = opcode
`0x30200073`). NEVER adopt the vendor's `__INTERRUPT`/`WCH-Interrupt-fast`
macro on a mainline toolchain — it is written for WCH's forked compiler
and does not carry over to this project's apt-installed one.

**General lesson beyond WCH:** when a vendor SDK's ISR macro carries a
non-standard attribute argument, a clean compile is not evidence the
mainline toolchain did what the vendor's compiler does — GCC accepts an
unrecognized attribute argument with a warning, not a hard error, and
quietly no-ops the attribute. Verify by DISASSEMBLY that the expected
return instruction (`mret`/`reti`/`rte`, architecture-dependent) is
actually emitted before trusting any vendor interrupt macro on a
toolchain the vendor didn't ship. A warning is not a failure signal here,
and the build succeeding either way is exactly what makes this trap
silent.
<a id="static-assert-sweep"></a>
## 21. `_Static_assert` sweep — four more contracts made compile-time facts
(PLAN.md Phase 2, 2026-07-26)

Beyond the CPU_FREQ example (samd21/platform.h:50), four more contract
classes from this document are now enforced at compile time instead of
living only in prose or a code comment:

1. **[§6.2](#spindle-pwm) duty domain, "duty-cap-twins" class**:
   `_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255, ...)` — added to
   stm32f103/platform.h, stm32h523/platform.h, stm32f411/platform.h,
   ch32v006/boards/generic/config.h, dspic33ak128mc102/boards/generic/
   config.h, `_template`/boards/generic/config.h. This is the exact
   contract h523 and f103 both violated (`SPINDLE_PWM_MAX_VALUE=1000`
   against a `uint8_t` core duty, capping actual duty at 25.5%) before
   REVIEW #3 caught it by inspection — a build-time assert would have
   caught both instances the moment the wrong value was typed.
   **CLOSED 2026-07-26 — the class now has NO exception on any port.**
   samd21 (megarm + generic) originally did NOT get this assert: both
   boards declared `SPINDLE_PWM_MAX_VALUE 65535` against `PER = 0xFF`
   ([§6.2](#spindle-pwm)) — a live, tracked violation, not a stale doc — and
   adding the assert at sweep time would have turned a runtime bug into an
   unrelated build break. That fix has now landed in its own Renode-verified
   batch, as the exclusion comment instructed: both boards' `config.h` now
   declare `SPINDLE_PWM_MAX_VALUE 255` (matching `PER` exactly, correct by
   construction) and carry the identical `_Static_assert` the other 6 ports
   have. Truth was established before the fix, not assumed: a fresh DEBUG
   build reproduced the exact `-Woverflow` diagnostic
   (`unsigned conversion from 'int' to 'uint8_t' ... changes value from
   '65535' to '255'`), and disassembly of `spindle_control.o` showed
   `spindle_compute_pwm_value`'s `pwm_value = SPINDLE_PWM_MAX_VALUE`
   assignment already compiled to `movs r2, #255` / `strb r2, [r3, #0]` —
   that ONE site was harmless because the `uint8_t` assignment truncates at
   compile time regardless of the declared macro value.
   **BUG #22 (reclassified from "no behaviour change" — the commit
   introducing this fix, 022e50c, is wrong on that point): a second,
   unguarded use site exists.** `spindle_control.c:45`,
   `pwm_gradient = SPINDLE_PWM_RANGE/(settings.rpm_max-settings.rpm_min)`,
   consumes `SPINDLE_PWM_RANGE` (`MAX-MIN`) in a **float** context, where no
   `uint8_t` truncation ever applied. Full RELEASE-object `objdump` diff of
   022e50c~1 vs 022e50c, both boards: exactly one word differs, at
   `spindle_init()+0x84` (file offset `0x34c`): `0x477ffe00` (`65534.0f`)
   -> `0x437e0000` (`254.0f`) — the `SPINDLE_PWM_RANGE` literal folded into
   `spindle_init()`'s gradient computation. Reproduced independently with a
   standalone host build of the unmodified function body against samd21's
   actual `DEFAULTS_GENERIC` `$30`/`$31` (`rpm_max=1000`, `rpm_min=0`):
   `pwm_gradient` was `65.534` before vs `0.254` after (a 258x error), and
   `spindle_compute_pwm_value()` for representative commanded speeds came
   out as (pre-fix -> post-fix pwm register byte): S100 154->26, S500
   255->128, S900 101->229, S999 189->254 — i.e. before the fix, PWM duty
   for nearly every commanded RPM below `rpm_max` was an unrelated wrapped
   (mod 256) value, not the requested duty. (S1000/S12000/S24000 all
   saturate to 255 either side of the fix because `DEFAULTS_GENERIC`'s
   `rpm_max` is 1000 and the clamp branch `rpm >= settings.rpm_max` short-
   circuits before `pwm_gradient` is used — the bug is invisible exactly at
   and above `rpm_max`, which is why disassembly-only or boundary-only
   testing missed it.) This was a real, silent spindle-speed-output defect
   on every samd21 board for the entire time `SPINDLE_PWM_MAX_VALUE` was
   65535, not a cosmetic/no-op change — 022e50c's "disassembly byte-
   identical" and "behaviour-preserving by construction" claims covered only
   the one `uint8_t` call site they disassembled and did not check
   `spindle_init()`, where the actual functional bug lived.
   The commit's own runtime evidence (Renode `M3 S1000` -> `ok`, `?` ->
   `FS:0,1000`) does not contradict this: S1000 lands exactly on the
   `rpm >= settings.rpm_max` saturation branch under `DEFAULTS_GENERIC`, so
   that one probed value was never able to exercise the broken gradient
   path — the smoke test happened to probe the one input class immune to
   the bug it was checking for.
   The `_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255, ...)` added by this
   same commit is still the correct, sufficient fix (`MAX_VALUE=255` makes
   `SPINDLE_PWM_RANGE` correct in both the float and uint8_t contexts) —
   only the commit's characterization of what was broken before it was
   wrong. Cross-checked with a `git stash`/rebuild/`stash pop` A-B size
   comparison on both boards (0 byte delta — the literal-pool constant swap
   costs no bytes) and a full Renode `smoke.sh --arc` run (banner/settings/
   motion/arc/dwell all PASS, exit 0) plus a live `M3 S1000` / `M5` spindle
   command exchange over the emulated UART (both acknowledged `ok`, no
   error/ALARM) — none of that runtime evidence was wrong, it just didn't
   probe the affected RPM range. The `ci/warn_baseline_samd21.txt`
   `-Woverflow` entry this exact truncation had recorded is removed
   (one-way ratchet, removal-on-real-fix direction), confirmed gone from
   fresh logs on all 4 megarm/generic × DEBUG/RELEASE combos.
   **Per-port audit (2026-07-26, re-verified, not assumed):** every other
   port's `SPINDLE_PWM_RANGE` was checked against its actual hardware PWM
   period register — atmega328p `PER`=255 (cpu_map.h, AVR fast-PWM hardware
   top, origin platform); stm32f103/stm32f411/stm32h523 `TIM1->ARR` = 255;
   hc32f460 `TMRA_1->PERAR` = 255; ch32v006 `ATRLR` = 255;
   dspic33ak128mc102 `CCP2PR` = 255; ch570 `R8_PWM_CONFIG =
   RB_PWM_CYC_256` (fixed 256-step/8-bit hardware cycle, matching
   `SPINDLE_PWM_MAX_VALUE=255` exactly) — all declare `MAX_VALUE=255`,
   `RANGE=254`, sane against their PER in every case; none exhibits this
   bug. sg2002 has no `VARIABLE_SPINDLE`/`SPINDLE_PWM_*` configuration at
   all (out of scope). hc32f460 and dspic33ak128mc102 predate 022e50c in
   the repo's history (`git merge-base --is-ancestor` confirms both are
   ancestors of 022e50c); ch570 landed after it (d4c5245) and was authored
   with `SPINDLE_PWM_MAX_VALUE 255` and the `_Static_assert` from its first
   commit — samd21 was the only port ever to carry the 65535 declaration.
2. **[§10](#nvmem-eeprom) NVMEM window vs cache buffer, BUG #20 class**: stm32h523 and
   stm32f411 already had `_Static_assert(FLASH_PAGE_SIZE * FLASH_NUM_PAGES
   <= NVMEM_WINDOW_SIZE, ...)`; stm32f103 (sharing the same
   `common/stm32/stm32_nvmem.c` cache-buffer pattern) was missing the
   sibling assert — added, identical wording. samd21/ch32v006/
   dspic33ak128mc102 do not need the equivalent: their RMW staging buffers
   (`page_buffer[FLASH_PAGE_SIZE]`, `page_buffer[NVMEM_PAGE_SIZE]`) are
   sized directly from the same macro that defines the erase unit, so there
   is no independent Makefile-supplied size to drift against — checked in
   each file, not assumed.
3. **[§1](#gpio-data)/[§17](#fp-precision)(BUG #17) STEP/DIR logical bits, "port-image" class**: core
   packs `step_outbits`/`dir_outbits`/`axislock` into a `uint8_t`
   (stepper.c) — every `X/Y/Z_STEP_BIT` and `X/Y/Z_DIRECTION_BIT` must
   resolve to <= 7. `_Static_assert(X_STEP_BIT <= 7 && ... , ...)` added to
   all 7 non-AVR ports (stm32f103/h523/f411, ch32v006, dspic33ak128mc102,
   samd21 megarm+generic, `_template`) at the point each board's config
   finishes defining these bits. This is exactly the invariant BUG #17's
   fix (PLAN.md Phase 3 history) established for samd21
   by hand; the assert makes sure a future re-pin on any port can't
   silently regress into the same truncation. atmega328p/`grbl/cpu_map.h`
   intentionally NOT touched — core file, golden-MD5 gate, outside port-code
   review scope.
4. **[§7](#serial) serial ring buffer vs index type, BUG #12 class**: the three
   TU-replacement `serial.c` files (samd21, ch32v006, dspic33ak128mc102)
   use `uint8_t rx/tx_buffer_head/tail` that wrap via plain `+1` (no
   explicit modulo) — correct only if `RX_RING_BUFFER`/`TX_RING_BUFFER`
   (`SIZE+1`) fit that index type, i.e. `RX_BUFFER_SIZE`/`TX_BUFFER_SIZE`
   <= 255. `grbl/config.h`'s own commented-out override already documents
   this as "(1-254)" in prose; `_Static_assert(RX_BUFFER_SIZE <= 255 &&
   TX_BUFFER_SIZE <= 255, ...)` added to all three files makes it a build
   fact. The macro-route ports (atmega328p, stm32f103/h523/f411) use core
   `grbl/serial.c` directly with its own `RX_BUFFER_SIZE`/`TX_BUFFER_SIZE`
   defaults (128 / 104-or-112, comfortably under the limit) — the core file
   itself is out of this sweep's scope (core is presumed clean per owner
   directive; the three ports above are the ones that reimplement the ring
   buffer and therefore own the invariant independently).

All four are one-line `_Static_assert`s placed exactly where their inputs
become fully known (after the relevant `#define`s, before first use) — no
new validation machinery, no runtime cost, zero bytes in any built image
(verified: every port's RELEASE size is byte-identical to the CANONICAL
RELEASE SIZE TABLE before and after this batch).
<a id="hc32f460-gaps"></a>
## 22. Gaps found porting HC32F460 (Phase 6 rolling port #3 — first
HDSC/Huada vendor-exotic chip, and the first port where NO donor in this
tree shares peripheral IP at all)

Every prior ARM port in this tree (samd21, stm32f103/h523/f411) is either
an Atmel/Microchip or ST part; all of them share enough peripheral-IP
family resemblance that CONTRACTS.md [sections 14](#ch32v006-riscv-gaps)/15 could talk about
"reuse the donor's shape, re-derive the addresses". HC32F460 (HDSC/XHSC,
formerly Huada Semiconductor) breaks that assumption completely: TIMER0/
TIMERA, the GPIO PORT model, the INTC interrupt router, EFM flash, and the
PWC/CMU clock tree all have zero donor-port precedent. Found empirically
this session with real `arm-none-eabi-gcc` 13.2.1 builds
(`grbl/platform/hc32f460/`, both `BUILD=DEBUG` and `BUILD=RELEASE` compile
every object and LINK with **zero `PORT_TODO_*`** and zero undefined
symbols — `nm -u` on both finished ELFs is empty).

1. **No permissively-licensed vendor SDK could be confirmed this
   session — the opposite of the dsPIC33AK/ch32v006 precedent, and
   PORTING-CHECKLIST's own ordering answered correctly**: HDSC's
   `hc32f4a0_ddl` Device Driver Library exists and is publicly mirrored
   (github.com/Mmatsnev/hc32f4a0), but no LICENSE file or SPDX header was
   found anywhere in it this session — only a bare "(C) HDSC" copyright
   footer. This is the OPPOSITE of CONTRACTS.md [section 16](#dspic33ak128mc102-gaps) item 11 (dsPIC33AK
   DFP, Apache-2.0, confirmed) and [section 14](#ch32v006-riscv-gaps) item 7 (ch32v006's Zephyr dtsi
   cross-check, Apache-2.0, confirmed) — those two precedents both found
   permissive licenses and used the vendor material as a source of truth.
   Here, the honest answer was "not confirmed permissive", so this port did
   NOT vendor or transcribe the HDSC DDL, per PORTING-CHECKLIST's own
   stated ordering ("vendor SDK only if permissively licensed; clean-room
   is the fallback, not a last resort" — this is the first port where that
   fallback branch was actually exercised for the reason it names, not
   skipped past). Lesson for the loop: "a vendor SDK exists" and "a vendor
   SDK is usable" are different questions, and the second one can come back
   negative — don't assume every future vendor-exotic chip gets a dsPIC-class
   green light.
2. **Klipper3d/klipper's real shipped firmware is a legitimate cross-check
   class this file did not have a name for yet**: neither "vendor SDK"
   ([section 14](#ch32v006-riscv-gaps) item 7 precedent) nor "device family pack" ([section 16](#dspic33ak128mc102-gaps) item
   11 precedent) — a THIRD source class: independent, real, GPL-3.0
   firmware actually running on physical HC32F460 hardware in the field
   (Voxelab Aquila 3D printers, `src/hc32f460/*` in Klipper mainline).
   GPL-3.0 is license-compatible with this GPLv3 grbl core, so even direct
   reuse would have been legally available — this port still chose
   clean-room (facts cross-checked, no code copied) per the file-header
   discipline every other clean-room port in this tree follows. Lesson:
   when a vendor's own SDK license is murky, check whether ANY real
   downstream open-source firmware for the same chip exists before
   defaulting straight to blind clean-room guessing — it materially
   changed how much could be CONFIRMED vs UNVERIFIED in `regs.h` (GPIO
   data-path register names, the INTC mechanism, TIMERA's role as the real
   PWM peripheral, and even a working PLL/clock bootstrap sequence with
   real addresses, all came from this source, not from guesswork).
3. **A chip can lack a fixed per-peripheral NVIC vector table entirely —
   a fourth interrupt-architecture family after ARM-hardware-fetch (samd21/
   stm32*), RISC-V mtvec/PFIC (ch32v006), and linker-synthesized IVT
   (dsPIC33A, [section 16](#dspic33ak128mc102-gaps) item 1)**: HC32F460's INTC is an event ROUTER —
   every peripheral interrupt source (compare-match timers, USART RX/TI,
   external pin EIRQ, …) is assigned at runtime to one of a small shared
   pool of identically-named vector slots (`Int000_IRQn`..`Int031_IRQn`,
   confirmed via Klipper's real `interrupts.c`: `M4_INTC->SEL[irqType]
   .INTSEL = irqSrc` then ordinary `NVIC_SetPriority`/`NVIC_EnableIRQ`).
   This means the vector TABLE itself (`hc32f460/startup.c`) is generic and
   stable across any board/pin-map variant of this port — what changes
   per-board is only which `intc_route(vector, source)` calls a platform.c
   makes at init time, not the table layout. Checklist lesson: PORTING-
   CHECKLIST Step 3's "audit IRQ capability before allocating" question now
   has a THIRD possible answer beyond "yes, fixed vector" (STM32/SAMD) and
   "no, this peripheral has no interrupt line at all" (CONTRACTS [section 14](#ch32v006-riscv-gaps)
   item 11): "yes, but the vector number is a runtime choice, not a
   compile-time fact" — a future porter must not assume Int000_IRQn means
   anything in particular without reading `platform.c`'s `intc_route()`
   calls.
4. **USART RX and TX are separate interrupt sources on this chip, unlike
   every prior USART-bearing port in this tree**: samd21/stm32f103/
   stm32h523/stm32f411 all combine RX and TX (and often error/idle) onto
   ONE physical vector, dispatched by reading a status register inside the
   handler. Klipper's real `serial.c` confirms this chip instead exposes
   `INT_USART1_RI` (RX) and `INT_USART1_TI` (TX) as independently routable
   INTC sources (plus separate error/TC sources this port does not use).
   `hc32f460/handlers.c` therefore has two trivial one-line vectors
   (`Int002_IRQHandler`/`Int003_IRQHandler`) instead of one dispatcher —
   simpler than every STM32 donor's SR-flag `if`/`if` shape, and a reminder
   that "the donor's shared-vector USART pattern is universal" (an implicit
   assumption baked into every prior port) is not actually universal.
5. **GPIO direction/pull-up is a per-pin configuration WORD, not a
   per-port bitfield register** — same shape-class as stm32f411/h523's
   MODER/PUPDR (CONTRACTS [section 14](#ch32v006-riscv-gaps) item 5's "4-bit packed config
   register" lesson) but a further generalization: here it is not even a
   shared per-port register with N bits per pin, but (per this port's
   best-effort model, since the real PCONR sub-layout was not reachable
   this session) one config register PER PIN, indexed by a global pin
   number. `hc32f460/gpio.h` implements direction/pull-up as function calls
   over an array of per-pin registers (`hc32_pconr()`, `regs.h`) rather
   than any bit-op macro, for the same reason ch32v006/stm32f103 made the
   same call on their own packed-register shapes. Checklist lesson,
   sharpened again: before allocating a `GPIO_DREG`/`GPIO_PREG` bit-op
   macro on ANY new vendor, check not just "is it packed 2+ bits per pin"
   ([section 14](#ch32v006-riscv-gaps) item 5) but "is direction/pull config even a per-PORT
   register at all, or could it be per-PIN" — the answer changes the
   addressing math, not just the bit width.
6. **Struct-shaped best-effort register layouts are worse than absent ones
   UNLESS FLAGGED, and this port is the first to flag EVERY SINGLE ONE
   at its point of definition, not just in a file-header disclaimer**:
   CONTRACTS [section 14](#ch32v006-riscv-gaps) item 7 stated this lesson (dsPIC's PFIC placeholder
   struct had wrong offsets that "compiled fine and read plausibly"). This
   port goes one step further as a methodology: every base address, bit
   position, and field name in `regs.h` that could not be sourced from
   either the datasheet's feature-list TOC or Klipper's real firmware is
   commented `UNVERIFIED` at its own definition site (not just summarized
   once at the top of the file), so a future reader auditing any single
   register write can immediately tell, without cross-referencing the file
   header, whether that specific fact is load-bearing or a placeholder.
   The build gates that matter for THIS session (compiles, links, zero
   PORT_TODO_*, boot-integrity, FP=SINGLE assert) do not require the
   placeholder values to be electrically correct — only hardware bring-up
   does, and this port is explicitly NOT claiming that gate. Checklist
   addition: a vendor-exotic port with no reachable register manual should
   still reach "links with zero PORT_TODO_*" (the linker-as-checklist
   mechanism doesn't care whether addresses are real), but must not claim
   "ready for hardware validation" in the same unqualified way a
   fully-verified port does — PLATFORM_ROADMAP.md's entry for this port
   says so explicitly.
7. **FPU verdict matches the stm32f411/stm32h523 precedent exactly, third
   time confirming the mechanism generalizes**: `-mfpu=fpv4-sp-d16
   -mfloat-abi=hard`, `FP=SINGLE` default. Disassembly of the RELEASE ELF:
   `vsqrt.f32` present (1 occurrence — `sqrtf()` compiling to the single
   real FPU instruction), 82 `vmul.f32` / 161 combined `vadd/vsub/vdiv.f32`
   — the identical `vmul.f32` count stm32f411 measured after its own
   `FP=SINGLE` rollout (CONTRACTS [section 17.7](#fp-precision)), unsurprising since it is
   the same compiler/core-code/FPU-class combination. Zero `__aeabi_d*` or
   generic DP soft-float symbols anywhere in the image (`nm | grep -iE
   "aeabi|df2"` empty) — cleaner than stm32f411's own result, which
   tolerated exactly one surviving `__aeabi_d2f` narrowing conversion at
   its `_delay_ms(double)` boundary; this port's equivalent boundary
   apparently optimizes away entirely under LTO. `assert_no_double.sh`
   PASSED on both DEBUG and RELEASE without needing the `delay_us_f()`
   float-worker fix samd21/ch32v006 both needed (this port's
   `_delay_ms`/`_delay_us` were written SysTick-integer-native from the
   start, with no double-typed remainder arithmetic to leak in the first
   place — the fix was designed in, not retrofitted).
8. **Boot-integrity and vector-table-under-LTO mechanics (CONTRACTS
   [section 18](#vector-table-lto)) transfer unmodified**: `SCB->VTOR = (uint32_t)vector_table` in
   `Reset_Handler`, `__attribute__((used))` on the table, `KEEP(*(.isr_vector))`
   plus `. = ALIGN(256)` in `script.ld` (48 vectors × 4 bytes = 192, next
   power of two = 256 — the same architectural VTOR-alignment rule as
   every other ARMv7-M port here), and `common/boot_check.sh` wired into
   the Makefile identically to every STM32/samd21 port. `boot_check.sh`
   reported OK on both flavors this session. Nothing new here — worth
   recording only as confirmation that this mechanism is genuinely
   ARM-architectural, not STM32-family-specific, exactly as [section 18](#vector-table-lto)
   already claimed.
9. **Gates re-run (not just inspected) this session**: golden AVR
   `make -C grbl/platform/atmega328p validate` **PASSED** (MD5
   `79af184e67b27defd27a39309ac53563`, text 30640, unchanged); samd21
   (`BOARD=megarm`) RELEASE **31952/296** (exact); stm32f103 RELEASE
   **28700/80**; stm32h523 RELEASE **25132/388**; stm32f411 RELEASE
   **25796/80**; ch32v006 (`BOARD=generic`) RELEASE **41072/0** — all six
   siblings byte-identical to their pre-existing state, confirming this
   port touched only `grbl/platform/hc32f460/`, `grbl/platform/CONTRACTS.md`,
   `grbl/platform/PLAN.md`, `grbl/platform/PLATFORM_ROADMAP.md`,
   `ci/warn_baseline_hc32f460.txt`, and `.github/workflows/ci.yml`.

<a id="cross-core-cache-coherency"></a>
## 23. Cross-core shared memory needs cache maintenance, not just ordering (SG2002 recon — a new class beyond BUG #12)

Every port closed so far ([§12](#weak-memory-obligations) item 1, BUG #12) shares one cache domain
with its own ISRs: producer and consumer are the same core (or a
core/DMA pair) inside one coherent view of memory, so a release-store
paired with `__DMB()`/a fence is the whole obligation — get the ORDER
right and the data is visible. That assumption breaks on an asymmetric
multi-core SoC where the companion core has its own L1 and no hardware
coherency between the two: SG2002 pairs a big core (C906 or Cortex-A53,
mutually exclusive by boot strap — see PLAN.md) running Linux against a
little C906L running our blob, and the two cores' D-caches are not kept
in sync by the interconnect. A fence only orders *this core's* memory
operations against *this core's* memory system; it says nothing about
when — or whether — another core's cache line for the same physical
address gets refreshed.

Consequence: the producer must explicitly WRITE BACK its dirty line(s)
after the data store, and the consumer must explicitly INVALIDATE its
copy before the data read, or the consumer can spin forever re-reading
its own stale cached line while the producer's fresh data sits
correctly ordered — and correctly written back nowhere the consumer's
cache knows to look. `__DMB()`/fence ordering and cache-maintenance are
ORTHOGONAL obligations; satisfying one says nothing about the other.
T-Head's C906/C906L expose custom cache-management ops for this
(XTheadCmo family, e.g. `th.dcache.call`) — not the base RISC-V ISA, a
vendor extension, so treat the encodings with the same "verify against
THIS toolchain" skepticism as [§14](#ch32v006-riscv-gaps)/[§20](#wch-isr-attribute) rather than assuming portability
from documentation alone.

This composes with the existing command-vs-data ordering obligation
(BUG #13 class, [§12](#weak-memory-obligations) item 4) into a THIRD requirement, not a
replacement: the doorbell/MMIO write that announces "data ready" must
be sequenced strictly AFTER the writeback that makes the data actually
visible in memory, or the consumer can be signaled before there is
anything correct to invalidate-and-read. So the full producer sequence
for a cross-core message is: write data -> writeback (cache op) ->
fence -> doorbell write; the full consumer sequence is: doorbell IRQ ->
invalidate (cache op) -> fence -> read data. Dropping either cache step,
or reordering the doorbell ahead of the writeback, both compile clean
and both fail silently.

Preferred simplification, where the SoC's PMA/MMU configuration allows
it: map the shared window as NON-CACHEABLE on both sides and sidestep
this entire class rather than hand-maintaining coherency — at the
serial byte rates this project moves data (GRBL command/status
traffic), the throughput cost of non-cacheable access is irrelevant, and
removing a manual-coherency class from a safety-relevant data path is
worth far more than the cycles it costs.

**General lesson beyond SG2002:** on any port where the producer and
consumer of a shared buffer are NOT guaranteed to be in the same cache
domain (different cores, no hardware coherency — as opposed to same-core
producer/ISR-consumer pairs, which is every port to date), ask "is this
memory coherent between these two agents" as a question separate from
"is this memory ordered between these two agents." Ordering-only
fixes ([§12](#weak-memory-obligations) item 1) are necessary but not sufficient once a second cache
enters the picture. This class is invisible to every test this project
can run without the actual hardware (no emulator models cross-core cache
incoherency at this fidelity) and its failure mode is not a hang or a
wrong timing — it is silent data corruption: stale bytes read as fresh,
with no assertion, no crash, and no distinguishing signature short of
comparing against ground truth. Treat "no emulator can catch this" as a
standing flag on the whole class, not a reason to defer it — an unfixed
example is a live footgun for whoever builds the SG2002 channel.

<a id="wch-common-extraction-ch570"></a>
## 24. Gaps found extracting common/wch/ and porting CH570 (Phase 6 rolling #4 — second WCH chip, first shared-code extraction between two RISC-V ports)

Two-part batch: Part A proved a real `common/<vendor>/` extraction is
possible for this project without disturbing a landed, golden-gated port
(ch32v006); Part B ported CH570 (QingKe V3C) consuming it. Every item
below is empirical — a real build, a real disassembly, or a real vendor
source file read this session, not theory.

1. **A `common/wch/` extraction can be BYTE-IDENTITY-PROVEN, not just
   "should be equivalent"**: ch32v006's PFIC struct/enable/disable
   (`wch_pfic.h`), `mstatus` critical-section/sei/cli/fence macros
   (`wch_critical.h`), and the mtvec vectored-mode write
   (`wch_vectors.h::wch_mtvec_set_vectored()`) moved out of
   `ch32v006.h`/`platform.h`/`startup.c` into `common/wch/` with the PFIC
   struct's fixed IRQ-bank width (`[2]`) replaced by a
   `WCH_PFIC_IRQ_WORDS`-parameterized one (arithmetic on the reserved
   padding arrays keeps every named register's byte OFFSET identical for
   any bank width — verified by `_Static_assert(offsetof(...))` for both
   values this tree uses, 2 and 8). The rebuild's RELEASE `.bin` MD5
   matched the pre-extraction build byte-for-byte
   (`075d79ced3a3f7e9324e93f6936bec54`, both DEBUG and RELEASE `.elf`
   `text/data` identical to the previously-recorded 41072/0) — proof, not
   inspection, that a shared header can be introduced under a hard
   byte-identity gate without disturbing the donor port, as long as the
   extracted text is copied verbatim and only the truly-fixed constants
   (the IRQ-bank width) become a parameter.
2. **The vendor SDK's own interrupt-enable helper is NOT the register
   `wch_critical.h` should use — a second, independent, HARDWARE-TESTED
   source resolved the apparent conflict**: openwch/ch570's
   `RVMSIS/core_riscv.h` (`__risc_v_enable_irq`/`__risc_v_disable_irq`,
   used by `sys_safe_access_enable/disable()`) reads/writes raw CSR
   **0x800** with mask `0x88` — a different numeric address than the
   standard named `mstatus` (0x300) ch32v006's `wch_critical.h` already
   used. Taken alone this would suggest V3C needs a different register
   than V2C. Two independent facts closed the question instead of
   guessing: (a) WCH's own OFFICIAL boot assembly for this exact chip
   (`startup_CH572.S`, Apache-2.0) enables interrupts with `li t0, 0x88` /
   `csrw mstatus, t0` — the STANDARD NAMED register, not the raw 0x800
   literal their own C helper uses; (b) cnlohr/ch32fun (MIT), a
   real, hardware-exercised project supporting BOTH QingKe V2
   (ch32v00x) and the CH5xx/V3 family CH570 belongs to, uses the named
   `mstatus` mnemonic uniformly across every chip it ports, compiled with
   mainline `riscv64-unknown-elf-gcc` — the same toolchain this project
   uses. Conclusion: `mstatus` (0x300) is correct and portable across
   QingKe generations on a mainline toolchain; the vendor SDK's raw-0x800
   helper is either a narrower-purpose register or tied to WCH's own
   forked-compiler convention, and this project deliberately does not
   reproduce it — CH570's flash safe-access bracket
   (`ch570.h::CH570_SAFE_ACCESS_BEGIN/END`) is built on this project's own
   already-trusted `sei()`/`cli()` instead of a second, less-verified
   primitive. **General lesson**: when a vendor's C-level helper and its
   own official assembly example disagree on which register to touch for
   the same stated purpose, the raw assembly (closer to what actually
   runs, less likely to be an artifact of a specific compiler's private
   ABI) is the better tiebreaker — and an independent, hardware-exercised
   community project that spans the same silicon family is worth more
   than either vendor artifact alone.
3. **Vendor startup code re-arming INTSYSCR is a stronger reason to WRITE
   the register than "trust the documented reset value"**: WCH's own
   `startup_CH572.S` executes `csrw 0x804, 0x3` during boot (INTSYSCR,
   BOTH HWSTKEN and INESTEN set) — the exact opposite of what this
   project's plain `__attribute__((interrupt))` handlers need (GCC's own
   software prologue, not the vendor hardware one; no preemption nesting
   assumed). ch32v006 (Phase 4) only relied on the TRM's documented
   reset-0 value and never observed a real counter-example, so its
   startup.c was left unchanged (HARD GATE: any added instruction would
   have broken Part A's byte-identity proof). CH570's startup.c calls the
   new `common/wch/wch_vectors.h::wch_intsyscr_clear()` explicitly, BECAUSE
   its own recon surfaced a real, official example reprogramming the same
   CSR away from 0 — the defense-in-depth the task brief asked for is not
   boilerplate caution here, it answers a genuine finding.
4. **TMR0 (this chip's only FIFO/DMA-capable general timer) has NO
   hardware clock prescaler** — a 26-bit up-counter that free-runs at
   Fsys with only a reload/compare register (`CNT_END`), unlike
   ch32v006's TIM2 (`PSC` register). `STP_TMR_PRESCALER_SET`/`_RESET`
   (CONTRACTS.md §3) cannot be a register write here without becoming the
   canonical silent no-op this document already forbids (§6.2's sibling
   class, the SAMD21 STP_TMR_PRESCALER_SET bug). Resolved by folding the
   /1,/8,/64 divisor into a stored software multiplier
   (`g_ch570_stepper_divisor`, `ch570/timer.h`) that `STP_TMR_PERIOD_SET`
   applies before writing `CNT_END` — externally identical semantics to a
   hardware prescaler (the period of the real-time tick genuinely scales
   by the selected divisor), just a different mechanism. 26-bit headroom
   (67,108,863 max) comfortably covers the worst case
   (`65535 * 64 = 4,194,240`), so no overflow risk. **General lesson**:
   "prescaler" in this document's contracts means an OBSERVABLE semantic
   (the tick period scales), not a specific register shape — a port
   without a hardware divider must still implement the semantic, in
   software, rather than treat its absence as license to no-op.
5. **Single-polarity edge-triggered GPIO interrupt hardware can still
   deliver CONTRACTS.md §2.6 "any pin CHANGE" semantics, via an edge-flip
   technique, not just a documented gap**: CH570's GPIO interrupt block
   (`R16_PA_INT_MODE`/`R16_PA_INT_EDGE_TYPE`, datasheet-confirmed) offers
   level-OR-edge trigger with a SINGLE selectable polarity per pin (no
   "either edge" encoding exists in the register, unlike ch32v006's EXTI
   RTENR+FTENR pair, which arms both edges simultaneously). This port's
   `hal_gpio_interrupt_enable()` arms the edge away from the pin's current
   level, and the shared GPIOA ISR (`handlers.c`) XORs the fired pins'
   `EDGE_TYPE` bits after each servicing — so the NEXT interrupt fires on
   whichever transition comes next, alternating forever across
   consecutive interrupts. This turns single-polarity hardware into
   "any change" semantics without hardware support for it, at the cost of
   one extra register write per interrupt (already inside the
   flag-clear-first ISR-hot budget, CONTRACTS.md §2.3). **General
   lesson**: before accepting "this hardware can't do any-edge, document
   the gap" for GPIO interrupt controllers with single-polarity edge
   select, check whether the polarity field itself is writable from the
   ISR — if so, the edge-flip technique closes the gap for real instead
   of leaving it as a known limitation.
6. **CORRECTED after adversarial review — a chip whose datasheet
   EXPLICITLY DECLINES to document its flash register protocol, and whose
   vendor object is confirmed by disassembly to contain real,
   non-trivial logic, is the honest case for vendoring a BINARY (the
   first in this project's tree) — investigated, not assumed.** The
   original draft of this port called `FLASH_EEPROM_CMD` a "boot-ROM
   call"; that phrase was imprecise and has been removed throughout this
   port (ch570.h, nvmem.c, ISP572.h, the Makefile). It is not a far call
   into a separate boot-ROM address range — full disassembly
   (`riscv64-unknown-elf-objdump -d vendor/ISP572.o`) shows every internal
   call is a normal PC-relative `auipc`/`jalr` to ANOTHER FUNCTION IN THE
   SAME OBJECT, and the whole thing links as an ordinary statically-placed
   function. The investigation this batch's review demanded, done
   properly:
   - **Is the ROM entry address + ABI independently documented (option
     "reimplement it ourselves")?** NO — the CH572/CH570 Datasheet V1.1,
     in the paragraph immediately preceding its own "4.4 Flash-ROM
     Operation Steps" section, states outright: *"For the operation or
     setting of FlashROM, please refer to related subprograms. **This
     datasheet does not provide the introductions to FlashROM word data
     registers and FlashROM control registers.**"* Section 4.4 itself:
     *"1. Erase Flash-ROM, please refer to and call related subprograms.
     2. Write Flash-ROM, please refer to and call the related
     subprograms."* The vendor is not offering a convenience wrapper
     around a documented mechanism — it is stating plainly that the
     register-level protocol on `R8_FLASH_CTRL`/`R8_FLASH_CFG`/
     `R32_FLASH_DATA`/`R32_FLASH_CONTROL` (0x40001800-0x40001807, all
     real, listed addresses with NO bit tables) is deliberately withheld,
     and that calling this exact function is the only supported path.
   - **Is the object a thin trampoline in disguise (the reviewer's
     explicit test — "20 instructions of load-address-and-jump")?** NO —
     ~1.3KB of real control flow: it saves and restores the PFIC
     interrupt-enable state around the operation (masks ALL interrupts
     via `PFIC->IENR`/`IRER` while flash is unreadable — necessary, since
     the CPU cannot fetch code from flash during program/erase), validates
     the requested address range against the boot-ROM boundary (0x3C000),
     dispatches EIGHT distinct sub-commands (erase/write/verify/get-ROM-
     info/get-unique-ID/power-up/power-down/software-reset/start-I/O),
     and for erase specifically runs a real block-size-selection loop
     (chooses among multiple erase granularities by address alignment,
     iterating over the requested range) against an internal byte-level
     command/status protocol on `R8_FLASH_CTRL` (opcodes like 4, 5,
     0xD8, 0x20, 0x81 — none explained by the datasheet). This is real,
     compact, non-trivial logic, not a stub — genuinely (b), not (a) in
     disguise.
   - **Given that, why not transcribe the disassembly into new
     "clean-room" source (Apache-2.0 already permits it)?** Because there
     is NO independent public specification of the `R8_FLASH_CTRL`
     protocol to derive from — the datasheet says so explicitly, above.
     Transcribing disassembly into new text under those conditions is not
     clean-room re-derivation, it is a hand-copy of the exact same vendor
     logic with strictly MORE transcription-error risk (a single
     mistyped immediate or flipped branch condition becomes a silent
     flash-corruption bug) than linking the vendor's own tested object,
     for zero corresponding benefit — Apache-2.0 already grants full
     reproduction rights, so there is no legal motive to paraphrase.
     Verdict: **(c), genuinely unavoidable** — tracked explicitly
     (`.gitignore`'s blanket `*.o` rule needed an explicit
     `!grbl/platform/ch570/vendor/ISP572.o` exception, verified via
     `git check-ignore -v` AND a simulated fresh checkout — `git archive`
     of a `git stash create` snapshot, extracted and rebuilt clean,
     byte-identical sizes), LICENSE kept alongside, and disclosed here in
     plain language: **this is the first port in this tree carrying a
     vendored binary artifact, not just vendored header text.**
   - **A second, related correction relocation analysis surfaced**:
     `nvmem.c`'s region-write-enable bracket originally claimed
     "least privilege" by setting `R8_GLOB_ROM_CFG`'s `RB_ROM_CODE_WE` to
     "enable 129-240K" (0x40) rather than "enable 0-240K" (0xC0) before
     calling `FLASH_EEPROM_CMD`. `readelf -r vendor/ISP572.o` shows this
     claim does NOT hold for the operation itself: both
     `FLASH_CMD_ROM_WRITE` and `FLASH_CMD_ROM_ERASE` call `FLASH_START`
     as their first action, and `FLASH_START` unconditionally ORs the
     SAME register with 0xE0 (0xC0 + `RB_ROM_CTRL_EN`) regardless of what
     this port set beforehand — the vendor code re-widens access to the
     full region every time. The narrower grant only protects the brief
     margins immediately before/after the `FLASH_EEPROM_CMD` call, not
     the erase/write window itself; `nvmem.c`'s comments now say so
     honestly instead of repeating the original overclaim. **General
     lesson**: when vendoring a black-box binary, verify any assumption
     about what it does with registers you also touch by reading its
     relocations/disassembly, not by inspection of your own bracketing
     code alone — the two can silently disagree.
7. **GPIO SET/CLR as two independent write-only registers (not one
   combined atomic register like STM32's BSRR) is still safe for a
   multi-bit STEP/DIRECTION group write, just not simultaneous at the bus
   level**: CH570's `R32_PA_SET`/`R32_PA_CLR` (WZ — write 1, auto-clears)
   each touch only the bits written, with no read-modify-write hazard
   against an ISR touching other pins concurrently (CONTRACTS.md §1.2) —
   but a group write (`hal_gpio_mwo()`, `ch570/gpio.h`) costs TWO register
   writes (SET then CLR) instead of STM32/ch32v006's one, so the group as
   a whole does not transition in a single bus cycle. Judged acceptable
   (not a new hazard class): even a single-register combined write only
   LOOKS simultaneous across bits because it is one instruction, not
   because hardware promises simultaneity at the pin-driver level: a
   few-nanosecond skew across 3 axis STEP/DIRECTION bits is not
   qualitatively different from what every port already tolerates.
8. **This chip's real GPIO pin budget (12 pins, ONE port) is far below
   what a full-featured "generic" GRBL board wants (~20 signals)** — the
   CH572/CH570 Datasheet V1.1 states plainly "the chip provides a group of
   GPIO ports PA with 12 general input and output pins"; the vendor SDK's
   own `GPIO_Pin_0..GPIO_Pin_23` defines are shared boilerplate across the
   whole CH5xx family tree (bigger siblings bond out more pins) and do NOT
   mean this specific chip has 24. `ch570/boards/generic/config.h` uses
   PA0-PA21 anyway (a placeholder map, explicitly NOT claimed hardware-fit,
   same posture ch32v006's and dsPIC33AK128MC102's own generic boards
   already established for their own real pin-budget constraints) with an
   explicit file-header caveat and a list of real consolidations a
   from-scratch board would need (shared STEPPERS_DISABLE, safety door
   sharing feed-hold, optional COOLANT_MIST). Two REAL, datasheet-fixed
   facts are honored regardless of the placeholder pin choices: PWM1's
   dedicated pin is PA7 (no remap exists for PWM1-5 on this chip) and
   UART1's default remap is TX=PA3/RX=PA2 — both load-bearing, not
   arbitrary, in the generic board's pin map.
9. **`assert_no_double.sh`'s allowed exceptions (widening/narrowing
   conversions at a legacy double-typed ABI boundary) held on a THIRD
   RISC-V target with real hardware multiply/divide (RV32IMC's M
   extension) and no FPU**: FP=SINGLE PASSED on both flavors with zero
   `__aeabi_d*`/`__*df3`/DP-libm symbols linked — the same class of leak
   this knob exists to plug (CONTRACTS.md §17) reproduces identically on
   a chip with hardware integer multiply, confirming the leak is about
   the ABSENCE OF AN FPU, not the absence of integer multiply/divide
   (ch32v006's rv32ec has neither; CH570's rv32imc has M but not F, and
   the same fix applies unchanged).
10. **The vendored `FLASH_EEPROM_CMD` blob carries 276B of dead code that
    `-ffunction-sections`/`--gc-sections` (both already on for this port,
    Makefile) CANNOT remove — verified empirically, not assumed** (found
    auditing this port's `.syms` artifact for compactness). `nvmem.c`
    only ever calls `FLASH_EEPROM_CMD` with `CMD_FLASH_ROM_ERASE`/
    `CMD_FLASH_ROM_WRITE`, but the linked RELEASE `.elf` still contains
    `FLASH_CMD_ROM_VERIFY` (80B), `FLASH_CMD_GET_ROM_INFO` (90B),
    `FLASH_CMD_GET_UNIQUE_ID` (62B), `FLASH_CMD_ROM_SW_RESET` (26B),
    `FLASH_CMD_ROM_PWR` (18B) = 276B, confirmed via
    `riscv64-unknown-elf-nm --print-size --size-sort` on a fresh RELEASE
    build. **`vendor/ISP572.o` DOES have one section per function**
    (`.highcode.FLASH_CMD_ROM_VERIFY` etc., `objdump -h` — unlike a naive
    "no function-sections" read of this gap might suggest) — the reason
    gc-sections still can't help is deeper: `FLASH_EEPROM_CMD` itself
    (the one symbol `nvmem.c` calls, therefore always kept) contains a
    runtime `switch` on its `cmd` argument whose EVERY case is a static
    `R_RISCV_CALL` relocation (`objdump -dr vendor/ISP572.o` confirms all
    seven, including the two used and five unused sub-commands) — gc-
    sections keeps a section if anything KEPT references it via a
    relocation, full stop; it has no way to know at link time that this
    port only ever passes two of the eight possible `cmd` values.
    Removing the 276B would require either (a) hand-patching the
    already-linked vendor object to delete the switch cases reaching the
    five unused sub-commands, which is binary-patching a vendored blob
    (fragile against any toolchain/vendor-source update, and the whole
    reason this object is vendored rather than reimplemented is that its
    register-level protocol is explicitly undocumented per the datasheet
    — item 6 above — so hand-editing it carries the same
    transcription-error risk that vendoring was chosen to avoid), or (b)
    reimplementing ERASE/WRITE from scratch and dropping the vendored
    object entirely, which reverses this port's own carefully-argued
    vendoring decision (item 6) and would remove this project's only
    vendored binary artifact — a policy call for the project owner, not
    a size-optimization call for this ledger entry to make unilaterally.
    **Verdict: leave it — the 276B is genuinely unavoidable without
    binary-patching a vendor blob or reversing an already-deliberated
    architecture decision, and is documented here as the accepted,
    measured cost rather than re-litigated.**

GATES this batch re-ran (not just inspected): golden AVR `make validate`
PASSED (MD5 79af184e67b27defd27a39309ac53563, text 30640); samd21 megarm
RELEASE 31952/296; stm32f103 RELEASE 28700/80; stm32h523 RELEASE
25132/388; stm32f411 RELEASE 25796/80; hc32f460 RELEASE 25596/80;
ch32v006 RELEASE 41072/0 (`.bin` MD5-identical before/after the Part A
extraction) — every sibling this task's brief named, all byte-identical,
confirming this batch touched only `grbl/platform/common/wch/`,
`grbl/platform/ch32v006/{ch32v006.h,platform.h,startup.c}` (extraction
only, zero behavior change), `grbl/platform/ch570/` (new),
`grbl/platform/hal.h` (additive `PLATFORM_CH570` dispatch, guarded so it
cannot affect any other platform's preprocessing), `CONTRACTS.md`,
`PLAN.md`, `ci/warn_baseline_ch570.txt`, and `.github/workflows/ci.yml`.
CH570: `make BUILD=DEBUG`/`BUILD=RELEASE` both LINK with **zero
`PORT_TODO_*`** (`nm | grep PORT_TODO` empty both flavors — verified, not
assumed), zero compiler warnings on platform files (baseline holds only
core-file warnings, identical text to ch32v006's), FP=SINGLE assert
PASSED both flavors, boot integrity OK both flavors (`_start=0x00000000`),
`mret` (opcode `0x30200073`) disassembly-confirmed in all four real
vector bodies (`TMR_IRQHandler`, `SysTick_Handler`, `GPIOA_IRQHandler`,
`UART_IRQHandler`). Sizes: DEBUG 46830/4/6850, RELEASE 40674/4/6849 (of
236KB usable flash / 12KB RAM). NOT marked ready for hardware validation
(no CH570 emulator exists, same posture as ch32v006/dsPIC33AK/hc32f460) —
every UNVERIFIED fact (the 60MHz PLL clock path end-to-end, the busy-wait
delay cycle-count assumption, the GPIO any-edge technique's real-silicon
behavior) is flagged at its own definition site, not asserted as
hardware-proven.

<a id="build-artifacts-tracked"></a>
## 25. Build artifacts are TRACKED IN GIT for observability, not reported once (placeholder number — integrator assigns the final one; cite this slug, not "§25", from elsewhere)

**Owner directive** (verbatim intent): commit RELEASE `elf`/`bin`/`hex` per
buildable port, not as an end-of-project deliverable but so the *current*
state of every port is inspectable and diffable over time. Before this
batch, `atmega328p` was the only port with any byte-level build history —
the golden MD5 in `grbl/platform/Makefile`'s `validate` target. Every other
port could only be compared "now vs now" inside a single session (rebuild
twice, diff the two local files); a size drift discovered a week later had
nothing upstream to diff against. That gap is closed by `artifacts/` (repo
root) + `tools/build_artifacts.py`.

**What's committed** — per port, `artifacts/<port>/grbl_<port>.{bin,hex}`
(RELEASE only) plus `grbl_<port>.syms` (`nm --print-size --size-sort
--demangle` on the RELEASE `.elf`, plain sorted text) — **every refresh**.
`grbl_<port>.elf` itself is tracked ONLY at release-tag time ("Эльф на
тегах" owner directive, this batch — see the dedicated subsection below);
it is NOT part of the ordinary refresh cadence. `samd21` gets two
directories (`samd21-megarm/`, `samd21-generic/`) because the toolchain
names both boards' ELF identically — `BINARY_NAME` in
`grbl/platform/samd21/Makefile` does not encode `BOARD`, only the directory
does. `artifacts/MANIFEST.sha256` covers every artifact of every port **and
flavor**, including DEBUG (never committed as a binary — 3-10x larger for
no diffing value; dsPIC33AK's DEBUG `.elf` alone is ~14MB uncompressed) —
DEBUG lines are `#`-prefixed so `sha256sum -c` skips them but
`tools/build_artifacts.py check` still parses and compares them, so a
DEBUG-only regression stays observable without paying for a second full
binary set per port. `sg2002` is absent by design — §23's own scope ruling
left it design-complete/implementation-deferred, nothing to build yet.

**Why the symbol map matters more than the binaries for THIS specific
purpose**: a binary diff proves a port's size moved and by how much; it
cannot say which function moved. `.syms` is the artifact that answers that,
in seconds, via plain `git diff` — no rebuild, no disassembler. It costs a
few KB per port because it's sorted text, not another binary copy — this is
the cheap half of the tracking cost, deliberately kept cheap because the
expensive half (the binaries) can't be.

**Growth cost, stated where a committer will see it before they're
surprised by repo size**: measured on this tree, `.bin` 25-95KB (dsPIC's
`.bin` is disproportionately large — `elf32-pic30`'s packed-instruction-word
layout expands under a raw `objcopy -O binary`, not a bug in this tooling),
`.hex` 72-116KB, `.elf` 48-166KB, per port/board. Ten units, one full
snapshot (all four extensions, the policy in force when this number was
first measured): ~2.7MB (exact figure that batch landed with: 2,612,919
bytes / 42 tracked files). **Git does not delta binaries usefully across
recompiles** — a source edit that moves one function by 40 bytes typically
re-links every address after it, so the *entire* blob differs and git
stores a new, separately-compressed copy; nothing tracks "99% identical to
the last commit's blob" for binary content the way it does for text. A
single ordinary refresh under that original always-track-everything policy
was observed to grow the repo's `.git` from 12MB to 14MB. This is the
accepted price of the observability the owner asked for, not a defect — but
see "ELF is tracked ONLY at release tags" immediately below for how this
batch cut that recurring cost roughly in half by no longer paying `.elf`'s
share (the single largest class) on every refresh. Full table:
`artifacts/README.md`'s "Growth cost" section.

**ELF is tracked ONLY at release tags, not on every refresh** ("Эльф на
тегах" owner directive, follow-up batch to the one above, same day):
`.elf` is the single largest artifact class (48-166KB/unit vs. `.bin`
25-95KB, `.hex` 72-116KB, `.syms` a few KB) and, like every binary here, is
not delta-compressible across recompiles — tracking it on every refresh, as
the original policy did, meant `.elf`'s bytes alone accounted for roughly
46-58% of any given unit's tracked size, i.e. routine refreshes were paying
close to double what `.bin`/`.hex`/`.syms` observability actually required.
`.bin`/`.hex`/`.syms` are unaffected and remain tracked every refresh
exactly as before.

- **Mechanism**: `tools/build_artifacts.py build` (the default) no longer
  copies `.elf` into `artifacts/<port>/`, and actively deletes any stale
  `.elf` left over from a prior tag build in that directory (so a plain
  refresh can never leave a mismatched, un-regenerated ELF sitting next to
  fresh `bin`/`hex`/`syms`). `tools/build_artifacts.py build --with-elf` is
  the explicit, tag-time-only mode that DOES copy `.elf` and record its
  hash in `MANIFEST.sha256`. `check` requires `bin`/`hex`/`syms` exactly as
  before but verifies `.elf` **only if it is present** in the tree — its
  absence between tags is the expected state, not a staleness failure; if
  it IS present (post-tag), it is still hash-gated for real drift like
  every other tracked file.
- **`.gitignore` mechanism, chosen to not repeat a trap that has already
  bitten this tree three times** (`tools/README.md`, `ch570/vendor/ISP572.o`,
  and this very `artifacts/*.elf|hex` pair under the OLD always-track
  policy — all three were blanket ignore rules silently dropping an
  intentionally-tracked file from `git add -A`): the fix for those three
  was a `!path` negation exception so `-A` "just works". Reversing the
  policy for `.elf` (now ignorable-by-default, addable only at tag time)
  makes negation the WRONG tool — a negation would make `.elf` permanently
  un-ignorable, exactly what this batch is trying to stop. So the
  `!artifacts/**/*.elf` negation is REMOVED from `.gitignore`, leaving
  `.elf` under artifacts/ covered by the pre-existing blanket `*.elf` rule
  ON PURPOSE. The corresponding risk — `git add -A`/`git add .` silently
  skip ignored paths with zero output, the identical failure class as the
  three prior traps, just pointed the other direction — is closed by NOT
  using `-A` at tag time: the documented tag-time command force-adds the
  ELFs by explicit path (`git add -f artifacts/*/*.elf`), which either
  succeeds or fails LOUDLY (no matching files), never silently. `!artifacts/**/*.hex`
  (and the pre-existing `!artifacts/README.md`) are unaffected and remain in
  `.gitignore` — only the `.elf` negation was removed.
- **Proof required after this change (and after any future edit to this
  rule)**: `git check-ignore -v artifacts/<port>/grbl_<port>.elf` must
  report the blanket `*.elf` line as the matching rule in the default
  (between-tags) state, regardless of whether the file is physically
  present in the working tree; `git add -f` on that same path must succeed
  once `build --with-elf` has produced it (tag-time state). Both were
  re-verified when this batch landed.
- **Numbers this batch measured, landing from the prior batch's 2.6MB/42-file
  snapshot**: removing the 10 tracked `.elf` files (1,221,872 bytes, ~1.19MB)
  dropped the tracked tree to 1,389,988 bytes / 32 files (~1.39MB, ~47%
  smaller). Every subsequent full-tree refresh now costs at most ~1.37MB
  (all ten units touched, the worst case) instead of ~2.6-2.7MB — and
  proportionally less for the common case of one or two ports changing,
  since `.elf` was the majority of most units' tracked bytes.

**dsPIC33AK128MC102's `.elf` (only the `.elf`) is tracked but not
hash-gated** (fact first surfaced building this tooling; SCOPE CORRECTED by
an adversarial review the same project — see "GAP 1 FIX" below): two
consecutive `make clean && make BUILD=RELEASE` runs of the *unmodified*
source tree were measured to differ in ~12-13% of the resulting **`.elf`'s**
bytes (a re-measurement this later batch: 20829-22185 of ~166000 bytes,
exact count wobbles run to run). Root cause, identified by the same review
(not previously explained, just observed): the differing bytes are embedded
`/tmp/ccXXXXXX.s.scnN` compiler-tempfile **SECTION NAMES** — `as`'s
per-invocation randomly-named scratch assembly file, echoed into a handful
of ELF section-name strings — not code, not layout, not a watermark.
Critically, **`.bin` and `.hex` are BYTE-IDENTICAL** across the same two
builds (`cmp -l`: empty) — `xc-dsc-objcopy`/`xc-dsc-bin2hex` read the
*linked image's actual code/data bytes* and never see those compiler-scratch
strings, so there is nothing for them to differ on. The **symbol map is
also stable** across those same two builds (`diff` empty — function
addresses/sizes don't move).

- **GAP 1 FIX (adversarial review, this batch)**: the original
  implementation used one all-or-nothing `nondeterministic_binary` flag
  that skipped the hash comparison for `.elf` **AND** `.hex` **AND**
  `.bin`, silently weakening the gate for two files that were never
  actually nondeterministic. Renamed to `nondeterministic_elf` and scoped
  to `.elf` only (`tools/build_artifacts.py`'s new
  `hash_gated_extensions()` helper, covered by `--selftest`): `check` now
  hash-gates dsPIC33AK's `.bin`/`.hex`/`.syms` for both RELEASE and DEBUG
  exactly like every other unit (previously DEBUG wasn't even built for
  this unit, since the old flag skipped the whole DEBUG stage) — only the
  `.elf` comparison is skipped, and only because it is genuinely, provenly
  nondeterministic. Re-verified this batch: two clean `BUILD=RELEASE`
  rebuilds' `.bin`/`.hex` sha256 identical; the same two builds' `.elf`
  sha256 differ (confirms both halves of the claim empirically, not just
  by re-reading the old comment). `bin`/`hex` are committed every refresh
  like every other port; `.elf` follows the same tag-time-only policy as
  every other port (see the subsection above) — when present, still useful
  for archival/manual inspection, just not part of the automated freshness
  gate for this one unit specifically.

**The mechanism**: `tools/build_artifacts.py` (subcommands `build`/`check`,
plus a bare `--selftest` matching `ci/warn_ratchet.py`/
`tools/assert_no_double.sh`/`tools/check_contracts_numbering.py`'s style —
pure manifest-format/hash-compare logic, no compiler invoked) is the sole
orchestrator; it shells out to each port's own Makefile for the actual
compile (thin invoker, same division of labor as
`.github/actions/build-platform` — build truth stays in the Makefiles).
`grbl/platform/Makefile` gains `make artifacts` / `make artifacts-tag`
(`--with-elf`, tag-time only) / `make artifacts-check` / `make
artifacts-selftest` as the documented entry points (placed there, not
per-platform or in the golden-gated AVR root Makefile, because it's already
the one file that knows about every non-AVR platform as a unit, and driving
AVR from the same script needed one entry point, not ten near-identical
copies). `check` rebuilds fresh into the ordinary scratch `build/`
directory — never touching `artifacts/` — and fails, naming every drifted
or missing file, if a commit landed without refreshing its port's
artifacts (`.elf` exempted from the missing-file case, per above). This is
the **sixth ratchet** in this project, after golden MD5, warn baseline,
boot integrity, no-DP assert, and docs integrity/CONTRACTS
numbering.

**GAP 2 FIX (adversarial review, this batch): the sixth ratchet now
actually RUNS in CI** — before this batch, `tools/build_artifacts.py check`
existed and was documented as "the sixth ratchet" but `.github/workflows/ci.yml`
never invoked it (`grep -n build_artifacts .github/workflows/ci.yml` returned
nothing), the same "certifies but never checks" failure class this project
has already hit twice (`ci.yml`'s own warning-ratchet and boot-integrity
history). Fixed by wiring `check --platforms <this-job's-units>` into every
existing build job rather than adding a dedicated all-toolchains job:
`check` needs every one of ARM/AVR/RISC-V/xc-dsc to rebuild everything, and
no single existing CI job has all four — a dedicated job would either
duplicate every toolchain-install step already present in the `build`
matrix and the `build-dspic33ak128mc102` job (double the install cost for
zero new coverage) or need `actions/download-artifact` to pull binaries
across jobs (outside this workflow's allowed action set, per the
`build-dspic33ak128mc102` job's own comment on why *it* isn't folded into
`build-platform`). Each existing job already has exactly the one toolchain
it needs on `$PATH`/at its probed location, already built its unit(s) once
this run — running `check --platforms <its own units>` there re-verifies
committed-vs-fresh for those units specifically, using a toolchain already
installed for a step that already ran, at zero extra install cost. Across
the full job matrix this still covers all ten units, same as a hypothetical
all-toolchains job would, without ever installing two heavy toolchains
(XC-DSC + one apt one) in the same job. The `docs-integrity` job (no
toolchain, already the home of `check_contracts_numbering.py`) also gained
`tools/build_artifacts.py --selftest` — it needs no compiler and was, like
`check`, wired nowhere before this batch.

**GAP 3 (documentation, adversarial review, this batch): DEBUG `.elf`
manifest hashes are BUILD-PATH DEPENDENT; RELEASE is not.** `-g3` (every
port's DEBUG flavor) embeds the compiler's absolute working directory
(`DW_AT_comp_dir`) and, for at least the dsPIC33AK toolchain, some
same-directory translation units' absolute source path (`DW_AT_name`) into
DWARF debug info — so a DEBUG `.elf` built from the identical, unmodified
source tree checked out at a *different absolute path* is a *different*
file, purely from path length/content, nothing to do with source or
toolchain drift. Measured (stm32f103, two full checkouts at
deliberately-different-length paths): DEBUG `.elf` differs in 20 bytes,
exactly the two paths' length delta, everywhere else byte-identical
(confirms the mechanism: comp_dir string length is the only variable).
RELEASE (`-g0`, no debug info at all) is measured **path-INDEPENDENT** —
0-byte diff between the same two checkouts — so the gate that actually
matters for the tracked/committed tree (RELEASE bin/hex/syms, `.elf` at tag
time) is robust; only DEBUG's *manifest-recorded* hashes (never a committed
binary, see "Why DEBUG isn't committed" in `artifacts/README.md`) are at
risk, and only if `check` is ever run from a different absolute path than
`build` was. **Fix option, applied this batch (proven cheap — see below)**:
`-ffile-prefix-map=$(CURDIR)=/grbl-src` added to every port's `CFLAGS` (the
literal target string doesn't matter, only that it's identical across
checkouts) remaps the embedded path to a fixed, checkout-independent
string. Verified (stm32f103, arm-none-eabi-gcc 13.2): DEBUG `.elf` becomes
fully byte-identical across the two differently-pathed checkouts (0-byte
diff, was 20) with the flag; RELEASE `.bin`/`.hex` sha256 UNCHANGED versus
the flag-less build (proves the flag is free where it matters — RELEASE
has no debug info to remap in the first place). Same RELEASE-unchanged
proof re-run for ch32v006 (picolibc/RISC-V) and dsPIC33AK
(xc-dsc-gcc 8.3.1) against their already-committed `artifacts/` hashes —
identical in both cases. **Caveat, stated plainly rather than
oversold**: on `xc-dsc-gcc` specifically, four locally-invoked translation
units (`platform.c`/`handlers.c`/`serial.c`/`nvmem.c` — compiled as a bare
filename, not a `../../relative/path.c`) still embed an absolute
`DW_AT_name` untouched by `-ffile-prefix-map` (a toolchain quirk, not a
flag-application bug — the ~16 other translation units in the same build
ARE fully remapped); dsPIC33AK's DEBUG `.elf` is therefore *improved* but
not *fully* path-independent. This is immaterial to the actual ratchet
(dsPIC33AK's `.elf` is already `nondeterministic_elf`-exempt from hash
comparison for an unrelated reason — the tempfile-section-name issue above
— so its DEBUG `.elf` hash was never gated either way) but is recorded here
so a future contributor doesn't re-discover it as a surprise.

**A real bug this batch found and fixed while building the tool itself**
(kept here as a lesson, not just in a commit message): the first
`check` run against a freshly-generated manifest reported samd21-megarm's
DEBUG binary as "stale" even though nothing had changed. Root cause: both
samd21 boards' DEBUG artifacts land at the identical toolchain-chosen path
`build/grbl_samd21_dbg.elf` (same `BINARY_NAME` collision noted above, for
DEBUG instead of RELEASE), so an unnamespaced manifest label
(`"build/" + basename`) let `samd21-generic`'s hash silently overwrite
`samd21-megarm`'s under one dict key — `check` then compared megarm's fresh
hash against generic's recorded one and false-positived. Fixed by
namespacing every DEBUG label with the unit's `artifact_dir`
(`"build/{artifact_dir}/{basename}"`), which cannot collide since
`artifact_dir` is the very thing that disambiguates the two boards'
committed RELEASE directories. Regression-guarded in
`tools/build_artifacts.py --selftest` (asserts the two boards' labels
differ) rather than only in a one-off manual repro.

**Refresh policy**: refresh-and-commit `bin`/`hex`/`syms` whenever a port's
*content* changes (part of finishing that port's change, per
`PORTING-CHECKLIST.md`'s Definition-of-Done item 8 and its own "Refresh
policy" section); do **not** refresh on every push (most pushes are
docs/ledger and move zero bytes of any port's binary). `.elf` is NOT part
of this cadence — it is tag-time only (`build --with-elf` +
`git add -f artifacts/*/*.elf`, see above). The checker enforces the
`bin`/`hex`/`syms` cadence rather than leaving it to memory — see
`PORTING-CHECKLIST.md` and `artifacts/README.md` for the full
contributor-facing statement of the rule.

---

<a id="cross-arch-dedup-byte-invariance"></a>
## 26. Cross-architecture de-duplication under a byte-identity gate — four extractions, and the one that had to stop at three ports (placeholder number — integrator assigns the final one; cite this slug, not "§26", from elsewhere)

Follow-on to the WCH extraction in
[§24](#wch-common-extraction-ch570), which proved the method on one vendor
family. This batch applied the same hard gate — *rebuild every consumer,
compare RELEASE `.bin` MD5 against the committed
[`artifacts/`](#build-artifacts-tracked) baseline, identical or the
extraction is rejected* — to four duplication clusters that span **different
architectures** (Cortex-M3/M4/M4F/M33, RISC-V, and dsPIC33A), not one
vendor's cores. Every claim below is a real build in this session.

1. **The gate scales across ISAs, and it is cheap.** All four extractions
   came out byte-identical on every consumer, first try, with no tuning:
   `common/cortexm/cortexm_critical.h` (stm32f103/f411/h523 + hc32f460),
   `common/serial_ring_accessors.h` (ch32v006, ch570, dspic33ak128mc102,
   samd21 ×2 boards), `common/nvmem_checksum.h` (same four), and
   `common/stm32/stm32_timer.h` (stm32f103/f411/h523). The rule §24
   established holds unchanged off the vendor axis: **copy the extracted
   text verbatim; parameterize only what is genuinely fixed per port.**
   What made all four safe is that the only per-port things were *names
   resolved at the include site* — buffer symbols, `RX_RING_BUFFER`/
   `TX_RING_BUFFER` sizing, `EEPROM_SIZE`, and (for the timer header) the
   TIM base addresses, which stay in each port's own `regs.h` and are
   reached through the plain `#include "regs.h"` the shared file does under
   each port directory's own `-I.`.

2. **`-Os` erases formatting differences; `-O0` does not — say which
   flavor your gate covers.** samd21's serial accessors and NVMEM read
   wrapper were the same logic written with `if/else` where the other three
   ports used early return / a conditional expression. Normalizing to the
   3-of-4 majority form was **byte-identical in RELEASE on both samd21
   boards** and changed the **DEBUG** image by 4 bytes (48408 → 48404,
   megarm). That is expected and is the correct trade: RELEASE is what
   ships and what `artifacts/` commits; DEBUG exists to be single-stepped.
   But it means `MANIFEST.sha256`'s (uncommitted, `#`-prefixed) DEBUG hash
   lines for the two samd21 boards move, and a reviewer who only knows
   "byte-identical" will read that as a contradiction unless the batch says
   *which flavor* the identity claim covers. Unifying two formattings can
   only ever be `-O0`-invariant for one of them; picking the majority form
   at least minimizes how many ports' DEBUG images move.

3. **A shared header that defines FUNCTIONS is the right shape for the
   TU-replacement route — and must announce that it is not an ordinary
   header.** `serial_ring_accessors.h` and `nvmem_checksum.h` both contain
   function *definitions* and are `#include`d exactly once, from inside a
   port's `serial.c`/`nvmem.c`, **after** that file has declared the
   objects they operate on. This looks wrong until you notice that
   TU-replacement ports ([§7](#serial)) do not link core
   `grbl/serial.c`/`grbl/nvmem.c` at all: there is no translation unit
   these functions could otherwise live in without every port growing an
   extra object file and an extra Makefile line, for five functions of pure
   ring arithmetic. Both files state the requirement, and the include-site
   ordering constraint, in their own banner — the failure mode otherwise is
   an "undeclared identifier" storm at a confusing line.

4. **THE ONE THAT STOPPED AT THREE PORTS: an NVMEM write wrapper is not
   shareable just because it reads identically.** `memcpy_to_nvmem_with_
   checksum` is character-identical in ch32v006/ch570/dspic33ak128mc102 —
   compute the checksum, then issue exactly **two** `nvmem_write_range`
   calls (data, then checksum byte). samd21 has **no**
   `nvmem_write_range` at all: its `eeprom_put_char` performs a full page
   read-modify-write per byte, and its wrapper interleaves checksum
   accumulation with those per-byte puts. Adopting the block form there
   would change what the chip physically does to its flash — a different
   erase/program pattern, i.e. a **behavior and wear-profile change**, not
   a formatting cleanup — and would not have been byte-invariant either.
   So the write half is **opt-in** (`GRBL_NVMEM_HAS_WRITE_RANGE`), samd21
   takes only the read half, and the header says why in-line so the next
   reader does not "finish the job". **Generalizable rule: two functions
   with the same name, signature and observable result are still not the
   same function if they drive the hardware differently. Diff what they DO
   to the peripheral, not just what they return.**

5. **`-I` shadowing is invisible duplication — go looking for it.** The
   four Cortex-M ports each carried a `<port>/avr/io.h` whose only purpose
   was to **shadow** the shared `common/dummy/avr/io.h` via `-I.` preceding
   `-I../common/dummy`. Nothing in any Makefile, header or doc said "this
   file exists to win an include race"; the four copies differed only in a
   chip name inside two comments. This class of duplicate does not show up
   in a grep for repeated *code* — the file name is the giveaway, not the
   contents. The fix also exposed the real constraint that had forced them:
   `grbl.h` includes `<avr/io.h>` at its line 29, long before
   `platform/hal.h` → `platform.h` at line 49, and the shared stub
   deliberately `#error`s when `sei`/`cli` are not yet defined — so those
   two macros must exist **before `grbl.h` is parsed**. There are exactly
   two legitimate ways to arrange that, and this tree now uses both
   explicitly: inject the port's own `platform.h` from `prelude.h` (samd21,
   dspic33ak128mc102), or inject a shared per-architecture critical-section
   header from `prelude.h` (`common/cortexm/cortexm_critical.h` for the
   four Cortex-M ports; `common/wch/wch_critical.h` for the two WCH ports).
   `common/dummy/avr/io.h`'s banner now names both routes instead of
   pointing at per-port stubs that no longer exist.

6. **The `||`-vs-`|` NVMEM checksum boundary survived contact with an
   extraction, and the shared file now enforces it mechanically.** Core
   `grbl/nvmem.c` computes `checksum = (checksum << 1) || (checksum >> 7)`
   — upstream GRBL's logical-OR typo, which
   [§10.4](#nvmem-eeprom) says must NEVER be "fixed" because the golden
   AVR binary and every settings blob already written by an atmega328p in
   the field depend on that exact arithmetic. Every non-AVR port has always
   used the bitwise `|` rotate instead (different storage, different sizes,
   no shared media — they were never bug-compatible with AVR's EEPROM
   contents to begin with). Extracting the non-AVR form is therefore safe,
   but it puts the two forms one careless include away from each other for
   the first time. `common/nvmem_checksum.h` carries the boundary in its
   banner **and** `#error`s outright under `__AVR__`, so the dangerous
   direction fails at compile time rather than relying on a reader
   noticing. Core `grbl/nvmem.c` and `atmega328p/` are untouched by this
   batch; `make -C grbl/platform/atmega328p validate` still reports the
   golden MD5 `79af184e67b27defd27a39309ac53563`.

7. **Timer contract macros are the highest-blast-radius thing in this
   tree; extract them last and say so in the file.** `stm32f103/timer.h`,
   `stm32f411/timer.h` and `stm32h523/timer.h` were 100% code-identical
   (comments and include-guard names were the entire difference), so
   `common/stm32/stm32_timer.h` is a pure dedup. But these are the
   `STP_TMR_*`/`STP_PULSE_RESET_*`/`PWM_*` macros that
   [§3](#stepper-timer)-[§6](#spindle-pwm) mark **ISR-hot**:
   one edit there now lands inside three step ISRs at once. The shared
   header opens with that fact and with the single-register-access
   constraint, because the next editor will otherwise see three ports' worth
   of blast radius as three ports' worth of convenience. The per-family
   notes the three copies carried (F411's APB1 timer-clock doubling to
   96 MHz, the 32-bit TIM2/TIM3 remarks, TIM1's `BDTR.MOE` gating with all
   three reference-manual citations) were merged into the shared file, not
   dropped — a dedup that loses the per-chip *why* is a net loss even when
   the code is identical.
<a id="boot-init-unreachable"></a>
## 27. Defined but never called + LTO = silently absent; byte-invariance is a WEAK signal (cite the slug, #boot-init-unreachable, not "§27", from elsewhere)

*(Companion to [§18](#vector-table-lto), which is the same failure class one
level down: §18 lost a **data** table the hardware reads behind the
compiler's back; this section loses **code** that nothing calls. Cite both
together — the fix for one does not detect the other.)*

Empirical, from BUG #23: `stm32f103`, `stm32f411`, `stm32h523` and
`hc32f460` shipped RELEASE binaries that **configured neither their clock
nor their GPIO**. Each of those four ports contained a complete, reviewed,
documented bring-up chain:

```c
void hal_system_init(void) {
  hal_clock_config();     // HSE -> PLL, flash wait states
  ...
  hal_gpio_init();        // port clocks, directions, pull-ups, AF mux
  ...
}
```

and **not one line of code anywhere called `hal_system_init()`**. Core
`grbl/main.c` is the golden gate: it opens with
`serial_init(); settings_init(); stepper_init(); system_init();` and has
never called platform init — that is precisely why it is golden. No
`Reset_Handler` called it either. So the entire subgraph was unreachable
from any root, GCC's whole-program IPA deleted it before codegen, and
`nm` on all four RELEASE ELFs found **zero** of
`hal_system_init` / `hal_clock_config` / `hal_gpio_init`. The chips booted
on their reset-default internal oscillator with GPIO in reset state.

### Why nothing caught it

Every existing gate is satisfied by a program that never configures the
chip:

| gate | what it proves | why it passed |
|---|---|---|
| the link itself | symbols resolve | unreachable code is *removed*, not *unresolved* |
| `--gc-sections` | no dead sections shipped | it did its job — the code really was dead |
| `size` | text/data/bss are plausible | ~29 KB of core GRBL is still there |
| `boot_check.sh` ([§18](#vector-table-lto)) | word0/word1 are a real reset record | the vector table was fine; `Reset_Handler` just did nothing useful |
| `assert_no_double.sh` ([§17](#fp-precision)) | no DP machinery linked | orthogonal |
| DEBUG build | everything present | **no `-flto`** — the dead chain is retained, so a DEBUG symbol dump looks perfect |

That last row is the same "DEBUG works / RELEASE bricks" signature as
[§18](#vector-table-lto), and it is worth internalizing as a *smell* rather
than a coincidence: **any defect whose mechanism is LTO reachability
analysis will present as DEBUG-clean.** Checking the DEBUG build is
checking the wrong artifact.

### The lesson that generalizes: byte-invariance is a WEAK signal

The tell that finally exposed this was supposed to be reassuring. Changing
`SPINDLE_ENABLE_PIN` in `stm32f103`'s board config and rebuilding produced
a **byte-identical** RELEASE `.bin` (md5 `b12b018e…` before and after).
Read one way that is textbook determinism. Read correctly it is proof that
**the only code consuming the pin map was not in the image**.

> A byte-identical rebuild proves two things are the same. It does **not**
> prove either one is *present*. When the code under test may be
> unreachable, "nothing changed" and "nothing is there" produce the
> identical observation, and byte-invariance cannot tell them apart.

So byte-invariance is only evidence *after* presence has been established
independently. The same reasoning applies to any invariance argument in
this tree — the extraction rebuild gates ("verified byte-identical by this
batch's rebuild gate", used in [§24](#wch-common-extraction-ch570) among
others) are sound **only** for code already proven to be linked in. Invert
the test when you need presence: perturb something the code under test
must consume and demand the binary **changes**. Post-fix, the same pin
flip moves the f103 image (`156056…` → `340f83…`); pre-fix it did not
move at all. That before/after pair is the actual proof, not either half
alone.

### The fix: the call comes from the platform side

`grbl/main.c` is untouchable, so the call cannot go there — and it should
not: pre-`main()` chip bring-up is not core's business. The established
precedent in this tree is `samd21/startup.c`, whose `Reset_Handler` has
always called `SystemInit()` and `SysTick_Config()` itself before
`main()`. That call is exactly why samd21 was immune to BUG #23 (and,
separately, why it was immune to BUG #21). All four broken ports now match
that shape:

```c
void Reset_Handler(void) {
  SCB->VTOR = (uint32_t)vector_table;   /* §18 */
  /* copy .data, zero .bss, __DSB() */
  hal_system_init();                    /* BUG #23 */
  main();
}
```

**Ordering inside that sequence is load-bearing** and is spelled out at
every call site rather than left to be re-derived:

1. `.data`/`.bss` **first** — `hal_gpio_init` and the NVMEM cache write
   initialized statics; running before the copy loop has them overwritten.
2. **clock before flash wait states before anything timing-dependent** —
   each port's `hal_clock_config` raises `FLASH->ACR` latency (or the EFM
   equivalent) *before* selecting the faster source, then the timing layer
   (`SysTick_Config` / `stm32_timing_init` / `hc32_systick_init`) derives
   its dividers from the final frequency.
3. **GPIO after clock** — the port-clock enables `hal_gpio_init` writes
   (`RCC->APB2ENR`/`AHB1ENR`/`AHB2ENR`) are meaningless until the bus
   clocks are settled.
4. `main()` **last** — core's `serial_init()`/`settings_init()` need the
   final clock and a live NVMEM cache.
5. `VTOR` before all of it, so a fault or IRQ raised *during* bring-up
   vectors into this image rather than a bootloader's table.

### The ratchet: `common/init_check.sh` (the seventh)

Post-link, per port, wired into each port's own Makefile immediately after
the no-DP assert — the same wiring point as `boot_check.sh`, so covering a
new port needs no CI change:

```make
INIT_SYMBOLS ?= Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init
	@sh ../common/init_check.sh $(PREFIX)nm $@ $(INIT_SYMBOLS)
```

It fails the build if any declared symbol is not **defined** (`nm` type
other than `U`) in the linked image. **Symbol lists are per-port and
declarable** because ports genuinely name this differently, and the
differences are informative rather than cosmetic:

| port | declared `INIT_SYMBOLS` | why this shape |
|---|---|---|
| stm32f103 / f411 / h523, hc32f460 | `Reset_Handler,hal_system_init,hal_clock_config,hal_gpio_init` | the shared three-function chain (default in `common/stm32/common.mk`) |
| samd21 | `Reset_Handler,SystemInit` | clock bring-up lives in `startup.c::SystemInit`; GPIO is configured per pin group by core's `*_init` |
| ch32v006, ch570 | `Reset_Handler,SystemInit,SystemClock_Config` | two-level split, `SystemInit` → `SystemClock_Config` in `platform.c` |
| dspic33ak128mc102 | `__reset,__user_init,_hal_clock_config,_main` | toolchain `crt0`, not a hand-written `startup.c`; pic30 assembler underscore prefix |
| atmega328p | `__init,main,serial_init,settings_init,stepper_init,system_init,limits_init,spindle_init,coolant_init,probe_init` | no software clock/GPIO bring-up at all — fuses plus the original per-`*_init` DDR/PORT model |

`atmega328p`'s leg hangs off `grbl/platform/atmega328p/Makefile` rather
than the port's real link, because that link happens in the golden-MD5-gated
root `Makefile`, which stays byte-untouched. It is also the deliberate
**control case**: the one port with no `-flto` and therefore the one port
where this defect could not have occurred.

### Why symbol presence is a reachability proof — and the one attribute that would destroy it

After a `-flto` + `--gc-sections` link, a function survives **only** if
something reaches it. "Defined in the final ELF" therefore *means*
"reachable". There is exactly one false negative — **inlining**: a
single-call-site init folded into its caller is present and executed but
has no symbol. That is not hypothetical, it is the normal case here
(`SystemInit` has one call site on samd21/ch32v006/ch570 and was being
inlined into `Reset_Handler`, producing an `nm` output byte-for-byte
indistinguishable from the four broken ports). The port side removes the
ambiguity with `GRBL_BOOT_INIT` (`grbl/platform/common/boot_init.h`):

```c
#define GRBL_BOOT_INIT __attribute__((noinline))
```

**`noinline`, and deliberately NOT `used`.** This is the subtle part, and
it is the opposite of the [§18](#vector-table-lto) answer:

- `noinline` kills the false negative without keeping anything alive. An
  init nobody calls is still deleted — which is exactly what the check
  needs in order to have teeth.
- `used` forces emission **even if unreferenced**. Applied to
  `hal_clock_config()` it would have put the symbol in every image whether
  or not a single instruction branched to it, and this ratchet would have
  reported all four broken ports **green**. `used` is correct for a data
  table the hardware reads behind the compiler's back (`vector_table[]`,
  §18); it is precisely wrong for a function whose *reachability is the
  property under test*.

Generalizing: **a guard attribute must not manufacture the evidence the
guard inspects.** §18 needs `used` because there is no reachability to
prove — the hardware is the consumer and it is invisible to the compiler.
This section must refuse `used` for the same reason §18 needs it.

`init_check.sh --selftest` (pure logic, no compiler — matching
`tools/assert_no_double.sh` / `ci/warn_ratchet.py` /
`tools/build_artifacts.py`) covers both directions, including the verbatim
pre-fix `stm32f103` symbol table as the positive case, `U`-typed
references rejected as not-defined, weak (`W`) definitions accepted (the
dsPIC `user_init` shape), and a substring lookalike (`hal_gpio_init_late`)
rejected as not satisfying `hal_gpio_init` — a `grep`-based implementation
passes that one, which is why the matcher is field-exact.

### Two adjacent defects this audit surfaced (NOT fixed here — separate work items)

Recorded so they are not rediscovered as novel:

1. **`ch32v006` never enables GPIOC/GPIOD port clocks — CLOSED, BUG #24.**
   `RCC->PB2PCENR` was written in exactly two places that set an `IOPxEN`
   bit: `hal_timer_spindle_pwm_init` (adds `IOPAEN`) and `serial_init`
   (adds `IOPDEN`). The board's STEP/DIRECTION/STEPPERS_DISABLE/COOLANT
   pins are all on **GPIOC**, and CONTROL is on **GPIOB** — neither port's
   clock was ever enabled anywhere (broader than the original one-line
   finding above, which named only GPIOC/GPIOD: GPIOB was equally
   ungated). LIMIT/serial's GPIOD was enabled only incidentally, by the
   serial path, which is exactly the kind of coincidence that breaks the
   moment a board separates those two signals onto different ports. Same
   *symptom class* as BUG #23 — a port whose pins are never really
   configured — but a different *mechanism*: the register write does not
   exist, rather than existing and being unreachable, so the BUG #23
   ratchet could not see it (there is no missing symbol to detect). See
   the new "A configured, wired GPIO pin still does nothing if its PORT's
   bus clock was never gated on" section appended at the end of this file
   (anchor `gpio-port-clock-gating`) for the fix and the new
   reachability-based ratchet — not linked here as a real markdown link:
   its heading is still `§NEW` (integrator renumbers), and this checker's
   `## N.` heading pattern does not register a `§NEW` section's anchor as
   a valid link target until that renumbering happens, so a real link
   here would report as dangling until then.
2. **`SPINDLE_ENABLE_PIN` has two conflicting live values on
   stm32f103/f411/h523.** The port's `config.h` (which shadows core's via
   `-I.`) and `platform.h` both define it unguarded, with *different*
   numbers — and which one wins **depends on include order per translation
   unit**: `platform.c` includes `platform.h` then `config.h` (so
   `config.h` wins inside `hal_gpio_init`), while core TUs reach
   `platform.h` last through `grbl.h` (so `platform.h` wins in
   `spindle_control.c`). The same signal is therefore configured on one
   pin and driven on another. Additionally `stm32h523::hal_gpio_init`
   consumes neither macro — it hardcodes `(1 << 7)` literals, so its pin
   map is decorative regardless.

<a id="gpio-port-clock-gating"></a>
## 28. A configured, wired GPIO pin still does nothing if its PORT's bus clock was never gated on (BUG #24)

Distinct from [§boot-init-unreachable](#boot-init-unreachable) (BUG #23,
code that exists but nothing calls) and from [§1](#gpio-data) (pins wired
to the wrong bit): this is a port whose GPIO code is reachable, correct,
and called — and still inert, because the peripheral bus never delivered
a clock to that port's register block. On every ARM/RISC-V MCU family in
this tree, each GPIO port sits behind its own bit in a peripheral
clock-enable register (STM32 `RCC->APB2ENR`/`AHBxENR` IOPxEN/GPIOxEN,
CH32V00x `RCC->PB2PCENR` IOPxEN, HC32/others under a different name for
the same gate). While that bit is 0, the port's registers read back all
zero and ignore every write — `CFGLR`/`MODER`/`OUTDR` writes silently
no-op, exactly like [§3](#stepper-timer)'s "prescaler that compiles and
destroys machine behavior" cautionary tale, one level down in the address
space instead of in a macro body.

**Empirical case, ch32v006 (verified via a real `make BUILD=RELEASE`
rebuild this session, `grbl/platform/ch32v006/`):** `RCC->PB2PCENR` had
exactly two write sites that ever set an `IOPxEN` bit —
`hal_timer_spindle_pwm_init()` (`IOPAEN`, because it also owns TIM1's
AFIO remap) and `serial_init()` (`IOPDEN`, because USART1 lives there).
Cross-checking the board's own pin map
(`boards/generic/config.h`) against that set:

| Port | Signals | Clock ever enabled? |
|---|---|---|
| GPIOA | PROBE, SPINDLE_ENABLE/DIRECTION/PWM | yes (`hal_timer_spindle_pwm_init`) |
| GPIOB | CONTROL_RESET/FEED_HOLD/CYCLE_START/SAFETY_DOOR | **no** |
| GPIOC | STEP, DIRECTION, STEPPERS_DISABLE, COOLANT_FLOOD | **no** |
| GPIOD | LIMIT, SERIAL_TX/RX | yes (`serial_init`, incidentally covers LIMIT) |

GPIOC carried the entire motion output group — on real silicon this board
never moves, never disables steppers, and never runs coolant, while
compiling clean, linking clean, and passing every existing gate (golden
AVR untouched, warning ratchet green, `assert_no_double.sh` green,
[§boot-init-unreachable](#boot-init-unreachable)'s `init_check.sh` green
— that ratchet proves `SystemInit` and `SystemClock_Config` are reachable,
it says nothing about which bits they set). GPIOB (CONTROL: feed-hold/
cycle-start/reset/safety-door) was equally dead. GPIOD only worked by the
coincidence of LIMIT and USART1 sharing a port on this particular
placeholder pin map — a board that moved LIMIT to its own port would lose
limit switches with no other code change and no compiler warning.

### The fix: derive the enable set from the pin map, not a literal

`grbl/platform/ch32v006/platform.c` gained a `gpio_port_clken(GPIO_TypeDef*)`
helper (pointer-equality dispatch over `GPIOA/B/C/D`) and
`hal_gpio_clock_init()`, which ORs the result of that helper over every
`*_PORT` macro the board defines (`STEP_PORT`, `DIRECTION_PORT`,
`STEPPERS_DISABLE_PORT`, `COOLANT_FLOOD_PORT`, `LIMIT_PORT`,
`CONTROL_PORT`, `PROBE_PORT`, `SPINDLE_ENABLE_PORT`,
`SPINDLE_DIRECTION_PORT`, `SPINDLE_PWM_PORT`, `SERIAL_TX_PORT`,
`SERIAL_RX_PORT`) into `RCC->PB2PCENR`. A hand-written literal
(`IOPAEN|IOPBEN|IOPCEN|IOPDEN`) would have fixed today's board but drifts
silently the moment a re-pin adds a port nobody remembers to add to the
literal — the exact failure mode this section documents, reintroduced by
the fix itself. Deriving from the same `*_PORT` macros the pin-config code
already consumes means a re-pin that moves a signal to a new port
automatically gates that port's clock too; it cannot silently regress.
The redundant `IOPAEN`/`IOPDEN` bits previously set inline inside
`hal_timer_spindle_pwm_init`/`serial_init` were removed (single source of
truth) once `hal_gpio_clock_init()` — called from `SystemInit()` before
`main()`, per [§boot-init-unreachable](#boot-init-unreachable)'s ordering
rule "GPIO after clock, both before `main()`" — was proven to run first.

### The ratchet considered, and the one actually added

A `_Static_assert` cannot check this: `*_PORT` are runtime pointer values
(`(GPIO_TypeDef*)0x...`), not preprocessor-comparable tokens, so there is
no way to assert at compile time "the enable mask covers every port these
pointers name" without reimplementing the same runtime dispatch inside
the assert and thereby checking the derivation against itself — a guard
that cannot fail (PLAN.md's standing warning about `assert_no_double.sh`-
class guards applies here too). What *was* added is
[§boot-init-unreachable](#boot-init-unreachable)'s existing reachability
ratchet, extended: `hal_gpio_clock_init` is tagged `GRBL_BOOT_INIT` and
added to `ch32v006/Makefile`'s `INIT_SYMBOLS`, so `common/init_check.sh`
now proves it is a real, called, non-inlined function in every RELEASE
link — the same proof BUG #23 established for `SystemInit`/
`SystemClock_Config`. That proves the function *runs*; it does not prove
its *contents* are complete (a future board that adds a 5th port and
forgets to add it to `hal_gpio_clock_init`'s OR-chain would still pass
every existing gate). This is the honestly-scoped half of the fix: the
reachability ratchet was cheap, real, and reused an established mechanism;
a completeness ratchet was not, and none was invented to fake one. Porters
adding a new `*_PORT` to a board's config.h must manually extend
`gpio_port_clken`'s dispatch and `hal_gpio_clock_init`'s call list — flagged
in `PORTING-CHECKLIST.md`'s GPIO step so it is asked at the right time
instead of discovered on the bench.

`ch570` (`grbl/platform/ch570/`, same WCH family, shares `common/wch/`)
was audited for the same defect and does **not** have it: that chip has a
single GPIO port ("PA", `ch570.h` — datasheet: "The chip provides a group
of GPIO ports PA with 12 general input and output pins") implemented as
always-on discrete registers, AVR-style — there is no per-port clock-gate
register for GPIO on this chip at all (confirmed by reading `ch570.h`'s
register map: the only gated peripherals behind `R8_SLP_POWER_CTRL`/
`R8_CLK_SYS_CFG` are clock-tree and sleep-mode related, never GPIO). No
change was made to ch570 — there is nothing to gate.

<a id="prelude-phase-dead-guard"></a>
## 29. A guard in the wrong TRANSLATION PHASE certifies just as falsely as one checking the wrong symbol family — §19's lesson 1, in a new shape (cite the slug, #prelude-phase-dead-guard, not "§29", from elsewhere)

Found auditing the sg2002 port's build prelude against every other port's,
for the pattern `#ifdef STEP_PULSE_DELAY` / `#error` in `timer.h`.
[§19](#guard-hardening) lesson 1 established that a guard checking the
*wrong symbol family* certifies the exact thing it exists to catch. This is
the same certification failure, but the wrong dimension is *when the
preprocessor sees it*, not *what it's named*.

**The mechanism.** Every non-AVR port's Makefile injects one board prelude
into EVERY translation unit via `-include boards/$(BOARD)/prelude.h`
(CONTRACTS.md §0) — this happens before the compiler even opens the `.c`
file being compiled, i.e. before that file's own `#include "grbl.h"` and
therefore before grbl.h's `#include "config.h"` (grbl.h line ~42) has ever
run. `STEP_PULSE_DELAY`, `ENABLE_M7`, and every other user-facing feature
toggle are `#define`d **only** inside core `grbl/config.h`. On
`ch32v006`, `ch570`, `samd21`, and `dspic33ak128mc102`, the prelude itself
`#include`s the chip's `platform.h` (needed for `sei`/`cli` before grbl.h's
`common/dummy/avr/io.h` stub demands them — a real, load-bearing reason),
and `platform.h` pulls in `timer.h`. Any `#ifdef STEP_PULSE_DELAY` or
`#ifdef ENABLE_M7` written inside `timer.h` or a board's `config.h` (pin
map) is therefore evaluated during the PRELUDE pass, while the macro it
tests is provably still undefined — and because `timer.h`/`config.h` carry
the usual `#ifndef FOO_H` double-inclusion guard, that is the ONLY time
the file's body is ever processed in that translation unit. grbl.h's own,
correctly-timed `#include "config.h"` later in the SAME file reopens
`timer.h`, finds the guard already set, and skips the body entirely — the
guard never gets a second chance to see the macro defined.

**Proof of the phase ordering** (`-E -dD` on ch32v006, compiling from
`grbl/platform/ch32v006/`, prelude flags exactly as the Makefile passes
them): the FIRST (and only) processing of `timer.h` happens at output line
2614, inside the prelude's `platform.h` include, closing at line 2651 —
`#define TIMER_CH32V006_H` (the guard) appears exactly once, at line 2616.
Core `grbl/config.h` is not reached until line 4947, deep inside grbl.h's
own chain (`grbl.h` -> `config.h`), **2300+ preprocessor lines after**
`timer.h`'s guard was already set. The second attempt to pull in
`platform.h` later (hal.h -> `ch32v006/platform.h`, line 5558) opens the
file and immediately closes it — guard hit, body skipped, `timer.h` never
re-entered.

**Proof it was live and silent, not theoretical.** Uncommenting
`grbl/config.h`'s `STEP_PULSE_DELAY` line and building `ch32v006`/`ch570`
(`#error` guards) exits 0 — no error, no warning, feature silently
unsupported. Uncommenting `ENABLE_M7` and building `ch32v006` fails, but
with `./boards/generic/../../gpio.h:39:41: error: invalid type argument of
'->' (have 'int')` — not the intended diagnostic. Root cause: the board
`config.h` pin map's `#ifdef ENABLE_M7` (same wrong-phase bug) never
defines `COOLANT_MIST_PORT`/`_BIT`, so `common/dummy/cpu_map.h`'s
`#ifndef COOLANT_MIST_PORT` fallback silently supplies literal `0`, and
`GPIO_OREG` then dereferences `(0)->OUTDR`. On `samd21` the SAME missing
pin macros resolve differently and *far more dangerously*: that port's
`GPIO_OREG` is `PORT->Group[name##_PORT].OUT`, an array index rather than
a struct-pointer dereference, so the bogus fallback `0` is a **syntactically
valid** `Group[0]` — the build succeeds and silently drives the wrong
physical pin. Same dead guard, three different failure shapes (silent
pass, confusing compile error, silent wrong-pin) depending on the
consuming macro's shape — the guard itself never discriminates any of
them, which is exactly §19 lesson 1's "certifies the exact thing it exists
to catch," just reached via phase instead of naming.

**Audit, all prelude-injecting ports** (only a port whose prelude chain
`#include`s `platform.h`/board `config.h` before grbl.h is exposed —
`stm32f103`/`stm32f411`/`stm32h523`/`hc32f460` deliberately keep
`platform.h` out of their prelude and reach it only through grbl.h's
ordinary chain, documented in their own prelude.h headers, so their
`#ifdef ENABLE_M7` in `platform.h` is correctly timed and NOT part of this
class; `sg2002`'s prelude includes nothing; `atmega328p` has no prelude at
all):

| Port | File | Guard | Shape | Fix |
|---|---|---|---|---|
| ch32v006 | timer.h | `#ifdef STEP_PULSE_DELAY` / `#error` | dead — hardware genuinely lacks a 2nd interrupt timer | moved to serial.c (already `#include`s grbl.h post-prelude) |
| ch570 | timer.h | `#ifdef STEP_PULSE_DELAY` / `#error` | dead — same hardware limit | moved to serial.c |
| dspic33ak128mc102 | timer.h | `#ifdef STEP_PULSE_DELAY` / `#error` | dead — CCP1RB dual-compare unverified | moved to serial.c |
| dspic33ak128mc102 | boards/generic/config.h | `#ifdef ENABLE_M7` / `#error` | dead — genuine 19-GPIO pin-budget exhaustion | moved to serial.c |
| samd21 | timer.h | `#ifdef STEP_PULSE_DELAY` gating `STP_PULSE_DELAY_INIT()` | dead — and the guarded body itself references an undeclared `TC5` (a second, independent latent bug the dead guard had been hiding end-to-end) | omitted the broken macro (matches ch32v006/ch570's "genuinely unsupported" precedent); `#error` moved to serial.c |
| ch32v006 | boards/generic/config.h | `#ifdef ENABLE_M7` gating `COOLANT_MIST_*` | dead — pin is real, gate was pointless | made unconditional |
| ch570 | boards/generic/config.h | `#ifdef ENABLE_M7` gating `COOLANT_MIST_*` | dead — pin is real | made unconditional |
| samd21 (generic + megarm) | \*/config.h | `#ifdef ENABLE_M7` gating `COOLANT_MIST_*` | dead — pin is real | made unconditional |
| _template | timer.h, boards/generic/config.h | both of the above, PORT_TODO-stub shaped | dead — propagates to every port copied from this file | made unconditional (matches the working ports' fix) |

**The fix, and why two different shapes.** Two genuinely different repair
strategies were needed, and conflating them would have been wrong:

1. *A guard that certifies "unsupported" for a real hardware limitation*
   (an `#error`) cannot be evaluated inside the prelude chain at all — it
   was relocated to each port's `serial.c`, which already carries its own
   `#include "../../grbl.h"` for unrelated reasons (BUG #19 realtime-byte
   interception) and is therefore the first REAL processing of core
   `config.h` in that translation unit. `#ifdef FEATURE / #error "..."`
   placed immediately after that include fires correctly, proven by
   re-enabling each macro and confirming the build now fails with the
   intended message (verified DEBUG+RELEASE, reverted after).
2. *A guard gating a plain constant `#define` that has no downstream cost
   when unused* (pin-map macros, an unconditionally-safe timer macro) does
   not need to be conditional AT ALL — core's own copy of the same
   `#ifdef FEATURE` test, reached correctly through grbl.h's ordinary
   chain, is the only place that ever consumes the macro. Deleting the
   dead prelude-phase gate and defining the constant unconditionally is
   strictly safer than trying to relocate a non-boolean definition to a
   different translation unit (which would make it invisible to whichever
   TU actually needs it — `serial.c` is not where `COOLANT_MIST_PORT` gets
   used).

Byte-identical canonical builds (both flavors, every affected port)
re-verified after the fix; see PLAN.md for the full build log.

**General takeaway:** before trusting an `#ifdef`/`#error` guard inside any
header a Makefile injects via `-include`, ask not just "does this test the
right macro" (§19 lesson 1) but "has this macro's OWNING file been
processed yet, on THIS specific inclusion path, in THIS translation
unit" — a prelude is, by construction, code that runs before the file
being compiled has said anything at all; a macro defined by that later
file's own include chain is invisible to it, permanently, once an
`#ifndef` guard has already made its one pass.

---

<a id="lto-asm-only-reachable-symbols"></a>
## 30. `-flto` on ch32v006/ch570: an assembly-only-reachable symbol is BUG #21's mechanism, one ISA over (cite the slug, not "§30", from elsewhere)

A compactness audit measured real, rebuilt savings from enabling `-flto`
`-fno-fat-lto-objects` (RELEASE only, house style — see below) on the two
RISC-V ports: ch32v006 41072 → **39012** (−2060 B, −5.0%); ch570 40674 →
**38422** (−2252 B, −5.5%). Both numbers reproduced exactly on a real
rebuild in this batch, not projected.

**The precondition the audit hit before either number was real: naive
`-flto` breaks the boot path.** Both RISC-V startup files
(`ch32v006/startup.c`, `ch570/startup.c`) reach `Reset_Handler` from
exactly one place — `_start`'s raw inline assembly:

```c
__attribute__((naked, section(".init")))
void _start(void) {
  __asm__ volatile (
    "la sp, _estack \n"
    "jal Reset_Handler \n"
  );
}
```

`jal Reset_Handler` is a string GCC's LTO frontend never parses for symbol
references — it is opaque to the whole-program IPA pass that decides what
survives into codegen. `Reset_Handler` has no other caller anywhere in the
C call graph (nothing else in the tree calls it; it is reached only via
this one `jal`). With `-flto` and no visible reference, IPA for an
executable link (GCC treats a non-PIC executable link as implicitly
whole-program) concludes `Reset_Handler` is dead and deletes its
*definition* before codegen ever runs. `_start` itself survives (`ld`'s
`ENTRY(_start)` — reinforced here by `script.ld`'s `KEEP(*(.init))` —
keeps the linker's own root set anchored on it), so the build does not
silently produce a bricked image the way [§18](#vector-table-lto)'s
ARM vector-table case did. Instead the *link fails loudly*:
`undefined reference to 'Reset_Handler'` — the one call site referencing it
(the `.init` object's relocation) now points at nothing. Loud is better
than silent, but it is still the same root cause as BUG #21, seen through a
different ISA's boot mechanism: **a symbol reachable only from raw assembly
(or only from a hardware-loaded table) is invisible to LTO's IPA and must
be pinned with `__attribute__((used))`, regardless of which architecture or
which flavor of "invisible to the compiler" is in play.** §18's ARM ports
dodge this specific instance only because their `Reset_Handler` happens to
be address-taken from a C-visible `vector_table[]` (`SCB->VTOR = (uint32_t)
vector_table;`) — a defense that has no equivalent here, because RISC-V
reset is entered by hand-written asm, not a hardware-loaded pointer table.

**Fix**: `__attribute__((used))` on `Reset_Handler` in both
`ch32v006/startup.c` and `ch570/startup.c` — nothing else. `used` pins the
symbol to GCC's emitted-symbols root set independent of visible callers,
the same role it already plays on `PFIC_Vector[]` in the same two files
(landed earlier, `--gc-sections` lifecycle fix, [§14 item 3](#ch32v006-riscv-gaps)).

**The rest of the audit: every other assembly-/table-reachable symbol on
both ports was already `used`-pinned before this batch, verified by nm/
disassembly, not assumed:**
- `PFIC_Vector[]` (both ports): `__attribute__((used, section(".vectors")))`
  already, plus `script.ld`'s `KEEP(*(.init)) KEEP(*(.vectors))` — landed
  during the M1-M3 `--gc-sections` reachability fix, unaffected by this
  batch.
- Every ISR body addressed only via `PFIC_Vector[]`
  (`Default_Handler`, `SysTick_Handler`, `TIM2_IRQHandler`,
  `EXTI7_0_IRQHandler`, `USART1_IRQHandler` on ch32v006;
  `Default_Handler`, `SysTick_Handler`, `TMR_IRQHandler`,
  `GPIOA_IRQHandler`, `UART_IRQHandler` on ch570): address-taken by a
  `used`-anchored array initializer, so IPA treats them as reachable —
  confirmed present by name in a post-`-flto` `nm` on both RELEASE ELFs
  (`_start`, `Reset_Handler`, `PFIC_Vector`, and all of the above, every
  one), and `mret` (opcode `0x30200073`) disassembly-confirmed as the last
  instruction of two ISR bodies per port ([§20](#wch-isr-attribute)'s
  trap-return contract — `TIM2_IRQHandler`/`USART1_IRQHandler` on
  ch32v006, `TMR_IRQHandler`/`UART_IRQHandler` on ch570).
- `_start` itself: not `used`, and does not need to be — it is the
  linker's `ENTRY()` symbol, a root the linker plugin's own symbol
  resolution keeps independent of C-level call-graph visibility. The
  Makefile's existing RISC-V boot-integrity check (`nm | grep ' _start$'`
  must equal the flash origin) is unchanged and still the correct
  belt-and-suspenders assertion for this fact — if a future toolchain
  ever failed to protect the entry symbol under LTO, this check catches it
  the same way it already catches any other reason `_start` might not land
  at the flash base.
- `ch570/vendor/ISP572.o` (the one vendored non-LTO object, linked as a
  plain `.o`, not compiled with `-flto`): mixing an ordinary object into an
  otherwise-LTO link is supported by design — it participates in the final
  link as opaque machine code, not LTO IR, and needs no `used` audit of its
  own (nothing in it is reached only from assembly; its one entry point is
  called from ordinary C in `nvmem.c`).

**House style matched, not invented**: `-flto -fno-fat-lto-objects` in
`CFLAGS` and `-flto -Os` in `LDFLAGS`, gated on `BUILD==RELEASE` only —
copied from `samd21/Makefile` (`grbl/platform/samd21/Makefile:134,150`) and
`grbl/platform/common/stm32/common.mk:114,130`, which every ARM port in
this tree already uses the same way. DEBUG stays `-Og -g3` on both RISC-V
ports, untouched — same reasoning as every other port: LTO's cross-TU
inlining/reordering makes single-stepping/variable inspection unreliable,
and DEBUG has no size pressure `-Og` doesn't already relieve. Confirmed
both DEBUG binaries are byte-for-byte unaffected by this batch (`used` is
inert without `-flto`): ch32v006 DEBUG 46988/0 unchanged, ch570 DEBUG
46830/4 unchanged (both match the pre-batch recorded figures exactly).

**GATES this batch re-ran (not just inspected)**: golden AVR `make -C
grbl/platform/atmega328p validate` **PASSED** (MD5
`79af184e67b27defd27a39309ac53563`, text 30640); boot integrity OK both
RISC-V ports both flavors (`_start=0x00000000`); FP=SINGLE post-link assert
PASSED all four RISC-V builds; warning ratchet clean against
`ci/warn_baseline_ch32v006.txt`/`ci/warn_baseline_ch570.txt` for all four
logs (ch570 RELEASE additionally dropped 4 warnings that no longer fire —
recorded as ratchet-reported removal candidates, baseline left as-is per
the one-way-ratchet rule); zero `PORT_TODO_*` in all four ELFs;
`tools/build_artifacts.py check` **OK** across all 10 buildable units after
refreshing `artifacts/ch32v006/` and `artifacts/ch570/` (`bin`/`hex`/`syms`
+ `MANIFEST.sha256`) — the other 8 units rebuilt byte-identical to their
already-committed artifacts (confirmed via `git diff --stat`: zero bytes
changed outside `ch32v006/`, `ch570/`, and `MANIFEST.sha256`), so this
batch's `-flto` change is confirmed scoped to exactly the two ports it
targets. `tools/build_artifacts.py --selftest`,
`tools/assert_no_double.sh --selftest`, `ci/warn_ratchet.py --selftest`,
and `tools/check_contracts_numbering.py` all still PASS unchanged.
**`grbl_<port>.elf.dump` added — a readable disassembly diff, tracked
CONTINUOUSLY, never hash-gated (this batch)**: owner directive was to put
an objdump log next to each ELF so a build-to-build change is visually
diffable even though the ELF itself (and now the dump) legitimately
differs every compile. Full flag-by-flag rationale, measured per-unit/
total sizes, and the `.gitignore`/`git archive` proof live in
`artifacts/README.md` (the `.elf.dump` sections); summarized here for the
canonical-detail location:

- **Flags**: `-d -S -h -t --no-show-raw-insn`, run through each port's own
  `objdump`. `-d` (not `-D`) keeps the disassembly to CODE sections only.
  `-S` is a verified no-op on today's `-g0` RELEASE builds, kept free for
  future-proofing. `--no-show-raw-insn` measured ~24% smaller (stm32f103:
  455,508 → 345,950 bytes) and keeps the diff about instructions, not
  encoded bytes. `--no-addresses` was rejected — unsupported by
  `avr-objdump` 2.26 / `xc-dsc-objdump` 2.32, would break two of the four
  toolchains. `-r` was rejected — relocations are empty in a final linked
  executable, verified.
- **Tracking policy: CONTINUOUS** (every refresh, same cadence as `.syms`),
  not tag-gated like `.elf` despite the shared name — argued from purpose:
  the owner wants a diff of what changed *between builds*, and a tag-only
  dump would only ever be diffable release-to-release, reopening the exact
  gap `.bin`/`.hex`/`.syms` exist to close. Generated from the same
  scratch-built RELEASE `.elf` `.syms` already reads; no committed `.elf`
  needs to exist alongside it between tags.
- **Size cost, measured**: 293 KB (hc32f460) – 649 KB (dsPIC33AK) per unit,
  2.5-3.9x each unit's `.elf` (atmega328p 9.6x, AVR disassembly density,
  not a flag bug). Total across ten units: **3,942,120 bytes (~3.76 MiB)**
  added to every full refresh — bringing the tracked tree from 32 files/
  1,403,154 bytes to 42 files/5,345,274 bytes (~281% growth). Stated
  plainly, same posture as every other growth-cost number in this section.
- **NOT hash-gated, proven not asserted**: `objdump` prints its own
  invocation path as line 1 of every dump, on every toolchain — proven by
  rebuilding stm32f103 RELEASE from two different absolute paths: `.elf`
  byte-identical (`cmp`: no difference), `.elf.dump` differs by exactly
  that one echoed-path line. This repo's actual workflow (fresh worktree
  per task) hits that difference on effectively every `check` run.
  dsPIC33AK's dump is additionally non-reproducible even from the SAME
  path (same tempfile-section-name/pointer-derived-symbol-name root cause
  as its existing `nondeterministic_elf` `.elf` exemption, reconfirmed this
  batch). `tools/build_artifacts.py check` verifies `.elf.dump` PRESENCE
  only, explicitly, per unit, every run — never silently. The pre-existing
  56-file hash-gated set is unchanged (`check` still reports "56 file(s)
  verified fresh across 10 unit(s)").
- **`-ffile-prefix-map=$(CURDIR)=/grbl-src` (DEBUG `.elf` manifest-hash
  path-independence, subsection above) reviewed against this batch's "ELF
  variation is storage, not diffing" framing, and KEPT**: that ruling is
  about not chasing `.elf` byte-stability for a binary diff (correct, and
  exactly why `.elf.dump` now exists instead) — it does not bear on
  `-ffile-prefix-map`, which fixes a *different*, still-live problem
  (spurious DEBUG-hash "drift" in `check` purely from checkout-path
  differences, which this project's actual multi-worktree workflow hits
  constantly). Zero storage cost either way (compiler flag, not a tracked
  byte), so dropping it would only reintroduce a real false-positive risk
  for no benefit. Left unchanged in every port's `Makefile`.
- **`.gitignore` proof**: `*.elf` matches paths ending `.elf`, not
  `.elf.dump`; no `*.dump` rule exists. `git check-ignore -v` on every
  committed `.elf.dump` prints nothing / exits 1 (all ten units); a
  post-commit `git archive HEAD` extraction was checked to include all ten
  paths — the same class of proof `tools/README.md`'s original fix needed,
  applied before this became a fourth blanket-ignore surprise.

<a id="limit-bit-width-second-consumer"></a>
## 31. A width contract has as many consumers as there are call sites — audit all of them, not the one you found first (cite the slug, not "§31", from elsewhere)

BUG #26 (2026-07-26, found via an independent-compiler probe: `clang
-Wconstant-conversion` on `grbl/settings.c:339`, a core file; gcc's
`-Woverflow` had also flagged it, but as an accepted, unexamined baseline
entry — see the closing note below).

**The defect.** `stm32f103`, `stm32f411` and `stm32h523` all declared
`Z_LIMIT_BIT = 10` (physical PB10 on all three — a shared donor pin map,
not three independent mistakes). [§1.3](#gpio-data) already states the
rule this violates: input-group bits must land in bits 0-7 because core
narrows the group read to `uint8_t`. One of the three ports' `platform.h`
carried a long, careful comment tracing exactly that consumer
(`limits.c`'s `uint8_t pin = GPIO_MRD(LIMIT, IREG)`) and correctly showing
X/Y/Z are all tested individually against the *same* group value — then
concluded the port was safe. It wasn't: `grbl/settings.c`'s
`get_limit_pin_mask(uint8_t axis_idx)` — a **second, independent** core
consumer of `Z_LIMIT_BIT`, in a different file, doing a different kind of
truncation (a function return, not a variable assignment) — does
`return((1<<Z_LIMIT_BIT));` from a function declared to return `uint8_t`.
`1<<10 = 1024`, truncated to `uint8_t` = **0**. `limits.c`'s per-axis test
`pin & get_limit_pin_mask(idx)` is therefore unconditionally false for Z,
regardless of whether the first truncation (the one that got audited) was
ever fixed.

**Why it mattered on real hardware, not just in principle**:
`limits_get_state()` (backed by both truncations above) is the *only*
detection path during a homing cycle — `motion_control.c` disables the
interrupt-driven hard-limit ISR for the entire homing cycle by design
(the ISR's own top-of-body comment says so: "this interrupt is disabled
during homing cycles"). A structurally-zero Z contribution to
`limits_get_state()` means Z-axis homing cannot detect its switch and
drives the axis into the physical hard stop. This is the same *failure
class* as [BUG #17](#gpio-data) (a port's own pin choice silently defeats
a core width contract) one axis-group over, and the same *meta-lesson* as
[BUG #23](#boot-init-unreachable) one level removed: a defect that looks
checked, because *someone did check something adjacent to it*, is not
the same as a defect that has been checked.

**The general lesson (this is why it gets its own section instead of just
a [§1.3](#gpio-data) footnote)**: a width/range contract on a named
constant (here, `*_LIMIT_BIT`) does not have "a consumer" — it has as
many consumers as there are places core reads that constant, and they are
not all shaped the same way (a group-mask AND, a function return, a
direct shift-and-test are three different textual shapes for the *same*
hazard). Tracing one call site to a correct conclusion says nothing about
the others. Before a port comment asserts "this bit choice is safe
because X" for any `*_BIT`/`*_PIN` constant core also reads, grep every
core file for that identifier (not just the file the constant is
`#define`d for) and check each hit independently. A CI-enforceable
partial mitigation for this specific class landed alongside the fix:
`_Static_assert(X_LIMIT_BIT <= 7 && Y_LIMIT_BIT <= 7 && Z_LIMIT_BIT <= 7,
...)` in the three affected ports' `platform.h` (mirroring the existing
STEP/DIRECTION assert the same file already carried for [BUG #17](#gpio-data)'s
class) — this cannot regress silently again on *these* three ports, but
it is not yet rolled to every port that has a LIMIT group, and a
compile-time bit-range assert is necessarily narrower than "this constant
has no unaudited consumer" in general; it closes the one class that is
mechanically checkable, not the methodology gap above.

**Fix**: Z moved to PB2 on all three ports (a free, previously-unused
GPIOB bit ≤7 on this donor pin map, confirmed by grepping each port's own
`platform.h` for existing PB-pin users before choosing it) — not a
logical/physical remap, because no hardware had been wired to PB10 for
any of the three (`platform.md`/`README` for each: "not yet run on real
hardware"), making a pin-map correction strictly simpler and lower-risk
than reproducing [BUG #17](#gpio-data)'s gather/scatter machinery for a
single bit. `config.h`'s independent copy of `Z_LIMIT_PIN` (the
already-documented dual-pin-map-canon debt, item 2 above) was updated to
match in the same commit — leaving it stale would have reintroduced the
exact "which header wins depends on include order" hazard item 2
documents, for this constant too.

**Closing note on the gcc-vs-clang framing**: gcc's `-Woverflow` (part of
`-Wall`, already enabled on every port) had already caught this — the
exact line, on all three ports, was sitting in
`ci/warn_baseline_stm32f{103,411}.txt`/`stm32h523.txt` as an accepted
baseline entry (`settings.c: warning: unsigned conversion from 'int' to
'uint8_t' ... changes value from '1024' to '0' [-Woverflow]`) since
whichever session first built these ports and folded its warning log into
the baseline. Nobody circled back to ask whether that specific
value-changing conversion was load-bearing. The value a second,
independent compiler actually added here was not detecting a fact gcc
missed — it was `-Wconstant-conversion`'s framing (a value-identity claim
about a specific returned constant, not a generic "conversion changes a
value" note) prompting fresh scrutiny of a warning that had already been
technically visible, and dismissed, for as long as these three ports have
existed. The baseline lines for this specific warning were removed from
all three files once the fix confirmed it no longer fires (`ci/
warn_ratchet.py`'s own convention: baseline entries are removed only
after the warning is verified gone, never speculatively).

---

<a id="core-purity-under-a-second-toolchain"></a>
## 32. Core-purity rule for a second toolchain (cite the slug, not "§32", from elsewhere)

`grbl/` (outside `grbl/platform/`) is byte-for-byte frozen — written for
avr-gcc 7.3.0 in 2011, golden-MD5-gated, and never edited to satisfy any
tool. A second compiler (recon: `docs/TOOLCHAIN-AXIS.md`) will emit
diagnostics on core files a single-compiler baseline never had reason to
record; that is the entire point of running one. When that happens:

1. **NEVER edit a `grbl/` core file to silence a diagnostic, on any
   toolchain, for any reason.** Not even a redundant-qualifier or
   dead-code-branch fix. The byte-golden AVR invariant is the project's
   central thesis; a "harmless cleanup" on core is not exempt from it
   just because it was clang, not gcc, that found the spot.
2. A diagnostic on core code is handled at exactly one of two layers:
   (a) **the flags/prelude layer**, if a compiler flag or a preprocessor
   define can make the diagnostic legitimately not apply (example:
   `-D_AVR_WDT_H_` skips an unused, uncallable avr-libc header whose
   untaken branch clang validates differently than gcc — a flags-layer
   fact about the header, not a claim about core); or (b) **accepted
   into that toolchain's own warn baseline**
   (`ci/warn_baseline_<port>.<tc>.txt`) if there is no legitimate
   flag-layer suppression and the diagnostic is judged noise, with the
   judgement written down at the point of acceptance, not silently
   absorbed.
3. If a diagnostic on core code cannot be handled either way — it is a
   genuine hard error with no flags-layer bypass, and it is not
   noise — **that toolchain does not support that port.** Record it as a
   `TOOLCHAINS_SUPPORTED` exclusion, not as a TODO to eventually silence.
4. **A hard ERROR (not warning) on core code under a toolchain being
   evaluated is a headline finding, not routine baseline noise** — report
   it prominently the moment it's found. (Precedent this rule codifies:
   avr-libc's `wdt.h` "value out of range for constraint" under clang was
   found this way, handled per rule 2(a) since a flags-layer bypass
   existed; had none existed, rule 3 would have applied and AVR would
   already be gcc-only for this reason alone, independent of the
   golden-MD5 argument that also applies on that port.)

This is the same discipline [§10.4](#nvmem-eeprom) already applies to the
AVR checksum `||` quirk ("Never fix the AVR `||`") — generalized here
because a second toolchain is where the temptation to "just clean up"
core code will recur constantly, and the answer is always the same one.

---

<a id="gpio-pin-map-single-owner"></a>
## 33. Two headers both defining the pinout: which one wins is a per-translation-unit accident, not a decision (BUG #25)

Same *symptom class* as the "GPIO port clock gating" section above
(anchor `gpio-port-clock-gating`, BUG #24 - not a real link here: that
section's own heading is still `§NEW`, and a link to a `§NEW` section's
anchor reports as dangling until the integrator's renumbering pass, per
this file's own numbering-collision note at the top) and
[§boot-init-unreachable](#boot-init-unreachable) (BUG #23) -
"the pin looks wired and isn't" - but a third, distinct *mechanism*: this
time the code exists, runs, and even configures a real GPIO pin as an
output. The pin it configures is simply not the pin anything else drives,
because two headers both claim to own the same pin's number and the
compiler silently resolves the conflict by C's ordinary `#define`
redefinition rule (last one wins, per translation unit) rather than by
anyone's decision.

### The mechanism, proven on stm32f103/stm32h523, from real preprocessor output

`stm32f103/config.h` and `stm32f103/platform.h` (and the h523 sibling, a
near-identical file) each defined `SPINDLE_ENABLE_PIN`, unguarded, with
different values - `config.h`: 7 (`// PB7`); `platform.h`: 12. Both files
are legitimately included in every translation unit (this is not the
[§boundary-wiring](#boundary-wiring) 4-step per-board chain - these three
single-board STM32 ports use the 2-step chain documented there - `config.h`
is simply the port's *second* header, included directly by `platform.c`
and indirectly, through `hal.h`'s `PLATFORM_STM32F103` branch, by every
core `.c` file). Which value survives depends entirely on **the order those
two `#include`s happen to appear in the one `.c` file currently being
compiled**:

- `stm32f103/platform.c` (and h523's) includes `platform.h` first, then
  `config.h` - so `config.h`'s 7 is the value alive inside `hal_gpio_init()`,
  the function that configures the pin as an output.
- Every core `.c` file (`grbl/spindle_control.c`, `grbl/coolant_control.c`,
  ...) reaches `platform.h` LAST, through `grbl.h`'s `PLATFORM_STM32F103`
  branch - `config.h` is never even on that path a second time - so
  `platform.h`'s 12 is the value alive inside `GPIO_BSET`/`GPIO_BCLR`, the
  macros that actually toggle the pin (via `name##_BIT`, itself never
  split - only `_PIN` was duplicated, not `_BIT`).

Proven with `arm-none-eabi-gcc -E -dM` (not inferred from reading the
`#include` order and reasoning about it - actually run, both files, real
toolchain), pre-fix:

```
$ gcc ... -E -dM stm32f103/platform.c   | grep SPINDLE_ENABLE_PIN
#define SPINDLE_ENABLE_PIN 7
$ gcc ... -E -dM grbl/spindle_control.c | grep SPINDLE_ENABLE_PIN
#define SPINDLE_ENABLE_PIN 12
```

Net effect on real hardware: `hal_gpio_init()` configures **PB7** as a
push-pull output and clears it once, then nothing ever touches PB7 again
(`SPINDLE_ENABLE_BIT`, the macro `GPIO_BSET`/`GPIO_BCLR` actually use, is
12 everywhere - never split). **PB12** is the pin `spindle_set_state()`
actually sets and clears on every M3/M4/M5 command, all session long - and
PB12 was never configured as an output, so it sits in its GPIO reset state
(floating input on F1) for the life of the firmware. Whichever physical pin
the relay is wired to, it does not work: PB7 is a real push-pull output
that is written exactly once, at boot, to logic 0, and never again: PB12 is
written constantly but drives nothing because its output stage was never
enabled. This is worse than either candidate pin "just being wrong" - there
is no wiring that makes the shipped binary's spindle-enable output work.

### Not confined to the one macro named in the bug report

A split pin number is never the only split. The same config.h/platform.h
pair also duplicated `SPINDLE_DIRECTION_PIN` (7 vs 13) and
`COOLANT_FLOOD_PIN`/`COOLANT_MIST_PIN` (0/1 vs 13/14), plus six `*_MASK`
macros (`STEP_MASK`, `DIRECTION_MASK`, `STEPPERS_DISABLE_MASK`,
`LIMIT_MASK`, `CONTROL_MASK`, `PROBE_MASK`) and every individual STEP/
DIRECTION/LIMIT `*_PIN` - all unguarded duplicates of names `platform.h`
already owned. Most of those were numerically **benign** (same value in
both files, so no compiler warning and no functional defect - GCC only
warns on a redefinition when the token sequence actually differs). Two
were **live but self-healing by accident**: `spindle_init()`/`coolant_init()`
(`grbl/spindle_control.c`/`coolant_control.c`) unconditionally call
`GPIO_DIR_OUT(SPINDLE_DIRECTION)` / `GPIO_DIR_OUT(COOLANT_FLOOD)` at
startup, which resolve through `_BIT` (never split) and therefore
reconfigure the correct pin as an output every boot regardless of what
`hal_gpio_init()` did first - masking the direction/coolant split from ever
manifesting under this project's *default* build config. This healing is
NOT robust: `spindle_init()` skips that call for `SPINDLE_DIRECTION`
specifically under `ENABLE_DUAL_AXIS` (config.h default off, but a real,
supported build option), and skips it for `SPINDLE_ENABLE` under every
default build because `VARIABLE_SPINDLE` is on and
`USE_SPINDLE_DIR_AS_ENABLE_PIN` is off (grbl/config.h defaults) - which is
exactly why the enable pin, and only the enable pin, is live in the
project's default configuration. A macro class that "happens to be masked
by an unrelated unconditional call in one specific build configuration" is
not a fixed class; it is a live one with a lucky default.

`stm32f411`'s `config.h` carried the identical duplicate set but every
value agreed with `platform.h` (hand-mirrored, per that file's own former
header comment) - **latent, not live**, confirmed the same way (`-E -dM`
on both `platform.c` and `spindle_control.c` returns 12/13 in both files).
Latent is not the same as safe: a hand-mirrored duplicate is one
unreviewed edit away from splitting exactly like its siblings did, and nothing
would warn about a *matching* redefinition drifting apart later - the
warning this class produces only ever detects existing duplication, never
future divergence of a currently-agreeing pair.

`stm32h523`'s `hal_gpio_init()` additionally didn't consume either macro
for the affected pins at all - it hardcoded raw literals
(`hal_gpio_set_output(GPIOB, (1 << 7))`, with a comment claiming "PB7:
Spindle enable"), so its copy of the pin map was decorative regardless of
which header would have won. The direction pin was hardcoded onto **GPIOA**
(`hal_gpio_set_output(GPIOA, (1 << 9))`) while `platform.h`'s
`SPINDLE_DIRECTION_PORT` is GPIOB - a port mismatch, not just a bit
mismatch, one rung further down the same "the pin map is fiction" ladder
than f103's.

`hc32f460` has no `config.h` at all - `platform.h` is its only pin-map
source, structurally immune by construction, not by luck. No other port in
this tree (samd21, ch32v006, ch570, dspic33ak128mc102, sg2002, `_template`)
has a config.h/platform.h pair that both claim the same pin-shaped macro
name at all - a repo-wide sweep (every `config.h`/`boards/*/config.h`
against its port's `platform.h`, comparing every macro name defined in
both) found zero hits anywhere outside these three. samd21's `platform.h`
DOES redefine two of its board `config.h`'s names (`PROBE_PIN`,
`PROBE_MASK`) - but always preceded by an explicit `#undef`, which is a
deliberate, visible, warning-free repurposing (the chip layer needs
`PROBE_PIN` to mean "the port register" for one read-back site, not "a pin
number"), not this bug's silent-shadow mechanism. `#undef` is the
line between "an override" and "an accident": one announces itself in the
diff and in the file, the other only announces itself in a compiler
warning nobody read.

### The baseline was hiding it - read literally, not inferred

This is not a hypothetical about baselines in general: `ci/warn_baseline_stm32f103.txt`
and `ci/warn_baseline_stm32h523.txt` carried these exact nine "redefined"
warnings (six on `stm32f411`, the benign-value set) under a comment reading,
verbatim, **"Known debt (config.h vs platform.h dual pin-map canon, PLAN.md
Phase 1/2)"** - and h523's copy of that same comment said **"same pattern
already accepted for stm32f103"**, and f411's said **"same accepted pattern
already carried by stm32f103/stm32h523"**. The pattern was noticed
recurring across three ports and was propagated as an accepted baseline
entry each time rather than escalated - `ci/warn_ratchet.py` is a strictly
one-way ratchet by design (new warnings fail the build; existing baseline
entries are trusted forever, `PLAN.md`'s "Phase 0" rationale for choosing a
baseline over `-Werror`), so an accepted entry provides exactly zero
ongoing protection once it is in the file - it is not "we are watching
this", it is "we have stopped watching this, permanently, unless a human
manually deletes the line." A baseline is supposed to hold down debt that
is inert; it held down a live wiring defect for at least three ports'
worth of porting sessions.

### The fix: one owner, not one value

Making both headers agree on 12 today would have reconciled the symptom
and left the mechanism intact - the next porter (or the next `sed`) is
still free to edit one file's copy of a pin number without the other,
and nothing structural would stop them. Per
[§boundary-wiring](#boundary-wiring), these three ports are legitimately
single-board (no per-board `config.h` selection to inject, unlike samd21/
ch32v006/ch570), so there is no board-vs-chip split to *build* here - there
is just one file too many claiming the same ownership. `platform.h` is now
the **sole** owner of every GPIO pin/port/bit/mask macro on all three ports
(it was already the file every *working* accessor macro - `GPIO_BSET`,
`GPIO_DIR_OUT`, all `_BIT`-driven - actually respected): the duplicate PIN
MAPPING and BITMASKS sections were deleted from `config.h` on all three,
each replaced with a comment naming this section and stating the rule for
future porters. `stm32h523/platform.c`'s `hal_gpio_init()` was rewritten to
derive every mask it configures from `platform.h`'s own macros
(`STEP_MASK`, `SPINDLE_ENABLE_BIT`, `SPINDLE_ENABLE_PORT`, ...) instead of
hardcoding literals, the same "derive the enable set from the pin map, not
a literal" principle the `gpio-port-clock-gating` section above (BUG #24)
already established for its clock-gate mask - a hardcoded mask and a
silently-shadowed macro are the same failure with a different-looking
diff: both let the pin map drift out of sync with whatever a `.h` file
actually says, invisibly.

If a genuinely per-board pin map is ever needed on one of these three chips
(a second board variant), the correct shape is the samd21/ch32v006/ch570
one: a `boards/<name>/config.h` selected via that board's own `prelude.h`,
chained `gpio.h -> common/gpio.h -> config.h -> platform.h` per
[§boundary-wiring](#boundary-wiring) - not a second file living beside a
single-board `platform.h` and hoping the two stay in sync by hand.

### Byte-invariance again - two of three ports changed, one did not, and that is the proof

Per [§boot-init-unreachable](#boot-init-unreachable)'s own lesson, a binary
that does not change proves nothing about correctness on its own - so both
directions were checked here. f103's RELEASE `.bin` changed (29116 -> 29120
bytes, +4) because `hal_gpio_init()` now configures a genuinely different
bit pattern on GPIOB; f103's DEBUG `.bin` is the sharper illustration -
**identical size** (43740 bytes both), but a **different MD5** (the
immediate operand inside a `MOVS`-class instruction changes value, not the
instruction's byte count) - proof that size alone would have missed this
fix exactly the way it would have missed the bug. h523's RELEASE changed
25856 -> 25852 (-4) and DEBUG 42396 -> 42392 (-4). f411's RELEASE and DEBUG
`.bin`s are **byte-identical, MD5-for-MD5**, before and after - the
predicted result for the one port whose duplicate was already numerically
benign, and the negative control that makes the other two ports' changes
mean something rather than being an artifact of touching the build.

### The ratchet: no new mechanism invented - the existing one had been told to stop looking

Unlike the `gpio-port-clock-gating` section above (BUG #24), which
needed a new reachability check because none existed for that mechanism,
this bug's detector already existed and had already fired - `ci/warn_ratchet.py`
had recorded every one of these warnings correctly. The fix is not a new
guard; it is deleting nine (f103), nine (h523) and six (f411) lines from
the three baseline files, with a comment explaining why they must never
come back. Re-running the ratchet against a fresh build log after the
source fix confirms all nine/nine/six are "no longer observed" (the
script's own built-in candidate-for-removal report) - the removal is
therefore verified against a real build, not merely asserted. A synthetic
regression test (re-inserting one baseline-format line for
`SPINDLE_ENABLE_PIN redefined` and re-running the comparator) confirms the
ratchet now reports it as **new** and fails the build - proving the guard
can fail, per this project's standing rule that a guard which cannot fail
is worse than none. No additional, broader "ban all macro redefinitions"
rule was added: a repo-wide grep confirms the other six baselines (samd21,
ch32v006, ch570, dspic33ak128mc102, hc32f460, atmega328p) carry zero
"redefined" entries of any kind today, so there was nothing further to
narrow, and inventing a heuristic name-pattern scanner for a class with
zero current instances would be exactly the kind of guard that cannot
meaningfully fail that this project's standing rule warns against.

<a id="core-purity-diagnostic-response"></a>
## 34. Core-purity rule: a diagnostic on frozen core code is never resolved by editing core

Found running `avr-gcc` 15.2.0/16.1.0 and `arm-none-eabi-gcc` 14.2.1
(compiler-version axis, see `docs/TOOLCHAIN-VERSIONS.md`) against the real
build flags (root `Makefile`/`common/stm32/common.mk`) plus `-fanalyzer`,
`-Wuse-after-free`, `-Wdangling-pointer`, `-Wnull-dereference`,
`-Warray-bounds=2`, `-Wstringop-overflow`, `-Wshadow` — the exact modern
diagnostic classes 7.3.0/13.2.1 predate. Every `grbl/*.c` compiles clean of
`-fanalyzer` findings under both newer AVR compilers and under
`arm-none-eabi-gcc` 14.2.1; the only non-empty classes are
`-Wimplicit-fallthrough` (6 sites, `gcode.c`/`report.c`/`system.c`,
intentional fallthrough documented by an old-style comment GCC's default
fallthrough-comment matcher doesn't recognize), `-Wint-in-bool-context` on
the checksum `(checksum<<1)||(checksum>>7)` (`nvmem.c`/`eeprom.c`, the
documented upstream quirk at [§10.4](#nvmem-eeprom) — never "fix" this),
and one version-dependent `-Wanalyzer-out-of-bounds` [CWE-787] false
positive in `settings.c:208` (present under `avr-gcc` 15.2.0 and
`arm-none-eabi-gcc` 14.2.1, ABSENT under `avr-gcc` 16.1.0 — a loop-carried
value-range imprecision in the analyzer itself: `parameter` is manually
traced bounded to `0..N_AXIS-1` before the write via the
`AXIS_SETTINGS_START_VAL`/`AXIS_SETTINGS_INCREMENT` `while`-loop dispatch
a few lines above; the analyzer's widening across the loop back-edge loses
that bound in two of the three compiler builds tested). None of these are
core defects; all three classes are either already-accepted upstream
behavior or analyzer noise.

That an every-file, every-modern-diagnostic sweep of the frozen core turned
up zero real bugs is itself the reportable result — but the rule below does
not depend on that outcome. It would apply identically the day a real
`-fanalyzer` finding DOES land in `grbl/*.c`, and this project has no
mechanism yet stating what happens then. State it now, before the day
someone is tempted to improvise:

**The rule.** A diagnostic whose reported location is inside frozen core
(`grbl/*.c`, `grbl/*.h` — anything the golden-MD5 gate covers, [§0](#boundary-wiring))
is NEVER resolved by editing that core file. Not a style pass, not a
one-line silence-the-warning tweak, not "it's obviously safe so I'll just
add a cast." The AVR golden MD5 (`79af184e67b27defd27a39309ac53563`,
`.text` 30640) is a byte-exact pin on the ROOT MAKEFILE'S compile of these
exact files; any source edit — however narrowly "just for the warning" —
changes the token stream the golden compiler sees and is rejected by
`make validate` by construction. The other nine ports compile the
identical `grbl/*.c` bytes into their own images; a core edit made to
placate one toolchain's diagnostic silently reflows every other port's
codegen too, the opposite of the "breakage surface stays isolated" law
(PLAN.md, Core philosophy).

A finding against core has exactly two legal resolutions, and the choice
between them is which side of the boundary the diagnostic's cause sits on:

1. **Flag/prelude-layer suppression**, when the diagnostic is provably a
   false positive or an accepted, already-documented upstream quirk (the
   `-Wint-in-bool-context` checksum case above is the reference example —
   [§10.4](#nvmem-eeprom) already states the quirk is deliberate). Suppress
   at the compiler-invocation layer a profile owns (a `-Wno-*` in the
   profile's own flag set, or a targeted `#pragma GCC diagnostic
   ignored/push/pop` bracket in a NON-core file that wraps the core
   `#include`, e.g. a prelude or the profile's build glue) — never inside
   the core `.c`/`.h` file the diagnostic points at.
2. **An accepted-baseline entry**, when the diagnostic is real noise from
   an intentional but structurally awkward pattern (the
   `-Wimplicit-fallthrough` case above: the fallthrough IS intentional,
   rewriting it as an attribute or a differently-worded comment is a core
   edit like any other). Record it in the toolchain profile's own baseline
   file (`ci/warn_baseline_<port>.txt`-class mechanism, or the
   analyzer-equivalent this file's [§static-assert-sweep](#static-assert-sweep)
   sibling docs discuss) with the file:line, the diagnostic name, and the
   one-line justification — exactly the catalogue format
   `docs/TOOLCHAIN-VERSIONS.md` uses. A baseline entry is a permanent,
   reviewable admission, not a silent suppression; it must name why the
   line is safe, not just that it is accepted.

**What is explicitly NOT a legal third option:** disabling the warning
class project-wide to make one file quiet (collateral-damages every other
`grbl/*.c` and every other port compiled with that profile); adding a
core-side `(void)` cast, a defensive bounds recheck, a rewritten loop
shape, or any other source change whose only purpose is to change what the
diagnostic sees — even when the change is a no-op for behavior. A change
that is a no-op for behavior is still a real edit to a byte-gated file, and
"the diff is harmless" is not a proof the golden hash agrees; only
`make validate` is.

**Why the distinction is a rule and not a case-by-case judgment call**:
this project's own history contains a case where "just fix it, it's core
and obviously fine" was tried before slowing down to check ([§19](#guard-hardening),
[§29](#prelude-phase-dead-guard) — both times a diagnostic that looked
straightforwardly right to silence at the flagged site turned out to be
solvable, correctly, one layer up). A rule that must be reconsidered per
finding is a rule with a two-strike class already waiting (PLAN.md working
rule 3); stating it in advance, once, removes the temptation to
reconsider it under the pressure of a red CI run.

<a id="logical-contract-vs-constraint-cure"></a>
## 35. Two cures for one disease: when to promote the logical port-image contract vs. keep the `<=7` constraint (cite the slug, not a number, from elsewhere)

[§limit-bit-width-second-consumer](#limit-bit-width-second-consumer) closed
BUG #26 on stm32f103/f411/h523 by moving `Z_LIMIT_BIT` back under 8 and
adding a `_Static_assert`. That fix is correct for those three ports today,
but it does not generalize: a board whose LIMIT/CONTROL/PROBE pins are
dictated by an existing header layout (samd21 megarm mirrors the Arduino
Mega pinout on purpose) cannot always free up a low bit by moving a pin.
[§gpio-data](#gpio-data) already names the two cures by name — "the contract
cure" (samd21's `L2P`/`P2L` logical<->physical dispatch, BUG #17) and "the
constraint cure" (a compile-time assert) — this section is the audit that
decided, per group and per port, which one applies, and the extraction that
makes the contract cure available to any port without reinventing it.

**Survey: every truncation-risk group, every port.** Core narrows exactly
five groups to a `uint8_t` (STEP/DIRECTION via the ISR port image;
LIMIT/CONTROL/PROBE via `GPIO_MRD(name, IREG)` into a local, per
limits.c:77, system.c:43, probe.c:54 — plus `settings.c`'s
`get_limit_pin_mask()` as [§limit-bit-width-second-consumer](#limit-bit-width-second-consumer)
already documents for LIMIT specifically). SPINDLE/COOLANT/STEPPERS_DISABLE
are NOT in this risk class: every core use site is a single-bit `GPIO_BSET/
BCLR/BGETOUT` operating on the native register width, never narrowed
(spindle_control.c, coolant_control.c — checked, not assumed). atmega328p is
the *reason* the contract exists, not a port that needs auditing: AVR's
`PORTx`/`PINx` registers are genuinely 8 bits wide, so physical == logical
by hardware construction and `grbl/cpu_map.h` (core, frozen) never has a bit
above 7 to begin with — that hardware fact is *why* core's port image is
`uint8_t` in the first place.

| Port / board | STEP | DIRECTION | LIMIT | CONTROL | PROBE | Live bug found this audit? |
|---|---|---|---|---|---|---|
| atmega328p | 0-2 (HW) | 0-2 (HW) | 0-2 (HW) | 0-2 (HW) | n/a | no — 8-bit HW port, origin case |
| samd21 megarm | 0-2 (L2P, phys 25/27/28) | 0-2 (phys=log) | 4,5,7 | **14,15,16 (fixed this batch)** | **19 (fixed this batch)** | yes — CONTROL was a documented gap; PROBE was not |
| samd21 generic | 0-2 (L2P, phys 16-18) | 0-2 (L2P, phys 19-21) | 4-6 | **7,8,9 (fixed this batch)** | **10 (fixed this batch)** | yes — neither was previously documented |
| stm32f103/f411/h523 | 0-2 | 3-5 | 0-2 (BUG #26 fix) | 3-6 | **15 (fixed this batch)** | yes — same class as BUG #26, one group over, never `-Woverflow`-visible (see below) |
| hc32f460 | 0-2 | 3-5 | 0-2 | 3-6 | 7 | no live bug — but zero asserts existed (fixed this batch) |
| ch32v006 | 0-2 (L2P) | 0-2 (L2P) | 0-2 | 3-5 | 0 | no — asserts added this batch for completeness |
| ch570 generic | 0-2 (L2P, phys 8-10) | 0-2 (L2P, phys 11-13) | 0,1,5 | **15,16,17 (fixed this batch)** | 6 | yes — CONTROL undocumented; interrupt-arm path also needed a real fix, not just the read (see below) |
| dspic33ak128mc102 | 0-2 | 0-2 | 0-2 | 0-2 | 3 | no — asserts added this batch for completeness |
| `_template` | 0-2 | 3-5 | 0-2 | 3-5 | 6 | no — asserts added this batch (LIMIT/CONTROL/PROBE assert lines were missing even though the header comment already said "MUST stay within bits 0-7") |
| sg2002 | — | — | — | — | — | not implemented (design-only, PLAN.md Phase 6 deferral) — nothing to audit |

**A second class this audit found, distinct from width**: gcc's `-Woverflow`
(the mechanism that caught BUG #26) only fires on a *compile-time constant*
narrowing conversion. `settings.c`'s `return((1<<Z_LIMIT_BIT))` is one; the
stm32 PROBE truncation (`GPIO_IREG(PROBE) & PROBE_MASK`, a **runtime** AND
between a register read and a mask, narrowed only at the enclosing
`uint8_t` return) is not — the compiler has no constant to reason about.
This defect was not sitting in a warning baseline as accepted debt (checked:
`grep -i "overflow\|conversion" ci/warn_baseline_*.txt` has no probe.c/
system.c hits anywhere); it was invisible to the entire warning-ratchet
mechanism, silently, on all three STM32 ports, until this audit's manual
call-site enumeration (the exact discipline
[§limit-bit-width-second-consumer](#limit-bit-width-second-consumer)
prescribes: grep every core file for the constant, not just the one call
site already traced). No other baseline entry was found masking a width or
truncation defect in this pass — the `stepper.c` `-Woverflow` lines in
hc32f460/stm32f103/f411/h523's baselines are a pre-existing, unrelated
integer-arithmetic class (AMASS prescaler math), not a pin-width symptom.

**Design decision.** Promote the *dispatch mechanism* — not the translation
formulas, which are inherently per-board — to
`grbl/platform/common/gpio_logical.h`: six `GPIO_LOGICAL_DISPATCH_*` macros
that fan `GPIO_MWO/MRD/MDIR_OUT/MDIR_INP/MPULLUP_EN/MPULLUP_DIS` out per
NAME, plus four `GPIO_LOGICAL_PASSTHRU_*` bodies for the common case where a
NAME needs no translation. A board opts a specific group into translation by
defining that group's `_L2P`/`_P2L`/`_MASK_PHYS` and a `GPIO_..._<NAME>()`
override; every other group keeps costing nothing. Applied to:
- **samd21 (both boards)**: extended the *already-landed* BUG #17 dispatch
  (previously STEP/DIRECTION only) to CONTROL and PROBE, closing the
  documented megarm CONTROL gap and the *undocumented* generic-board
  CONTROL/PROBE truncation found this session. `GPIO_INT_ON`'s `CONTROL_MASK`
  argument is currently inert on this port (`GPIO_INT_ON`/`OFF` are empty
  no-ops, [§gpio-interrupts](#gpio-interrupts) item 1) — a comment flags that
  whoever closes that gap must reach for `CONTROL_L2P(CONTROL_MASK)`, not
  the bare logical value, at that call site.
- **ch570**: same promotion, but `GPIO_INT_ON` is NOT inert here — it is a
  real, hardware-backed interrupt arm (`hal_gpio_interrupt_enable()`, a
  physical-register write). Redefining `CONTROL_MASK` as logical without
  more would have silently armed the wrong physical pins (0/1/2 — which are
  LIMIT/SERIAL_RX on this chip) the moment the fix landed, a live regression
  worse than the bug it fixed. Resolved by repurposing this port's
  previously-unused `name_PCMSK` argument slot (documented as "unused
  placeholder" before this batch) to carry the real physical arm mask
  (`CONTROL_PCMSK` = `CONTROL_MASK_PHYS`; `LIMIT_PCMSK` = `LIMIT_MASK`,
  unchanged in effect since LIMIT is still physical==logical there), and
  `HAL_GPIO_INTERRUPT_ENABLE/DISABLE` now read that slot instead of the
  logical `mask` argument. `handlers.c`'s own dispatch test
  (`pending & CONTROL_MASK`, testing a raw physical interrupt-flag register)
  needed the same correction to `CONTROL_MASK_PHYS` — found by tracing every
  consumer of the constant per the [§limit-bit-width-second-consumer](#limit-bit-width-second-consumer)
  discipline, not by inspection alone.
- **stm32f103/f411/h523**: kept the constraint cure. PROBE moved from PC15
  to PC0 (free bit, confirmed by grepping GPIOC users first — same method
  BUG #26 used for `Z_LIMIT_PIN`), plus the matching `_Static_assert`. No
  hardware was ever wired to PC15 for any of these three ports
  (platform.md/README: "never run on real hardware"), so a pin move is
  strictly simpler and lower-risk than reproducing the logical-dispatch
  machinery for a single input bit — **this is the honest case for keeping
  the constraint cure**: the donor pin map already fits under 8 once PROBE
  moves, a uniform "always use the logical contract" policy would add
  translation machinery this port does not need, and CONTRACTS itself
  states a worse-but-uniform design is not the goal. The dead second copy
  of `PROBE_PIN` in each port's `config.h` (the pre-existing dual-pin-map
  debt already on record — see the "config.h vs platform.h" note near
  [§boundary-wiring](#boundary-wiring)) was updated to match in the same
  commit; leaving it stale would have tripped a real
  `"PROBE_PIN" redefined` warning once the two copies disagreed (caught by
  a full rebuild against `ci/warn_baseline_stm32f103.txt`, not asserted).
- **hc32f460, ch32v006, dspic33ak128mc102, `_template`**: all pin maps
  already fit under 8 for every group; added the missing LIMIT/CONTROL/
  PROBE `_Static_assert`s (STEP/DIRECTION already had them from the
  [§static-assert-sweep](#static-assert-sweep) batch) so the guarantee is
  uniform. Zero-cost, confirmed by byte-identical RELEASE `.bin` against the
  committed `artifacts/` blob on every one of these ports.

**Why not promote every port to the logical contract uniformly?** Measured
cost of the alternative: on samd21 generic, where physical pins are
contiguous, the translation collapses to a pure shift (confirmed by
disassembly — `system_control_get_state()`'s `GPIO_MRD_CONTROL` compiles to
one `lsrs r3, r3, #7` plus a mask, not a branch or a multi-instruction
gather). The mechanism is cheap *when a port needs it*. But four ports in
this tree have every group already under 8 bits with no scattering at all;
forcing them through `L2P`/`P2L` indirection would add a header include, an
opt-in per group, and a translation formula that is always the identity —
pure cost for zero benefit, and exactly the "uniform design that is worse"
CONTRACTS warns against. The right unit of decision is the **group**, not
the port: a port can (and samd21/ch570 now do) mix constraint-satisfied
groups with logically-translated ones in the same board.

**Guarantee after this batch, per port**: every LIMIT/CONTROL/PROBE/STEP/
DIRECTION group on every implemented port (atmega328p excepted — hardware
guarantees it) now has either (a) a `_Static_assert(<= 7)` tied to the exact
constant core reads, or (b) a logical/physical dispatch through
`common/gpio_logical.h` that makes the physical pin number irrelevant to
core's width. A future re-pin that violates (a) fails the build; a future
re-pin under (b) cannot violate the contract because core never sees the
physical bit number at all. sg2002 has no code yet, so nothing to guarantee
there — the same audit applies the day it lands.

<a id="clock-constant-width"></a>
## 36. A clock constant must be wide enough for its worst real value, not its current one (BUG #18 class)

**Correction first**: PLAN.md's BUG #18 entry ("F_CPU: `-DF_CPU=$(CLOCK)UL`,
stepper.c:1015 computes unsigned, warning gone") was itself incomplete, and
no section of this file documented the underlying contract - there was no
"§18" here to cross-reference. This section is that missing contract, not
an edit to an existing one.

**The arithmetic**: core's `grbl/nuts_bolts.h:47` defines
`TICKS_PER_MICROSECOND (F_CPU/1000000)`; `grbl/stepper.c:1015` computes
`TICKS_PER_MICROSECOND*1000000*60` - every operand a compile-time constant,
so GCC folds the whole thing at compile time, before it ever reaches the
runtime `*inv_rate` float multiply. The fold happens in F_CPU's own type.
An `int` (no suffix) overflows this above ~35.8 MHz; `unsigned long`
(`UL`) only pushes that ceiling to ~71.58 MHz, because `unsigned long` is
**32-bit on every ILP32 target this tree ships for** (ARM/AVR/RISC-V32
`-mabi=ilp32*`) - `TICKS_PER_MICROSECOND*60,000,000` exceeds `UINT32_MAX`
the moment `TICKS_PER_MICROSECOND` (= clock in MHz) passes 71. Only
`unsigned long long` (`ULL`) is guaranteed >=64 bits by the C standard
regardless of target ABI, and only it survives every clock this tree
actually uses (72-250 MHz on the affected ARM ports, 700 MHz on sg2002).

**The trap that made this a two-strike class**: unsigned overflow is
**silent** - it is well-defined wraparound, not undefined behavior, so
`-Woverflow` does not fire on it the way it fires on signed overflow.
Confirmed empirically (arm-none-eabi-gcc 13.2.1, xc-dsc-gcc 8.3.1,
riscv64-unknown-elf-gcc 13.2.0, real `-S`/`-c` codegen, not
`-fsyntax-only`): `F_CPU=200000000UL` on an ILP32 target compiles clean,
zero warnings, and silently bakes in `3410065408` where the true value is
`12000000000` - a ~3.52x error with nothing in the build log to find it.
This is exactly what happened to `dspic33ak128mc102` (200 MHz): its own
Makefile carried `-DF_CPU=$(CLOCK)UL`, checked in under a "BUG #18 FIXED"
banner, and was never actually fixed - the warning's disappearance was
mistaken for the bug's disappearance. `hc32f460` (200 MHz, no suffix at
all) and `stm32f103/f411/h523` (72/96/250 MHz, no suffix,
`common/stm32/common.mk`) carried the same defect with the warning still
visible (signed overflow), which is why they were caught and dsPIC wasn't.

**The rule**: any clock constant that feeds `TICKS_PER_MICROSECOND` or an
equivalent core-consumed timing macro must carry `ULL`, not `UL` -
regardless of whether the port's CURRENT `CLOCK` value happens to fit
under 32 bits today. A port's clock is a Makefile variable a future board
revision changes; a suffix that is "safe" only because of today's value is
a latent recurrence of this exact bug, one clock bump away.

**CORRECTION / CLOSURE (2026-07-26, same day as the paragraph above):** the
original text here said `samd21` (48 MHz), `ch32v006` (48 MHz), `ch570`
(60 MHz) would keep `UL` deliberately because their real clocks sit under
the 32-bit threshold. That reasoning was accurate for TODAY's value and
exactly the class of latent-regression risk this section itself warns
about one paragraph up - a documented exception is still an exception a
future porter can trip over (samd21's DFLL is a real 48 MHz today, but a
different SAMD2x/SAMx variant or an external-crystal board revision is an
ordinary edit). All three were widened to `ULL` in the same batch that
added the enforcement mechanism below, closing the exception rather than
just re-documenting it. Measured, not assumed - RELEASE/DEBUG, every
affected board, before (`UL`) vs after (`ULL`):

| Port            | Flavor  | Before | After | Delta |
|-----------------|---------|-------:|------:|------:|
| samd21 megarm   | RELEASE |  32176 | 32280 |  +104 |
| samd21 megarm   | DEBUG   |  48128 | 48232 |  +104 |
| samd21 generic  | RELEASE |  32132 | 32236 |  +104 |
| samd21 generic  | DEBUG   |  48040 | 48148 |  +108 |
| ch32v006        | RELEASE |  39044 | 39224 |  +180 |
| ch32v006        | DEBUG   |  47120 | 47156 |   +36 |
| ch570           | RELEASE |  38586 | 38594 |   +8  |
| ch570           | DEBUG   |  46866 | 46906 |  +40  |

None is byte-identical, on either flavor. `data`/`bss` are unchanged in
every row - only `text` moves. Root cause, found by inspection, not
guessed: `TICKS_PER_MICROSECOND` (`F_CPU/1000000`) is itself a
compile-time constant, but its **type** is now `unsigned long long`, and
it is used at RUNTIME (not just in the fully-folded stepper.c:1015
expression) at stepper.c:240/242/245: `settings.pulse_microseconds *
TICKS_PER_MICROSECOND` - `settings.pulse_microseconds` is a plain
variable, so this multiply cannot be constant-folded away, and the
64-bit-typed constant now forces the WHOLE expression (and the
following `>> 3`) to execute as 64-bit arithmetic on a 32-bit target at
those three call sites, three times, at stepper init. That is exactly the
"real (if small) code-size cost at the three runtime-variable pulse-time
call sites" the original paragraph predicted before it was known to be
true - the prediction is now a measurement.

**The enforcement mechanism** (new this batch, closing the actual gap:
a value-based `_Static_assert(F_CPU > 0, ...)` cannot detect a width
regression, only a sign/zero one): `grbl/platform/common/clock_width.h`,
a new shared header, `_Static_assert(sizeof(F_CPU) >= 8, ...)`. `UL` on
every ILP32 target this tree ships for is `unsigned long`, `sizeof == 4`;
`ULL` is `unsigned long long`, `sizeof == 8`, guaranteed by the C standard
independent of ABI - so the assert is a pure WIDTH check, blind to the
numeric value, and fires identically whether the reverted clock is
16 MHz or 250 MHz. Included from every non-AVR port's `prelude.h` (the
one `-include`d header injected into every translation unit of that
port, see ARCHITECTURE.md's "Build Prelude" section) - 11 files (every
board directory under `stm32f103, stm32f411, stm32h523, hc32f460,
sg2002, samd21/megarm, samd21/generic, ch32v006/boards/generic,
ch570/boards/generic, dspic33ak128mc102/boards/generic, _template/boards/
generic`), one `#include` line added to each.

**Phase-ordering, checked, not assumed**: F_CPU is not routed through any
header at all - it arrives as a `-DF_CPU=...` command-line macro, defined
for a translation unit before the first character of any `#include` is
even opened. So the "prelude preprocessed long before core's own,
correctly-timed config.h pass, and include guards mean that later pass
never re-enters" trap this section itself documents (the reason a value
threaded through a header chain can silently miss its intended check
point) does not apply here: there is no header-chain timing for this
assert to miss, because its one input isn't threaded through a header at
all. Verified empirically: `arm-none-eabi-gcc -E` on stm32f103's `main.c`
with the new include in place shows the assert's expansion sitting
immediately under `-include prelude.h`'s output, thousands of lines
before `grbl/config.h`'s own text appears in the same translation unit -
and the assert still evaluates correctly there, because F_CPU was already
fully defined before either header opened.

**Seen to actually fail, not just inspected** (the project's own stated
bar, after `assert_no_double.sh`'s libgcc-symbol miss and `-fanalyzer`'s
silent `-fsyntax-only` no-op): with the guard and the `ULL` widening both
landed, `ch32v006/Makefile`'s `-DF_CPU=$(CLOCK)ULL` was temporarily
reverted to `...UL` and rebuilt. The very first translation unit failed:

```
riscv64-unknown-elf-gcc [...] -c ../../main.c -o .../main.o
In file included from ./boards/generic/prelude.h:13,
                 from <command-line>:
./boards/generic/../../../common/clock_width.h:102:1: error: static
assertion failed: "F_CPU must be suffixed ULL (>=64-bit unsigned long
long), not UL or a plain literal - see CONTRACTS.md #36
(clock-constant-width): unsigned long is 32-bit on every ILP32 target
this tree ships for and silently wraps grbl/stepper.c:1015's compile-time
constant fold above ~71.58 MHz, with zero compiler warning (unsigned
overflow is well-defined wraparound, not diagnosed by -Woverflow)."
  102 | _Static_assert(sizeof(F_CPU) >= 8,
      | ^~~~~~~~~~~~~~
make: *** [Makefile:278: .../main.o] Error 1
```

`make` exited 2. The Makefile was restored (`diff` against the pre-revert
copy: empty) and rebuilt clean. Before this negative control, the guard
had *also* already been observed firing for real (not synthetically) on
`ch32v006` in its own still-`UL` state, immediately after the header was
added and before the Makefile was widened - the identical error, same
file:line, at the point in the batch where the gap between "guard exists"
and "every port satisfies it" was still open.

**`HAL_CPU_FREQ`/`CPU_FREQ`-style port-owned capability constants**
(separate macros, not derived from this Makefile define) are a different
contract and must be audited independently - most already carry a
correctly-sized literal (hc32f460's own `HAL_CPU_FREQ` is real,
200000000UL, and *is* consumed directly in a runtime multiply/SysTick-
reload, which is exactly why 32-bit is fine there: 200000000/1000 fits
any width), except stm32h523/platform.h's `HAL_CPU_FREQ` (72000000UL,
stale copy-paste from its stm32f103 sibling, "72 MHz" comment and all -
dead code, confirmed unused anywhere in that port's own sources, so
numerically inert, not fixed here because it is outside this section's
scope and touching it risks the concurrent pin-width batch's territory in
the same file). `clock_width.h` intentionally does NOT assert on these -
its one input is the `F_CPU` token, by design; a future batch auditing
`HAL_CPU_FREQ` sites is free to add its own, differently-scoped guard.

**atmega328p is excluded from `clock_width.h`, deliberately**: it has no
`prelude.h` at all (its own, much smaller injection is the repo-root
Makefile's single `-include grbl/platform/common/gpio.h`), and that
Makefile is golden-MD5-gated (`make -C grbl/platform/atmega328p validate`,
MD5 `79af184e67b27defd27a39309ac53563` - unchanged by this batch, verified
by re-running it). Its `F_CPU` (`16000000`, no suffix at all - the root
Makefile's `-DF_CPU=$(CLOCK)` predates every suffix convention this
section discusses) is a plain decimal literal; the C standard promotes an
unsuffixed decimal constant too large for `int` to the next type in the
list, `long` - 32-bit `long` on AVR (where `int` is only 16 bits, so
16000000 never fits it). `TICKS_PER_MICROSECOND * 60,000,000` = 16 *
60,000,000 = 960,000,000, comfortably under signed `INT32_MAX`
(~2.147e9) with more than a factor of two to spare, and AVR's realistic
clock ceiling (~20 MHz crystal, the practical limit of the part's own
datasheet) never approaches the ~35.8 MHz signed-overflow threshold this
same class has for a non-suffixed constant. Requiring `ULL` there would
mean editing the golden-gated root Makefile to close a class of bug that
cannot occur on this port at any real clock - assessed as not worth the
risk to the byte-exact gate, so it is excluded by construction (no
`prelude.h` to carry the include) rather than by an explicit `#ifdef
__AVR__` skip that would need maintaining. This mirrors the existing
precedent at `grbl/platform/atmega328p/Makefile` (the BOOT-INIT
REACHABILITY RATCHET, BUG #23/CONTRACTS.md #boot-init-unreachable):
ratchets for this port attach at the shim layer, never at the golden
Makefile itself.

<a id="baseline-entry-discipline"></a>
## 37. A warning-baseline entry requires a recorded judgement, not a resemblance

This file has no written rule for what may enter a `ci/warn_baseline_*.txt`
file. BUG #18's own history shows the gap is not theoretical: the F_CPU/UL
fix was judged correct at samd21, and the SAME suffix was then applied to
ch32v006/ch570/dspic33ak128mc102 because it had already worked once, not
because each site's own arithmetic was re-derived at its own clock. It
happened to hold for ch32v006/ch570 (48/60 MHz, under the 32-bit
threshold) and silently failed for dspic33ak128mc102 (200 MHz, over it) -
see [§clock-constant-width](#clock-constant-width). A baseline entry is
the same class of decision wearing a different hat: "this diagnostic is
safe" is a claim about the code at hand, and a claim about a different
site is not evidence for it.

The concrete, already-landed precedent this rule generalizes from:
`config.h`'s "dual pin-map canon" comment, verbatim, on two ports before
BUG #25's fix - h523's copy said **"same pattern already accepted for
stm32f103"**, f411's said **"same accepted pattern already carried by
stm32f103/stm32h523"** ([§33](#gpio-pin-map-single-owner)). Both were
citing precedent instead of checking the site: `SPINDLE_ENABLE_PIN`/
`SPINDLE_DIRECTION_PIN`/`COOLANT_FLOOD_PIN` actually disagreed in value
between `config.h` and `platform.h` on the ports carrying that comment,
and the disagreement drove a real miswired relay - "already accepted
elsewhere" was the reasoning that let it sit unexamined on a second and
third port after the first.

**The rule**:

1. Every `ci/warn_baseline_<port>.txt` entry's surrounding comment must
   state, for that entry specifically, WHY the diagnostic is a false
   positive or accepted debt - argued from the flagged code itself (its
   actual values, types, or call sites), not from the entry's shape
   matching one already in this file or another port's baseline.
2. **"Same pattern/class already accepted elsewhere" is not, by itself, a
   judgement.** It may be cited as supporting context after the site has
   been independently checked, never as the check itself. If the
   justification text could be copy-pasted to a different file:line
   without editing anything but the filename, it has not yet stated a
   judgement.
3. A baseline entry for a numeric diagnostic (`-Woverflow`,
   `-Wconversion`, `-Wtype-limits` and siblings) must record the actual
   value in question (the wrapped/truncated result GCC reports, or the
   values being compared) and why that specific number is harmless -
   "the compiler flagged a conversion but it looked fine" is not a
   judgement without the number. `docs/TOOLCHAIN-VERSIONS.md`'s §2
   catalogue and this file's [§34](#core-purity-diagnostic-response) both
   already model the expected shape; hold every baseline file to it.
4. When one fix is applied to more than one file or port under a shared
   assumption (a suffix, a flag, a static assert), each site's own
   numbers must be independently re-derived before the fix is trusted
   there - inheriting a fix's correctness from the one site that was
   actually checked is the same failure as inheriting a baseline entry's
   safety from the one site that was actually read.
5. An entry that cannot be justified under points 1-3 is not deleted on
   sight either - flag it for a real look (as this section's own audit
   did across every `ci/warn_baseline_*.txt` in the tree) rather than
   mass-removing or mass-keeping. Silence in either direction is the same
   mistake this rule exists to stop.
<a id="sg2002-companion-core-gaps"></a>
## §NEW. Gaps found porting SG2002 (first companion-core port: no flash, no clock to configure, a second cache domain, and an OS on the other side)

*(Section number deliberately left as the literal `§NEW` placeholder per this
file's top-of-file authoring rule - the integrator assigns the real number at
merge time. Cite this section by its slug, `sg2002-companion-core-gaps`, not
by a number.)*

SG2002 is structurally unlike every port before it. Its target is not "the
CPU on the board" - it is a *companion* core inside a Linux SoC: no flash of
its own, no clock tree it is allowed to touch, a peer core with a separate
cache, and a loader (`remoteproc`) that is a kernel driver rather than a
programmer. Several checklist steps therefore do not mean what they say on
this shape of target, and two long-standing habits in this tree turn out to be
silently broken. Everything below is empirical - from a disassembly, a failing
build, or a code read with the line cited - not theory.

### 1. A linker symbol declared `uint8_t []` silently TORE every cross-core 32-bit index store

The shared window's address comes from the linker, reached the obvious way:

```c
extern uint8_t __shm_start[];
#define SG2002_SHM ((volatile sg2002_shm_t *)(void *)__shm_start)
```

`sg2002_shm_t`'s ring indices are `volatile uint32_t`. Disassembling
`serial_init()` showed GCC emitting **four `sb` byte stores** for each of
them, not one `sw`. GCC propagates the *declared* alignment of the extern
symbol (1, for a `uint8_t` array) through the cast, decides the whole
structure may be unaligned, and splits every wide access.

On a single-core port that is a performance wart. Here it is **a torn index
the other core can observe halfway written** - precisely the silent cross-core
corruption the coherency work exists to prevent, produced by a *declaration
detail*, with no warning, no failing test, and no diagnostic. Declaring the
alignment fixed it (single `sw`, and 712 bytes of text disappeared as a side
effect):

```c
extern uint8_t __shm_start[] __attribute__((aligned(SG2002_CACHE_LINE)));
```

Two general lessons, both of which generalise past this chip:

- **`volatile` guarantees the access HAPPENS; it does not guarantee the access
  is SINGLE.** [§12](#weak-memory-obligations) item 2 already says
  "volatile != atomic" about read-modify-write. This is a second, narrower way
  the same word misleads: even a plain aligned store of a `volatile uint32_t`
  can become four stores if the compiler believes the address is unaligned.
  Any index another agent reads concurrently needs its width-atomicity
  *established*, not assumed.
- **The declared type of a linker-provided symbol is part of the ABI**, not a
  formality. `extern uint8_t x[]` is the idiomatic spelling and it is the
  wrong one whenever the symbol is about to be cast to something with
  alignment requirements.

Found by reading the disassembly of a function that had already been reviewed
and looked correct. Nothing else in this project's gate set would have caught
it.

### 2. Cache maintenance acts on LINES: single-writer-per-line is a layout obligation, not padding

Extends [§23](#cross-core-cache-coherency). Once a port hand-maintains
coherency, the *layout* of the shared structure becomes load-bearing in a way
it never is for a same-core producer/ISR ring:

> If the producer index and the consumer index share one cache line, writing
> back the index you own also writes back your stale copy of the index the
> other core owns - **silently reverting the other core's progress**.

So every independently-written word in a cross-core structure must start its
own cache line, and that property must be pinned (`_Static_assert` on
`offsetof(...) % LINE == 0`) so a later field insertion cannot quietly undo
it. The symmetric rule constrains the *invalidate* side: a consumer may only
invalidate memory it never writes, or it discards its own stores. Both are
satisfied here by construction - one writer per line, and `observe()` is only
ever pointed at the peer's index or at ring data this core does not produce -
and both are stated at each call site, because neither is visible in the code
that calls them.

### 3. The "preferred simplification" of [§23](#cross-core-cache-coherency) has a precondition a no-MMU core cannot meet

[§23](#cross-core-cache-coherency) recommends mapping the shared window
non-cacheable "where the SoC's PMA/MMU configuration allows it", and that
recommendation is sound - but the qualifier is doing more work than it looks
like. The documented T-Head mechanism for marking memory non-cacheable is the
extended attribute bits in a **PTE**, and this target is a **no-MMU core in
machine mode**: there are no PTEs. What remains is the SoC's PMA, fixed in
fabric and undocumented for a chip with no TRM.

The port therefore defaults to explicit cache maintenance and offers the
non-cacheable window as a *declared* alternative
(`SHM_COHERENCY=CMO|NONCACHEABLE`, shaped exactly like
[§17](#fp-precision)'s FP knob: two real implementations, neither a no-op -
`NONCACHEABLE` still emits the ordering fences - and an unrecognised value is
a hard error). Measured cost of the safe default: 472 bytes of text.

**Lesson for the doc, not just for this port:** when a contract offers a
"preferred simplification", the reader has to check its precondition against
the actual core, and a port that cannot meet it should say so in one sentence
rather than silently taking the harder route (or, worse, taking the easy route
on a machine where it does not hold). "Which of these two did you pick, and
why" belongs in the port's own docs as a declared property.

### 4. A `#ifdef` on a CORE build option, written in a prelude-injected header, CAN NEVER FIRE

**This one indicts two already-landed ports.** `ch32v006/timer.h:76` and
`ch570/timer.h:71` both carry:

```c
#ifdef STEP_PULSE_DELAY
  #error "STEP_PULSE_DELAY is not supported on <chip> ..."
#endif
```

presented (in this file, [§14](#ch32v006-riscv-gaps) item 11, and in
[§4](#pulse-reset-timer)'s conditional rule) as the loud failure that makes
the missing feature legal. It is dead code. `STEP_PULSE_DELAY` lives in core
`grbl/config.h`, which is included from exactly one place - `grbl.h:42` - and
`grbl.h` is included by core `.c` files. `timer.h` is pulled in by
`platform.h`, which the Makefile `-include`s via the board prelude at the very
top of **every** translation unit, long before any core header. At the moment
that `#ifdef` is evaluated, `STEP_PULSE_DELAY` cannot possibly be defined by
the documented enable path (uncommenting it in `config.h`).

Verified both ways: passing `-DSTEP_PULSE_DELAY` on the command line *does*
trip ch570's `#error` (so the guard is not syntactically broken), but the
in-`config.h` route - the only route the option documents - reaches it never.
A user who enables `STEP_PULSE_DELAY` the intended way gets a build that
succeeds and a machine whose delayed-step path is quietly wrong.

This is [§19](#guard-hardening) Lesson 1's shape exactly ("a guard that checks
the wrong thing does not fail to protect - it certifies"), in a new location:
not the wrong symbol *family*, the wrong *translation phase*.

**Rule:** a platform file that needs to branch on a CORE build option must
include `grbl.h` itself. `serial.c` already does on every port (it needs the
`CMD_*` bytes), which is why the same class of guard works there. This port
puts its `STEP_PULSE_DELAY` guard in `handlers.c` and adds
`#include "../../grbl.h"` for exactly this reason; the guard was then verified
to fire. Conversely, macro *definitions* in a prelude-injected header must be
unconditional - `timer.h` here defines `PWM_*` and the delayed-step macros
with no `#ifdef` at all, since a core-option guard there could only ever
mislead. Suggested follow-up for the integrator, out of scope for this branch
(it must not touch other ports): move ch32v006's and ch570's
`STEP_PULSE_DELAY` guards into a TU that sees `grbl.h`.

### 5. `make clean` cleans ONE flavor, and a stale-object relink then silently reports the wrong build

Every Makefile in this tree derives `BUILD_DIR = .../$(BUILD)` with
`BUILD ?= DEBUG`. So a bare `make clean` removes only the DEBUG object
directory. The RELEASE objects survive - and a following
`make BUILD=RELEASE SOMEKNOB=other` sees them as up to date, relinks them, and
prints a plausible size for a binary built with the **previous** knob setting.

Hit live while measuring this port's `SHM_COHERENCY` knob:
`make clean && make BUILD=RELEASE SHM_COHERENCY=NONCACHEABLE` produced a
binary byte-identical to the CMO build, and the natural reading of that result
("the knob does nothing") was wrong - the knob works, the objects were stale.
Two flavors of damage: a real setting can look broken, and (worse) a broken
setting can look correct. It is the same *class* as
[§19](#guard-hardening) Lesson 2 (`.DELETE_ON_ERROR:` - make's default
behaviour serving a stale artifact as a fresh result), one level up: there the
guard's verdict was stale, here the whole object set is.

`make clean BUILD=RELEASE` is the correct incantation today. Note that the
per-flavor `BUILD_DIR` split is itself a *fix* (PLAN.md's DEBUG/RELEASE
object-collision entry) - this is a rough edge of that fix, not a reason to
undo it. A `clean` that removed every flavor, or a knob fingerprint that
forced a rebuild when the flags change, would close it; both are cross-port
changes and deliberately not made on this branch.

### 6. `build_artifacts.py build --platforms X` REWRITES the manifest with only X

Code read, `tools/build_artifacts.py` `do_build()`: `release_entries` and
`debug_entries` start empty, are appended to only for the *selected* units,
and are then written over `artifacts/MANIFEST.sha256` wholesale. The existing
manifest is never read. A scoped refresh - the exact thing
`PORTING-CHECKLIST.md`'s Definition-of-Done item 8 recommends when "a full
10-unit rebuild is overkill" - therefore **deletes every other port's recorded
hashes**, after which `check` reports them as missing from the manifest.

Not exercised here (this branch registers `sg2002` in the `UNITS` table but
deliberately commits no artifacts and does not touch the manifest - a full
regeneration on an isolated branch would conflict with any concurrently
landing port, and a scoped one would corrupt the file). Flagged for the
integrator: `do_build` should merge into the parsed existing manifest instead
of replacing it, and `--platforms` should probably refuse to write the
manifest at all until it does.

### 7. On a companion core, PORTING-CHECKLIST Step 1 has nothing to configure - and its wording actively misleads

Step 1 says "System clock to the frequency you pass as `F_CPU`". On a
remoteproc-loaded companion core there is no clock to bring up: the PLLs, the
DDR controller and every peripheral clock were configured by the boot chain
and are owned by Linux drivers. A second writer would be a *bug*, not
diligence. `SystemClock_Config()` here is genuinely empty, with the reasoning
stated in the function - an honest empty function with a contract, not the
"compiles but dead" stub class.

The obligation Step 1 actually protects (a lie about `F_CPU` breaks every
later step invisibly) is discharged instead by **declaration plus a
compile-time check**. Which leads to the sharper finding:

**`F_CPU` too HIGH is as fatal as `F_CPU` too low, and nothing said so.**
[§14](#ch32v006-riscv-gaps) item 9 records the classic trap (an undivided HPRE
making the real clock 3x slower than declared). The inverse bites on any
application-class core: `F_CPU` feeds `TICKS_PER_MICROSECOND`, and
[§4](#pulse-reset-timer)'s pulse arithmetic lands in a `uint8_t`:

```
step_pulse_time = -((pulse_us - 2) * TICKS_PER_MICROSECOND) >> 3
```

At a 700 MHz `F_CPU`, the default 10 us pulse computes 700 - it does not fit a
`uint8_t` at all, and every realistic pulse width wraps to garbage. The
resolution is that **`F_CPU` is the STEPPER TIMER's tick rate, not the CPU
frequency** - true on AVR only because they coincide there. This port declares
the 25 MHz APB timer clock and keeps the CPU frequency as a separate constant
used for nothing timing-critical.

Recommended for `_template` and any future fast-core port, since the failure
is otherwise invisible until a scope is on the pins:

```c
_Static_assert((((PULSE_US_HEADROOM - 2UL) * (F_CPU / 1000000UL)) >> 3) <= 255UL,
               "8-bit pulse horizon: F_CPU too high for the stepper-timer role");
```

The general ceiling the origin arithmetic imposes is
`pulse_us_max = 2 + (255 * 8) / TICKS_PER_MICROSECOND` - 129 us on the 16 MHz
AVR, i.e. an inherited property, not a new limitation.

### 8. Item 7 of [§12](#weak-memory-obligations) is NVIC-shaped and does not transfer to a PLIC

[§12](#weak-memory-obligations) item 7 tells a port to give pulse-reset the
highest preemption priority, the stepper next, and serial a lower one so it
cannot starve the pair. On a **PLIC** that is only half implementable:
priorities decide which source is *claimed first when several are pending
simultaneously*; a PLIC has no preemption levels and cannot interrupt a
handler that is already running. Setting priorities satisfies the letter of
the item and delivers none of the starvation protection.

The second half has to be solved in software, and can be: the long-running
handler re-enables interrupts around its own body, exactly the way core's
`ISR_STEP` does with its `sei()`. Here the doorbell handler's drain loop is
bounded only by how much the host sent (up to a full 8 KiB ring) - orders of
magnitude past the 33.3 us ISR-hot budget - so it brackets the drain with
`sei()`/`cli()` and the stepper pair preempts it freely. It cannot recurse
into itself because the PLIC will not re-deliver a claimed-but-incomplete
source.

That requires real nesting, which in turn requires the trap entry to save
`mepc`/`mstatus` itself: GCC's `__attribute__((interrupt))` prologue saves
GPRs and **not** those two CSRs, so a nested trap silently destroys the outer
trap's return address. This is the first port in the tree to nest rather than
defer (ch32v006 and ch570 both defer, which
[§5.2](#isr-definition-macros) accepts); the saving is four instructions and it
is what makes [§5.2](#isr-definition-macros)'s AVR semantic actually hold
instead of merely being tolerated.

**Suggested edit to item 7 of [§12](#weak-memory-obligations):** say "where the
interrupt controller HAS preemption levels (NVIC, PFIC)", and name the
software bracket as the required substitute where it does not.

### 9. Contract macros can be satisfied by a hardware shape the contract never imagined - the check is the SEMANTIC, not the mechanism

Four of this port's blocks lack the register the contract's reference
implementation uses, and none of the four is a no-op:

- **No timer prescaler.** [§3](#stepper-timer)'s `STP_TMR_PRESCALER_SET`
  becomes a stored software multiplier applied by `PERIOD_SET` (ch570's
  technique, reused). The observable semantic - the next segment's real-time
  period scales by the selected divisor - is identical.
- **No F_CPU/8 pulse tick.** [§4](#pulse-reset-timer) explicitly permits
  rescaling; `START()` loads `(256 - val) * 8` counts, which reproduces *both*
  halves of the contract at once: the exact pulse width and the 8-bit overflow
  HORIZON (the `256` is computed from the `uint8_t` core handed over, so the
  wrap point stays core's, not the 32-bit counter's). This is the SAMD21 gap
  of [§4](#pulse-reset-timer) fixed rather than inherited.
- **No UART at all.** [§7](#serial) over a shared-memory ring, with one
  deliberate cardinality change: the doorbell fires once per burst so the
  handler drain-loops. [§7](#serial)'s table binds semantics, not
  one-interrupt-per-byte, so this is legal - and BUG #19's realtime
  interception is inherited verbatim *provided* the drain loop performs the
  per-byte classify exactly as many times as N separate byte interrupts would.
  That call-count invariant is the single thing a future editor must not
  break, and it is stated at the top of the file that could break it: a "fast
  path" memcpy'ing a run of bytes past the switch would compile, link, pass
  every gate in this repo, and silently disable the reset key.
- **No atomic set/clear registers, and no pull-up register.** DesignWare
  apb_gpio has neither. [§1.2](#gpio-data) names the remedy when hardware
  set/clear does not exist (a critical section) and this port takes it for
  every DR/DDR read-modify-write; [§1.4](#gpio-data) forbids a no-op pull-up,
  so the pulls are real writes into the SoC pad block, with the per-pad
  register mapping supplied by the board config because it is a package fact
  and not derivable. Being wrong there is a bring-up defect; being absent
  would be a contract violation.

### 10. Documenting UNVERIFIED facts: per-block banners, and confining the weakest block to two functions

This is the first port in the tree with **no vendor documentation of any
kind** - not "the TRM is thin", but no TRM exists.
[§14](#ch32v006-riscv-gaps) item 7 already recorded that "struct-shaped
best-effort register layouts are worse than absent ones", with the RM as the
mitigation. With no RM, two other mitigations were used and are worth reusing:

- **Per-block banners that grade themselves.** Confidence is not uniform and a
  blanket file-level "unverified" flattens it. The DesignWare GPIO/timer
  blocks and the PLIC/CLINT are third-party IP with published specifications,
  so only the *instantiation* (base address, IRQ number, clock) is guesswork;
  the vendor mailbox has no specification anywhere. Each block states what its
  claim rests on, what a bring-up engineer must confirm, and **what the
  symptom of it being wrong looks like** - the last being the part that
  actually saves time (e.g. "a wrong PLIC context delivers no interrupt at
  all: the firmware boots, prints its banner, and never steps").
- **Put the least-documented block off the correctness-critical path, on
  purpose.** The mailbox doorbell is the weakest fact in the port, so the ring
  protocol was designed to be fully self-describing through its head/tail
  indices: a host that ignores the doorbell and polls is a functional peer,
  and every mailbox access is confined to two functions. A wrong doorbell
  costs **liveness**, never data integrity. Choosing which unverified fact is
  allowed to be load-bearing is a design decision, and it should be made
  deliberately rather than discovered later.

### 11. Two gaps this port itself introduced, found rebasing onto a 69-commit-newer integration branch

This port's own commit was written and merge-tested against an OLD base and
never checked against the invariants that landed on the integration branch
while it was away. Both are the exact classes this file already names
elsewhere in this same port's gap log and in sibling ports' own histories -
not new bug classes, just this port's own instance of them, caught at
integration time rather than left latent:

- **`#ifdef ENABLE_M7` inside a prelude-injected header** -
  `boards/generic/config.h` gated `COOLANT_MIST_PORT/PIN/BIT` behind it. This
  file is reached through `boards/generic/prelude.h`'s `-include`, which runs
  before core `grbl.h`'s own `#include "config.h"` ever defines `ENABLE_M7`
  ([§29](#prelude-phase-dead-guard)'s wrong-phase class) - the guard could never
  observe the option even if a user enabled it, permanently dropping mist
  coolant. The identical bug was already found and fixed on ch32v006 and
  ch570's own `boards/generic/config.h` (see their file comments); this
  port's `timer.h` correctly AVOIDED the same class for `STEP_PULSE_DELAY`
  two files over, in the same batch, which is what made the config.h instance
  conspicuous rather than plausible. Fixed by defining the pins
  unconditionally - core's own correctly-timed `#ifdef ENABLE_M7` in
  `coolant_control.c` is the only place that ever reads them.
- **No boot-init-reachability wiring at all** ([§boot-init-unreachable](#boot-init-unreachable),
  BUG #23) - unlike every sibling RISC-V port, this port shipped with no
  `GRBL_BOOT_INIT`, no `INIT_SYMBOLS`, and no `../common/init_check.sh`
  invocation in its Makefile. `SystemClock_Config()` and `sg2002_plic_init()`
  are called only from `Reset_Handler`, before `main()` - precisely the shape
  that deleted four other ports' clock/GPIO bring-up under `-flto`. This port
  has no `-flto` today, so nothing was silently lost yet, but the absence of
  the ratchet itself was the gap: the day RELEASE gains `-flto` (the house
  style every sibling RISC-V port already follows), this port had zero
  protection against the identical regression. Fixed: both functions tagged
  `GRBL_BOOT_INIT` (declaration in `platform.h`, definition in `platform.c`);
  `Reset_Handler` tagged `__attribute__((used))` instead (ch32v006/ch570's own
  precedent - it is reached only via `_start`'s raw inline asm `jal
  Reset_Handler`, invisible to any IPA `noinline` would help against, so
  `used` is the correct, narrow exception to "never use `used` here" rather
  than a violation of it); Makefile gained `INIT_SYMBOLS =
  Reset_Handler,SystemClock_Config,sg2002_plic_init` and runs
  `../common/init_check.sh` at link time. `BOOT INIT: OK` on both flavors;
  sizes unchanged (`noinline`/`used` cost nothing when the functions were
  never going to be inlined or deleted in the first place - this port
  deliberately did NOT also add `-flto`, to avoid stacking an unrelated
  optimization-correctness risk onto this same rebase).
