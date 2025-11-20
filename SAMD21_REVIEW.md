# SAMD21 Platform Deep Review

## Overview
Platform: SAMD21/ATSAMC21E18A-MZ (MegARM board)
CPU: ARM Cortex-M0+, 48 MHz, 32KB RAM, 256KB Flash
Status: **PARTIALLY IMPLEMENTED** - Several critical features incomplete

---

## CRITICAL ISSUES

### 1. System Timer NOT WORKING ⚠️⚠️⚠️
**Location:** `platform.c:169-175`
```c
// SysTick_Config(HAL_CPU_FREQ / 1000);  // COMMENTED OUT!
// __enable_irq();                        // COMMENTED OUT!
```

**Impact:**
- `hal_millis()` and `hal_micros()` return 0
- All timing functions broken
- Dwell times, feed rates, delays won't work

**Fix Required:** Uncomment SysTick initialization

---

### 2. NVMEM Write NOT IMPLEMENTED ⚠️⚠️
**Location:** `platform.c:430-439`
```c
void hal_nvmem_write_byte(uint32_t addr, uint8_t value) {
  // TODO: Implement flash write with page erase logic
}
```

**Impact:**
- Cannot save settings to EEPROM
- Settings changes lost on reset
- GRBL configuration unusable

**Fix Required:** Implement SAMD21 NVM controller write sequence

---

### 3. Spindle PWM NOT IMPLEMENTED ⚠️
**Location:** `platform.c:466-476`
```c
void hal_spindle_pwm_set(uint16_t value) {
  // TODO: Implement TCC0 PWM set
}

void hal_timer_spindle_pwm_set_duty(uint16_t duty) {
  (void)duty;  // Not implemented yet
}
```

**Impact:**
- Variable spindle speed (M3 Sxxx) won't work
- Only on/off spindle control available

**Fix Required:** Configure TCC0 PWM output

---

### 4. GPIO Interrupts NOT IMPLEMENTED ⚠️
**Location:** `platform.h:193-194`
```c
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, interrupt, mask)   /* TODO: Implement EIC */
#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, interrupt, mask)  /* TODO: Implement EIC */
```

**Impact:**
- Hard limits won't trigger interrupts
- Control pins (reset, feed hold) won't work as interrupts
- Probe detection may be unreliable

**Fix Required:** Implement External Interrupt Controller (EIC)

---

## MAJOR ISSUES

### 5. Outdated GPIO Code in hal_gpio_init()
**Location:** `platform.c:108-158`

**Problem:** Uses old-style direct PORT manipulation instead of new GPIO macros

**Examples:**
```c
// OLD STYLE (current):
PORT->Group[PORT_GROUPA].DIRSET = DIRECTION_MASK;
PORT->Group[PORT_GROUPA].OUTCLR = DIRECTION_MASK;
PORT->Group[PORT_GROUPA].DIRSET = (1 << SPINDLE_DIRECTION_PIN);

// NEW STYLE (should be):
GPIO_SET_OUT(X_DIRECTION);
GPIO_SET_OUT(Y_DIRECTION);
GPIO_SET_OUT(Z_DIRECTION);
GPIO_BCLR(SPINDLE_DIRECTION);
```

**Lines to update:**
- 115-116: Direction pins
- 119-120: Step pins
- 123-124: Stepper enable
- 127-131: Limit switches (3 pins)
- 134-138: Control pins (3 pins)
- 141-143: Probe pin
- 146-147: Spindle direction
- 152-157: Coolant pins

**Fix Required:** Rewrite entire hal_gpio_init() using new GPIO_* macros

---

### 6. Inaccurate Microsecond Delay
**Location:** `platform.c:502-509`
```c
void hal_delay_us(uint32_t us) {
  // Simple delay loop - not accurate
  // TODO: Implement precise microsecond delay using timer
  volatile uint32_t count = us * (HAL_CPU_FREQ / 1000000) / 10;
  while (count--) {
    __asm__ volatile ("nop");
  }
}
```

**Problem:**
- NOP loop timing varies with optimization level
- "/10" is an arbitrary guess
- Not calibrated

**Fix Required:** Use SysTick or TC timer for precise delays

---

### 7. Inefficient Pullup Enable/Disable
**Location:** `platform.c:246-263`
```c
void hal_gpio_pullup_enable(hal_gpio_port_t port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 32; pin++) {  // Always loops 32 times!
    if (mask & (1UL << pin)) {
      PORT->Group[port].PINCFG[pin] |= PORT_PINCFG_PULLEN;
      PORT->Group[port].OUTSET = (1UL << pin);
    }
  }
}
```

**Problem:** O(32) even for single bit
**Fix:** Use __builtin_ctz() to iterate only set bits

---

## MODERATE ISSUES

### 8. Redundant Pin Definitions
**Location:** `megarm/config.h` (all pin definitions)

**Problem:** Both PIN and BIT defined for same value
```c
#define X_STEP_PIN   25
#define X_STEP_BIT   25   // REDUNDANT!
```

**Recommendation:** Remove all `*_BIT` definitions, use only `*_PIN`

---

### 9. Thread-Safety Issue in GPIO Write
**Location:** `platform.c:216-219`
```c
void hal_gpio_write_port(hal_gpio_port_t port, uint32_t mask, uint32_t value) {
  // Read-modify-write without critical section!
  PORT->Group[port].OUT = (PORT->Group[port].OUT & ~mask) | (value & mask);
}
```

**Problem:** Not atomic, can corrupt if called from ISR
**Fix:** Use OUTSET/OUTCLR instead, or add critical section

---

### 10. Unused Global Variable
**Location:** `platform.c:20`
```c
uint32_t _hal_critical_state = 0;  // Never used!
```

**Fix:** Remove or use properly

---

### 11. Magic Numbers Without Comments
**Location:** `platform.c:82, 89`
```c
SYSCTRL->OSC8M = 0x87;  // What does 0x87 mean?
uint32_t coarse_cal = (*((uint32_t*)0x00806020) >> 26) & 0x3F;  // What is this address?
```

**Fix:** Add explanatory comments:
```c
SYSCTRL->OSC8M = 0x87;  // Enable OSC8M: ENABLE=1, PRESC=0, ONDEMAND=0
uint32_t coarse_cal = (*((uint32_t*)0x00806020) >> 26) & 0x3F;  // NVM Software Calibration Area
```

---

### 12. Confusing AVR Compatibility Layer
**Location:** `platform.h:233-255`
```c
#define LIMIT_DDR     0      // Not used on ARM (DDR is for AVR only)
#define LIMIT_PCMSK   0      // Not used on ARM
#define LIMIT_INT     0      // Not used on ARM
```

**Problem:** Defines meaningless values that confuse readers
**Recommendation:** Remove these entirely or add clear documentation

---

## MINOR ISSUES

### 13. Inconsistent Pointer Casting
**Location:** `platform.c:363`
```c
PORT->Group[PORT_GROUPA].PMUX[23 >> 1] = (0x2 << 4) | 0x2;  // Hard to read
```

**Better:**
```c
PORT->Group[PORT_GROUPA].PMUX[23/2] = (PMUX_FUNC_C << 4) | PMUX_FUNC_C;
```

---

### 14. Missing Bounds Checks
**Location:** `platform.c:184, 191, 197, 203`

All pin functions check `if (pin < 32)` but this should never happen
**Recommendation:** Use assert() in debug builds

---

## RECOMMENDATIONS

### Priority 1 (CRITICAL - System Won't Work):
1. ✅ Enable SysTick and interrupts
2. ✅ Implement NVMEM write (flash emulation)
3. ✅ Implement spindle PWM (TCC0)
4. ✅ Implement GPIO interrupts (EIC)

### Priority 2 (IMPORTANT - Code Quality):
5. ✅ Rewrite hal_gpio_init() with new GPIO macros
6. ✅ Fix hal_delay_us() precision
7. ✅ Optimize pullup functions
8. ✅ Fix thread-safety in gpio_write_port()

### Priority 3 (CLEANUP):
9. Remove redundant *_BIT definitions
10. Add comments for magic numbers
11. Remove unused variables
12. Clean up AVR compatibility layer

---

## POSITIVE ASPECTS

✅ Good structure and organization
✅ Clear separation of board config (megarm/) from platform code
✅ Proper use of SAMD21 hardware features (DIRSET, OUTCLR, OUTTGL)
✅ Clock configuration looks correct (DFLL48M)
✅ UART configuration appears complete
✅ Critical section implementation is correct
✅ GPIO read/write functions are zero-overhead

---

## FILES REVIEWED

- `grbl/platform/samd21/platform.h` (257 lines)
- `grbl/platform/samd21/platform.c` (530 lines)
- `grbl/platform/samd21/megarm/config.h` (208 lines)
- `grbl/platform/samd21/Makefile` (brief)

---

## CONCLUSION

Platform has **good foundation** but **several critical features incomplete**.
Estimated completion: **60-70%**

**Must implement before production:**
1. SysTick timer
2. NVMEM writes
3. Spindle PWM
4. GPIO interrupts

**Recommended improvements:**
5. Modernize GPIO init code
6. Fix timing precision
7. Code cleanup

**Risk level:** MEDIUM-HIGH (basic functionality works but advanced features broken)
