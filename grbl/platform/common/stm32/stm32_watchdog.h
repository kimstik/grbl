/*
  stm32_watchdog.h - Independent Watchdog (IWDG) for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef STM32_WATCHDOG_H
#define STM32_WATCHDOG_H

#include "stm32_platform.h"

// WATCHDOG PUBLIC API

/**
 * Initialize independent watchdog with specified timeout
 * @param timeout_ms Timeout in milliseconds (min: ~100ms, max: ~26000ms)
 * @return STM32_OK on success, error code otherwise
 *
 * NOTE: Once enabled, watchdog CANNOT be disabled except by reset!
 */
stm32_status_t stm32_watchdog_init(uint32_t timeout_ms);

/**
 * Refresh watchdog timer (pet the dog)
 * Must be called periodically before timeout to prevent reset.
 */
void stm32_watchdog_refresh(void);

#endif // STM32_WATCHDOG_H
