/*
  gpio.h - FIXME:...
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GPIO_H
#define GPIO_H

#define BIT_MSK(nbit)		( 1<<(nbit) )

#define BIT_OR(x, nbit)		( x |  BIT_MSK(nbit) )
#define BIT_AI( x, nbit)	( x & ~BIT_MSK(nbit) )
#define BIT_XR(x, nbit)		( x ^  BIT_MSK(nbit) )
                               
#define BIT_SET(x, nbit)	{ x |=  BIT_MSK(nbit); }
#define BIT_CLR( x, nbit)	{ x &= ~BIT_MSK(nbit); }
#define BIT_TGL(x, nbit)	{ x ^=  BIT_MSK(nbit); }

//---------------------------------------------------------------

#ifdef __AVR__	// in the far future it have to be dropped. keep it for the momemt for initial integritiy check

	// Port manipulation - CRITICAL: These must be identical to original GRBL!
	// Write multiple pins atomically with mask
	#define GPIO_WRITE_PORT(port, mask, value)	((port) = ((port) & ~(mask)) | ((value) & (mask)))

	// Write single pin
	#define GPIO_WRITE_PIN(port, pin, value) \
	do { \
	  if (value) \
	    (port) |= (1 << (pin)); \
	  else \
	    (port) &= ~(1 << (pin)); \
	} while(0)

#define GPIO_SET_OUT(name)  	BIT_SET( name##_DDR, name##_PIN )	// AVR-specific naming
#define GPIO_SET_INP(name)  	BIT_CLR( name##_DDR, name##_PIN )

#endif

//----------------------------------------------------------------


#if !defined(GPIO_PIN_RD)
 #define GPIO_PIN_RD(name) 	 	( !(name##_PORT & BIT_MSK(name##_PIN)) != 0 )	// GPIO pin read
#endif

// FIXME: following 9 macroses have to be (also, like one above) conditionaly defined. platforms may redefine them in very flexible way by cherrypicking

#define GPIO_BSET(name)  		BIT_SET( name##_PORT, name##_PIN ) // Set    gpio pin ( = 1)
#define GPIO_BCLR(name)  		BIT_CLR( name##_PORT, name##_PIN ) // Clear  gpio pin ( = 0)
#define GPIO_BTGL(name)  		BIT_TGL( name##_PORT, name##_PIN ) // Toggle gpio pin
                                
#define GPIO_DIR_OUT(name)  	BIT_SET( name##_DIR, name##_PIN )	// Set gpio pin as output
#define GPIO_DIR_INP(name)  	BIT_CLR( name##_DIR, name##_PIN )	// Set gpio pin as input

#define GPIO_PULLUP_EN( name)	BIT_SET( name##_PU, name##_PIN )	// GPIO pin pull-up enable
#define GPIO_PULLUP_DIS(name)	BIT_CLR( name##_PU, name##_PIN )

#define GPIO_WR(name, val)  	{ name##_PORT = (val); }			// GPIO port write
#define GPIO_RD(name) 		 	( name##_PORT )						// GPIO port read

#endif // GPIO_H
