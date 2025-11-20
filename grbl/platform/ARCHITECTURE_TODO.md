# GRBL HAL Architecture Refactoring TODO

This document outlines necessary architectural improvements to reduce code duplication, improve maintainability, and align with vanilla GRBL design principles.

## Critical Issues

### 1. Platform-Specific Code in Common Directories

**Problem**: `grbl/platform/common/dummy/avr/io.h` contains platform-specific ARM code:
```c
#define sei()  __enable_irq()
#define cli()  __disable_irq()
```

**Impact**: Pollutes common code with ARM-specific implementations, breaking other platforms.

**Solution**:
- Move ARM-specific compatibility to each ARM platform's directory
- Keep `common/dummy` truly platform-agnostic
- Each platform defines its own compatibility layer

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

## Directory Structure Reorganization

### 10. Introduce Chip/Board Folder Hierarchy

**Problem**: Current structure mixes chip-specific and board-specific configuration:
```
platform/samd21/
  ├── platform.h     # Mix of chip + board config
  ├── config.h       # Board-specific pins
  └── platform.c
```

**Proposed structure**:
```
platform/samd21/                    # Chip-specific (SAMD21 family)
  ├── samd21.h                      # Register definitions
  ├── platform.h                    # HAL declarations
  ├── platform.c                    # HAL implementations
  └── boards/
      ├── megarm/                   # MegARM board
      │   └── config.h              # Pin mappings for MegARM
      ├── arduino_zero/             # Arduino Zero board
      │   └── config.h              # Pin mappings for Arduino Zero
      └── generic/                  # Generic SAMD21 board
          └── config.h              # Default pin mappings
```

**Benefits**:
- Chip code shared across all boards using same chip
- Easy to add new boards without duplicating chip code
- Clear separation: chip vs board configuration
- User only modifies board-specific config

**Makefile selection**:
```makefile
CHIP = samd21
BOARD = megarm
CFLAGS += -I platform/$(CHIP)/boards/$(BOARD)
```

**Example usage**:
```c
// In platform/samd21/boards/megarm/config.h
#define X_STEP_PORT   PORT_GROUPA
#define X_STEP_PIN    25   // PA25 (D2 on MegARM)

// In platform/samd21/boards/arduino_zero/config.h
#define X_STEP_PORT   PORT_GROUPA
#define X_STEP_PIN    18   // PA18 (D11 on Arduino Zero)
```

---

### 11. Add PORT Definition to Pin Macros

**Problem**: Current pin definitions only specify pin number:
```c
#define X_STEP_PIN    25  // PA25 - but which port?
```

**Issue**: Makes GPIO macros ambiguous:
```c
GPIO_BSET(X_STEP_PIN);  // Which port? Implicit assumption.
```

**Solution**: Always define both PORT and PIN:
```c
#define X_STEP_PORT   PORT_GROUPA
#define X_STEP_PIN    25
```

**Benefits**:
- Explicit port specification
- Works for chips with multiple ports (PORTA, PORTB, etc.)
- Clearer GPIO macro calls:
  ```c
  GPIO_BSET(X_STEP_PORT, X_STEP_PIN);
  ```

**Implementation**:
1. Update all pin definitions to include PORT
2. Update GPIO macros to accept (port, pin) arguments
3. Verify on hardware that pins match expectations

---

## Implementation Priority

1. **Critical Priority** (architectural foundation):
   - Issue #10: Introduce chip/board folder hierarchy
   - Issue #11: Add PORT definition to pin macros

2. **High Priority** (breaks other platforms):
   - Issue #1: Fix `common/dummy` pollution
   - Issue #9: Remove platform conditionals from core

3. **Medium Priority** (technical debt):
   - Issue #4: Remove redundant `hal_*.h` files
   - Issue #7: Separate config from platform headers (superseded by #10)
   - Issue #8: Restore vanilla core files

4. **Low Priority** (cleanup):
   - Issue #5: Rename macros (remove HAL_ prefix)
   - Issue #6: Simplify single-bit operations
   - Issue #3: Change header inclusion method

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

## Example: SAMD21 Chip/Board Structure

### Proposed File Organization

```
platform/samd21/                           # SAMD21 chip family
├── samd21.h                               # Register definitions (SERCOM, TC, TCC, PORT, etc.)
├── platform.h                             # HAL function declarations
├── platform.c                             # HAL implementations (GPIO, timers, UART, etc.)
├── startup.s                              # Chip startup code
├── script.ld                              # Linker script
├── Makefile                               # Chip build rules
└── boards/                                # Board-specific configurations
    ├── megarm/
    │   ├── config.h                       # MegARM pin mappings
    │   └── README.md                      # Board documentation
    ├── arduino_zero/
    │   ├── config.h                       # Arduino Zero pin mappings
    │   └── README.md                      # Board documentation
    └── generic/
        ├── config.h                       # Generic SAMD21 defaults
        └── README.md                      # Generic board info
```

### Example Board Config: MegARM

**File**: `platform/samd21/boards/megarm/config.h`

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

### Build System Integration

**Makefile example**:
```makefile
# Select chip and board
CHIP = samd21
BOARD = megarm

# Include paths
INCLUDES = -I platform/$(CHIP) \
           -I platform/$(CHIP)/boards/$(BOARD)

# Chip-specific sources
CHIP_SRC = platform/$(CHIP)/platform.c \
           platform/$(CHIP)/startup.s

# Board-specific config (included via -include flag)
CFLAGS += -include platform/$(CHIP)/boards/$(BOARD)/config.h
```

### Benefits of This Approach

1. **Reusability**: SAMD21 chip code shared across MegARM, Arduino Zero, and custom boards
2. **Maintainability**: Pin changes only affect board config, not chip HAL
3. **Clarity**: Clear separation between hardware abstraction and board layout
4. **Extensibility**: Adding new board = create new folder + config.h
5. **Port Safety**: Explicit port specification prevents wrong-port bugs
