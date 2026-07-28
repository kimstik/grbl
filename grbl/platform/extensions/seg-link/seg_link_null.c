/*
  seg_link_null.c - the transport that does not exist yet, made visible.

  Part of Grbl / Intelligence assisted / License: MIT

  seg_link.c is complete and proven on the host. The BOARD side - SPI1 remap
  011 with DMA1 ch2/ch3, the PB6/EXTI6 event line, PC4 exporting the clock on
  MCO, the KILL pin - is not written. A build of EXT=seg-link therefore has to
  do something with the bytes, and there are two honest options: refuse to
  link, or park them somewhere a human can see.

  Parking them is more useful (the shipper's flash/RAM cost and its warning
  profile are worth measuring before the transport exists), but a plain no-op
  sink is exactly the shape that makes a build lie: LTO deletes the sink,
  deletes the calls, deletes the shipper, and the unit "passes" every ratchet
  while doing nothing. seg-trace already shipped that bug once - see its
  live_check.sh.

  So the sink is a volatile mailbox plus counters. It is observable from a
  debugger, it cannot be elided, and the post-link guard in ext.mk asserts the
  STORAGE (not a function symbol - an elided buffer still leaves the function).
  When a real transport lands, this file is replaced, not extended.
*/

#include "grbl.h"
#include "hal.h"
#include "seg_link.h"

#define SEG_LINK_NULL_MAILBOX 32

/* volatile: the reader is outside the program. Without it, RELEASE LTO proves
   nothing ever reads these bytes and deletes the mailbox, the stores, and
   transitively the entire shipper. Measured on ch32v006 for seg-trace's
   equivalent ring; the guard exists so it cannot come back unnoticed. */
volatile uint8_t  seg_link_null_mailbox[SEG_LINK_NULL_MAILBOX];
volatile uint16_t seg_link_null_bytes;
volatile uint16_t seg_link_null_frames;

void seg_link_tx(const uint8_t *bytes, uint16_t n)
{
  uint16_t i;
  for (i = 0; i < n && i < SEG_LINK_NULL_MAILBOX; i++) {
    seg_link_null_mailbox[i] = bytes[i];
  }
  seg_link_null_bytes = (uint16_t)(seg_link_null_bytes + n);
  seg_link_null_frames++;
}
