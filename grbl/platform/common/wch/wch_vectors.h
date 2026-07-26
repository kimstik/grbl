/*
  wch_vectors.h - mtvec vectored-mode setup + the interrupt-entry STRATEGY,
  Part of Grbl
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
