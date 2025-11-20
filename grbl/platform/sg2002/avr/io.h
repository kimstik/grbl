// AVR compatibility for SG2002 (RISC-V)
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On RISC-V, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// SG2002 RISC-V interrupt control
// Use inline assembly for RISC-V CSR manipulation
#define sei()  __asm volatile ("csrsi mstatus, 8" : : : "memory")
#define cli()  __asm volatile ("csrci mstatus, 8" : : : "memory")

#endif
