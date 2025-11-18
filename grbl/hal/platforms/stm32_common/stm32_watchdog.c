/*
  stm32_watchdog.c - Independent Watchdog (IWDG) for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT
*/

#include "stm32_watchdog.h"

// IWDG registers (identical across all STM32 families)
#define IWDG_BASE           0x40003000UL
#define IWDG_KR             (*((__IO uint32_t*)(IWDG_BASE + 0x00)))
#define IWDG_PR             (*((__IO uint32_t*)(IWDG_BASE + 0x04)))
#define IWDG_RLR            (*((__IO uint32_t*)(IWDG_BASE + 0x08)))
#define IWDG_SR             (*((__IO uint32_t*)(IWDG_BASE + 0x0C)))

// IWDG key values
#define IWDG_KEY_ENABLE     0xCCCCUL
#define IWDG_KEY_WRITE      0x5555UL
#define IWDG_KEY_REFRESH    0xAAAAUL

// IWDG prescaler values (40kHz / prescaler = counter frequency)
#define IWDG_PRESCALER_4    0  // 10 kHz counter (max timeout: 409ms)
#define IWDG_PRESCALER_8    1  // 5 kHz counter (max timeout: 819ms)
#define IWDG_PRESCALER_16   2  // 2.5 kHz counter (max timeout: 1.6s)
#define IWDG_PRESCALER_32   3  // 1.25 kHz counter (max timeout: 3.3s)
#define IWDG_PRESCALER_64   4  // 625 Hz counter (max timeout: 6.6s)
#define IWDG_PRESCALER_128  5  // 312.5 Hz counter (max timeout: 13.1s)
#define IWDG_PRESCALER_256  6  // 156.25 Hz counter (max timeout: 26.2s)

// ============================================================================
// PUBLIC FUNCTIONS
// ============================================================================

stm32_status_t stm32_watchdog_init(uint32_t timeout_ms) {
  // Validate timeout range
  STM32_VALIDATE_RANGE(timeout_ms, 100, 26000, STM32_ERROR_INVALID_PARAM);

  // Calculate prescaler and reload value
  // IWDG runs at 40kHz (LSI), divided by prescaler
  uint8_t prescaler;
  uint32_t reload;
  uint32_t freq;  // Counter frequency in Hz

  if (timeout_ms <= 400) {
    prescaler = IWDG_PRESCALER_4;
    freq = 10000;  // 40kHz / 4 = 10kHz
  } else if (timeout_ms <= 800) {
    prescaler = IWDG_PRESCALER_8;
    freq = 5000;   // 40kHz / 8 = 5kHz
  } else if (timeout_ms <= 1600) {
    prescaler = IWDG_PRESCALER_16;
    freq = 2500;   // 40kHz / 16 = 2.5kHz
  } else if (timeout_ms <= 3200) {
    prescaler = IWDG_PRESCALER_32;
    freq = 1250;   // 40kHz / 32 = 1.25kHz
  } else if (timeout_ms <= 6500) {
    prescaler = IWDG_PRESCALER_64;
    freq = 625;    // 40kHz / 64 = 625Hz
  } else if (timeout_ms <= 13000) {
    prescaler = IWDG_PRESCALER_128;
    freq = 312;    // 40kHz / 128 = 312.5Hz (approx)
  } else {
    prescaler = IWDG_PRESCALER_256;
    freq = 156;    // 40kHz / 256 = 156.25Hz (approx)
  }

  // Calculate reload value: timeout_ms * (freq / 1000)
  reload = (timeout_ms * freq) / 1000;
  STM32_VALIDATE_RANGE(reload, 1, 0xFFF, STM32_ERROR_INVALID_PARAM);

  // Start IWDG
  IWDG_KR = IWDG_KEY_ENABLE;

  // Enable register access
  IWDG_KR = IWDG_KEY_WRITE;

  // Configure prescaler and reload value
  IWDG_PR = prescaler;
  IWDG_RLR = reload;

  // Wait for registers to update
  while (IWDG_SR) {
    __NOP();
  }

  // Refresh watchdog to start counting
  IWDG_KR = IWDG_KEY_REFRESH;

  return STM32_OK;
}

void stm32_watchdog_refresh(void) {
  IWDG_KR = IWDG_KEY_REFRESH;
}
