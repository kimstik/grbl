/*
  startup.c - SG2002 C906L reset entry and trap-vector setup
  Part of Grbl

  RISC-V has no ARM-style hardware SP/PC autoload from a data table
  (CONTRACTS.md §14 item 2), so this file supplies what the `_template`
  skeleton's ARM vector table cannot: a `naked` `_start` that establishes
  `sp` (and `gp`) itself before any C runs, then a C reset path.

  ============================================================================
  HOW THIS IMAGE IS ACTUALLY STARTED
  ============================================================================
  Not by a boot ROM out of flash - there is no flash on this core's side.
  Linux, running on the big core, loads this ELF with the upstream
  `sophgo,cv1800b-c906l` remoteproc driver: the driver copies each PT_LOAD
  segment to its p_paddr inside the device-tree reserved-memory carve-out,
  then releases the C906L from reset at the ELF's entry point. Stop/start via
  /sys/class/remoteproc/.../state re-loads the segments each time.

  Consequence for the boot-integrity ratchet (CONTRACTS.md §18, BUG #21):
  RISC-V has no SP-in-word0 convention to check, so this port asserts the
  architecture-appropriate invariant that ch32v006/ch570 established -
  `_start` must link at the image base - and the Makefile enforces it
  post-objcopy against script.ld's ORIGIN. Here the check carries EXTRA
  weight over those ports: the loader is a Linux driver that honours
  p_paddr, so an image whose entry drifted away from the carve-out base
  would be started at an address the driver never wrote to.

  ============================================================================
  TRAP MODE: DIRECT (mtvec MODE = 0)
  ============================================================================
  Deliberate, and the safe choice for a chip with no TRM. RISC-V standard
  direct mode means ONE trap entry with `mcause` dispatch in C - spec-defined
  behaviour on every RV64 core in existence, needing zero vendor facts.
  The alternative (vectored mode) buys shorter dispatch on an interrupt path
  that runs at serial and step rates, in exchange for depending on
  undocumented behaviour of an undocumented core. ch32v006 made the same call
  for the same reason before its TRM facts landed (§14 item 2).

  Interrupt CONTROLLER is the PLIC, so all external sources arrive as a
  single `mcause` = machine external interrupt and are demultiplexed by a
  PLIC claim - see handlers.c.

  ============================================================================
  WHAT THIS FILE DELIBERATELY DOES NOT TOUCH
  ============================================================================
  The C906 D-cache enable bits live in the T-Head vendor CSR `mhcr` (0x7c1).
  This file does not write it. Reasons: (a) writing an unimplemented CSR
  traps, and whether the cut-down C906L implements `mhcr` is UNVERIFIED like
  everything else about this part; (b) the correctness of the cross-core
  channel does not depend on it either way - the cache-maintenance sequence
  in shm.h is correct with caches on, and trivially correct with them off.
  Cache state is inherited from whatever released this core from reset. If a
  bring-up engineer confirms `mhcr`, enabling the D-cache here is a pure
  performance change, not a correctness one.
*/

#include <stdint.h>
#include "platform.h"
#include "shm.h"

// ============================================================================
// EXTERNAL SYMBOLS (script.ld)
// ============================================================================
extern uint64_t _sdata, _edata, _sidata;
extern uint64_t _sbss,  _ebss;

extern int main(void);

// handlers.c - the single direct-mode trap entry.
extern void sg2002_trap_entry(void);

// platform.c
extern void SystemClock_Config(void);

// ============================================================================
// RESET HANDLER (C portion - reached from _start with sp/gp already valid)
// ============================================================================
void Reset_Handler(void) {
  uint64_t *src, *dst;

  // Copy .data from its load address to its run address. On this target both
  // are DDR inside the same carve-out; the copy exists so that a restart
  // which re-enters the entry point WITHOUT a fresh remoteproc load still
  // gets pristine initialised data.
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // BUG #13-class ordering between init phases (CONTRACTS.md #12.4).
  __DSB();

  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  __DSB();

  /*
    mtvec: direct mode. Bits [1:0] = 0 select "all traps set pc to BASE";
    BASE must be 4-byte aligned, which sg2002_trap_entry's
    __attribute__((aligned(64))) over-satisfies. Interrupts stay globally
    masked (mstatus.MIE = 0) until core's sei() in main().
  */
  {
    uintptr_t base = (uintptr_t)&sg2002_trap_entry;
    __asm__ volatile ("csrw mtvec, %0" : : "r" (base) : "memory");
    // Machine external interrupts (the PLIC's single mcause line) are the
    // only source this port uses; unmask it in mie. Individual peripherals
    // are gated at the PLIC (platform.c).
    __asm__ volatile ("csrs mie, %0" : : "r" ((uintptr_t)(1UL << 11)) : "memory");
  }

  SystemClock_Config();
  sg2002_plic_init();

  main();

  // main() never returns in normal operation. Hang loudly rather than run
  // off into whatever Linux has in the next page of DDR.
  for (;;) {
    __asm__ volatile ("wfi");
  }
}

// ============================================================================
// _start - the real entry point. Must be the FIRST thing in the image
// (script.ld puts .init first; the Makefile's boot-integrity step verifies
// the resulting address).
//
// `gp` is set up with relaxation disabled around it - the standard RISC-V
// sequence. Without it, `la gp, __global_pointer$` would itself be relaxed
// into a gp-relative access before gp is valid.
// ============================================================================
__attribute__((naked, section(".init")))
void _start(void) {
  __asm__ volatile (
    ".option push            \n"
    ".option norelax         \n"
    "la gp, __global_pointer$\n"
    ".option pop             \n"
    "la sp, _estack          \n"
    "jal Reset_Handler       \n"
  );
}
