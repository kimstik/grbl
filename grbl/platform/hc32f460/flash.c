/*
  flash.c - HC32F460 EFM flash-emulated NVMEM
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "../hal.h"
#include "platform.h"

static uint8_t cache[HAL_NVMEM_FLASH_PAGE_SIZE];
static bool cache_loaded = false;

static void load_cache(void) {
  const uint8_t *flash = (const uint8_t *)HAL_NVMEM_FLASH_START;
  for (unsigned i = 0; i < HAL_NVMEM_FLASH_PAGE_SIZE; i++) {
    cache[i] = flash[i];
  }
  cache_loaded = true;
}

static void efm_unlock(void) {
  EFM->FAPRT = EFM_FAPRT_KEY1;
  EFM->FAPRT = EFM_FAPRT_KEY2;
}

static void efm_lock(void) {
  EFM->FAPRT = 0;   /* any value other than the key sequence re-locks (UNVERIFIED, common convention) */
}

static void efm_wait_ready(void) {
  /* Bounded by construction on real hardware (erase/program commands are
     finite); no watchdog-class timeout here matches every other flash
     controller in this tree at the same verification stage. */
  while (!(EFM->FSR & EFM_FSR_RDY));
}

static void efm_erase_page(uint32_t addr) {
  efm_unlock();
  efm_wait_ready();

  EFM->FWMC = EFM_FWMC_PEMODE_ERASE;
  __DSB();   /* BUG#13-class: mode-select store lands before the trigger write (CONTRACTS.md section 12.4) */
  EFM->FSTP = EFM_FSTP_START;

  efm_wait_ready();
  efm_lock();
}

static void efm_program_word(uint32_t addr, uint32_t value) {
  efm_unlock();
  efm_wait_ready();

  EFM->FWMC = EFM_FWMC_PEMODE_PROGRAM;
  __DSB();
  *(volatile uint32_t *)addr = value;

  efm_wait_ready();
  efm_lock();
}

static void commit_page(void) {
  efm_erase_page(HAL_NVMEM_FLASH_START);

  for (unsigned i = 0; i < HAL_NVMEM_FLASH_PAGE_SIZE; i += 4) {
    uint32_t word = (uint32_t)cache[i]
                  | ((uint32_t)cache[i + 1] << 8)
                  | ((uint32_t)cache[i + 2] << 16)
                  | ((uint32_t)cache[i + 3] << 24);
    efm_program_word(HAL_NVMEM_FLASH_START + i, word);
  }
}

void hal_nvmem_init(void) {
  load_cache();
}

unsigned char hal_nvmem_read_byte(unsigned int addr) {
  if (!cache_loaded) load_cache();
  if (addr >= HAL_NVMEM_FLASH_PAGE_SIZE) return 0xFF;   /* out-of-range: erased-flash semantics (section 10.6) */
  return cache[addr];
}

void hal_nvmem_write_byte(unsigned int addr, unsigned char data) {
  if (!cache_loaded) load_cache();
  if (addr >= HAL_NVMEM_FLASH_PAGE_SIZE) return;   /* out-of-range: drop (section 10.6) */
  if (cache[addr] == data) return;                 /* skip-write-if-equal wear guard (section 10.3) */
  cache[addr] = data;
  commit_page();
}

void hal_nvmem_flush(void) {
  commit_page();
}
