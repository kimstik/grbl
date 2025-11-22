#include <stdint.h>
#include "samd21.h"
#include "../../nvmem.h"

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size)	{}
int  memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size)	{  return (1); }


unsigned char eeprom_get_char(unsigned int addr) { return 0; };
void eeprom_put_char(unsigned int addr, unsigned char new_value) {};

// end of file
