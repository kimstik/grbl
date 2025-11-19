# GRBL HAL Platform Roadmap

**Date**: 2025-11-18
**Status**: Planning for future platform ports

This document outlines the planned platform ports and their implementation roadmaps.

---

## Current Platforms (100% Complete)

### STM32F103C8 (Blue Pill)
- **Status**: ✅ Production ready
- **Architecture**: ARM Cortex-M3, 72MHz
- **Memory**: 20KB RAM, 64KB Flash
- **Completion**: 100%
- **Code reuse**: ~60% via stm32_common

### STM32H523CBT6 (Black Pill H5)
- **Status**: ✅ Ready for testing
- **Architecture**: ARM Cortex-M33, 250MHz
- **Memory**: 32KB RAM, 128KB Flash
- **Completion**: 100%
- **Code reuse**: ~60% via stm32_common

---

## Planned Platforms

### 1. CH32V006 (RISC-V Microcontroller)
- **Priority**: HIGH
- **Architecture**: RISC-V RV32EC, 48MHz
- **Vendor**: WCH (Nanjing Qinheng Microelectronics)
- **Target board**: CH32V003F4P6 development board
- **Memory**: 2KB RAM, 16KB Flash
- **Unique features**:
  - First RISC-V port of GRBL
  - Ultra low-cost ($0.10 in volume)
  - 32-bit RISC-V core in 8-pin package
  - Built-in USB and UART bootloader
- **Challenges**:
  - RISC-V toolchain setup (riscv-none-elf-gcc)
  - Different interrupt model (ECLIC vs NVIC)
  - Very limited RAM (2KB) - requires careful memory optimization
  - No FPU (emulated floating point)
- **Estimated timeline**: 2-3 weeks
- **Estimated code size**: ~20KB (fits in 16KB with LTO optimization)
- **Target use case**: Ultra-low-cost CNC controllers, educational projects

### 2. HC32F460JETA (High-Performance ARM)
- **Priority**: MEDIUM
- **Architecture**: ARM Cortex-M4F, 200MHz
- **Vendor**: HDSC (Huada Semiconductor)
- **Target board**: Small System HC32F460 development board
- **Memory**: 192KB RAM, 512KB Flash
- **Unique features**:
  - High RAM (192KB) - largest of all current platforms
  - Hardware FPU (single precision)
  - Advanced motor control peripherals
  - CAN-FD support
  - 12-bit ADC with up to 24 channels
- **Challenges**:
  - Limited documentation (mostly Chinese)
  - Less common toolchain
  - Non-standard peripheral library
  - Register definitions not in CMSIS standard format
- **Estimated timeline**: 3-4 weeks
- **Estimated code size**: ~28KB
- **Target use case**: High-performance CNC, multi-axis systems, industrial applications

### 3. ATSAMC21E18A (Microchip ARM)
- **Priority**: MEDIUM
- **Architecture**: ARM Cortex-M0+, 48MHz
- **Vendor**: Microchip (formerly Atmel)
- **Target board**: SAM C21 Xplained Pro
- **Memory**: 32KB RAM, 256KB Flash
- **Unique features**:
  - 5V tolerant I/O pins
  - CAN-FD support
  - Hardware CRC and AES encryption
  - Configurable Custom Logic (CCL)
  - Event System for autonomous peripheral operation
- **Challenges**:
  - M0+ has limited instruction set (no division, no FPU)
  - Atmel/Microchip register naming conventions differ from STM32
  - SERCOM peripheral requires more complex configuration
  - Different clock system (GCLK, generic clock generators)
- **Estimated timeline**: 2-3 weeks
- **Estimated code size**: ~26KB (M0+ has good code density)
- **Target use case**: Automotive, industrial with 5V legacy peripherals

---

## Implementation Priority

1. **CH32V006** (RISC-V) - Highest priority for architecture diversity
2. **HC32F460JETA** (ARM M4F) - High performance applications
3. **ATSAMC21E18A** (ARM M0+) - 5V I/O and automotive applications

---

## Shared Code Reuse Strategy

Each new platform will follow the proven stm32_common pattern:

### Common Modules (platform-agnostic):
- `hal/common/timing_common.c` - DWT-based microsecond timing
- `hal/common/nvmem_common.c` - Flash-based EEPROM emulation
- `hal/common/watchdog_common.c` - Watchdog timer abstraction

### Platform-Specific Modules:
- `config.h` - Pin mappings, clock frequencies, peripheral assignments
- `platform.c` - HAL implementation (GPIO, interrupts, clocks)
- `regs.h` - Minimal register definitions
- `startup.c` - Vector table and reset handler
- `handlers.c` - Interrupt handlers
- `flash.c` - Flash programming for NVMEM
- `script.ld` - Linker script
- `Makefile` - Build configuration

### Expected Code Reuse:
- CH32V006: 40% (RISC-V architecture different)
- HC32F460: 50% (ARM but different vendor)
- ATSAMC21: 55% (ARM with similar peripherals)

---

## Next Steps

1. Create detailed platform plans for each target (see individual files)
2. Set up toolchains and development environments
3. Acquire hardware development boards
4. Implement platforms in priority order
5. Test on real hardware
6. Update REVIEW documents for each platform

---

**See detailed implementation plans:**
- [CH32V006_PLAN.md](ch32v006/CH32V006_PLAN.md)
- [HC32F460_PLAN.md](hc32f460/HC32F460_PLAN.md)
- [ATSAMC21_PLAN.md](atsamc21/ATSAMC21_PLAN.md)
