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
