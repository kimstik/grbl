# GRBL for SAMD21G18A (Arduino Zero / MKR Series)

**Status**: 🚧 Work In Progress
**Completion**: ~40% (Foundation complete, HAL implementation in progress)

Hardware Abstraction Layer implementation for SAMD21G18A-based boards (Arduino Zero, MKR series, Adafruit Feather M0).

---

## Hardware Specifications

- **MCU:** SAMD21G18A
- **Core:** ARM Cortex-M0+ @ 48MHz
- **RAM:** 32KB SRAM
- **Flash:** 256KB
- **Bootloader:** rSamba (512 bytes) - https://github.com/kimstik/rSamba
- **FPU:** No (software emulation)
- **DIVAS:** ✅ Division and Square Root Accelerator (1-3 cycles)
- **DMA:** 12 channels
- **USB:** Native USB 2.0 Full Speed
- **Timers:** 3x TC (24-bit), 3x TCC (24-bit with PWM)
- **SERCOM:** 6x (configurable as UART/SPI/I2C)

---

## Current Implementation Status

### ✅ Complete
- [x] Build system (Makefile with DEBUG/RELEASE)
- [x] Startup code (reset handler, 44 IRQ vectors)
- [x] Linker script (256KB Flash, 32KB RAM, 4KB stack)
- [x] Pin mapping (complete, Arduino Zero compatible)
- [x] Platform configuration (platform.h, config.h)
- [x] Interrupt handler structure
- [x] HAL function stubs
- [x] CMSIS stub headers (temporary)
- [x] AVR compatibility layer

### 🚧 In Progress
- [ ] GPIO implementation (hal_gpio_*)
- [ ] Timer configuration (TC3, TC4)
- [ ] UART implementation (SERCOM3)
- [ ] Clock configuration (GCLK, DFLL48M)
- [ ] NVMEM flash emulation
- [ ] External interrupts (EIC)

### ⏳ Planned
- [ ] TCC0 PWM for spindle
- [ ] SysTick for timing
- [ ] USB CDC serial (optional)
- [ ] DMA optimization (optional)
- [ ] Official CMSIS integration
- [ ] Full testing and validation

---

## Pin Mapping (Arduino Zero Compatible)

### Stepper Motors
- **X Step:** PA2 (D0)
- **Y Step:** PA4 (D1)
- **Z Step:** PA5 (D2)
- **X Direction:** PA6 (D8)
- **Y Direction:** PA7 (D9)
- **Z Direction:** PA8 (D4)
- **Stepper Enable:** PA9 (D3) - active LOW

### Limit Switches
- **X Limit:** PA10 (D1/TX)
- **Y Limit:** PA11 (D0/RX)
- **Z Limit:** PB10 (MOSI)

**Note:** All limit switches use internal pull-ups

### Control Pins
- **Reset:** PB11 (SCK)
- **Feed Hold:** PA12 (D22)
- **Cycle Start:** PA13 (D38)
- **Safety Door:** PA14 (D2)

**Note:** All control pins use internal pull-ups

### Spindle Control
- **Spindle Enable:** PA16 (D11)
- **Spindle PWM:** PA15 (D5) - TCC0/WO[5], 16-bit
- **Spindle Direction:** PA17 (D13/LED)

### Coolant
- **Coolant Flood:** PA18 (D10)
- **Coolant Mist:** PA19 (D12)

### Serial Communication (SERCOM3)
- **TX:** PA22 (D0/TX)
- **RX:** PA23 (D1/RX)
- **Baud Rate:** 115200

### Probe
- **Probe:** PA20 (D6)

---

## Quick Start (When Complete)

### 1. Prerequisites

```bash
# Install ARM GCC toolchain
sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi

# Install BOSSA (for Arduino bootloader)
sudo apt-get install bossa-cli

# Or OpenOCD (for SWD debugging)
sudo apt-get install openocd
```

### 2. Build

```bash
cd grbl/platform/samd21

# DEBUG build (default)
make

# RELEASE build (optimized)
make BUILD=RELEASE

# Show help
make help
```

### 3. Flash

**Method 1: Using Arduino Bootloader (BOSSA)**
```bash
# Put board in bootloader mode (double-tap reset button)
make flash-bossa
```

**Method 2: Using SWD/CMSIS-DAP**
```bash
make flash
```

### 4. Connect

```bash
# Linux/macOS
screen /dev/ttyACM0 115200

# Or use any serial terminal
picocom -b 115200 /dev/ttyACM0
```

---

## Build Configurations

### DEBUG (Default)
- Compiler flags: `-O0 -g3`
- Full debug symbols
- No optimizations
- Use for: Development, debugging

```bash
make              # or make BUILD=DEBUG
```

### RELEASE (Production)
- Compiler flags: `-Os -g0`
- Link-time optimization (LTO)
- NDEBUG defined
- Use for: Production deployment

```bash
make BUILD=RELEASE
```

### Output Files

All artifacts go to `/build` directory:
```
/build/
├── grbl_samd21_dbg.elf      # DEBUG: ELF with symbols
├── grbl_samd21_dbg.hex      # DEBUG: Intel HEX
├── grbl_samd21_dbg.bin      # DEBUG: Raw binary
├── grbl_samd21_dbg.dump     # DEBUG: Disassembly
├── grbl_samd21_dbg.map      # DEBUG: Linker map
├── grbl_samd21.elf          # RELEASE: ELF
├── grbl_samd21.hex          # RELEASE: Intel HEX
├── grbl_samd21.bin          # RELEASE: Raw binary
├── grbl_samd21.dump         # RELEASE: Disassembly
└── grbl_samd21.map          # RELEASE: Linker map
```

Object files go to `/build/samd21/`

---

## Memory Layout

### Flash (256KB, 0x00000000 - 0x0003FFFF)
- **Bootloader:** 512 bytes (0x00000000 - 0x000001FF) - rSamba bootloader
- **Application:** 255.5KB (0x00000200 - 0x0003EFFF) - GRBL code
- **NVMEM:** 4KB (0x0003F000 - 0x0003FFFF) - Settings storage

**rSamba**: Ultra-compact 512-byte bootloader (https://github.com/kimstik/rSamba)
- Based on SAM-BA v2.18 (Microchip original)
- Implements "WwGVE" command subset
- Minimal footprint allows maximum application space

### RAM (32KB, 0x20000000 - 0x20007FFF)
- **Stack:** 4KB (grows downward from 0x20008000)
- **BSS/Data:** ~5KB
- **Heap:** Remaining (~23KB)

---

## NVMEM (Settings Storage)

SAMD21 has no hardware EEPROM. GRBL settings are stored in Flash:

- **Location:** Last 4KB of Flash (0x0003F000 - 0x0003FFFF)
- **Page Size:** 64 bytes (SAMD21 flash page)
- **Operations:** Erase page + program
- **Endurance:** ~10,000 write cycles minimum
- **Implementation:** Flash emulation layer

**Note:** Flash writes are slower than EEPROM, but sufficient for GRBL settings

---

## Supported Boards

### Tested:
- ⏳ Arduino Zero (primary target)

### Should Work:
- Arduino MKR series (MKR1000, MKR Zero, etc.)
- Adafruit Feather M0 / M0 Express
- Seeeduino XIAO (SAMD21G18 variant)
- SparkFun SAMD21 boards

**Note:** Pin mapping may need adjustment for non-Zero boards

---

## Hardware Accelerators

### DIVAS - Division and Square Root Accelerator
SAMD21 includes a hardware accelerator that compensates for Cortex-M0+ lack of hardware division:

- **Operations**: 32-bit signed/unsigned division, modulo, square root
- **Performance**: 1-3 cycles (vs 20+ cycles software division)
- **Usage**: Transparent to compiler with proper flags
- **Benefit**: Faster motion calculations, trajectory planning

**Note**: GCC can automatically use DIVAS with `-mcpu=cortex-m0plus` and proper CMSIS definitions.

---

## Timing Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| CPU Clock | 48 MHz | From DFLL48M |
| Timer Resolution | ~20.8 ns | @ 48MHz |
| Division (DIVAS) | 1-3 cycles | Hardware accelerator |
| Stepper ISR | TC3 (24-bit) | Planned |
| Pulse Reset | TC4 (24-bit) | Planned |
| PWM (Spindle) | TCC0 (16-bit) | Up to 65535 levels |
| PWM Frequency | Configurable | Default: 5 kHz |

---

## Development Plan

See [SAMD21_PLAN.md](SAMD21_PLAN.md) for detailed implementation roadmap.

**Current Phase:** Phase 2 - Core HAL Implementation
**Next Milestone:** GPIO + Timers + UART functional
**ETA for Phase 2:** 2025-11-22

---

## Known Limitations

### Current WIP Status:
- ⚠️ **Not yet functional** - HAL implementation incomplete
- ⚠️ Code compiles but untested on hardware
- ⚠️ Using temporary CMSIS stub headers
- ⚠️ GPIO operations not implemented
- ⚠️ Timers not configured
- ⚠️ UART not functional

### Planned Limitations:
- No hardware FPU (software floating-point)
- Flash NVMEM slower than EEPROM
- Some boards require pin mapping changes

---

## Files

```
grbl/platform/samd21/
├── Makefile                # Build system (DEBUG/RELEASE)
├── README.md               # This file
├── SAMD21_PLAN.md          # Implementation plan & roadmap
├── platform.h              # HAL interface, pin definitions
├── platform.c              # HAL implementation (WIP)
├── config.h                # Platform configuration
├── startup.c               # Startup code, vector table
├── handlers.c              # Interrupt handlers (TC3, TC4, SERCOM3, EIC)
├── script.ld               # Linker script (256KB/32KB)
├── samd21.h                # SAMD21 stub header (temporary)
└── core_cm0plus.h          # Cortex-M0+ stub header (temporary)
```

---

## Contributing

This platform is under active development. Contributions welcome!

**Areas needing help:**
- [ ] GPIO implementation
- [ ] Timer configuration
- [ ] UART/SERCOM3 setup
- [ ] Clock tree configuration
- [ ] Flash NVMEM implementation
- [ ] Testing on real hardware
- [ ] Pin mapping for other SAMD21 boards

---

## References

- [SAMD21 Datasheet (PDF)](https://ww1.microchip.com/downloads/en/DeviceDoc/SAM_D21_DA1_Family_DataSheet_DS40001882F.pdf)
- [SAMD21 Reference Manual (PDF)](https://ww1.microchip.com/downloads/en/DeviceDoc/SAM_D21_DA1_Family_Data%20Sheet_DS40001882E.pdf)
- [Arduino Zero Documentation](https://docs.arduino.cc/hardware/zero/)
- [GRBL Wiki](https://github.com/grbl/grbl/wiki)
- [Atmel START](https://start.atmel.com/) - Configuration tool

---

## License

See main GRBL license.

---

**Status**: Work In Progress 🚧
**Last Updated**: 2025-11-19
**Next Review**: 2025-11-22 (after HAL implementation)
