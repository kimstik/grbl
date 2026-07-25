/*
  startup.c - CH32V006 reset entry + trap/vector handling
  Part of Grbl

  PORTING-CHECKLIST Step 0/Step 1. This is the file with the LEAST
  reusable structure from `_template/startup.c` of anything in this
  port: the template's vector table is pure ARMv6-M/v7-M convention
  (hardware auto-loads SP from vector_table[0] and jumps to
  vector_table[1] on reset - zero software boot code needed for that
  part) and its ISR model is "array of function pointers the CPU
  hardware fetches directly". RISC-V has NEITHER of those things, even
  before getting to QingKe's PFIC specifics - see the GAP notes inline
  and the new RISC-V section folded into CONTRACTS.md.

  DESIGN CHOSEN FOR THIS BATCH: standard RISC-V direct-mode trap vector
  (mtvec mode=00, one trap entry, `mcause` dispatch in C) rather than
  attempting QingKe's vendor "absolute-address vectored" PFIC mode.
  Rationale: direct mode is unambiguously spec-correct on ANY RV32/64
  core (verified against this toolchain in this session - see the
  Makefile's ARCHFLAGS comment for the Zicsr gap found while proving
  it), whereas the vectored/absolute-address PFIC mode is a WCH
  extension this session could not verify against a real CH32V006 TRM
  or any hardware/emulator. Nothing in M1-M3 needs a real peripheral IRQ
  to fire (STP_TMR_INIT/serial/nvmem are all still PORT_TODO - Step 3+
  is "the next batch" per this batch's own mandate), so direct mode is
  sufficient today; the vectored-mode question is deferred, not silently
  dropped - see PFIC_Vector[] below and CONTRACTS.md.
*/

#include <stdint.h>
#include "platform.h"

// ============================================================================
// EXTERNAL SYMBOLS (from script.ld)
// ============================================================================

extern uint32_t _estack;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sidata;
extern uint32_t _sbss;
extern uint32_t _ebss;

extern int main(void);

void Default_Handler(void);

// ============================================================================
// TRAP ENTRY (direct mode - mtvec[1:0] = 00)
// ============================================================================
/*
  __attribute__((interrupt)) makes GCC emit the full callee-saved-register
  spill/restore and `mret` (verified by disassembly in this session: RV32EC
  + Zicsr correctly emits `mret` opcode 0x30200073 and a real prologue/
  epilogue for both plain and nested-call interrupt functions - see the
  toolchain-evidence transcript). QingKe's `mret` semantics are standard
  RISC-V privileged-spec `mret` - the PFIC's "hardware fast interrupt"
  behavior (documented informally as extra automatic context save/restore
  for lower latency) is additive hardware behavior UNDERNEATH this, not a
  different software contract; software still just needs a correct
  interrupt-attributed C function pointed to by mtvec, which is what this
  provides. `aligned(4)` satisfies direct-mode's BASE alignment
  requirement (RISC-V priv spec: mtvec.BASE is a 4-byte-aligned address
  in direct mode - the low 2 bits are the MODE field, not part of the
  address).
*/
__attribute__((interrupt, aligned(4)))
void trap_entry(void) {
  // GAP: no real ISR needs to run yet (Step 3+). A trap reaching here
  // today is either a synchronous exception (bug) or a spuriously
  // enabled peripheral IRQ (shouldn't happen - nothing in this batch
  // ever sets a PFIC IENR bit) - Default_Handler's infinite loop is the
  // correct "loud failure" for both, matching PORTING-CHECKLIST's
  // "compiles but dead" anti-pattern warning: better to hang visibly
  // than silently swallow a fault.
  Default_Handler();
}

void Default_Handler(void) {
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// PLACEHOLDER "CUSTOM VECTOR TABLE" (PFIC absolute-address vectored mode -
// NOT WIRED TO mtvec YET, see the design note above)
// ============================================================================
/*
  M1's ask is a "QingKe vector table" skeleton. This array is that
  skeleton: it is what Step 3+ will populate with real dispatcher
  function pointers (stepper_timer_irq_dispatch / serial_irq_dispatch /
  gpio_irq_dispatch, all already defined in handlers.c/serial.c) once
  the real PFIC IRQ numbering for THIS chip (not V003's) is confirmed
  against a datasheet (ch32v006.h's IRQn_Type is deliberately left
  almost empty for the same reason). Sized 32 as a placeholder - WCH
  V00x-family parts commonly expose on the order of 30-40 vectored
  sources; this is NOT a verified count for V006. Marked `used` so
  --gc-sections (once re-enabled per _template's README step 4) cannot
  silently discard it before anyone notices it is still a placeholder.
*/
#define PFIC_VECTOR_COUNT_PLACEHOLDER 32

__attribute__((used, aligned(4)))
static void (* const PFIC_Vector[PFIC_VECTOR_COUNT_PLACEHOLDER])(void) = {
  [0 ... PFIC_VECTOR_COUNT_PLACEHOLDER - 1] = Default_Handler,
};

// ============================================================================
// SYSTEM CLOCK BRING-UP (PORTING-CHECKLIST Step 1)
// ============================================================================
extern void SystemClock_Config(void);

void SystemInit(void) {
  SystemClock_Config();
}

// ============================================================================
// RESET HANDLER (C portion - reached from _start with SP already valid)
// ============================================================================

void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Copy .data section from Flash to RAM.
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // BUG #13-class ordering (CONTRACTS.md #12.4): fence between the .data
  // copy and .bss zero, and again before SystemInit - plain stores are
  // not guaranteed complete before the next phase begins. See platform.h
  // for why this uses `fence rw,rw` rather than assuming an in-order
  // pipeline needs nothing (UNVERIFIED whether QingKe truly needs it -
  // correctness-first until confirmed otherwise).
  __DSB();

  // Zero-initialize .bss section.
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  __DSB();

  // Point mtvec at trap_entry, direct mode (mode bits = 00 - trap_entry
  // is 4-byte aligned via its own attribute, and the low 2 bits are
  // masked off here defensively in case the linker ever placed something
  // odd there). Needs Zicsr (see platform.h's HAL_CRITICAL_SECTION
  // comment for the toolchain flag gap this session found).
  {
    uint32_t mtvec_val = ((uint32_t)trap_entry) & ~0x3u;
    __asm__ volatile ("csrw mtvec, %0" :: "r" (mtvec_val));
  }

  SystemInit();

  main();

  // main() never returns in normal operation; if it does, hang rather
  // than run off into undefined memory.
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// _start - the real reset entry point (linked at the base of FLASH via
// script.ld's ENTRY(_start) + .init section placement)
// ============================================================================
/*
  RISC-V has no ARM-style "vector_table[0] = initial SP, hardware loads
  it automatically" mechanism (GAP vs. every ARM port in this repo) - the
  very first instructions to run after reset must set SP themselves.
  `naked` + inline asm is the standard, portable way to do this on RISC-V
  (matches every bare-metal RISC-V bring-up this session is aware of,
  including the pre-existing but chip-mismatched CH32V006_PLAN.md sketch
  this file supersedes). Falls straight into Reset_Handler (a normal C
  function, not `naked`) once SP is valid.
*/
__attribute__((naked, section(".init")))
void _start(void) {
  __asm__ volatile (
    "la sp, _estack \n"
    "jal Reset_Handler \n"
  );
}
