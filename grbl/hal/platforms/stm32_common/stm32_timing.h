/*
  stm32_timing.h - Common timing functions for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT

  SysTick-based millisecond counter and DWT cycle counter for microsecond delays.
  Works on all Cortex-M3/M4/M7/M33 cores.
*/

#ifndef STM32_TIMING_H
#define STM32_TIMING_H

#include "stm32_platform.h"

// ============================================================================
// TIMING PUBLIC API
// ============================================================================

/**
 * Initialize timing system (DWT cycle counter)
 * Call once during system initialization.
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_timing_init(void);

/**
 * Get milliseconds since boot (SysTick-based, 1ms resolution)
 * @return Milliseconds elapsed since system start
 */
uint32_t stm32_millis(void);

/**
 * Get microseconds since boot (SysTick + DWT, ~14ns resolution @ 72MHz)
 * @return Microseconds elapsed since system start
 */
uint64_t stm32_micros(void);

/**
 * Delay for specified milliseconds (blocking)
 * Uses SysTick counter, works during interrupts.
 * @param ms Milliseconds to delay
 */
void stm32_delay_ms(uint32_t ms);

/**
 * Delay for specified microseconds (blocking)
 * Uses DWT cycle counter for cycle-accurate delays.
 * @param us Microseconds to delay
 */
void stm32_delay_us(uint32_t us);

/**
 * SysTick interrupt handler (must be called from platform's SysTick_Handler)
 * Increments internal millisecond counter.
 */
void stm32_systick_handler(void);

#endif // STM32_TIMING_H
