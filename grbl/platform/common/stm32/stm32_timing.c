/*
  stm32_timing.c - Common timing functions for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "stm32_timing.h"

// CMSIS CoreDebug/DWT/SysTick registers (standard across all Cortex-M)
#define CoreDebug_DEMCR     (*((__IO uint32_t*)0xE000EDFC))
#define CoreDebug_DEMCR_TRCENA_Msk  (1UL << 24)

#define DWT_CTRL            (*((__IO uint32_t*)0xE0001000))
#define DWT_CYCCNT          (*((__IO uint32_t*)0xE0001004))
#define DWT_CTRL_CYCCNTENA_Msk  (1UL << 0)

#define SysTick_CTRL        (*((__IO uint32_t*)0xE000E010))
#define SysTick_LOAD        (*((__IO uint32_t*)0xE000E014))
#define SysTick_VAL         (*((__IO uint32_t*)0xE000E018))
#define SysTick_CALIB       (*((__IO uint32_t*)0xE000E01C))

#define SysTick_CTRL_ENABLE_Msk     (1UL << 0)
#define SysTick_CTRL_TICKINT_Msk    (1UL << 1)
#define SysTick_CTRL_CLKSOURCE_Msk  (1UL << 2)

// ============================================================================
// TIMING STATE
// ============================================================================

static volatile uint32_t systick_millis = 0;
static bool timing_initialized = false;

// ============================================================================
// PUBLIC FUNCTIONS
// ============================================================================

stm32_status_t stm32_timing_init(void) {
  // Enable DWT cycle counter (for accurate microsecond delays)
  CoreDebug_DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
  DWT_CYCCNT = 0;
  DWT_CTRL |= DWT_CTRL_CYCCNTENA_Msk;

  // Configure SysTick for 1ms interrupts
  uint32_t ticks = stm32_config.cpu_freq / 1000;  // 1ms period
  STM32_VALIDATE_RANGE(ticks, 1, 0x00FFFFFF, STM32_ERROR_INVALID_PARAM);

  SysTick_LOAD = ticks - 1;
  SysTick_VAL = 0;
  SysTick_CTRL = SysTick_CTRL_CLKSOURCE_Msk |
                 SysTick_CTRL_TICKINT_Msk |
                 SysTick_CTRL_ENABLE_Msk;

  systick_millis = 0;
  timing_initialized = true;

  return STM32_OK;
}

uint32_t stm32_millis(void) {
  return systick_millis;
}

uint64_t stm32_micros(void) {
  uint32_t m, t;

  // Atomic read of millis and SysTick counter
  __disable_irq();
  m = systick_millis;
  t = SysTick_VAL;
  __enable_irq();

  // SysTick counts DOWN from LOAD to 0
  // Convert to microseconds
  uint32_t load = SysTick_LOAD & 0x00FFFFFF;
  uint32_t elapsed_ticks = load - t;
  uint32_t ticks_per_us = stm32_config.cpu_freq / 1000000;

  return ((uint64_t)m * 1000) + (elapsed_ticks / ticks_per_us);
}

void stm32_delay_ms(uint32_t ms) {
  uint32_t start = systick_millis;
  while ((systick_millis - start) < ms) {
    __NOP();
  }
}

void stm32_delay_us(uint32_t us) {
  uint32_t start = DWT_CYCCNT;
  uint32_t cycles = us * (stm32_config.cpu_freq / 1000000);

  while ((DWT_CYCCNT - start) < cycles) {
    __NOP();
  }
}

void stm32_systick_handler(void) {
  systick_millis++;
}
