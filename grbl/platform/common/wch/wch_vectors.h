/*
  wch_vectors.h - mtvec vectored-mode setup + the interrupt-entry STRATEGY,
  shared across WCH QingKe RISC-V cores
  Part of Grbl

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
*/

#ifndef GRBL_PLATFORM_COMMON_WCH_VECTORS_H
#define GRBL_PLATFORM_COMMON_WCH_VECTORS_H

#include <stdint.h>

// mtvec = table base (4-byte aligned) | MODE1 | MODE0.
static inline void wch_mtvec_set_vectored(const void *table) {
  uint32_t mtvec_val = ((uint32_t)(uintptr_t)table & ~0x3u) | 0x3u;
  __asm__ volatile ("csrw mtvec, %0" :: "r" (mtvec_val));
}

// INTSYSCR = CSR 0x804. Writes 0: HWSTKEN=0 (no vendor hardware
// prologue - GCC's plain `interrupt` attribute supplies the whole frame),
// INESTEN=0 (no 2-level nesting - matches the SAMD21 M0+ no-preemption
// reference posture, CONTRACTS.md §5.2/§14.2). Defense-in-depth: called
// explicitly by any port whose own recon found a reason not to trust the
// documented reset value (see file header) rather than assumed silently.
static inline void wch_intsyscr_clear(void) {
  __asm__ volatile ("csrw 0x804, zero");
}

#endif // GRBL_PLATFORM_COMMON_WCH_VECTORS_H
