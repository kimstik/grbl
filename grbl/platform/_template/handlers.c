/*
  handlers.c - _template interrupt dispatch + integration glue (copy-me starting point)
  Part of Grbl

  Houses the ISR *vector* dispatch wrappers PORTING-CHECKLIST.md Step 6
  groups together (CONTRACTS.md §2 gpio, §5 timer): naming/clearing/
  forwarding glue between a real vector slot and core's ISR_STEP()-class
  bodies. Stateful chip bring-up (delay calibration, GPIO-IRQ controller
  arm-up) lives in platform.c instead - see its header comment for why the
  split matches every landed port's own file boundary.

  Every dispatcher below is deliberately named *_irq_dispatch rather than a
  real vector name (TC3_Handler, EIC_Handler, ...) - this template does not
  know your chip's vector table layout. Wire each one into startup.c's
  vector_table[] under its real IRQ slot once you know it; until then they
  are kept reachable only by the __keep_alive table at the bottom of this
  file (see its comment - delete that table once real wiring exists).
*/

#warning "PORT-TODO: handlers.c"

#include <stdint.h>
#include "platform.h"
#include "timer.h"

// ============================================================================
// STEPPER TIMER ISR (CONTRACTS.md §3, §5)
// ============================================================================
// Core's ISR_STEP() macro (timer.h) named this function; it is defined in
// stepper.c. Clear the peripheral's compare-match flag FIRST, then call the
// body (§2.3/§5.1) - clearing after can ghost or drop an edge that arrives
// during the body.
extern void __isr_step_impl(void);

void stepper_timer_irq_dispatch(void) {
  PORT_TODO_STP_TMR_IRQ_CLEAR_FLAG();
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER ISR (CONTRACTS.md §4, §5)
// ============================================================================
// ISR_STEP_RESET() stops the timer inside its body (stepper.c:503) -
// clearing the overflow flag after that write can ghost the final overflow,
// so PORT_TODO_STP_PULSE_RESET_IRQ_CLEAR_FLAG() must run before the call,
// same as above.
extern void __isr_step_reset_impl(void);

void pulse_reset_timer_irq_dispatch(void) {
  PORT_TODO_STP_PULSE_RESET_IRQ_CLEAR_FLAG();
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
extern void __isr_step_delay_impl(void);

void pulse_delay_timer_irq_dispatch(void) {
  PORT_TODO_STP_PULSE_DELAY_IRQ_CLEAR_FLAG();
  __isr_step_delay_impl();
}
#endif

// ============================================================================
// GPIO PIN-CHANGE / EXTERNAL INTERRUPT DISPATCH (CONTRACTS.md §2)
// ============================================================================
// limits.c/system.c define these via HAL_GPIO_IRQ_HANDLER(LIMIT_INT) /
// HAL_GPIO_IRQ_HANDLER(CONTROL_INT) (hal_gpio.h owns that expansion:
// `void <name>_IRQHandler(void)`).
extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

/*
  If your chip shares one vector for every pin-change source (EIC/EXTI
  class), dispatch to BOTH core handlers when both groups are pending
  (§2.5) - do not early-return after the first match. PORT_TODO_*_PENDING()
  below stand in for "read this source's pending bit"; if your chip gives
  each group its own vector instead, split this function into two and wire
  each half to its own real vector - the two PORT_TODO_*_PENDING() calls
  disappear, but you must still clear-flags-first in each one individually.
*/
void gpio_irq_dispatch(void) {
  PORT_TODO_GPIO_IRQ_CLEAR_FLAGS();
  if (PORT_TODO_GPIO_IRQ_LIMIT_PENDING())   { LIMIT_INT_IRQHandler(); }
  if (PORT_TODO_GPIO_IRQ_CONTROL_PENDING()) { CONTROL_INT_IRQHandler(); }
}

// ============================================================================
// KEEP-ALIVE TABLE - delete once real vector wiring exists
// ============================================================================
// Nothing in startup.c's placeholder vector table calls the dispatchers
// above yet (this chip's IRQ layout is unknown). This template's Makefile
// omits --gc-sections specifically so that omission does not also delete
// the PORT_TODO_* references inside them before the linker can report them
// - but the table below is cheap insurance if you ever copy these
// functions into a build that DOES use --gc-sections before wiring is
// done. Once startup.c's vector_table[] references these functions by
// name for real, delete this table; it exists only to keep them linked in
// the meantime.
static void (* const __keep_alive[])(void) __attribute__((used)) = {
  stepper_timer_irq_dispatch,
  pulse_reset_timer_irq_dispatch,
  gpio_irq_dispatch,
};
