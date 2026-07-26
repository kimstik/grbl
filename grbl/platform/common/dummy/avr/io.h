// AVR stub for non-AVR platforms
//
// Platform-specific interrupt control (sei/cli) must be defined by the time
// this file is reached (CONTRACTS.md §11: "Non-AVR must define both"). Two
// legal routes, both live in this tree - the #ifndef guards below pass
// silently under either:
//   (1) Define sei()/cli() directly in the platform's own platform.h,
//       injected earlier in the prelude chain than this file - this file is
//       then included as-is (never overridden). Reference: samd21/
//       platform.h:206-207; also ch32v006/ch570/dspic33ak128mc102/_template.
//   (2) Ship a platform-local avr/io.h (same relative path as this file)
//       whose directory is listed with -I before -I.../common/dummy in the
//       Makefile's CFLAGS_EXTRA - it shadows this file entirely and
//       defines sei()/cli() itself. Reference: stm32f103/avr/io.h (and its
//       header comment for the full writeup); stm32h523/stm32f411/
//       hc32f460 copy the same mechanism.
// If you hit the #error below, your new port took neither route - pick
// one, don't work around the error by weakening this guard.
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// Platform must provide sei() and cli() definitions
#ifndef sei
  #error "sei() must be defined by platform (platform.h, or a shadowing platform/<name>/avr/io.h - see this file's header comment)"
#endif
#ifndef cli
  #error "cli() must be defined by platform (platform.h, or a shadowing platform/<name>/avr/io.h - see this file's header comment)"
#endif

#endif
