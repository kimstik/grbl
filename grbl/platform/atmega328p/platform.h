/*
  platform.h - AVR ATmega328P platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for AVR ATmega328P.
  All definitions expand to original GRBL code for ZERO overhead.
*/

#ifndef PLATFORM_AVR_ATMEGA328P_H
#define PLATFORM_AVR_ATMEGA328P_H

#include "timer.h"
// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

#define PLATFORM_NAME     "AVR ATmega328P"
#define PLATFORM_CPU      "8-bit AVR"
#define PLATFORM_ARCH     "AVR"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           0
#define HAL_HAS_DMA           0
#define HAL_HAS_USB           0
#define HAL_HAS_HW_EEPROM     1
#define HAL_HAS_HW_MULTIPLY   0
#define HAL_HAS_HW_DIVIDE     0

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#define HAL_CPU_FREQ        F_CPU           // 16000000UL
#define HAL_RAM_SIZE        2048            // 2 KB
#define HAL_FLASH_SIZE      32768           // 32 KB
#define HAL_EEPROM_SIZE     1024            // 1 KB

// ============================================================================
// AVR HARDWARE INCLUDES
// ============================================================================

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>
#include <util/delay.h>

// ============================================================================
// CPU MAPPING - PIN DEFINITIONS
// ============================================================================

/*
  NOTE: For AVR ATmega328P, pin definitions are already in cpu_map.h
  This file only provides HAL macro abstractions that expand to the original code.
  Pin definitions are NOT redefined here to avoid conflicts.
*/

// Serial interrupt vectors (defined for consistency)
#ifndef SERIAL_RX
  #define SERIAL_RX     USART_RX_vect
#endif
#ifndef SERIAL_UDRE
  #define SERIAL_UDRE   USART_UDRE_vect
#endif


// ============================================================================
// TIMING FUNCTIONS (AVR-specific implementations)
// ============================================================================

// These will be implemented in platform.c (or inline here for AVR)

static inline uint32_t hal_millis(void) {
  // TODO: Implement using Timer0 overflow (Arduino-style millis())
  // For now, return 0 (will be implemented when integrating with core)
  extern volatile uint32_t _hal_millis_counter;
  return _hal_millis_counter;
}

static inline uint32_t hal_micros(void) {
  // TODO: Implement using Timer0 counter + overflow
  extern volatile uint32_t _hal_millis_counter;
  uint8_t oldSREG = SREG;
  cli();
  uint32_t m = _hal_millis_counter;
  uint8_t t = TCNT0;
  SREG = oldSREG;
  return (m * 1000) + (t * (64 / 16));  // Approximate
}

// ============================================================================
// HAL GPIO MACROS (ZERO OVERHEAD - expand to original AVR code)
// ============================================================================
/*
// Basic GPIO operations - expand to original GRBL code EXACTLY
#define HAL_GPIO_SET_BITS(port, mask)           ((port) |= (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)         ((port) &= ~(mask))
#define HAL_GPIO_TOGGLE_BITS(port, mask)        ((port) ^= (mask))
#define HAL_GPIO_WRITE_PORT(port, mask, value)  ((port) = ((port) & ~(mask)) | (value))
#define HAL_GPIO_READ_PORT(port, mask)          ((port) & (mask))
#define HAL_GPIO_READ_PIN(pin, mask)            ((pin) & (mask))
#define HAL_GPIO_WRITE_DIRECT(port, value)      ((port) = (value))

// GPIO direction configuration
#define HAL_GPIO_SET_OUTPUT(ddr, mask)          ((ddr) |= (mask))
#define HAL_GPIO_SET_INPUT(ddr, mask)           ((ddr) &= ~(mask))

// Pull-up resistor control
#define HAL_GPIO_PULLUP_ENABLE(port, mask)      ((port) |= (mask))
#define HAL_GPIO_PULLUP_DISABLE(port, mask)     ((port) &= ~(mask))

// Pin change interrupt configuration
// IMPORTANT: These must expand to EXACTLY the original code - no do-while, no if statements
#define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, pcie, mask) \
  ((pcmsk) |= (mask), PCICR |= (1 << (pcie)))

#define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, pcie, mask) \
  ((pcmsk) &= ~(mask), PCICR &= ~(1 << (pcie)))

// Pin change interrupt handlers
#define HAL_GPIO_IRQ_HANDLER(int_name)          ISR(int_name##_vect)
*/

#define GPIO_INT_ENA(name)	((name##_PCMSK) |=  (name##_MASK), PCICR |=  (1 << (name##_INT))) // <- GPIO_INT_ON( LIMIT_PCMSK, LIMIT_INT, LIMIT_MASK);
#define GPIO_INT_DIS(name)	((name##_PCMSK) &= ~(name##_MASK), PCICR &= ~(1 << (name##_INT))) // <- GPIO_INT_OFF(LIMIT_PCMSK, LIMIT_INT, LIMIT_MASK);
//#define GPIO_INT_ON(pcmsk, int_flag, mask)   HAL_GPIO_INTERRUPT_ENABLE(pcmsk, int_flag, mask)
//  GPIO_INT_ON(CONTROL_PCMSK, CONTROL_INT, CONTROL_MASK);

// #define HAL_GPIO_INTERRUPT_ENABLE(pcmsk, pcie, mask)   ((pcmsk) |= (mask), PCICR |= (1 << (pcie)))
// #define HAL_GPIO_INTERRUPT_DISABLE(pcmsk, pcie, mask)  ((pcmsk) &= ~(mask), PCICR &= ~(1 << (pcie)))

//#define HAL_GPIO_IRQ_HANDLER(name)  void name##_IRQHandler(void)
#define IRQ_HANDLER(name)  void name##_IRQHandler(void)



/*
// ============================================================================
// HAL TIMER MACROS (ZERO OVERHEAD - expand to original AVR code)
// ============================================================================

// ----------------------------------------------------------------------------
// TIMER1: Stepper Driver Interrupt (Main ISR - Bresenham algorithm)
// ----------------------------------------------------------------------------

#define HAL_TIMER_STEPPER_ISR()                 ISR(TIMER1_COMPA_vect)

#define HAL_TIMER_STEPPER_INIT() \
  ( \
    TCCR1B &= ~(1<<WGM13), \
    TCCR1B |=  (1<<WGM12), \
    TCCR1A &= ~((1<<WGM11) | (1<<WGM10)), \
    TCCR1A &= ~((1<<COM1A1) | (1<<COM1A0) | (1<<COM1B1) | (1<<COM1B0)) \
  )

#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)    (OCR1A = (cycles))
#define HAL_TIMER_STEPPER_GET_PERIOD()          (OCR1A)
#define HAL_TIMER_STEPPER_GET_COUNT()           (TCNT1)

#define HAL_TIMER_STEPPER_SET_PRESCALER(prescaler) \
  (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | ((prescaler) << CS10))

#define HAL_TIMER_STEPPER_RESET_PRESCALER() \
  (TCCR1B = (TCCR1B & ~(0x07<<CS10)) | (1<<CS10))

// ----------------------------------------------------------------------------
// TIMER0: Step Pulse Reset Interrupt & Pulse Delay (when STEP_PULSE_DELAY defined)
// ----------------------------------------------------------------------------

#define HAL_TIMER_PULSE_RESET_INIT() \
  ( \
    TIMSK0 &= ~((1<<OCIE0B) | (1<<OCIE0A) | (1<<TOIE0)), \
    TCCR0A = 0, \
    TCCR0B = 0, \
    TIMSK0 |= (1<<TOIE0) \
  )

#define HAL_TIMER_PULSE_RESET_SET_COUNT(count)  (TCNT0 = (count))
#define HAL_TIMER_PULSE_RESET_SET_COMPARE(val)  (OCR0A = (val))
#define HAL_TIMER_PULSE_RESET_START()           (TCCR0B = (1<<CS01))
#define HAL_TIMER_PULSE_RESET_STOP()            (TCCR0B = 0)

// Step pulse delay (optional - when STEP_PULSE_DELAY is defined)
#ifdef STEP_PULSE_DELAY
  #define HAL_TIMER_PULSE_DELAY_ISR()           ISR(TIMER0_COMPA_vect)

  #define HAL_TIMER_PULSE_DELAY_INIT()          (TIMSK0 |= (1<<OCIE0A))
#endif

// ----------------------------------------------------------------------------
// TIMER2: Spindle PWM
// ----------------------------------------------------------------------------
// Note: Always defined (hardware registers always exist)
// Actual usage guarded by VARIABLE_SPINDLE in spindle_control.c

#define HAL_TIMER_SPINDLE_PWM_INIT() \
  TCCR2A = ((1<<WGM20) | (1<<WGM21)); \
  TCCR2B = (1<<CS22)

#define HAL_TIMER_SPINDLE_PWM_SET_DUTY(duty)  (OCR2A = (duty))
#define HAL_TIMER_SPINDLE_PWM_GET_DUTY()      (OCR2A)
*/

#define ISR_STEP_DELAY() 	ISR(TIMER0_COMPA_vect)	//HAL_TIMER_PULSE_DELAY_ISR
#define ISR_STEP_RESET()   	ISR(TIMER0_OVF_vect)	//HAL_TIMER_PULSE_RESET_ISR
#define ISR_STEP()       	ISR(TIMER1_COMPA_vect)	//HAL_TIMER_STEPPER_ISR

//ISR_STEP_DELAY()
//ISR_STEP_RESET()
//ISR_STEP()


#define STP_TMR_INT_ENA()	(TIMSK1 |=  (1<<OCIE1A))	//	HAL_TIMER_STEPPER_INTERRUPT_ENABLE
#define STP_TMR_INT_DIS()	(TIMSK1 &= ~(1<<OCIE1A))	//	HAL_TIMER_STEPPER_INTERRUPT_DISABLE


#define HAL_TIMER_SPINDLE_PWM_ENABLE()        (TCCR2A |= (1<<COM2A1))
#define HAL_TIMER_SPINDLE_PWM_DISABLE()       (TCCR2A &= ~(1<<COM2A1))
#define PWM_IS_ENABLED()    (TCCR2A & (1<<COM2A1))		//HAL_TIMER_SPINDLE_PWM_IS_ENABLED


// ============================================================================
// HAL SERIAL/UART MACROS (ZERO OVERHEAD - expand to original AVR code)
// ============================================================================

#define HAL_SERIAL_RX_BUFFER_SIZE               128
#define HAL_SERIAL_TX_BUFFER_SIZE               64

// Serial ISR definitions
#define HAL_SERIAL_RX_ISR()                     ISR(SERIAL_RX)
#define HAL_SERIAL_TX_ISR()                     ISR(SERIAL_UDRE)

// Serial initialization - expands to original GRBL code exactly
#if BAUD_RATE < 57600
  #define HAL_SERIAL_INIT() \
    ({ \
      uint16_t UBRR0_value = ((F_CPU / (8L * BAUD_RATE)) - 1)/2; \
      UCSR0A &= ~(1 << U2X0); \
      UBRR0H = UBRR0_value >> 8; \
      UBRR0L = UBRR0_value; \
      UCSR0B |= (1<<RXEN0 | 1<<TXEN0 | 1<<RXCIE0); \
    })
#else
  #define HAL_SERIAL_INIT() \
    ({ \
      uint16_t UBRR0_value = ((F_CPU / (4L * BAUD_RATE)) - 1)/2; \
      UCSR0A |= (1 << U2X0); \
      UBRR0H = UBRR0_value >> 8; \
      UBRR0L = UBRR0_value; \
      UCSR0B |= (1<<RXEN0 | 1<<TXEN0 | 1<<RXCIE0); \
    })
#endif

// Serial data register access
#define HAL_SERIAL_WRITE_DATA(data)             (UDR0 = (data))
#define HAL_SERIAL_READ_DATA()                  (UDR0)

// Serial interrupt control
#define HAL_SERIAL_TX_INTERRUPT_ENABLE()        (UCSR0B |= (1 << UDRIE0))
#define HAL_SERIAL_TX_INTERRUPT_DISABLE()       (UCSR0B &= ~(1 << UDRIE0))
#define HAL_SERIAL_RX_INTERRUPT_ENABLE()        (UCSR0B |= (1 << RXCIE0))
#define HAL_SERIAL_RX_INTERRUPT_DISABLE()       (UCSR0B &= ~(1 << RXCIE0))

// ============================================================================
// HAL SYSTEM MACROS (ZERO OVERHEAD - expand to original AVR code)
// ============================================================================

// Global interrupt control
#define HAL_INTERRUPTS_ENABLE()                 sei()
#define HAL_INTERRUPTS_DISABLE()                cli()

// Critical sections - saves/restores SREG exactly as original GRBL
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint8_t _sreg_save = SREG; cli()

#define HAL_CRITICAL_SECTION_END() \
  SREG = _sreg_save

// Watchdog timer
#define HAL_WATCHDOG_INIT()                     wdt_init()
#define HAL_WATCHDOG_RESET()                    wdt_reset()

// Delay functions
#define HAL_DELAY_MS(ms)                        _delay_ms(ms)
#define HAL_DELAY_US(us)                        _delay_us(us)

// ============================================================================
// HAL NVMEM (EEPROM) - Defined in hal_nvmem.h
// ============================================================================

// NVMEM macros are defined in platform/hal_nvmem.h for all platforms
// AVR uses optimized eeprom_get_char/eeprom_put_char from nvmem.c

// Note: cpu_map.h is included from grbl.h AFTER config.h to get VARIABLE_SPINDLE

#endif // PLATFORM_AVR_ATMEGA328P_H
