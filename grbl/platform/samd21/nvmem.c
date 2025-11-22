#include <stdint.h>
#include "samd21.h"
#include "../../nvmem.h"

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size)	{}
int  memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size)	{  return (1); }

uint8_t hal_nvmem_read_byte(unsigned int addr) { return 0; }
void hal_nvmem_write_byte(unsigned int addr, uint8_t value) {}

// end of file
