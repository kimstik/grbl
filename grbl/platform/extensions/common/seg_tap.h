/*
  seg_tap.h - GRBL_STEPPER_TU_EXPORTS bodies for the segment seam.

  Part of Grbl / Intelligence assisted / License: MIT

  stepper.c's rings and its segment_t/st_block_t typedefs are file-static and
  file-private. The seam's second touch point (GRBL_STEPPER_TU_EXPORTS, last
  line of stepper.c) is the only sanctioned way to reach them: an extension
  predefines it and the resulting function definitions are compiled INSIDE
  stepper.c's translation unit, so they have legitimate access with no storage
  class changed and no struct layout mirrored anywhere. Accessors copy FIELDS
  into canonical SEGX/1 frames; the compiler's struct image never reaches a
  wire, a vector file or a trace.

  Two composable fragments:
    SEG_TAP_READERS  read-only introspection plus the reverse credit pump.
                     This is the production set (seg-trace, and seg-link later).
    SEG_TAP_LOADERS  writers into the rings. Test infrastructure ONLY - the
                     hosted oracle replays a captured stream by injecting it
                     where st_prep_buffer() would have. Never in a firmware
                     build: nothing but the frozen producer may write a slot.

  Compose with SEG_TAP_CAT2, e.g.
      #define GRBL_STEPPER_TU_EXPORTS SEG_TAP_CAT2(SEG_TAP_READERS, SEG_TAP_LOADERS)

  CONFIG-TUPLE ENFORCEMENT, and why it is structural rather than #ifdef'd.
  An extension prelude is injected BEFORE the board prelude, i.e. before
  config.h has decided anything, so this header cannot branch on the tuple at
  include time - and it must not, because the macro bodies below are expanded at
  the END of stepper.c where the tuple IS decided. So it does not branch at all:
  it is written for the one tuple SEGX/1 §3.1 fixes -

      N_AXIS 3, SEGMENT_BUFFER_SIZE 6, AMASS on (MAX_AMASS_LEVEL 3),
      VARIABLE_SPINDLE on, ENABLE_DUAL_AXIS off

  - and a build with a different tuple fails to compile at the expansion site,
  by name: segment_t has no `amass_level` without AMASS, no `spindle_pwm`
  without VARIABLE_SPINDLE, st_block_t no `is_pwm_rate_adjusted`. That is the
  same refusal SEGX/1 requires of an executor on a CONFIG mismatch ("MUST be
  refused with FAULT, never best-effort"), moved to compile time and impossible
  to fake. N_AXIS is a value, not a member, so it gets an explicit guard.
  ENABLE_DUAL_AXIS is the one tuple element with no structural tell - the wire
  simply does not carry the dual pins; see each extension's ext.md.
*/

#ifndef GRBL_SEG_TAP_H
#define GRBL_SEG_TAP_H

#include "segframe.h"

#define SEG_TAP_CAT2(a, b) a b

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
    o->amass_level = s->amass_level; \
    o->spindle_pwm = s->spindle_pwm; \
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
    o->flags = b->is_pwm_rate_adjusted ? SEGX_BLK_FLAG_PWM_RATE_ADJUSTED : 0; \
  }

#define SEG_TAP_LOADERS \
  void grbl_seg_write(uint8_t idx, const grbl_seg_frame_t *i) { \
    segment_t *s = &segment_buffer[idx]; \
    s->n_step = i->n_step; \
    s->cycles_per_tick = i->cycles_per_tick; \
    s->st_block_index = SEGX_GEN_TO_SLOT(i->blk_gen); \
    s->amass_level = i->amass_level; \
    s->spindle_pwm = i->spindle_pwm; \
  } \
  void grbl_blk_write(const grbl_blk_frame_t *i) { \
    st_block_t *b = &st_block_buffer[SEGX_GEN_TO_SLOT(i->blk_gen)]; \
    b->steps[0] = i->steps[0]; \
    b->steps[1] = i->steps[1]; \
    b->steps[2] = i->steps[2]; \
    b->step_event_count = i->step_event_count; \
    b->direction_bits = i->direction_bits; \
    b->is_pwm_rate_adjusted = \
      ((i)->flags & SEGX_BLK_FLAG_PWM_RATE_ADJUSTED) ? 1 : 0; \
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
