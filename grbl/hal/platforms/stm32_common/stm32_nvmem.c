/*
  stm32_nvmem.c - Flash-based NVMEM emulation for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT

  Uses platform configuration to support different flash geometries.
*/

#include "stm32_nvmem.h"
#include "stm32_flash.h"  // Platform-specific flash operations
#include <string.h>

// ============================================================================
// NVMEM STATE
// ============================================================================

static uint8_t* nvmem_cache = NULL;
static bool nvmem_initialized = false;
static bool nvmem_dirty = false;
static uint32_t nvmem_size = 0;

// ============================================================================
// PUBLIC FUNCTIONS
// ============================================================================

stm32_status_t stm32_nvmem_init(void) {
  // Calculate NVMEM size from platform config
  nvmem_size = stm32_config.flash_page_size * stm32_config.flash_num_pages;

  // Validate configuration
  STM32_VALIDATE_PARAM(nvmem_size > 0, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_PARAM(stm32_config.flash_base_addr >= 0x08000000, STM32_ERROR_INVALID_PARAM);

  // Allocate cache (freed on reset, no dynamic deallocation needed)
  if (!nvmem_cache) {
    // Static allocation for embedded systems (safer than malloc)
    static uint8_t cache_buffer[4096];  // Max 4KB for now (covers F103, H523)
    STM32_VALIDATE_PARAM(nvmem_size <= sizeof(cache_buffer), STM32_ERROR_INVALID_PARAM);
    nvmem_cache = cache_buffer;
  }

  // Read flash into cache
  const uint8_t* flash_base = (const uint8_t*)stm32_config.flash_base_addr;
  for (uint32_t i = 0; i < nvmem_size; i++) {
    nvmem_cache[i] = flash_base[i];
  }

  nvmem_initialized = true;
  nvmem_dirty = false;

  return STM32_OK;
}

stm32_status_t stm32_nvmem_read_byte(uint32_t addr, uint8_t* data) {
  // Auto-initialize on first access
  if (!nvmem_initialized) {
    stm32_status_t status = stm32_nvmem_init();
    if (status != STM32_OK) return status;
  }

  // Validate parameters
  STM32_VALIDATE_PARAM(data != NULL, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_RANGE(addr, 0, nvmem_size - 1, STM32_ERROR_OUT_OF_RANGE);

  *data = nvmem_cache[addr];
  return STM32_OK;
}

stm32_status_t stm32_nvmem_write_byte(uint32_t addr, uint8_t data) {
  // Auto-initialize on first access
  if (!nvmem_initialized) {
    stm32_status_t status = stm32_nvmem_init();
    if (status != STM32_OK) return status;
  }

  // Validate parameters
  STM32_VALIDATE_RANGE(addr, 0, nvmem_size - 1, STM32_ERROR_OUT_OF_RANGE);

  // Update cache and mark dirty if changed
  if (nvmem_cache[addr] != data) {
    nvmem_cache[addr] = data;
    nvmem_dirty = true;
  }

  return STM32_OK;
}

stm32_status_t stm32_nvmem_flush(void) {
  STM32_VALIDATE_INIT(nvmem_initialized, STM32_ERROR_NOT_INITIALIZED);

  // Nothing to write
  if (!nvmem_dirty) {
    return STM32_OK;
  }

  // Erase flash pages/sectors
  for (uint32_t page = 0; page < stm32_config.flash_num_pages; page++) {
    uint32_t page_addr = stm32_config.flash_base_addr +
                         (page * stm32_config.flash_page_size);

    stm32_status_t status = stm32_flash_erase_page(page_addr);
    if (status != STM32_OK) {
      return status;
    }
  }

  // Write cache back to flash
  stm32_status_t status = stm32_flash_write(
    stm32_config.flash_base_addr,
    nvmem_cache,
    nvmem_size
  );

  if (status == STM32_OK) {
    nvmem_dirty = false;
  }

  return status;
}

bool stm32_nvmem_is_dirty(void) {
  return nvmem_dirty;
}

uint32_t stm32_nvmem_get_size(void) {
  return nvmem_size;
}
