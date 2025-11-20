# GRBL HAL Refactoring TODO

This document tracks architectural improvements to reduce code duplication, improve maintainability, and align with vanilla GRBL design principles.

## Status Summary

✅ **Completed**:
- Issue #10: Chip/board directory structure (SAMD21)
- Issue #11: PORT + PIN definitions for all pins
- Issue #1: Fix `common/dummy` pollution

🚧 **In Progress**:
- None

📋 **Planned**:
- Issues #2-9: See priority list below

---

## Implementation Status

### ✅ Issue #10: Chip/Board Folder Hierarchy [COMPLETED]

**Status**: Implemented for SAMD21

**Structure**:
```
platform/samd21/
├── samd21.h       # Chip: register definitions
├── platform.h     # Chip: HAL API
├── platform.c     # Chip: implementations
├── megarm/        # Board: MegARM config
│   └── config.h
└── generic/       # Board: generic template
    └── config.h
```

**Build**: `make BOARD=megarm` (default) or `make BOARD=generic`

**Benefits**:
- ✅ Chip code shared across all boards
- ✅ Easy to add new boards (copy generic/)
- ✅ Clear separation: chip vs board config

---

### ✅ Issue #11: PORT + PIN Definitions [COMPLETED]

**Status**: Implemented for SAMD21

**Before**:
```c
#define X_STEP_PIN    25  // Which port?
```

**After**:
```c
#define X_STEP_PORT   PORT_GROUPA
#define X_STEP_PIN    25   // PA25
#define X_STEP_BIT    25
```

**Benefits**:
- ✅ Explicit port specification
- ✅ Prevents wrong-port bugs
- ✅ Works for multi-port chips

---

## Critical Issues

### ✅ Issue #1: Platform-Specific Code in Common Directories [COMPLETED]

**Status**: Implemented for all platforms

**Problem**: `grbl/platform/common/dummy/avr/io.h` contained platform-specific ARM code:
```c
#define sei()  __enable_irq()
#define cli()  __disable_irq()
```

**Impact**: Polluted common code with ARM-specific implementations.

**Solution Implemented**:
- ✅ Created platform-specific `avr/io.h` for each platform:
  - `platform/samd21/avr/io.h` (ARM Cortex-M0+: cpsie/cpsid)
  - `platform/stm32f103/avr/io.h` (ARM Cortex-M3: cpsie/cpsid)
  - `platform/stm32f411/avr/io.h` (ARM Cortex-M4: cpsie/cpsid)
  - `platform/stm32h523/avr/io.h` (ARM Cortex-M33: cpsie/cpsid)
  - `platform/hc32f460/avr/io.h` (ARM Cortex-M4: cpsie/cpsid)
  - `platform/ch32v006/avr/io.h` (RISC-V: csrsi/csrci mstatus)
  - `platform/sg2002/avr/io.h` (RISC-V: csrsi/csrci mstatus)
- ✅ Updated `common/dummy/avr/io.h` to require platform-specific definitions
- ✅ Verified SAMD21 build still works correctly

**Benefits**:
- ✅ Common code is now truly platform-agnostic
- ✅ Each platform uses correct interrupt control instructions
- ✅ Easy to add new platforms with different architectures

---

### 2. Serial Abstraction Layer Redundancy

**Problem**: Unnecessary abstraction layer `hal_serial.h` over existing `serial.h`

**Current**:
```
serial.h (abstract) -> hal_serial.h -> serial_read/write -> platform serial.c
```

**Issue**: `serial.h` is already sufficiently abstract. Adding `hal_serial.h` creates redundant indirection.

**Solution**:
- Remove `hal_serial.h`
- Each platform implements `serial.c` directly
- Use standard C abstraction (`putchar`/`getchar`) on platform side

---

### 3. Platform Header Inclusion Method

**Problem**: Platform headers included via `#include` in `hal.h`:
```c
#include "samd21/platform.h"  // Current approach
```

**Solution**: Include platform headers via compiler flags in Makefile:
```makefile
CFLAGS += -include platform/samd21/platform.h
```

**Benefits**:
- Cleaner code
- No conditional compilation in headers
- Standard approach for platform abstraction

---

### 4. Excessive HAL Abstraction Files

**Problem**: Too many `hal_*.h` files for already-abstract subsystems

**Examples**:
- `serial.h` is abstract enough → why add `hal_serial.h`?
- `nvmem.h` is abstract enough → why add `hal_nvmem.h`?

**Solution**: Review each `hal_*.h` file:
- Keep only if it provides genuine cross-platform value
- Remove if underlying module is already abstract
- Platforms implement `.c` files directly against abstract headers

---

## Naming Convention Changes

### 5. Remove HAL_ Prefix Noise

**Current naming** (verbose):
```c
HAL_GPIO_READ_PIN()
HAL_GPIO_WRITE_PORT()
HAL_GPIO_PULLUP_ENABLE()
HAL_TIMER_STEPPER_INIT()
HAL_TIMER_STEPPER_RESET_PRESCALER()
```

**Proposed naming** (concise):
```c
GPIO_PIN_RD()
GPIO_PORT_WR()
GPIO_PULLUP_ENABLE()     // Keep when semantically clear
TIMER_STEPPER_INIT()
TIMER_STEPPER_RESET_PRESCALER()
```

**Additional simplifications**:
```c
GPIO_DIR_OUT()    // Direction: output
GPIO_DIR_IN()     // Direction: input
GPIO_BSET()       // Bit set
GPIO_BCLR()       // Bit clear
GPIO_BTGL()       // Bit toggle
```

---

### 6. Simplify Single-Bit Operations

**Current approach** (verbose):
```c
HAL_GPIO_CLEAR_BITS(STEPPERS_DISABLE_PORT, (1<<STEPPERS_DISABLE_BIT));
```

**Proposed approach** (concise):
```c
GPIO_BCLR(PIN_STEPPERS_DISABLE);
```

**Benefits**:
- More readable
- Matches hardware operation semantics
- Reduces macro complexity

**Implementation**:
1. Create single-pin macros: `PIN_STEPPERS_DISABLE`, `PIN_X_STEP`, etc.
2. Implement `GPIO_BCLR(pin)`, `GPIO_BSET(pin)`, `GPIO_BTGL(pin)`
3. Verify MD5 checksum of compiled binary matches before/after
4. Apply to all single-bit GPIO operations

---

## Configuration File Organization

### 7. Separate Platform Config from Platform Headers

**Problem**: `platform.h` contains pin configuration that may vary between boards:
```c
// In platform.h (should not be here)
#define X_STEP_PIN    25
#define Y_STEP_PIN    27
```

**Solution**:
- Move pin configuration to `$(platform)/config.h`
- `$(platform)/platform.h` contains only:
  - Hardware register definitions
  - HAL function declarations
  - Architecture-specific macros
- `$(platform)/config.h` contains:
  - Pin mappings (like AVR's `cpu_map.h`)
  - Board-specific configuration
  - Easy to change for different hardware variants

**Structure**:
```
platform/samd21/
  ├── platform.h     # Hardware abstraction (rarely changes)
  ├── config.h       # Board pinout (user-configurable)
  ├── platform.c     # HAL implementation
  └── samd21.h       # Register definitions
```

---

## Code Rollback Strategy

### 8. Restore Vanilla GRBL Core Files

**Goal**: Minimize modifications to original GRBL core code

**Files to restore to vanilla**:
- `grbl/cpu_map.h` → Full rollback to vanilla version
- `grbl/nvmem.c` → Full rollback to vanilla version

**Reason**:
- `nvmem.h` is sufficiently abstract for platform implementations
- Platforms can include `grbl/nvmem.c` in their build if compatible
- Or provide platform-specific `nvmem.c` if needed

---

### 9. Remove Platform-Specific Conditionals

**Problem**: Platform checks scattered in core code:
```c
#ifdef PLATFORM_SAMD21
  // Platform-specific code
#endif
```

**Solution**:
- Remove all `#ifdef PLATFORM_*` from core GRBL files
- Use HAL abstraction macros instead
- Platform differences handled in `platform.h` macros
- Restore affected files to vanilla with valid MD5

**Validation**:
- After changes, verify vanilla files match MD5 checksums
- Ensure all platforms still build and function correctly

---

## Implementation Priority

### ✅ Completed
- ~~Issue #10: Chip/board folder hierarchy~~ (SAMD21: ✅ Done)
- ~~Issue #11: PORT definition to pin macros~~ (SAMD21: ✅ Done)
- ~~Issue #1: Fix `common/dummy` pollution~~ (All platforms: ✅ Done)

### 🔴 High Priority (next tasks)
1. **Issue #9**: Remove platform conditionals from core
   - Remove `#ifdef PLATFORM_*` from grbl/*.c files
   - Use HAL abstraction instead

### 🟡 Medium Priority
3. **Issue #4**: Remove redundant `hal_*.h` files
   - Review hal_serial.h, hal_nvmem.h
   - Keep only if genuine cross-platform value

4. **Issue #8**: Restore vanilla core files
   - Rollback grbl/cpu_map.h to vanilla
   - Rollback grbl/nvmem.c to vanilla
   - Verify AVR MD5 match

5. **Issue #2**: Remove hal_serial.h redundancy
   - Platforms implement serial.c directly

### 🟢 Low Priority (polish)
6. **Issue #5**: Rename macros (remove HAL_ prefix)
7. **Issue #6**: Simplify single-bit GPIO operations
8. **Issue #3**: Change header inclusion method
9. **Issue #7**: ~~Separate config from platform~~ (superseded by #10)

---

## Testing Requirements

For each change:
1. All platforms must build successfully
2. Binary MD5 should match (or document intentional changes)
3. Test on actual hardware (where available)
4. Document any behavior changes

---

## Notes

- These changes improve code maintainability
- Reduces vendor lock-in to "HAL" naming
- Makes codebase more approachable for vanilla GRBL users
- Facilitates porting to new platforms

---

## Example: SAMD21 Implementation (COMPLETED)

### ✅ Actual File Organization

```
platform/samd21/                      # SAMD21 chip family
├── samd21.h                          # Register definitions (SERCOM, TC, TCC, PORT, etc.)
├── platform.h                        # HAL function declarations
├── platform.c                        # HAL implementations (GPIO, timers, UART, etc.)
├── startup.s                         # Chip startup code
├── script.ld                         # Linker script (rSamba bootloader @ 0x200)
├── Makefile                          # Chip build rules (BOARD selection)
├── megarm/                           # MegARM board configuration
│   ├── config.h                      # Pin mappings
│   └── README.md                     # Board documentation
└── generic/                          # Generic SAMD21 template
    ├── config.h                      # Default pin mappings
    └── README.md                     # Template guide
```

### Build Results (MegARM)

**DEBUG** (symbols included):
- Size: 59,036 bytes text + 6,160 bytes RAM
- Note: DEBUG size not representative of final binary

**RELEASE** (TODO: measure):
- Size: TBD (need `make BUILD=RELEASE`)
- Expected: ~30-35KB with LTO optimization

### Example Board Config: MegARM

**File**: `platform/samd21/megarm/config.h`

```c
/*
  MegARM Board Configuration
  ATSAMC21E18A-MZ - Arduino Mega pin-compatible replacement
  https://github.com/kimstik/MegARM
*/

#ifndef BOARD_MEGARM_CONFIG_H
#define BOARD_MEGARM_CONFIG_H

// Board identification
#define BOARD_NAME "MegARM"
#define BOARD_MCU  "ATSAMC21E18A-MZ"

// Step pins (D2, D3, D4 on Arduino Mega pinout)
#define X_STEP_PORT   PORT_GROUPA
#define X_STEP_PIN    25   // PA25 (D2)

#define Y_STEP_PORT   PORT_GROUPA
#define Y_STEP_PIN    27   // PA27 (D3)

#define Z_STEP_PORT   PORT_GROUPA
#define Z_STEP_PIN    28   // PA28 (D4)

// Direction pins (D5, D6, D7)
#define X_DIR_PORT    PORT_GROUPA
#define X_DIR_PIN     0    // PA0 (D5)

#define Y_DIR_PORT    PORT_GROUPA
#define Y_DIR_PIN     1    // PA1 (D6)

#define Z_DIR_PORT    PORT_GROUPA
#define Z_DIR_PIN     2    // PA2 (D7)

// Stepper enable (B0)
#define STEPPERS_DISABLE_PORT  PORT_GROUPA
#define STEPPERS_DISABLE_PIN   3    // PA3 (B0)

// Limit switches (B1, B2, B4)
#define X_LIMIT_PORT  PORT_GROUPA
#define X_LIMIT_PIN   4    // PA4 (B1)

#define Y_LIMIT_PORT  PORT_GROUPA
#define Y_LIMIT_PIN   5    // PA5 (B2)

#define Z_LIMIT_PORT  PORT_GROUPA
#define Z_LIMIT_PIN   7    // PA7 (B4)

// Control pins (C0, C1, C2)
#define CONTROL_RESET_PORT      PORT_GROUPA
#define CONTROL_RESET_PIN       14   // PA14 (C0)

#define CONTROL_FEED_HOLD_PORT  PORT_GROUPA
#define CONTROL_FEED_HOLD_PIN   15   // PA15 (C1)

#define CONTROL_CYCLE_START_PORT   PORT_GROUPA
#define CONTROL_CYCLE_START_PIN    16   // PA16 (C2)

// Spindle control (B3, B5)
#define SPINDLE_PWM_PORT       PORT_GROUPA
#define SPINDLE_PWM_PIN        6    // PA6 (B3)

#define SPINDLE_DIRECTION_PORT PORT_GROUPA
#define SPINDLE_DIRECTION_PIN  8    // PA8 (B5)

// Coolant (C3, C4)
#define COOLANT_FLOOD_PORT     PORT_GROUPA
#define COOLANT_FLOOD_PIN      17   // PA17 (C3)

#define COOLANT_MIST_PORT      PORT_GROUPA
#define COOLANT_MIST_PIN       18   // PA18 (C4)

// Probe (C5)
#define PROBE_PORT             PORT_GROUPA
#define PROBE_PIN              19   // PA19 (C5)

// UART (D0, D1)
#define UART_RX_PORT           PORT_GROUPA
#define UART_RX_PIN            23   // PA23 (D0)
#define UART_TX_PORT           PORT_GROUPA
#define UART_TX_PIN            24   // PA24 (D1)

#endif // BOARD_MEGARM_CONFIG_H
```

### ✅ Build System (Implemented)

**Actual Makefile**:
```makefile
# Board selection (override with make BOARD=generic)
BOARD ?= megarm

# Include paths
CFLAGS_EXTRA = -I. -I../common/dummy -I$(BOARD)

# Board-specific config (included via -include flag)
CFLAGS_EXTRA += -include $(BOARD)/config.h
```

**Usage**:
```bash
cd grbl/platform/samd21
make BOARD=megarm    # Default
make BOARD=generic   # Generic template
```

### ✅ Benefits Realized

1. **Reusability**: SAMD21 chip code shared across all boards ✅
2. **Maintainability**: Pin changes only affect board config.h ✅
3. **Clarity**: Clear chip vs board separation ✅
4. **Extensibility**: Add board = `cp -r generic/ myboard/` ✅
5. **Port Safety**: Explicit PORT + PIN prevents bugs ✅

---

## Next Steps

1. Measure RELEASE binary size for SAMD21
2. Apply chip/board structure to other platforms (STM32F103, STM32H523, etc.)
3. **Issue #9** (High Priority): Remove platform conditionals from core GRBL files
