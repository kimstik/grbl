/*
  platform.h - Sophgo SG2002 (C906L runtime core) chip-specific HAL
  Part of Grbl

  TARGET: the SG2002's little C906L core - RV64, no MMU, machine mode only,
  ~700 MHz. This is the RUNTIME core on EVERY SG2002 configuration. The
  RISC-V-vs-ARM strap choice belongs to the BIG, Linux-hosting core (C906 or
  Cortex-A53, mutually exclusive); it never frees an ARM core to target
  instead, so "both ISA variants" collapses to exactly ONE port. See
  PLAN.md's sg2002 entry.

  DELIVERABLE SHAPE: a bare-metal blob, not a Linux program. Linux loads it
  with the upstream `sophgo,cv1800b-c906l` remoteproc driver (ELF segments
  into a device-tree reserved-memory carve-out; load/start/stop/restart via
  /sys/class/remoteproc/.../state). ONE carve-out backs both the firmware
  image and the shared-memory rings - see script.ld and shm.h.

  ############################################################################
  # EVERY CHIP FACT THIS PORT RESTS ON IS UNVERIFIED. No public TRM exists   #
  # for SG2002/CV1800B; sg2002.h carries a per-block banner naming what each #
  # claim rests on and what a bring-up engineer must confirm first. This is  #
  # not boilerplate hedging - it is the honest state of the sources.         #
  ############################################################################
*/

#ifndef PLATFORM_SG2002_H
#define PLATFORM_SG2002_H

#include <stdint.h>
#include "common/boot_init.h" // GRBL_BOOT_INIT (BUG #23, CONTRACTS.md #boot-init-unreachable)
#include "sg2002.h"
#include "timer.h"

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================
// String matches grbl/platform/hal.h's own SG2002 branch exactly. It is
// re-stated here (rather than left to hal.h) because the prelude injects this
// header first, and an identical redefinition is silent while a differing one
// warns on every translation unit.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "Sophgo SG2002"
#define PLATFORM_CPU      "RISC-V RV64IMAC (XuanTie C906L, no MMU, M-mode)"
#define PLATFORM_ARCH     "RISC-V"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================
#define PLATFORM_HAS_FPU           1   // hardware single-precision (F) - see the ARCH/ABI note below; no D
#define PLATFORM_HAS_DMA           1   // SoC has DMA (unused by this port)
#define PLATFORM_HAS_USB           1   // owned by Linux, never by this core
#define PLATFORM_HAS_HW_EEPROM     0   // NVMEM lives in the shared carve-out (nvmem.c)
#define PLATFORM_HAS_HW_MULTIPLY   1   // M extension
#define PLATFORM_HAS_HW_DIVIDE     1

/*
  ARCH/ABI NOTE (the toolchain decision, recorded where it is consumed).
  Built rv64imafc / lp64f - HARDWARE SINGLE-PRECISION FLOAT - not rv64gc,
  and (as of 2026-07-26) not the soft-float rv64imac/lp64 this port shipped
  with either:

  1. rv64gc/lp64d IS NOT BUILDABLE HERE. `gcc -march=rv64gc -mabi=lp64d
     -print-multi-directory` resolves to `rv64imafdc/lp64d`, and
     picolibc-riscv64-unknown-elf ships no such multilib - its rv64 list
     stops at rv64imafc/lp64f (verified by listing the installed lib tree).
  2. WHETHER F/D SURVIVE THE CUT-DOWN "L" CORE IS RESOLVED, not merely
     re-asserted, by a primary source: Milk-V/Sophgo's own shipped FreeRTOS
     SDK for this exact core (github.com/milkv-duo/milkv-duo-smallcore-
     freertos - same "C906L"/"C906-NOMMU" silicon, same CV1800B/SG2002
     family) builds `cvitek/scripts/toolchain-riscv64-elf.cmake` with
     `-march=rv64imafdc -mabi=lp64d -mcmodel=medany` - the vendor compiling
     real, shipped, hardware-run firmware for THIS core with hardware DOUBLE
     precision. A core implementing D structurally implements F, so
     rv64imafc/lp64f (single precision only) is a strict, safe subset of
     what the vendor's own build proves the hardware executes.

  This port still targets single precision only, by this project's own
  tree-wide FP=SINGLE default (CONTRACTS.md §17) - not because double is
  unavailable on this silicon (it demonstrably is, per point 2 above).
  Multilib confirmed present (not merely requested):
  /usr/lib/picolibc/riscv64-unknown-elf/lib/rv64imafc/lp64f/ ships
  crt0.o/libc.a/libm.a. Measured RELEASE effect of the ABI switch alone
  (before also enabling LTO): text 37156 -> 31348, 5 soft-float helper
  symbols -> 0 (nm-verified). Full before/after table: PLAN.md's sg2002
  hardware-float entry.
*/

// ============================================================================
// F_CPU - READ THIS BEFORE CHANGING THE CLOCK
//
// F_CPU here is the STEPPER TIMER'S TICK RATE, not the CPU core frequency.
// That is what core actually uses it for (nuts_bolts.h TICKS_PER_MICROSECOND
// feeds stepper period and pulse-width arithmetic; stepper.c's AMASS levels
// are F_CPU/N cutoff frequencies on the same timer). Declaring the 700 MHz
// CPU clock here would be a lie in exactly the direction CONTRACTS.md §14
// item 9 warns about, and a fatal one: core computes
//   step_pulse_time = -((pulse_us - 2) * TICKS_PER_MICROSECOND) >> 3
// into a uint8_t (CONTRACTS.md §4's 8-bit horizon). At 700 ticks/us the
// default 10 us pulse yields 700, which does not fit a uint8_t at all -
// pulse widths would wrap to garbage for every realistic setting. At the
// APB timer's clock the same expression stays inside the horizon, which is
// the AVR-origin design point.
//
// The CPU frequency is a SEPARATE constant (SG2002_CPU_HZ) and is used for
// nothing timing-critical - delays come from the CLINT mtime counter.
// ============================================================================
#ifndef F_CPU
  #error "F_CPU not defined - build via this platform's Makefile (sets -DF_CPU=$(CLOCK)UL)"
#endif
_Static_assert(F_CPU > 0, "F_CPU must be a real clock frequency in Hz");
_Static_assert((F_CPU / 1000000UL) >= 8UL,
               "F_CPU/1000000 (TICKS_PER_MICROSECOND) below 8 makes the >>3 pulse-width "
               "arithmetic of CONTRACTS.md #4 truncate to zero");
// The 8-bit horizon caps the settable pulse width at
//   pulse_us_max = 2 + (255 * 8) / TICKS_PER_MICROSECOND
// (AVR's own ceiling at 16 MHz is 129 us by the same formula - this is an
// inherited property of the origin arithmetic, not a new limitation). This
// assert pins a floor of 30 us, three times GRBL's 10 us default and well
// past any real step-driver requirement, so a future F_CPU change that
// would quietly shrink the usable range below that fails the build instead.
#define SG2002_PULSE_US_HEADROOM_CHECK  30UL
_Static_assert((((SG2002_PULSE_US_HEADROOM_CHECK - 2UL) * (F_CPU / 1000000UL)) >> 3) <= 255UL,
               "8-bit pulse horizon (CONTRACTS.md #4): at this F_CPU a 30 us step pulse "
               "already overflows core's uint8_t step_pulse_time - F_CPU is too high for "
               "the stepper timer role (see this header's F_CPU note)");

// UNVERIFIED: nominal C906L frequency, community-sourced. Used only for
// reporting and for the sanity bound on the mtime-based delay loop.
#define SG2002_CPU_HZ        700000000UL

// UNVERIFIED: CLINT mtime tick rate. Assumed equal to the timer block's
// clock (both are documented by the community as the SoC's 25 MHz reference
// on cv18xx parts). If these differ on real silicon, _delay_us/_delay_ms
// scale wrong by a constant factor - measurable in one scope shot at
// bring-up, and the ONLY thing that changes is this one constant.
#define SG2002_MTIME_HZ      F_CPU

// ============================================================================
// SHARED-WINDOW COHERENCY KNOB (declared port property, shaped like the FP
// knob of CONTRACTS.md §17). Set by the Makefile; the full decision and its
// justification live in shm.h's header.
//   CMO (default)  - explicit T-Head cache maintenance around every ring
//                    access. Correct under every hypothesis about this SoC.
//   NONCACHEABLE   - integrator has CONFIRMED the carve-out is non-cacheable
//                    on this core; cache ops removed, ordering fences kept.
// Neither is a no-op; an unrecognised value is a hard error, never a
// silently-degraded default.
// ============================================================================
#if !defined(SG2002_SHM_COHERENCY_CMO) && !defined(SG2002_SHM_COHERENCY_NONCACHEABLE)
  #error "SHM_COHERENCY not selected - build via this platform's Makefile (SHM_COHERENCY=CMO|NONCACHEABLE)"
#endif
#if defined(SG2002_SHM_COHERENCY_CMO) && defined(SG2002_SHM_COHERENCY_NONCACHEABLE)
  #error "SHM_COHERENCY: CMO and NONCACHEABLE are mutually exclusive"
#endif
#ifndef SG2002_SHM_COHERENCY_CMO
  #define SG2002_SHM_COHERENCY_CMO 0
#endif

// ============================================================================
// MEMORY - all of it is the DDR carve-out; there is no flash and no SRAM.
// The numbers come from script.ld (single source of truth) via the Makefile.
// ============================================================================
#define HAL_EEPROM_SIZE   0   // no hardware EEPROM; nvmem.c backs settings in the carve-out

// ============================================================================
// TYPE DEFINITIONS (must precede hal_gpio.h). GPIO "port" is the DesignWare
// bank index 0..3.
// ============================================================================
typedef uint8_t hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// ============================================================================
// GPIO INTERRUPTS (CONTRACTS.md #2). Core passes (name_PCMSK, name_INT,
// name_MASK); on this chip the first two carry the GPIO BANK index (board
// config sets both to the bank) and the mask is the pin mask within it.
// ============================================================================
void hal_gpio_interrupt_enable(uint8_t bank, uint32_t mask);
void hal_gpio_interrupt_disable(uint8_t bank, uint32_t mask);

#define HAL_GPIO_INTERRUPT_ENABLE(bank, unused, mask)   hal_gpio_interrupt_enable((bank), (mask))
#define HAL_GPIO_INTERRUPT_DISABLE(bank, unused, mask)  hal_gpio_interrupt_disable((bank), (mask))

// HAL_GPIO_IRQ_HANDLER is deliberately NOT defined here - hal_gpio.h owns it
// exclusively (CONTRACTS.md #2.2).

// ============================================================================
// GPIO PULL-UPS (CONTRACTS.md #1.4) - real writes into the pad-control
// block, never a no-op. gpio.h routes GPIO_MPULLUP_* here.
// ============================================================================
void hal_gpio_pullup_enable(uint8_t bank, uint32_t mask);
void hal_gpio_pullup_disable(uint8_t bank, uint32_t mask);

// ============================================================================
// MEMORY BARRIERS (CONTRACTS.md #12)
//
// `fence rw,rw` orders all prior loads/stores against all later ones - the
// architecturally correct primitive for #12.1's ring publish and #12.4's
// command-vs-data ordering. On this port it is NECESSARY BUT NOT SUFFICIENT
// for anything crossing to the other core: see shm.h. Nothing in this file
// may be used as a substitute for the cache maintenance there.
// ============================================================================
#define __DSB()  __asm__ volatile ("fence rw, rw" ::: "memory")
#define __DMB()  __asm__ volatile ("fence rw, rw" ::: "memory")

// ============================================================================
// CRITICAL SECTIONS (CONTRACTS.md #8) - save/restore mstatus.MIE (bit 3).
// Save/restore, not blind disable/enable: the pair runs inside the RX path
// on DEBUG builds, where an unconditional re-enable would corrupt nesting.
// ============================================================================
#define HAL_CRITICAL_SECTION_BEGIN() \
  uint64_t __hal_mstatus_save; \
  __asm__ volatile ("csrr %0, mstatus" : "=r" (__hal_mstatus_save)); \
  __asm__ volatile ("csrci mstatus, 8" ::: "memory")

#define HAL_CRITICAL_SECTION_END() \
  __asm__ volatile ("csrw mstatus, %0" : : "r" (__hal_mstatus_save) : "memory")

// ============================================================================
// INTERRUPT GLOBAL CONTROL (CONTRACTS.md #11). "memory" clobber is
// mandatory (#12.6) - it is the compiler barrier that keeps stores from
// floating across the interrupt-enable boundary.
// ============================================================================
#define sei()  __asm__ volatile ("csrsi mstatus, 8" ::: "memory")
#define cli()  __asm__ volatile ("csrci mstatus, 8" ::: "memory")

// ============================================================================
// WATCHDOG (CONTRACTS.md #9) - deliberately UNDEFINED. A no-op would be
// ILLEGAL under ENABLE_SOFTWARE_DEBOUNCE (debounce would silently vanish
// while the raw ISR path is compiled out); leaving the family undefined
// makes that build fail loudly instead, which is the contract's own
// prescribed behaviour. Same posture as ch32v006/ch570.
// ============================================================================

// ============================================================================
// PLIC / doorbell plumbing used by startup.c, handlers.c and serial.c.
//
// sg2002_plic_init() is called only from Reset_Handler, before main() -
// exactly the shape BUG #23 hit on four other ports (a pre-main init chain
// core's own golden-gate main.c never calls). GRBL_BOOT_INIT (noinline)
// keeps it a real, separately-named symbol so ../common/init_check.sh's
// post-link check (this port's Makefile INIT_SYMBOLS) can prove it survived
// the link instead of silently vanishing into Reset_Handler if LTO is ever
// turned on for this port.
// ============================================================================
GRBL_BOOT_INIT void sg2002_plic_init(void);
void sg2002_plic_enable(uint32_t irq, uint32_t priority);
void sg2002_plic_disable(uint32_t irq);

void sg2002_doorbell_init(void);
void sg2002_doorbell_ring(void);   // signal the host: data is ready
void sg2002_doorbell_ack(void);    // clear OUR pending doorbell (called first in the ISR)

#endif // PLATFORM_SG2002_H
