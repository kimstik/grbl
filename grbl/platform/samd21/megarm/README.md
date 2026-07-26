# MegARM Board Configuration

## Board Information

- **Name**: MegARM
- **MCU**: ATSAMC21E18A-MZ
- **Architecture**: ARM Cortex-M0+ @ 48MHz
- **Memory**: 32KB RAM, 256KB Flash
- **Description**: Arduino Mega pin-compatible replacement board
- **Reference**: https://github.com/kimstik/MegARM

## Pin Mapping

MegARM uses ATmega328P-compatible pinout for GRBL:

### Stepper Control
- **Step Pins**: D2 (PA25), D3 (PA27), D4 (PA28)
- **Direction Pins**: D5 (PA0), D6 (PA1), D7 (PA2)
- **Enable Pin**: B0 (PA3)

### Limit Switches
- **X-Limit**: B1 (PA4)
- **Y-Limit**: B2 (PA5)
- **Z-Limit**: B4 (PA7)

### Control
- **Reset**: C0 (PA14)
- **Feed Hold**: C1 (PA15)
- **Cycle Start**: C2 (PA16)

### Spindle
- **PWM**: B3 (PA6) - TCC0/WO[0]
- **Direction**: B5 (PA8)

### Coolant
- **Flood**: C3 (PA17)
- **Mist**: C4 (PA18)

### Probe
- **Probe Pin**: C5 (PA19)

### Serial
- **RX**: D0 (PA23) - SERCOM3 PAD[1]
- **TX**: D1 (PA24) - SERCOM3 PAD[2]

## Building

Build for MegARM board (default):
```bash
cd grbl/platform/samd21
make BOARD=megarm
```

## Programming

Using OpenOCD:
```bash
make flash
```

Using Arduino IDE bootloader (rSamba):
```bash
# Upload via USB bootloader
bossac -e -w -v -R --offset=0x200 build/grbl_samd21.bin
```

## Features

- **rSamba Bootloader**: Ultra-compact 512-byte bootloader at 0x00000000
- **Application Start**: 0x00000200 (512 bytes offset)
- **DIVAS Accelerator**: Hardware division and square root (1-3 cycles)
- **TCC0 PWM**: 8-bit PWM for spindle control (`PER=0xFF`, `SPINDLE_PWM_MAX_VALUE=255` — CONTRACTS.md #6.2, BUG #22)
- **SERCOM Flexibility**: Can reconfigure for I2C, SPI if needed

## Notes

- All pins use 3.3V logic (not 5V tolerant!)
- Stepper enable is active LOW
- Limit switches have internal pullups enabled
- Spindle PWM frequency configurable via TCC0
