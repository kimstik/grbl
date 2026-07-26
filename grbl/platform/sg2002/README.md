# GRBL for Sophgo SG2002 (RISC-V C906)

> **STATUS: NON-FUNCTIONAL — never compiled.** This directory is the
> FOURTH platform port in this project found presenting as complete
> while never having built successfully. Verified by direct build
> attempt (2026-07-26):
> 1. The Makefile never passes `--specs=picolibc.specs`, so file 1
>    (`main.c` → `grbl.h`) fails immediately on `fatal error: math.h:
>    No such file or directory` — the apt `picolibc-riscv64-unknown-elf`
>    package's headers are never on the include path GCC actually
>    searches without that flag.
> 2. Even with that fixed, the apt picolibc package ships no
>    `rv64imafdc`/`lp64d` multilib (i.e. no `crt0.o` for the exact
>    ARCH/ABI this Makefile requests, `rv64gc`/`lp64d`) — the closest
>    available multilibs are `rv64iafd`/`rv64ifd` (no `m`, no compressed
>    `c`), so linking would fail even past the header error.
> 3. Fatally: `platform.h` defines a private `HAL_*` macro namespace
>    (`HAL_GPIO_SET_OUTPUT`, `HAL_TIMER_STEPPER_INIT`, etc.) that core
>    `grbl/stepper.c` has not called since this project's Nov-2025
>    HAL_-strip refactor — core now calls `GPIO_BSET`/`GPIO_MWO`/
>    `STP_TMR_INT_ENA`/etc. directly. This platform layer never reaches
>    `stepper.c` at all; even a clean build would not step a motor.
>
> Do not trust the "Implementation Status" table below — it describes
> code that exists on disk, not code that has ever built or run. Treat
> this port as a candidate to be **restarted from `_template`** (see
> `PLAN.md`), not repaired in place. See [`CONTRACTS.md` §23](../CONTRACTS.md#cross-core-cache-coherency) and `PLAN.md`
> (`sg2002` entry) for the separate, still-valid runtime-core design work
> done on top of this — that design targets a rewrite, not this source.

GRBL CNC controller port for Sophgo SG2002 RISC-V processor (LicheeRV-Nano board).

## Hardware

**Processor:** T-Head XuanTie C906
- 64-bit RISC-V core @ 700MHz
- RV64IMAFDC instruction set
- 5-stage in-order execution pipeline
- 32KB I-cache + 32KB D-cache
- 16KB branch history table
- RISC-V Vector extension V0.7.1
- 256MB DDR3 RAM

**Target Board:** LicheeRV-Nano-WIFI
- Sophgo SG2002 SoC
- WiFi 6 connectivity
- Ethernet support
- Camera and display interfaces
- Cost: ~$6 USD

## Pin Mapping (LicheeRV-Nano)

### Stepper Motors
| Signal | GPIO | Description |
|--------|------|-------------|
| X_STEP | GPIO0_0 | X-axis step |
| Y_STEP | GPIO0_1 | Y-axis step |
| Z_STEP | GPIO0_2 | Z-axis step |
| X_DIR  | GPIO0_3 | X-axis direction |
| Y_DIR  | GPIO0_4 | Y-axis direction |
| Z_DIR  | GPIO0_5 | Z-axis direction |
| ENABLE | GPIO0_6 | Stepper enable (active low) |

### Limit Switches
| Signal | GPIO | Description |
|--------|------|-------------|
| X_LIMIT | GPIO1_0 | X-axis limit switch |
| Y_LIMIT | GPIO1_1 | Y-axis limit switch |
| Z_LIMIT | GPIO1_2 | Z-axis limit switch |

### Control Pins
| Signal | GPIO | Description |
|--------|------|-------------|
| RESET       | GPIO1_3 | Emergency stop |
| FEED_HOLD   | GPIO1_4 | Feed hold button |
| CYCLE_START | GPIO1_5 | Cycle start button |
| SAFETY_DOOR | GPIO1_6 | Safety door switch |

### Spindle Control
| Signal | GPIO | Description |
|--------|------|-------------|
| ENABLE    | GPIO2_0 | Spindle enable |
| DIRECTION | GPIO2_1 | Spindle direction |
| PWM       | GPIO2_2 | Spindle PWM speed |

### Coolant
| Signal | GPIO | Description |
|--------|------|-------------|
| FLOOD | GPIO2_3 | Flood coolant |
| MIST  | GPIO2_4 | Mist coolant |

### Other
| Signal | GPIO | Description |
|--------|------|-------------|
| PROBE | GPIO2_5 | Tool probe input |

### Serial (UART0)
- TX: PA9
- RX: PA10
- Baud: 115200

## Building

### Prerequisites

Install RISC-V GCC toolchain:

```bash
# Ubuntu/Debian
sudo apt install gcc-riscv64-unknown-elf

# Arch Linux
sudo pacman -S riscv64-elf-gcc

# macOS
brew tap riscv/riscv
brew install riscv-tools
```

### Compile

```bash
cd grbl/platform/sg2002

# Debug build
make BUILD=DEBUG

# Release build (with LTO optimization)
make BUILD=RELEASE

# Clean
make clean
```

### Build Output

Build artifacts are created in `build_sg2002_RELEASE/`:
- `grbl_sg2002.elf` - ELF executable with debug symbols
- `grbl_sg2002.bin` - Raw binary for flashing
- `grbl_sg2002.hex` - Intel HEX format
- `grbl_sg2002.map` - Linker map file

## Flashing

### Via USB (DFU mode)
```bash
# TODO: Add DFU flashing instructions
```

### Via JTAG (OpenOCD)
```bash
# TODO: Add JTAG flashing instructions
```

### Via SD Card
```bash
# Copy binary to SD card boot partition
cp build_sg2002_RELEASE/grbl_sg2002.bin /media/boot/
```

## Memory Layout

```
0x80000000 - 0x80100000  : Firmware (1MB)
0x80100000 - 0x90000000  : Free RAM (~255MB)
```

## HAL Implementation Status

**NON-FUNCTIONAL — table below describes code written to disk, not code
verified to build or run (see status banner at top of this file). The
`✅ Implemented` markers below predate that discovery and are retained only
to show what a from-scratch `_template` restart should re-cover; do not
read them as "working".**

| Feature | Status | Notes |
|---------|--------|-------|
| GPIO | ⚠️ Written, unverified | Never compiled; uses private `HAL_*` names core no longer calls |
| UART | ⚠️ Written, unverified | 115200 baud; same private `HAL_*` namespace issue |
| Timer | ⚠️ Written, unverified | Stepper interrupt; same private `HAL_*` namespace issue |
| PLIC | 🚧 Partial | Basic setup |
| NVMEM | ⚠️ RAM-based | Flash emulation TODO |
| PWM | ⚠️ Stub | GPIO-based spindle PWM TODO |
| Watchdog | ❌ Not implemented | |
| USB CDC | ❌ Not implemented | |

## Performance

Estimated performance (700MHz RISC-V vs 16MHz AVR):
- CPU: ~44x faster
- Step rate: >100kHz (vs ~30kHz on AVR)
- Lookahead: Much larger buffer possible

## Known Issues

0. **Does not build** (see status banner at top of this file): missing
   `--specs=picolibc.specs`, no `rv64imafdc`/`lp64d` multilib in the apt
   picolibc package, and a private `HAL_*` macro layer core no longer
   calls — any one of these blocks a working image today.
1. NVMEM is RAM-based (settings lost on reset)
2. PWM spindle control not implemented
3. USB CDC not implemented (UART only)
4. No watchdog timer
5. Interrupt priorities not optimized

## TODO

- [ ] Restart from `_template` (see `PLAN.md`) rather than repairing this
      tree in place — issue 0 above is structural, not a small fix
- [ ] Flash-based NVMEM implementation
- [ ] Hardware PWM for spindle control
- [ ] USB CDC virtual serial port
- [ ] Watchdog timer support
- [ ] Optimize interrupt priorities
- [ ] Add WiFi/Ethernet connectivity for wireless GCode streaming
- [ ] Vector extension optimization for motion planning

## References

- [SG2002 Datasheet](https://github.com/sophgo/sophgo-doc)
- [XuanTie C906 Manual](https://occ-intl-prod.oss-ap-southeast-1.aliyuncs.com/resource/XuanTie-OpenC906-UserManual.pdf)
- [LicheeRV-Nano](https://wiki.sipeed.com/hardware/en/lichee/RV_Nano/1_intro.html)
- [RISC-V Spec](https://riscv.org/technical/specifications/)

## License

MIT License (see main GRBL license)

## Credits

Port developed with AI assistance for the GRBL HAL project.
