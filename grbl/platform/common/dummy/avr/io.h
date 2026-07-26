// AVR stub for non-AVR platforms
//
// Platform-specific interrupt control (sei/cli) must already be defined by
// the time grbl.h reaches its `#include <avr/io.h>` (grbl.h line 29) - this
// stub cannot know a given chip's interrupt primitive, so it errors out
// below rather than guessing. Ports satisfy that from their injected
// prelude.h, one of two ways:
//   - include the port's own platform.h from the prelude (samd21,
//     dspic33ak128mc102), or
//   - include a shared per-architecture critical-section header from the
//     prelude: common/cortexm/cortexm_critical.h (stm32f103/f411/h523,
//     hc32f460) or common/wch/wch_critical.h (ch32v006, ch570).
// sg2002 still carries a local avr/io.h that shadows this file via -I order.
//
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// Platform must provide sei() and cli() definitions before grbl.h runs
// (see the header comment above for the two supported injection routes)
#ifndef sei
  #error "sei() must be defined by the platform prelude (platform.h or common/<arch>/*_critical.h)"
#endif
#ifndef cli
  #error "cli() must be defined by the platform prelude (platform.h or common/<arch>/*_critical.h)"
#endif

#endif
