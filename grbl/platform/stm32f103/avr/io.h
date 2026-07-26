// AVR compatibility for STM32F103 (ARM Cortex-M3)
//
// REAL DIFFERENCE vs ../../common/dummy/avr/io.h (audited, kept - not
// cosmetic duplication): the shared dummy header #errors unless sei()/cli()
// are ALREADY defined by the time it's reached ("Platform must provide
// sei() and cli()"). This platform's own -I. precedes -I../common/dummy
// (CFLAGS_EXTRA order in the Makefile), so THIS file shadows the dummy one
// entirely and supplies the real CPSIE/CPSID definitions itself
// (CONTRACTS.md §11: "Non-AVR must define both"). stm32h523/stm32f411/
// hc32f460 use the identical mechanism (their own avr/io.h, content
// differing only in the header comment). samd21/ch32v006/ch570/
// dspic33ak128mc102/_template take the OTHER legal route instead: they
// define sei()/cli() directly in platform.h, which - because platform.h is
// injected before this compat header in their prelude chain - makes the
// dummy's #ifndef guard see them already defined and its #error never
// fires, with no local avr/io.h needed at all. Both routes satisfy the
// same contract; this port's four files were never reconciled into the
// platform.h convention. Left as-is (not restructured) to avoid touching a
// golden-byte-identical build for a pure style unification - see the
// cross-port consistency audit note in PLAN.md/CONTRACTS.md if you do
// decide to unify them later.
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// STM32F103 ARM Cortex-M3 interrupt control
// Use inline assembly for direct CPSIE/CPSID instructions
#define sei()  __asm volatile ("cpsie i" : : : "memory")
#define cli()  __asm volatile ("cpsid i" : : : "memory")

#endif
