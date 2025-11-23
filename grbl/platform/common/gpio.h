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
#define BIT_AI(x, nbit)		( x & ~BIT_MSK(nbit) )
#define BIT_XR(x, nbit)		( x ^  BIT_MSK(nbit) )

#define BIT_SET(x, nbit)	((x) |=  BIT_MSK(nbit))
#define BIT_CLR(x, nbit)	((x) &= ~BIT_MSK(nbit))
#define BIT_TGL(x, nbit)	((x) ^=  BIT_MSK(nbit))

#define MSK_SET(x, mask)	((x) |=  (mask))
#define MSK_CLR(x, mask)	((x) &= ~(mask))
#define MSK_TGL(x, mask)	((x) ^=  (mask))

//--  internal part --

#if !defined(GPIO_MSK)
 #define GPIO_MSK(name)		BIT_MSK( name##_BIT )
#endif

#if !defined(GPIO_OREG)
 #define GPIO_OREG(name)	name##_PORT
#endif

#if !defined(GPIO_IREG)
 #define GPIO_IREG(name)	name##_PIN	// GPIO pin read (LIMIT/CONTROL/PROBE)	AVR strange naming used _PIN as data input reg... lets survive on this condition...
#endif

#if !defined(GPIO_DREG)
 #define GPIO_DREG(name)	name##_DDR	// AVR-specific naming - subject to be redefined in platform
#endif

#if !defined(GPIO_PREG)
 #define GPIO_PREG(name)	name##_PORT // AVR-specific - default
#endif

// TODO: BWR/BRD potom pereiminuem v RD/WR (kogra izbavimsya ot HAL kolliziy)
#define GPIO_BWR(name, reg,  op)		   BIT_##op( GPIO_##reg(name), name##_BIT  )	//	bit write op
#define GPIO_BRD(name, reg     )		( GPIO_##reg(name) & BIT_MSK(  name##_BIT) )	//	bit read
#define GPIO_MWR(name, reg,  op)		   MSK_##op( GPIO_##reg(name), name##_MASK )	//	mask write op
#define GPIO_MWV(name, reg, val)		( GPIO_##reg(name) = (GPIO_##reg(name) & ~name##_MASK) | (val) )	//	mask write value
#define GPIO_MWO(name, val     )			GPIO_MWV( name, OREG, val )					//	mask write OREG shorthand
#define GPIO_MRD(name, reg     )		( GPIO_##reg(name) & name##_MASK )				//	read by mask 

//---------------------------------------------------------------------
//-- finally usefull part - have to be used in GRBL base core mostly --
// platforms may redefine them also in very flexible way by cherry-picking

#if !defined(GPIO_BSET)
 #define GPIO_BSET(name)  		GPIO_BWR( name, OREG, SET )	// Set    gpio pin ( = 1)
#endif

#if !defined(GPIO_BCLR)
 #define GPIO_BCLR(name)  		GPIO_BWR( name, OREG, CLR )	// Clear  gpio pin ( = 0)
#endif

#if !defined(GPIO_BTGL)
 #define GPIO_BTGL(name)  		GPIO_BWR( name, OREG, TGL )	// Toggle gpio pin
#endif

#if !defined(GPIO_DIR_OUT)
 #define GPIO_DIR_OUT(name)  	GPIO_BWR( name, DREG, SET )	// Set gpio pin as output
#endif

#if !defined(GPIO_DIR_INP)
 #define GPIO_DIR_INP(name)  	GPIO_BWR( name, DREG, CLR )	// Set gpio pin as input
#endif

#if !defined(GPIO_PULLUP_EN)
 #define GPIO_PULLUP_EN( name)	GPIO_BWR( name, PREG, SET )	// GPIO pin pull-up enable
#endif

#if !defined(GPIO_PULLUP_DIS)
 #define GPIO_PULLUP_DIS(name)	GPIO_BWR( name, PREG, CLR )
#endif

// Multi-bit versions (for composite masks like STEP_MASK, LIMIT_MASK)
#if !defined(GPIO_MDIR_OUT)
 #define GPIO_MDIR_OUT(name)	GPIO_MWR( name, DREG, SET )	// Set multiple gpio pins as output
#endif

#if !defined(GPIO_MDIR_INP)
 #define GPIO_MDIR_INP(name)	GPIO_MWR( name, DREG, CLR )	// Set multiple gpio pins as input
#endif

#if !defined(GPIO_MPULLUP_EN)
 #define GPIO_MPULLUP_EN(name)	GPIO_MWR( name, PREG, SET )	// Enable pullup on multiple gpio pins
#endif

#if !defined(GPIO_MPULLUP_DIS)
 #define GPIO_MPULLUP_DIS(name)	GPIO_MWR( name, PREG, CLR )	// Disable pullup on multiple gpio pins
#endif

#if !defined(GPIO_BGET)
 #define GPIO_BGET(name) 	 	( !(GPIO_BRD(name, IREG)) != 0 )	// GPIO pin get/read (LIMIT/CONTROL/PROBE)
#endif

#if !defined(GPIO_BGETOUT)
 #define GPIO_BGETOUT(name) 	GPIO_BRD(name, OREG)	// GPIO output pin state read (COOLANT/SPINDLE)
#endif

#endif // GPIO_H
