/*
  seg_trace.c - RAM capture ring for the SEGX/1 segment stream.

  Part of Grbl / Intelligence assisted / License: MIT

  Records emitted are the CANONICAL wire frames (extensions/common/segframe.h),
  tagged, not the compiler's struct image - so what a drained capture contains is
  byte-identical in layout to what a Profile F link would have shipped, and to
  what tools/hosted/ replays. Wire format == capture format == vector format.

  Record layout on the drain stream:
      [0]      tag: SEG_TRACE_TAG_BLK / SEG_TRACE_TAG_SEG
      [1..]    the frame, little-endian, per segframe.h
  BLK records are 1 + 19, SEG records 1 + 8.

  Concurrency: seg_trace_publish_hook() runs on the producer side, inside
  st_prep_buffer(), immediately after the publish store. seg_trace_drain() runs
  from the main loop. The ring is the same lock-free SPSC shape as the segment
  ring itself - one index per side, 8-bit, atomic by construction - which is why
  no critical section appears here. Overrun is COUNTED, never silently dropped:
  a capture with overruns is not a valid conformance vector and the count is the
  proof.
*/

#include "grbl.h"
#include "hal.h"

#define SEG_TRACE_TAG_SEG 0x53   /* 'S' */
#define SEG_TRACE_TAG_BLK 0x42   /* 'B' */
#define SEG_TRACE_REC_MAX (1 + SEGX_BLK_WIRE_LEN)

/* volatile, and that is load-bearing, not defensive. The capture ring's reader
   is OUTSIDE this program: a debugger halting the core and dumping RAM is the
   intended first consumer, before any drain transport exists on a given board.
   Without volatile, RELEASE LTO correctly proves nothing in the image ever
   reads these bytes and deletes both the arrays and every store into them -
   measured on ch32v006: seg_trace_buf and seg_trace_len vanished from the ELF
   entirely while the extension still "built", i.e. a silently no-op capture.
   The post-link guard in ext.mk exists so that can never come back unnoticed. */
static volatile uint8_t seg_trace_buf[SEG_TRACE_RECORDS][SEG_TRACE_REC_MAX];
static volatile uint8_t seg_trace_len[SEG_TRACE_RECORDS];
static volatile uint8_t seg_trace_tail;
static uint8_t  seg_trace_head;
static uint16_t seg_trace_overrun;
static uint8_t  seg_trace_last_blk;
static uint8_t  seg_trace_primed;

static void seg_trace_push(uint8_t tag, const uint8_t *body, uint8_t n)
{
  uint8_t next = (uint8_t)(seg_trace_head + 1);
  uint8_t i;
  if (next == SEG_TRACE_RECORDS) { next = 0; }
  if (next == seg_trace_tail) { seg_trace_overrun++; return; }
  seg_trace_buf[seg_trace_head][0] = tag;
  for (i = 0; i < n; i++) { seg_trace_buf[seg_trace_head][1 + i] = body[i]; }
  seg_trace_len[seg_trace_head] = (uint8_t)(n + 1);
  seg_trace_head = next;
}

void seg_trace_publish_hook(void)
{
  grbl_seg_frame_t sf;
  uint8_t w[SEGX_BLK_WIRE_LEN];
  uint8_t head = grbl_seg_head_get();

  grbl_seg_read(head, &sf);

  /* blk_gen on the wire is a generation counter; what the slot carries is the
     mod-5 ring index. Lift it: +1 on every change, which reproduces
     st_next_block_index()'s sequence and makes a wrap-drop detectable
     downstream (SEGMENT-RUNTIME-PLAN §7c). */
  if (!seg_trace_primed || sf.blk_gen != (uint8_t)(seg_trace_last_blk % 5u)) {
    grbl_blk_frame_t bf;
    grbl_blk_read(sf.blk_gen, &bf);
    seg_trace_last_blk = (uint8_t)(seg_trace_last_blk + 1u);
    if (seg_trace_last_blk == 0u) { seg_trace_last_blk = 1u; }
    seg_trace_primed = 1;
    bf.blk_gen = seg_trace_last_blk;
    segx_blk_encode(&bf, w);
    seg_trace_push(SEG_TRACE_TAG_BLK, w, SEGX_BLK_WIRE_LEN);
  }
  sf.blk_gen = seg_trace_last_blk;
  segx_seg_encode(&sf, w);
  seg_trace_push(SEG_TRACE_TAG_SEG, w, SEGX_SEG_WIRE_LEN);
}

uint16_t seg_trace_drain(uint8_t *dst, uint16_t cap)
{
  uint16_t n = 0;
  while (seg_trace_tail != seg_trace_head) {
    uint8_t len = seg_trace_len[seg_trace_tail];
    uint8_t i;
    if ((uint16_t)(n + len) > cap) { break; }
    for (i = 0; i < len; i++) { dst[n + i] = seg_trace_buf[seg_trace_tail][i]; }
    n = (uint16_t)(n + len);
    seg_trace_tail = (uint8_t)(seg_trace_tail + 1);
    if (seg_trace_tail == SEG_TRACE_RECORDS) { seg_trace_tail = 0; }
  }
  return n;
}

uint16_t seg_trace_overruns(void) { return seg_trace_overrun; }
