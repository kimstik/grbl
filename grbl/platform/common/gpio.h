/*
  gpio.h - GPIO abstraction for ALL platforms
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  NOTE: This file is auto-included via -include flag in Makefile
*/

#ifndef GPIO_H
#define GPIO_H

// -- generic part --
#define BIT_MSK(nbit)		( 1<<(nbit) )

#define BIT_OR(x, nbit)		( x |  BIT_MSK(nbit) )
#define BIT_AI( x, nbit)	( x & ~BIT_MSK(nbit) )
#define BIT_XR(x, nbit)		( x ^  BIT_MSK(nbit) )
                               
#define BIT_SET(x, nbit)	{ x |=  BIT_MSK(nbit); }
#define BIT_CLR( x, nbit)	{ x &= ~BIT_MSK(nbit); }
#define BIT_TGL(x, nbit)	{ x ^=  BIT_MSK(nbit); }

// -- temporal workaround part --

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

#endif

//--  internal part --

#if !defined(GPIO_OUT_REG)
 #define GPIO_OUT_REG(name)	name##_PORT
#endif

#if !defined(GPIO_INP_REG)
 #define GPIO_INP_REG(name)	name##_PIN	// GPIO pin read (LIMIT/CONTROL/PROBE)	AVR strange naming used _PIN as data input reg... lets survive on this condition...
#endif

#if !defined(GPIO_DIR_REG)
 #define GPIO_DIR_REG(name)	name##_DDR	// AVR-specific naming - subject to be redefined in platform
#endif

#if !defined(GPIO_PU_REG)
 #define GPIO_PU_REG(name)	name##_PORT // AVR-specific - default
#endif


// __scratch__, keepme
//#define GPIO_PSET(port, val)  { GPIO_OUT_REG(port) = (val); }				// GPIO port write
//#define GPIO_PGET(port) 		( GPIO_INP_REG(port) )						// GPIO port read

//-- finally usefull part - have to be used in GRBL base core mostly --
// platforms may redefine them also in very flexible way by cherry-picking

#if !defined(GPIO_BSET)
 #define GPIO_BSET(name)  		BIT_SET( GPIO_OUT_REG(name), name##_BIT )	// Set    gpio pin ( = 1)
#endif

#if !defined(GPIO_BCLR)
 #define GPIO_BCLR(name)  		BIT_CLR( GPIO_OUT_REG(name), name##_BIT )	// Clear  gpio pin ( = 0)
#endif

#if !defined(GPIO_BTGL)
 #define GPIO_BTGL(name)  		BIT_TGL( GPIO_OUT_REG(name), name##_BIT )	// Toggle gpio pin
#endif

#if !defined(GPIO_DIR_OUT)
 #define GPIO_DIR_OUT(name)  	BIT_SET( GPIO_DIR_REG(name), name##_BIT )	// Set gpio pin as output
#endif

#if !defined(GPIO_DIR_INP)
 #define GPIO_DIR_INP(name)  	BIT_CLR( GPIO_DIR_REG(name), name##_BIT )	// Set gpio pin as input
#endif

#if !defined(GPIO_PULLUP_EN)
 #define GPIO_PULLUP_EN( name)	BIT_SET( GPIO_PU_REG(name),  name##_BIT )	// GPIO pin pull-up enable
#endif

#if !defined(GPIO_PULLUP_DIS)
 #define GPIO_PULLUP_DIS(name)	BIT_CLR( GPIO_PU_REG(name),  name##_BIT )
#endif

#if !defined(GPIO_BGET)
 #define GPIO_BGET(name) 	 	( !(GPIO_INP_REG(name) & BIT_MSK(name##_BIT)) != 0 )	// GPIO pin get/read (LIMIT/CONTROL/PROBE)
#endif

#endif // GPIO_H
