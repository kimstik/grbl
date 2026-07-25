/*
  handlers.c - CH32V006 interrupt dispatch + integration glue
  Part of Grbl

  PORTING-CHECKLIST Step 6 - NOT wired this batch (Phase 4 M1-M3 stops
  after clock+GPIO). Identical shape to `_template/handlers.c`: dispatch
  wrappers exist and reference their PORT_TODO_* register-level
  primitives, but nothing in startup.c's vector table calls them yet
  (this chip's real PFIC IRQ numbers are UNVERIFIED - see ch32v006.h).
  The `__keep_alive` table keeps them linked in the meantime, same
  reasoning as the template (this Makefile also omits --gc-sections for
  the same reason - see its comment).
*/

#include <stdint.h>
#include "platform.h"
#include "timer.h"

// ============================================================================
// STEPPER TIMER ISR (CONTRACTS.md #3, #5)
// ============================================================================
extern void __isr_step_impl(void);

void stepper_timer_irq_dispatch(void) {
  PORT_TODO_STP_TMR_IRQ_CLEAR_FLAG();
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER ISR (CONTRACTS.md #4, #5)
// ============================================================================
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
// GPIO PIN-CHANGE / EXTERNAL INTERRUPT DISPATCH (CONTRACTS.md #2)
// ============================================================================
extern void LIMIT_INT_IRQHandler(void);
extern void CONTROL_INT_IRQHandler(void);

void gpio_irq_dispatch(void) {
  PORT_TODO_GPIO_IRQ_CLEAR_FLAGS();
  if (PORT_TODO_GPIO_IRQ_LIMIT_PENDING())   { LIMIT_INT_IRQHandler(); }
  if (PORT_TODO_GPIO_IRQ_CONTROL_PENDING()) { CONTROL_INT_IRQHandler(); }
}

// ============================================================================
// DELAY PRIMITIVES (PORTING-CHECKLIST Step 6)
// ============================================================================
// See CONTRACTS.md #13 "Closed: _delay_us/_delay_ms empty stubs" - an
// empty body compiles clean and breaks homing debounce/spindle ramp
// silently. PORT_TODO instead: a linker error, not a support ticket.
void _delay_us(double __us) {
  (void)__us;
  PORT_TODO_DELAY_US();
}

void _delay_ms(double __ms) {
  (void)__ms;
  PORT_TODO_DELAY_MS();
}

// ============================================================================
// KEEP-ALIVE TABLE - delete once real PFIC vector wiring exists
// ============================================================================
static void (* const __keep_alive[])(void) __attribute__((used)) = {
  stepper_timer_irq_dispatch,
  pulse_reset_timer_irq_dispatch,
  gpio_irq_dispatch,
};
