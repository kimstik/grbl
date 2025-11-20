/*
  hal_serial.h - Serial/UART HAL
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

// -- FIXME: THIS useless file have to disappear --

#ifndef HAL_SERIAL_H
#define HAL_SERIAL_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// SERIAL CONFIGURATION
// ============================================================================

// Baud rate
#ifndef BAUD_RATE
  #define BAUD_RATE 115200
#endif

// RX/TX buffer sizes (can be overridden in config.h)
#ifndef RX_BUFFER_SIZE
  #define RX_BUFFER_SIZE 128
#endif

#ifndef TX_BUFFER_SIZE
  #define TX_BUFFER_SIZE 104
#endif

// ============================================================================
// PLATFORM-SPECIFIC IMPLEMENTATIONS
// ============================================================================

#ifdef __AVR__
  // ============================================================================
  // AVR IMPLEMENTATION - ZERO OVERHEAD
  // ============================================================================

  #include <avr/io.h>
  #include <avr/interrupt.h>

  // Calculate baud rate register value
  #define BAUD_SETTING (((F_CPU / 8 / BAUD_RATE) - 1) / 2)
  #define BAUD_SETTING_HIGH (BAUD_SETTING >> 8)
  #define BAUD_SETTING_LOW  (BAUD_SETTING & 0xFF)

  // --------------------------------------------------------------------------
  // SERIAL INITIALIZATION
  // --------------------------------------------------------------------------

  #define HAL_SERIAL_INIT() \
    do { \
      UBRR0H = BAUD_SETTING_HIGH; \
      UBRR0L = BAUD_SETTING_LOW; \
      UCSR0A = 0; \
      UCSR0B = (1<<RXEN0) | (1<<TXEN0) | (1<<RXCIE0); \
      UCSR0C = (1<<UCSZ01) | (1<<UCSZ00); \
    } while(0)

  // --------------------------------------------------------------------------
  // DATA REGISTER ACCESS
  // --------------------------------------------------------------------------

  // Read data register (UDR0)
  #define HAL_SERIAL_READ_DATA()  (UDR0)

  // Write data register (UDR0)
  #define HAL_SERIAL_WRITE_DATA(data)  (UDR0 = (data))

  // --------------------------------------------------------------------------
  // STATUS FLAGS
  // --------------------------------------------------------------------------

  // RX complete flag
  #define HAL_SERIAL_RX_READY()  (UCSR0A & (1<<RXC0))

  // TX data register empty flag
  #define HAL_SERIAL_TX_READY()  (UCSR0A & (1<<UDRE0))

  // Frame error flag
  #define HAL_SERIAL_FRAME_ERROR()  (UCSR0A & (1<<FE0))

  // Data overrun flag
  #define HAL_SERIAL_OVERRUN_ERROR()  (UCSR0A & (1<<DOR0))

  // --------------------------------------------------------------------------
  // INTERRUPT CONTROL
  // --------------------------------------------------------------------------

  // Enable RX complete interrupt
  #define HAL_SERIAL_RX_INTERRUPT_ENABLE()   (UCSR0B |= (1<<RXCIE0))
  #define HAL_SERIAL_RX_INTERRUPT_DISABLE()  (UCSR0B &= ~(1<<RXCIE0))

  // Enable TX data register empty interrupt
  #define HAL_SERIAL_TX_INTERRUPT_ENABLE()   (UCSR0B |= (1<<UDRIE0))
  #define HAL_SERIAL_TX_INTERRUPT_DISABLE()  (UCSR0B &= ~(1<<UDRIE0))

  // --------------------------------------------------------------------------
  // ISR DEFINITIONS
  // --------------------------------------------------------------------------

  // RX complete ISR
  #define HAL_SERIAL_RX_ISR()  ISR(USART_RX_vect)

  // TX data register empty ISR
  #define HAL_SERIAL_TX_ISR()  ISR(USART_UDRE_vect)

#else
  // ============================================================================
  // OTHER PLATFORMS - Function-based implementations
  // ============================================================================

  // --------------------------------------------------------------------------
  // SERIAL INITIALIZATION
  // --------------------------------------------------------------------------

  void hal_serial_init(uint32_t baud_rate);
  #ifndef HAL_SERIAL_INIT
    #define HAL_SERIAL_INIT()  hal_serial_init(BAUD_RATE)
  #endif

  // --------------------------------------------------------------------------
  // DATA REGISTER ACCESS
  // --------------------------------------------------------------------------

  uint8_t hal_serial_read_data(void);
  void hal_serial_write_data(uint8_t data);

  #ifndef HAL_SERIAL_READ_DATA
    #define HAL_SERIAL_READ_DATA()       hal_serial_read_data()
  #endif
  #ifndef HAL_SERIAL_WRITE_DATA
    #define HAL_SERIAL_WRITE_DATA(data)  hal_serial_write_data(data)
  #endif

  // --------------------------------------------------------------------------
  // STATUS FLAGS
  // --------------------------------------------------------------------------

  bool hal_serial_rx_ready(void);
  bool hal_serial_tx_ready(void);
  bool hal_serial_frame_error(void);
  bool hal_serial_overrun_error(void);

  #ifndef HAL_SERIAL_RX_READY
    #define HAL_SERIAL_RX_READY()        hal_serial_rx_ready()
  #endif
  #ifndef HAL_SERIAL_TX_READY
    #define HAL_SERIAL_TX_READY()        hal_serial_tx_ready()
  #endif
  #ifndef HAL_SERIAL_FRAME_ERROR
    #define HAL_SERIAL_FRAME_ERROR()     hal_serial_frame_error()
  #endif
  #ifndef HAL_SERIAL_OVERRUN_ERROR
    #define HAL_SERIAL_OVERRUN_ERROR()   hal_serial_overrun_error()
  #endif

  // --------------------------------------------------------------------------
  // INTERRUPT CONTROL
  // --------------------------------------------------------------------------

  void hal_serial_rx_interrupt_enable(void);
  void hal_serial_rx_interrupt_disable(void);
  void hal_serial_tx_interrupt_enable(void);
  void hal_serial_tx_interrupt_disable(void);

  #ifndef HAL_SERIAL_RX_INTERRUPT_ENABLE
    #define HAL_SERIAL_RX_INTERRUPT_ENABLE()   hal_serial_rx_interrupt_enable()
  #endif
  #ifndef HAL_SERIAL_RX_INTERRUPT_DISABLE
    #define HAL_SERIAL_RX_INTERRUPT_DISABLE()  hal_serial_rx_interrupt_disable()
  #endif
  #ifndef HAL_SERIAL_TX_INTERRUPT_ENABLE
    #define HAL_SERIAL_TX_INTERRUPT_ENABLE()   hal_serial_tx_interrupt_enable()
  #endif
  #ifndef HAL_SERIAL_TX_INTERRUPT_DISABLE
    #define HAL_SERIAL_TX_INTERRUPT_DISABLE()  hal_serial_tx_interrupt_disable()
  #endif

  // --------------------------------------------------------------------------
  // ISR DEFINITIONS
  // --------------------------------------------------------------------------

  #ifndef HAL_SERIAL_RX_ISR
    #define HAL_SERIAL_RX_ISR()  void hal_serial_rx_isr(void)
  #endif
  #ifndef HAL_SERIAL_TX_ISR
    #define HAL_SERIAL_TX_ISR()  void hal_serial_tx_isr(void)
  #endif

#endif

// ============================================================================
// RING BUFFER IMPLEMENTATION (platform-independent)
// ============================================================================

/*
  Ring buffer structure and functions are platform-independent.
  They use the HAL macros above for hardware access.

  Buffer implementation remains in serial.c, uses HAL macros for hardware.
*/

// Ring buffer size (defined in serial.c)
#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

// Ring buffer arrays (extern, defined in serial.c)
extern uint8_t serial_rx_buffer[RX_RING_BUFFER];
extern uint8_t serial_tx_buffer[TX_RING_BUFFER];

// Ring buffer indices (extern, defined in serial.c)
// NOTE: Only _tail variables are volatile (modified in ISR)
extern uint8_t serial_rx_buffer_head;
extern volatile uint8_t serial_rx_buffer_tail;
extern uint8_t serial_tx_buffer_head;
extern volatile uint8_t serial_tx_buffer_tail;

// ============================================================================
// COMMON SERIAL FUNCTIONS (all platforms)
// ============================================================================

/*
  These functions are implemented in serial.c using HAL macros.
  They are platform-independent at the C source level.
*/

void serial_init(void);
void serial_write(uint8_t data);
uint8_t serial_read(void);
void serial_reset_read_buffer(void);
uint8_t serial_get_rx_buffer_available(void);
uint8_t serial_get_tx_buffer_count(void);

#endif // HAL_SERIAL_H


