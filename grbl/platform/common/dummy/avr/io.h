// avr/io.h - AVR stub for non-AVR platforms; see common/platform.md

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
