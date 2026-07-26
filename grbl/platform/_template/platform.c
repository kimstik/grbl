/*
  platform.c - _template stateful chip glue (copy-me starting point)
  Part of Grbl

  PORT-TODO: this whole file. Every landed port in this tree (samd21,
  ch32v006, ch570, hc32f460, dspic33ak128mc102, stm32f103/f411/h523) needed
  a platform.c to hold the STATEFUL chip glue that platform.h's macros
  cannot be - things that need a static/local variable, a calibration
  constant, or a one-time boot-sequence call, as opposed to platform.h's
  pure inline-asm macros (HAL_CRITICAL_SECTION_*, sei/cli - genuinely
  stateless PRIMASK sequences, correctly NOT here). This file is that home
  for this template. Two things intentionally still live elsewhere:
    - PORT_TODO_SYSTEM_CLOCK_INIT() stays a direct call inside startup.c's
      SystemInit() (not wrapped here) - it must run before this file's own
      globals (delay calibration, millisecond counters) are printed or
      timed, and keeping it in the one file that already owns boot
      sequencing avoids a false "which file runs first" question.
    - ISR *vector* dispatch wrappers (stepper_timer_irq_dispatch() etc.)
      stay in handlers.c, matching every landed port's own file boundary
      (that file's job is naming/clearing/forwarding to core; this file's
      job is chip bring-up state).
*/

#warning "PORT-TODO: platform.c"

#include <stdint.h>
#include "platform.h"

// ============================================================================
// GPIO INTERRUPT CONTROLLER ARM-UP (CONTRACTS.md §2)
// ============================================================================
/*
  CONTEXT: init, called once from Reset_Handler (startup.c) before main()/
  sei() - see the call site there. This is DIFFERENT from
  HAL_GPIO_INTERRUPT_ENABLE/DISABLE (platform.h's GPIO_INT_ON/OFF, called
  REPEATEDLY at runtime per CONTRACTS §2.1 to arm/disarm individual
  LIMIT/CONTROL channels). Most chips also need a one-time, boot-level
  "let this peripheral's IRQ line reach the core at all" step (NVIC/PFIC/
  INTC enable for the EIC/EXTI-class peripheral) - THAT one-time step is
  this function's job.

  KNOWN-GAP WARNING, do not repeat it here: CONTRACTS.md §13 records that
  SAMD21's own copy of this exact function
  (`hal_gpio_interrupt_init()`, samd21/platform.c:232) is defined
  correctly but is NEVER CALLED anywhere in that port's build - limit/
  control interrupts are silently never armed at runtime. This template
  wires the call for you (startup.c's Reset_Handler) specifically so a new
  port copied from here starts from a called, PORT_TODO-enumerated hook
  instead of an orphaned one. Do not delete the call site without
  replacing it with equivalent wiring elsewhere.
*/
void hal_gpio_interrupt_init(void) {
  PORT_TODO_GPIO_IRQ_GLOBAL_ENABLE();
}

// ============================================================================
// DELAY PRIMITIVES (PORTING-CHECKLIST Step 6; CONTRACTS.md §13)
// ============================================================================
/*
  Declared by common/dummy/util/delay.h (AVR <util/delay.h> compatibility -
  core calls delay_ms()/delay_us() in nuts_bolts.c, which call these with
  small integral arguments). "Closed: _delay_us/_delay_ms empty stubs" in
  CONTRACTS.md §13 records why an empty body here is NOT an option even
  though it compiles clean: it silently breaks homing debounce and spindle
  ramp on real hardware, with no warning at build or link time. A
  PORT_TODO call is the correct stand-in - it costs you a linker error
  instead of a support ticket.

  DELAY CALIBRATION, the piece every landed port had to author for real
  (not a PORT_TODO stand-in - the reference implementation, not fabricated
  here since it is core/pipeline specific): a counted inline-asm busy-wait
  loop, calibrated in cycles-per-iteration for YOUR core, converted to
  iterations-per-microsecond via CPU_FREQ. samd21/platform.c:132-176 is the
  fully worked Cortex-M0+ reference (3 cycles/iteration: `subs`+`bne`);
  Cortex-M3/M4 cores pipeline differently (branch cost varies with flash
  wait states and branch prediction where present) - re-derive the cycle
  count for your core, do not copy the M0+ constant. Once you have a real
  millisecond timebase (SysTick, a free-running timer) wired, prefer
  polling it over the busy loop for _delay_ms() - the busy loop cannot
  yield to interrupts, so any ISR that fires during it (limit/serial)
  stretches the requested delay by the ISR's own runtime.

  FP #17 note: keep the AVR-compatible `double` signature at the public
  entry point (core compatibility), narrow to `float` exactly ONCE at
  entry, and do all arithmetic behind that point in float/uint32 - a
  second, hidden double narrowing further down (e.g. a sub-millisecond
  remainder computed as `__ms - (double)ms`) still links in the full
  double-precision soft-float library under FP=SINGLE even though the
  entry point "looked" narrowed. This bit both samd21 and ch32v006 for
  real (CONTRACTS.md / PLAN.md's assert_no_double.sh finding) - verify with
  `tools/assert_no_double.sh` after wiring FP=SINGLE (see the Makefile's FP
  knob), don't assume the entry-point narrowing was sufficient.
*/
void _delay_us(double __us) {
  (void)__us;
  PORT_TODO_DELAY_US();
}

void _delay_ms(double __ms) {
  (void)__ms;
  PORT_TODO_DELAY_MS();
}
