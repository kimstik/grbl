/*
  segframe.h - SEGX/1 canonical frames and their little-endian wire codec.

  Part of Grbl / Intelligence assisted / License: MIT

  This is the ONE definition of the segment-executor wire format
  (grbl/platform/docs/SEGMENT-RUNTIME-PLAN.md §3.2). It is deliberately
  independent of stepper.c's private segment_t/st_block_t: those reshape with
  N_AXIS / AMASS / VARIABLE_SPINDLE / ENABLE_DUAL_AXIS and with the target ABI
  (segment_t is 7 B on AVR, 8 B on 32-bit). Accessors copy FIELDS across the
  seam; the compiler's struct image never reaches a wire, a vector file or a
  trace.

  Same header is used by the hosted oracle, by the seg-trace extension and by
  the conformance corpus generator, so vector format == wire format == what the
  trace tap emits. They cannot drift apart.
*/

#ifndef GRBL_SEGFRAME_H
#define GRBL_SEGFRAME_H

#include <stdint.h>

#define SEGX_VERSION      1
#define SEGX_SEG_WIRE_LEN 8
#define SEGX_BLK_WIRE_LEN 19

/* SEG - one per DT_SEGMENT. §3.2. */
typedef struct {
  uint16_t n_step;          /* ISR ticks, 1..65535; 0 is a protocol violation */
  uint16_t cycles_per_tick; /* tick period = (v+1) F_TICK clocks; 0xffff = clamp */
  uint8_t  blk_gen;         /* +1 per planner block; ring index = gen % 5 */
  uint8_t  amass_level;     /* 0..3 */
  uint8_t  spindle_pwm;     /* applied once, before this segment's first tick */
  uint8_t  seq;             /* Profile F sequence number */
} grbl_seg_frame_t;

/* BLK - one per planner block, MUST precede the first SEG referencing it. */
typedef struct {
  uint8_t  blk_gen;
  uint32_t steps[3];        /* pre-multiplied << MAX_AMASS_LEVEL */
  uint32_t step_event_count;
  uint8_t  direction_bits;  /* pin-position encoded; 1 = negative */
  uint8_t  flags;           /* bit0 = is_pwm_rate_adjusted */
} grbl_blk_frame_t;

#define SEGX_BLK_FLAG_PWM_RATE_ADJUSTED 0x01

static inline void segx_put16(uint8_t *p, uint16_t v)
{
  p[0] = (uint8_t)(v & 0xff); p[1] = (uint8_t)(v >> 8);
}

static inline void segx_put32(uint8_t *p, uint32_t v)
{
  p[0] = (uint8_t)(v & 0xff);         p[1] = (uint8_t)((v >> 8) & 0xff);
  p[2] = (uint8_t)((v >> 16) & 0xff); p[3] = (uint8_t)((v >> 24) & 0xff);
}

static inline uint16_t segx_get16(const uint8_t *p)
{
  return (uint16_t)(p[0] | ((uint16_t)p[1] << 8));
}

static inline uint32_t segx_get32(const uint8_t *p)
{
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
         ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static inline void segx_seg_encode(const grbl_seg_frame_t *s, uint8_t *w)
{
  segx_put16(w + 0, s->n_step);
  segx_put16(w + 2, s->cycles_per_tick);
  w[4] = s->blk_gen; w[5] = s->amass_level; w[6] = s->spindle_pwm; w[7] = s->seq;
}

static inline void segx_seg_decode(const uint8_t *w, grbl_seg_frame_t *s)
{
  s->n_step = segx_get16(w + 0); s->cycles_per_tick = segx_get16(w + 2);
  s->blk_gen = w[4]; s->amass_level = w[5]; s->spindle_pwm = w[6]; s->seq = w[7];
}

static inline void segx_blk_encode(const grbl_blk_frame_t *b, uint8_t *w)
{
  w[0] = b->blk_gen;
  segx_put32(w + 1, b->steps[0]);
  segx_put32(w + 5, b->steps[1]);
  segx_put32(w + 9, b->steps[2]);
  segx_put32(w + 13, b->step_event_count);
  w[17] = b->direction_bits; w[18] = b->flags;
}

static inline void segx_blk_decode(const uint8_t *w, grbl_blk_frame_t *b)
{
  b->blk_gen = w[0];
  b->steps[0] = segx_get32(w + 1);
  b->steps[1] = segx_get32(w + 5);
  b->steps[2] = segx_get32(w + 9);
  b->step_event_count = segx_get32(w + 13);
  b->direction_bits = w[17]; b->flags = w[18];
}

/* blk_gen -> st_block_buffer index. Reproduces st_next_block_index() exactly:
   prep.st_block_index starts at 0 and is pre-incremented, so the first block
   claims 1 and the sequence is 1,2,3,4,0,1,... for gen = 1,2,3,... */
#define SEGX_GEN_TO_SLOT(gen) ((uint8_t)((gen) % 5u))

#endif /* GRBL_SEGFRAME_H */
