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


---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `config.h`

config.h - STM32F411 platform configuration

STM32F411CEU6 ("Black Pill"): 96MHz Cortex-M4F, 128KB RAM, 512KB Flash.

## `flash.c`

flash.c - STM32F4 flash programming implementation

Flash controller for the STM32F4 family (F401/F411/F405/...): SECTOR
erase, not the F1/H5 PAGE erase model - PLATFORM_ROADMAP.md and
common/stm32/ARCHITECTURE.md both flagged this as the expected divergence
point for this platform. Sectors on F411CE (512KB) are non-uniform in
size (4x16KB, 1x64KB, 3x128KB); this file only implements the address
range this port actually uses (sector 7, the last 128KB sector, per
config.h/platform.h HAL_NVMEM_FLASH_START) rather than a full generic
address-to-sector table for the whole part.

## `gpio.h`

gpio.h - STM32F411 GPIO register accessors and macro overrides

Injected by prelude.h BEFORE platform/common/gpio.h: that file only
supplies AVR-style defaults for accessors/macros that are not already
defined (all of its definitions are #ifndef-guarded), so everything
here wins by coming first.
Composition contract (platform/CONTRACTS.md section 1): core code calls
GPIO_*(NAME) macros; NAME##_PORT / NAME##_BIT / NAME##_MASK come from the
pin map in platform.h (NAME##_PORT is a GPIO_TypeDef*).
Ported from stm32h523/gpio.h (byte-identical shape - F4's MODER/OTYPER/
PUPDR is the same 2-bit-per-pin model as H5's, so every macro that would
touch them is overridden below with function calls, implemented in
platform.c: hal_gpio_set_output/set_input/pullup_enable/pullup_disable).

## `handlers.c`

handlers.c - STM32F411 interrupt vector wrappers

Real IRQ vectors for the timers (TIM2/TIM3) and external interrupts
(EXTI, limit switches + control pins). Each wrapper clears the peripheral
interrupt flag FIRST, then calls the core-supplied ISR body - clearing
after would lose edges/updates that arrive during the body, and for
ISR_STEP_RESET specifically would ghost the final overflow after the
timer is stopped (CONTRACTS.md sections 2.3 and 5.1).
EXTI model: F4 keeps the classic single-pending-register (PR) EXTI, same
as F1 - NOT stm32h523's H5-specific RPR1/FPR1 split. This file therefore
follows stm32f103/handlers.c's shape (shared EXTI9_5/EXTI15_10 vectors with
core-ISR dedup dispatch, BUG#19-class realtime interception verbatim via
the core bodies), not stm32h523's per-line vectors.

## `platform.c`

platform.c - STM32F411 platform implementation

STM32F411CEU6 ("Black Pill"): 96MHz Cortex-M4F, 128KB RAM, 512KB Flash.
GPIO/clock code ported from stm32h523/platform.c (same MODER/OTYPER/PUPDR
model - CONTRACTS.md notes this is F4-style, and H5 kept it); EXTI/SYSCFG
wiring reverts to stm32f103's single-PR-register model (F4 does NOT have
H5's RPR1/FPR1 split); USART uses the classic SR/DR register pair (F4 is
NOT H5's ISR/RDR/TDR - see regs.h and platform.h HAL_SERIAL_* comments).

## `platform.h`

platform.h - STM32F411 platform HAL interface

Platform-specific HAL interface for STM32F411CEU6 ("Black Pill").
ARM Cortex-M4F, 96 MHz (25 MHz HSE via PLL), 128KB RAM, 512KB Flash.
NOTE (Phase 6 rolling port #1): the file this replaces was a documentation
skeleton only - marketing-comment blocks, a 65535 SPINDLE_PWM_MAX_VALUE
(one of the "duty-cap twins" this port fixes to the CONTRACTS.md-canonical
255), no Makefile/gpio.h/timer.h/startup.c/platform.c/handlers.c/script.ld,
and F1-vintage EXTI_LineN symbolic names that don't exist on this MCU
family. It never built. Per PORTING-CHECKLIST.md's "trust only builds"
rule, none of its claims were carried forward without re-verification.

## `regs.h`

regs.h - STM32F411 register definitions

```
Minimal register definitions for STM32F411CEU6 ("Black Pill"), ARM
Cortex-M4F. For production use, recommend using official CMSIS headers.
F411 is F4-family, NOT F1: GPIO is the MODER/OTYPER/OSPEEDR/PUPDR/AFR model
(same shape as stm32h523/regs.h, ported from there), but the peripheral
BASE ADDRESSES differ from both F1 and H5 - this is the trap flagged in
PORTING-CHECKLIST.md's reuse-first guidance: "same family resemblance" is
not "same memory map". Verified against RM0383 citations below (web search
this session, since no CMSIS pack is vendored here):
  - TIM1 is at 0x40010000 on F4 (NOT stm32f103/stm32h523's 0x40012C00 -
    that address is F1's TIM1 base; blindly reusing it would silently
    misdirect every TIM1 register access, including BDTR/CCR1, to whatever
    lives at 0x40012C00 on F4 (SDIO), a "compiles, links, destroys the
    machine at runtime" class bug the CONTRACTS.md cautionary tale warns
    against generalizing).
  - RCC_APB2ENR: TIM1EN=bit0, USART1EN=bit4, SYSCFGEN=bit14 (confirmed via
    STM32F412 RM cross-reference + community citations - F412/F411 share
    the APB2ENR layout in this range).
  - RCC_AHB1ENR: GPIOAEN=bit0, GPIOBEN=bit1, GPIOCEN=bit2 (standard F4).
  - RCC_PLLCFGR: PLLM[5:0]=bits0-5, PLLN[8:0]=bits6-14, PLLSRC=bit22,
    PLLP[1:0]=bits16-17, PLLQ[3:0]=bits24-27 (RM0383).
  - EXTI/SYSCFG: F4 keeps the classic single-PR-register EXTI model
    (write-1-to-clear on one pending register), UNLIKE stm32h523's
    RPR1/FPR1 split (that split is H5-specific) - handlers.c below follows
    the stm32f103 shared-vector dispatch pattern (EXTI9_5/EXTI15_10), not
    h523's per-line vectors.
  - IRQn positions (EXTI9_5=23, EXTI15_10=40, TIM2=28, TIM3=29, USART1=37,
    USART2=38) verified via search this session against the published
    STM32F411 CMSIS vector table - identical numbering to stm32f103/h523
    for these entries (coincidental overlap in the low IRQ range across
    F1/F4 families; NOT to be assumed for peripherals not cited here).
```

## `startup.c`

startup.c - Startup code for STM32F411

Interrupt vector table and reset handler for STM32F411CEU6. ARM Cortex-M
hardware-vector-fetch model (PORTING-CHECKLIST.md's non-ARM warning does
not apply here). IRQ numbering verified this session against the published
STM32F411 CMSIS vector table for every slot this port actually enables
(EXTI0-4, EXTI9_5, EXTI15_10, TIM2, TIM3, USART1) - see regs.h header
comment. Slots for peripherals absent on F411 silicon (CAN, USART3, TIM6/7/
8, FSMC, UART4/5, DAC - this is ST's cost-reduced "Cat.1 access line", not
the full F405/407 family) are left as 0 (reserved) rather than guessed.
