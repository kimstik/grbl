/*
  startup.c - CH570 reset entry + PFIC vector table
  Part of Grbl

  Same shape as ch32v006/startup.c (RISC-V has no ARM-style hardware SP/PC
  autoload): `_start` (naked, .init) sets SP, Reset_Handler does
  .data/.bss init, points mtvec at the vector table via
  common/wch/wch_vectors.h::wch_mtvec_set_vectored(), then calls main().

  INTERRUPT MODE: mtvec MODE0=MODE1=1 (absolute-address vectored mode) -
  CONTRACTS.md §14 item 2/§20: confirmed identical on QingKe V3C.

  INTSYSCR - UNLIKE ch32v006, this port explicitly WRITES INTSYSCR=0
  (common/wch/wch_vectors.h::wch_intsyscr_clear()) rather than only
  trusting the documented reset-0 value. Reason (CONTRACTS.md §20 gap log,
  this batch): this port's own recon found WCH's OFFICIAL startup
  assembly for this exact silicon family (`startup_CH572.S`, Apache-2.0)
  explicitly REPROGRAMS INTSYSCR to 0x3 (HWSTKEN=1, INESTEN=1) during
  boot - the opposite of what this project's plain `__attribute__((interrupt))`
  handlers need (GCC's software prologue, not the vendor hardware one).
  A future silicon revision or boot-ROM path could plausibly leave this
  CSR non-zero for the same reason WCH's own example sets it - explicit
  defense-in-depth, not just documentation.
    - HWSTKEN=0: handlers need a full software frame - exactly what GCC's
      interrupt attribute emits (spill + `mret`).
    - INESTEN=0: no preemption - core's sei() inside ISR_STEP
      (stepper.c) cannot nest the pulse-reset interrupt into the running
      handler; delivery defers to handler exit. Same accepted posture as
      ch32v006 (CONTRACTS.md §5.2) and the SAMD21 M0+ reference.
*/

#include <stdint.h>
#include "platform.h"
#include "../common/wch/wch_vectors.h"

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
extern void TMR_IRQHandler(void);
extern void SysTick_Handler(void);
extern void GPIOA_IRQHandler(void);
extern void UART_IRQHandler(void);

// ============================================================================
// DEFAULT HANDLER - loud hang for exceptions and unexpected interrupts.
// ============================================================================
__attribute__((interrupt))
void Default_Handler(void) {
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// PFIC VECTOR TABLE (absolute-address mode). 36 entries, numbers 0-35.
// `used` + KEEP(.vectors) in script.ld guard it from any future
// --gc-sections reinstatement (CONTRACTS.md §14 item 3 lesson).
// ============================================================================

__attribute__((used, section(".vectors"), aligned(4)))
static void (* const PFIC_Vector[PFIC_VECTOR_COUNT])(void) = {
  [0]  = Default_Handler, [1]  = Default_Handler,   // reserved
  [2]  = Default_Handler,                            // NMI
  [3]  = Default_Handler,                            // HardFault - all exceptions land here
  [4]  = Default_Handler, [5]  = Default_Handler, [6]  = Default_Handler,
  [7]  = Default_Handler, [8]  = Default_Handler, [9]  = Default_Handler,
  [10] = Default_Handler, [11] = Default_Handler,
  [SysTick_IRQn]  = SysTick_Handler,     // 12 - pulse-reset timer (STK)
  [13] = Default_Handler,
  [SW_IRQn]       = Default_Handler,    // 14 - software int, unused
  [15] = Default_Handler, [16] = Default_Handler,
  [GPIOA_IRQn]    = GPIOA_IRQHandler,   // 17 - limits + controls (shared, single port)
  [18] = Default_Handler,
  [SPI_IRQn]      = Default_Handler,    // 19
  [BLEB_IRQn]     = Default_Handler,    // 20
  [BLEL_IRQn]     = Default_Handler,    // 21
  [USB_IRQn]      = Default_Handler,    // 22
  [23] = Default_Handler,
  [TMR_IRQn]      = TMR_IRQHandler,     // 24 - stepper timer
  [25] = Default_Handler, [26] = Default_Handler,
  [UART_IRQn]     = UART_IRQHandler,    // 27 - serial RX/TX
  [RTC_IRQn]      = Default_Handler,    // 28
  [CMP_IRQn]      = Default_Handler,    // 29
  [I2C_IRQn]      = Default_Handler,    // 30
  [PWMX_IRQn]     = Default_Handler,    // 31 - unused (spindle PWM needs no IRQ)
  [32] = Default_Handler,
  [KEYSCAN_IRQn]  = Default_Handler,    // 33
  [ENCODER_IRQn]  = Default_Handler,    // 34
  [WDOG_BAT_IRQn] = Default_Handler,    // 35
};

// ============================================================================
// SYSTEM CLOCK BRING-UP
// ============================================================================
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

// ============================================================================
// RESET HANDLER (C portion - reached from _start with SP already valid)
//
// `used` (CONTRACTS.md gap log, LTO batch - same fix as ch32v006/startup.c,
// identical mechanism, see that file's comment for the full writeup):
// Reset_Handler's only caller is _start's raw `jal Reset_Handler` inline
// asm below, invisible to LTO's IPA. Without `used`, -flto's whole-program
// analysis for an executable link removes this externally-visible-but-
// uncalled-in-C function before codegen, and the link fails with
// "undefined reference to Reset_Handler". BUG #21's mechanism, one ISA
// over.
// ============================================================================

__attribute__((used))
void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Copy .data section from Flash to RAM.
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // BUG #13-class ordering (CONTRACTS.md §12.4): fence between init phases.
  __DSB();

  // Zero-initialize .bss section.
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  __DSB();

  // Defense-in-depth (see file header): explicitly zero INTSYSCR before
  // wiring mtvec/enabling anything - do NOT trust the documented reset
  // value alone on this chip.
  wch_intsyscr_clear();

  // mtvec -> PFIC vector table, vectored-by-number + absolute-address
  // entries (common/wch/wch_vectors.h). Interrupts are still globally
  // masked (mstatus.MIE=0 out of reset) until core's sei() at main.c.
  wch_mtvec_set_vectored(PFIC_Vector);

  SystemInit();

  main();

  // main() never returns in normal operation; if it does, hang rather
  // than run off into undefined memory.
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// _start - the real reset entry point
// ============================================================================
__attribute__((naked, section(".init")))
void _start(void) {
  __asm__ volatile (
    "la sp, _estack \n"
    "jal Reset_Handler \n"
  );
}
