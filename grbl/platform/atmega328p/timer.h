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

#include <avr/io.h>
#include <avr/interrupt.h>

// ============================================================================
// ISR DEFINITIONS
// ============================================================================

#define ISR_STEP()          ISR(TIMER1_COMPA_vect)   // Stepper ISR
#define ISR_STEP_RESET()    ISR(TIMER0_OVF_vect)     // Step pulse reset ISR
#define ISR_STEP_DELAY()    ISR(TIMER0_COMPA_vect)   // Step pulse delay ISR (optional)

// ============================================================================
// STEPPER TIMER (TIMER1 - 16-bit)
// ============================================================================

#define STP_TMR_INIT() \
do { \
  TCCR1B = 0; \
  TCCR1A = 0; \
  TCCR1B = (1<<WGM12); \
} while(0)

#define STP_TMR_INT_ENA()               (TIMSK1 |=  (1<<OCIE1A))
#define STP_TMR_INT_DIS()               (TIMSK1 &= ~(1<<OCIE1A))
#define STP_TMR_PERIOD_SET(cycles)      (OCR1A = (cycles))
#define STP_TMR_PRESCALER_SET(prescaler)  (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | ((prescaler) << CS10))
#define STP_TMR_PRESCALER_RESET()       (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | (1<<CS10))

// ============================================================================
// STEP PULSE RESET TIMER (TIMER0 - 8-bit)
// ============================================================================

#define STP_PULSE_RESET_INIT() \
do { \
  TCCR0A = 0; \
  TCCR0B = 0; \
} while(0)

#define STP_PULSE_RESET_START()         (TCCR0B = (1<<CS01))
#define STP_PULSE_RESET_STOP()          (TCCR0B = 0)
#define STP_PULSE_RESET_COUNT_SET(val)  (TCNT0 = (val))
#define STP_PULSE_RESET_COMPARE_SET(val) (OCR0A = (val))

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_DELAY_INIT()        (TIMSK0 |= (1<<OCIE0A))
#endif

// ============================================================================
// SPINDLE PWM TIMER (TIMER2 - 8-bit)
// ============================================================================

#define PWM_INIT() \
do { \
  TCCR2B = 0; \
  TCCR2A = 0; \
} while(0)

#define PWM_ENABLE()            (TCCR2A |= (1<<COM2A1))
#define PWM_DISABLE()           (TCCR2A &= ~(1<<COM2A1))
#define PWM_IS_ENABLED()        (TCCR2A & (1<<COM2A1))
#define PWM_SET(duty_value)     (OCR2A = (duty_value))

// ============================================================================
// TIMER CONSTANTS
// ============================================================================

// Note: TICKS_PER_MICROSECOND already defined in nuts_bolts.h
// Avoid redefinition warning by not defining it here

// ============================================================================
// BACKWARD COMPATIBILITY (still used in base code)
// TODO: Replace in base code with new short names
// ============================================================================

// Stepper timer
#define HAL_TIMER_STEPPER_INIT()                    STP_TMR_INIT()
#define HAL_TIMER_STEPPER_SET_PRESCALER(prescaler)  STP_TMR_PRESCALER_SET(prescaler)

// Pulse reset timer
#define HAL_TIMER_PULSE_RESET_INIT()                STP_PULSE_RESET_INIT()
#define HAL_TIMER_PULSE_RESET_SET_COUNT(val)        STP_PULSE_RESET_COUNT_SET(val)
#define HAL_TIMER_PULSE_RESET_SET_COMPARE(val)      STP_PULSE_RESET_COMPARE_SET(val)

#ifdef STEP_PULSE_DELAY
  #define HAL_TIMER_PULSE_DELAY_INIT()              STP_PULSE_DELAY_INIT()
#endif

// Spindle PWM
#define HAL_TIMER_SPINDLE_PWM_INIT()                PWM_INIT()
#define HAL_TIMER_SPINDLE_PWM_ENABLE()              PWM_ENABLE()
#define HAL_TIMER_SPINDLE_PWM_DISABLE()             PWM_DISABLE()
#define HAL_TIMER_SPINDLE_PWM_SET_DUTY(val)         PWM_SET(val)
