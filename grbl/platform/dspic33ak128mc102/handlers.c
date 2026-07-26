/*
  handlers.c - dsPIC33AK128MC102 interrupt vectors + integration glue
  Part of Grbl

  Unlike the ARM/RISC-V siblings there is NO vector_table[] array here:
  the XC-DSC linker synthesizes the IVT from canonical ISR symbol names
  (see platform.c's startup-model banner). Each vector below is a real
  dsPIC ISR (DFP vector table doc, xc16/docs/vector_docs/PIC33AK128MC102.html,
  cross-checked against the header's commented-out "void _ISR _T1Interrupt(void);"
  style declarations) wired to the peripheral allocation from timer.h/platform.c.

  Flag-clear-first contract (#2.3/#5.1): every wrapper below clears its
  own IFSx bit BEFORE calling the core body. On dsPIC the IFSx bit does
  NOT auto-clear on vector entry (unlike AVR) - forgetting it re-enters
  forever, the loud kind of bug. `_T1IF`/`_CCT1IF`/`_U1RXIF`/`_U1TXIF`/
  `_CNAIF`/`_CNDIF` are the DFP's own IFSx bitfield-access macros
  (p33AK128MC102.h) - direct bit clears, not read-modify-write of the
  whole IFSx word, so no risk of clearing an unrelated pending flag.

  ISR frame note: __attribute__((interrupt)) makes xc-dsc emit full
  save/restore + RETFIE. Priorities (IPCx, set in platform.c) and
  nesting: dsPIC33A nests by priority natively (INTCON1.NSTDIS=0 at
  reset), so core's sei() inside ISR_STEP (stepper.c:355) genuinely lets
  the pulse-reset IRQ preempt it - CCT1IP=5 > T1IP=4 (platform.c) - the
  first port that can honor the AVR preemption semantic properly instead
  of the M0+ "defer, don't nest" posture (#5.2).
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
  _T1IF = 0;
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER ISR - SCCP1 timer (_CCT1Interrupt), CONTRACTS.md #4/#5
// ============================================================================
extern void __isr_step_reset_impl(void);

void __attribute__((interrupt, no_auto_psv)) _CCT1Interrupt(void)
{
  _CCT1IF = 0;
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
// timer.h #errors on STEP_PULSE_DELAY (not implemented on this chip yet) -
// this block intentionally has no vector to claim.
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
  _CNDIF = 0;             // IFS3.CNDIF - clear FIRST (#2.3)
  CNFD = 0;                // per-pin change flags (CNFD0-3) - clear after servicing edge (write 0)
  LIMIT_INT_IRQHandler();
}

void __attribute__((interrupt, no_auto_psv)) _CNAInterrupt(void)
{
  _CNAIF = 0;             // IFS3.CNAIF
  CNFA = 0;                // per-pin change flags (CNFA0-4)
  CONTROL_INT_IRQHandler();
}

// ============================================================================
// UART1 ISRs (Step 4) - route both to serial.c's dispatch, which checks
// which condition (RX data / TX ready) actually applies.
// ============================================================================
extern void serial_irq_dispatch(void);

void __attribute__((interrupt, no_auto_psv)) _U1RXInterrupt(void)
{
  _U1RXIF = 0;
  serial_irq_dispatch();
}

void __attribute__((interrupt, no_auto_psv)) _U1TXInterrupt(void)
{
  _U1TXIF = 0;
  serial_irq_dispatch();
}

// ============================================================================
// DELAY PRIMITIVES (PORTING-CHECKLIST Step 6)
// ============================================================================
// __delay32()/FCY are real toolchain library primitives (libpic30.a,
// verified this session: compiles, links against the shipped lib with no
// extra flags). FCY = instruction-cycle frequency; dsPIC33A is a 32-bit
// DSC core with a documented 1-cycle-per-instruction pipeline class -
// FCY=F_CPU is ASSUMED here (UNVERIFIED against the RM, same status as
// every other Fp-vs-F_CPU assumption in this port, platform.h). Unlike
// the earlier PORT_TODO stub, this is a REAL calibrated busy-wait (the
// "compiles but dead" class this contract exists to prevent, #13
// Closed-note precedent from the SAMD21 port).
#define FCY F_CPU
#include <libpic30.h>

void _delay_us(double __us) {
  __delay_us((unsigned long)__us);
}

void _delay_ms(double __ms) {
  __delay_ms((unsigned long)__ms);
}
