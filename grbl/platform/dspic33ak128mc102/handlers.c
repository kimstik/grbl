/*
  handlers.c - dsPIC33AK128MC102 interrupt vectors + integration glue
  Part of Grbl

  Unlike the ARM/RISC-V siblings there is NO vector_table[] array here:
  the XC-DSC linker synthesizes the IVT from canonical ISR symbol names
  (see platform.c's startup-model banner). Each vector below is the real
  dsPIC ISR (placed in a KEEP'd .isr* section by the toolchain - no
  __keep_alive table needed, gc cannot drop them) wired to the candidate
  peripheral allocation from boards/generic/config.h; the IFSx
  flag-clear primitives are PORT_TODO_* until Step 3/6 verify the exact
  IFSx bit positions against the RM.

  Flag-clear-first contract (#2.3/#5.1) is already structural below:
  the PORT_TODO_*_CLEAR_FLAG call precedes the core body call in every
  vector. On dsPIC the IFSx bit does NOT auto-clear on vector entry
  (unlike AVR) - forgetting it re-enters forever, the loud kind of bug.

  ISR frame note: __attribute__((interrupt)) makes xc-dsc emit full
  save/restore + RETFIE. Priorities (IPCx) and nesting: dsPIC33A nests by
  priority natively (INTCON1.NSTDIS=0 at reset), so core's sei() inside
  ISR_STEP (stepper.c:355) can genuinely let the pulse-reset IRQ preempt
  if Step 3 assigns it a HIGHER IPC priority than the stepper IRQ - this
  chip can honor the AVR semantic properly, unlike the M0+ reference
  (#5.2). Step 3 must set IPCx explicitly.
*/

#include <xc.h>
#include <stdint.h>
#include "platform.h"
#include "timer.h"

// ============================================================================
// STEPPER TIMER ISR - Timer1 (_T1Interrupt), CONTRACTS.md #3/#5
// ============================================================================
extern void __isr_step_impl(void);

void __attribute__((interrupt, no_auto_psv)) _T1Interrupt(void)
{
  PORT_TODO_STP_TMR_IRQ_CLEAR_FLAG();   // IFSx.T1IF = 0 (Step 3: verify position)
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER ISR - SCCP1 timer (_CCT1Interrupt), CONTRACTS.md #4/#5
// ============================================================================
extern void __isr_step_reset_impl(void);

void __attribute__((interrupt, no_auto_psv)) _CCT1Interrupt(void)
{
  PORT_TODO_STP_PULSE_RESET_IRQ_CLEAR_FLAG();
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
extern void __isr_step_delay_impl(void);
// Step 3 decision: SCCP1's second compare or another SCCP - #error in
// timer.h keeps this honest until then. No vector is claimed yet.
#endif

// ============================================================================
// GPIO CHANGE-NOTIFICATION ISRs (CONTRACTS.md #2) - per-port vectors:
// LIMIT group on port D, CONTROL group on port A (boards/generic/config.h).
// No shared-vector dispatch needed (#2.5) - each group owns its vector.
// ============================================================================
extern void LIMIT_INT_IRQHandler(void);     // core body, limits.c:107 via HAL_GPIO_IRQ_HANDLER
extern void CONTROL_INT_IRQHandler(void);   // core body, system.c:64

void __attribute__((interrupt, no_auto_psv)) _CNDInterrupt(void)
{
  PORT_TODO_GPIO_IRQ_LIMIT_CLEAR_FLAGS();   // CNSTATD/CNFD + IFSx CNDIF (Step 6)
  LIMIT_INT_IRQHandler();
}

void __attribute__((interrupt, no_auto_psv)) _CNAInterrupt(void)
{
  PORT_TODO_GPIO_IRQ_CONTROL_CLEAR_FLAGS(); // CNSTATA/CNFA + IFSx CNAIF (Step 6)
  CONTROL_INT_IRQHandler();
}

// ============================================================================
// UART1 ISRs (Step 4) - route both to serial.c's dispatch; Step 4 may
// split RX/TX for latency once the U1 flag model is RM-verified.
// ============================================================================
extern void serial_irq_dispatch(void);

void __attribute__((interrupt, no_auto_psv)) _U1RXInterrupt(void)
{
  PORT_TODO_SERIAL_RX_IRQ_CLEAR_FLAG();
  serial_irq_dispatch();
}

void __attribute__((interrupt, no_auto_psv)) _U1TXInterrupt(void)
{
  PORT_TODO_SERIAL_TX_IRQ_CLEAR_FLAG();
  serial_irq_dispatch();
}

// ============================================================================
// DELAY PRIMITIVES (PORTING-CHECKLIST Step 6)
// ============================================================================
// Declared by common/dummy/util/delay.h. An empty body here compiles
// clean and silently breaks homing debounce / spindle ramp (CONTRACTS.md
// #13 "Closed" note) - PORT_TODO is the correct stand-in.
void _delay_us(double __us) {
  (void)__us;
  PORT_TODO_DELAY_US();
}

void _delay_ms(double __ms) {
  (void)__ms;
  PORT_TODO_DELAY_MS();
}
