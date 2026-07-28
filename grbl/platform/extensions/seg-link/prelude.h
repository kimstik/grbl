/*
  prelude.h - seg-link extension: ship the segment stream over a Profile F link.

  Part of Grbl / Intelligence assisted / License: MIT

  Injected BEFORE the board prelude (extensions/README.md), so it is textually
  first in every TU and cannot assume the config tuple is decided yet. It does
  not need to: seg_tap.h is tuple-structural, not #ifdef'd.

  Two seam macros are claimed, both only ever expanding inside stepper.c:

    GRBL_SEG_PUBLISH()      performs the ORIGINAL store FIRST, unchanged, then
                            ships everything between the ship cursor and the new
                            head. The strobe stays the strobe. This override
                            never suppresses the store - the ILLEGAL-no-op law
                            applies to both seam macros.

    GRBL_STEPPER_TU_EXPORTS SEG_TAP_READERS. The readers include
                            grbl_seg_tail_advance(), which the reverse credit
                            pump needs; SEG_TAP_LOADERS is test-only and is
                            deliberately absent.

  WHAT IS AND IS NOT HERE. seg_link.c - the serialiser, the blk_gen
  reconstruction, the credit pump - is complete and is gated end to end by
  ci/seg_conformance.py's "rtl via seg-link wire" subject, on the host, against
  the Verilated executor. What is NOT written is the board transport: SPI1
  remap 011 + DMA1 ch2/ch3, the PB6/EXTI6 event line, PC4 MCO exporting the
  clock, the KILL pin, and the STP_TMR_INT_ENA / STP_TMR_INT_DIS overrides that
  carry WAKE and the HALT_FLUSH transaction (SEGMENT-RUNTIME-PLAN §3.5 R6).
  Until those exist this extension ships bytes into a counter, which is why
  seg_link_null.c and the post-link guard in ext.mk are shaped the way they
  are: they make "it linked" not mean "it works".

  With EXT empty this file is not included, no -include flag is emitted, no
  source is added, and every bare unit stays byte-identical.
*/

#ifndef GRBL_EXT_SEG_LINK_PRELUDE_H
#define GRBL_EXT_SEG_LINK_PRELUDE_H

#define GRBL_EXT_SEG_LINK 1

#include <stdint.h>
#include "../common/seg_tap.h"
#include "seg_link.h"

#define GRBL_SEG_PUBLISH() \
  do { segment_buffer_head = segment_next_head; seg_link_publish_hook(); } while (0)

#define GRBL_STEPPER_TU_EXPORTS SEG_TAP_READERS

#endif /* GRBL_EXT_SEG_LINK_PRELUDE_H */
