/*
  amass_floor.h - build-time guard for CONTRACTS.md #amass-floor
  (AMASS 16-bit clamp minimum-speed floor scales with F_CPU)
  Part of Grbl

  Copyright (c) 2026 kimstik
  Intelligence assisted
  License: MIT

  WHY THIS EXISTS
  ---------------
  grbl/stepper.c (core, frozen - never edited by this file or the ports
  that include it) computes, per segment, a dominant-axis cycles-per-step
  value and stores it in `segment_t.cycles_per_tick`, a `uint16_t`
  (stepper.c:86). Under ADAPTIVE_MULTI_AXIS_STEP_SMOOTHING (config.h:304,
  default ON, no port turns it off), the exact order is:

    stepper.c:1025   cycles >>= prep_segment->amass_level;   // divide FIRST
    stepper.c:1028-9 if (cycles < 65536) { cycles_per_tick = cycles; }
                      else { cycles_per_tick = 0xffff; }      // clamp SECOND

  AMASS therefore has a second, undocumented job beyond anti-aliasing: the
  pre-clamp shift (up to MAX_AMASS_LEVEL=3, i.e. /8) extends the
  representable low-speed range 8x versus a bare 16-bit timer. The floor
  this leaves is exact: the last unshifted cycles-per-step value that
  still fits after the level-3 shift is 65536<<3 = 524288 (2^19). Below
  that dominant-axis step rate (i.e. slower than F_CPU/524288 steps/sec),
  the true cycles value no longer fits and cycles_per_tick clamps to
  0xffff regardless - the ISR then runs FASTER than the commanded feed,
  silently, forever, until the feed is raised back above the floor. This
  is a clamp, not a wraparound: verified at stepper.c:1028-1029 (grep
  finds no arithmetic overflow path for cycles_per_tick, only this
  explicit ternary-shaped clamp with its own comment, "Just set the
  slowest speed possible").

  Full arithmetic, the per-unit table (corrected: sg2002's real F_CPU is
  25 MHz, its Makefile's own APB-timer-input-clock comment, NOT the ~700
  MHz application-core frequency a first pass can be misled by), and the
  severity call: CONTRACTS.md, "amass-floor".

  THE GAP THIS CLOSES
  --------------------
  The floor is F_CPU/524288 dominant-axis steps/sec - a PURE function of
  F_CPU, a Makefile-owned, per-port constant. Nothing in the tree computed
  or bounded it before this file: a porter raising CLOCK (a routine board-
  revision edit, the same class §36/clock-constant-width already warns
  about for a different symptom) silently raises the floor in lock-step,
  with no warning, no test, and no CONTRACTS entry to consult. This file
  turns that silent scaling into a build-time fact a porter must look at.

  WHY THIS IS A PLATFORM-LAYER FIX, NOT A CORE-PURITY-DIAGNOSTIC CASE
  ----------------------------------------------------------------------
  CONTRACTS.md #34 (core-purity-diagnostic-response) governs a COMPILER
  diagnostic whose reported location is inside frozen core. That does not
  apply here: no diagnostic ever points at stepper.c over this, because
  nothing about the clamp is malformed C - it is silent, correct-looking
  arithmetic whose SEVERITY is entirely a function of a platform-owned
  parameter (F_CPU) that core has no visibility into. The correct
  precedent is #36 (clock-constant-width, BUG #18 class) instead: a clock
  constant a porter controls interacts with a fixed piece of core
  arithmetic, and the failure mode is invisible until measured. #36's
  remedy - a `_Static_assert` computed from F_CPU, included from every
  non-AVR port's prelude.h, next to the core files it protects but never
  inside them - is the template this file follows.

  WHAT THE PLATFORM LAYER CANNOT DO ABOUT THIS
  ----------------------------------------------
  `cycles_per_tick` is declared `uint16_t` in the frozen `segment_t`
  (stepper.c:86) and is clamped to that width by frozen core arithmetic
  (stepper.c:1028-1029) BEFORE `STP_TMR_PERIOD_SET(st.exec_segment->
  cycles_per_tick)` (stepper.c:371) ever hands a value to the platform
  layer. A port whose hardware stepper timer is 32-bit wide (several are:
  stm32 TIM2 on most parts, dsPIC33AK's timers, hc32f460's) gets no relief
  from that width - the precision is already gone by the time the
  platform macro runs. Widening the PLATFORM's timer register is not an
  available remedy for this specific defect; only changing what F_CPU
  itself represents (see below) touches the actual arithmetic.

  THE REMEDY THAT IS AVAILABLE, AND WHY THIS FILE DOES NOT APPLY IT
  ---------------------------------------------------------------------
  sg2002 already establishes the precedent this class needs: F_CPU is
  documented there as "the APB TIMER's input clock, NOT the CPU clock"
  (sg2002/Makefile) - a platform is free to feed grbl's stepper-timing
  arithmetic from a divided/prescaled clock lower than the MCU's real
  core frequency, which moves this floor down by the same factor. Doing
  that correctly for hc32f460/dspic33ak128mc102/stm32h523 needs a real
  per-port clock-tree change (which peripheral bus, which prescaler) and
  re-verification against every OTHER F_CPU-derived contract that would
  shift with it - pulse width (CONTRACTS.md #4's 8-bit horizon), PWM
  frequency, UART baud, watchdog timing - which is real per-port hardware
  engineering this file does not attempt. This guard exists so that gap
  stays visible and deliberate instead of silently shipped.

  THE THRESHOLD, AND THE ACKNOWLEDGMENT ESCAPE HATCH
  ------------------------------------------------------
  200 dominant-axis steps/sec (F_CPU <= 104,857,600, i.e. ~104.9 MHz) is
  chosen because every unit below it lands at or under stm32f411's
  measured 183 steps/sec (27.5 mm/min @ 400 steps/mm / 137 mm/min @ 80
  steps/mm - already a real, if lesser, concern, but not this guard's cut
  line), while hc32f460/dspic33ak128mc102 (200 MHz, 381 steps/sec) and
  stm32h523 (250 MHz, 477 steps/sec) land at 57-72 mm/min @ 400 steps/mm
  and 286-358 mm/min @ 80 steps/mm - inside ordinary finishing-to-roughing
  feed ranges by the project owner's own examples (V-carve/engraving
  detail, thread milling, fine finishing passes in hard material). A port
  that knowingly ships above the threshold without the real clock-domain
  remedy (the three named above, today) must define
  GRBL_ACKNOWLEDGE_AMASS_FLOOR in its own prelude.h, BEFORE this include,
  with a comment - the same discipline CONTRACTS.md #37 (baseline-entry-
  discipline) already requires of a warning-baseline entry: a permanent,
  reviewable admission, not a silent suppression. Acknowledged ports still
  get a `#warning` (non-fatal, visible in every build log) instead of a
  silent pass.

  SEEN TO ACTUALLY FIRE, NOT JUST INSPECTED: this batch, stm32h523's
  GRBL_ACKNOWLEDGE_AMASS_FLOOR line was temporarily commented out and
  rebuilt. Verbatim transcript and restoration in CONTRACTS.md
  "amass-floor".
*/

#ifndef GRBL_PLATFORM_COMMON_AMASS_FLOOR_H
#define GRBL_PLATFORM_COMMON_AMASS_FLOOR_H

#ifdef F_CPU

#define GRBL_AMASS_FLOOR_STEPS_PER_SEC (F_CPU / 524288ULL)

#ifndef GRBL_ACKNOWLEDGE_AMASS_FLOOR

_Static_assert(GRBL_AMASS_FLOOR_STEPS_PER_SEC <= 200ULL,
    "AMASS 16-bit clamp minimum-speed floor (F_CPU/524288 dominant-axis "
    "steps/sec) exceeds 200 steps/sec at this port's F_CPU - see "
    "CONTRACTS.md #amass-floor. Below this floor, commanded feeds execute "
    "FASTER than programmed, silently (a clamp, not a crash). At 200 "
    "MHz+, this lands inside ordinary finishing/roughing feed ranges, not "
    "just an unreachable edge case. Either lower the stepper timer's "
    "effective input clock (sg2002/Makefile's F_CPU-is-the-timer-clock "
    "precedent, not the raw core frequency) or, having reviewed "
    "CONTRACTS.md #amass-floor and accepted the consequence for this "
    "port, #define GRBL_ACKNOWLEDGE_AMASS_FLOOR before this include with "
    "a comment stating why.");

#else

#warning "GRBL_ACKNOWLEDGE_AMASS_FLOOR: AMASS floor exceeds 200 steps/sec (CONTRACTS.md #amass-floor); feeds below it execute faster than programmed; no clock-domain remedy has landed for this port yet"

#endif // GRBL_ACKNOWLEDGE_AMASS_FLOOR

#endif // F_CPU

#endif // GRBL_PLATFORM_COMMON_AMASS_FLOOR_H
