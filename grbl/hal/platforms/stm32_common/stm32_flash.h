/*
  stm32_flash.h - Flash programming API abstraction for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT
  Intelligence assisted

  Platform-specific flash operations. Each platform implements these functions
  according to its flash controller (F1/F4/H5 have different registers).
*/

#ifndef STM32_FLASH_H
#define STM32_FLASH_H

#include "stm32_platform.h"

// ============================================================================
// FLASH PROGRAMMING API (platform-specific implementation)
// ============================================================================

/**
 * Unlock flash for programming
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_flash_unlock(void);

/**
 * Lock flash after programming
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_flash_lock(void);

/**
 * Erase flash page/sector
 * @param page_addr Start address of page/sector to erase (must be page-aligned)
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_flash_erase_page(uint32_t page_addr);

/**
 * Write data to flash
 * Handles alignment requirements (half-word for F1, word for F4/H5)
 * @param addr Flash address to write to
 * @param data Pointer to data buffer
 * @param size Number of bytes to write
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_flash_write(uint32_t addr, const uint8_t* data, uint32_t size);

/**
 * Wait for flash operation to complete
 * @param timeout_ms Maximum time to wait in milliseconds
 * @return STM32_OK on success, STM32_ERROR_TIMEOUT if timeout
 */
stm32_status_t stm32_flash_wait_ready(uint32_t timeout_ms);

#endif // STM32_FLASH_H
