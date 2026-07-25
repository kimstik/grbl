/*
  nvmem.c - CH32V006 EEPROM emulation (TU-replacement route)
  Part of Grbl

  PORTING-CHECKLIST Step 5 - NOT implemented this batch. Bounds-checking,
  wear guard and bulk checksum loops are real/working (reused from
  `_template/nvmem.c`); only the two innermost primitives are PORT_TODO.
  Future note for Step 5: this chip's flash controller register names are
  FLASH->CTLR/STATR/ADDR (ch32v006.h) - WCH renames STM32's CR/SR/AR but
  the erase/program/wait-BSY sequencing is expected to be the same shape.
*/

#include <stdint.h>
#include "platform.h"
#include "../../nvmem.h"

#define EEPROM_SIZE 1024

unsigned char eeprom_get_char(unsigned int addr) {
  if (addr >= EEPROM_SIZE) { return 0xFF; }
  return PORT_TODO_NVMEM_READ_BYTE(addr);
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  if (addr >= EEPROM_SIZE) { return; }

  // Wear guard (CONTRACTS.md #10.3): skip writes that would not change
  // the stored byte.
  if (PORT_TODO_NVMEM_READ_BYTE(addr) == new_value) { return; }

  PORT_TODO_NVMEM_WRITE_BYTE(addr, new_value);
}

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += source[i];
    eeprom_put_char(destination + i, source[i]);
  }

  eeprom_put_char(destination + size, checksum);
}

int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  uint8_t checksum = 0;

  for (unsigned int i = 0; i < size; i++) {
    destination[i] = eeprom_get_char(source + i);
    checksum = (checksum << 1) | (checksum >> 7);
    checksum += destination[i];
  }

  uint8_t stored_checksum = eeprom_get_char(source + size);
  return (checksum == stored_checksum) ? 1 : 0;
}
