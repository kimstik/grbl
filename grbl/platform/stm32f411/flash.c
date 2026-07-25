/*
  flash.c - STM32F4 flash programming implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Flash controller for the STM32F4 family (F401/F411/F405/...): SECTOR
  erase, not the F1/H5 PAGE erase model - PLATFORM_ROADMAP.md and
  common/stm32/ARCHITECTURE.md both flagged this as the expected divergence
  point for this platform. Sectors on F411CE (512KB) are non-uniform in
  size (4x16KB, 1x64KB, 3x128KB); this file only implements the address
  range this port actually uses (sector 7, the last 128KB sector, per
  config.h/platform.h HAL_NVMEM_FLASH_START) rather than a full generic
  address-to-sector table for the whole part.
*/

#include <stddef.h>
#include "../common/stm32/stm32_flash.h"
#include "../common/stm32/stm32_timing.h"
#include "regs.h"
#include "config.h"

// Flash unlock keys (universal across STM32 families)
#define FLASH_KEY1  0x45670123UL
#define FLASH_KEY2  0xCDEF89ABUL

#define FLASH_TIMEOUT_MS  2000  // Sector erase of a 128KB sector is slow

// ============================================================================
// FLASH API IMPLEMENTATION (STM32F4-specific)
// ============================================================================

stm32_status_t stm32_flash_unlock(void) {
  if (!(FLASH->CR & FLASH_CR_LOCK)) {
    return STM32_OK;
  }

  FLASH->KEYR = FLASH_KEY1;
  FLASH->KEYR = FLASH_KEY2;

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

  // F4 error flags differ from F1/H5 (OPERR/PGAERR/PGPERR/PGSERR/WRPERR)
  if (FLASH->SR & (FLASH_SR_OPERR | FLASH_SR_WRPERR | FLASH_SR_PGAERR |
                   FLASH_SR_PGPERR | FLASH_SR_PGSERR)) {
    FLASH->SR = FLASH_SR_OPERR | FLASH_SR_WRPERR | FLASH_SR_PGAERR |
                FLASH_SR_PGPERR | FLASH_SR_PGSERR | FLASH_SR_EOP;
    return STM32_ERROR_FLASH_WRITE;
  }

  FLASH->SR = FLASH_SR_EOP;

  return STM32_OK;
}

// Map a NVMEM base address to its F4 sector number (SNB field, FLASH_CR bits
// 3-6). Only covers the addresses this port's config.h actually configures
// (sector 7, 0x08060000) - not a general F411 address decoder. Falls back to
// sector 7 for any other address in this build (STM32_VALIDATE_PARAM below
// still rejects addresses below the flash base entirely).
static uint32_t stm32f4_sector_of(uint32_t addr) {
  switch (addr) {
    case 0x08000000UL: return 0;
    case 0x08004000UL: return 1;
    case 0x08008000UL: return 2;
    case 0x0800C000UL: return 3;
    case 0x08010000UL: return 4;
    case 0x08020000UL: return 5;
    case 0x08040000UL: return 6;
    case 0x08060000UL: return 7;
    default:            return 7;
  }
}

stm32_status_t stm32_flash_erase_page(uint32_t page_addr) {
  stm32_status_t status;

  status = stm32_flash_unlock();
  if (status != STM32_OK) return status;

  status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
  if (status != STM32_OK) {
    stm32_flash_lock();
    return status;
  }

  uint32_t sector = stm32f4_sector_of(page_addr);

  // Sector erase, PSIZE not relevant to erase (only to programming), VDD
  // range assumed >=2.7V (Black Pill runs at 3.3V) so word-size (x32)
  // programming is valid per RM0383 Table 6.
  FLASH->CR = FLASH_CR_SER | (sector << FLASH_CR_SNB_Pos) | FLASH_CR_PSIZE_WORD;
  FLASH->CR |= FLASH_CR_STRT;

  status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);

  FLASH->CR &= ~FLASH_CR_SER;

  stm32_flash_lock();
  return status;
}

stm32_status_t stm32_flash_write(uint32_t addr, const uint8_t* data, uint32_t size) {
  stm32_status_t status;

  STM32_VALIDATE_PARAM(data != NULL, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_PARAM(size > 0, STM32_ERROR_INVALID_PARAM);
  STM32_VALIDATE_PARAM(addr >= 0x08000000UL, STM32_ERROR_INVALID_PARAM);

  status = stm32_flash_unlock();
  if (status != STM32_OK) return status;

  // F4 program size is configurable (byte/half-word/word/double-word) via
  // PSIZE; word (32-bit) writes are used here, matching FLASH_CR_PSIZE_WORD
  // above and RM0383's "PSIZE must match VDD range" note (word writes valid
  // >=2.7V).
  for (uint32_t i = 0; i < size; i += 4) {
    uint32_t word = 0xFFFFFFFFUL;
    for (uint32_t j = 0; j < 4 && (i + j) < size; j++) {
      word &= ~(0xFFUL << (j * 8));
      word |= ((uint32_t)data[i + j] << (j * 8));
    }

    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      stm32_flash_lock();
      return status;
    }

    FLASH->CR = FLASH_CR_PG | FLASH_CR_PSIZE_WORD;

    volatile uint32_t* dest = (volatile uint32_t*)(addr + i);
    *dest = word;

    status = stm32_flash_wait_ready(FLASH_TIMEOUT_MS);
    if (status != STM32_OK) {
      FLASH->CR &= ~FLASH_CR_PG;
      stm32_flash_lock();
      return status;
    }

    FLASH->CR &= ~FLASH_CR_PG;

    if (*dest != word) {
      stm32_flash_lock();
      return STM32_ERROR_FLASH_WRITE;
    }
  }

  stm32_flash_lock();
  return STM32_OK;
}
