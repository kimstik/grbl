# HC32F460 Platform Notes

**Status**: builds clean (DEBUG + RELEASE), zero `PORT_TODO_*`, zero undefined
symbols, `FP=SINGLE` assert PASSED, boot-integrity check PASSED. **NOT** "ready
for hardware validation" in the same unqualified sense as stm32f411/stm32h523/
stm32f103: most register facts in `regs.h` are honestly-flagged UNVERIFIED
placeholders (no register-level manual reachable this session) — see below.

Chip: HC32F460JETA (HDSC/XHSC, Huada Semiconductor), ARM Cortex-M4F, up to
200 MHz, up to 512KB Flash, up to 192KB SRAM. First HDSC/vendor-exotic chip
in this tree — see [CONTRACTS.md section 22](../CONTRACTS.md#hc32f460-gaps) for the full gap log.

## Verification methodology (read this before trusting any register write)

No donor port in this tree shares this vendor's peripheral IP. Facts in
`regs.h` are graded at their own definition site:

- **CONFIRMED**: sourced from the official HC32F460 Series Datasheet Rev1.3
  (HDSC, English, feature-list/TOC only — not the full register manual) and/or
  cross-checked against Klipper3d/klipper's real shipped `src/hc32f460`
  firmware (GPL-3.0, license-compatible with this GPLv3 core; running on
  physical Voxelab Aquila hardware, not a vendor SDK; used as a factual
  cross-check, not copied).
- **UNVERIFIED**: this port's own clean-room placeholder, explicitly commented
  at the point of use. No register-level HC32F460 manual was reachable this
  session; the HDSC `hc32f4a0_ddl` vendor SDK exists publicly
  (github.com/Mmatsnev/hc32f4a0) but no permissive LICENSE file was found in
  it, so it was not vendored or transcribed (PORTING-CHECKLIST's "vendor SDK
  only if permissively licensed, clean-room is the fallback" rule, exercised
  for the first time in this tree for the reason it names).

Confirmed this session: GPIO data-path register names (PIDRx/PODRx/POSRx/
PORRx, 0x10 stride per port letter), the INTC event-router mechanism (32
shared `Int000_IRQn`..`Int031_IRQn` vectors, source routed at runtime via
`M4_INTC->SEL[n].INTSEL`), TIMERA as the real PWM peripheral, TIMER0/USART/
CMU/PWC/EFM peripheral *existence* and section numbers, and three real CMU
sub-register addresses (`CMU_XTALCFGR`/`CMU_PLLCFGR`/`CMU_CKSWR`) plus the
`CMU_CKSWR_MPLL = 0x05` value, from a real Voxelab bootloader.

UNVERIFIED (hardware bring-up must confirm before trusting anything
electrical): PCONR per-pin config bit layout, EFM flash controller register
layout and `FAPRT` key value, TIMER0/TIMERA control-register layouts, PWC_FPRC
unlock code value, INTC/EIRQ/PORT/TIMER0/TIMERA/USART1 base addresses, the PLL
coefficient set for 200MHz.

## Pin map (generic reference board — no specific commercial board targeted)

Step PA0-2, Direction PA3-5, Steppers-disable PA6, Spindle PWM PA8 (TIMERA1
CH1), Spindle enable/dir PA9/PA10, Coolant PA11/PA12, Limits PB0-2, Control
PB3-6, Probe PB7, Serial USART1 PC0(TX)/PC1(RX) — the last pair matches
Klipper's documented alternate USART1 pins for this exact chip. LIMIT and
CONTROL deliberately share one port at non-colliding bit numbers 0-6 to
sidestep any EIRQ/EXTI-style line-number collision regardless of the real
(unverified) cross-port interrupt model.

## Architecture highlights new to this tree

- **INTC event router, not a fixed vector table.** Every peripheral
  interrupt source is assigned at runtime to one of 32 shared vectors
  (`intc_route()`, regs.h). `startup.c`'s vector table is therefore generic
  and stable; what changes per board is only the `intc_route()` calls in
  `platform.c`.
- **Split USART RX/TX interrupt sources**, unlike every STM32/SAMD21 donor's
  combined vector — two one-line handlers instead of an SR-flag dispatcher.
- **Per-pin GPIO config register** (not per-port bitfield) for direction/
  pull-up — function calls (`hal_gpio_set_output`/etc), same shape-class
  reasoning as stm32f411/h523's MODER/PUPDR, generalized one step further.

## FPU

`-mfpu=fpv4-sp-d16 -mfloat-abi=hard`, `FP=SINGLE` default. Disassembly of the
RELEASE ELF: `vsqrt.f32` present (1), 82 `vmul.f32` / 161 combined
`vadd/vsub/vdiv.f32`, **zero** `__aeabi_d*`/generic DP soft-float symbols
anywhere in the image — cleaner than stm32f411's own result (which tolerated
one surviving `__aeabi_d2f` conversion). Same FPU win class as stm32f411/
stm32h523 (CONTRACTS.md section 17.7).

## Verified build (this session)

```
make BUILD=DEBUG    # .text 41220B, .data 80B, .bss 129968B (of 512KB flash / 128KB RAM)
make BUILD=RELEASE  # .text 25596B, .data 80B, .bss 129968B
```

Both link with zero `PORT_TODO_*` symbols and zero undefined references.
`tools/assert_no_double.sh` PASSED on both. `common/boot_check.sh` PASSED on
both (`BOOT INTEGRITY: OK`). Sibling builds re-verified untouched this
session: golden AVR MD5 `79af184e67b27defd27a39309ac53563`; samd21
(`BOARD=megarm`) RELEASE 31952/296; stm32f103 RELEASE 28700/80; stm32h523
RELEASE 25132/388; stm32f411 RELEASE 25796/80; ch32v006 (`BOARD=generic`)
RELEASE 41072/0.

Note on `.bss` size: the large `.bss` figure (~127KB) is the `script.ld`
`.heap` section's location-counter reservation spanning to
`ORIGIN(RAM)+LENGTH(RAM)-stack_size` — an artifact of the shared template
linker-script pattern (confirmed identical on a fresh stm32f411 rebuild this
session, also 129968), not something specific to this port or a real
128KB-of-uninitialized-data problem.

## Known gaps (hardware bring-up items, not build blockers)

- No register-level HC32F460 manual reachable this session — every
  UNVERIFIED item in `regs.h` needs confirmation before hardware bring-up.
- Not smoke-tested (no HC32F460 emulator target in this repo).
- USB FS, DMA, ADC, CAN present in silicon are not wired up by this port.
- EFM flash-emulated NVMEM (`flash.c`) commits the WHOLE page on every write
  (no batching) — correct-but-slow, matching this port's "correctness first,
  optimize later" posture given the underlying register facts are themselves
  unverified.


---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `flash.c`

flash.c - HC32F460 EFM flash-emulated NVMEM

Macro route (CONTRACTS.md section 10): core grbl/nvmem.c IS compiled
(Makefile GRBL_SOURCES) - its platform-agnostic
memcpy_to/from_nvmem_with_checksum functions are used unmodified, exactly
like every STM32 port in this tree. This file supplies the two functions
those call through the eeprom_get_char/eeprom_put_char macros
(platform.h): hal_nvmem_read_byte/hal_nvmem_write_byte, backed by a
write-through RAM cache of one EFM flash page.
EFM register layout (regs.h) is UNVERIFIED placeholder - see regs.h file
header. This file's structure (unlock/erase/program/wait-ready/lock,
__DSB() before the commit command, poll READY after every erase/write,
skip-write-if-equal wear guard) is the CONTRACTS.md section 10.5/12.4
discipline applied regardless of whether the exact bit values are right;
hardware bring-up must confirm the register facts before trusting actual
flash retention.

## `gpio.h`

gpio.h - HC32F460 GPIO register accessors and macro overrides

Injected by prelude.h BEFORE platform/common/gpio.h: that file only
supplies AVR-style defaults for accessors/macros that are not already
defined (all of its definitions are #ifndef-guarded), so everything here
wins by coming first.
Composition contract (platform/CONTRACTS.md section 1): core code calls
GPIO_*(NAME) macros; NAME##_PORT / NAME##_BIT / NAME##_MASK come from the
pin map in platform.h (NAME##_PORT is a HC32_PORT_TypeDef*).
Direction/pull-up are function calls, not bit-op macros: the PCONR
per-pin config register (regs.h) is one word per pin, not a packable
per-port bitfield - same shape-class reason stm32f411/stm32h523 use
function calls for MODER/PUPDR (CONTRACTS.md section 14 item 5's "4-bit
packed config register" lesson, generalized here to "one config word
per pin").

## `handlers.c`

handlers.c - HC32F460 interrupt vector wrappers

Real IRQ vectors for the timers (TIMER0 units 1/2), USART1 RX/TX, and the
PORT EIRQ channels (limit switches + control pins), all routed through
this chip's INTC event router onto the shared Int0xx_IRQn vector pool
(regs.h) - a materially different shape from every donor port in this
tree, which hard-wire one physical IRQ number per peripheral.
Each wrapper clears the peripheral interrupt flag FIRST, then calls the
core-supplied ISR body - clearing after would lose edges/updates that
arrive during the body (CONTRACTS.md sections 2.3 and 5.1). USART RX/TX
are the one exception noted below: reading/writing DR is itself what
clears RXNE/TXE on this class of UART, mirroring every other port in
this tree's USART handling.

## `platform.c`

platform.c - HC32F460 platform implementation

HC32F460JETA: up to 200MHz Cortex-M4F. Every register access below routes
through regs.h, which grades each fact CONFIRMED vs UNVERIFIED placeholder
- see that file's header for the full methodology. This file's job is to
give every CONTRACTS.md macro a genuine, self-consistent implementation so
the port BUILDS and LINKS with zero PORT_TODO_*; electrical correctness on
real silicon is explicitly deferred to hardware bring-up (no HC32F460
emulator exists, same posture as CONTRACTS.md section 16's dsPIC33AK
notes).

## `platform.h`

platform.h - HC32F460 platform HAL interface

Platform-specific HAL interface for HC32F460JETA (HDSC/Huada, ARM
Cortex-M4F, up to 200 MHz, up to 512KB Flash, up to 192KB SRAM).
NOTE (Phase 6 rolling port #3): the file this replaces was a
documentation skeleton only - marketing-comment blocks ("BEAST", "12.5x
faster"), `#include "hc32_ddl.h"`/`"hc32f460.h"`/`"core_cm4.h"` pointing
at a vendor SDK never vendored into this tree, and no Makefile/gpio.h/
timer.h/regs.h/startup.c/platform.c/handlers.c/script.ld anywhere in the
directory (`ls grbl/platform/hc32f460/` before this port: only a stub
`avr/io.h` and this 460-line doc-only header). It never built. Per
PORTING-CHECKLIST.md's "trust only builds" rule (three prior "complete"
claims in this tree - stm32f103, stm32h523, stm32f411 - never having
compiled before their real ports landed), none of its claims were
carried forward without re-verification; this file replaces it entirely.
Vendor-exotic disclosure: HC32F460 is HDSC/Huada silicon, not an
STM32/SAMD clone. Its peripheral IP (TIMER0/TIMERA, GPIO PORT model,
INTC event router, EFM flash, PWC/CMU clock tree) has no donor port in
this tree. See regs.h's file header for the full verification
methodology - facts are graded CONFIRMED (datasheet TOC + Klipper3d/
klipper's real shipped GPL-3.0 firmware, cross-checked, not copied) vs
UNVERIFIED placeholder (no register-level manual reachable this
session).

## `regs.h`

regs.h - HC32F460 register definitions

```
HDSC/XHSC HC32F460JETA, ARM Cortex-M4F, up to 200MHz, up to 512KB Flash,
up to 192KB SRAM.
VERIFICATION METHODOLOGY (Phase 6 rolling port #3 - first HDSC/Huada
vendor-exotic chip, neither ST/NXP/Atmel-family "familiar ARM" nor a
previously-ported ISA). PORTING-CHECKLIST.md's reuse-first rule does not
apply here: no donor port in this tree shares this vendor's peripheral IP
at all (TIMER0/TIMERA/TIMER4/TIMER6, an INTC event router instead of a
fixed NVIC vector map, EFM flash, PWC/CMU clock tree). Every fact below is
sourced and graded honestly, same discipline as CONTRACTS.md sections 14/16
(RISC-V/dsPIC first-time gaps):
CONFIRMED sources this session:
  - HC32F460 Series Datasheet Rev1.3 (HDSC/Huada, official, English) TOC
    and feature list confirm peripheral EXISTENCE and section numbers:
    CMU 1.4.4 (p18), PWC 1.4.5 (p19), EFM 1.4.7 (p20), GPIO 1.4.9 (p21),
    INTC 1.4.10 (p22), TimerA 1.4.21/Timer0 1.4.22 (p27, "2 16bit basic
    Timer(Timer0)", "6 16bit universal Timer(TimerA)"), USART 1.4.25
    (p28, "4 USART"). This document is the datasheet, not the full
    register-level user manual (not available in extractable form this
    session) - it does NOT contain register bit-field tables.
  - Klipper3d/klipper `src/hc32f460` directory (github.com/Klipper3d/klipper,
    GPL-3.0 - license-compatible with this GPLv3 grbl core; real firmware
    shipping on Voxelab Aquila printers, not a vendor SDK) - fetched and
    cross-checked this session for CONCRETE facts: GPIO data-path register
    NAMES (PIDRx/PODRx/POSRx/PORRx/POTRx, offsetof-derived, "ports are in
    one M4_PORT - offset by 0x10" between port letters), the INTC event
    router mechanism (`M4_INTC->SEL[irqType].INTSEL = irqSrc` then
    `NVIC_SetPriority`/`NVIC_EnableIRQ(irqType)`, vector slots
    "Int000_IRQn through Int031_IRQn" - QUOTED VERBATIM from the fetched
    source, 32 shared peripheral vectors, NOT a fixed per-peripheral
    table like every STM32/SAMD21 donor in this tree), USART register
    access via `DR_f.RDR`/`DR_f.TDR` fields and `PWC_FcgxPeriphClockCmd()`
    clock-gate calls, TIMERA used for PWM (`M4_TMRA_TypeDef`,
    `stc_timera_base_init_t`/`stc_timera_compare_init_t`,
    `PORT_SetFunc(..., Func_Tima0, ...)` pin routing), and real clock-tree
    addresses from a Voxelab bootloader (CMU_XTALCFGR @ 0x40054410,
    CMU_PLLCFGR @ 0x40054100, CMU_CKSWR @ 0x40054026, PLL config value
    0x11102900 decoded to MPLLN=41/x1/x42/div2).
  - Vendor DDL (HDSC/XHSC `hc32f4a0_ddl`, github.com/Mmatsnev/hc32f4a0
    mirror): confirmed to EXIST (CMSISPack + DeviceDriverLibrary
    directories) but NO permissive license file was found this session
    (repo footer shows bare "(C) HDSC" copyright, no LICENSE/SPDX
    anywhere located) - unlike the dsPIC33AK DFP (Apache-2.0, CONTRACTS.md
    section 16 item 11) or the ch32v006 Zephyr dtsi cross-check
    (Apache-2.0, section 14 item 7). Per PORTING-CHECKLIST's own ordering
    ("vendor SDK only if permissively licensed; clean-room is the
    fallback, not a last resort"), this port does NOT vendor or transcribe
    the HDSC DDL - every struct/macro below is original clean-room code,
    informed by (not copied from) the facts above.
RM-ONLY / UNVERIFIED this session (no register-level manual reachable):
every base address below OTHER than the CMU sub-registers cited above,
every bit-field position, the PCONR per-pin config layout, the EFM
FAPRT unlock key value, and the exact numeric INTC source-ID values.
Each is flagged at its definition with "UNVERIFIED" and a plain-language
note of what hardware bring-up must confirm before trusting it - the
same posture CONTRACTS.md sections 14/16 established for RISC-V/dsPIC
fields with no locally-reachable RM. A struct-shaped placeholder that
compiles is not evidence of correctness (CONTRACTS.md section 14 item 7's
explicit lesson: "struct-shaped best-effort register layouts are worse
than absent ones" when NOT flagged - so every guess here IS flagged).
```

## `startup.c`

startup.c - Startup code for HC32F460

Interrupt vector table and reset handler for HC32F460JETA. ARM Cortex-M
hardware-vector-fetch model (PORTING-CHECKLIST.md's non-ARM warning does
not apply here - this port is ARM, not RISC-V/dsPIC). The peripheral
region of the table is NOT a fixed per-peripheral layout like every
STM32/SAMD21 donor in this tree: this chip routes every peripheral
interrupt source through the INTC event router (regs.h) onto a pool of
32 identically-named "Int000_IRQn..Int031_IRQn" shared vectors - CONFIRMED
shape via Klipper3d/klipper's real hc32f460 port (see regs.h file header),
UNVERIFIED numeric base addresses for the router itself.

## `timer.h`

timer.h - HC32F460 timer primitives with contract naming

```
Contracts: platform/CONTRACTS.md sections 3-6; naming: platform/common/timer.md.
Allocation (PORTING-CHECKLIST Step 3's "audit IRQ capability before
allocating" rule, CONTRACTS.md section 14 item 11):
  - Stepper timer:      TIMER0 unit 1 (datasheet 1.4.22, "2 16bit basic
    Timer(Timer0)", each generates a real compare-match event/interrupt
    per the datasheet feature description - confirmed at the
    feature-existence level, register layout UNVERIFIED, see regs.h).
  - Pulse-reset timer:  TIMER0 unit 2 (second instance of the same IP).
  - Spindle PWM:        TIMERA unit 1 channel 1 (datasheet 1.4.21, "6
    16bit universal Timer(TimerA)" - CONFIRMED via Klipper's hard_pwm.c
    to be this chip family's real PWM peripheral).
regs.h flags every register offset/bit position in this file's
dependencies as UNVERIFIED placeholder - hardware bring-up must confirm
before trusting pulse width or PWM waveform shape (same posture as
CONTRACTS.md section 16 item 13's SCCP note on dsPIC33AK).
```
