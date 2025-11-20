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

## Implementation Priority

1. **High Priority** (breaks other platforms):
   - Issue #1: Fix `common/dummy` pollution
   - Issue #9: Remove platform conditionals from core

2. **Medium Priority** (technical debt):
   - Issue #4: Remove redundant `hal_*.h` files
   - Issue #7: Separate config from platform headers
   - Issue #8: Restore vanilla core files

3. **Low Priority** (cleanup):
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
