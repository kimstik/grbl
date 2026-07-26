# GRBL HAL Architecture

## Overview

This document describes the Hardware Abstraction Layer (HAL) architecture for GRBL. The HAL allows GRBL to run on multiple microcontroller platforms while keeping the core GRBL code unchanged.

**Staleness note (2026-07-26):** most of the concrete examples below (directory layout, macro
names, "Future Platforms" list) were written 2025-11-18 against an early single-platform design
and were never fully synced as the tree grew to 8 platforms across 3 ISA families. The macro
*concepts* here (compile-time expansion, zero AVR overhead, no runtime indirection) are still
accurate and are the project's actual invariant — but for the current directory layout, platform
list, and per-port status, treat `PLAN.md` (the live ledger) and `PLATFORM_ROADMAP.md` as
authoritative over this file, not the other way around. The "Build Prelude" section further below
was truth-updated 2026-07-26 and is current.

## Design Principles

1. **Zero Overhead on AVR**: The HAL must not add any performance or code size overhead on the original AVR platform
2. **Keep Original Code Pristine**: Never modify original GRBL source files - all platform logic goes in HAL
3. **Compile-Time Abstraction**: Use macros that expand to platform-specific code at compile time
4. **Single Source Tree**: All platforms build from the same GRBL source code

## Directory Structure

```
grbl/
├── platform/
│   ├── hal.h                      # Main HAL header (includes platform headers, #error guard)
│   ├── hal_gpio.h                 # GPIO abstraction
│   ├── hal_timer.h                # Timer abstraction
│   ├── CONTRACTS.md               # Per-macro contracts (24 sections)
│   ├── PORTING-CHECKLIST.md       # Ordered bring-up steps + exit tests
│   ├── PLAN.md                    # Live orchestration ledger (authoritative status)
│   ├── PLATFORM_ROADMAP.md        # Platform-facing overview, synced from PLAN.md
│   ├── _template/                 # Copy this to start a new port (PORT_TODO_* linker-as-checklist)
│   ├── common/                    # Shared helpers (gpio.h, dummy/, stm32/common.mk, ...)
│   ├── atmega328p/                # AVR reference (single flavor, golden-MD5 gated)
│   ├── stm32f103/, stm32h523/, stm32f411/  # ARM Cortex-M3/M33/M4F, share common/stm32/
│   ├── samd21/                    # ARM Cortex-M0+, boards/{megarm,generic} - only Renode-proven port
│   ├── ch32v006/                  # RISC-V rv32ec, first port built from _template + contracts alone
│   ├── hc32f460/                  # ARM Cortex-M4F, vendor-exotic, no donor IP reused
│   ├── dspic33ak128mc102/         # dsPIC33 DSC, third ISA family, not yet in CI
│   └── sg2002/                    # RISC-V C906L, NON-FUNCTIONAL, rewrite deferred by design
├── grbl.h                         # Main GRBL header (includes hal.h first)
├── main.c                         # GRBL main (original, unmodified)
├── stepper.c                      # Stepper motor control (original, unmodified)
├── serial.c                       # Serial communication (original, unmodified)
└── ...                            # Other GRBL source files (all original, unmodified)
```

## HAL Header Inclusion Order

The include order is critical for proper abstraction:

```c
// In grbl.h:
#include "hal.h"         // HAL FIRST
#include "config.h"
#include "nuts_bolts.h"
// ... other GRBL headers
```

```c
// In hal.h:
#if defined(PLATFORM_STM32F103)
  #include <stdint.h>
  // ... standard C libraries
  #define sei()  HAL_INTERRUPTS_ENABLE()  // AVR compatibility
  #define cli()  HAL_INTERRUPTS_DISABLE()
  #define __flash const
#else
  #include <avr/io.h>
  // ... AVR libraries
#endif

// Include platform-specific configuration
#if defined(PLATFORM_STM32F103)
  #include "platforms/stm32f103/platform.h"
#elif defined(PLATFORM_STM32H523)
  #include "platforms/stm32h523/platform.h"
#else
  #include "platforms/atmega328p/platform.h"
#endif

// Include HAL subsystem headers (GPIO, Timer, Serial, etc.)
#include "hal_gpio.h"
#include "hal_timer.h"
#include "hal_serial.h"
#include "hal_nvmem.h"
#include "hal_system.h"
```

## Build Prelude (non-AVR platforms)

Non-AVR platform Makefiles inject ONE header into every translation unit via
GCC's `-include` flag, before any of the file's own code:

- samd21: `-include $(BOARD)/prelude.h` (board-selectable: `megarm/`, `generic/`)
- ch32v006, dspic33ak128mc102, `_template`: `-include $(BOARD_DIR)/prelude.h`
  (board-selectable, same shape as samd21)
- stm32f103, stm32h523, stm32f411, sg2002: `-include prelude.h` (one prelude
  per port, no `boards/` subdir on any of the three STM32 ports)

(Updated 2026-07-26 — PLAN.md Phase 1 "roll prelude pattern" item: this list
was stale, missing stm32f411/ch32v006/dspic33ak128mc102/`_template`, which
had already landed the identical single-`-include` shape. Verified live: every
non-AVR platform Makefile has exactly one `-include .../prelude.h` and no
other `-include` flag — `grep -rn -- '-include' grbl/platform/*/Makefile`.)

The prelude defines `GRBL_PRELUDE` and, where the platform needs it (samd21),
chains the platform's GPIO register accessors, `common/gpio.h` helpers, the
board pin map and `platform.h` in a load-bearing order. `hal.h` fails with a
`#error` on any non-AVR compile that did not inject a prelude — building by
invoking the compiler manually (without the platform Makefile) is unsupported.
New `-include` needs go INTO the platform's prelude.h, never as additional
Makefile flags. Proven, not just asserted: temporarily dropping stm32f103's
`-include prelude.h` reproduces
`hal.h:50:4: error: "No build prelude injected - build via the platform
Makefile..."` on the very first TU; restoring the flag builds clean again
(PLAN.md Phase 1 ledger entry).

The AVR reference build is exempt, deliberately and permanently: the root
Makefile is golden-frozen (byte-for-byte MD5 gate) and its single
`-include grbl/platform/common/gpio.h` stays as-is — atmega328p's own
`platform.h` never gained a `prelude.h` and never will. This is not an
oversight; see the Decision Log entry "AVR prelude-canon exemption" in
PLAN.md for the full reasoning (single already-`-include`d header, zero
redefinition hazard on that port, and the golden-MD5 gate makes any
speculative refactor there strictly a liability with no payoff).

## Platform Selection

Platforms are selected via compiler flags:

```makefile
# AVR (default, no flag needed)
make

# STM32F103
make PLATFORM=STM32F103

# STM32H523
make PLATFORM=STM32H523
```

The Makefile adds `-DPLATFORM_<name>` to CFLAGS, which the HAL uses for conditional compilation.

## HAL Macro System

The HAL uses a two-level macro system:

### Level 1: Generic HAL Macros (in hal_*.h)

These are the macros that GRBL code uses:

```c
// From hal_gpio.h:
#define HAL_GPIO_SET_BITS(port, mask)
#define HAL_GPIO_CLEAR_BITS(port, mask)
#define HAL_GPIO_READ_PORT(port)

// From hal_timer.h:
#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)
#define HAL_TIMER_STEPPER_GET_COUNT()

// From hal_serial.h:
#define HAL_SERIAL_READ_DATA()
#define HAL_SERIAL_WRITE_DATA(data)
```

### Level 2: Platform-Specific Implementation (in platform.h)

Each platform's `platform.h` expands these macros to platform-specific code:

**AVR (zero overhead - direct register access):**
```c
#define HAL_GPIO_SET_BITS(port, mask)         ((port) |= (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)       ((port) &= ~(mask))
#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)  (OCR1A = (cycles))
```

**STM32 (direct register access):**
```c
#define HAL_GPIO_SET_BITS(port, mask)         ((port)->BSRR = (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)       ((port)->BSRR = ((uint32_t)(mask) << 16))
#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)  (TIM2->ARR = (cycles))
```

Both expand to zero-overhead inline operations!

## AVR Compatibility Macros

To avoid modifying original GRBL code, the HAL provides AVR compatibility macros for ARM platforms:

```c
#define sei()     HAL_INTERRUPTS_ENABLE()    // Enable interrupts
#define cli()     HAL_INTERRUPTS_DISABLE()   // Disable interrupts
#define __flash   const                      // Program memory (const on ARM)
```

## Port Mapping Example

Original GRBL code:
```c
// stepper.c (original, unmodified):
HAL_GPIO_SET_BITS(STEP_PORT, step_outbits);
```

AVR platform.h:
```c
#define STEP_PORT    PORTD
#define HAL_GPIO_SET_BITS(port, mask)  ((port) |= (mask))
// Expands to: PORTD |= step_outbits;  (original GRBL code!)
```

STM32 platform.h:
```c
#define STEP_PORT    GPIOA
#define HAL_GPIO_SET_BITS(port, mask)  ((port)->BSRR = (mask))
// Expands to: GPIOA->BSRR = step_outbits;  (STM32 atomic bit-set register)
```

## Pin Definitions

### AVR (cpu_map.h)

Original GRBL pin definitions remain in `cpu_map.h` (moved to `hal/platforms/atmega328p/cpu_map.h`):

```c
#define X_STEP_BIT    0
#define Y_STEP_BIT    1
#define Z_STEP_BIT    2
#define STEP_MASK     ((1<<X_STEP_BIT)|(1<<Y_STEP_BIT)|(1<<Z_STEP_BIT))
#define STEP_PORT     PORTD
```

### STM32 (platform.h)

STM32 platforms define equivalent macros with different values:

```c
// STM32 uses different pin numbering and GPIO ports
#define X_STEP_PIN    0   // PA0
#define Y_STEP_PIN    1   // PA1
#define Z_STEP_PIN    2   // PA2
#define STEP_MASK     ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))
#define STEP_PORT     GPIOA
```

## Interrupt Handling

### AVR (Original)

```c
// stepper.c:
ISR(TIMER1_COMPA_vect) {
  // Stepper ISR code
}
```

### HAL Approach

```c
// stepper.c (modified to use HAL macro):
HAL_TIMER_STEPPER_ISR() {
  // Stepper ISR code (same as original)
}
```

Platform definitions:

```c
// AVR platform.h:
#define HAL_TIMER_STEPPER_ISR()  ISR(TIMER1_COMPA_vect)

// STM32F103 platform.h:
#define HAL_TIMER_STEPPER_ISR()  void TIM2_IRQHandler(void)

// STM32H523 platform.h:
#define HAL_TIMER_STEPPER_ISR()  void TIM2_IRQHandler(void)
```

## NVMEM (Non-Volatile Memory)

### AVR: Hardware EEPROM

AVR has built-in EEPROM accessed via `eeprom_read_byte()` / `eeprom_write_byte()`.

### STM32: Flash Emulation

STM32 has no EEPROM, so we emulate it using Flash:

- **Reserve last 8KB of flash** for NVMEM
- **RAM cache** for fast reads
- **Dirty bit tracking** to minimize flash writes
- **Wear leveling** not implemented yet (future enhancement)

```c
// hal_nvmem.c (STM32):
#define NVMEM_FLASH_START  (FLASH_BASE + FLASH_SIZE - NVMEM_SIZE)
#define NVMEM_SIZE         8192  // 8KB

static uint8_t nvmem_cache[NVMEM_SIZE];
static bool nvmem_dirty = false;

uint8_t hal_nvmem_read_byte(uint16_t addr) {
  return nvmem_cache[addr];  // Read from RAM cache
}

void hal_nvmem_write_byte(uint16_t addr, uint8_t value) {
  nvmem_cache[addr] = value;
  nvmem_dirty = true;  // Mark for flush
}
```

## Clock Configuration

### AVR
- Fixed 16 MHz crystal
- No PLL configuration needed

### STM32F103
- 8 MHz HSE (external crystal)
- PLL × 9 = 72 MHz CPU clock
- APB1 = 36 MHz (CPU/2)
- APB2 = 72 MHz (CPU/1)

### STM32H523
- 8 MHz HSE (external crystal)
- PLL × 125 / 2 = 250 MHz CPU clock
- APB1/2/3 = 125 MHz (CPU/2)
- Flash latency = 5 wait states @ 250MHz

## Timer Configuration

### AVR (TIMER1 for stepper)
- 16-bit timer
- CTC mode (Clear Timer on Compare Match)
- Prescaler: 8
- Frequency: 16MHz / 8 = 2 MHz

### STM32F103 (TIM2 for stepper)
- 32-bit timer (more range!)
- Up-counting mode
- Prescaler: 0 (full speed)
- Frequency: 72 MHz

### STM32H523 (TIM2 for stepper)
- 32-bit timer
- Up-counting mode
- Prescaler: 0
- Frequency: 125 MHz (from APB1 × 2)

## Build System

### AVR
```makefile
PLATFORM_AVR_ATMEGA328P = atmega328p

MCU = atmega328p
F_CPU = 16000000UL

CC = avr-gcc
OBJCOPY = avr-objcopy
SIZE = avr-size

CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU)
```

### STM32 (Common)
```makefile
# common.mk (shared by all STM32 platforms)
TOOLCHAIN_PATH ?=
PREFIX = $(TOOLCHAIN_PATH)/arm-none-eabi-

CC = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size

CFLAGS = -mcpu=$(CPU) -mthumb -DPLATFORM_$(PLATFORM) -DF_CPU=$(F_CPU)
CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS = -Wl,--gc-sections  # Remove unused code

# Release build: optimize for size with LTO
ifdef RELEASE
  CFLAGS += -Os -flto
  LDFLAGS += -flto
endif
```

### STM32F103 Makefile
```makefile
CPU = cortex-m3
F_CPU = 72000000
PLATFORM = STM32F103

include ../stm32_common/common.mk
```

## Performance Comparison

| Operation | AVR @16MHz | STM32F103 @72MHz | STM32H523 @250MHz |
|-----------|------------|------------------|-------------------|
| Stepper ISR | ~15 µs | ~2 µs | ~0.6 µs |
| Max step rate | 30 kHz | 250 kHz | 800 kHz |
| Flash write | 2 ms | 50 µs | 100 µs (quad-word) |

## Memory Usage

RELEASE flash body (`text`+`data`), re-measured 2026-07-26 by fresh clean builds — see
`PLAN.md`'s canonical size table for how these are re-verified at every integration:

| Platform | Flash used (`text`+`data`) | Flash budget | RAM (`data`+`bss`) |
|---|---|---|---|
| AVR ATmega328P (golden) | 30640 B (30640+0) | 32KB (94%) | 1.6KB / 2KB |
| STM32F103 | 28780 B (28700+80) | 64KB (44%) | ~19.5KB / 20KB |
| STM32H523 | 25520 B (25132+388) | 128KB (19%) | ~10.4KB / 32KB |
| STM32F411 | 25876 B (25796+80) | 512KB (5%) | ~127KB / 128KB |
| SAMD21 (megarm) | 32248 B (31952+296) | 256KB (12.3%) | ~6.3KB / 32KB |
| CH32V006 | 41072 B (41072+0) | 61K usable (62K minus a 1K NVMEM window), per `script.ld` | ~2.7KB / 8KB |
| HC32F460 | 25676 B (25596+80) | 512KB (5%) | ~127KB / 128KB |
| dsPIC33AK128MC102 | ~41.8KB (approximate — see its platform.md) | 128KB (~33%) | ~3.8KB / 16KB |

Note on ch32v006: some older docs in this tree (`PLATFORM_ROADMAP.md`'s original entry) quote
"2KB RAM, 16KB Flash" — that was the CH32V003-class part first considered before the port
settled on a CH32V006-class part with 8KB RAM / 62KB flash (`ch32v006/script.ld`); the 41072-byte
RELEASE build above is measured against the real linker script, not the stale estimate.

Four ARM ports (STM32F103, STM32H523, STM32F411, HC32F460) are now smaller in flash body
(`text`+`data`) than the AVR reference build; only SAMD21 and CH32V006 are larger.

## Platforms in this tree today

Not "future" — these are built now (`grbl/platform/PLATFORM_ROADMAP.md` has full per-port detail):
STM32F411 (Cortex-M4F), SAMD21 (Cortex-M0+, Renode-proven), CH32V006 (RISC-V rv32ec), HC32F460
(Cortex-M4F, vendor-exotic), dsPIC33AK128MC102 (dsPIC33 DSC, third ISA family, not yet in CI).

## Future Platforms

### Potential (unscheduled, no directory exists)
- RP2040 / RP2350 (Raspberry Pi Pico, dual-core Cortex-M0+/M33)
- ESP32-C3 (RISC-V, WiFi)
- ATSAMC21E18A (Cortex-M0+ — see PLATFORM_ROADMAP.md, "not currently in PLAN.md's Phase 6 queue")
- STM32G4 (Cortex-M4F with advanced timer)
- CH570 (WCH RISC-V QingKe V3C) — recon done, unblocked, queued in PLAN.md but not started

## HAL Interface Guidelines

When adding a new platform:

1. **Create platform directory**: `grbl/platform/<name>/` (copy `_template/` as the starting point)
2. **Create platform.h**: Define all HAL macros for your platform
3. **Implement required functions**: clock init, GPIO, timers, serial, NVMEM
4. **Create Makefile**: Set CPU, F_CPU, linker script
5. **Test with original GRBL**: Compile original GRBL source unchanged
6. **Document**: Create platform.md with chip specs, boards, pinout

## Testing Strategy

1. **Compile test**: Ensure all platforms compile without errors
2. **Size test**: Verify flash/RAM usage within limits
3. **Functional test**: Run GRBL test suite on hardware
4. **Performance test**: Measure stepper ISR execution time
5. **Endurance test**: 24-hour continuous operation

## Known Issues

### STM32F103
- ✅ NVMEM flush timing needs optimization
- ✅ Limit switch debouncing may need adjustment

### STM32H523
- ⚠️  Quad-word flash writing more complex than F103
- ✅ EXTI register model changed (FPR1/RPR1 vs PR)

## References

- [Original GRBL](https://github.com/gnea/grbl)
- [AVR ATmega328P Datasheet](https://www.microchip.com/en-us/product/ATmega328P)
- [STM32F103 Reference Manual](https://www.st.com/resource/en/reference_manual/rm0008-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
- [STM32H523 Reference Manual](https://www.st.com/resource/en/reference_manual/rm0481-stm32h523533-and-stm32h562563573-armbased-32bit-mcus-stmicroelectronics.pdf)

---

**Version**: 1.1
**Last Updated**: 2026-07-26 (Directory Structure / Memory Usage / Future Platforms truth-updated
against fresh builds; see the staleness note at the top of this file — PLAN.md and
PLATFORM_ROADMAP.md remain authoritative over this file for current per-port status)
**Author**: kimstik (with AI assistance)
**License**: MIT
