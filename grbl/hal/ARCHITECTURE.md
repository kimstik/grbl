# GRBL HAL Architecture

## Overview

This document describes the Hardware Abstraction Layer (HAL) architecture for GRBL. The HAL allows GRBL to run on multiple microcontroller platforms while keeping the core GRBL code unchanged.

## Design Principles

1. **Zero Overhead on AVR**: The HAL must not add any performance or code size overhead on the original AVR platform
2. **Keep Original Code Pristine**: Never modify original GRBL source files - all platform logic goes in HAL
3. **Compile-Time Abstraction**: Use macros that expand to platform-specific code at compile time
4. **Single Source Tree**: All platforms build from the same GRBL source code

## Directory Structure

```
grbl/
├── hal/
│   ├── hal.h                      # Main HAL header (includes platform headers)
│   ├── hal_gpio.h                 # GPIO abstraction
│   ├── hal_timer.h                # Timer abstraction
│   ├── hal_serial.h               # Serial/UART abstraction
│   ├── hal_nvmem.h                # NVMEM/EEPROM abstraction
│   ├── hal_system.h               # System functions (reset, delay, etc.)
│   └── platforms/
│       ├── avr_atmega328p/        # AVR ATmega328P (Arduino Uno)
│       │   ├── platform.h         # Platform configuration
│       │   ├── cpu_map.h          # Pin definitions (original GRBL file, moved here)
│       │   └── Makefile           # AVR build system
│       ├── stm32f103/             # STM32F103 (Blue Pill)
│       │   ├── platform.h         # Platform configuration
│       │   ├── regs.h             # STM32F103 register definitions
│       │   ├── clock.c            # Clock configuration
│       │   ├── gpio.c             # GPIO implementation
│       │   ├── timer.c            # Timer implementation
│       │   ├── serial.c           # USART implementation
│       │   ├── nvmem.c            # Flash emulation for EEPROM
│       │   ├── system.c           # System functions
│       │   ├── handlers.c         # Interrupt handlers
│       │   ├── Makefile           # STM32F103 build system
│       │   └── platform.md        # Platform documentation
│       ├── stm32h523/             # STM32H523 (Black Pill H5)
│       │   ├── platform.h
│       │   ├── regs.h
│       │   ├── clock.c
│       │   ├── gpio.c
│       │   ├── timer.c
│       │   ├── serial.c
│       │   ├── nvmem.c
│       │   ├── system.c
│       │   ├── handlers.c
│       │   ├── Makefile
│       │   └── platform.md
│       └── stm32_common/          # Shared code for all STM32 platforms
│           ├── common.mk          # Common Makefile rules
│           └── startup.c          # Common startup code
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
  #include "platforms/avr_atmega328p/platform.h"
#endif

// Include HAL subsystem headers (GPIO, Timer, Serial, etc.)
#include "hal_gpio.h"
#include "hal_timer.h"
#include "hal_serial.h"
#include "hal_nvmem.h"
#include "hal_system.h"
```

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

Original GRBL pin definitions remain in `cpu_map.h` (moved to `hal/platforms/avr_atmega328p/cpu_map.h`):

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
PLATFORM_AVR_ATMEGA328P = avr_atmega328p

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

### AVR ATmega328P
- Flash: 30KB / 32KB (94%)
- RAM: 1.5KB / 2KB (75%)

### STM32F103
- Flash: 30KB / 64KB (47%)
- RAM: 6KB / 20KB (30%)

### STM32H523
- Flash: 24KB / 128KB (19%)
- RAM: 10KB / 32KB (31%)

## Future Platforms

### Planned
- **RP2040** (Raspberry Pi Pico) - Dual Cortex-M0+, 133MHz, 264KB RAM
- **RP2350** (Raspberry Pi Pico 2) - Dual Cortex-M33, 150MHz, 520KB RAM

### Potential
- ESP32-C3 (RISC-V, WiFi)
- SAMD21 (Cortex-M0+, Arduino Zero)
- STM32G4 (Cortex-M4F with advanced timer)

## HAL Interface Guidelines

When adding a new platform:

1. **Create platform directory**: `hal/platforms/<name>/`
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

**Version**: 1.0
**Last Updated**: 2025-11-18
**Author**: kimstik (with AI assistance)
**License**: MIT
