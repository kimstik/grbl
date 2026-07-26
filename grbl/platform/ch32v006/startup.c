/*
  startup.c - CH32V006 reset entry + PFIC vector table
  Part of Grbl
*/

#include <stdint.h>
#include "platform.h"
#include "../common/wch/wch_vectors.h"

// EXTERNAL SYMBOLS (from script.ld)

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

// DEFAULT HANDLER - loud hang for exceptions and unexpected interrupts.
// Exceptions funnel to the HardFault slot (vector 3, RM table 6-1); a trap
// landing here is a bug, and hanging visibly beats silently swallowing it
// ("compiles but dead" anti-pattern).

__attribute__((interrupt))
void Default_Handler(void) {
  while (1) {
    __asm__ volatile ("nop");
  }
}

// PFIC VECTOR TABLE (absolute-address mode). 41 entries, numbers 0-40 per
// RM table 6-1. `used` + KEEP(.vectors) in script.ld guard it from any
// future --gc-sections reinstatement (CONTRACTS.md #14.3 lesson).

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

// SYSTEM CLOCK BRING-UP (PORTING-CHECKLIST Step 1)
GRBL_BOOT_INIT void SystemClock_Config(void);

// GRBL_BOOT_INIT (== noinline) on both SystemInit and SystemClock_Config:
// each has exactly one call site, so LTO used to inline them away and
// leave no symbol in the RELEASE ELF - byte-for-byte the same `nm` output
// as a port whose clock init is never called at all (BUG #23, which hit
// stm32f103/f411/h523 and hc32f460 for real). Out-of-line is what lets
// common/init_check.sh prove post-link that the bring-up is in the image.
// Deliberately noinline and NOT `used` - see common/boot_init.h.
GRBL_BOOT_INIT void SystemInit(void) {
  SystemClock_Config();
}

// RESET HANDLER (C portion - reached from _start with SP already valid)
//
// `used` (CONTRACTS.md gap log, LTO batch): the ONLY call to this function
// is `jal Reset_Handler` inside _start's raw inline asm, below - invisible
// to LTO's IPA (it never parses asm strings for symbol references). With
// -flto and no other caller in the C call graph, whole-program analysis for
// an executable link treats an unreferenced external symbol as dead and
// removes it before codegen ever runs; the link then fails with "undefined
// reference to Reset_Handler" (the DEFINITION got deleted, but _start's
// asm-level call still needs it resolved). This is BUG #21's exact
// mechanism (KEEP() cannot save a symbol IPA already erased) on an ISA
// where the ARM ports' usual defense (Reset_Handler address-taken from a
// C-visible vector_table[]) does not apply - reset here is entered via
// hand-written assembly, not a hardware-loaded table entry. `used` pins
// this function to the emitted-symbols root set regardless of visible
// callers, the same role it already plays on PFIC_Vector[] below.

__attribute__((used))
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
  //
  // EXTRACTED (Phase 6 rolling #4, Part A) to
  // common/wch/wch_vectors.h::wch_mtvec_set_vectored() - same instruction
  // this inline block emitted, verified byte-identical by this batch's
  // rebuild gate. INTSYSCR is deliberately NOT written here (unlike
  // CH570's startup.c) - this port continues to rely on the TRM's
  // documented reset-0 value exactly as before this extraction; see
  // wch_vectors.h's header for why that stays a valid choice for THIS
  // chip while CH570 explicitly zeroes it.
  wch_mtvec_set_vectored(PFIC_Vector);

  SystemInit();

  main();

  // main() never returns in normal operation; if it does, hang rather
  // than run off into undefined memory.
  while (1) {
    __asm__ volatile ("nop");
  }
}

// _start - the real reset entry point (linked at the base of FLASH via
// script.ld's ENTRY(_start) + .init section placement)
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
