/*
  startup.c - _template reset/vector code (copy-me starting point)
  Part of Grbl

  PORTING-CHECKLIST.md Step 0/Step 1: vector table, .data copy, .bss zero,
  system clock bring-up. The data/bss copy loop below is genuinely
  chip-agnostic (every Cortex-M works the same way) and ships real,
  working code. The vector table only has room filled in for the handful
  of exception slots every Cortex-M core defines identically (Reset, NMI,
  HardFault, SVC, PendSV, SysTick) - your chip's peripheral IRQs (the
  stepper timer, pulse-reset timer, PWM timer, UART, GPIO/EXTI, ...) go in
  the PORT-TODO gap below vector_table[15], in whatever order your
  datasheet's vector table assigns them, aliased to the *_irq_dispatch()
  functions in handlers.c.

  ARM-ONLY WARNING (added after the ch32v006/RISC-V port, Phase 4 M1-M3 -
  CONTRACTS.md #14): everything in this file assumes ARM Cortex-M
  hardware vector fetch - `vector_table[0]` = initial SP and
  `vector_table[1]` = Reset_Handler, loaded into the core automatically
  on reset, no software involved. RISC-V (including this repo's
  ch32v006) has NO equivalent mechanism at all: there is no hardware SP
  autoload, and a data-pointer array is not a valid `mtvec` target in
  standard direct mode. If you are porting to a non-ARM core, do NOT
  start from this file - read `ch32v006/startup.c` instead for a worked
  RISC-V alternative (naked `_start` that sets `sp` itself, an
  `__attribute__((interrupt))` C trap entry, `mtvec` written via `csrw`)
  and CONTRACTS.md #14 for the full list of what else does not transfer.
*/

#include <stdint.h>
#include "platform.h"

#warning "PORT-TODO: startup.c"

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

void Reset_Handler(void);
void Default_Handler(void);

// Core ARMv6-M/v7-M/v8-M exception handlers - identical on every Cortex-M.
void NMI_Handler(void)       __attribute__((weak, alias("Default_Handler")));
void HardFault_Handler(void) __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)       __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)    __attribute__((weak, alias("Default_Handler")));
void SysTick_Handler(void)   __attribute__((weak, alias("Default_Handler")));

// ============================================================================
// VECTOR TABLE
// ============================================================================
// PORT-TODO: everything after SysTick_Handler. Your chip's reference manual
// lists the peripheral IRQ order - it is NOT portable between chips, unlike
// the 6 slots above. Wire in, at minimum: the stepper timer IRQ ->
// stepper_timer_irq_dispatch(), the pulse-reset timer IRQ ->
// pulse_reset_timer_irq_dispatch(), the GPIO/EXTI IRQ(s) that cover
// LIMIT+CONTROL -> gpio_irq_dispatch(), and the UART IRQ -> serial.c's
// dispatcher (see serial.c). All four are defined in handlers.c/serial.c
// and already reference their PORT_TODO_* register-level primitives.
__attribute__((section(".isr_vector")))
void (* const vector_table[])(void) = {
  (void (*)(void))&_estack,   // 0  Initial Stack Pointer
  Reset_Handler,              // 1  Reset Handler
  NMI_Handler,                // 2  NMI Handler
  HardFault_Handler,          // 3  Hard Fault Handler
  0, 0, 0, 0, 0, 0, 0,        // 4-10 Reserved / core-variant-specific
                              //      (MemManage/BusFault/UsageFault on M3+)
  SVC_Handler,                // 11 SVCall Handler
  0, 0,                       // 12-13 Reserved (DebugMon on M3+)
  PendSV_Handler,             // 14 PendSV Handler
  SysTick_Handler,            // 15 SysTick Handler

  // PORT-TODO: peripheral IRQ vectors start here (position 16 = IRQn 0).
};

// ============================================================================
// SYSTEM CLOCK BRING-UP (PORTING-CHECKLIST Step 1)
// ============================================================================
/*
  Must bring the system clock up to exactly F_CPU (Makefile CLOCK variable)
  and set flash wait states appropriately BEFORE raising the clock past
  whatever your flash controller's zero-wait-state ceiling is. A lie here
  breaks every later timing step invisibly (stepper rates, baud rate, pulse
  width, delay loops all derive from F_CPU) - verify against a scope or
  emulator cycle count, not by assumption.
*/
void SystemInit(void) {
  PORT_TODO_SYSTEM_CLOCK_INIT();
}

// ============================================================================
// RESET HANDLER
// ============================================================================

void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Copy .data section from Flash to RAM.
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // BUG #13 class: DSB between the .data copy and .bss zero, and again
  // before SystemInit - plain stores are not guaranteed complete before the
  // next phase begins on a weakly-ordered core (CONTRACTS.md §12.4).
  __DSB();

  // Zero-initialize .bss section.
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  __DSB();

  // PORT-TODO: point VTOR at vector_table if your chip boots through a
  // bootloader whose vector table is not this image's (samd21/startup.c:196-201
  // is the reference - `SCB->VTOR = (uint32_t)vector_table;`). Requires a
  // real SCB register definition, which this chip-agnostic template does
  // not have. Do this BEFORE SystemInit() so any fault during clock
  // bring-up vectors into this image.

  SystemInit();

  // One-time GPIO-IRQ controller arm-up (NVIC/PFIC/INTC enable for the
  // EIC/EXTI-class peripheral) - platform.c's hal_gpio_interrupt_init().
  // Wired here so it is never the orphaned, never-called function
  // CONTRACTS.md §13 flags on the SAMD21 reference port - see that
  // function's docstring for the full contract.
  hal_gpio_interrupt_init();

  // PORT-TODO: start whatever 1 kHz-class timebase your _delay_ms()
  // implementation (platform.c) needs, if any (samd21/startup.c:207-219 is
  // the reference: SysTick_Config() + a priority demotion so it never
  // preempts motion/serial on simultaneous arrival).

  main();

  // main() never returns in normal operation; if it does, hang rather than
  // run off into undefined memory.
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// DEFAULT HANDLER
// ============================================================================

void Default_Handler(void) {
  while (1) {
    __asm__ volatile ("nop");
  }
}
