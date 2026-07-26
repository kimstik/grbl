# GRBL for SAMD21G18A (Arduino Zero / MKR Series)

**Status**: Builds clean (DEBUG + RELEASE, both `megarm` and `generic`
boards), zero `PORT_TODO_*`, boot-integrity and `FP=SINGLE` assert both
PASSED. **This is the only port in this tree with ANY runtime evidence**:
a Renode-emulated boot smoke test (banner, `$$` settings dump, EEPROM
restore) and a Renode motion smoke test (`G2` arc interpolation - the only
core path touching atan2/sqrt/cos/sin - with real STEP-pin toggling on
PA25, MPos tracked correctly through the arc, no phantom motion). **Still
never run on real physical hardware** - like every other port in this tree,
zero exceptions - so treat this as "ready for hardware validation" per
PORTING-CHECKLIST.md's definition of done, not as a field-tested board.
**Completion**: 100% (Steps 0-6 of PORTING-CHECKLIST.md); 0% physical-hardware-validated

Hardware Abstraction Layer implementation for SAMD21G18A-based boards (Arduino Zero, MKR series, Adafruit Feather M0). The two boards actually built and Renode-tested in this tree are `megarm` (MegARM, Arduino Mega pin-compatible) and `generic` - see `megarm/README.md` and `generic/README.md`. Arduino Zero/MKR/Feather M0 pin mappings below are this port's original target reference and have not been individually built/tested as boards.

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

### ✅ Complete (builds clean, zero `PORT_TODO_*`, Renode-verified)
- [x] Build system (Makefile with DEBUG/RELEASE, BOARD=megarm/generic)
- [x] Startup code (reset handler, IRQ vectors, VTOR fix)
- [x] Linker script (256KB Flash, 32KB RAM, 4KB stack)
- [x] Pin mapping (megarm + generic boards; Arduino Zero mapping below is
      the original reference, not independently board-tested)
- [x] Platform configuration (platform.h, config.h)
- [x] GPIO implementation (hal_gpio_*) - real PORT register access
- [x] Timer configuration (TC3 stepper ISR, TC4 pulse-reset) - Renode-proven
      via the `G2` arc motion smoke test (STEP pin PA25 toggled 150+ times)
- [x] UART implementation (SERCOM3) - Renode-proven via `$$` dump over RXC
      interrupt + realtime character interception (`?`/`!`/`~`/ctrl-X)
- [x] Clock configuration (GCLK, DFLL48M)
- [x] NVMEM flash emulation - Renode-proven via blank-EEPROM recovery +
      `settings_restore` at boot
- [x] External interrupts (EIC) for limits/control pins
- [x] TCC0 PWM for spindle
- [x] AVR compatibility layer

### Known gaps (not build blockers)
- [ ] Official CMSIS integration (uses clean-room stub headers,
      `core_cm0plus.h`/`samd21.h`, since Atmel/ASF's real headers are
      proprietary)
- [ ] USB CDC serial (optional; SERCOM3 UART is the tested path)
- [ ] DMA optimization (optional)
- [ ] Real physical hardware validation - never run on physical silicon;
      Renode is the only execution evidence, for this port or any other in
      this tree

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
- **Spindle PWM:** PA15 (D5) - TCC0/WO[5], configured for 8-bit duty: `TCC0->PER = 0xFF`
  (samd21/timer.h:109), matching `SPINDLE_PWM_MAX_VALUE=255` — the core plumbs spindle duty as
  `uint8_t` end-to-end (CONTRACTS.md #6.2), so `PER` is fixed at 255 regardless of what wider
  counting modes the TCC peripheral itself may support
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

## Quick Start

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

### Build + Renode smoke-tested (boot and motion, both DEBUG/RELEASE):
- **megarm** (MegARM, ATSAMC21E18A-MZ, Arduino Mega pin-compatible) -
  `make BOARD=megarm`
- **generic** - `make BOARD=generic`

### Should Work (untested pin-mapping guesses, not built as boards here):
- Arduino Zero (this README's original primary target)
- Arduino MKR series (MKR1000, MKR Zero, etc.)
- Adafruit Feather M0 / M0 Express
- Seeeduino XIAO (SAMD21G18 variant)
- SparkFun SAMD21 boards

**Note:** No board, including megarm/generic, has been run on real physical
hardware - Renode emulation is the only execution evidence that exists.
Pin mapping may need adjustment for non-tested boards.

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
| Stepper ISR | TC3 (24-bit) | Implemented, Renode-proven |
| Pulse Reset | TC4 (24-bit) | Implemented, Renode-proven |
| PWM (Spindle) | TCC0, `PER=0xFF` | 256 levels (0-255), matching `SPINDLE_PWM_MAX_VALUE=255` (CONTRACTS.md #6.2; BUG #22, 2026-07-26 — was incorrectly declared 65535 against this same 255-level hardware, see PLAN.md/CONTRACTS.md) |
| PWM Frequency | Configurable | Default: 5 kHz |

---

## Development Plan

See [SAMD21_PLAN.md](SAMD21_PLAN.md) for the detailed implementation history
(note: that file's own header status line is stale/pre-dates the work
described here).

**Current Phase:** Complete - builds clean, zero `PORT_TODO_*`, Renode boot
and motion smoke tests both PASSED (2026-07-23 through 2026-07-25).
**Remaining milestone:** Real physical hardware validation (community/owner
item, not yet done for this or any port in this tree).

---

## Known Limitations

### Current Status:
- ⚠️ **Never run on real physical hardware** - Renode emulation (boot +
  motion) is the only execution evidence that exists, for this port or any
  other port in this tree
- ⚠️ Using clean-room CMSIS stub headers (not vendor Atmel/ASF headers -
  those are proprietary)
- ⚠️ Non-megarm/generic boards (Arduino Zero, MKR, Feather M0, etc.) are
  untested pin-mapping guesses, not built/verified boards

### Planned Limitations:
- No hardware FPU (software floating-point); `FP=SINGLE` assert PASSED
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
├── platform.c              # HAL implementation (complete)
├── config.h                # Platform configuration
├── startup.c               # Startup code, vector table
├── handlers.c              # Interrupt handlers (TC3, TC4, SERCOM3, EIC)
├── script.ld               # Linker script (256KB/32KB)
├── samd21.h                # SAMD21 stub header (temporary)
└── core_cm0plus.h          # Cortex-M0+ stub header (temporary)
```

---

## Contributing

Core HAL work (GPIO, timers, UART/SERCOM3, clock tree, flash NVMEM) is done
and Renode-verified. Contributions welcome on what's left!

**Areas needing help:**
- [ ] Testing on real physical hardware (never done for this or any port in
      this tree)
- [ ] Pin mapping / board files for SAMD21 boards other than megarm/generic
- [ ] Official CMSIS integration (replacing the clean-room stub headers)
- [ ] USB CDC serial (optional)

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

**Status**: Builds clean (DEBUG + RELEASE, megarm + generic), zero
`PORT_TODO_*`. Only port in this tree with runtime (Renode) evidence: boot
and motion smoke tests both PASSED. Never run on real physical hardware.
**Last Updated**: 2026-07-26 (audit correction; prior revision was stale and
described this port as ~40% complete/non-functional)
