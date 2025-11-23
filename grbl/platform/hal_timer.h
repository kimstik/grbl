/*
  hal_timer.h - Timer HAL (stepper interrupt, PWM, delays)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

#ifndef HAL_TIMER_H
#define HAL_TIMER_H

//FIXME: this file have to be NOT used anymore- use platform specific /timer.h

/*
#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// TIMER IDENTIFIERS
// ============================================================================

// Standard GRBL timers (logical names)
typedef enum {
  HAL_TIMER_STEPPER = 0,        // Main stepper interrupt (TIMER1 on AVR)
  HAL_TIMER_STEP_PULSE_RESET,   // Step pulse reset (TIMER0 on AVR)
  HAL_TIMER_SPINDLE_PWM,        // Spindle PWM (TIMER2 on AVR)
  HAL_TIMER_COUNT
} hal_timer_id_t;

// ============================================================================
// PLATFORM-SPECIFIC IMPLEMENTATIONS
// ============================================================================

#ifdef __AVR__

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

#else
  // ============================================================================
  // OTHER PLATFORMS - Function-based implementations
  // ============================================================================

  // --------------------------------------------------------------------------
  // STEPPER TIMER
  // --------------------------------------------------------------------------

  void hal_timer_stepper_init(void);
  void hal_timer_stepper_start(void);
  void hal_timer_stepper_stop(void);
  void hal_timer_stepper_set_period(uint32_t ticks);
  uint32_t hal_timer_stepper_get_count(void);

  #ifndef HAL_TIMER_STEPPER_INIT
    #define HAL_TIMER_STEPPER_INIT()            hal_timer_stepper_init()
  #endif
  #ifndef HAL_TIMER_STEPPER_START
    #define HAL_TIMER_STEPPER_START()           hal_timer_stepper_start()
  #endif
  #ifndef HAL_TIMER_STEPPER_STOP
    #define HAL_TIMER_STEPPER_STOP()            hal_timer_stepper_stop()
  #endif
  #ifndef HAL_TIMER_STEPPER_SET_PERIOD
    #define HAL_TIMER_STEPPER_SET_PERIOD(t)     hal_timer_stepper_set_period(t)
  #endif
  #ifndef HAL_TIMER_STEPPER_GET_COUNT
    #define HAL_TIMER_STEPPER_GET_COUNT()       hal_timer_stepper_get_count()
  #endif

  // ISR prototype (implemented in platform code)
  #ifndef HAL_TIMER_STEPPER_ISR
    #define HAL_TIMER_STEPPER_ISR()  void hal_timer_stepper_isr(void)
  #endif

  // --------------------------------------------------------------------------
  // STEP PULSE RESET TIMER
  // --------------------------------------------------------------------------

  void hal_timer_pulse_reset_init(void);
  void hal_timer_pulse_reset_config_ovf(uint32_t prescaler);
  void hal_timer_pulse_reset_config_cmp(uint32_t prescaler);
  void hal_timer_pulse_reset_set_count(uint32_t value);
  void hal_timer_pulse_reset_set_compare(uint32_t value);
  uint32_t hal_timer_pulse_reset_get_count(void);
  void hal_timer_pulse_reset_ovf_enable(void);
  void hal_timer_pulse_reset_ovf_disable(void);
  void hal_timer_pulse_reset_cmp_enable(void);
  void hal_timer_pulse_reset_cmp_disable(void);

  #ifndef HAL_TIMER_PULSE_RESET_INIT
    #define HAL_TIMER_PULSE_RESET_INIT()              hal_timer_pulse_reset_init()
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_CONFIG_OVF
    #define HAL_TIMER_PULSE_RESET_CONFIG_OVF(p)       hal_timer_pulse_reset_config_ovf(p)
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_CONFIG_CMP
    #define HAL_TIMER_PULSE_RESET_CONFIG_CMP(p)       hal_timer_pulse_reset_config_cmp(p)
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_SET_COUNT
    #define HAL_TIMER_PULSE_RESET_SET_COUNT(v)        hal_timer_pulse_reset_set_count(v)
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_SET_COMPARE
    #define HAL_TIMER_PULSE_RESET_SET_COMPARE(v)      hal_timer_pulse_reset_set_compare(v)
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_GET_COUNT
    #define HAL_TIMER_PULSE_RESET_GET_COUNT()         hal_timer_pulse_reset_get_count()
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_OVF_ENABLE
    #define HAL_TIMER_PULSE_RESET_OVF_ENABLE()        hal_timer_pulse_reset_ovf_enable()
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_OVF_DISABLE
    #define HAL_TIMER_PULSE_RESET_OVF_DISABLE()       hal_timer_pulse_reset_ovf_disable()
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_CMP_ENABLE
    #define HAL_TIMER_PULSE_RESET_CMP_ENABLE()        hal_timer_pulse_reset_cmp_enable()
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_CMP_DISABLE
    #define HAL_TIMER_PULSE_RESET_CMP_DISABLE()       hal_timer_pulse_reset_cmp_disable()
  #endif

  // ISR prototypes
  #ifndef HAL_TIMER_PULSE_RESET_OVF_ISR
    #define HAL_TIMER_PULSE_RESET_OVF_ISR()  void hal_timer_pulse_reset_ovf_isr(void)
  #endif
  #ifndef HAL_TIMER_PULSE_RESET_CMP_ISR
    #define HAL_TIMER_PULSE_RESET_CMP_ISR()  void hal_timer_pulse_reset_cmp_isr(void)
  #endif

  // --------------------------------------------------------------------------
  // SPINDLE PWM TIMER
  // --------------------------------------------------------------------------

  void hal_timer_spindle_pwm_init(void);
  void hal_timer_spindle_pwm_config(uint32_t frequency_hz);
  void hal_timer_spindle_pwm_set_duty(uint16_t value);
  uint16_t hal_timer_spindle_pwm_get_duty(void);
  void hal_timer_spindle_pwm_enable(void);
  void hal_timer_spindle_pwm_disable(void);

  #ifndef HAL_TIMER_SPINDLE_PWM_INIT
    #define HAL_TIMER_SPINDLE_PWM_INIT()        hal_timer_spindle_pwm_init()
  #endif
  #ifndef HAL_TIMER_SPINDLE_PWM_CONFIG
    #define HAL_TIMER_SPINDLE_PWM_CONFIG(f)     hal_timer_spindle_pwm_config(f)
  #endif
  #ifndef HAL_TIMER_SPINDLE_PWM_SET_DUTY
    #define HAL_TIMER_SPINDLE_PWM_SET_DUTY(v)   hal_timer_spindle_pwm_set_duty(v)
  #endif
  #ifndef HAL_TIMER_SPINDLE_PWM_GET_DUTY
    #define HAL_TIMER_SPINDLE_PWM_GET_DUTY()    hal_timer_spindle_pwm_get_duty()
  #endif
  #ifndef HAL_TIMER_SPINDLE_PWM_ENABLE
    #define HAL_TIMER_SPINDLE_PWM_ENABLE()      hal_timer_spindle_pwm_enable()
  #endif
  #ifndef HAL_TIMER_SPINDLE_PWM_DISABLE
    #define HAL_TIMER_SPINDLE_PWM_DISABLE()     hal_timer_spindle_pwm_disable()
  #endif

  // --------------------------------------------------------------------------
  // PLATFORM CONSTANTS
  // --------------------------------------------------------------------------

  // Defined in platform.h for each platform
  extern const uint32_t hal_timer_cpu_freq;
  extern const uint32_t hal_ticks_per_microsecond;

  #define HAL_TIMER_CPU_FREQ         hal_timer_cpu_freq
  #define HAL_TICKS_PER_MICROSECOND  hal_ticks_per_microsecond

#endif

// ============================================================================
// COMMON TIMER UTILITIES (all platforms)
// ============================================================================

// Convert microseconds to timer ticks
#define HAL_TIMER_US_TO_TICKS(us)  ((us) * HAL_TICKS_PER_MICROSECOND)

// Convert milliseconds to timer ticks
#define HAL_TIMER_MS_TO_TICKS(ms)  ((ms) * 1000UL * HAL_TICKS_PER_MICROSECOND)

// Convert timer ticks to microseconds
#define HAL_TIMER_TICKS_TO_US(ticks)  ((ticks) / HAL_TICKS_PER_MICROSECOND)

*/

#endif // HAL_TIMER_H
