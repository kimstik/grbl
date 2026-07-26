/*
  clock_width.h - build-time guard for CONTRACTS.md #36
  (clock-constant-width, BUG #18 class)
  Part of Grbl

  Copyright (c) 2026 kimstik
  Intelligence assisted
  License: MIT

  WHY THIS EXISTS
  ---------------
  grbl/stepper.c:1015 (core, frozen - never edited by this file or the
  ports that include it) computes
  `TICKS_PER_MICROSECOND*1000000*60`. grbl/nuts_bolts.h:47 (also core)
  defines `TICKS_PER_MICROSECOND` as `(F_CPU/1000000)`. Every operand is a
  compile-time constant, so GCC folds the whole expression at compile
  time, in F_CPU's OWN integer type - `unsigned long` is 32-bit on every
  ILP32 target this tree ships for (ARM/AVR/RISC-V32 -mabi=ilp32*), so the
  fold silently wraps (well-defined unsigned wraparound, NOT diagnosed by
  -Woverflow - that flag only fires on SIGNED overflow) the moment
  TICKS_PER_MICROSECOND exceeds ~71 (a ~71.58 MHz clock). Only
  `unsigned long long` is guaranteed >=64 bits by the C standard
  regardless of target ABI, and only it survives every clock this tree
  uses today (up to 250 MHz on the affected ARM ports, 700 MHz on
  sg2002) and any future one. Full arithmetic, the exact 172.6x/3.52x
  measured errors, and the dsPIC33AK128MC102 incident this class actually
  caused: CONTRACTS.md, "clock-constant-width" (#36).

  THE GAP THIS CLOSES
  -------------------
  A `_Static_assert(F_CPU > 0, ...)` (already present in several
  platform.h files) checks the VALUE, not the WIDTH - it cannot catch a
  port whose Makefile carries `-DF_CPU=$(CLOCK)UL` at a clock that
  currently fits under 32 bits, only to silently reintroduce the bug the
  day a board revision raises CLOCK past the threshold. This header
  checks the WIDTH of the literal the compiler actually assigned to the
  F_CPU token, independent of its numeric value: an `UL`-suffixed
  constant is `unsigned long` (sizeof == 4 on every ILP32 target this
  tree targets); a `ULL`-suffixed constant is `unsigned long long`
  (sizeof == 8, guaranteed by the C standard regardless of ABI). A port
  that reverts to `UL`, or that never had a suffix at all, fails THIS
  assert at compile time unconditionally - a build break at the exact
  moment the regression is introduced, not a silent wraparound discovered
  later (or never).

  VERIFIED TO ACTUALLY FIRE (not just inspected - see CONTRACTS.md #36
  and PLAN.md for the verbatim transcript): ch32v006/Makefile's
  `-DF_CPU=$(CLOCK)ULL` was temporarily reverted to `...UL` and rebuilt;
  the very first translation unit failed with this file's own
  _Static_assert message and `make` exited nonzero. The Makefile was then
  restored and rebuilt clean.

  WHERE THIS IS INCLUDED, AND WHY THAT IS SAFE
  ---------------------------------------------
  Every non-AVR port's prelude.h - the single header each port's Makefile
  injects into EVERY translation unit via `-include prelude.h` /
  `-include <board>/prelude.h` (the Phase-1 prelude canon,
  ARCHITECTURE.md "Build Prelude") - includes this file. F_CPU itself
  arrives via that same Makefile's `-DF_CPU=...` compiler flag, a
  command-line macro definition that exists for a translation unit from
  the very first character of preprocessing, before any `#include` is
  even opened. So this assert has no dependency on include order or on
  any other header having run first - it is immune to the prelude
  phase-ordering trap CONTRACTS.md #36 warns about (platform headers
  pulled in via `-include prelude.h` are preprocessed long before core's
  own `grbl/config.h` is reached on its own, correctly-timed pass, and
  include guards mean that later pass never re-enters them): there is
  nothing here for that later pass to have missed, because the one input
  this file reads - F_CPU - was never routed through any header at all.
  Confirmed empirically, not assumed: `arm-none-eabi-gcc -E` on
  stm32f103's main.c with this include added shows the assert's
  expansion sitting immediately under the `-include prelude.h` output,
  literally thousands of lines before grbl/config.h's own text appears in
  the same translation unit - and it still evaluates correctly, because
  the token it inspects (F_CPU) was already fully defined before either
  header opened.

  atmega328p is EXCLUDED from this file entirely, deliberately, not by
  oversight: it has no prelude.h at all. Its own injection is the
  repo-root Makefile's single `-include grbl/platform/common/gpio.h`
  (unrelated to this file), and that Makefile is golden-MD5-gated (see
  grbl/platform/atmega328p/Makefile's own header comment for the
  precedent of attaching ratchets at the shim layer instead of touching
  the golden build). Its F_CPU (16000000, no suffix at all) is a plain
  decimal literal that the C standard promotes to `long` (32-bit `long`
  is the first type in the no-suffix decimal-constant list that holds
  16000000 - AVR's `int` is only 16 bits) - TICKS_PER_MICROSECOND *
  60,000,000 = 960,000,000, comfortably under signed INT32_MAX
  (~2.147e9), and AVR's realistic clock ceiling (~20 MHz crystal) never
  approaches the ~35.8 MHz signed-overflow threshold this same class has
  for a non-suffixed constant. Requiring ULL there would mean editing the
  golden-gated root Makefile to close a class of bug that cannot occur on
  this port at any real clock - not worth the risk to the byte-exact
  gate. See CONTRACTS.md #36 for the full reasoning, restated there
  rather than only here so it survives independent of this file.
*/

#ifndef GRBL_PLATFORM_COMMON_CLOCK_WIDTH_H
#define GRBL_PLATFORM_COMMON_CLOCK_WIDTH_H

#ifdef F_CPU
_Static_assert(sizeof(F_CPU) >= 8,
    "F_CPU must be suffixed ULL (>=64-bit unsigned long long), not UL or "
    "a plain literal - see CONTRACTS.md #36 (clock-constant-width): "
    "unsigned long is 32-bit on every ILP32 target this tree ships for "
    "and silently wraps grbl/stepper.c:1015's compile-time constant fold "
    "above ~71.58 MHz, with zero compiler warning (unsigned overflow is "
    "well-defined wraparound, not diagnosed by -Woverflow).");
#endif

#endif // GRBL_PLATFORM_COMMON_CLOCK_WIDTH_H
