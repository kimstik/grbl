# Shared platform code port notes

---

# Design notes moved out of file banners

Source-compactness directive: file banners carry one purpose line plus
the license block; the rationale that used to sit above the `#include`s
lives here, keyed by file.

## `cortexm/cortexm_critical.h`

cortexm_critical.h - PRIMASK-based critical sections + sei/cli, shared

```
across every ARM Cortex-M port in this tree
EXTRACTED verbatim from the four ports that had byte-identical copies of
this text inline - stm32f103, stm32f411, stm32h523, hc32f460 - following
the common/wch/wch_critical.h precedent (Phase 6 rolling #4). The macro
bodies below are the SAME text those ports shipped; only their location
changed, so every consumer preprocesses to what it did before. HARD GATE
for this extraction: all four ports' RELEASE .bin MD5 unchanged against
artifacts/<port>/ (CONTRACTS.md #build-artifacts-tracked).
WHY THIS HEADER IS INJECTED BY prelude.h, NOT INCLUDED BY platform.h
(the one non-obvious thing here): grbl.h includes <avr/io.h> at its line
29, LONG before platform/hal.h -> platform.h at line 49. The shared AVR
stub common/dummy/avr/io.h deliberately `#error`s when sei()/cli() are
not already defined, because it cannot know a given chip's interrupt
primitive. So sei/cli must exist BEFORE grbl.h is parsed. Two ways exist
to arrange that, and both are used in this tree:
  - samd21 injects ../platform.h itself from its prelude (so platform.h's
    own sei/cli land early);
  - stm32f103/f411/h523 + hc32f460 have no platform.h in their prelude, so
    each previously carried a LOCAL avr/io.h that shadowed the shared stub
    via `-I.` preceding `-I../common/dummy`. Those four local stubs were
    identical apart from a chip name in two comments.
Including THIS header from those four preludes replaces both copies at
once - the shadowing avr/io.h stubs are gone (the shared
common/dummy/avr/io.h now resolves, and is satisfied because sei/cli are
already defined by the time grbl.h runs) and the HAL_* block is no longer
duplicated in four platform.h files.
Applicability: PRIMASK and CPSIE/CPSID exist on every Cortex-M profile
(M0/M0+/M3/M4/M33 - ARMv6-M and ARMv7-M/ARMv8-M alike), so this file is
correct for any Cortex-M port, not just the four listed above. It relies
on __enable_irq/__disable_irq/__get_PRIMASK/__set_PRIMASK, which each port
defines in its own regs.h (or gets from CMSIS core_cm*.h).
```

## `dummy/cpu_map.h`

cpu_map.h - Dummy stub for non-AVR platforms

This is a compatibility stub for platforms that don't use AVR-style
pin mappings. Each platform defines its pins in platform.h instead.
This file is only used when a platform doesn't provide its own cpu_map.h.
AVR platform has its own full cpu_map.h with real pin definitions.

## `nvmem_checksum.h`

nvmem_checksum.h - the chip-agnostic checksum-copy wrappers core GRBL

```
calls into a port's nvmem.c (NON-AVR ports only)
NOT AN ORDINARY HEADER - this file contains FUNCTION DEFINITIONS and is
meant to be #included exactly once, from inside a port's nvmem.c, AFTER
that port has defined EEPROM_SIZE, eeprom_get_char/eeprom_put_char and
(if it opts into the write half, see below) nvmem_write_range. Same
rationale as common/serial_ring_accessors.h: these are TU-replacement
ports (CONTRACTS.md #7) that do not link core grbl/nvmem.c at all, so
there is no translation unit these functions could otherwise share
without every port growing an extra object file and Makefile line.
============================================================================
HARD BOUNDARY: THIS FILE IS FOR NON-AVR PORTS ONLY. IT MUST NEVER BE
INCLUDED BY grbl/nvmem.c OR BY atmega328p.
============================================================================
Core grbl/nvmem.c computes its rolling checksum with
    checksum = (checksum << 1) || (checksum >> 7);   // LOGICAL or
which is upstream GRBL's long-standing typo: `||` yields 0 or 1, so the
"rotate" degenerates to a boolean and the core checksum is a much weaker
function than it looks. CONTRACTS.md §10.4 says NEVER to "fix" it - the
AVR golden binary (ratchet #1, Makefile:validate MD5) and every settings
blob already written by an atmega328p in the field depend on that exact
arithmetic. This file uses the BITWISE `|` rotate, which is what every
non-AVR port in this tree has always used: those ports were never
bug-compatible with AVR's EEPROM contents in the first place (different
storage, different sizes, no shared media), so they get the correct
rotate. Extracting the non-AVR form here does not touch, and must not be
made to touch, the core/AVR form.
============================================================================
WHAT THE INCLUDING nvmem.c MUST PROVIDE FIRST
============================================================================
  EEPROM_SIZE                emulated-EEPROM byte count (per port)
  eeprom_get_char(addr)      single-byte read
  GRBL_NVMEM_HAS_WRITE_RANGE optional opt-in, see below
  nvmem_write_range(addr, const uint8_t *src, size)
                             staged block write - ONLY required when
                             GRBL_NVMEM_HAS_WRITE_RANGE is defined
The write half is OPT-IN because the two write strategies in this tree
are genuinely different code, not formatting:
  - ch32v006, ch570, dspic33ak128mc102 stage a whole flash block once and
    program it (nvmem_write_range), so the wrapper computes the checksum
    first and then issues exactly two range writes. They `#define
    GRBL_NVMEM_HAS_WRITE_RANGE` before including this file.
  - samd21 has no nvmem_write_range at all: its eeprom_put_char does its
    own page read-modify-write per byte, and its wrapper interleaves
    checksum accumulation with per-byte puts. Sharing the block form
    there would change what the chip actually does to its flash (and its
    binary), so samd21 keeps its own write wrapper and takes only the
    read half below. Do not "unify" this without first giving samd21 a
    real nvmem_write_range - that is a behavior change, not a cleanup.
EXTRACTED verbatim from ch32v006/nvmem.c (character-identical in
ch570/nvmem.c apart from an explanatory comment, and in
dspic33ak128mc102/nvmem.c apart from a redundant (char) cast; samd21's
read half was the same logic with if/else instead of a conditional
expression). Byte-invariance proven on all four consumers.
```

## `serial_ring_accessors.h`

serial_ring_accessors.h - the chip-agnostic half of a TU-replacement

```
serial.c: the five ring-buffer accessors core GRBL calls
NOT AN ORDINARY HEADER - this file contains FUNCTION DEFINITIONS and is
meant to be #included exactly once, from inside a port's serial.c, AFTER
that port has declared its ring buffers. It is the "TU-replacement route"
(CONTRACTS.md #7) equivalent of a shared .c file: those ports do not link
core grbl/serial.c at all, so there is no translation unit these five
functions could otherwise live in without every port growing an extra
object file and an extra Makefile line.
WHAT THE INCLUDING serial.c MUST HAVE DEFINED FIRST (all five names are
identical in every consumer today - that is precisely why this extraction
is possible):
  RX_RING_BUFFER / TX_RING_BUFFER   (RX_BUFFER_SIZE+1)/(TX_BUFFER_SIZE+1);
                                    PER-PORT sizing stays in the port's
                                    config.h - nothing here fixes a size.
  rx_buffer[] / tx_buffer[]         static uint8_t ring storage
  rx_buffer_head / rx_buffer_tail   static volatile uint8_t
  tx_buffer_head / tx_buffer_tail   static volatile uint8_t
  SERIAL_NO_DATA                    from grbl/serial.h
EXTRACTED verbatim from ch32v006/serial.c (character-identical in
ch570/serial.c and dspic33ak128mc102/serial.c; samd21/serial.c had the
same logic written with if/else instead of early return and K&R empty
parens - normalized to this form, and proven byte-invariant on both of
its boards like the other three). Core grbl/serial.c and atmega328p are
NOT consumers and were not touched: the AVR port links the real core
serial.c, which owns its own copies of these functions plus the HAL_*
ISR macros this file has no business knowing about.
CONCURRENCY (do not "simplify" this): every accessor reads each volatile
index EXACTLY ONCE into a local and then works off the local. That is the
core serial.c:96-108 pattern and it is load-bearing - the opposite index
is written by the UART ISR, so re-reading it mid-function can observe two
different values within one comparison and produce a ring size that is
briefly negative (i.e. huge, as uint8_t). Pure math only below: no
register touches, no interrupt masking, nothing chip-specific.
```

## `stm32/stm32_flash.h`

stm32_flash.h - Flash programming API abstraction for all STM32 families

Platform-specific flash operations. Each platform implements these functions
according to its flash controller (F1/F4/H5 have different registers).

## `stm32/stm32_nvmem.c`

stm32_nvmem.c - Flash-based NVMEM emulation for all STM32 families

Uses platform configuration to support different flash geometries.

## `stm32/stm32_nvmem.h`

stm32_nvmem.h - Flash-based NVMEM emulation for all STM32 families

Platform-independent flash emulation using configuration from stm32_platform.h

## `stm32/stm32_platform.h`

stm32_platform.h - Common platform abstraction for all STM32 families

Platform-independent configuration interface for STM32 MCUs.
Each platform (F103/F411/H5) provides its own configuration.

## `stm32/stm32_timer.h`

stm32_timer.h - GRBL timer contract macros shared by every STM32 port

Contracts: platform/CONTRACTS.md sections 3-6; naming: platform/common/timer.md
EXTRACTED from stm32f103/timer.h, stm32f411/timer.h and stm32h523/timer.h,
which were 100% code-identical - every macro body below was already
character-for-character the same in all three; only comments and the
include-guard name differed. The per-family notes those three carried are
merged inline below rather than dropped.
WHY ONE FILE IS CORRECT ACROSS F1/F4/H5: the TIM2/TIM3 register shape
(CR1/DIER/SR/EGR/PSC/ARR/CNT/CCR1) is field-identical on all three
families, and TIM1 is an advanced-control timer on all three. Only the
BASE ADDRESSES differ, and those live in each port's own regs.h - which
this file includes by the plain name "regs.h", resolved per port through
the port directory's own `-I.` (F411's TIM1 is at 0x40010000, NOT F1/H5's
0x40012C00 - see stm32f411/regs.h's file header). Same division of labor
as the rest of common/stm32/: shared logic here, per-chip addresses and
clock trees there.
ISR-HOT CONTRACT SURFACE (CONTRACTS.md section 6.1): every macro below is
a SINGLE register access. Do not grow them into multi-statement bodies,
add read-modify-write where a plain store is used, or wrap them in
critical sections - stepper.c calls these from inside the step ISR.

## `stm32/stm32_timing.h`

stm32_timing.h - Common timing functions for all STM32 families

SysTick-based millisecond counter and DWT cycle counter for microsecond delays.
Works on all Cortex-M3/M4/M7/M33 cores.

## `stm32/stm32_watchdog.h`

stm32_watchdog.h - Independent Watchdog (IWDG) for all STM32 families

IWDG uses internal 40kHz RC oscillator, independent from main clock.
Identical API across all STM32 families (F1/F4/H5).

## `wch/wch_critical.h`

wch_critical.h - mstatus-based critical sections + sei/cli + memory

barriers, shared across WCH QingKe RISC-V cores
EXTRACTED (Phase 6 rolling #4, CH570 recon) verbatim from ch32v006's
Phase 4 platform.h - the macro bodies below are byte-for-byte the same
text that shipped there (CONTRACTS.md §8/§11/§12), only relocated so a
second WCH port does not re-derive or copy/paste them. HARD GATE
(PLAN.md Phase 6 rolling #4 Part A): ch32v006 including this header must
preprocess to the SAME text as its previous inline copy - verified by
this batch's rebuild (identical RELEASE text/data).
Why `mstatus` (not the vendor SDK's raw CSR 0x800) is the right register
on QingKe V3C too, not just V2C: the CH570 recon (CONTRACTS.md §20 gap
log, this batch) found the vendor's own `core_riscv.h`
(__risc_v_enable_irq/__risc_v_disable_irq) reads/writes CSR **0x800**
with a two-bit mask (0x88) - a DIFFERENT numeric address than the
standard `mstatus` (0x300) this file uses. That looked, at first, like a
real hardware difference between V2C and V3C that would make this
extraction wrong. It is not: WCH's own OFFICIAL startup assembly for
this exact chip (`startup_CH572.S`, Apache-2.0, openwch/ch570) enables
interrupts with `li t0, 0x88` / `csrw mstatus, t0` using the STANDARD
named CSR - the identical instruction and mask this file already used
for ch32v006. Independently, cnlohr/ch32fun (MIT) uses the same named
`mstatus` mnemonic uniformly across EVERY QingKe generation it supports,
V2 through the CH5xx (V3) family CH570 belongs to, and is exercised on
real hardware by its userbase. Two independent, hardware-facing sources
agree that `mstatus` (0x300) is the correct, portable primitive under a
MAINLINE mainline riscv64-unknown-elf-gcc toolchain; the vendor SDK's
raw-0x800 helpers are written for WCH's OWN forked compiler/runtime
convention (used internally by their `sys_safe_access_enable/disable()`
flash-unlock bracket) and are not evidence against using `mstatus` here.
This project does not reproduce the 0x800 primitive - CH570's nvmem.c
brackets its safe-access window with these same sei()/cli() macros
instead, deliberately choosing the one interrupt-gate primitive this
whole platform layer already trusts over introducing a second, less
understood one. See CONTRACTS.md §20 gap log entry for this batch.

## `wch/wch_pfic.h`

wch_pfic.h - PFIC (Program Fast Interrupt Controller) register layout,

shared across WCH QingKe RISC-V cores
EXTRACTED (Phase 6 rolling #4, CH570 recon), not written fresh: this is
the PFIC_TypeDef struct + PFIC_EnableIRQ/PFIC_DisableIRQ that shipped in
ch32v006.h (Phase 4 Steps 3-6, TRM-verified against CH32V00X RM V1.5,
cross-checked against Zephyr's Apache-2.0 ch32v006.dtsi). CONTRACTS.md
§14 item 7 recorded the offsets; the CH570 recon (PLAN.md rolling-ports
queue, CONTRACTS.md §20) found the SAME offsets hold on QingKe V3C
(independently confirmed against openwch/ch570's Apache-2.0
RVMSIS/core_riscv.h PFIC_Type, and cross-checked once more against
cnlohr/ch32fun's MIT ch32fun.h) - the only difference is the IRQ-count
window: QingKe V2C exposes 64 IRQ numbers (2 x 32-bit words per bank),
QingKe V3C exposes 256 (8 words per bank). Byte OFFSETS of every named
register (ISR@0x000, IPR@0x020, ITHRESDR@0x040, IENR@0x100, IRER@0x180,
IPSR@0x200, IPRR@0x280, IACTR@0x300, IPRIOR@0x400, SCTLR@0xD10) are
IDENTICAL on both cores - only the reserved-padding gaps between them
scale with the bank width. WCH_PFIC_IRQ_WORDS (defined by the including
chip header BEFORE this file) parameterizes that width; every reserved
gap below is expressed as an arithmetic function of it so the offsets
above hold for ANY value, not just 2 or 8 - verified by the
_Static_assert block at the end of this file for both values this
project currently uses.
HARD GATE (PLAN.md Phase 6 rolling #4 Part A): ch32v006 consuming this
header (WCH_PFIC_IRQ_WORDS=2) must reproduce its existing PFIC_TypeDef
byte-for-byte - this file changes NOTHING about ch32v006's behavior,
it only relocates already-proven-correct code so CH570 (WCH_PFIC_IRQ_WORDS=8)
can reuse it instead of re-deriving the same offsets from scratch.
Do NOT add chip-specific peripherals here (GPIO/UART/timers/flash) -
those are different IP per chip family member and stay in each port's
own chip header (CONTRACTS.md §14/§20 "reuse before write" scope: only
what the recon PROVED shareable moves here).

## `wch/wch_vectors.h`

wch_vectors.h - mtvec vectored-mode setup + the interrupt-entry STRATEGY,

```
shared across WCH QingKe RISC-V cores
EXTRACTED (Phase 6 rolling #4, CH570 recon) from ch32v006/startup.c
(Phase 4 Steps 3-6). Two things live here:
1. `wch_mtvec_set_vectored()` - the mtvec write ch32v006/startup.c's
   Reset_Handler already performed inline. QingKe's mtvec (RM 6.5.3.2 on
   V2C; the CH570 recon found the same MODE bits on V3C, CONTRACTS.md
   §20) has MODE0 (bit 0) = 1: table entries are indexed by IRQ number,
   and MODE1 (bit 1) = 1: entries are ABSOLUTE ADDRESSES (a plain C
   array of function pointers), not jump instructions. Both bits set
   (BASEADDR | 0x3) is what every WCH port in this tree uses.
   HARD GATE (PLAN.md Phase 6 rolling #4 Part A): ch32v006 calling this
   instead of its old inline asm block must compile to the SAME
   instructions - verified by this batch's byte-identical rebuild.
2. The INTERRUPT-ENTRY STRATEGY, documented here (not force-adopted by
   every consumer - see below) because CONTRACTS.md §20 found it
   transfers across the whole QingKe family, not just one chip:
     - INTSYSCR (CSR 0x804) bit 0 HWSTKEN (vendor hardware
       prologue/epilogue - automatic register push/pop) and bit 1
       INESTEN (2-level interrupt nesting). ch32v006's TRM (CH32V00X RM
       V1.5) documents both as reset-0 on V2C; the CH570 recon found the
       identical CSR number and reset-0 claim on V3C (CH572/CH570
       Datasheet V1.1 §3.4.2, openwch/ch570, Apache-2.0). CONTRACTS.md
       §20 additionally found that WCH's OWN official startup assembly
       for CH572 (`startup_CH572.S`) does NOT trust that reset value -
       it explicitly WRITES `csrw 0x804, 0x3` (BOTH bits SET) during
       boot, because their forked-compiler `"WCH-Interrupt-fast"`
       attribute is designed to cooperate with hardware stacking. That
       is the opposite of what this project's ISR strategy needs: this
       project's `__attribute__((interrupt))` is GCC's PLAIN, portable
       attribute (CONTRACTS.md §20's whole finding is that the vendor
       attribute silently no-ops on mainline GCC), which emits its OWN
       software register-save prologue. If HWSTKEN were left/set to 1,
       the hardware would push a SECOND, redundant frame on top of
       GCC's software one - at best wasted cycles, at worst a stack
       layout GCC's epilogue does not expect. Concretely: a WCH port
       MUST NOT reuse vendor startup boilerplate for this register - it
       must explicitly WRITE INTSYSCR = 0, not just trust "reset value is
       documented as 0", precisely because the vendor's own official
       example for this exact silicon programs it to something else.
     - Plain `__attribute__((interrupt))`, GCC's own default (machine
       mode assumed on this bare-metal target) - never the vendor's
       `__INTERRUPT` / `"WCH-Interrupt-fast"` macro (CONTRACTS.md §20).
   `wch_intsyscr_clear()` below is provided for any WCH port to call
   from its own startup code. ch32v006 (already landed, Phase 4, HARD
   GATE byte-identical) does NOT call it - it continues to rely on the
   documented reset-0 value exactly as it did before this extraction,
   unchanged, so Part A's rebuild-parity gate holds. CH570 (Part B, this
   batch) DOES call it, precisely because its own recon (unlike
   ch32v006's) surfaced a real vendor example that reprograms the
   register away from 0 - the defense-in-depth the task brief asks for.
```

## `dummy/avr/io.h`

avr/io.h - AVR stub for non-AVR platforms

Platform-specific interrupt control (`sei`/`cli`) must already be defined by
the time grbl.h reaches its `#include <avr/io.h>` (grbl.h line 29). This stub
cannot know a given chip's interrupt primitive, so it `#error`s out rather
than guessing. Ports satisfy the requirement from their injected `prelude.h`,
one of two ways:

- include the port's own `platform.h` from the prelude (samd21,
  dspic33ak128mc102), or
- include a shared per-architecture critical-section header from the prelude:
  `common/cortexm/cortexm_critical.h` (stm32f103/f411/h523, hc32f460) or
  `common/wch/wch_critical.h` (ch32v006, ch570).

sg2002 still carries a local `avr/io.h` that shadows this file via `-I` order.
