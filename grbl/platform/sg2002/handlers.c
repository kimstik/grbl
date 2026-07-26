/*
  handlers.c - SG2002 trap entry, PLIC demultiplex, and interrupt bodies
  Part of Grbl

  Structure mandated by CONTRACTS.md #2.3/#5.1: every wrapper clears its own
  peripheral flag FIRST, then calls the CORE-SUPPLIED ISR body. No wrapper in
  this file contains machine logic of its own - the only code here besides
  flag hygiene is the any-edge polarity flip, which is flag hygiene for a
  hardware shape that has no any-edge mode.

  ============================================================================
  ONE TRAP ENTRY, TWO LEVELS OF DEMULTIPLEX
  ============================================================================
  mtvec direct mode (startup.c) -> sg2002_trap_entry() -> mcause says
  "machine external interrupt" -> PLIC claim says which peripheral. Any other
  mcause is an exception and hangs loudly: on a core with no debugger
  attached and no console of its own until serial.c is up, a silent restart
  loop is the worst possible failure mode.

  ============================================================================
  NESTING IS SUPPORTED HERE, UNLIKE THE OTHER RISC-V PORTS IN THIS TREE
  ============================================================================
  CONTRACTS.md #5.2: core re-enables interrupts inside ISR_STEP (stepper.c's
  `sei()`) so the pulse-reset interrupt can preempt it - that is the AVR
  origin semantic. ch32v006 and ch570 both DEFER instead of nesting (their
  vendor INESTEN stays 0), which #5.2 accepts as a precedent because their
  ISR_STEP tails are short.

  This port nests for real. The blocker on a plain
  `__attribute__((interrupt))` handler is that GCC's generated prologue saves
  GPRs but NOT `mepc`/`mstatus` - so a nested trap overwrites the outer
  trap's return address and the outer handler `mret`s into the wrong place.
  sg2002_trap_entry() saves and restores both CSRs explicitly around its
  dispatch, which is the whole fix. `mstatus` is restored (with MIE clear, as
  it was on entry) BEFORE `mepc`, so no interrupt can be taken between the
  restore and the compiler's `mret`.

  This also discharges the second half of CONTRACTS.md #12.7 - "serial must
  not starve the stepper". The PLIC has no preemption-level concept (unlike
  the NVIC): priorities only order simultaneous claims, they do not let a
  higher-priority source interrupt a running handler. Since the doorbell
  handler's drain loop is bounded only by how much the host sent - up to a
  full 8 KiB ring - running it with interrupts masked would blow the 33.3 us
  ISR-hot budget by orders of magnitude. So the doorbell handler re-enables
  interrupts around its drain, exactly the way ISR_STEP does, and the
  stepper/pulse-reset pair preempts it freely. It cannot recurse into itself:
  the PLIC will not re-deliver a source that is claimed and not yet
  completed.
*/

#include <stdint.h>
#include "platform.h"
#include "../../grbl.h"   // core build options (STEP_PULSE_DELAY, ...) must be
                          // visible HERE, not just in core files - a guard on a
                          // core option written before grbl.h is a guard that
                          // never fires (see timer.h's note on the same trap)

#ifdef STEP_PULSE_DELAY
/*
  ISR_STEP_DELAY's core body writes the WHOLE step register with a LOGICAL
  port image (`GPIO_OREG(STEP) = st.step_bits`, stepper.c:513 - CONTRACTS.md
  #1's raw-store case). That is only correct where the logical and physical
  images coincide. This board deliberately maps STEP past bit 7 to exercise
  the L2P/P2L machinery (BUG #17), so the two do not coincide and the option
  must fail loudly rather than drive the wrong pins - #4's conditional rule.
  A board with an identity STEP map passes this assert and gets working
  delayed-step support, which the timer side already provides (timer.h).
*/
_Static_assert(STEP_MASK_PHYS == STEP_MASK,
               "STEP_PULSE_DELAY needs an identity STEP logical->physical map: core's "
               "ISR_STEP_DELAY body stores a logical port image straight into the step "
               "register (stepper.c:513) and cannot go through L2P");
#endif

// Core-supplied ISR bodies (the ONLY things this file dispatches to)
extern void __isr_step_impl(void);         // stepper.c via ISR_STEP()
extern void __isr_step_reset_impl(void);   // stepper.c via ISR_STEP_RESET()
#ifdef STEP_PULSE_DELAY
extern void __isr_step_delay_impl(void);   // stepper.c via ISR_STEP_DELAY()
#endif
extern void LIMIT_INT_IRQHandler(void);    // limits.c via HAL_GPIO_IRQ_HANDLER(LIMIT_INT)
extern void CONTROL_INT_IRQHandler(void);  // system.c via HAL_GPIO_IRQ_HANDLER(CONTROL_INT)
extern void serial_irq_dispatch(void);     // serial.c (the doorbell handler body)

// ============================================================================
// STEPPER TIMER (CONTRACTS.md #3, #5)
// The DesignWare timer's interrupt flag is cleared by READING the EOI
// register - a read-to-clear, not a write-1-to-clear. The read result is
// deliberately discarded into a volatile-qualified access; it must not be
// optimised away, which the register macro's `volatile` guarantees.
// ============================================================================
static inline void sg2002_isr_step(void) {
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_STEP);   // clear FIRST (#5.1)
  __isr_step_impl();
}

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md #4, #5)
// The core body stops the timer itself (stepper.c:503); clearing the flag
// after that write can ghost or drop the final expiry, which is precisely
// why #5.1 says clear first.
// ============================================================================
static inline void sg2002_isr_step_reset(void) {
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_PULSE);
  __isr_step_reset_impl();
}

#ifdef STEP_PULSE_DELAY
static inline void sg2002_isr_step_delay(void) {
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_PULSE_DLY);
  // One-shot: the delayed-step channel must not free-run.
  SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE_DLY) &= ~SG2002_TMR_CTRL_ENABLE;
  __isr_step_delay_impl();
}
#endif

// ============================================================================
// GPIO BANK - one PLIC line for all 32 pins of a bank (CONTRACTS.md #2).
// LIMIT and CONTROL occupy disjoint bit ranges in the board config, so the
// pending mask separates them; both are dispatched when both are pending,
// per #2.5.
//
// ANY-EDGE EMULATION (#2.6): DesignWare apb_gpio's INT_POLARITY selects ONE
// edge per pin; a minimal synthesis has no both-edge register. Core treats
// any CHANGE as a trigger (limits.c:95-101 - a switch must register on press
// AND release). So after servicing each pending bit, its polarity is flipped,
// arming the opposite transition for next time. Same technique ch570
// contributed; the flip is done as part of flag hygiene, before any core
// body runs, so an edge arriving during the body is captured on the new
// polarity rather than lost.
// ============================================================================
static inline void sg2002_isr_gpio(uint8_t bank) {
  uint32_t pending = SG2002_GPIO_INTSTATUS(bank);

  SG2002_GPIO_PORTA_EOI(bank)    = pending;   // write-1-to-clear, FIRST (#2.3)
  SG2002_GPIO_INT_POLARITY(bank) ^= pending;  // arm the opposite edge

  // Bank-qualified so the two groups may live in different banks without the
  // masks aliasing each other. When they share a bank (the generic board)
  // both comparisons fold away at compile time.
  if ((bank == (uint8_t)LIMIT_PORT)   && (pending & LIMIT_MASK))   { LIMIT_INT_IRQHandler(); }
  if ((bank == (uint8_t)CONTROL_PORT) && (pending & CONTROL_MASK)) { CONTROL_INT_IRQHandler(); }
}

// ============================================================================
// MAILBOX DOORBELL - this IS HAL_SERIAL_RX_ISR (CONTRACTS.md #7); see
// serial.c and shm.h for the drain-loop contract and the BUG #19 invariant.
//
// The doorbell is acked BEFORE draining, not after: acking after would race
// a burst the host pushes while we drain, losing its notification. Acking
// first can at worst produce one spurious empty entry later, which the drain
// loop handles by finding head == tail and doing nothing.
//
// sei()/cli() bracket: see this file's header - the drain is unbounded in
// principle and must not hold off the stepper pair.
// ============================================================================
static inline void sg2002_isr_doorbell(void) {
  sg2002_doorbell_ack();   // clear FIRST (#2.3 discipline, applied to the mailbox)
  sei();
  serial_irq_dispatch();
  cli();
}

// ============================================================================
// TRAP ENTRY
// ============================================================================
#define MCAUSE_INTERRUPT_BIT   (1UL << 63)
#define MCAUSE_CODE_MASK       0xFFUL
#define MCAUSE_MACHINE_EXT     11UL

__attribute__((interrupt("machine"), aligned(64)))
void sg2002_trap_entry(void) {
  uintptr_t mepc_save, mstatus_save, cause;

  // Save what the compiler's interrupt prologue does not, so the dispatch
  // below may safely re-enable interrupts and take a nested trap.
  __asm__ volatile ("csrr %0, mepc"    : "=r" (mepc_save));
  __asm__ volatile ("csrr %0, mstatus" : "=r" (mstatus_save));
  __asm__ volatile ("csrr %0, mcause"  : "=r" (cause));

  if ((cause & MCAUSE_INTERRUPT_BIT) &&
      ((cause & MCAUSE_CODE_MASK) == MCAUSE_MACHINE_EXT)) {

    // PLIC claim/complete loop: claim returns 0 when nothing is pending.
    for (;;) {
      uint32_t irq = SG2002_PLIC_CLAIM(SG2002_PLIC_CONTEXT);
      if (irq == 0u) { break; }

      if (irq == SG2002_IRQ_TIMER(SG2002_TMR_CH_STEP)) {
        sg2002_isr_step();
      } else if (irq == SG2002_IRQ_TIMER(SG2002_TMR_CH_PULSE)) {
        sg2002_isr_step_reset();
#ifdef STEP_PULSE_DELAY
      } else if (irq == SG2002_IRQ_TIMER(SG2002_TMR_CH_PULSE_DLY)) {
        sg2002_isr_step_delay();
#endif
      } else if (irq == SG2002_IRQ_GPIO(LIMIT_PORT)) {
        sg2002_isr_gpio((uint8_t)LIMIT_PORT);
#if (CONTROL_PORT != LIMIT_PORT)
      } else if (irq == SG2002_IRQ_GPIO(CONTROL_PORT)) {
        sg2002_isr_gpio((uint8_t)CONTROL_PORT);
#endif
      } else if (irq == SG2002_IRQ_MAILBOX) {
        sg2002_isr_doorbell();
      }
      // An unknown source is still completed below - dropping the completion
      // would wedge the whole PLIC context on one stray line forever.

      SG2002_PLIC_CLAIM(SG2002_PLIC_CONTEXT) = irq;   // complete
    }
  } else {
    /*
      Synchronous exception, or an interrupt this port never enables. There
      is no console to report on (serial.c's ring may not even be up) and
      returning would re-execute the faulting instruction forever. Hang
      visibly instead: `wfi` in a loop leaves the core in a state the host
      can see through remoteproc's state file and stop/restart, rather than
      spinning hot or silently looping through the trap handler.
    */
    for (;;) {
      __asm__ volatile ("wfi");
    }
  }

  __asm__ volatile ("csrw mstatus, %0" : : "r" (mstatus_save) : "memory");
  __asm__ volatile ("csrw mepc, %0"    : : "r" (mepc_save)    : "memory");
}
