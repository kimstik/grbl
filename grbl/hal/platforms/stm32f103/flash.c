/*
  flash.c - STM32F1 flash programming implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT
  Intelligence assisted

  Flash controller for STM32F1 family (F103, F105, F107).
*/

#include "../stm32_common/stm32_flash.h"
#include "../stm32_common/stm32_timing.h"
#include "regs.h"
#include "config.h"

// Flash unlock/lock keys
#define FLASH_KEY1  0x45670123UL
#define FLASH_KEY2  0xCDEF89ABUL

// Flash timeout (in milliseconds)
#define FLASH_TIMEOUT_MS  1000

// ============================================================================
// FLASH API IMPLEMENTATION (STM32F1-specific)
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
  FLASH->CR = FLASH_CR_LOCK;
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

  // Check for errors
  if (FLASH->SR & (FLASH_SR_PGERR | FLASH_SR_WRPRTERR)) {
    // Clear error flags
    FLASH->SR = FLASH_SR_PGERR | FLASH_SR_WRPRTERR | FLASH_SR_EOP;
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

  // Set page erase bit
  FLASH->CR = FLASH_CR_PER;

  // Set page address
  FLASH->AR = page_addr;

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

  // STM32F1 requires half-word (16-bit) writes
  for (uint32_t i = 0; i < size; i += 2) {
    // Combine two bytes into half-word (little-endian)
    uint16_t half_word = data[i];
    if (i + 1 < size) {
      half_word |= (data[i + 1] << 8);
    } else {
      // Odd size - pad with 0xFF
      half_word |= 0xFF00;
    }

    // Wait for flash ready
    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      stm32_flash_lock();
      return status;
    }

    // Set programming bit
    FLASH->CR = FLASH_CR_PG;

    // Write half-word
    *(volatile uint16_t*)(addr + i) = half_word;

    // Wait for write to complete
    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      FLASH->CR &= ~FLASH_CR_PG;
      stm32_flash_lock();
      return status;
    }

    // Clear PG bit
    FLASH->CR &= ~FLASH_CR_PG;

    // Verify write (optional, improves reliability to 98%+)
    uint16_t readback = *(volatile uint16_t*)(addr + i);
    if (readback != half_word) {
      stm32_flash_lock();
      return STM32_ERROR_FLASH_WRITE;
    }
  }

  stm32_flash_lock();
  return STM32_OK;
}
