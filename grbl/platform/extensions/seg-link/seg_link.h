/*
  seg_link.h - SEGX/1 Profile F host shipper.

  Part of Grbl / Intelligence assisted / License: MIT

  The host half of the segment boundary: it reads the frozen SPSC ring through
  the seam's TU exports and turns it into the byte stream
  tools/hosted/subjects/rtl consumes. Nothing here knows about SPI, DMA or any
  MCU - the transport is one function the board supplies.

  BLK_GEN, which is the one piece of real reconstruction. The ring carries a
  mod-5 slot index (segment_t::st_block_index); the wire carries an 8-bit
  generation counter, because a slot index cannot tell block 1 from block 6 and
  "inequality triggers counter reinit" would miss the wrap. The shipper
  recovers the generation by counting: st_next_block_index() pre-increments
  from 0, so blocks claim slots 1,2,3,4,0,1,... and generations 1,2,3,4,5,6,...
  which is exactly gen % 5 == slot. Every slot change the shipper observes is
  one new block, so gen is a counter and needs no state from the producer.
  SEGX_GEN_TO_SLOT() is the inverse the executor applies, and the two are
  checked against each other exhaustively by the RTL testbench's --selfcheck.
*/

#ifndef GRBL_SEG_LINK_H
#define GRBL_SEG_LINK_H

#include <stdint.h>
#include "../common/segwire.h"

/* Supplied by the board (SPI+DMA) or by the host test harness (a file).
   Called from the publish hook, i.e. from st_prep_buffer's context - main
   loop, never an ISR. It MUST NOT block for longer than the credit window
   allows; SEGX/1 §3.4 sizes that at ~50 ms of buffered motion. */
void seg_link_tx(const uint8_t *bytes, uint16_t n);

void seg_link_reset(void);          /* WAKE(epoch): resync the ship cursor */
void seg_link_publish_hook(void);   /* the GRBL_SEG_PUBLISH override calls this */
void seg_link_config(uint8_t step_invert, uint8_t dir_invert,
                     uint16_t pulse_ticks, uint8_t flags,
                     uint8_t homing_lock, uint8_t probe_invert,
                     const int32_t pos[3]);
void seg_link_wake(uint8_t epoch);

/* Reverse: cumulative completion count from the executor (SEGX/1 §3.5 R1).
   CREDIT == segment_buffer_tail by construction, so the pump is a delta and a
   call into the seam's single sanctioned writer. Absolute, never a delta on
   the wire - a dropped frame heals at the next one (P1). */
void seg_link_credit(uint8_t cumulative_consumed);

uint8_t seg_link_seq(void);
uint8_t seg_link_gen(void);

#endif /* GRBL_SEG_LINK_H */
