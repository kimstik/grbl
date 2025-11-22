/*
  nvmem.c - Non-volatile memory abstraction for Grbl
  Part of Grbl

  Copyright (c) 2025 Grbl HAL Contributors
  Copyright (c) 2012-2016 Sungeun K. Jeon for Gnea Research LLC

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

#include "grbl.h"
#include "hal.h"

// ============================================================================
// AVR EEPROM functions (from Atmel AVR103 application note)
// ============================================================================

#ifdef __AVR__

#include <avr/io.h>
#include <avr/interrupt.h>

// EEPROM bit compatibility for older AVR devices
#ifndef EEPE
  #define EEPE  EEWE
  #define EEMPE EEMWE
#endif

#ifndef EEPM1
  #define EEPM1 5
  #define EEPM0 4
#endif

#define EEPROM_IGNORE_SELFPROG  // Remove SPM flag polling to reduce code size

unsigned char eeprom_get_char(unsigned int addr)
{
  do {} while(EECR & (1<<EEPE));  // Wait for completion of previous write
  EEAR = addr;              // Set EEPROM address register
  EECR = (1<<EERE);        // Start EEPROM read operation
  return EEDR;              // Return the byte read from EEPROM
}

void eeprom_put_char(unsigned int addr, unsigned char new_value)
{
  char old_value;   // Old EEPROM value
  char diff_mask;   // Difference mask, i.e. old value XOR new value

  cli();  // Ensure atomic operation

  do {} while(EECR & (1<<EEPE));  // Wait for completion of previous write

#ifndef EEPROM_IGNORE_SELFPROG
  do {} while(SPMCSR & (1<<SELFPRGEN));  // Wait for completion of SPM
#endif

  EEAR = addr;              // Set EEPROM address register
  EECR = (1<<EERE);        // Start EEPROM read
  old_value = EEDR;         // Get old EEPROM value
  diff_mask = old_value ^ new_value;  // Get bit differences

  // Check if any bits are changed to '1' in the new value
  if(diff_mask & new_value) {
    // Now we know that _some_ bits need to be erased to '1'

    // Check if any bits in the new value are '0'
    if(new_value != 0xff) {
      // Now we know that some bits need to be programmed to '0' also

      EEDR = new_value;     // Set EEPROM data register
      EECR = (1<<EEMPE) |   // Set Master Write Enable bit...
             (0<<EEPM1) | (0<<EEPM0);  // ...and Erase+Write mode
      EECR |= (1<<EEPE);   // Start Erase+Write operation
    } else {
      // Now we know that all bits should be erased

      EECR = (1<<EEMPE) |   // Set Master Write Enable bit...
             (1<<EEPM0);    // ...and Erase-only mode
      EECR |= (1<<EEPE);   // Start Erase-only operation
    }
  } else {
    // Now we know that _no_ bits need to be erased to '1'

    // Check if any bits are changed from '1' in the old value
    if(diff_mask) {
      // Now we know that _some_ bits need to be programmed to '0'

      EEDR = new_value;     // Set EEPROM data register
      EECR = (1<<EEMPE) |   // Set Master Write Enable bit...
             (1<<EEPM1);    // ...and Write-only mode
      EECR |= (1<<EEPE);   // Start Write-only operation
    }
  }

  sei();  // Restore interrupt flag state
}

#endif // __AVR__

// ============================================================================
// GRBL NVMEM extensions (platform-agnostic)
// ============================================================================

/*! \brief  Write buffer to NVMEM with checksum.
 *
 *  Writes a buffer of data to NVMEM and appends a rolling checksum byte.
 *
 *  \param  destination  Starting NVMEM address.
 *  \param  source  Source buffer pointer.
 *  \param  size  Number of bytes to write (excluding checksum).
 */
void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size)
{
  unsigned char checksum = 0;
  for(; size > 0; size--) {
    checksum = (checksum << 1) || (checksum >> 7);
    checksum += *source;
    eeprom_put_char(destination++, *(source++));
  }
  eeprom_put_char(destination, checksum);
}


/*! \brief  Read buffer from NVMEM and verify checksum.
 *
 *  Reads a buffer of data from NVMEM and verifies the appended checksum.
 *
 *  \param  destination  Destination buffer pointer.
 *  \param  source  Starting NVMEM address.
 *  \param  size  Number of bytes to read (excluding checksum).
 *  \return  1 if checksum matches, 0 if checksum fails.
 */
int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size)
{
  unsigned char data, checksum = 0;
  for(; size > 0; size--) {
    data = eeprom_get_char(source++);
    checksum = (checksum << 1) || (checksum >> 7);
    checksum += data;
    *(destination++) = data;
  }
  return(checksum == eeprom_get_char(source));
}

// end of file
