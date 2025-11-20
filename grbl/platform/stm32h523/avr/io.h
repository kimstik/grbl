// AVR compatibility for STM32H523 (ARM Cortex-M33)
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// STM32H523 ARM Cortex-M33 interrupt control
// Use inline assembly for direct CPSIE/CPSID instructions
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

#endif
