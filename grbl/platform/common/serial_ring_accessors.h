/*
  serial_ring_accessors.h - the chip-agnostic half of a TU-replacement
  serial.c: the five ring-buffer accessors core GRBL calls
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  NOT AN ORDINARY HEADER - this file contains FUNCTION DEFINITIONS and is
  meant to be #included exactly once, from inside a port's serial.c, AFTER
  that port has declared its ring buffers. It is the "TU-replacement route"
  (CONTRACTS.md #7) equivalent of a shared .c file: those ports do not link
  core grbl/serial.c at all, so there is no translation unit these five
  functions could otherwise live in without every port growing an extra
  object file and an extra Makefile line.

  WHAT THE INCLUDING serial.c MUST HAVE DEFINED FIRST (all five names are
  identical in every consumer today - that is precisely why this extraction
  is possible):

    RX_RING_BUFFER / TX_RING_BUFFER   (RX_BUFFER_SIZE+1)/(TX_BUFFER_SIZE+1);
                                      PER-PORT sizing stays in the port's
                                      config.h - nothing here fixes a size.
    rx_buffer[] / tx_buffer[]         static uint8_t ring storage
    rx_buffer_head / rx_buffer_tail   static volatile uint8_t
    tx_buffer_head / tx_buffer_tail   static volatile uint8_t
    SERIAL_NO_DATA                    from grbl/serial.h

  EXTRACTED verbatim from ch32v006/serial.c (character-identical in
  ch570/serial.c and dspic33ak128mc102/serial.c; samd21/serial.c had the
  same logic written with if/else instead of early return and K&R empty
  parens - normalized to this form, and proven byte-invariant on both of
  its boards like the other three). Core grbl/serial.c and atmega328p are
  NOT consumers and were not touched: the AVR port links the real core
  serial.c, which owns its own copies of these functions plus the HAL_*
  ISR macros this file has no business knowing about.

  CONCURRENCY (do not "simplify" this): every accessor reads each volatile
  index EXACTLY ONCE into a local and then works off the local. That is the
  core serial.c:96-108 pattern and it is load-bearing - the opposite index
  is written by the UART ISR, so re-reading it mid-function can observe two
  different values within one comparison and produce a ring size that is
  briefly negative (i.e. huge, as uint8_t). Pure math only below: no
  register touches, no interrupt masking, nothing chip-specific.
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
