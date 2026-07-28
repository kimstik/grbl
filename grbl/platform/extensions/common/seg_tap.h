/*
  seg_tap.h - GRBL_STEPPER_TU_EXPORTS bodies for the segment seam.

  Part of Grbl / Intelligence assisted / License: MIT

  stepper.c's rings and its segment_t/st_block_t typedefs are file-static and
  file-private. The seam's second touch point (GRBL_STEPPER_TU_EXPORTS, last
  line of stepper.c) is the only sanctioned way to reach them: an extension
  predefines it, and the resulting function definitions are compiled INSIDE
  stepper.c's translation unit, so they have legitimate access with no storage
  class changed and no struct layout mirrored anywhere.

  Two composable fragments:
    SEG_TAP_READERS  read-only introspection + the reverse credit pump.
                     This is the production set (seg-trace, seg-link).
    SEG_TAP_LOADERS  writers into the rings. Test infrastructure ONLY - the
                     hosted oracle replays a captured stream by injecting it
                     where st_prep_buffer() would have. Never in a firmware
                     build: nothing but the frozen producer may write a slot.

  Compose with SEG_TAP_CAT2, e.g.
      #define GRBL_STEPPER_TU_EXPORTS SEG_TAP_CAT2(SEG_TAP_READERS, SEG_TAP_LOADERS)

  Field access to config-conditional members goes through the SEG_TAP_*_FIELD
  macros below, because a macro body cannot contain #ifdef.
*/

#ifndef GRBL_SEG_TAP_H
#define GRBL_SEG_TAP_H

#include "segframe.h"

#define SEG_TAP_CAT2(a, b) a b

/* segment_t carries amass_level under AMASS and prescaler without it; the wire
   field is amass_level either way, and the non-AMASS profile is out of scope
   for the conformance corpus (SEGMENT-RUNTIME-PLAN §8) - so a non-AMASS build
   reports 0 and a loader on such a build is refused at compile time. */
#ifdef ADAPTIVE_MULTI_AXIS_STEP_SMOOTHING
  #define SEG_TAP_RD_AMASS(s, o)  (o)->amass_level = (s)->amass_level
  #define SEG_TAP_WR_AMASS(s, i)  (s)->amass_level = (i)->amass_level
#else
  #define SEG_TAP_RD_AMASS(s, o)  (o)->amass_level = 0
  #define SEG_TAP_WR_AMASS(s, i)  (s)->prescaler = (i)->amass_level
#endif

#ifdef VARIABLE_SPINDLE
  #define SEG_TAP_RD_PWM(s, o)    (o)->spindle_pwm = (s)->spindle_pwm
  #define SEG_TAP_WR_PWM(s, i)    (s)->spindle_pwm = (i)->spindle_pwm
  #define SEG_TAP_RD_FLAGS(b, o)  (o)->flags = (b)->is_pwm_rate_adjusted ? \
                                    SEGX_BLK_FLAG_PWM_RATE_ADJUSTED : 0
  #define SEG_TAP_WR_FLAGS(b, i)  (b)->is_pwm_rate_adjusted = \
                                    ((i)->flags & SEGX_BLK_FLAG_PWM_RATE_ADJUSTED) ? 1 : 0
#else
  #define SEG_TAP_RD_PWM(s, o)    (o)->spindle_pwm = 0
  #define SEG_TAP_WR_PWM(s, i)    (void)(i)
  #define SEG_TAP_RD_FLAGS(b, o)  (o)->flags = 0
  #define SEG_TAP_WR_FLAGS(b, i)  (void)(i)
#endif

/* N_AXIS is 3 in every unit in this tree; the wire fixes 3 (SEGX/1 §3.2).
   A build that changed it must not silently ship a truncated frame. */
#define SEG_TAP_AXIS_GUARD \
  typedef char seg_tap_n_axis_must_be_3[(N_AXIS == 3) ? 1 : -1];

#define SEG_TAP_READERS \
  SEG_TAP_AXIS_GUARD \
  uint8_t grbl_seg_head_get(void) { return segment_buffer_head; } \
  uint8_t grbl_seg_tail_get(void) { return segment_buffer_tail; } \
  void grbl_seg_tail_advance(uint8_t n) { \
    uint8_t t = segment_buffer_tail; \
    while (n--) { if (++t == SEGMENT_BUFFER_SIZE) { t = 0; } } \
    segment_buffer_tail = t; \
  } \
  void grbl_seg_read(uint8_t idx, grbl_seg_frame_t *o) { \
    const segment_t *s = &segment_buffer[idx]; \
    o->n_step = s->n_step; \
    o->cycles_per_tick = s->cycles_per_tick; \
    o->blk_gen = s->st_block_index; \
    SEG_TAP_RD_AMASS(s, o); \
    SEG_TAP_RD_PWM(s, o); \
    o->seq = 0; \
  } \
  void grbl_blk_read(uint8_t idx, grbl_blk_frame_t *o) { \
    const st_block_t *b = &st_block_buffer[idx]; \
    o->blk_gen = idx; \
    o->steps[0] = b->steps[0]; \
    o->steps[1] = b->steps[1]; \
    o->steps[2] = b->steps[2]; \
    o->step_event_count = b->step_event_count; \
    o->direction_bits = b->direction_bits; \
    SEG_TAP_RD_FLAGS(b, o); \
  }

#define SEG_TAP_LOADERS \
  void grbl_seg_write(uint8_t idx, const grbl_seg_frame_t *i) { \
    segment_t *s = &segment_buffer[idx]; \
    s->n_step = i->n_step; \
    s->cycles_per_tick = i->cycles_per_tick; \
    s->st_block_index = SEGX_GEN_TO_SLOT(i->blk_gen); \
    SEG_TAP_WR_AMASS(s, i); \
    SEG_TAP_WR_PWM(s, i); \
  } \
  void grbl_blk_write(const grbl_blk_frame_t *i) { \
    st_block_t *b = &st_block_buffer[SEGX_GEN_TO_SLOT(i->blk_gen)]; \
    b->steps[0] = i->steps[0]; \
    b->steps[1] = i->steps[1]; \
    b->steps[2] = i->steps[2]; \
    b->step_event_count = i->step_event_count; \
    b->direction_bits = i->direction_bits; \
    SEG_TAP_WR_FLAGS(b, i); \
  } \
  void grbl_seg_head_set(uint8_t h) { segment_buffer_head = h; } \
  void grbl_seg_next_head_set(uint8_t h) { segment_next_head = h; }

/* Declarations for TUs other than stepper.c. */
#ifdef __cplusplus
extern "C" {
#endif
uint8_t grbl_seg_head_get(void);
uint8_t grbl_seg_tail_get(void);
void    grbl_seg_tail_advance(uint8_t n);
void    grbl_seg_read(uint8_t idx, grbl_seg_frame_t *out);
void    grbl_blk_read(uint8_t idx, grbl_blk_frame_t *out);
void    grbl_seg_write(uint8_t idx, const grbl_seg_frame_t *in);
void    grbl_blk_write(const grbl_blk_frame_t *in);
void    grbl_seg_head_set(uint8_t h);
void    grbl_seg_next_head_set(uint8_t h);
#ifdef __cplusplus
}
#endif

#endif /* GRBL_SEG_TAP_H */
