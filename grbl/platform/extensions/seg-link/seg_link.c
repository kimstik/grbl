/*
  seg_link.c - SEGX/1 Profile F host shipper.

  Part of Grbl / Intelligence assisted / License: MIT

  Reads the frozen ring through the seam exports, serialises canonical frames,
  hands bytes to the board's transport. See seg_link.h for the blk_gen
  reconstruction, which is the only non-mechanical part.

  Integer only: no float reaches this file, so FP=SINGLE / tools/assert_no_double
  stay satisfied without a waiver.
*/

#include "seg_link.h"
#include "../common/seg_tap.h"

#ifndef SEGMENT_BUFFER_SIZE
#define SEGMENT_BUFFER_SIZE 6
#endif

static struct {
  uint8_t cursor;      /* next ring slot to ship; lives between tail and head */
  uint8_t gen;         /* blocks shipped so far == the wire generation        */
  uint8_t last_slot;   /* the slot the last shipped segment referenced        */
  uint8_t primed;      /* have we shipped anything since the last reset       */
  uint8_t seq;         /* Profile F sequence, wraps at 256                    */
  uint8_t credit;      /* last cumulative completion count applied to tail    */
} sl;

void seg_link_reset(void)
{
  sl.cursor = grbl_seg_tail_get();
  sl.gen = 0;
  sl.last_slot = 0;
  sl.primed = 0;
  sl.seq = 0;
  sl.credit = 0;
}

static void ship(uint8_t tag, const uint8_t *payload, uint8_t len)
{
  uint8_t frame[SEGX_MAX_FRAME];
  uint16_t n = segx_frame_build(frame, tag, payload, len);
  seg_link_tx(frame, n);
}

void seg_link_config(uint8_t step_invert, uint8_t dir_invert,
                     uint16_t pulse_ticks, uint8_t flags,
                     uint8_t homing_lock, uint8_t probe_invert,
                     const int32_t pos[3])
{
  grbl_cfg_frame_t c;
  uint8_t pay[SEGX_CFG_WIRE_LEN];
  c.step_invert = step_invert;
  c.dir_invert = dir_invert;
  c.pulse_ticks = pulse_ticks;
  c.flags = flags;
  c.homing_lock = homing_lock;
  c.probe_invert = probe_invert;
  c.pos[0] = pos[0]; c.pos[1] = pos[1]; c.pos[2] = pos[2];
  segx_cfg_encode(&c, pay);
  ship(SEGX_TAG_CFG, pay, SEGX_CFG_WIRE_LEN);
}

void seg_link_wake(uint8_t epoch)
{
  ship(SEGX_TAG_WAKE, &epoch, 1);
}

/* Called immediately after the publish strobe, so every slot from the ship
   cursor up to (not including) head is complete and immutable. Walking to head
   rather than shipping "the one segment just published" is deliberate: it is
   the same loop whether one or several were published, and it re-converges
   after any transport stall without a separate catch-up path. */
void seg_link_publish_hook(void)
{
  uint8_t head = grbl_seg_head_get();

  while (sl.cursor != head) {
    grbl_seg_frame_t s;
    uint8_t pay[SEGX_SEG_WIRE_LEN];

    grbl_seg_read(sl.cursor, &s);      /* s.blk_gen is the RING SLOT here */

    if (!sl.primed || s.blk_gen != sl.last_slot) {
      grbl_blk_frame_t b;
      uint8_t bpay[SEGX_BLK_WIRE_LEN];
      grbl_blk_read(s.blk_gen, &b);
      sl.gen++;                        /* one slot change == one new block */
      sl.last_slot = s.blk_gen;
      sl.primed = 1;
      b.blk_gen = sl.gen;
      segx_blk_encode(&b, bpay);
      /* F1: the BLK goes out BEFORE the first SEG that references it. On a
         framed link that is the whole ordering obligation - the frame boundary
         is the validity strobe, so there is no window in which the executor
         can see a segment whose block has not landed. */
      ship(SEGX_TAG_BLK, bpay, SEGX_BLK_WIRE_LEN);
    }

    s.blk_gen = sl.gen;
    s.seq = sl.seq++;
    segx_seg_encode(&s, pay);
    ship(SEGX_TAG_SEG, pay, SEGX_SEG_WIRE_LEN);

    if (++sl.cursor == SEGMENT_BUFFER_SIZE) { sl.cursor = 0; }
  }
}

void seg_link_credit(uint8_t cumulative_consumed)
{
  uint8_t delta = (uint8_t)(cumulative_consumed - sl.credit);
  if (delta == 0) { return; }
  sl.credit = cumulative_consumed;
  /* The seam's single sanctioned writer of the consumer-owned index. In
     Profile F the local step ISR never runs, so the link IRQ is the only
     consumer-side writer and the SPSC discipline transfers intact. */
  grbl_seg_tail_advance(delta);
}

uint8_t seg_link_seq(void) { return sl.seq; }
uint8_t seg_link_gen(void) { return sl.gen; }
