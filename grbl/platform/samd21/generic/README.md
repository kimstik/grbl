# Generic SAMD21 Board Configuration

## Board Information

- **Name**: Generic SAMD21
- **MCU**: SAMD21G18A
- **Architecture**: ARM Cortex-M0+ @ 48MHz
- **Memory**: 32KB RAM, 256KB Flash
- **Description**: Generic configuration template for SAMD21 development boards

## Purpose

This is a template configuration for creating custom SAMD21 board definitions.

To create a custom board:

1. Copy this directory to a new name:
   ```bash
   cd grbl/platform/samd21/boards
   cp -r generic myboard
   ```

2. Edit `myboard/config.h` to match your pin layout

3. Update `myboard/README.md` with your board details

4. Build with your board:
   ```bash
   make BOARD=myboard
   ```

## Pin Mapping

Generic pin assignments (modify for your board):

### Stepper Control
- **Step Pins**: PA16, PA17, PA18
- **Direction Pins**: PA19, PA20, PA21
- **Enable Pin**: PA22

### Limit Switches
- **X/Y/Z-Limit**: PA4, PA5, PA6

### Control
- **Reset**: PA7
- **Feed Hold**: PA8
- **Cycle Start**: PA9

### Spindle
- **PWM**: PA14 - TCC0/WO[0]
- **Direction**: PA15

### Coolant
- **Flood**: PA24
- **Mist**: PA25

### Probe
- **Probe Pin**: PA10

### Serial
- **RX**: PA11 - SERCOM0 PAD[3]
- **TX**: PA10 - SERCOM0 PAD[2]

## Configuration Tips

### Pin Selection Guidelines

1. **Stepper Pins**: Use any GPIO, prefer grouped ports for efficiency
2. **PWM Pins**: Must use TCC-capable pins (see datasheet)
3. **UART Pins**: Must match SERCOM PAD configuration
4. **I2C/SPI**: Can be remapped to different SERCOM instances

### SERCOM Configuration

SERCOM modules can be configured as UART, SPI, or I2C:
- SERCOM0-5 available on SAMD21G18A
- Each has 4 PADs for signal routing
- Check datasheet for PAD-to-pin mapping

### Timer Resources

- **TC3**: Stepper timer (16-bit)
- **TC4**: Pulse reset timer (16-bit)
- **TCC0**: Spindle PWM (24-bit, advanced features)
- Other timers available for custom use

## Example Boards

See other board configurations for examples:
- `boards/megarm/` - MegARM board (ATSAMC21E18A-MZ)
- `boards/arduino_zero/` - Arduino Zero (coming soon)

## Building

```bash
cd grbl/platform/samd21
make BOARD=generic
```

## Notes

- All GPIO is 3.3V logic
- Maximum GPIO current: 7mA per pin, 120mA total
- Internal pullup resistors available
- Refer to SAMD21 datasheet for electrical characteristics
