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
   platform must remap in its accessors). SAMD21 megarm CONTROL bits are 14/15/16
   (megarm/config.h:97-103) — truncated to zero at system.c:43: control-pin
   input is dead on that port as written. Known gap; a port is not done while
   such a mismatch exists.
4. **Pull-up semantics**: after `GPIO_MDIR_INP` + `GPIO_MPULLUP_EN`, the pin
   must read logic 1 when the switch is open (AVR PORTx-on-input = pull-up,
   cpu_map.h wiring assumption throughout limits/probe/control). No-op is
   `conditional`: legal only for boards with external pull hardware, and the
   board config must say so. SAMD21 maps `GPIO_PREG` to `PORT...CTRL`
   (samd21/gpio.h:18) — the sampling-control register, not `PINCFG.PULLEN`:
   pull-ups are NOT actually enabled on that port as written. Known gap.
5. **No-op**: ILLEGAL for everything except the pull-up pair per (4).

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

## 5. Timer ISR definition macros (`ISR_STEP`, `ISR_STEP_RESET`, `ISR_STEP_DELAY`)

Core defines the bodies: stepper.c:326, 496, 511. AVR expands directly to
vectors (atmega328p/timer.h:37-39). ARM route: expand to named plain functions
(samd21/timer.h:45-47) and provide vector wrappers that **clear INTFLAG first,
then call the body** (handlers.c:30-47).

Contracts:
1. Flag-clear-first, same rationale as section 2.3. `ISR_STEP_RESET` stops the
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
   (cpu_map.h:131). SAMD21 megarm declares 65535 (megarm/config.h:139) against
   `PER = 0xFF` (samd21/timer.h:109) — both sides of that are contract
   violations (values >255 truncate in core; CC[0] > PER saturates). Known gap.
3. `PWM_SET(x); PWM_ENABLE()` in either order must yield duty `x` — core does
   SET before ENABLE (spindle_control.c:124-129).
4. `PWM_DISABLE()` must drive the spindle pin inactive, not float it
   (SPINDLE_PWM_MIN_VALUE comment, megarm/config.h:140).

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

## 11. Interrupt global control (`sei`/`cli`)

Core calls bare `sei()` (main.c:48, stepper.c:355). AVR: native. Non-AVR must
define both (samd21/platform.h:206-207: `cpsie i`/`cpsid i` with `"memory"`
clobber — the clobber is mandatory: it is the compiler barrier that keeps
stores from floating across the interrupt-enable boundary).

---

## 12. Weak-memory obligations — consolidated

Every ARM/RISC-V implementation must be audited against this list; the AVR
origin needed none of it, so nothing in core will remind you:

1. **Ring buffers**: data store -> `__DMB()`/release -> index publish
   (BUG #12; samd21/serial.c:172). Consumer: index read -> `__DMB()`/acquire ->
   data read if the consumer can race a concurrent producer slot reuse.
2. **volatile != atomic**: `volatile uint8_t` gives width-atomicity of the
   single access only. Any RMW (`|=`, `&=~`) shared with an ISR needs
   `HAL_CRITICAL_SECTION_*` or interrupt masking (section 8).
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

## 13. Known contract gaps in the SAMD21 reference (do not copy blindly)

The SAMD21 port is the ARM *adaptation reference*, not a compliance gold
standard. Open violations, all cited above: prescaler silent no-op (§3),
empty critical sections (§8), CONTROL input bits above bit 7 (§1.3),
pull-up accessor mapped to PORT CTRL (§1.4), pulse-width 16-bit overflow
horizon (§4), PWM range 65535 vs PER=0xFF vs core uint8_t (§6.2),
EIC arming never called (§2.1). Each is a Phase-3 closure item; each future
port must clear this whole file instead.

Closed: `_delay_us/_delay_ms` empty stubs — real calibrated busy-wait
implementations landed (samd21/platform.c:169-214, commit dd5c5e7). The
lesson stands: empty delay stubs compile and break homing debounce and
spindle ramp silently.
