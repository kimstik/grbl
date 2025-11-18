/*
  flash.c - STM32H5 flash programming implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Flash controller for STM32H5 family (H523, H533, H563).
  Uses 8KB pages, dual-bank architecture.
*/

#include "../stm32_common/stm32_flash.h"
#include "../stm32_common/stm32_timing.h"
#include "regs.h"
#include "config.h"

// Flash unlock keys
#define FLASH_KEY1  0x45670123UL
#define FLASH_KEY2  0xCDEF89ABUL

// Flash timeout
#define FLASH_TIMEOUT_MS  2000  // H5 flash is slower

// ============================================================================
// FLASH API IMPLEMENTATION (STM32H5-specific)
// ============================================================================

stm32_status_t stm32_flash_unlock(void) {
  // Check if already unlocked
  if (!(FLASH->CR & FLASH_CR_LOCK)) {
    return STM32_OK;
  }

  // Unlock sequence
  FLASH->KEYR = FLASH_KEY1;
  FLASH->KEYR = FLASH_KEY2;

  // Verify unlock
  if (FLASH->CR & FLASH_CR_LOCK) {
    return STM32_ERROR_FLASH_LOCKED;
  }

  return STM32_OK;
}

stm32_status_t stm32_flash_lock(void) {
  FLASH->CR |= FLASH_CR_LOCK;
  return STM32_OK;
}

stm32_status_t stm32_flash_wait_ready(uint32_t timeout_ms) {
  uint32_t start = stm32_millis();

  while (FLASH->SR & FLASH_SR_BSY) {
    if ((stm32_millis() - start) >= timeout_ms) {
      return STM32_ERROR_TIMEOUT;
    }
    __NOP();
  }

  // Check for errors (H5 has different error flags than F1)
  if (FLASH->SR & (FLASH_SR_PGSERR | FLASH_SR_WRPERR)) {
    // Clear error flags
    FLASH->SR = FLASH_SR_PGSERR | FLASH_SR_WRPERR | FLASH_SR_EOP;
    return STM32_ERROR_FLASH_WRITE;
  }

  // Clear EOP flag
  FLASH->SR = FLASH_SR_EOP;

  return STM32_OK;
}

stm32_status_t stm32_flash_erase_page(uint32_t page_addr) {
  stm32_status_t status;

  // Unlock flash
  status = stm32_flash_unlock();
  if (status != STM32_OK) return status;

  // Wait for any ongoing operation
  status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
  if (status != STM32_OK) {
    stm32_flash_lock();
    return status;
  }

  // Calculate page number (8KB pages)
  uint32_t page_num = (page_addr - 0x08000000) / 8192;

  // Set page erase
  FLASH->CR = FLASH_CR_PER | (page_num << FLASH_CR_PNB_Pos);

  // Start erase
  FLASH->CR |= FLASH_CR_STRT;

  // Wait for erase to complete
  status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);

  // Clear PER bit
  FLASH->CR &= ~FLASH_CR_PER;

  stm32_flash_lock();
  return status;
}

stm32_status_t stm32_flash_write(uint32_t addr, const uint8_t* data, uint32_t size) {
  stm32_status_t status;

  // Validate parameters
  STM32_VALIDATE_PARAM(data != NULL, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_PARAM(size > 0, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_PARAM(addr >= 0x08000000, STM32_ERROR_INVALID_PARAM);

  // Unlock flash
  status = stm32_flash_unlock();
  if (status != STM32_OK) return status;

  // H5 uses quad-word (128-bit / 16-byte) writes
  for (uint32_t i = 0; i < size; i += 16) {
    // Combine bytes into quad-word (little-endian)
    uint32_t quad_word[4] = {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF};

    for (uint32_t j = 0; j < 16 && (i + j) < size; j++) {
      uint32_t word_idx = j / 4;
      uint32_t byte_idx = j % 4;
      quad_word[word_idx] &= ~(0xFF << (byte_idx * 8));
      quad_word[word_idx] |= (data[i + j] << (byte_idx * 8));
    }

    // Wait for flash ready
    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      stm32_flash_lock();
      return status;
    }

    // Set programming bit
    FLASH->CR = FLASH_CR_PG;

    // Write quad-word (4 x 32-bit)
    volatile uint32_t* dest = (volatile uint32_t*)(addr + i);
    dest[0] = quad_word[0];
    dest[1] = quad_word[1];
    dest[2] = quad_word[2];
    dest[3] = quad_word[3];

    // Wait for write to complete
    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      FLASH->CR &= ~FLASH_CR_PG;
      stm32_flash_lock();
      return status;
    }

    // Clear PG bit
    FLASH->CR &= ~FLASH_CR_PG;

    // Verify write
    for (uint32_t j = 0; j < 4; j++) {
      if (dest[j] != quad_word[j]) {
        stm32_flash_lock();
        return STM32_ERROR_FLASH_WRITE;
      }
    }
  }

  stm32_flash_lock();
  return STM32_OK;
}
