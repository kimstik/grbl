/*
  serial_ring_accessors.h - the chip-agnostic half of a TU-replacement
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef GRBL_PLATFORM_COMMON_SERIAL_RING_ACCESSORS_H
#define GRBL_PLATFORM_COMMON_SERIAL_RING_ACCESSORS_H

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

#endif // GRBL_PLATFORM_COMMON_SERIAL_RING_ACCESSORS_H
