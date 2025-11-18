/*
  nvmem.h - Non-volatile memory abstraction
  Part of Grbl

  Copyright (c) 2025 Grbl HAL Contributors
  Copyright (c) 2009-2016 Sungeun K. Jeon for Gnea Research LLC

  Grbl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Grbl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Grbl.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef nvmem_h
#define nvmem_h

// NVMEM (non-volatile memory) abstraction functions
// On AVR: Direct EEPROM access via HAL macros (from hal/hal_nvmem.h)
// On STM32/other platforms: Flash emulation via HAL
//
// NOTE: HAL is included via grbl.h, so eeprom_get_char/eeprom_put_char macros are already defined

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size);
int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size);

// Backward compatibility with original GRBL - map to HAL
#define memcpy_to_eeprom_with_checksum         memcpy_to_nvmem_with_checksum
#define memcpy_from_eeprom_with_checksum       memcpy_from_nvmem_with_checksum

#endif
