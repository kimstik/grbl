// AVR stub for non-AVR platforms
//
// Platform-specific interrupt control (sei/cli) must be defined
// in each platform's own avr/io.h file.
// Example: platform/samd21/avr/io.h
//
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// Platform must provide sei() and cli() definitions
// Each platform should define these in platform/[name]/avr/io.h
#ifndef sei
  #error "sei() must be defined by platform (in platform/[name]/avr/io.h)"
#endif
#ifndef cli
  #error "cli() must be defined by platform (in platform/[name]/avr/io.h)"
#endif

#endif
