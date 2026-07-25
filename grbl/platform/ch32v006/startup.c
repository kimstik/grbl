/*
  startup.c - CH32V006 reset entry + PFIC vector table
  Part of Grbl

  PORTING-CHECKLIST Step 0/1 (+ the Step 3-6 vector wiring). RISC-V has
  no ARM-style hardware SP/PC autoload from a data table: `_start` (naked,
  at the base of flash via .init) sets SP itself, then Reset_Handler does
  .data/.bss init, points mtvec at the vector table, and calls main().

  INTERRUPT MODE - the M1-M3 "direct vs vendor vectored" open question
  (CONTRACTS.md #14.2) is now CLOSED with TRM facts (RM 6.5.3.2 MTVEC):
    MODE0 (bit 0) = 1: entry address = BASEADDR + interrupt_number * 4
    MODE1 (bit 1) = 1: table entries are ABSOLUTE ADDRESSES (function
                       pointers), not jump instructions
  This port uses MODE0=1, MODE1=1: a plain `const` array of C function
  pointers below IS the vector table - no asm jump stubs needed, and the
  hot vectors (TIM2/STK/USART1/EXTI) get hardware dispatch instead of an
  mcause switch. BASEADDR is bits [31:2], so 4-byte alignment suffices.

  HPE / HARDWARE STACKING - DOCUMENTED CHOICE (task brief asks for it):
  QingKe V2C's INTSYSCR (CSR 0x804) has HWSTKEN (bit 0, vendor hardware
  prologue: auto register push) and INESTEN (bit 1, 2-level nesting).
  BOTH RESET TO 0 AND ARE LEFT AT 0 by this port:
    - HWSTKEN=0 means handlers need a full software frame - which is
      precisely what GCC's __attribute__((interrupt)) emits (spill +
      `mret`; disassembly-verified). Enabling HWSTKEN under GCC-attributed
      handlers would double-save (harmless but slow) and its interaction
      with picolibc/GCC frames is silicon-unverified - correctness first.
    - INESTEN=0 means no preemption: core's sei() inside ISR_STEP
      (stepper.c:355) cannot nest the pulse-reset interrupt into the
      running handler; delivery defers to handler exit. This is the SAME
      accepted posture as the SAMD21 M0+ reference (CONTRACTS.md #5.2:
      "acceptable only because ISR_STEP's tail is short"). Flip-side
      benefit: no nested-trap mepc/mstatus clobber hazard on a core where
      GCC's interrupt attribute does not save those CSRs.
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

// Real vector bodies (handlers.c, all __attribute__((interrupt)))
extern void TIM2_IRQHandler(void);
extern void SysTick_Handler(void);
extern void EXTI7_0_IRQHandler(void);
extern void USART1_IRQHandler(void);

// ============================================================================
// DEFAULT HANDLER - loud hang for exceptions and unexpected interrupts.
// Exceptions funnel to the HardFault slot (vector 3, RM table 6-1); a trap
// landing here is a bug, and hanging visibly beats silently swallowing it
// ("compiles but dead" anti-pattern).
// ============================================================================

__attribute__((interrupt))
void Default_Handler(void) {
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// PFIC VECTOR TABLE (absolute-address mode). 41 entries, numbers 0-40 per
// RM table 6-1. `used` + KEEP(.vectors) in script.ld guard it from any
// future --gc-sections reinstatement (CONTRACTS.md #14.3 lesson).
// ============================================================================

__attribute__((used, section(".vectors"), aligned(4)))
static void (* const PFIC_Vector[PFIC_VECTOR_COUNT])(void) = {
  [0]  = Default_Handler,        // reserved (reset enters via _start, not the table)
  [1]  = Default_Handler,        // reserved
  [2]  = Default_Handler,        // NMI
  [3]  = Default_Handler,        // HardFault - all exceptions land here
  [4]  = Default_Handler, [5]  = Default_Handler, [6]  = Default_Handler,
  [7]  = Default_Handler, [8]  = Default_Handler, [9]  = Default_Handler,
  [10] = Default_Handler, [11] = Default_Handler,
  [SysTick_IRQn]  = SysTick_Handler,      // 12 - pulse-reset timer (STK)
  [13] = Default_Handler,
  [SW_IRQn]       = Default_Handler,      // 14 - software int, unused
  [15] = Default_Handler,
  [WWDG_IRQn]     = Default_Handler,      // 16
  [PVD_IRQn]      = Default_Handler,      // 17
  [FLASH_IRQn]    = Default_Handler,      // 18
  [RCC_IRQn]      = Default_Handler,      // 19
  [EXTI7_0_IRQn]  = EXTI7_0_IRQHandler,   // 20 - limits + controls (shared)
  [AWU_IRQn]      = Default_Handler,      // 21
  [DMA1_CH1_IRQn] = Default_Handler, [DMA1_CH2_IRQn] = Default_Handler,
  [DMA1_CH3_IRQn] = Default_Handler, [DMA1_CH4_IRQn] = Default_Handler,
  [DMA1_CH5_IRQn] = Default_Handler, [DMA1_CH6_IRQn] = Default_Handler,
  [DMA1_CH7_IRQn] = Default_Handler,
  [ADC_IRQn]      = Default_Handler,      // 29
  [I2C1_EV_IRQn]  = Default_Handler, [I2C1_ER_IRQn] = Default_Handler,
  [USART1_IRQn]   = USART1_IRQHandler,    // 32 - serial RX/TX
  [SPI1_IRQn]     = Default_Handler,      // 33
  [TIM1_BRK_IRQn] = Default_Handler, [TIM1_UP_IRQn] = Default_Handler,
  [TIM1_TRG_IRQn] = Default_Handler, [TIM1_CC_IRQn] = Default_Handler,
  [TIM2_IRQn]     = TIM2_IRQHandler,      // 38 - stepper timer
  [USART2_IRQn]   = Default_Handler,      // 39
  [OPCM_IRQn]     = Default_Handler,      // 40
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

  // BUG #13-class ordering (CONTRACTS.md #12.4): fence between init
  // phases - plain stores are not guaranteed complete before the next
  // phase begins (kept even though QingKe reordering is unconfirmed -
  // correctness-first, see platform.h).
  __DSB();

  // Zero-initialize .bss section.
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  __DSB();

  // mtvec -> PFIC vector table, vectored-by-number (MODE0=1) with
  // absolute-address entries (MODE1=1) - see file header. Interrupts are
  // still globally masked (mstatus.MIE=0 out of reset) until core's
  // sei() at main.c:48.
  {
    uint32_t mtvec_val = ((uint32_t)PFIC_Vector & ~0x3u) | 0x3u;
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
  it" mechanism - the very first instructions after reset must set SP
  themselves. `naked` + inline asm, falling into Reset_Handler once SP is
  valid (CONTRACTS.md #14.2's worked non-ARM reference).
*/
__attribute__((naked, section(".init")))
void _start(void) {
  __asm__ volatile (
    "la sp, _estack \n"
    "jal Reset_Handler \n"
  );
}
