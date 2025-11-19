# SAMD21 Platform Implementation Plan

**Platform**: SAMD21G18A (Arduino Zero, MKR series)
**Vendor**: Microchip (formerly Atmel)
**Status**: 🚧 Work In Progress (WIP)
**Priority**: MEDIUM (Popular ARM Cortex-M0+ platform)

---

## 1. HARDWARE OVERVIEW

### Target MCU: SAMD21G18A
- **Architecture**: ARM Cortex-M0+
- **Frequency**: 48MHz (from DFLL48M or external crystal)
- **Flash**: 256KB
- **RAM**: 32KB SRAM
- **Package**: TQFP-48, QFN-48
- **Voltage**: 1.62V - 3.63V
- **Cost**: ~$2-3 USD in volume

### Key Features:
- ✅ Native USB device (USB 2.0 Full Speed)
- ✅ 6x SERCOM (configurable as UART/SPI/I2C)
- ✅ 3x 24-bit Timer/Counters (TC)
- ✅ 3x 24-bit Timer/Counters for Control (TCC) with PWM
- ✅ 12-bit ADC (20 channels, 350 ksps)
- ✅ 12-channel DMA controller
- ✅ 10-bit DAC
- ✅ 16 external interrupts
- ❌ No hardware FPU (software emulation only)
- ❌ No hardware EEPROM (use flash emulation)

### Development Boards:
- **Arduino Zero** - official Arduino board
- **Arduino MKR series** - compact form factor
- **Adafruit Feather M0** - Feather ecosystem
- **Seeeduino XIAO** - ultra-compact

### Programmers:
- **Native USB** - bootloader via USB (BOSSA)
- **CMSIS-DAP** - debugging via SWD
- **Atmel-ICE** - professional debugger
- **J-Link** - via SWD interface

---

## 2. GRBL FEASIBILITY ANALYSIS

### Memory Constraints:
- **Flash**: 256KB total
  - GRBL core: ~30KB (with optimizations)
  - HAL layer: ~5-10KB
  - NVMEM emulation: 4KB reserved
  - **Available**: ~210KB (plenty of space!)
  - **Status**: ✅ NO CONSTRAINTS

- **RAM**: 32KB total
  - GRBL core: ~5KB (buffers, state)
  - Stack: 4KB
  - **Available**: ~23KB (excellent!)
  - **Status**: ✅ NO CONSTRAINTS

### Performance:
- **Clock**: 48MHz (3x faster than AVR)
- **Timer Resolution**: ~20.8ns @ 48MHz
- **Expected Performance**: 2-3x AVR speed

---

## 3. CURRENT STATUS

### ✅ Completed (Phase 1)
- [x] Platform directory structure
- [x] Makefile with DEBUG/RELEASE modes
- [x] Unified build system integration
- [x] Pin mapping (platform.h)
- [x] Startup code (reset handler, vector table)
- [x] Linker script (256KB Flash, 32KB RAM)
- [x] Interrupt handlers structure
- [x] HAL function stubs (platform.c)
- [x] CMSIS stub headers (temporary)
- [x] Configuration files
- [x] AVR compatibility layer (__flash, DDR macros)

### 🚧 In Progress (Phase 2)
- [ ] Complete HAL GPIO implementation
- [ ] Fix HAL macro compatibility issues
- [ ] Timer/Counter configuration (TC3, TC4)
- [ ] SERCOM3 UART implementation
- [ ] Flash NVMEM emulation
- [ ] Clock configuration (DFLL48M setup)
- [ ] SysTick configuration
- [ ] External interrupts (EIC) for limits/controls

### ⏳ TODO (Phase 3)
- [ ] Replace CMSIS stubs with official headers
- [ ] TCC0 PWM for spindle control
- [ ] DMA optimization (optional)
- [ ] USB CDC serial (alternative to UART)
- [ ] Power management
- [ ] Comprehensive testing
- [ ] Documentation completion

---

## 4. IMPLEMENTATION ROADMAP

### Phase 1: Foundation ✅ DONE
**Goal**: Basic platform infrastructure
- [x] Build system
- [x] Startup code
- [x] Pin definitions
- [x] Stub implementations

**Status**: Complete, code compiles

### Phase 2: Core HAL 🚧 IN PROGRESS
**Goal**: Complete HAL implementation
**ETA**: 2-3 days

Tasks:
1. **GPIO** (Priority: HIGH)
   - Implement hal_gpio_set_pin()
   - Implement hal_gpio_clear_pin()
   - Implement hal_gpio_read_pin()
   - Implement hal_gpio_set_output()
   - Configure PORT registers

2. **Timers** (Priority: HIGH)
   - TC3: Stepper timer
   - TC4: Pulse reset timer
   - Configure prescalers
   - Setup interrupts

3. **UART** (Priority: HIGH)
   - SERCOM3 configuration
   - TX/RX buffers
   - Interrupt handlers
   - 115200 baud

4. **Clock** (Priority: MEDIUM)
   - GCLK configuration
   - DFLL48M setup
   - Peripheral clocks
   - SysTick for millis()

5. **NVMEM** (Priority: MEDIUM)
   - Flash page operations
   - Erase/write/read
   - NVM controller
   - 4KB reserved area

### Phase 3: Advanced Features ⏳ PLANNED
**Goal**: Complete platform capabilities
**ETA**: 1-2 weeks

Tasks:
1. **PWM** (Spindle)
   - TCC0 configuration
   - 16-bit resolution
   - Frequency control

2. **Interrupts**
   - EIC for limit switches
   - EIC for control pins
   - NVIC priorities

3. **DMA** (Optional)
   - UART TX/RX
   - Reduce CPU load

4. **USB CDC** (Optional)
   - Alternative serial
   - No UART needed
   - Native to board

### Phase 4: Testing & Documentation ⏳ PLANNED
**Goal**: Production ready
**ETA**: 1 week

Tasks:
- [ ] Unit tests for each HAL function
- [ ] Integration testing with GRBL
- [ ] Stepper timing verification
- [ ] Serial throughput testing
- [ ] NVMEM reliability testing
- [ ] Complete README.md
- [ ] Pin mapping diagrams
- [ ] Performance benchmarks

---

## 5. TECHNICAL CHALLENGES

### Challenge 1: No Hardware EEPROM
**Problem**: SAMD21 has no EEPROM, must emulate in Flash

**Solution**:
- Reserve last 4KB of Flash (0x0003F000 - 0x0003FFFF)
- Use page erase + program operations
- Implement wear leveling (optional)
- Expected writes: ~10,000 cycles minimum

**Status**: ⏳ Planned

### Challenge 2: CMSIS Dependencies
**Problem**: Need official Microchip headers for production

**Solution**:
- Phase 1: Use minimal stub headers (DONE)
- Phase 2: Integrate official CMSIS from Microchip Packs
- Phase 3: Test with official headers

**Status**: ✅ Stubs working, official integration planned

### Challenge 3: Clock Configuration
**Problem**: Complex clock tree (GCLK, DFLL48M, OSC8M)

**Solution**:
- Start with Arduino bootloader assumptions (48MHz ready)
- Implement full clock configuration later
- Document clock dependencies

**Status**: ⏳ Planned for Phase 2

### Challenge 4: USB vs UART
**Problem**: Boards may use USB or UART for serial

**Solution**:
- Phase 1: UART on SERCOM3 (universal)
- Phase 2: USB CDC as optional feature
- Makefile flag to select serial backend

**Status**: UART planned first

---

## 6. PIN MAPPING (Arduino Zero Compatible)

See `platform.h` for complete definitions:

### Stepper Signals:
- X/Y/Z Step: PA2, PA4, PA5
- X/Y/Z Dir: PA6, PA7, PA8
- Enable: PA9

### Limit Switches:
- X/Y/Z Limits: PA10, PA11, PB10

### Control:
- Reset, Feed Hold, Cycle Start, Safety Door

### Spindle:
- PWM: PA15 (TCC0/WO[5])
- Enable/Direction: PA16, PA17

### Coolant:
- Flood/Mist: PA18, PA19

### Serial:
- TX/RX: PA22/PA23 (SERCOM3)

---

## 7. BUILD SYSTEM

### Current Status: ✅ Working
- DEBUG/RELEASE modes
- Generates .elf, .hex, .bin, .dump
- Output to unified /build directory
- Naming: grbl_samd21.bin (release), grbl_samd21_dbg.bin (debug)

### Flash Methods:
1. **BOSSA** (Arduino bootloader)
   ```bash
   make flash-bossa
   ```

2. **OpenOCD** (SWD/CMSIS-DAP)
   ```bash
   make flash
   ```

---

## 8. MILESTONES

### M1: Foundation ✅ COMPLETE (2025-11-19)
- Platform structure
- Build system
- Stubs compiling

### M2: Core HAL ⏳ Target: 2025-11-22
- GPIO working
- Timers configured
- UART functional

### M3: Full HAL ⏳ Target: 2025-11-29
- All HAL functions
- NVMEM working
- Clock stable

### M4: Production ⏳ Target: 2025-12-06
- Testing complete
- Documentation done
- Ready for users

---

## 9. TESTING STRATEGY

### Unit Tests:
- GPIO: Toggle test, read test
- UART: Loopback test, throughput
- Timers: Frequency verification
- NVMEM: Write/read/erase cycles

### Integration Tests:
- Run GRBL test suite
- Stepper timing accuracy
- Serial command processing
- Limit switch response

### Boards for Testing:
- Arduino Zero (primary)
- Adafruit Feather M0 (secondary)
- Seeeduino XIAO (compact variant)

---

## 10. REFERENCES

- [SAMD21 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/SAM_D21_DA1_Family_DataSheet_DS40001882F.pdf)
- [SAMD21 Family Manual](https://ww1.microchip.com/downloads/en/DeviceDoc/SAM_D21_DA1_Family_Data%20Sheet_DS40001882E.pdf)
- [Arduino Zero Docs](https://docs.arduino.cc/hardware/zero/)
- [Atmel START](https://start.atmel.com/) - Code configurator
- [CMSIS Packs](https://developer.arm.com/tools-and-software/embedded/cmsis)

---

**Last Updated**: 2025-11-19
**Next Review**: 2025-11-22 (after Phase 2 completion)
