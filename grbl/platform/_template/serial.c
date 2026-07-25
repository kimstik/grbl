/*
  serial.c - _template serial port driver (copy-me starting point)
  Part of Grbl

  TU-replacement route (CONTRACTS.md §0/§7): this file provides the whole
  grbl/serial.h API instead of core grbl/serial.c; this platform's Makefile
  excludes the core file. The ring-buffer bookkeeping below (head/tail
  math, the DMB memory-ordering fix for BUG #12) is genuinely chip-agnostic
  and is reused verbatim from samd21/serial.c - only the actual UART
  register touches are PORT_TODO_SERIAL_* calls. That split is deliberate:
  copying the ring buffer logic into every port and getting the ordering
  subtly wrong each time is worse than sharing one proven implementation
  and localizing the hardware-specific 20% behind a handful of PORT_TODO
  primitives.
*/

#include <stdint.h>
#include "platform.h"
#include "../../serial.h"

#warning "PORT-TODO: serial.c"

#define RX_RING_BUFFER (RX_BUFFER_SIZE+1)
#define TX_RING_BUFFER (TX_BUFFER_SIZE+1)

static uint8_t rx_buffer[RX_RING_BUFFER];
static uint8_t tx_buffer[TX_RING_BUFFER];

static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;
static volatile uint8_t tx_buffer_head = 0;
static volatile uint8_t tx_buffer_tail = 0;

// CONTRACTS.md §7: UART at BAUD_RATE, 8N1, RX interrupt enabled, TX (DRE)
// interrupt disabled. Context: init. Verify your baud divisor formula
// against the datasheet at 115200, not just 9600 (BUG #4 class - AVR's own
// reference formula rounds differently above/below 57600, platform.h:223-241
// pattern in atmega328p).
void serial_init(void) {
  PORT_TODO_SERIAL_HW_INIT();
}

// Ring-buffer append is genuinely chip-agnostic; only the "is the hardware
// TX register empty / please interrupt me when it is" part is PORT_TODO.
void serial_write(uint8_t data) {
  uint8_t next_head = tx_buffer_head + 1;
  if (next_head == TX_RING_BUFFER) { next_head = 0; }

  // Block while full, keeping the hardware TX-empty interrupt armed so the
  // ISR can drain the buffer and make room.
  while (next_head == tx_buffer_tail) {
    PORT_TODO_SERIAL_TX_INT_ENABLE();
  }

  // CONTRACTS.md §7 (BUG #12 lesson): bracket the data-store + head-publish
  // pair by masking the consuming interrupt, so a producer/consumer race on
  // this weakly-ordered core cannot reorder them (§12.1).
  PORT_TODO_SERIAL_TX_INT_DISABLE();

  tx_buffer[tx_buffer_head] = data;
  tx_buffer_head = next_head;

  PORT_TODO_SERIAL_TX_INT_ENABLE();
}

// Pure ring-buffer math below - no hardware access, no PORT_TODO needed.
// Preserve the "read index once into a local" pattern (core's own
// serial.c:96-108 does the same) so a concurrent ISR update mid-function
// cannot produce a torn read.

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
// PORT-TODO: alias your real UART IRQ vector (startup.c's vector_table[])
// to this function. PORT_TODO_SERIAL_RX_PENDING/TX_READY stand in for
// "read this peripheral's interrupt-flag register"; whichever your chip
// calls it, clear/consume the condition by reading DATA / writing DATA
// exactly once per pass, matching the hardware's own flag-clear-on-access
// behavior (CONTRACTS.md §7 table: HAL_SERIAL_READ_DATA/WRITE_DATA "must
// clear the flag").
void serial_irq_dispatch(void) {
  if (PORT_TODO_SERIAL_RX_PENDING()) {
    uint8_t data = PORT_TODO_SERIAL_RX_READ();
    uint8_t next_head = rx_buffer_head + 1;
    if (next_head == RX_RING_BUFFER) { next_head = 0; }

    if (next_head != rx_buffer_tail) {
      rx_buffer[rx_buffer_head] = data;
      // BUG #12 fix: data store MUST complete before the head publish is
      // visible to serial_read() on another context - volatile alone does
      // not order this on a weakly-ordered core (CONTRACTS.md §12.1).
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
      // Buffer empty - self-disable so the TX-empty condition doesn't
      // re-fire forever (CONTRACTS.md §7: "TX ISR self-disables when the
      // buffer drains", PORTING-CHECKLIST Step 4).
      PORT_TODO_SERIAL_TX_INT_DISABLE();
    }
  }
}
