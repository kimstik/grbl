# ATmega328P port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `platform.h`

platform.h - AVR ATmega328P platform configuration

This file provides platform-specific definitions for AVR ATmega328P.
All definitions expand to original GRBL code for ZERO overhead.
