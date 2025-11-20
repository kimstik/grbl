// AVR compatibility for SAMD21 (ARM Cortex-M0+)
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// SAMD21 ARM Cortex-M0+ interrupt control
// Use inline assembly for direct CPSIE/CPSID instructions
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

#endif
