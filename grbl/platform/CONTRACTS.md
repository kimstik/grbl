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
   posture as the SAMD21 M0+ reference (§5.2) and avoids the nested-trap
   mepc/mstatus clobber hazard (GCC's interrupt attribute saves GPRs
   only). Consequence: core's `sei()` inside ISR_STEP defers, not nests,
   the pulse-reset IRQ — acceptable per §5.2's existing precedent.
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
   pulse-reset role (§4) moved to the QingKe STK, which is actually the
   BETTER fit: its STCLK=0 mode ticks at HCLK/8 — bit-identical to the
   AVR Timer0 F_CPU/8 prescale, so core's `>>3` arithmetic transfers
   with no rescaling; CMPLR is fixed at 256 and COUNT_SET preloads the
   8-bit value (the §4 overflow-horizon contract on a 32-bit counter).
   Cost: the STK has ONE compare — `STEP_PULSE_DELAY` is unsupported
   and `#error`s loudly (legal per §4 conditional rule). Checklist
   lesson: PORTING-CHECKLIST Step 3 must ask "does the candidate timer
   HAVE an interrupt line" before allocating it.
12. **EXTI line/port collision is a board-design constraint** on every
   F1/CH32-class EXTI (one port per line number via AFIO_EXTICR):
   LIMIT and CONTROL groups must not use the same pin NUMBERS on
   different ports or one group's interrupts are unroutable. The M1-M3
   placeholder board had exactly this bug (LIMIT PD0-2 + CONTROL
   PA0-2); CONTROL moved to PB3-5. On V00x additionally ALL lines 0-7
   share the single EXTI7_0 vector — the §2.5 shared-vector dispatch
   rule applies to the whole GPIO interrupt space, and per-group
   disable (§2.1) works because the two groups own disjoint INTENR
   bits.
13. **`-O0` debug builds do not fit small-flash parts**: soft-float
   rv32ec grbl at -O0 is ~77 KB of .text vs 61 KB available (62 K minus
   the 1 KB NVMEM window). ch32v006 DEBUG uses `-Og -g3` instead —
   fitting the part beats stepping through unoptimized spills. Any port
   below ~96 KB flash should expect the same decision; RELEASE (-Os)
   text here is ~55.5 KB, so headroom exists but not at -O0.

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
   handlers per §2.5) rather than stm32h523's per-line vectors. Two "same
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
   (§14.4) and the choice was forced rather than optional. stm32h523 already
   set this precedent one FPU generation up (`fpv5-sp-d16`); this port
   follows it rather than falling back to softfp by default.
6. **HPRE already resets to /1 on F4 (no CH32-class trap here), but the
   §14.9 lesson is still followed defensively**: unlike CH32V00x's
   `RCC_CFGR0.HPRE` reset value of SYSCLK/3 (§14.9(a)), STM32F4's
   `RCC_CFGR.HPRE` reset value genuinely is 0000 = SYSCLK/1 (RM0383) — so
   this port's clock config would have worked even without touching HPRE.
   `hal_clock_config()` clears/sets it explicitly anyway, on the principle
   that "verified correct by inspection of the reset value" is exactly the
   failure mode §14.9 exists to warn against generalizing from — a future
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
   (grepped the DFP header). So the §1.2 mixed-writer hazard
   (STEPPERS_DISABLE/SPINDLE/COOLANT from mainline + `st_go_idle()`
   inside ISR_STEP) is REAL on a chip whose ISA looks AVR-safe on paper.
   Fix shape: GPIO_BSET/BCLR wrapped in the save/restore critical
   section (gpio.h); GPIO_MWO stays bare RMW under the ISR-only writer
   discipline. `_template/gpio.h`'s §1.2 audit box now has its first
   "ISA has the instruction, codegen won't promise it" reproducer.
3. **"What barriers exist?" can legitimately answer NONE**: the dsPIC33A
   instruction set has no fence/DSB/DMB-class instruction. Single core,
   single bus master (DMA unused), no cache, in-order pipeline — the
   compiler is the only reordering agent, so `__DSB()/__DMB()` are
   compiler barriers (`asm volatile("":::"memory")`), which is exactly
   what §12.1/§12.4 need here. SFR read-after-write pipeline hazards are
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
   flash absorbs it; contrast §14.13 where small flash forced the
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
   real bit-per-pin pull-up register — §1.4 satisfied by construction,
   first port where the pull-up contract cost zero thought.
6. **The §14.3 gc-sections hazard is ABSENT here, and the check method
   is now proven**: xc-dsc specs contain no gc-sections rule
   (`-dumpspecs` grepped), and the M3 link's 33-symbol PORT_TODO list
   was diffed IDENTICAL against `nm -u` over all 20 objects — the
   linker-as-checklist is complete by construction on this toolchain.
   Every future port should run that same nm-vs-link diff once before
   trusting its M3 list.
7. **dsPIC33A interrupt model upgrades on classic dsPIC in ways that
   matter to §5.2**: INTCON1 has a real GIE bit (global enable — classic
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
   (§14.9's class, third variant): on dsPIC33A the CPU clock (CLKGEN1)
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
   none of which is /8. This is the "or rescale" branch CONTRACTS.md #4
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
   boot-integrity check (BUG #21 ratchet, §18) PASSED on all 6 STM32
   images; ch32v006's RISC-V `_start`-at-flash-base boot check PASSED on
   both flavors. `FP=DOUBLE` re-verified as a true no-op vs. pre-rollout
   HEAD on all four ports (byte-identical text to the pre-knob baseline)
   before switching each to the `FP=SINGLE` default.
7. **dsPIC33AK128MC102 IS the intended first conscious `FP=DOUBLE`
   consumer, landed (Steps 3-6, this session)** — §17.3's own framing
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
   exercised (no dsPIC33A emulator exists, CONTRACTS.md #16). Both
   `FP=DOUBLE` flavors (the default) link with zero `PORT_TODO_*`: RELEASE
   ~41.8KB code / DEBUG ~53.2KB code (both well inside the 128KB budget) —
   see CONTRACTS.md #16 items 12-20 for the Steps 3-6 register-fact
   writeup this build rests on.

## 18. KEEP() does not survive LTO: vector tables need a real code reference

*(Section number assigned by the BUG #21 work item; §17 is FP precision, landed
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

## 19. Guard hardening: two lessons from an adversarial review of §17/§18

An adversarial review of the FP=SINGLE assert (§17) and the boot-integrity
ratchet (§18) — the two newest guards at the time — found both were
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

`boot_check.sh` (§18) and `assert_no_double.sh` (§17) both run as a
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
correct by disassembly in CONTRACTS §14 item 2 (`mret` = opcode
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
