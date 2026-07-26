/*
  startup.c - Startup code for HC32F460
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include <stdint.h>
#include "platform.h"

/* Linker symbols */
extern uint32_t _estack;
extern uint32_t _sidata, _sdata, _edata;
extern uint32_t _sbss, _ebss;

extern int main(void);

/* Interrupt vector table (defined at the bottom of this file). Forward-
   declared here so Reset_Handler can take its address - the real code
   reference that survives -flto's whole-program IPA (CONTRACTS.md section
   18 / BUG #21: KEEP(*(.isr_vector)) alone does NOT survive LTO, since IPA
   deletes an unreferenced vector_table[] before codegen ever emits the
   input section for KEEP to match). `used` on the definition below is the
   second, independent defense-in-depth mechanism. */
extern const void *vector_table[];

static void handle_fault(uint32_t fault_code) {
  __disable_irq();

  /* Stepper enable pin (PA6) high = disabled */
  GPIOA->POSR = (1UL << STEPPERS_DISABLE_PIN);
  /* Spindle PWM pin (PA8) driven low via plain GPIO would require undoing
     the TIMERA function-select first; simplest safe action here is to
     leave the timer running with 0 duty (already the reset state unless
     a fault occurs mid-job) and only guarantee steppers are disabled. */

  while (1) {
    for (uint32_t i = 0; i < fault_code; i++) {
      GPIOA->PORR = (1UL << COOLANT_FLOOD_PIN);
      for (volatile uint32_t d = 0; d < 200000; d++);
      GPIOA->POSR = (1UL << COOLANT_FLOOD_PIN);
      for (volatile uint32_t d = 0; d < 200000; d++);
    }
    for (volatile uint32_t d = 0; d < 2000000; d++);   /* long pause */
  }
}

void Default_Handler(void) {
  handle_fault(9);   /* fault code 9 = unhandled interrupt */
}

/* Reset handler - copies data, clears BSS, calls main */
void Reset_Handler(void) {
  uint32_t *src, *dst;

  /* Point VTOR at this image's vector table (CONTRACTS.md section 18):
       1. Real code reference that survives LTO and forces the table into
          .isr_vector (BUG #21).
       2. Bootloader-offset-robust: if entered with VTOR still pointing at
          a bootloader's table, retarget it. */
  SCB->VTOR = (uint32_t)vector_table;

  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }
  __DSB();   /* BUG#13-class: copy loop's stores land before .bss zeroing (CONTRACTS.md section 12.4) */

  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }
  __DSB();

  /* BUG #23: bring the chip up BEFORE main().
   *
   * hal_system_init() -> hal_clock_config() (XTAL -> MPLL 200MHz, EFM
   * flash wait states raised before the switch) + hal_gpio_init() (PORT
   * unlock, PCR direction/pull, function mux) was written, reviewed and
   * documented - and called from NOWHERE. main.c is the golden gate and
   * does not call platform init, so under -flto the entire chain was
   * unreachable and GCC's IPA deleted it: the RELEASE image defined none
   * of the three symbols and the chip ran on the MRC reset default with
   * unconfigured GPIO. Same class as BUG #21 (LTO deleted the vector
   * table because nothing referenced it), one level up.
   *
   * Placed HERE, in the platform's own Reset_Handler, matching samd21's
   * SystemInit()/SysTick_Config() precedent - the established way this
   * tree runs pre-main platform code without touching core.
   *
   * Ordering is load-bearing and must not be reshuffled:
   *   .data/.bss first  - hal_gpio_init and the NVMEM cache write
   *                       initialized statics.
   *   clock (+ its own flash wait states) before anything timing-
   *                       dependent - hal_clock_config programs EFM
   *                       wait states BEFORE switching the system clock
   *                       source; hc32_systick_init() then derives the
   *                       tick from the final frequency.
   *   GPIO after clock  - the PORT/PWC gating it writes is meaningless
   *                       until the bus clocks are settled.
   *   main() last       - core's serial_init()/settings_init() need the
   *                       final clock and the NVMEM cache already up.
   * VTOR is already set above, so an IRQ raised during bring-up vectors
   * into this image. */
  hal_system_init();

  main();

  while (1);
}

void HardFault_Handler(void)  { handle_fault(1); }
void MemManage_Handler(void)  { handle_fault(2); }
void BusFault_Handler(void)   { handle_fault(3); }
void UsageFault_Handler(void) { handle_fault(4); }

void NMI_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void DebugMon_Handler(void)         __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)           __attribute__((weak, alias("Default_Handler")));

extern void SysTick_Handler(void);   /* platform.c */

/* GRBL interrupt handlers (handlers.c) */
extern void Int000_IRQHandler(void);   /* Stepper ISR */
extern void Int001_IRQHandler(void);   /* Pulse reset ISR */
extern void Int002_IRQHandler(void);   /* USART1 RX */
extern void Int003_IRQHandler(void);   /* USART1 TX */
extern void Int004_IRQHandler(void);   /* X limit */
extern void Int005_IRQHandler(void);   /* Y limit */
extern void Int006_IRQHandler(void);   /* Z limit */
extern void Int007_IRQHandler(void);   /* Reset */
extern void Int008_IRQHandler(void);   /* Feed hold */
extern void Int009_IRQHandler(void);   /* Cycle start */
extern void Int010_IRQHandler(void);   /* Safety door */

#ifdef STEP_PULSE_DELAY
  extern void Int011_IRQHandler(void);
#else
  void Int011_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
#endif

void Int012_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int013_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int014_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int015_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int016_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int017_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int018_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int019_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int020_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int021_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int022_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int023_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int024_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int025_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int026_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int027_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int028_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int029_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int030_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void Int031_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));

/* Interrupt vector table: 16 Cortex-M4 core exceptions + 32 shared
   Int000-031 peripheral vectors (regs.h HC32_NUM_SHARED_IRQ). `used` is
   belt to the VTOR write's braces (BUG #21, CONTRACTS.md section 18). */
__attribute__((section(".isr_vector"), used))
const void *vector_table[] = {
  &_estack,                    /* 0:  Initial stack pointer */
  Reset_Handler,                /* 1:  Reset handler */
  NMI_Handler,                  /* 2:  NMI handler */
  HardFault_Handler,            /* 3:  Hard fault handler */
  MemManage_Handler,            /* 4:  MPU fault handler */
  BusFault_Handler,              /* 5:  Bus fault handler */
  UsageFault_Handler,           /* 6:  Usage fault handler */
  0,                             /* 7:  Reserved */
  0,                             /* 8:  Reserved */
  0,                             /* 9:  Reserved */
  0,                             /* 10: Reserved */
  SVC_Handler,                   /* 11: SVCall handler */
  DebugMon_Handler,              /* 12: Debug monitor handler */
  0,                             /* 13: Reserved */
  PendSV_Handler,                /* 14: PendSV handler */
  SysTick_Handler,               /* 15: SysTick handler */

  /* Int000-031: this chip's shared peripheral vector pool (index 16 = Int000) */
  Int000_IRQHandler,              /* 16: Int000 - STEPPER ISR */
  Int001_IRQHandler,              /* 17: Int001 - PULSE RESET ISR */
  Int002_IRQHandler,              /* 18: Int002 - USART1 RX */
  Int003_IRQHandler,              /* 19: Int003 - USART1 TX */
  Int004_IRQHandler,              /* 20: Int004 - X limit */
  Int005_IRQHandler,              /* 21: Int005 - Y limit */
  Int006_IRQHandler,              /* 22: Int006 - Z limit */
  Int007_IRQHandler,              /* 23: Int007 - Reset */
  Int008_IRQHandler,              /* 24: Int008 - Feed hold */
  Int009_IRQHandler,              /* 25: Int009 - Cycle start */
  Int010_IRQHandler,              /* 26: Int010 - Safety door */
  Int011_IRQHandler,              /* 27: Int011 - step pulse delay (STEP_PULSE_DELAY only) */
  Int012_IRQHandler,              /* 28 */
  Int013_IRQHandler,              /* 29 */
  Int014_IRQHandler,              /* 30 */
  Int015_IRQHandler,              /* 31 */
  Int016_IRQHandler,              /* 32 */
  Int017_IRQHandler,              /* 33 */
  Int018_IRQHandler,              /* 34 */
  Int019_IRQHandler,              /* 35 */
  Int020_IRQHandler,              /* 36 */
  Int021_IRQHandler,              /* 37 */
  Int022_IRQHandler,              /* 38 */
  Int023_IRQHandler,              /* 39 */
  Int024_IRQHandler,              /* 40 */
  Int025_IRQHandler,              /* 41 */
  Int026_IRQHandler,              /* 42 */
  Int027_IRQHandler,              /* 43 */
  Int028_IRQHandler,              /* 44 */
  Int029_IRQHandler,              /* 45 */
  Int030_IRQHandler,              /* 46 */
  Int031_IRQHandler,              /* 47 */
};
