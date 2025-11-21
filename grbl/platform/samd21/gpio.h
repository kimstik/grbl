/*
  gpio.h - FIXME:...
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

// platform specific notation - to be defined before platform\common\gpio.h 

#define GPIO_OREG(name)	PORT->Group[name##_PORT].OUT	// GPIO output register - to write to                         
#define GPIO_IREG(name)	PORT->Group[name##_PORT].IN		// GPIO input register  - tp read from (LIMIT/CONTROL/PROBE)  
#define GPIO_DREG(name)	PORT->Group[name##_PORT].DIR    // GPIO direction control reg                                 
#define GPIO_PREG(name)	PORT->Group[name##_PORT].CTRL   // GPIO pullup control                                        

#endif // GPIO_SAMD_H
