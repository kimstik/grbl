// AVR stub for STM32 - pgmspace macros
#ifndef _AVR_PGMSPACE_H_
#define _AVR_PGMSPACE_H_

// On STM32, strings are already in flash, so PSTR is just identity
#define PSTR(s) ((const char *)(s))
#define pgm_read_byte(addr) (*(const unsigned char *)(addr))
#define pgm_read_word(addr) (*(const unsigned short *)(addr))

#endif
