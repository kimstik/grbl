//AVR specific timer primitives with correct naming

/* T_O_D_O list - _keep_ me compact for reference at the file top

// spindle_control.c
PWM_INIT();				<- HAL_TIMER_SPINDLE_PWM_INIT();			
PWM_DISABLE();          <- HAL_TIMER_SPINDLE_PWM_DISABLE();		
PWM_ENABLE();           <- HAL_TIMER_SPINDLE_PWM_ENABLE();			
PWM_IS_ENABLED()        <- HAL_TIMER_SPINDLE_PWM_IS_ENABLED()		
PWM_SET(duty_value);    <- HAL_TIMER_SPINDLE_PWM_SET_DUTY(pwm_value);

// stepper.c
STP_PULSE_DELAY_INIT()					<- HAL_TIMER_PULSE_DELAY_INIT();				  

STP_PULSE_RESET_INIT()                  <- HAL_TIMER_PULSE_RESET_INIT();				  
STP_PULSE_RESET_COMPARE_SET(val);       <- HAL_TIMER_PULSE_RESET_SET_COMPARE(val);		                                              
STP_PULSE_RESET_COUNT_SET(val);         <- HAL_TIMER_PULSE_RESET_SET_COUNT(val);  		  
STP_PULSE_RESET_START();                <- HAL_TIMER_PULSE_RESET_START();		 		  
STP_PULSE_RESET_STOP();                 <- HAL_TIMER_PULSE_RESET_STOP();		  		  

STP_TMR_INIT();              		    <- HAL_TIMER_STEPPER_INIT();			  		  
STP_TMR_INT_DIS(); 		                <- HAL_TIMER_STEPPER_INTERRUPT_DISABLE(); 		  
STP_TMR_INT_ENA();  		            <- HAL_TIMER_STEPPER_INTERRUPT_ENABLE();  		  
STP_TMR_PERIOD_SET(val);			    <- HAL_TIMER_STEPPER_SET_PERIOD(val);			  
STP_TMR_PRESCALER_SET(val);		        <- HAL_TIMER_STEPPER_SET_PRESCALER(val);		  
STP_TMR_PRESCALER_RESET();   		    <- HAL_TIMER_STEPPER_RESET_PRESCALER();   		  
*/                                         
                                           
                                           
                                           
#define STP_TMR_PERIOD_SET(cycles)    (OCR1A = (cycles))
//#define HAL_TIMER_STEPPER_GET_PERIOD()          (OCR1A)
//#define HAL_TIMER_STEPPER_GET_COUNT()           (TCNT1)

#define STP_TMR_PRESCALER_SET(prescaler)	(TCCR1B = (TCCR1B & ~(0x07<<CS10)) | ((prescaler) << CS10))
#define STP_TMR_PRESCALER_RESET()			(TCCR1B = (TCCR1B & ~(0x07<<CS10)) | (1<<CS10))

#define STP_PULSE_RESET_START()           	(TCCR0B = (1<<CS01))
#define STP_PULSE_RESET_STOP()            	(TCCR0B = 0)




// !! TODO: following oa OUTDTAED code - TO BE updated !!!
// TODO: HAL_ prefixs is forbidden! have to disappear absolutely

// ============================================================================
// AVR IMPLEMENTATION - ZERO OVERHEAD
// ============================================================================

#include <avr/io.h>
#include <avr/interrupt.h>

// --------------------------------------------------------------------------
// STEPPER TIMER (TIMER1 - 16-bit)
// --------------------------------------------------------------------------

// Initialize stepper timer
// Expands to original GRBL code - identical assembly!
#define HAL_TIMER_STEPPER_INIT() \
do { \
  TCCR1B = 0; \
  TCCR1A = 0; \
  TCCR1B = (1<<WGM12); \
} while(0)

// Start stepper timer
#define HAL_TIMER_STEPPER_START() \
do { \
  TCNT1 = 0; \
  TCCR1B |= (1<<CS10); \
  TIMSK1 |= (1<<OCIE1A); \
} while(0)

// Stop stepper timer
#define HAL_TIMER_STEPPER_STOP() \
do { \
  TCCR1B &= ~((1<<CS12) | (1<<CS11) | (1<<CS10)); \
  TIMSK1 &= ~(1<<OCIE1A); \
} while(0)

// Set stepper timer period (in ticks)
#define HAL_TIMER_STEPPER_SET_PERIOD(ticks)  (OCR1A = (ticks))

// Get stepper timer counter
#define HAL_TIMER_STEPPER_GET_COUNT()  (TCNT1)

// Stepper ISR definition
#define HAL_TIMER_STEPPER_ISR()  ISR(TIMER1_COMPA_vect)

// --------------------------------------------------------------------------
// STEP PULSE RESET TIMER (TIMER0 - 8-bit)
// --------------------------------------------------------------------------

// Initialize step pulse reset timer
#define HAL_TIMER_PULSE_RESET_INIT() \
do { \
  TCCR0A = 0; \
  TCCR0B = 0; \
} while(0)

// Configure for overflow interrupt
#define HAL_TIMER_PULSE_RESET_CONFIG_OVF(prescaler) \
do { \
  TCCR0B = (prescaler); \
  TIMSK0 |= (1<<TOIE0); \
} while(0)

// Configure for compare match interrupt
#define HAL_TIMER_PULSE_RESET_CONFIG_CMP(prescaler) \
do { \
  TCCR0A = (1<<WGM01); \
  TCCR0B = (prescaler); \
  TIMSK0 |= (1<<OCIE0A); \
} while(0)

// Set timer0 counter value
#define HAL_TIMER_PULSE_RESET_SET_COUNT(value)  (TCNT0 = (value))

// Set timer0 compare value
#define HAL_TIMER_PULSE_RESET_SET_COMPARE(value)  (OCR0A = (value))

// Get timer0 counter
#define HAL_TIMER_PULSE_RESET_GET_COUNT()  (TCNT0)

// Enable/disable overflow interrupt
#define HAL_TIMER_PULSE_RESET_OVF_ENABLE()   (TIMSK0 |= (1<<TOIE0))
#define HAL_TIMER_PULSE_RESET_OVF_DISABLE()  (TIMSK0 &= ~(1<<TOIE0))

// Enable/disable compare interrupt
#define HAL_TIMER_PULSE_RESET_CMP_ENABLE()   (TIMSK0 |= (1<<OCIE0A))
#define HAL_TIMER_PULSE_RESET_CMP_DISABLE()  (TIMSK0 &= ~(1<<OCIE0A))

// ISR definitions
#define HAL_TIMER_PULSE_RESET_OVF_ISR()  ISR(TIMER0_OVF_vect)
#define HAL_TIMER_PULSE_RESET_CMP_ISR()  ISR(TIMER0_COMPA_vect)

// Timer prescaler constants
#define HAL_TIMER0_PRESCALER_1     ((1<<CS00))
#define HAL_TIMER0_PRESCALER_8     ((1<<CS01))
#define HAL_TIMER0_PRESCALER_64    ((1<<CS01)|(1<<CS00))
#define HAL_TIMER0_PRESCALER_256   ((1<<CS02))
#define HAL_TIMER0_PRESCALER_1024  ((1<<CS02)|(1<<CS00))

// --------------------------------------------------------------------------
// SPINDLE PWM TIMER (TIMER2 - 8-bit)
// --------------------------------------------------------------------------

// Initialize spindle PWM
#define HAL_TIMER_SPINDLE_PWM_INIT() \
do { \
  TCCR2B = 0; \
  TCCR2A = 0; \
} while(0)

// Configure fast PWM mode
#define HAL_TIMER_SPINDLE_PWM_CONFIG(prescaler) \
do { \
  TCCR2A = (1<<COM2A1) | (1<<WGM21) | (1<<WGM20); \
  TCCR2B = (prescaler); \
} while(0)

// Set PWM duty cycle (0-255)
#define HAL_TIMER_SPINDLE_PWM_SET_DUTY(value)  (OCR2A = (value))

// Get PWM duty cycle
#define HAL_TIMER_SPINDLE_PWM_GET_DUTY()  (OCR2A)

// Enable/disable PWM output
#define HAL_TIMER_SPINDLE_PWM_ENABLE()   (TCCR2A |= (1<<COM2A1))
#define HAL_TIMER_SPINDLE_PWM_DISABLE()  (TCCR2A &= ~(1<<COM2A1))

// Timer2 prescaler constants
#define HAL_TIMER2_PRESCALER_1     ((1<<CS20))
#define HAL_TIMER2_PRESCALER_8     ((1<<CS21))
#define HAL_TIMER2_PRESCALER_32    ((1<<CS21)|(1<<CS20))
#define HAL_TIMER2_PRESCALER_64    ((1<<CS22))
#define HAL_TIMER2_PRESCALER_128   ((1<<CS22)|(1<<CS20))
#define HAL_TIMER2_PRESCALER_256   ((1<<CS22)|(1<<CS21))
#define HAL_TIMER2_PRESCALER_1024  ((1<<CS22)|(1<<CS21)|(1<<CS20))

// --------------------------------------------------------------------------
// TIMER CONSTANTS
// --------------------------------------------------------------------------

// CPU frequency (from F_CPU define in Makefile)
#define HAL_TIMER_CPU_FREQ  F_CPU

// Ticks per microsecond
#define HAL_TICKS_PER_MICROSECOND  (F_CPU/1000000UL)
