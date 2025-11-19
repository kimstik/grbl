// AVR stub for non-AVR platforms
#ifndef _AVR_IO_H_
#define _AVR_IO_H_

// On ARM, constants go to Flash automatically, no special attribute needed
#ifndef __flash
  #define __flash const
#endif

// AVR interrupt functions compatibility
#define sei()  __enable_irq()
#define cli()  __disable_irq()

#endif
