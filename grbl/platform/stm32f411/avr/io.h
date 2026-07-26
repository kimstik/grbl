// AVR compatibility for STM32F411 (ARM Cortex-M4)
//
// REAL DIFFERENCE vs ../../common/dummy/avr/io.h (audited, kept - not
// cosmetic duplication): see stm32f103/avr/io.h's header comment for the
// full explanation. Short version: this port's own -I. precedes
// -I../common/dummy, so this file shadows the dummy's #error stub and
// supplies real CPSIE/CPSID sei()/cli() here (CONTRACTS.md §11) instead of
// in platform.h, unlike samd21/ch32v006/ch570/dspic33ak128mc102/_template.
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// STM32F411 ARM Cortex-M4 interrupt control
// Use inline assembly for direct CPSIE/CPSID instructions
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

#endif
