/*
  serial.c - SG2002 serial channel over cross-core shared memory
  Part of Grbl

  CONTRACTS.md #7, TU-replacement route (#0): core grbl/serial.c is excluded
  from the build and this file supplies serial.h's API. The transport is not
  a UART - it is a pair of byte rings in the DDR carve-out this core shares
  with Linux (shm.h owns the layout, the ABI and the coherency argument).

  ============================================================================
  THE BUG #19 INVARIANT - READ BEFORE TOUCHING THE DRAIN LOOP
  ============================================================================
  Realtime-command interception (`?`, `~`, `!`, ctrl-X, and the extended-ASCII
  override set) is NOT in the platform layer on any port - it lives in the
  per-byte RX path, and it is reproduced VERBATIM below from core
  grbl/serial.c's HAL_SERIAL_RX_ISR() body, character for character. That is
  BUG #19's whole lesson: a port that paraphrases this switch, or that routes
  bytes around it, silently loses feed-hold and reset.

  This port makes ONE deliberate change to the interrupt CARDINALITY: a
  doorbell fires once per BURST, not once per byte, so sg2002_rx_drain()
  loops. §7's table binds each macro's SEMANTICS, not a one-interrupt-per-byte
  cardinality, so this is contract-legal - and it is the reason this channel
  costs orders of magnitude fewer interrupt entries than a byte-at-a-time
  UART.

  THE INVARIANT THAT MAKES IT SAFE, stated so it cannot be lost: the drain
  loop performs the per-byte pop-and-classify exactly as many times as N
  separate byte interrupts would. Every byte the host sent passes through the
  switch below exactly once, in order. Nothing may batch, coalesce, skip or
  reorder bytes ahead of that switch. Adding a "fast path" that memcpy's a
  run of bytes straight into the RX ring would compile, link, pass every
  gate in this project, and silently break the reset key.

  ============================================================================
  TX BACKPRESSURE - the open point PLAN.md flagged, and how it is closed
  ============================================================================
  PLAN.md's design pass noted that GRBL's TX path assumes a hardware
  TX-empty interrupt, and that a shared-memory ring has nothing to interrupt
  on unless the host doorbells back when it frees space. This implementation
  does not need that: serial_write() SPINS on the host's tail index with
  interrupts left ENABLED, so the stepper and pulse-reset interrupts keep
  running normally while a full ring drains. Liveness therefore depends only
  on the host consuming bytes, never on a host->runtime doorbell. That also
  means the channel degrades gracefully if the mailbox facts in sg2002.h turn
  out to be wrong: a host that polls instead of waiting for doorbells is a
  fully functional peer.

  Blocking mainline until the host reads is the same semantic AVR has when
  its TX ring fills, so nothing above this layer notices a difference.
*/

#include <stdint.h>
#include "platform.h"
#include "shm.h"
#include "../../grbl.h"    // realtime CMD_* bytes, sys, mc_reset(), exec-flag setters (BUG #19)
#include "../../serial.h"

// ============================================================================
// LOCAL RX RING - the doorbell handler is its producer, exactly as a UART RX
// ISR would be, so core's consumer-side discipline (serial.h API, index read
// once into a local) is preserved unchanged. The SHARED ring is not used
// directly as core's RX buffer precisely because bytes must pass through the
// realtime-command switch on the way in.
// ============================================================================
#define RX_RING_BUFFER (RX_BUFFER_SIZE + 1)

_Static_assert(RX_BUFFER_SIZE <= 255 && TX_BUFFER_SIZE <= 255,
               "RX/TX_BUFFER_SIZE must fit the uint8_t ring index (BUG #12 class)");

static uint8_t rx_buffer[RX_RING_BUFFER];
static volatile uint8_t rx_buffer_head = 0;
static volatile uint8_t rx_buffer_tail = 0;

// ============================================================================
// SHARED-RING HELPERS
//
// Each helper names which index it owns and which it merely observes; that
// ownership is what makes the invalidate in sg2002_shm_observe() safe (see
// shm.h - invalidating a line this core had dirtied would discard our own
// writes).
// ============================================================================

// Observe the other core's index. We never write these.
static inline uint32_t shm_load_peer_idx(volatile sg2002_idx_t *idx) {
  sg2002_shm_observe(&idx->v, sizeof(idx->v));
  return idx->v;
}

// Publish an index this core owns.
static inline void shm_store_own_idx(volatile sg2002_idx_t *idx, uint32_t v) {
  idx->v = v;
  sg2002_shm_publish(&idx->v, sizeof(idx->v));
}

// ============================================================================
// serial_init - bring up the channel and the doorbell.
//
// HANDSHAKE: this core owns initialisation of the whole window. It writes
// the descriptor, zeroes BOTH rings' indices, publishes all of it, and only
// then sets rt_ready. The host bridge must wait for magic + a version it
// understands + rt_ready before touching any index. Without that ordering a
// host that attached before we booted would race our zeroing of ITS head
// pointer.
// ============================================================================
void serial_init(void) {
  volatile sg2002_shm_t *shm = SG2002_SHM;

  shm->rt_ready = 0u;
  sg2002_shm_publish(&shm->rt_ready, sizeof(shm->rt_ready));

  shm->magic      = SG2002_SHM_MAGIC;
  shm->version    = SG2002_SHM_VERSION;
  shm->ring_size  = SG2002_SHM_RING_SIZE;
  shm->nvmem_size = SG2002_SHM_NVMEM_SIZE;
  sg2002_shm_publish(&shm->magic, sizeof(uint32_t) * 4u);

  shm->h2r.head.v = 0u;
  shm->h2r.tail.v = 0u;
  shm->r2h.head.v = 0u;
  shm->r2h.tail.v = 0u;
  sg2002_shm_publish(&shm->h2r.head.v, sizeof(uint32_t));
  sg2002_shm_publish(&shm->h2r.tail.v, sizeof(uint32_t));
  sg2002_shm_publish(&shm->r2h.head.v, sizeof(uint32_t));
  sg2002_shm_publish(&shm->r2h.tail.v, sizeof(uint32_t));

  sg2002_doorbell_init();

  // rt_ready LAST, and after a full publish of everything it certifies -
  // the same "command strictly after the data it commits" ordering the
  // doorbell obeys (CONTRACTS.md #12.4 composed with the cross-core class).
  shm->rt_ready = 1u;
  sg2002_shm_publish(&shm->rt_ready, sizeof(shm->rt_ready));
}

// ============================================================================
// serial_write - push one byte into the runtime->host ring.
//
// FULL PRODUCER SEQUENCE (CONTRACTS.md cross-core-cache-coherency):
//   write data -> writeback -> fence -> publish head -> writeback -> fence
//   -> doorbell
// The doorbell MUST be last. A doorbell that overtakes the writeback signals
// the host to invalidate-and-read a line that still holds stale bytes -
// compiles clean, fails silently, exactly the composition of the BUG #13
// class with the coherency class that CONTRACTS calls out.
//
// DOORBELL COALESCING: rung only when the ring was observed EMPTY before
// this push - a host that is already draining will keep draining until it
// finds the ring empty, so one doorbell per idle-to-busy transition is
// sufficient. No wakeup can be lost as long as the host's IRQ delivery is
// COUNTING rather than level-sampled (the stock uio_pdrv_genirq driver's
// read() returns the accumulated interrupt count, so a doorbell that lands
// between the host's emptiness check and its blocking read still wakes it).
// That requirement is part of this channel's ABI and is stated in
// platform.md as such.
// ============================================================================
void serial_write(uint8_t data) {
  volatile sg2002_shm_t *shm  = SG2002_SHM;
  volatile sg2002_ring_t *r   = &shm->r2h;

  uint32_t head      = r->head.v;                 // we own it; no observe needed
  uint32_t next_head = (head + 1u) & SG2002_SHM_RING_MASK;
  uint32_t tail      = shm_load_peer_idx(&r->tail);
  int      was_empty = (head == tail);

  // Wait for space. Interrupts stay enabled: the stepper and pulse-reset
  // interrupts must keep running while we stall here (see the file header).
  // The doorbell is rung ONCE on entering the wait - a full ring means the
  // host has work whether or not it noticed - and then we simply poll, so a
  // stalled host cannot turn into an MMIO storm.
  if (next_head == tail) {
    sg2002_doorbell_ring();
    do {
      tail = shm_load_peer_idx(&r->tail);
    } while (next_head == tail);
    was_empty = 0;
  }

  r->data[head] = data;
  sg2002_shm_publish(&r->data[head], 1u);   // data visible FIRST

  shm_store_own_idx(&r->head, next_head);                 // then the index

  if (was_empty) {
    sg2002_doorbell_ring();                                // and only then the doorbell
  }
}

// ============================================================================
// serial_read / buffer accounting - plain local-ring consumer code, the same
// shape every port in this tree uses (index read once into a local).
// ============================================================================
uint8_t serial_read(void) {
  uint8_t tail = rx_buffer_tail;

  if (rx_buffer_head == tail) {
    return SERIAL_NO_DATA;
  }
  uint8_t data = rx_buffer[tail];
  tail++;
  if (tail == RX_RING_BUFFER) { tail = 0; }
  rx_buffer_tail = tail;
  return data;
}

void serial_reset_read_buffer(void) {
  rx_buffer_tail = rx_buffer_head;
}

uint8_t serial_get_rx_buffer_available(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) { return (uint8_t)(RX_BUFFER_SIZE - (head - tail)); }
  return (uint8_t)(tail - head - 1);
}

uint8_t serial_get_rx_buffer_count(void) {
  uint8_t head = rx_buffer_head;
  uint8_t tail = rx_buffer_tail;

  if (head >= tail) { return (uint8_t)(head - tail); }
  return (uint8_t)(RX_RING_BUFFER - (tail - head));
}

uint8_t serial_get_tx_buffer_count(void) {
  volatile sg2002_ring_t *r = &SG2002_SHM->r2h;
  uint32_t head = r->head.v;
  uint32_t tail = shm_load_peer_idx(&r->tail);
  uint32_t used = (head - tail) & SG2002_SHM_RING_MASK;

  // Core's API is uint8_t and this ring is far larger; saturate rather than
  // wrap, so a "bytes queued" debug report can never read as nearly-empty
  // while thousands of bytes are in flight.
  return (used > 255u) ? 255u : (uint8_t)used;
}

// ============================================================================
// sg2002_rx_drain - THE RX PATH. Called from the mailbox doorbell handler
// (handlers.c), which is this port's HAL_SERIAL_RX_ISR (CONTRACTS.md #7).
//
// FULL CONSUMER SEQUENCE (cross-core-cache-coherency): doorbell -> invalidate
// -> fence -> read data. Both the peer's head index and the data bytes are
// invalidated before being read; our own tail is published back with a
// writeback so the host sees the space free up.
//
// The per-byte body below is core grbl/serial.c's HAL_SERIAL_RX_ISR() body,
// VERBATIM (BUG #19). Do not "clean it up".
// ============================================================================
void serial_irq_dispatch(void) {
  volatile sg2002_ring_t *r = &SG2002_SHM->h2r;

  for (;;) {
    uint32_t head = shm_load_peer_idx(&r->head);
    uint32_t tail = r->tail.v;                     // we own it

    if (head == tail) { break; }

    // Invalidate exactly what we are about to read - BOTH chunks when the
    // run wraps the ring, or the bytes past the wrap would be read from a
    // stale line. The ring data is a byte array this core never writes, so
    // an invalidate here can never discard a store of ours (shm.h).
    if (head > tail) {
      sg2002_shm_observe(&r->data[tail], head - tail);
    } else {
      sg2002_shm_observe(&r->data[tail], SG2002_SHM_RING_SIZE - tail);
      sg2002_shm_observe(&r->data[0], head);
    }

    while (tail != head) {
      uint8_t data = r->data[tail];
      tail = (tail + 1u) & SG2002_SHM_RING_MASK;

      // ---- BEGIN verbatim core grbl/serial.c HAL_SERIAL_RX_ISR() body ----
      // Pick off realtime command characters directly from the serial stream.
      switch (data) {
        case CMD_RESET:         mc_reset(); break;
        case CMD_STATUS_REPORT: system_set_exec_state_flag(EXEC_STATUS_REPORT); break;
        case CMD_CYCLE_START:   system_set_exec_state_flag(EXEC_CYCLE_START); break;
        case CMD_FEED_HOLD:     system_set_exec_state_flag(EXEC_FEED_HOLD); break;
        default :
          if (data > 0x7F) { // Real-time control characters are extended ASCII only.
            switch(data) {
              case CMD_SAFETY_DOOR:   system_set_exec_state_flag(EXEC_SAFETY_DOOR); break;
              case CMD_JOG_CANCEL:
                if (sys.state & STATE_JOG) { // Block all other states from invoking motion cancel.
                  system_set_exec_state_flag(EXEC_MOTION_CANCEL);
                }
                break;
              #ifdef DEBUG
                case CMD_DEBUG_REPORT: {
                  HAL_CRITICAL_SECTION_BEGIN();
                  bit_true(sys_rt_exec_debug,EXEC_DEBUG_REPORT);
                  HAL_CRITICAL_SECTION_END();
                } break;
              #endif
              case CMD_FEED_OVR_RESET: system_set_exec_motion_override_flag(EXEC_FEED_OVR_RESET); break;
              case CMD_FEED_OVR_COARSE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_PLUS); break;
              case CMD_FEED_OVR_COARSE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_COARSE_MINUS); break;
              case CMD_FEED_OVR_FINE_PLUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_PLUS); break;
              case CMD_FEED_OVR_FINE_MINUS: system_set_exec_motion_override_flag(EXEC_FEED_OVR_FINE_MINUS); break;
              case CMD_RAPID_OVR_RESET: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_RESET); break;
              case CMD_RAPID_OVR_MEDIUM: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_MEDIUM); break;
              case CMD_RAPID_OVR_LOW: system_set_exec_motion_override_flag(EXEC_RAPID_OVR_LOW); break;
              case CMD_SPINDLE_OVR_RESET: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_RESET); break;
              case CMD_SPINDLE_OVR_COARSE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_PLUS); break;
              case CMD_SPINDLE_OVR_COARSE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_COARSE_MINUS); break;
              case CMD_SPINDLE_OVR_FINE_PLUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_PLUS); break;
              case CMD_SPINDLE_OVR_FINE_MINUS: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_FINE_MINUS); break;
              case CMD_SPINDLE_OVR_STOP: system_set_exec_accessory_override_flag(EXEC_SPINDLE_OVR_STOP); break;
              case CMD_COOLANT_FLOOD_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_FLOOD_OVR_TOGGLE); break;
              #ifdef ENABLE_M7
                case CMD_COOLANT_MIST_OVR_TOGGLE: system_set_exec_accessory_override_flag(EXEC_COOLANT_MIST_OVR_TOGGLE); break;
              #endif
            }
            // Throw away any unfound extended-ASCII character.
          } else { // Write character to buffer
            uint8_t next_head = rx_buffer_head + 1;
            if (next_head == RX_RING_BUFFER) { next_head = 0; }

            if (next_head != rx_buffer_tail) {
              rx_buffer[rx_buffer_head] = data;
              __DMB();   // BUG #12: data store must land before head publish
              rx_buffer_head = next_head;
            }
          }
      }
      // ---- END verbatim core grbl/serial.c HAL_SERIAL_RX_ISR() body ----
    }

    // Publish the space we freed. Loop again: the host may have pushed more
    // while we were classifying, and one doorbell covers the whole burst.
    shm_store_own_idx(&r->tail, tail);
  }
}
