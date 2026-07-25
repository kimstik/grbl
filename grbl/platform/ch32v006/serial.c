/*
  serial.c - CH32V006 serial port driver (TU-replacement route)
  Part of Grbl

  PORTING-CHECKLIST Step 4 - NOT implemented this batch. Ring-buffer
  bookkeeping (chip-agnostic, includes the BUG #12 __DMB() memory-
  ordering fix) is real/working, reused verbatim from `_template/serial.c`
  (itself reused from samd21/serial.c) - only the USART1 register touches
  are PORT_TODO. Future note for Step 4: USART1 register names on this
  chip are STATR/DATAR/CTLR1/CTLR2/CTLR3/GPR (ch32v006.h), not
  STM32-standard SR/DR/CR1 - same bit positions, different names.
*/

#include <stdint.h>
#include "platform.h"
#include "../../serial.h"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

void serial_init(void) {
  PORT_TODO_SERIAL_HW_INIT();
}

void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  while (next_head == tx_buffer_tail) {
    PORT_TODO_SERIAL_TX_INT_ENABLE();
  }

  // CONTRACTS.md #7 (BUG #12 lesson): bracket the data-store + head-publish
  // pair by masking the consuming interrupt.
  PORT_TODO_SERIAL_TX_INT_DISABLE();

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  PORT_TODO_SERIAL_TX_INT_ENABLE();
}

uint8_t serial_read(void) {
  uint8_t tail = rx_buffer_tail;

  if (rx_buffer_head == tail) {
    return SERIAL_NO_DATA;
  }
  uint8_t data = rx_buffer[tail];
  tail++;
  if (tail == RX_RING_BUFFER) { tail = 0; }
  rx_buffer_tail = tail;
  return data;
}

void serial_reset_read_buffer(void) {
  rx_buffer_tail = rx_buffer_head;
}

uint8_t serial_get_rx_buffer_available(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) {
    return (RX_BUFFER_SIZE - (head - tail));
  }
  return (tail - head - 1);
}

uint8_t serial_get_rx_buffer_count(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) { return (head - tail); }
  return (RX_RING_BUFFER - (tail - head));
}

uint8_t serial_get_tx_buffer_count(void) {
  uint8_t head = tx_buffer_head;
  uint8_t tail = tx_buffer_tail;

  if (head >= tail) { return (head - tail); }
  return (TX_RING_BUFFER - (tail - head));
}

// ============================================================================
// UART INTERRUPT DISPATCH
// ============================================================================
void serial_irq_dispatch(void) {
  if (PORT_TODO_SERIAL_RX_PENDING()) {
    uint8_t data = PORT_TODO_SERIAL_RX_READ();
    uint8_t next_head = rx_buffer_head + 1;
    if (next_head == RX_RING_BUFFER) { next_head = 0; }

    if (next_head != rx_buffer_tail) {
      rx_buffer[rx_buffer_head] = data;
      __DMB();
      rx_buffer_head = next_head;
    }
  }

  if (PORT_TODO_SERIAL_TX_READY()) {
    uint8_t tail = tx_buffer_tail;

    if (tx_buffer_head != tail) {
      PORT_TODO_SERIAL_TX_WRITE(tx_buffer[tail]);
      tail++;
      if (tail == TX_RING_BUFFER) { tail = 0; }
      tx_buffer_tail = tail;
    } else {
      PORT_TODO_SERIAL_TX_INT_DISABLE();
    }
  }
}
