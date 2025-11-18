# STM32F103 HAL Implementation Review

**Date:** 2025-11-18
**Reviewer:** Claude (Automated Code Analysis)
**Focus:** Functionality, Reliability, Extensibility, Flexibility

## Executive Summary

STM32F103 HAL architecture is **60-70% complete**. Core framework is solid, but implementation has critical bugs preventing compilation and runtime operation.

**Status:** ❌ Will NOT compile
**Priority:** Fix CRITICAL issues first (items 1-3)

---

## CRITICAL ISSUES (Блокеры компиляции)

### ❌ CRITICAL #1: AVR-Specific Code in nvmem.c (Lines 42-101)

**Problem:**
```c
// grbl/nvmem.c lines 42-48
unsigned char eeprom_get_char(unsigned int addr)
{
  do {} while(EECR & (1<<EEPE));  // ❌ EECR не существует на STM32!
  EEAR = addr;                     // ❌ EEAR не существует на STM32!
  EECR = (1<<EERE);                // ❌ EECR не существует на STM32!
  return EEDR;                     // ❌ EEDR не существует на STM32!
}
```

**Impact:** Compilation error - undefined identifiers `EECR`, `EEAR`, `EEDR`, `SPMCSR`

**Root Cause:** Functions должны быть только для AVR, но нет `#ifdef` guards

**Fix:**
```c
// grbl/nvmem.c
#include "grbl.h"
#include "hal/grbl_hal.h"

// ONLY compile these for AVR - STM32 uses hal_nvmem_read_byte/write_byte
#ifdef PLATFORM_AVR_ATMEGA328P

// EEPROM bit compatibility for older AVR devices
#ifndef EEPE
  #define EEPE  EEWE
  #define EEMPE EEMWE
#endif

#ifndef EEPM1
  #define EEPM1 5
  #define EEPM0 4
#endif

#define EEPROM_IGNORE_SELFPROG

unsigned char eeprom_get_char(unsigned int addr)
{
  do {} while(EECR & (1<<EEPE));
  EEAR = addr;
  EECR = (1<<EERE);
  return EEDR;
}

void eeprom_put_char(unsigned int addr, unsigned char new_value)
{
  // ... весь AVR-specific код ...
}

#endif // PLATFORM_AVR_ATMEGA328P

// Extensions - работают на всех платформах через eeprom_get_char/eeprom_put_char
void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size)
{
  // ...
}
```

**Priority:** 🔴 CRITICAL - Must fix to compile

---

### ❌ CRITICAL #2: Missing STM32 CMSIS Headers

**Problem:**
```c
// grbl/hal/platforms/stm32f103/platform.c line 11
#include "../../grbl_hal.h"
#include "platform.h"

// platform.h lines 58-60 try to include:
#include "stm32f103xb.h"   // ❌ File not found
#include "core_cm3.h"       // ❌ File not found
```

**Impact:** Compilation error - no STM32 register definitions (GPIOA, TIM2, USART1, etc.)

**Fix Option 1 (Simple):** Remove `#ifdef USE_HAL_DRIVER` и всегда использовать inline definitions:
```c
// platform.h
// Remove CMSIS dependency for now - define minimal registers directly
typedef struct {
  volatile uint32_t CRL;
  volatile uint32_t CRH;
  volatile uint32_t IDR;
  volatile uint32_t ODR;
  volatile uint32_t BSRR;
  // ...
} GPIO_TypeDef;

#define GPIOA ((GPIO_TypeDef*)0x40010800)
// etc.
```

**Fix Option 2 (Better):** Add CMSIS to project или require external CMSIS pack

**Priority:** 🔴 CRITICAL - Must fix to compile

---

### ❌ CRITICAL #3: Missing Interrupt Handler Implementations

**Problem:**
```c
// startup_stm32f103.c lines 64-66
extern void TIM2_IRQHandler(void);   // ❌ Declared but NEVER defined
extern void TIM3_IRQHandler(void);   // ❌ Declared but NEVER defined
extern void USART1_IRQHandler(void); // ❌ Declared but NEVER defined
```

GRBL code defines these via macros:
```c
// stepper.c
HAL_TIMER_STEPPER_ISR() {  // Expands to: void TIM2_IRQHandler(void)
  // stepper logic
}
```

**BUT** - ISR macro needs to clear interrupt flag!

**Impact:**
1. Linker error - undefined references
2. If they link, infinite interrupt loop (flag never cleared)

**Fix:**
```c
// stepper.c - add at start of ISR
HAL_TIMER_STEPPER_ISR() {
  HAL_TIMER_STEPPER_CLEAR_FLAG();  // ⚠️ BUT this macro is BUGGY!
  // ...
}
```

**AND fix the macro:**
```c
// platform.h line 348 - CURRENT (WRONG):
#define HAL_TIMER_STEPPER_CLEAR_FLAG()  (TIM2->SR = ~TIM_SR_UIF)
//                                                   ^^^ WRONG!

// CORRECT:
#define HAL_TIMER_STEPPER_CLEAR_FLAG()  (TIM2->SR = 0)
```

**Priority:** 🔴 CRITICAL - Prevents linking and causes interrupt storms

---

## HIGH SEVERITY (Функциональность сломана)

### 🟠 HIGH #4: Incomplete Flash Write Implementation

**File:** `platform.c` lines 344-361

**Problem:**
```c
void hal_nvmem_write_byte(unsigned int addr, unsigned char data) {
  // ...
  nvmem_cache[addr] = data;  // Updates cache

  // ❌ MISSING: Write cache back to flash!
  // Commented out: "Full implementation would erase and write flash"
}
```

**Impact:** GRBL settings (feed rate, steps/mm, etc.) LOST on every reboot

**Fix Required:**
```c
void hal_nvmem_write_byte(unsigned int addr, unsigned char data) {
  if (addr >= HAL_NVMEM_FLASH_SIZE) return;

  nvmem_cache[addr] = data;

  // Mark page as dirty, defer actual flash write to hal_nvmem_flush()
  nvmem_dirty = true;
}

void hal_nvmem_flush(void) {
  if (!nvmem_dirty) return;

  // Unlock flash
  FLASH->KEYR = 0x45670123;
  FLASH->KEYR = 0xCDEF89AB;

  // Erase page
  FLASH->CR = FLASH_CR_PER;
  FLASH->AR = HAL_NVMEM_FLASH_START;
  FLASH->CR |= FLASH_CR_STRT;
  while (FLASH->SR & FLASH_SR_BSY);

  // Write cache
  for (uint32_t i = 0; i < HAL_NVMEM_FLASH_SIZE; i += 2) {
    uint16_t data = nvmem_cache[i] | (nvmem_cache[i+1] << 8);
    FLASH->CR = FLASH_CR_PG;
    *(volatile uint16_t*)(HAL_NVMEM_FLASH_START + i) = data;
    while (FLASH->SR & FLASH_SR_BSY);
  }

  // Lock flash
  FLASH->CR = FLASH_CR_LOCK;
  nvmem_dirty = false;
}
```

**Priority:** 🟠 HIGH - Settings won't persist

---

### 🟠 HIGH #5: Missing AFIO Configuration for GPIO Interrupts

**File:** `platform.c` lines 145-163

**Problem:**
```c
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  // This is simplified - real implementation needs AFIO config
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      EXTI->IMR |= (1 << pin);   // Enables interrupt
      // ❌ MISSING: AFIO->EXTICRx to map port to EXTI line!
    }
  }
}
```

**Impact:** Limit switches (PB0, PB1, PB10) and control buttons (PB3-6) **won't trigger interrupts**

**Explanation:**
STM32 requires AFIO (Alternate Function I/O) configuration to map GPIO port to EXTI line.
Without it, EXTI0 might listen to PA0 instead of PB0.

**Fix:**
```c
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  // Enable AFIO clock
  RCC->APB2ENR |= RCC_APB2ENR_AFIOEN;

  // Determine port number (A=0, B=1, C=2)
  uint8_t port_num = 0;
  if (port == GPIOB) port_num = 1;
  else if (port == GPIOC) port_num = 2;

  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Configure AFIO_EXTICRx
      uint8_t reg_idx = pin / 4;        // 0-3
      uint8_t bit_pos = (pin % 4) * 4;  // 0, 4, 8, 12

      AFIO->EXTICR[reg_idx] &= ~(0xF << bit_pos);
      AFIO->EXTICR[reg_idx] |= (port_num << bit_pos);

      // Enable EXTI line
      EXTI->IMR |= (1 << pin);
      EXTI->RTSR |= (1 << pin);  // Rising edge
      EXTI->FTSR |= (1 << pin);  // Falling edge

      // Enable NVIC interrupt
      if (pin < 5) {
        NVIC_EnableIRQ(EXTI0_IRQn + pin);
      } else if (pin < 10) {
        NVIC_EnableIRQ(EXTI9_5_IRQn);
      } else {
        NVIC_EnableIRQ(EXTI15_10_IRQn);
      }
    }
  }
}
```

**Priority:** 🟠 HIGH - Critical safety feature (limits) broken

---

### 🟠 HIGH #6: Timer Interrupt Flag Clearing Bug

**File:** `platform.h` lines 348, 365

**Problem:**
```c
#define HAL_TIMER_STEPPER_CLEAR_FLAG()  (TIM2->SR = ~TIM_SR_UIF)
#define HAL_TIMER_PULSE_RESET_CLEAR_FLAG()  (TIM3->SR = ~TIM_SR_UIF)
```

**Bug Analysis:**
- `TIM_SR_UIF` = bit 0 (0x0001)
- `~TIM_SR_UIF` = 0xFFFE (all bits set EXCEPT UIF!)
- Writing to SR sets flags, not clears them

**Result:** Sets all other timer flags → more interrupts → **interrupt storm** → system hang

**Fix:**
```c
// Option 1: Clear all flags
#define HAL_TIMER_STEPPER_CLEAR_FLAG()  (TIM2->SR = 0)

// Option 2: Clear only UIF (RC_W0 - write 0 to clear)
#define HAL_TIMER_STEPPER_CLEAR_FLAG()  (TIM2->SR &= ~TIM_SR_UIF)
```

**Priority:** 🟠 HIGH - System will hang

---

## MEDIUM SEVERITY (Нужно исправить для полной функциональности)

### 🟡 MEDIUM #7: No EXTI Interrupt Handler Logic

**File:** `startup_stm32f103.c` lines 69-75

**Problem:**
```c
void EXTI0_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
// ...
void Default_Handler(void) {
  while (1);  // ❌ Infinite loop - CPU stuck!
}
```

**Impact:** Limit switch triggers → CPU hangs forever

**Fix:** Need to implement EXTI handlers:
```c
// In limits.c or new file hal/platforms/stm32f103/exti_handlers.c
void EXTI0_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR0) {
    EXTI->PR = EXTI_PR_PR0;  // Clear flag
    // X limit switch triggered
    limits_isr();  // Call GRBL limit handler
  }
}

void EXTI1_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR1) {
    EXTI->PR = EXTI_PR_PR1;
    limits_isr();  // Y limit
  }
}

void EXTI15_10_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR10) {
    EXTI->PR = EXTI_PR_PR10;
    limits_isr();  // Z limit (PB10)
  }
}
```

**Priority:** 🟡 MEDIUM - Safety feature (limits) non-functional

---

### 🟡 MEDIUM #8: Unreliable Microsecond Delay

**File:** `platform.c` lines 302-311

**Problem:**
```c
void hal_delay_us(uint32_t us) {
  uint32_t cycles = us * 72;  // 72 MHz

  for (uint32_t i = 0; i < cycles / 4; i++) {
    __NOP();  // ❌ Compiler may optimize away!
  }
}
```

**Issues:**
1. No `volatile` - optimizer may remove loop
2. Division by 4 is arbitrary - not calibrated
3. Loop overhead not accounted for

**Impact:** Step pulse width incorrect → stepper motors skip steps

**Fix:** Use SysTick or DWT cycle counter:
```c
void hal_delay_us(uint32_t us) {
  uint32_t start = DWT->CYCCNT;
  uint32_t cycles = us * 72;
  while ((DWT->CYCCNT - start) < cycles);
}

// In hal_system_init():
CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
DWT->CYCCNT = 0;
DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
```

**Priority:** 🟡 MEDIUM - May cause step loss

---

### 🟡 MEDIUM #9: Missing CMSIS Include Paths in Makefile

**File:** `Makefile.stm32f103` line 38

**Problem:**
```makefile
CFLAGS += -I. -I$(SOURCE_DIR)
# ❌ Missing: -ICMSIS/Include -ICMSIS/Device/ST/STM32F1xx/Include
```

**Impact:** Compilation fails if CMSIS not in system path

**Fix:**
```makefile
# Add CMSIS paths
CMSIS_DIR = CMSIS
CFLAGS += -I. -I$(SOURCE_DIR)
CFLAGS += -I$(CMSIS_DIR)/Include
CFLAGS += -I$(CMSIS_DIR)/Device/ST/STM32F1xx/Include
```

**Priority:** 🟡 MEDIUM - Build system incomplete

---

## ARCHITECTURAL REVIEW

### ✅ STRENGTHS

1. **Clean HAL Abstraction**
   - Macro-based interface matches AVR exactly
   - Easy to add new platforms (STM32F411, SAMD21, etc.)

2. **Zero-Overhead for AVR**
   - AVR build verified 100% binary match (MD5: `79af184e67b27defd27a39309ac53563`)
   - No performance penalty for abstraction

3. **Proper Separation of Concerns**
   - Platform code isolated in `hal/platforms/stm32f103/`
   - Core GRBL code unchanged

4. **Good Pin Mapping**
   - Logical grouping (all step pins on GPIOA)
   - Hardware PWM on correct timer (TIM1_CH1)
   - EXTI-capable pins for interrupts

### ⚠️ WEAKNESSES

1. **Incomplete Platform Guards**
   - `nvmem.c` has AVR code without `#ifdef PLATFORM_AVR_ATMEGA328P`
   - Could break other platforms

2. **Missing Hardware Abstraction**
   - Direct register access in macros (TIM2->SR, GPIOA->BSRR)
   - Hard to unit test
   - Consider adding thin wrapper functions for testability

3. **No Error Handling**
   - Flash write can fail (write-protected, timeout) - not checked
   - NVMEM addr overflow not handled
   - GPIO config doesn't validate pins

4. **Inflexible Timer Assignment**
   - TIM2/TIM3 hardcoded for stepper/pulse
   - Can't reassign if timer needed for other purpose

### 🔄 EXTENSIBILITY

**Good:**
- Easy to add STM32F411 (copy platform.h, change registers to 32-bit TIMx)
- HAL interface well-defined

**Needs Improvement:**
- Pin mappings hardcoded - should be in config.h or platform_config.h
- Timer selection hardcoded - should be defines

**Suggestion:**
```c
// platform_config.h
#define GRBL_STEPPER_TIMER      TIM2
#define GRBL_PULSE_TIMER        TIM3
#define GRBL_SPINDLE_TIMER      TIM1
#define GRBL_STEP_PORT          GPIOA
// etc.
```

### 🛡️ RELIABILITY

**Critical Missing Features:**
1. **Watchdog Timer** - System can hang forever (see EXTI Default_Handler)
2. **Flash Write Protection** - No wear leveling, no error checking
3. **Stack Overflow Detection** - Only 1KB stack, easy to overflow
4. **Interrupt Priority** - All same priority → potential race conditions

**Suggestions:**
```c
// Enable IWDG watchdog
void hal_watchdog_init(void) {
  IWDG->KR = 0xCCCC;  // Enable
  IWDG->KR = 0x5555;  // Unlock
  IWDG->PR = 0x06;    // Prescaler /256
  IWDG->RLR = 4095;   // Max reload (26s timeout @ 40kHz)
}

// In main loop:
void hal_watchdog_refresh(void) {
  IWDG->KR = 0xAAAA;  // Reload
}
```

---

## TESTING CHECKLIST

Before declaring STM32F103 port "working":

- [ ] **Compilation** - Builds without errors/warnings
- [ ] **Linker** - All symbols resolved
- [ ] **Boot** - Reaches main(), LED blinks
- [ ] **Serial** - Can receive/send characters @ 115200 baud
- [ ] **Stepper ISR** - Timer fires, step pins toggle
- [ ] **Pulse Reset** - Step pulses have correct width (10µs default)
- [ ] **Limits** - Pressing limit switch triggers interrupt, shows in status
- [ ] **Settings** - Write settings, reboot, settings persist
- [ ] **Spindle PWM** - M3 S1000 outputs PWM on PA8
- [ ] **Coolant** - M8/M9 toggle PC13
- [ ] **G-code** - Run simple program (G0 X10 Y10)

---

## PRIORITY FIX ORDER

1. **CRITICAL #1** - Add `#ifdef PLATFORM_AVR_ATMEGA328P` guards to nvmem.c
2. **CRITICAL #2** - Add minimal STM32 register definitions (remove CMSIS dependency)
3. **CRITICAL #3** - Fix interrupt flag clear macros (remove `~`)
4. **HIGH #5** - Add AFIO configuration for EXTI
5. **HIGH #4** - Implement flash write (deferred/batch write)
6. **MEDIUM #7** - Add EXTI handler stubs
7. **MEDIUM #8** - Fix microsecond delay
8. **Test compilation**
9. **Test on hardware**

---

## FINAL RECOMMENDATION

**Status:** Implementation is architecturally sound but incomplete.

**Action Required:**
1. Fix CRITICAL issues #1-3 (will take ~1 hour)
2. Fix HIGH issues #4-6 (will take ~2 hours)
3. Test compilation (should pass after fixes)
4. Test on hardware with simple G-code

**Estimated Time to Working Prototype:** 4-6 hours of focused development

**Long-term:** Add watchdog, wear leveling for flash, better error handling

---

## CODE QUALITY METRICS

| Metric | Score | Notes |
|--------|-------|-------|
| Architecture | 9/10 | Excellent abstraction design |
| Completeness | 6/10 | Major features missing (flash write, EXTI) |
| Reliability | 4/10 | Critical bugs (interrupt flag, AFIO) |
| Extensibility | 8/10 | Easy to add platforms, but some hardcoding |
| Testability | 5/10 | Direct register access hard to mock |
| Documentation | 7/10 | Good comments, but missing setup guide |

**Overall Grade:** C+ (70%)
**Blockers:** 3 critical compilation issues
**Recommendation:** Fix critical issues, then incremental improvement
