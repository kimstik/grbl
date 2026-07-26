/*
  nvmem.c - SG2002 settings storage in the shared carve-out (TU-replacement)
  Part of Grbl

  CONTRACTS.md #10, four-function API. Every other port in this tree backs
  NVMEM with on-chip flash. This core has none: it executes out of DDR that
  Linux handed it, and the only non-volatile storage on the board is behind
  Linux's filesystem. So the backing store is a 1 KiB slot in the same
  cross-core carve-out the serial rings live in (shm.h), with a two-tier
  durability story that is stated here rather than implied:

  TIER 1 - SURVIVES A FIRMWARE RESTART, WITH NO HOST COOPERATION AT ALL.
    The shared window is placed by script.ld in a region with NO loadable
    section (its address is a linker PROVIDE, not a section, so no PT_LOAD
    covers it). remoteproc writes only PT_LOAD segments, therefore
    stop/start/restart via /sys/class/remoteproc/.../state leaves the window
    byte-for-byte intact. `$100=123.456`, restart the firmware, `$$` shows
    the value - the PORTING-CHECKLIST Step 5 exit test - passes on the
    hardware alone.

  TIER 2 - SURVIVES A POWER CYCLE, WITH HOST COOPERATION.
    DDR does not. After every change this file sets `nvmem_dirty` and rings
    the doorbell; the host bridge is expected to copy the 1 KiB slot to a
    file and clear the flag. Restoring it before starting the firmware is
    likewise the host's job. That is a REQUIREMENT ON THE HOST SIDE, written
    down in platform.md as part of this port's ABI, not an assumption: a
    host that ignores it gets tier-1 durability and settings that revert to
    defaults after a power cycle, which is a visible, diagnosable behaviour
    rather than silent corruption.

  ERASED-STATE SEMANTICS: an uninitialised or host-cleared window is
  recognised by its magic word and filled with 0xFF - matching the
  erased-flash convention every other port's nvmem.c relies on, so core's
  existing "checksum failed, load defaults" path (settings.c) works with no
  special-casing here.

  COHERENCY: the window is cross-core memory like everything else in it, so
  reads observe and writes publish (shm.h). The nvmem slot is written ONLY
  by this core - the host reads it to persist it, and only writes it back
  while the firmware is stopped - so the invalidate in observe() can never
  discard a store of ours.

  CONTEXT (#10.1): mainline only, interrupts enabled, never from an ISR.
  Unlike a flash-emulation port this path cannot stall the stepper at all -
  there is no erase, no busy poll, no controller to wait on. It is a memcpy.
*/

#include <stdint.h>
#include "platform.h"
#include "shm.h"
#include "../../nvmem.h"

#define NVMEM_SIZE   SG2002_SHM_NVMEM_SIZE

// #10.2 requires at least 1 KB, byte-addressable, address 0 valid.
_Static_assert(NVMEM_SIZE >= 1024u, "CONTRACTS.md #10.2: NVMEM must be at least 1 KB");

// ----------------------------------------------------------------------------
// Lazy first-touch initialisation. Called at the top of every entry point
// rather than from a separate init hook, because core's first NVMEM access
// (settings.c reading the version byte at address 0) happens before any
// platform init function this port controls could run.
// ----------------------------------------------------------------------------
static void nvmem_ensure_ready(void) {
  volatile sg2002_shm_t *shm = SG2002_SHM;

  sg2002_shm_observe(&shm->nvmem_magic, sizeof(shm->nvmem_magic));
  if (shm->nvmem_magic == SG2002_SHM_NVMEM_MAGIC) {
    return;
  }

  // Fresh (or host-cleared) window: present it as erased storage.
  for (uint32_t i = 0u; i < NVMEM_SIZE; i++) {
    shm->nvmem[i] = 0xFFu;
  }
  sg2002_shm_publish(&shm->nvmem[0], NVMEM_SIZE);

  // Magic LAST, and only after the contents it certifies are published -
  // the same command-after-data ordering as the doorbell (#12.4).
  shm->nvmem_magic = SG2002_SHM_NVMEM_MAGIC;
  sg2002_shm_publish(&shm->nvmem_magic, sizeof(shm->nvmem_magic));
}

// Tell the host there is something worth persisting. Dirty flag first, then
// the doorbell - never the other way round.
static void nvmem_mark_dirty(void) {
  volatile sg2002_shm_t *shm = SG2002_SHM;

  shm->nvmem_dirty = 1u;
  sg2002_shm_publish(&shm->nvmem_dirty, sizeof(shm->nvmem_dirty));
  sg2002_doorbell_ring();
}

// ----------------------------------------------------------------------------
// Four-function NVMEM API (CONTRACTS.md #10)
// ----------------------------------------------------------------------------

unsigned char eeprom_get_char(unsigned int addr) {
  volatile sg2002_shm_t *shm = SG2002_SHM;

  if (addr >= NVMEM_SIZE) { return 0xFF; }   // erased semantics for out-of-range (#10.6)

  nvmem_ensure_ready();
  sg2002_shm_observe(&shm->nvmem[addr], 1u);
  return (unsigned char)shm->nvmem[addr];
}

void eeprom_put_char(unsigned int addr, unsigned char new_value) {
  volatile sg2002_shm_t *shm = SG2002_SHM;

  if (addr >= NVMEM_SIZE) { return; }        // drop out-of-range writes (#10.6)

  nvmem_ensure_ready();

  // Wear guard (#10.3). There is no flash cell to wear here, but the guard
  // is kept for the reason that matters on THIS port: it suppresses a
  // pointless publish + dirty flag + host doorbell on every unchanged byte
  // of a settings rewrite, which is the overwhelmingly common case.
  sg2002_shm_observe(&shm->nvmem[addr], 1u);
  if (shm->nvmem[addr] == new_value) { return; }

  shm->nvmem[addr] = new_value;
  sg2002_shm_publish(&shm->nvmem[addr], 1u);
  nvmem_mark_dirty();
}

/*
  Checksum: bitwise rotate, and the SAME function is used by both the write
  and the read path below (#10.4). This is deliberately NOT the AVR core's
  `(checksum << 1) || (checksum >> 7)` logical-OR quirk - that is preserved
  on AVR for byte-golden reasons and must never be imported into new code,
  nor ever "fixed" on AVR. Cross-platform NVMEM image portability is an
  explicit non-goal, so self-consistency on one platform is the whole
  contract.
*/
static inline uint8_t nvmem_checksum_step(uint8_t checksum, uint8_t value) {
  checksum = (uint8_t)((checksum << 1) | (checksum >> 7));
  return (uint8_t)(checksum + value);
}

void memcpy_to_nvmem_with_checksum(unsigned int destination, char *source, unsigned int size) {
  volatile sg2002_shm_t *shm = SG2002_SHM;
  uint8_t checksum = 0;
  unsigned int i;
  int changed = 0;

  if (destination >= NVMEM_SIZE || size >= NVMEM_SIZE ||
      destination + size + 1u > NVMEM_SIZE) { return; }   // (#10.6)

  nvmem_ensure_ready();
  sg2002_shm_observe(&shm->nvmem[destination], size + 1u);

  for (i = 0; i < size; i++) {
    uint8_t v = (uint8_t)source[i];
    checksum = nvmem_checksum_step(checksum, v);
    if (shm->nvmem[destination + i] != v) {
      shm->nvmem[destination + i] = v;
      changed = 1;
    }
  }
  if (shm->nvmem[destination + size] != checksum) {
    shm->nvmem[destination + size] = checksum;
    changed = 1;
  }

  if (changed) {
    sg2002_shm_publish(&shm->nvmem[destination], size + 1u);
    nvmem_mark_dirty();
  }
}

int memcpy_from_nvmem_with_checksum(char *destination, unsigned int source, unsigned int size) {
  volatile sg2002_shm_t *shm = SG2002_SHM;
  uint8_t checksum = 0;
  unsigned int i;

  if (source >= NVMEM_SIZE || size >= NVMEM_SIZE ||
      source + size + 1u > NVMEM_SIZE) { return 0; }

  nvmem_ensure_ready();
  sg2002_shm_observe(&shm->nvmem[source], size + 1u);

  for (i = 0; i < size; i++) {
    uint8_t v = (uint8_t)shm->nvmem[source + i];
    destination[i] = (char)v;
    checksum = nvmem_checksum_step(checksum, v);
  }

  return (checksum == (uint8_t)shm->nvmem[source + size]) ? 1 : 0;
}
