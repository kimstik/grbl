# STM32F103 Platform Documentation

**Status**: Builds clean (DEBUG + RELEASE), zero `PORT_TODO_*`, boot-integrity
and `FP=SINGLE` assert both PASSED. **Never run on real hardware** - "ready
for hardware validation" per PORTING-CHECKLIST.md's definition of done, not
"production ready" in an unqualified sense.
**Completion**: 100% (build/link/contract gates); 0% hardware-validated
**Last Updated**: 2025-11-18

---

## Platform Overview

### Microcontroller: STM32F103C8T6
- **Manufacturer**: STMicroelectronics
- **Architecture**: ARM Cortex-M3
- **CPU Frequency**: 72 MHz
- **Flash Memory**: 64 KB (128 KB on some variants)
- **SRAM**: 20 KB
- **Package**: LQFP48
- **Operating Voltage**: 2.0V - 3.6V
- **Temperature Range**: -40°C to +85°C (industrial)

### Key Features
- ✅ 37 GPIO pins (48-pin package)
- ✅ 3x USART, 2x SPI, 2x I2C
- ✅ 7x Timers (3x 16-bit, 1x PWM, 2x watchdog, 1x SysTick)
- ✅ 2x 12-bit ADC (16 channels)
- ✅ 2x 12-bit DAC
- ✅ USB 2.0 full-speed
- ✅ CAN 2.0B
- ❌ No hardware FPU
- ❌ No DMA for all peripherals

---

## Official Documentation

### Datasheets & Reference Manuals (PDF)

**Datasheet**:
- [STM32F103x8/B Datasheet (DS5319)](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
  - 117 pages, complete electrical specifications
  - Pin descriptions, memory map, electrical characteristics

**Reference Manual**:
- [STM32F10xxx Reference Manual (RM0008)](https://www.st.com/resource/en/reference_manual/rm0008-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
  - 1134 pages, complete peripheral descriptions
  - Register definitions, timing diagrams, usage examples

**Programming Manual**:
- [STM32 Cortex-M3 Programming Manual (PM0056)](https://www.st.com/resource/en/programming_manual/pm0056-stm32f10xxx20xxx21xxxl1xxxx-cortexm3-programming-manual-stmicroelectronics.pdf)
  - ARM Cortex-M3 processor core details
  - Instruction set, exception model, debug features

**Flash Programming**:
- [STM32 Flash Programming Manual (PM0075)](https://www.st.com/resource/en/programming_manual/pm0075-stm32f10xxx-flash-memory-microcontrollers-stmicroelectronics.pdf)
  - Flash memory organization and programming
  - EEPROM emulation techniques

**Errata Sheet**:
- [STM32F103x8/B Errata (ES093)](https://www.st.com/resource/en/errata_sheet/es093-stm32f101x8-b-stm32f102x8-b-and-stm32f103x8-b-mediumdensity-device-limitations-stmicroelectronics.pdf)
  - Known silicon bugs and workarounds

---

## Development Boards

### 1. Blue Pill (Most Popular)
- **Board Name**: STM32F103C8T6 "Blue Pill"
- **Price**: $2-5 USD
- **Availability**: AliExpress, eBay, Amazon
- **Features**:
  - Minimal design, maximum GPIO access
  - LED on PC13
  - Boot0 jumper for programming
  - Crystal oscillator: 8 MHz HSE, 32.768 kHz LSE
- **Search Terms**: "Blue Pill STM32F103C8T6"
- **Link**: [AliExpress Search](https://www.aliexpress.com/w/wholesale-stm32f103c8t6.html)
- **⚠️ Warning**: Some boards have counterfeit chips with only 64KB flash instead of advertised 128KB

### 2. ST Nucleo-F103RB (Official)
- **Board Name**: NUCLEO-F103RB
- **Price**: $12-15 USD
- **Manufacturer**: STMicroelectronics
- **Features**:
  - Official ST development board
  - Integrated ST-LINK/V2-1 debugger/programmer
  - Arduino Uno R3 compatible headers
  - Morpho extension headers (all pins accessible)
  - Guaranteed genuine STM32 chip
- **Link**: [ST Official Store](https://www.st.com/en/evaluation-tools/nucleo-f103rb.html)
- **Buy**: [Mouser](https://www.mouser.com/ProductDetail/STMicroelectronics/NUCLEO-F103RB), [DigiKey](https://www.digikey.com/en/products/detail/stmicroelectronics/NUCLEO-F103RB/4695525)

### 3. MiniF103 (Compact)
- **Board Name**: STM32F103C8T6 MiniF103
- **Price**: $3-6 USD
- **Features**:
  - Ultra-compact design (breadboard friendly)
  - USB-C connector (some versions)
  - LDO voltage regulator
- **Search Terms**: "MiniF103 STM32"

### 4. WeAct Studio Black Pill (Improved Blue Pill)
- **Board Name**: Black Pill STM32F103C8T6
- **Price**: $4-7 USD
- **Features**:
  - Better quality PCB than Blue Pill
  - USB-C connector
  - Proper reset circuit
  - ESD protection
- **Link**: [WeAct Studio Official](https://github.com/WeActTC/MiniSTM32F4x1)

---

## Programmers & Debuggers

### 1. ST-LINK/V2 (Recommended)
- **Type**: SWD programmer/debugger
- **Price**: $2-10 USD (clone), $25 USD (original)
- **Features**: Full debugging support, SWD and JTAG
- **Link**: [AliExpress clones](https://www.aliexpress.com/w/wholesale-st-link-v2.html)

### 2. USB-UART Adapter (Basic Programming)
- **Type**: Serial bootloader (UART1)
- **Price**: $1-3 USD
- **Features**: Programming only (no debugging)
- **Requires**: Boot0 jumper set to HIGH, then RESET
- **Tool**: `stm32flash` utility

### 3. Black Magic Probe (Advanced)
- **Type**: Open-source GDB server debugger
- **Price**: $60 USD (official), $15 USD (DIY)
- **Features**: Best debugging experience, no additional software
- **Link**: [Black Magic Probe](https://black-magic.org/)

---

## Software Tools

### Toolchain
- **GCC ARM**: [ARM GNU Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
- **OpenOCD**: [OpenOCD GitHub](https://github.com/openocd-org/openocd)

### Programming Tools
- **stm32flash** (UART bootloader): https://sourceforge.net/projects/stm32flash/
- **ST-LINK Utility** (Windows): [ST Official](https://www.st.com/en/development-tools/stsw-link004.html)
- **STM32CubeProgrammer** (Cross-platform): [ST Official](https://www.st.com/en/development-tools/stm32cubeprog.html)

### IDEs (Optional)
- **STM32CubeIDE** (Eclipse-based, free): [ST Official](https://www.st.com/en/development-tools/stm32cubeide.html)
- **PlatformIO**: https://platformio.org/
- **Arduino IDE** (with STM32 core): [Arduino STM32](https://github.com/stm32duino/Arduino_Core_STM32)

---

## Community Resources

### Forums & Support
- **ST Community**: https://community.st.com/
- **STM32duino Forum**: https://www.stm32duino.com/
- **r/stm32** (Reddit): https://www.reddit.com/r/stm32/
- **EEVblog Forum**: https://www.eevblog.com/forum/microcontrollers/

### Tutorials & Examples
- **STM32 Tutorial Series**: https://vivonomicon.com/category/stm32/
- **STM32F103 Examples**: https://github.com/LibOpenCM3/libopencm3-examples
- **Blue Pill Wiki**: https://stm32-base.org/boards/STM32F103C8T6-Blue-Pill.html

### Libraries
- **libopencm3** (Lightweight HAL): https://github.com/libopencm3/libopencm3
- **STM32 HAL** (Official): https://github.com/STMicroelectronics/STM32CubeF1
- **CMSIS**: https://github.com/ARM-software/CMSIS_5

---

## Pin Mapping for GRBL

See `config.h` for complete pin definitions. Default mapping:

| Function | Pin | Notes |
|----------|-----|-------|
| X_STEP | PA0 | Stepper X step pulse |
| Y_STEP | PA1 | Stepper Y step pulse |
| Z_STEP | PA2 | Stepper Z step pulse |
| X_DIR | PA3 | Stepper X direction |
| Y_DIR | PA4 | Stepper Y direction |
| Z_DIR | PA5 | Stepper Z direction |
| STEPPER_DISABLE | PA6 | Active LOW |
| X_LIMIT | PB0 | With pull-up |
| Y_LIMIT | PB1 | With pull-up |
| Z_LIMIT | PB10 | With pull-up |
| SPINDLE_PWM | PA8 | TIM1 CH1 |
| SPINDLE_ENABLE | PB7 | Active HIGH |
| SERIAL_TX | PA9 | USART1 TX |
| SERIAL_RX | PA10 | USART1 RX |

---

## Memory Layout

```
Flash (64KB):
  0x08000000 - 0x0800FFFF   Code and data (56KB)
  0x08010000 - 0x0800FFFF   Reserved (8KB)

SRAM (20KB):
  0x20000000 - 0x20004FFF   Data and stack

Peripherals:
  0x40000000 - 0x5FFFFFFF   APB1, APB2, AHB peripherals
  0xE000E000 - 0xE000EFFF   Cortex-M3 private peripherals
```

---

## Known Issues

1. **Counterfeit Chips**: Many "Blue Pill" boards contain counterfeit chips
   - **Workaround**: Buy from reputable sellers, test flash size
   - **Test**: Try to erase/program full 128KB

2. **8MHz Crystal Tolerance**: Some boards have low-quality crystals
   - **Impact**: USB may not work reliably
   - **Workaround**: Replace crystal or use HSI for USB

3. **USB Pull-up Resistor**: Some boards missing/wrong value on PA12
   - **Impact**: USB not detected by host
   - **Workaround**: Add 1.5kΩ resistor from PA12 to 3.3V

4. **Bootloader UART**: Boot0 must be HIGH to enter bootloader mode
   - **Procedure**: Set Boot0=HIGH → Reset → Flash → Boot0=LOW → Reset

---

## GRBL Build Statistics

Verified this session (fresh build, both flavors):
- DEBUG: .text 43,120 bytes, .data 80 bytes
- RELEASE (with LTO): .text 28,700 bytes (44% of 64KB), .data 80 bytes
- Free flash (RELEASE): ~35.8KB (56%)

**Optimization Level**: `-Os -flto`

---


---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `config.h`

config.h - STM32F103 platform configuration

Defines all STM32F103-specific parameters for the common code.

## `flash.c`

flash.c - STM32F1 flash programming implementation

Flash controller for STM32F1 family (F103, F105, F107).

## `gpio.h`

gpio.h - STM32F103 GPIO register accessors and macro overrides

Injected by prelude.h BEFORE platform/common/gpio.h: that file only
supplies AVR-style defaults for accessors/macros that are not already
defined (all of its definitions are #ifndef-guarded), so everything
here wins by coming first.
Composition contract (platform/CONTRACTS.md section 1): core code calls
GPIO_*(NAME) macros; NAME##_PORT / NAME##_BIT / NAME##_MASK come from the
pin map in platform.h (NAME##_PORT is a GPIO_TypeDef*).

## `handlers.c`

handlers.c - STM32F103 interrupt vector wrappers

Real IRQ vectors for the timers (TIM2/TIM3) and external interrupts
(EXTI, limit switches + control pins). Each wrapper clears the peripheral
interrupt flag FIRST, then calls the core-supplied ISR body - clearing
after would lose edges/updates that arrive during the body, and for
ISR_STEP_RESET specifically would ghost the final overflow after the
timer is stopped (CONTRACTS.md sections 2.3 and 5.1).

## `platform.c`

platform.c - STM32F103 platform implementation

STM32F103 (Blue Pill) implementation of HAL functions.
ARM Cortex-M3, 72 MHz, 20KB RAM, 64-128KB Flash

## `platform.h`

platform.h - STM32F103 platform configuration

This file provides platform-specific definitions for STM32F103 (Blue Pill).
ARM Cortex-M3, 72 MHz, 20KB RAM, 64-128KB Flash

## `regs.h`

regs.h - STM32F103 register definitions

Minimal register definitions for STM32F103C8T6 to avoid CMSIS dependency.
Includes only registers needed for GRBL operation.

## `startup.c`

startup.c - Startup code for STM32F103

Interrupt vector table and reset handler for STM32F103C8T6.
