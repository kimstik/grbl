/*
  platform.c - SAMD21 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "platform.h"
#include "../hal.h"
#include "config.h"

// CRITICAL SECTIONS

// ISSUE #10 (MINOR): Unused global variable - never referenced anywhere
// TODO: Remove or use properly
uint32_t _hal_critical_state = 0;

uint32_t hal_critical_enter(void) {
  uint32_t primask;
  __asm volatile ("MRS %0, primask" : "=r" (primask));
  __asm volatile ("cpsid i" : : : "memory");
  return primask;
}

void hal_critical_exit(uint32_t state) {
  __asm volatile ("MSR primask, %0" : : "r" (state) : "memory");
}

// SYSTEM TIMING

static volatile uint32_t system_milliseconds = 0;
static volatile uint64_t system_microseconds = 0;

// SysTick Handler (called every 1ms)
void SysTick_Handler(void) {
  system_milliseconds++;
  system_microseconds += 1000;
}

uint32_t hal_millis(void) {
  return system_milliseconds;
}

uint64_t hal_micros(void) {
  // Simple approximation - actual implementation would use TC counter
  return system_microseconds;
}

// CLOCK CONFIGURATION - see startup.c::SystemInit()
//
// BUG #23: a second hal_clock_config() used to live here - a near-copy of
// startup.c's SystemInit() DFLL48M sequence that NOTHING CALLED. It was
// unreachable, LTO stripped it from every RELEASE image (verified by nm),
// and its only real effect was to look like the port's clock bring-up
// while being free to drift out of sync with the copy that actually runs.
// Deleted. The one and only clock bring-up on this port is
// startup.c::SystemInit(), called from Reset_Handler before main() and
// enforced post-link by common/init_check.sh via INIT_SYMBOLS.

// TIMER FUNCTIONS - Now implemented as macros in timer.h
// Timer initialization, control, and ISR definitions moved to timer.h
// All timer operations use platform-agnostic macros:
//   STP_TMR_*          - Stepper timer (TC3)
//   STP_PULSE_RESET_*  - Pulse reset timer (TC4)
//   PWM_*              - Spindle PWM (TCC0)
//   ISR_STEP, ISR_STEP_RESET, ISR_STEP_DELAY - Interrupt handlers

// WATCHDOG FUNCTIONS

void hal_watchdog_init(uint32_t timeout_ms) {
  // Initialize watchdog timer
  (void)timeout_ms;  // Not implemented yet
}

void hal_watchdog_feed(void) {
  // Reset watchdog timer
}

// DELAY FUNCTIONS (AVR <util/delay.h> compatibility)
//
// GRBL core calls these with small integral arguments only:
//   nuts_bolts.c delay_ms()  -> _delay_ms(1) in a loop (homing debounce,
//                               stepper idle lock, report flush)
//   nuts_bolts.c delay_us()  -> _delay_us(1 / 10 / 100), _delay_ms(1)
//   nuts_bolts.c delay_sec() -> _delay_ms(DWELL_TIME_STEP == 50)
// Signatures keep AVR's double parameter for core compatibility (on avr-gcc
// that `double` IS a float - see CONTRACTS #17). Each entry point performs
// exactly ONE double->float narrowing up front (__aeabi_d2f, a pure format
// conversion) and then stays in float/uint32 forever; no double-precision
// ARITHMETIC exists behind the boundary, which is what
// tools/assert_no_double.sh enforces post-link under FP=SINGLE.

// --- Calibrated busy-wait core ----------------------------------------------
//
// Implementation choice: counted inline-asm loop, NOT SysTick->VAL sampling.
// Rationale: Cortex-M0+ has no DWT cycle counter, so cycles must be counted
// some other way. A SysTick->VAL based wait only works after SysTick has been
// configured and needs 24-bit wrap handling; the counted loop is correct from
// reset onward, touches no peripheral state, and — because it is inline asm —
// times identically at -O0 (DEBUG) and -Os (RELEASE).
//
// Cycle math (ARMv6-M Cortex-M0+, 2-stage pipeline):
//   subs Rd,#1      1 cycle
//   bne  (taken)    2 cycles (pipeline reload)
//   => 3 cycles per iteration => 48e6 / 3e6 = 16 iterations per microsecond.
//
// Accuracy bounds:
//  * The 4-byte loop body fits one NVM cache line, so the 1 flash wait state
//    set in SystemInit() only penalizes the first iteration.
//  * Call/return plus the one soft-double conversion add roughly 1 us of
//    fixed overhead at 48 MHz; delays only ever run LONG, never short.
//  * Any interrupt served during the wait extends the delay by the ISR's
//    runtime — identical to AVR _delay_us() reality with interrupts enabled.
//  * us * 16 iterations overflows uint32 above ~268 s; core passes <= 100 us.

#define DELAY_LOOP_CYCLES        3u  // subs (1) + bne taken (2)
#define DELAY_LOOP_ITERS_PER_US  (CPU_FREQ / (DELAY_LOOP_CYCLES * 1000000uL)) // 16 @ 48 MHz

static void delay_busy_loop(uint32_t iterations) {
  if (iterations == 0) { return; }
  // ".syntax unified": GCC wraps Thumb inline asm in ".syntax divided" by
  // default; the closing ".syntax unified" is emitted by GCC after the block.
  __asm volatile (
    ".syntax unified     \n"
    "1: subs %0, %0, #1  \n"   // 1 cycle
    "   bne  1b          \n"   // 2 cycles while taken
    : "+l" (iterations)
    :
    : "cc"
  );
}

// Float-typed worker: everything past the ABI boundary is single precision.
static void delay_us_f(float us) {
  uint32_t n = (uint32_t)us;     // truncates, SP->int
  if (n) { delay_busy_loop(n * DELAY_LOOP_ITERS_PER_US); }
}

void _delay_us(double __us) {
  delay_us_f((float)__us);       // the ONE narrowing (__aeabi_d2f)
}

void _delay_ms(double __ms) {
  float    ms_f = (float)__ms;   // the ONE narrowing (__aeabi_d2f)
  uint32_t ms   = (uint32_t)ms_f;

  if (ms) {
    // Preferred path: poll the SysTick-driven millisecond counter. Robust and
    // interrupt-friendly — wall time keeps advancing while ISRs run, so IRQ
    // load does not stretch the delay the way it stretches the busy loop.
    // Quantization: the first tick may be partial (up to -1 ms on a single
    // call), but chained calls (core's delay_ms() loops _delay_ms(1)) re-sync
    // to the tick edge and accumulate to within 1 ms overall.
    //
    // The poll can only progress when SysTick_Handler is able to fire. It is
    // NOT able to fire while SysTick is unconfigured, while PRIMASK masks
    // interrupts, or in handler mode at >= SysTick priority (st_go_idle() ->
    // delay_ms() runs inside the stepper ISR when the segment buffer drains).
    // Fall back to the calibrated busy-wait there instead of dead-locking.
    uint32_t ipsr, primask;
    __asm volatile ("MRS %0, ipsr"    : "=r" (ipsr));
    __asm volatile ("MRS %0, primask" : "=r" (primask));
    uint32_t systick_ticking = (SysTick->CTRL &
        (SysTick_CTRL_ENABLE_Msk | SysTick_CTRL_TICKINT_Msk)) ==
        (SysTick_CTRL_ENABLE_Msk | SysTick_CTRL_TICKINT_Msk);

    if (systick_ticking && ipsr == 0 && primask == 0) {
      uint32_t start = hal_millis();
      while ((uint32_t)(hal_millis() - start) < ms) { /* spin */ }
    } else {
      for (uint32_t i = ms; i != 0; i--) {
        delay_busy_loop(1000u * DELAY_LOOP_ITERS_PER_US);
      }
    }
  }

  // Sub-1ms remainder (e.g. _delay_ms(0.5)): delegate to the busy-wait. All
  // current core callers pass integral values, so this normally costs one
  // single-precision compare outside any wait loop and calls nothing.
  // Kept in float deliberately: doing this subtract/compare/multiply in
  // double relinks __aeabi_dsub/dcmpgt/dmul and the DP support they pull
  // with them - measured +3940 bytes of RELEASE text (35892 vs 31952) for
  // arithmetic the origin AVR performed in 32 bits. This is the leak
  // tools/assert_no_double.sh caught after the compile flags alone looked
  // "done": narrowing at entry is necessary, not sufficient.
  float rem = ms_f - (float)ms;
  if (rem > 0.0f) { delay_us_f(rem * 1000.0f); }
}
// GPIO INTERRUPT INITIALIZATION

void hal_gpio_interrupt_init(void) {
  // Initialize EIC
  EIC_INIT();

  // Configure LIMIT pins (PA4, PA5, PA7)
  EIC_PIN_CONFIG(PORT_GROUPA, 4);   // X_LIMIT
  EIC_PIN_CONFIG(PORT_GROUPA, 5);   // Y_LIMIT
  EIC_PIN_CONFIG(PORT_GROUPA, 7);   // Z_LIMIT
  EIC_CONFIG_CHANNEL(4, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(5, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(7, EIC_CONFIG_SENSE_BOTH);
  EIC_INT_ENABLE(4);
  EIC_INT_ENABLE(5);
  EIC_INT_ENABLE(7);

  // Configure CONTROL pins (PA14, PA15, PA16)
  EIC_PIN_CONFIG(PORT_GROUPA, 14);  // RESET
  EIC_PIN_CONFIG(PORT_GROUPA, 15);  // FEED_HOLD
  EIC_PIN_CONFIG(PORT_GROUPA, 16);  // CYCLE_START
  EIC_CONFIG_CHANNEL(14, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(15, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(0, EIC_CONFIG_SENSE_BOTH);  // PA16 -> EXTINT[0]
  EIC_INT_ENABLE(14);
  EIC_INT_ENABLE(15);
  EIC_INT_ENABLE(0);

  // NOTE: PROBE pin (PA19) is POLLED, not interrupt-driven (see probe.c)
  // Pin direction and pullup configured by probe_init() in probe.c
  // No EIC configuration needed here

  // Enable EIC interrupt in NVIC
  NVIC_EnableIRQ(EIC_IRQn);
}

// INTERRUPT CONTROL

void hal_system_enable_interrupts(void) {
  __enable_irq();
}

void hal_system_disable_interrupts(void) {
  __disable_irq();
}

