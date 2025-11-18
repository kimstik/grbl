/*
  stm32_nvmem.h - Flash-based NVMEM emulation for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT
  Intelligence assisted

  Platform-independent flash emulation using configuration from stm32_platform.h
*/

#ifndef STM32_NVMEM_H
#define STM32_NVMEM_H

#include "stm32_platform.h"

// ============================================================================
// NVMEM PUBLIC API
// ============================================================================

/**
 * Initialize NVMEM system - loads flash into cache
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_nvmem_init(void);

/**
 * Read byte from NVMEM (cached read, fast)
 * @param addr Address relative to NVMEM base (0 to size-1)
 * @param data Pointer to store read byte
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_nvmem_read_byte(uint32_t addr, uint8_t* data);

/**
 * Write byte to NVMEM cache (fast, deferred write)
 * @param addr Address relative to NVMEM base (0 to size-1)
 * @param data Byte to write
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_nvmem_write_byte(uint32_t addr, uint8_t data);

/**
 * Flush NVMEM cache to flash (slow, blocks)
 * Call after settings update to persist changes.
 * @return STM32_OK on success, error code otherwise
 */
stm32_status_t stm32_nvmem_flush(void);

/**
 * Check if NVMEM has pending writes
 * @return true if cache is dirty, false otherwise
 */
bool stm32_nvmem_is_dirty(void);

/**
 * Get NVMEM size in bytes
 * @return NVMEM size (page_size * num_pages)
 */
uint32_t stm32_nvmem_get_size(void);

#endif // STM32_NVMEM_H
