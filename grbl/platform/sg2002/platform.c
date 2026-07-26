/*
  platform.c - SG2002 C906L bring-up and peripheral init
  Part of Grbl

  Every register touched here is UNVERIFIED - see sg2002.h's per-block
  banners for what each claim rests on. This file is where those claims turn
  into writes, so each function repeats the specific consequence of its own
  block being wrong.
*/

#include <stdint.h>
#include "platform.h"
#include "shm.h"

// ============================================================================
// SYSTEM CLOCK
//
// DELIBERATELY EMPTY, AND THIS IS NOT THE "COMPILES BUT DEAD" CLASS.
//
// PORTING-CHECKLIST Step 1 exists because a port that lies about its clock
// breaks every later step invisibly. On this target there is nothing for
// this firmware to configure: the C906L is a companion core released from
// reset by Linux, long after the boot chain has already brought up the PLLs,
// the DDR controller and every peripheral clock. The SoC's clock controller
// is owned by a Linux driver; a second writer here would be a bug, not
// diligence - the same "two drivers on one block" hazard sg2002.h warns
// about, applied to the most load-bearing block on the chip.
//
// So Step 1's obligation is discharged by DECLARATION plus a compile-time
// check rather than by configuration: platform.h's F_CPU static asserts pin
// the relationship the stepper arithmetic actually depends on (the 8-bit
// pulse-width horizon of CONTRACTS.md #4), and the Makefile's CLOCK variable
// carries the value a bring-up engineer must MEASURE. That is an honest
// empty function with a stated contract, not an empty stub standing where an
// implementation belongs.
// ============================================================================
void SystemClock_Config(void) {
  /* nothing to configure - see the comment above */
}

// ============================================================================
// PLIC
//
// If SG2002_PLIC_CONTEXT is wrong, everything below succeeds and no
// interrupt is ever delivered (sg2002.h names that signature).
//
// PRIORITY ORDERING (CONTRACTS.md #12.7): on a PLIC, a higher NUMBER is a
// higher priority, and priority only decides which source is claimed first
// when several are pending at the same instant - a PLIC has no preemption
// levels, so it cannot interrupt a running handler the way an NVIC can.
// The ordering below therefore expresses the contract's intent as far as
// this hardware can:  pulse-reset > stepper > GPIO > mailbox.
// The other half of #12.7 - "serial must not starve the stepper" - is
// handled where it actually can be, in handlers.c (the doorbell handler
// re-enables interrupts around its drain loop).
// ============================================================================
#define SG2002_PRIO_PULSE     7u
#define SG2002_PRIO_STEP      6u
#define SG2002_PRIO_GPIO      4u
#define SG2002_PRIO_MAILBOX   1u

#define SG2002_PLIC_MAX_IRQ   256u

void sg2002_plic_init(void) {
  // Accept every source with a nonzero priority.
  SG2002_PLIC_THRESHOLD(SG2002_PLIC_CONTEXT) = 0u;

  // Start from a known state: nothing enabled for OUR context, every
  // priority zeroed. Linux owns a different context, so this does not touch
  // its enables - only the shared per-source priority array, which is why
  // the priorities are (re)written by sg2002_plic_enable() for exactly the
  // sources this port uses and left at 0 for everything else.
  for (uint32_t irq = 0u; irq < SG2002_PLIC_MAX_IRQ; irq += 32u) {
    SG2002_PLIC_ENABLE(SG2002_PLIC_CONTEXT, irq) = 0u;
  }
}

void sg2002_plic_enable(uint32_t irq, uint32_t priority) {
  HAL_CRITICAL_SECTION_BEGIN();
  SG2002_PLIC_PRIORITY(irq) = priority;
  SG2002_PLIC_ENABLE(SG2002_PLIC_CONTEXT, irq) |= (1UL << (irq & 31u));
  HAL_CRITICAL_SECTION_END();
}

void sg2002_plic_disable(uint32_t irq) {
  HAL_CRITICAL_SECTION_BEGIN();
  SG2002_PLIC_ENABLE(SG2002_PLIC_CONTEXT, irq) &= ~(1UL << (irq & 31u));
  HAL_CRITICAL_SECTION_END();
}

// ============================================================================
// MAILBOX DOORBELL
//
// The whole chip's weakest-known register block, confined to these three
// functions on purpose (sg2002.h). Nothing else in this port touches the
// mailbox, so correcting these offsets is a three-function change.
//
// A wrong doorbell costs LIVENESS, never data integrity: the ring in shm.h
// is fully described by its head/tail indices, so a host that polls works
// with the doorbell absent entirely.
// ============================================================================
void sg2002_doorbell_init(void) {
  SG2002_MBOX_INT_CLR(SG2002_MBOX_CPU_RTOS) = 0xFFFFFFFFUL;  // drop anything stale
  SG2002_MBOX_EN(SG2002_MBOX_CPU_RTOS)      = 0xFFFFFFFFUL;  // accept host doorbells
  sg2002_plic_enable(SG2002_IRQ_MAILBOX, SG2002_PRIO_MAILBOX);
}

void sg2002_doorbell_ring(void) {
  // ORDERING IS THE CONTRACT (CONTRACTS.md #cross-core-cache-coherency
  // composed with the BUG #13 class): this MMIO store announces "data is
  // ready" and must not be observable before the writeback that made the
  // data real. Callers do the writeback; this fence is the second half of
  // the guarantee, ensuring the store below cannot be hoisted above it.
  SG2002_FENCE();
  SG2002_MBOX_SET(SG2002_MBOX_CPU_HOST) = 1UL;
}

void sg2002_doorbell_ack(void) {
  SG2002_MBOX_INT_CLR(SG2002_MBOX_CPU_RTOS) = 0xFFFFFFFFUL;
}

// ============================================================================
// GPIO PULL-UPS (CONTRACTS.md #1.4)
//
// A real write into the pad-control block. DesignWare apb_gpio has no pull
// control of its own, so the register a given pin's pull lives in is a
// PACKAGE fact, supplied by the board config as SG2002_PAD_PULL_REG(bank,
// bit) - it is not derivable here and is not guessed here.
//
// If the mapping is wrong: inputs stay floating and limit/probe reads are
// noise. That is a hardware-bring-up defect. A no-op here would instead be a
// CONTRACT violation (#1.4 permits an empty pull-up only on boards with
// external pull hardware, and then only if the board config says so), which
// is why this is written even though the mapping is unverified.
// ============================================================================
void hal_gpio_pullup_enable(uint8_t bank, uint32_t mask) {
  for (uint32_t bit = 0u; bit < 32u; bit++) {
    if (mask & (1UL << bit)) {
      volatile uint32_t *pad = (volatile uint32_t *)(uintptr_t)SG2002_PAD_PULL_REG(bank, bit);
      *pad = (*pad & ~SG2002_PAD_PD_BIT) | SG2002_PAD_PU_BIT;
    }
  }
}

void hal_gpio_pullup_disable(uint8_t bank, uint32_t mask) {
  for (uint32_t bit = 0u; bit < 32u; bit++) {
    if (mask & (1UL << bit)) {
      volatile uint32_t *pad = (volatile uint32_t *)(uintptr_t)SG2002_PAD_PULL_REG(bank, bit);
      // Floating, matching every other port's PULLUP_DIS semantics: drop the
      // pull-up without asserting a pull-down.
      *pad = *pad & ~SG2002_PAD_PU_BIT;
    }
  }
}

// ============================================================================
// GPIO INTERRUPTS (CONTRACTS.md #2)
//
// #2.1: these are called REPEATEDLY at runtime, not only at boot - homing
// disables hard limits (limits.c:67) and every `$` settings write re-enables
// them (limits.c:53). Both must actually gate delivery. Disable therefore
// clears INTEN, which stops the source at the pin, rather than merely
// masking a downstream controller line that other pins share.
//
// #2.6 wants edge detection on BOTH edges. This IP's INT_POLARITY selects
// ONE edge per pin. The enable path arms the polarity AWAY from each pin's
// CURRENT level, so the first interrupt is guaranteed to be a real change
// rather than a stale edge; handlers.c then flips the polarity after each
// firing, which is what turns single-polarity hardware into any-change
// semantics across consecutive interrupts.
//
// Critical sections: INT_POLARITY is read-modify-written both here (mainline)
// and in the ISR. That is exactly CONTRACTS.md #12.2 - a volatile RMW shared
// with an ISR - and needs the bracket, not just `volatile`.
//
// DEBOUNCE is deliberately left OFF: the DesignWare debounce stage needs a
// separate slow clock whose presence and rate on this SoC is unverified, and
// #2.6 makes filtering permitted, never required. ENABLE_SOFTWARE_DEBOUNCE
// remains the supported route (and correctly fails to build - CONTRACTS.md
// #9 - since no port implements the watchdog family).
// ============================================================================
void hal_gpio_interrupt_enable(uint8_t bank, uint32_t mask) {
  HAL_CRITICAL_SECTION_BEGIN();
  {
    uint32_t cur_high = SG2002_GPIO_EXT_PORTA(bank) & mask;

    SG2002_GPIO_INTTYPE_LEVEL(bank) |= mask;    // 1 = edge-sensitive
    SG2002_GPIO_INT_POLARITY(bank)   =
        (SG2002_GPIO_INT_POLARITY(bank) & ~mask) | (~cur_high & mask);
    SG2002_GPIO_PORTA_EOI(bank)      = mask;    // drop stale pending before unmasking
    SG2002_GPIO_INTMASK(bank)       &= ~mask;
    SG2002_GPIO_INTEN(bank)         |= mask;
  }
  HAL_CRITICAL_SECTION_END();

  sg2002_plic_enable(SG2002_IRQ_GPIO(bank), SG2002_PRIO_GPIO);
}

void hal_gpio_interrupt_disable(uint8_t bank, uint32_t mask) {
  HAL_CRITICAL_SECTION_BEGIN();
  SG2002_GPIO_INTEN(bank) &= ~mask;
  HAL_CRITICAL_SECTION_END();
  // The PLIC line stays enabled: the other group may share this bank
  // (#2.5), and homing must silence LIMIT without silencing CONTROL.
}

// ============================================================================
// STEPPER TIMER (CONTRACTS.md #3)
//
// Exit state required by #3: running, /1, interrupt MASKED. INT_MASK is
// active-high "masked", so it is SET here and cleared by STP_TMR_INT_ENA().
// ============================================================================
uint32_t g_sg2002_stepper_divisor = 1u;   // timer.h's software prescaler

void hal_timer_stepper_init(void) {
  SG2002_TMR_CONTROL(SG2002_TMR_CH_STEP)   = 0u;            // stop before reprogramming
  SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_STEP) = 0xFFFFFFFFUL;  // full range until first PERIOD_SET
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_STEP);                 // read-to-clear any stale flag

  g_sg2002_stepper_divisor = 1u;

  SG2002_TMR_CONTROL(SG2002_TMR_CH_STEP) =
      SG2002_TMR_CTRL_MODE_USER | SG2002_TMR_CTRL_INT_MASK | SG2002_TMR_CTRL_ENABLE;

  sg2002_plic_enable(SG2002_IRQ_TIMER(SG2002_TMR_CH_STEP), SG2002_PRIO_STEP);
}

// ============================================================================
// PULSE-RESET TIMER (CONTRACTS.md #4)
//
// Exit state required by #4: interrupt source ENABLED, timer STOPPED (the
// AVR Timer0 semantic - TIMSK0 armed, TCCR0B zero). So INT_MASK is left
// CLEAR and ENABLE is left clear; STP_PULSE_RESET_START() starts it.
// ============================================================================
uint8_t g_sg2002_pulse_preload = 0u;      // timer.h's staged uint8_t preload

void hal_timer_pulse_reset_init(void) {
  SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE)   = 0u;
  SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_PULSE) = 256u * 8u;   // full 8-bit horizon
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_PULSE);

  g_sg2002_pulse_preload = 0u;

  SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE) = SG2002_TMR_CTRL_MODE_USER;  // armed, stopped

  sg2002_plic_enable(SG2002_IRQ_TIMER(SG2002_TMR_CH_PULSE), SG2002_PRIO_PULSE);
}

void hal_timer_pulse_delay_init(void) {
  SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE_DLY)   = 0u;
  SG2002_TMR_LOADCOUNT(SG2002_TMR_CH_PULSE_DLY) = 256u * 8u;
  (void)SG2002_TMR_EOI(SG2002_TMR_CH_PULSE_DLY);
  SG2002_TMR_CONTROL(SG2002_TMR_CH_PULSE_DLY)   = SG2002_TMR_CTRL_MODE_USER;

  sg2002_plic_enable(SG2002_IRQ_TIMER(SG2002_TMR_CH_PULSE_DLY), SG2002_PRIO_PULSE);
}

// ============================================================================
// SPINDLE PWM (CONTRACTS.md #6)
//
// Duty domain is core's uint8_t 0..SPINDLE_PWM_MAX_VALUE (=255, #6.2). The
// PWM counter runs far too fast to use 255 ticks as the whole period, so
// both PERIOD and HLPERIOD are scaled by a stored factor - the duty RATIO,
// which is what #6 actually binds, stays exact because both sides of the
// ratio carry the same factor.
// ============================================================================
uint32_t g_sg2002_pwm_scale = 1u;

void hal_timer_spindle_pwm_init(void) {
  uint32_t scale = F_CPU / (SPINDLE_PWM_FREQUENCY * (SPINDLE_PWM_MAX_VALUE + 1u));
  if (scale == 0u) { scale = 1u; }
  g_sg2002_pwm_scale = scale;

  SG2002_PWM_START    &= ~(1UL << SPINDLE_PWM_CH);          // stopped while reprogramming
  SG2002_PWM_PERIOD(SPINDLE_PWM_CH)   = (SPINDLE_PWM_MAX_VALUE + 1u) * scale;
  SG2002_PWM_HLPERIOD(SPINDLE_PWM_CH) = 0u;
  SG2002_PWM_POLARITY &= ~(1UL << SPINDLE_PWM_CH);          // low idle, high active
  SG2002_PWM_UPDATE   |= (1UL << SPINDLE_PWM_CH);
  SG2002_PWM_OE       &= ~(1UL << SPINDLE_PWM_CH);          // #6.4: pin driven inactive,
                                                            // not floating, until PWM_ENABLE
}

// ============================================================================
// DELAYS (_delay_us / _delay_ms)
//
// Backed by the CLINT's mtime counter, NOT a calibrated busy loop. Every
// other port in this tree counts instruction cycles, which works because
// their cores are simple in-order machines with a known cycle count per
// loop iteration. This one is a 700 MHz superscalar core whose loop timing
// is not derivable from any document that exists, so a cycle-counted loop
// would be a guess in a path that matters (homing debounce and spindle
// ramp - CONTRACTS.md #13's "empty delay stubs compile and break homing
// silently" lesson, one step further: a WRONGLY CALIBRATED loop fails the
// same way, just less obviously).
//
// mtime is a real monotonic counter with a single unknown - its tick rate,
// captured in ONE constant (SG2002_MTIME_HZ, platform.h) that a bring-up
// engineer can correct in one line after one measurement.
//
// The (double) signatures come from AVR's util/delay.h contract. Everything
// past that boundary is single precision (CONTRACTS.md #17): ONE narrowing
// at entry, then float throughout - no double arithmetic hides behind the
// boundary, which is exactly the samd21 defect #17 records.
// ============================================================================
static void delay_mtime_ticks(uint64_t ticks) {
  uint64_t start = SG2002_CLINT_MTIME;
  while ((uint64_t)(SG2002_CLINT_MTIME - start) < ticks) {
    /* spin - interrupts stay enabled, the stepper keeps running */
  }
}

#define SG2002_MTIME_PER_US   ((float)SG2002_MTIME_HZ / 1000000.0f)

static void delay_us_f(float us) {
  if (us > 0.0f) {
    delay_mtime_ticks((uint64_t)(us * SG2002_MTIME_PER_US));
  }
}

void _delay_us(double __us) {
  delay_us_f((float)__us);
}

void _delay_ms(double __ms) {
  delay_us_f((float)__ms * 1000.0f);
}
