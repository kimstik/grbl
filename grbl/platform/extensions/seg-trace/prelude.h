/*
  prelude.h - seg-trace extension: tee the segment stream at the publish strobe.

  Part of Grbl / Intelligence assisted / License: MIT

  Injected BEFORE the board prelude (extensions/README.md), so it is textually
  first in every TU and cannot assume the config tuple is decided yet. It does
  not need to: seg_tap.h is tuple-structural, not #ifdef'd (see its header).

  Two seam macros are claimed, and they only ever expand inside stepper.c:

    GRBL_SEG_PUBLISH()      performs the ORIGINAL store FIRST, unchanged, then
                            tees. The strobe stays the strobe; the tee reads
                            what was just published. This override never
                            suppresses the store - the ILLEGAL-no-op law applies
                            to both seam macros.

    GRBL_STEPPER_TU_EXPORTS SEG_TAP_READERS only. The trace tap reads slots and
                            indices; it never writes one. SEG_TAP_LOADERS is
                            test-only and is deliberately absent here.

  With EXT empty this file is not included, no -include flag is emitted, no
  source is added, and every bare unit stays byte-identical (proven by
  tools/build_artifacts.py check).
*/

#ifndef GRBL_EXT_SEG_TRACE_PRELUDE_H
#define GRBL_EXT_SEG_TRACE_PRELUDE_H

#define GRBL_EXT_SEG_TRACE 1

#include <stdint.h>
#include "../common/seg_tap.h"

/* Ring capacity in RECORDS, not bytes. Sized for the smallest participating
   part (ch32v006: 8 KB SRAM) - 32 records x 20 B is 640 B plus indices.
   Overridable per build for parts with room. */
#ifndef SEG_TRACE_RECORDS
  #define SEG_TRACE_RECORDS 32
#endif

void seg_trace_publish_hook(void);
uint16_t seg_trace_drain(uint8_t *dst, uint16_t cap);
uint16_t seg_trace_overruns(void);

#define GRBL_SEG_PUBLISH() \
  do { segment_buffer_head = segment_next_head; seg_trace_publish_hook(); } while (0)

#define GRBL_STEPPER_TU_EXPORTS SEG_TAP_READERS

#endif /* GRBL_EXT_SEG_TRACE_PRELUDE_H */
