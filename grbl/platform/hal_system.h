/*
  hal_system.h - System HAL (interrupts, delays, critical sections)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

#ifndef HAL_SYSTEM_H
#define HAL_SYSTEM_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

// Initialize platform hardware (clocks, peripherals)
// For AVR: No-op (Arduino bootloader already initialized)
// For others: Configure clocks, enable peripheral clocks, etc.
void hal_system_init(void);

// ============================================================================
// INTERRUPT CONTROL
// ============================================================================

// Global interrupt enable/disable
// AVR: cli() / sei() - inline assembly, zero overhead
// Others: NVIC or equivalent

#ifdef __AVR__
  // For AVR: Direct mapping to original macros - ZERO overhead!
  #include <avr/interrupt.h>
  #define HAL_INTERRUPTS_ENABLE()   sei()
  #define HAL_INTERRUPTS_DISABLE()  cli()

#else
  // For other platforms: implement in platform code
  void hal_interrupts_enable(void);
  void hal_interrupts_disable(void);
  #define HAL_INTERRUPTS_ENABLE()   hal_interrupts_enable()
  #define HAL_INTERRUPTS_DISABLE()  hal_interrupts_disable()
#endif

// ============================================================================
// CRITICAL SECTIONS
// ============================================================================

// Critical section: Save interrupt state, disable interrupts, restore
// Usage:
//   HAL_CRITICAL_SECTION_BEGIN();
//   // ... critical code ...
//   HAL_CRITICAL_SECTION_END();

#ifdef __AVR__
  // AVR: Use SREG save/restore - original GRBL pattern
  #include <avr/interrupt.h>

  #define HAL_CRITICAL_SECTION_BEGIN() \
    uint8_t _hal_sreg = SREG; \
    cli()

  #define HAL_CRITICAL_SECTION_END() \
    SREG = _hal_sreg

#else
  // Other platforms: implement save/restore
  extern uint32_t _hal_critical_state;

  #define HAL_CRITICAL_SECTION_BEGIN() \
    _hal_critical_state = hal_critical_enter()

  #define HAL_CRITICAL_SECTION_END() \
    hal_critical_exit(_hal_critical_state)

  uint32_t hal_critical_enter(void);
  void hal_critical_exit(uint32_t state);
#endif

// ============================================================================
// DELAY FUNCTIONS
// ============================================================================

#ifdef __AVR__
  // AVR: Use original delay functions - zero overhead
  #include <util/delay.h>
  #define HAL_DELAY_MS(ms)  _delay_ms(ms)
  #define HAL_DELAY_US(us)  _delay_us(us)

#else
  // Other platforms: implement delays
  void hal_delay_ms(uint32_t milliseconds);
  void hal_delay_us(uint32_t microseconds);
  #define HAL_DELAY_MS(ms)  hal_delay_ms(ms)
  #define HAL_DELAY_US(us)  hal_delay_us(us)
#endif

// ============================================================================
// TIMING FUNCTIONS
// ============================================================================

// Get milliseconds since boot
// Get microseconds since boot (if available)

#ifdef __AVR__
  // AVR: Will be implemented using existing timer0 overflow
  // (Arduino millis() equivalent, but we'll implement our own)
  uint32_t hal_millis(void);
  uint32_t hal_micros(void);

#else
  // Other platforms: Use SysTick or hardware timer
  uint32_t hal_millis(void);
  uint64_t hal_micros(void);  // 64-bit for longer uptime on faster CPUs
#endif

#define HAL_MILLIS()  hal_millis()
#define HAL_MICROS()  hal_micros()

// ============================================================================
// SYSTEM RESET
// ============================================================================

// Perform software reset
#ifdef __AVR__
  // AVR: Watchdog reset method
  #include <avr/wdt.h>
  #define HAL_SYSTEM_RESET() \
    do { \
      wdt_enable(WDTO_15MS); \
      while(1); \
    } while(0)

#else
  // Other platforms: NVIC reset or equivalent
  void hal_system_reset(void);
  #define HAL_SYSTEM_RESET()  hal_system_reset()
#endif

// ============================================================================
// PLATFORM INFO
// ============================================================================

// Get platform information (defined in platform.h)
typedef struct {
  const char* name;       // Platform name
  const char* cpu;        // CPU type
  uint32_t cpu_freq_hz;   // CPU frequency
  uint32_t ram_bytes;     // RAM size
  uint32_t flash_bytes;   // Flash size
} hal_platform_info_t;

const hal_platform_info_t* hal_platform_get_info(void);

// ============================================================================
// WATCHDOG
// ============================================================================

#ifdef __AVR__
  // AVR: Direct watchdog control
  #include <avr/wdt.h>
  #define HAL_WATCHDOG_INIT(ms)  wdt_enable(WDTO_##ms##MS)
  #define HAL_WATCHDOG_RESET()   wdt_reset()
  #define HAL_WATCHDOG_DISABLE() wdt_disable()

#else
  // Other platforms: Implement watchdog
  void hal_watchdog_init(uint32_t timeout_ms);
  void hal_watchdog_reset(void);
  void hal_watchdog_disable(void);
  #define HAL_WATCHDOG_INIT(ms)  hal_watchdog_init(ms)
  #define HAL_WATCHDOG_RESET()   hal_watchdog_reset()
  #define HAL_WATCHDOG_DISABLE() hal_watchdog_disable()
#endif

#endif // HAL_SYSTEM_H
