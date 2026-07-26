# STM32F411 Platform Notes

**Status**: builds clean (DEBUG + RELEASE), zero `PORT_TODO_*`, zero undefined
symbols. Not yet run on real hardware - "ready for hardware validation" per
PORTING-CHECKLIST.md's definition of done.

Chip: STM32F411CEU6 ("Black Pill"), ARM Cortex-M4F, 96 MHz, 128KB RAM, 512KB
Flash. Clock: HSE 25MHz -> PLL (PLLM=25, PLLN=192, PLLP=/2) -> 96MHz. This is
the community-standard Black Pill configuration (verified against multiple
independent sources this session, see `regs.h`/`platform.c` citations) rather
than the chip's absolute maximum (100MHz) - 96MHz also yields a clean 48MHz
USB clock on PLLQ if a future port wires up USB CDC.

## Pin map

Same physical layout as the stm32f103/stm32h523 "Blue/Black Pill" boards this
port reuses code from - see `platform.h` for the full table (step/dir/enable
on PA0-6, limits on PB0/1/10, control on PB3-6, spindle PWM PA8/TIM1_CH1,
spindle enable/dir PB12/13, coolant PC13/14, probe PC15, serial PA9/10).

## What was reused vs. what is new

- GPIO register model (MODER/OTYPER/OSPEEDR/PUPDR/AFR) and clock-config
  shape: ported from `stm32h523` (both are F4-style).
- EXTI dispatch (single `PR` pending register, shared `EXTI9_5`/`EXTI15_10`
  vectors) and USART register shape (`SR`/`DR`): ported from `stm32f103`
  (F411 is F1-shaped on these two axes despite sharing H5's GPIO shape - see
  CONTRACTS.md section 15 items 2-3).
- `flash.c`: new. F411 erases in 128KB SECTORS (`FLASH_CR.SER`/`SNB`), not
  the page model F1/H5 use. See CONTRACTS.md section 15 item 4 for how this
  port avoids a NVMEM cache-buffer overflow that exists (undisturbed, out of
  gate) on `stm32h523`.
- TIM1 base address (`0x40010000`) was re-derived from F4's own memory map,
  NOT copied from stm32f103/stm32h523's `0x40012C00` (that is F1/H5's TIM1
  address; on F4 it is SDIO) - see CONTRACTS.md section 15 item 1.

## FPU

`-mfpu=fpv4-sp-d16 -mfloat-abi=hard`. Justification in CONTRACTS.md section
15 item 5: core grbl is float-heavy throughout, hard-float register passing
is the reason to port to an FPU-bearing chip at all, and this toolchain's
multilib has a matching hard-float variant (confirmed by a clean link).

## Verified build (this session)

```
make BUILD=DEBUG    # .text 41644B, .data 80B
make BUILD=RELEASE  # .text 25796B, .data 80B
```

(Earlier `platform.md` revisions cited 48472B/28644B DEBUG/RELEASE `.text` -
those were this port's initial-landing sizes, since reduced by a later
size-optimization pass shared across the STM32 ports; the numbers above are
from a fresh build today.)

Both link with zero `PORT_TODO_*` symbols and zero undefined references.
Warning baseline: `ci/warn_baseline_stm32f411.txt` (regenerated from these
real logs, DEBUG and RELEASE produce the identical warning set).

## Known gaps

- Not smoke-tested (no Renode/emulator target for this chip in this repo).
- USB OTG FS, DMA, and ADC present in silicon are not wired up by this port.
- `config.h` redefines several `*_MASK` macros already canonical in
  `platform.h` (identical values) - same accepted "dual pin-map canon"
  pattern already carried by `stm32f103`/`stm32h523` (in the warning
  baseline, not fixed here to avoid diverging further from the established
  pattern those two ports set).
