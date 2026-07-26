/*
  shm.h - cross-core shared-memory channel layout + coherency primitives
  Part of Grbl

  This file is the ABI between the GRBL firmware running on the SG2002's
  C906L runtime core and the Linux-side bridge running on the big core. It
  is also where CONTRACTS.md's cross-core cache-coherency obligation
  (#cross-core-cache-coherency) is discharged.

  ============================================================================
  WHY A SHARED-MEMORY RING INSTEAD OF A UART
  ============================================================================
  CONTRACTS.md §7 binds serial SEMANTICS, not a peripheral. The runtime core
  here has no UART of its own worth spending (every on-chip UART is a pin
  budget Linux usually already owns), but it does have the thing a UART is a
  poor substitute for: a DDR carve-out both cores can see. So §7 is
  implemented over a byte ring in that carve-out:

    RX_PENDING            -> h2r.head != h2r.tail
    HAL_SERIAL_RX_ISR     -> the mailbox doorbell IRQ (handlers.c)
    HAL_SERIAL_READ_DATA  -> pop one byte from h2r
    HAL_SERIAL_WRITE_DATA -> push one byte into r2h

  This port takes the TU-replacement route (CONTRACTS.md §0/§7) - core
  grbl/serial.c is excluded and serial.c here provides serial.h's API - for
  the same reason samd21 and ch570 do: the ring bookkeeping does not fit
  behind single-expression macros.

  ONE DELIBERATE, CONTRACT-LEGAL CARDINALITY CHANGE: a doorbell fires once
  per BURST, not once per byte, so the doorbell handler DRAIN-LOOPS. §7's
  table binds what each macro means, not how many interrupts deliver N
  bytes, so this is legal - and it is a large win (one interrupt entry per
  burst instead of per byte). The invariant that makes it safe is stated in
  serial.c and must not be violated: the drain loop calls the READ_DATA
  equivalent exactly as many times as N separate byte interrupts would, so
  BUG #19's realtime-command interception - which lives in the per-byte path,
  not in the interrupt plumbing - is inherited completely unchanged.

  ============================================================================
  COHERENCY: THE DECISION AND WHY
  ============================================================================
  CONTRACTS.md #cross-core-cache-coherency: the two cores have separate,
  non-coherent L1 D-caches. Ordering fences are NOT sufficient; the producer
  must write back and the consumer must invalidate, and the doorbell write
  must be sequenced strictly AFTER the writeback (the BUG #13 class composed
  with the coherency class). That doc names mapping the window non-cacheable
  as the preferred simplification "where the SoC's PMA/MMU configuration
  allows it".

  DECISION: this port DEFAULTS to explicit cache maintenance (CMO), and
  offers the non-cacheable window as a declared, opt-in alternative
  (SHM_COHERENCY=NONCACHEABLE, a Makefile knob shaped exactly like the FP
  knob of CONTRACTS.md §17). Justification, in order of weight:

  1. THE PREFERRED ROUTE IS NOT REACHABLE FROM HERE, AND THE DOC'S OWN
     PRECONDITION SAYS SO. The C906L runs with NO MMU, in machine mode.
     T-Head's documented way to mark memory non-cacheable/strongly-ordered
     is the extended page-attribute bits in a PTE - and there are no PTEs on
     a core with no MMU. What remains is the SoC's PMA configuration, which
     is fixed in the fabric and undocumented for this chip (no TRM exists).
     A simplification you cannot program is not a simplification; choosing it
     by default would mean shipping a port whose correctness rests on an
     unwritable configuration bit.
  2. IT IS ALSO WHAT THE VENDOR'S OWN C906L FIRMWARE DOES. The cvitek RTOS
     images for this exact core reach their Linux-shared buffers through
     explicit cache ops, not a non-cacheable mapping - the strongest
     available evidence about a chip with no documentation.
  3. THE ALTERNATIVE IS STILL BUILT, NOT DISMISSED. If a bring-up engineer
     confirms the carve-out is non-cacheable on the C906L side (e.g. the
     integrator places the window in a PMA region that is), building with
     SHM_COHERENCY=NONCACHEABLE removes every cache op and leaves the fences.
     That is a DECLARED port property with a real alternative implementation,
     not a silent no-op: the knob is validated in platform.h and an
     unrecognised value is a hard #error.

  The cost of choosing wrong in the safe direction is a handful of cache ops
  per byte at serial data rates - irrelevant. The cost of choosing wrong in
  the other direction is silent data corruption with no crash and no
  signature, which is the failure mode CONTRACTS.md flags as invisible to
  every test this project can run.

  ============================================================================
  CACHE-LINE SEPARATION IS LOAD-BEARING, NOT COSMETIC PADDING
  ============================================================================
  Cache maintenance operates on LINES, not variables. If a producer index
  and a consumer index share one 64-byte line, our writeback of the index we
  own also writes back our stale copy of the index the OTHER core owns -
  silently reverting the other core's progress. Every independently-written
  word in the structures below therefore sits on its own cache line, and
  _Static_asserts at the bottom of this file pin that property so a future
  field insertion cannot quietly break it. This hazard does not exist in any
  same-core producer/ISR ring in this tree, which is exactly why it is worth
  spelling out.
*/

#ifndef SG2002_SHM_H
#define SG2002_SHM_H

#include <stdint.h>
#include <stddef.h>
#include "sg2002.h"

// The coherency knob is a build-level declaration (Makefile -> platform.h).
// Repeated here so this header is not silently mis-compiled if it is ever
// reached without platform.h having been seen first.
#if !defined(SG2002_SHM_COHERENCY_CMO) && !defined(SG2002_SHM_COHERENCY_NONCACHEABLE)
  #error "SHM_COHERENCY not selected - build via this platform's Makefile (SHM_COHERENCY=CMO|NONCACHEABLE)"
#endif
#ifndef SG2002_SHM_COHERENCY_CMO
  #define SG2002_SHM_COHERENCY_CMO 0
#endif

// ============================================================================
// C906 D-cache line size.
// UNVERIFIED: 64 bytes is the XuanTie C906 documented line size and matches
// every community register dump; no SG2002 TRM confirms it. Over-estimating
// is harmless (extra ops); UNDER-estimating silently breaks the separation
// argument above, so the _Static_asserts below are written against this
// constant and the padding is generous.
// ============================================================================
#define SG2002_CACHE_LINE   64u

// ============================================================================
// CHANNEL ABI - the Linux-side bridge must agree with all of this.
// Bump SG2002_SHM_VERSION on any layout change; the host bridge is expected
// to refuse a version it does not know rather than misparse it.
// ============================================================================
#define SG2002_SHM_MAGIC        0x4C425247UL   // "GRBL" little-endian
#define SG2002_SHM_VERSION      1UL

// Ring capacity per direction, in bytes. Power of two so the index wrap is a
// mask. Deliberately generous (CONTRACTS/PLAN flagged TX backpressure as the
// open point of this design): 8 KiB of a 256 KiB window costs nothing and
// makes the full condition rare in practice.
#define SG2002_SHM_RING_SIZE    8192UL
#define SG2002_SHM_RING_MASK    (SG2002_SHM_RING_SIZE - 1UL)

// NVMEM (settings) backing store - see nvmem.c.
#define SG2002_SHM_NVMEM_SIZE   1024UL
#define SG2002_SHM_NVMEM_MAGIC  0x4D564E47UL   // "GNVM" little-endian

// One index, alone on its cache line.
typedef struct {
  volatile uint32_t v;
  uint8_t  _pad[SG2002_CACHE_LINE - sizeof(uint32_t)];
} sg2002_idx_t;

// A unidirectional byte ring. `head` is written ONLY by the producer,
// `tail` ONLY by the consumer - the single-writer-per-line property the
// cache maintenance below depends on.
typedef struct {
  sg2002_idx_t     head;
  sg2002_idx_t     tail;
  volatile uint8_t data[SG2002_SHM_RING_SIZE];
} sg2002_ring_t;

typedef struct {
  // --- immutable descriptor, written once by this core at serial_init ---
  volatile uint32_t magic;
  volatile uint32_t version;
  volatile uint32_t ring_size;
  volatile uint32_t nvmem_size;
  uint8_t  _pad_desc[SG2002_CACHE_LINE - 4 * sizeof(uint32_t)];

  // --- liveness flag, written only by this core ---
  volatile uint32_t rt_ready;
  uint8_t  _pad_ready[SG2002_CACHE_LINE - sizeof(uint32_t)];

  // --- data channel ---
  sg2002_ring_t h2r;   // host -> runtime core. Our RX. Host owns head, we own tail.
  sg2002_ring_t r2h;   // runtime core -> host. Our TX. We own head, host owns tail.

  // --- persistent settings image (nvmem.c) ---
  volatile uint32_t nvmem_magic;
  uint8_t  _pad_nvm0[SG2002_CACHE_LINE - sizeof(uint32_t)];
  volatile uint32_t nvmem_dirty;   // we set; host clears after persisting
  uint8_t  _pad_nvm1[SG2002_CACHE_LINE - sizeof(uint32_t)];
  volatile uint8_t  nvmem[SG2002_SHM_NVMEM_SIZE];
} sg2002_shm_t;

// The window's address comes from the linker (script.ld PROVIDEs it at the
// carve-out offset the device tree agrees on). NOTHING is emitted into the
// ELF for it - no section, no PT_LOAD - which is what makes the region
// survive a remoteproc stop/start cycle instead of being reloaded as zeros.
/*
  ALIGNMENT IS NOT DECORATION HERE. Declared with an explicit
  __attribute__((aligned)) because GCC propagates the DECLARED alignment of
  this symbol through the cast below: left at a bare `uint8_t []` (alignment
  1) the compiler assumed the whole structure was unaligned and split every
  `volatile uint32_t` index store into FOUR byte stores. That is not a
  performance wart - it is a torn index the other core can observe halfway
  written, i.e. exactly the cross-core corruption this whole file exists to
  prevent, produced silently by a declaration detail. Found by disassembling
  serial_init(), not by reasoning about it.

  The linker places this at ORIGIN(SHM), which script.ld keeps cache-line
  aligned; the _Static_asserts above pin the internal layout to match.
*/
extern uint8_t __shm_start[] __attribute__((aligned(SG2002_CACHE_LINE)));
#define SG2002_SHM   ((volatile sg2002_shm_t *)(void *)__shm_start)

_Static_assert(offsetof(sg2002_ring_t, head) % SG2002_CACHE_LINE == 0,
               "ring head must start a cache line (cross-core writeback would clobber a neighbour)");
_Static_assert(offsetof(sg2002_ring_t, tail) % SG2002_CACHE_LINE == 0,
               "ring tail must start a cache line (cross-core writeback would clobber a neighbour)");
_Static_assert(offsetof(sg2002_ring_t, data) % SG2002_CACHE_LINE == 0,
               "ring data must start a cache line");
_Static_assert(offsetof(sg2002_shm_t, rt_ready) % SG2002_CACHE_LINE == 0,
               "rt_ready must start a cache line");
_Static_assert(offsetof(sg2002_shm_t, h2r) % SG2002_CACHE_LINE == 0, "h2r misaligned");
_Static_assert(offsetof(sg2002_shm_t, r2h) % SG2002_CACHE_LINE == 0, "r2h misaligned");
_Static_assert(offsetof(sg2002_shm_t, nvmem_magic) % SG2002_CACHE_LINE == 0, "nvmem_magic misaligned");
_Static_assert(offsetof(sg2002_shm_t, nvmem_dirty) % SG2002_CACHE_LINE == 0, "nvmem_dirty misaligned");
_Static_assert(offsetof(sg2002_shm_t, nvmem) % SG2002_CACHE_LINE == 0, "nvmem misaligned");
_Static_assert((SG2002_SHM_RING_SIZE & SG2002_SHM_RING_MASK) == 0,
               "ring size must be a power of two (index wrap is a mask)");

// ============================================================================
// COHERENCY PRIMITIVES
//
// sg2002_shm_publish(p, n)  - producer side: make our stores at [p, p+n)
//                             visible to the other core.
// sg2002_shm_observe(p, n)  - consumer side: discard our cached copy of
//                             [p, p+n) so the next read sees the other
//                             core's stores.
//
// SAFETY OF THE INVALIDATE: sg2002_shm_observe() is only ever called on
// memory this core does NOT write (the other core's index, or the RX ring's
// data). Invalidating a line we had dirtied would DISCARD our own writes.
// The single-writer-per-line layout above is what makes every call site
// provably safe; do not point observe() at anything this core produces.
// ============================================================================

#if SG2002_SHM_COHERENCY_CMO

static inline void sg2002_shm_publish(const volatile void *p, size_t n) {
  uintptr_t a   = (uintptr_t)p & ~(uintptr_t)(SG2002_CACHE_LINE - 1u);
  uintptr_t end = (uintptr_t)p + n;
  for (; a < end; a += SG2002_CACHE_LINE) {
    sg2002_dcache_clean_line((const volatile void *)a);
  }
  SG2002_FENCE();
}

static inline void sg2002_shm_observe(const volatile void *p, size_t n) {
  uintptr_t a   = (uintptr_t)p & ~(uintptr_t)(SG2002_CACHE_LINE - 1u);
  uintptr_t end = (uintptr_t)p + n;
  SG2002_FENCE();
  for (; a < end; a += SG2002_CACHE_LINE) {
    sg2002_dcache_invalidate_line((const volatile void *)a);
  }
  SG2002_FENCE();
}

#else  /* SG2002_SHM_COHERENCY_NONCACHEABLE */

/*
  DECLARED ALTERNATIVE, not a no-op: the integrator has asserted that the
  shared window is non-cacheable on this core, so there are no cached copies
  to write back or discard and the ONLY remaining obligation is the ordering
  one (CONTRACTS.md §12.1 / §12.4) - which these fences discharge in full.
  Dropping the fences too WOULD be the illegal silent no-op; they stay.
*/
static inline void sg2002_shm_publish(const volatile void *p, size_t n) {
  (void)p; (void)n;
  SG2002_FENCE();
}

static inline void sg2002_shm_observe(const volatile void *p, size_t n) {
  (void)p; (void)n;
  SG2002_FENCE();
}

#endif

#endif // SG2002_SHM_H
