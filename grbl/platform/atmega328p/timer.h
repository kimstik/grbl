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

// NEW SHORT NAMES (for migrated code)

// ISR definitions
#define ISR_STEP()          ISR(TIMER1_COMPA_vect)
#define ISR_STEP_RESET()    ISR(TIMER0_OVF_vect)
#define ISR_STEP_DELAY()    ISR(TIMER0_COMPA_vect)

// Stepper timer - Issue #1 FIX: Use bitwise operations (&=, |=) not assignment
#define STP_TMR_INIT() \
  ( \
    TCCR1B &= ~(1<<WGM13), \
    TCCR1B |=  (1<<WGM12), \
    TCCR1A &= ~((1<<WGM11) | (1<<WGM10)), \
    TCCR1A &= ~((1<<COM1A1) | (1<<COM1A0) | (1<<COM1B1) | (1<<COM1B0)) \
  )

#define STP_TMR_INT_ENA()               (TIMSK1 |=  (1<<OCIE1A))
#define STP_TMR_INT_DIS()               (TIMSK1 &= ~(1<<OCIE1A))
#define STP_TMR_PERIOD_SET(cycles)      (OCR1A = (cycles))
#define STP_TMR_PRESCALER_SET(prescaler)  (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | ((prescaler) << CS10))
#define STP_TMR_PRESCALER_RESET()       (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | (1<<CS10))

// Pulse reset timer - Issue #2 FIX: Must initialize TIMSK0
#define STP_PULSE_RESET_INIT() \
  ( \
    TIMSK0 &= ~((1<<OCIE0B) | (1<<OCIE0A) | (1<<TOIE0)), \
    TCCR0A = 0, \
    TCCR0B = 0, \
    TIMSK0 |= (1<<TOIE0) \
  )

#define STP_PULSE_RESET_START()         (TCCR0B = (1<<CS01))
#define STP_PULSE_RESET_STOP()          (TCCR0B = 0)
#define STP_PULSE_RESET_COUNT_SET(val)  (TCNT0 = (val))
#define STP_PULSE_RESET_COMPARE_SET(val) (OCR0A = (val))

#ifdef STEP_PULSE_DELAY
  #define STP_PULSE_DELAY_INIT()        (TIMSK0 |= (1<<OCIE0A))
#endif

// PWM timer - Issue #3 FIX: Must set WGM20|WGM21 and CS22, not zero
#define PWM_INIT() \
  TCCR2A = ((1<<WGM20) | (1<<WGM21)); \
  TCCR2B = (1<<CS22)

#define PWM_ENABLE()            (TCCR2A |= (1<<COM2A1))
#define PWM_DISABLE()           (TCCR2A &= ~(1<<COM2A1))
#define PWM_IS_ENABLED()        (TCCR2A & (1<<COM2A1))
#define PWM_SET(duty_value)     (OCR2A = (duty_value))
