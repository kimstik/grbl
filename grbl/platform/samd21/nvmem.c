/*
  nvmem.c - SAMD21 EEPROM emulation using Flash
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted

  Uses last 4KB of Flash for EEPROM emulation
  Flash: 64-byte pages, 256-byte rows (4 pages per row)
*/

#include <stdint.h>
#include <string.h>
#include "samd21.h"
#include "platform.h"
#include "../../nvmem.h"

// EEPROM emulation area (last 4KB of 256KB Flash)
// This file owns the bare EEPROM_SIZE name (emulated-EEPROM byte count).
// The platform.h capability flag is HAL_EEPROM_SIZE (= 0, no hardware
// EEPROM) - a different quantity that once collided with this name.
#define EEPROM_FLASH_BASE  (0x0003F000UL)  // 256KB - 4KB
#define EEPROM_SIZE        4096
#define FLASH_PAGE_SIZE    64
#define FLASH_ROW_SIZE     256

// Flash operations helper functions
static void flash_wait_ready(void) {
  while (!(NVMCTRL->INTFLAG & NVMCTRL_INTFLAG_READY));
}

static void flash_execute_command(uint32_t cmd, uint32_t addr) {
  // Clear any previous error flags
  NVMCTRL->INTFLAG = NVMCTRL_INTFLAG_READY;

  // Set address (byte address >> 1 for word address)
  NVMCTRL->ADDR = addr >> 1;

  // Execute command
  NVMCTRL->CTRLA = NVMCTRL_CTRLA_CMDEX_KEY | (cmd << NVMCTRL_CTRLA_CMD_Pos);

  // Wait for command completion
  flash_wait_ready();
}

static void flash_erase_row(uint32_t addr) {
  // Erase must be on row boundary (256 bytes)
  flash_execute_command(NVMCTRL_CMD_ER, addr);
}

static void flash_write_page(uint32_t addr, const uint8_t *data) {
  // Clear page buffer
  flash_execute_command(NVMCTRL_CMD_PBC, 0);

  // Write data to page buffer (word by word)
  uint16_t *dst = (uint16_t*)addr;
  const uint16_t *src = (const uint16_t*)data;

  for (uint32_t i = 0; i < FLASH_PAGE_SIZE / 2; i++) {
    dst[i] = src[i];
  }

  // Data Synchronization Barrier - ensure ALL page buffer writes complete
  // before issuing Flash write command (BUG #13 fix)
  __DSB();

  // Write page buffer to Flash
  flash_execute_command(NVMCTRL_CMD_WP, addr);
}

// Read byte from emulated EEPROM
unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) {
    return 0xFF;
  }

  uint8_t *flash_addr = (uint8_t*)(EEPROM_FLASH_BASE + addr);
  return *flash_addr;
}

// Write byte to emulated EEPROM
void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) {
    return;
  }

  uint32_t flash_addr = EEPROM_FLASH_BASE + addr;
  uint8_t *flash_ptr = (uint8_t*)flash_addr;

  // Check if value already matches (avoid unnecessary writes)
  if (*flash_ptr == new_value) {
    return;
  }

  // Calculate page address and offset
  uint32_t page_addr = flash_addr & ~(FLASH_PAGE_SIZE - 1);
  uint32_t page_offset = flash_addr & (FLASH_PAGE_SIZE - 1);

  // Read entire page into buffer
  uint8_t page_buffer[FLASH_PAGE_SIZE];
  memcpy(page_buffer, (void*)page_addr, FLASH_PAGE_SIZE);

  // Modify byte
  page_buffer[page_offset] = new_value;

  // Check if we need to erase row (if any byte is not 0xFF after modification)
  uint32_t row_addr = flash_addr & ~(FLASH_ROW_SIZE - 1);
  uint8_t need_erase = 0;

  // Read all 4 pages in the row
  for (uint32_t i = 0; i < FLASH_ROW_SIZE; i++) {
    uint8_t current = *((uint8_t*)(row_addr + i));
    if (i >= (page_addr - row_addr) && i < (page_addr - row_addr + FLASH_PAGE_SIZE)) {
      // Check modified page
      if ((current & page_buffer[i - (page_addr - row_addr)]) != page_buffer[i - (page_addr - row_addr)]) {
        need_erase = 1;
        break;
      }
    }
  }

  if (need_erase) {
    // Save entire row
    uint8_t row_buffer[FLASH_ROW_SIZE];
    memcpy(row_buffer, (void*)row_addr, FLASH_ROW_SIZE);

    // Update the modified byte in row buffer
    row_buffer[flash_addr - row_addr] = new_value;

    // Erase row
    flash_erase_row(row_addr);

    // Write back all 4 pages
    for (uint32_t i = 0; i < 4; i++) {
      flash_write_page(row_addr + i * FLASH_PAGE_SIZE, &row_buffer[i * FLASH_PAGE_SIZE]);
    }
  } else {
    // Can write page directly without erase
    flash_write_page(page_addr, page_buffer);
  }
}

// Bulk write with checksum
void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += source[i];
    eeprom_put_char(destination + i, source[i]);
  }

  // Write checksum at end
  eeprom_put_char(destination + size, checksum);
}

// Bulk read with checksum verification
int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    destination[i] = eeprom_get_char(source + i);
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += destination[i];
  }

  // Verify checksum
  uint8_t stored_checksum = eeprom_get_char(source + size);

  if (checksum == stored_checksum) {
    return 1; // Success
  } else {
    return 0; // Checksum mismatch
  }
}
