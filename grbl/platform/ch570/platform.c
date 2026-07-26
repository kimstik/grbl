/*
  platform.c - CH570 chip bring-up + peripheral init functions
  Part of Grbl
*/

#include <stdint.h>
#include "ch570.h"
#include "platform.h"

// GPIO PULL-UP / PULL-DOWN (Step 2) - two independent full-width
// registers (PD_DRV forces pull-down regardless of PU when set), truth
// table matches the vendor SDK's own GPIOA_ModeCfg exactly (CH57x_gpio.c):
//   floating: PD_DRV=0, PU=0      pull-up: PD_DRV=0, PU=1
//   pull-down: PD_DRV=1 (PU irrelevant once PD_DRV=1)
void hal_gpio_pullup_enable(hal_gpio_port_t port, uint32_t mask) {
  (void)port;   // single real port - see gpio.h's note on hal_gpio.h's shared signature
  R32_PA_PD_DRV &= ~mask;
  R32_PA_PU     |= mask;
}

void hal_gpio_pullup_disable(hal_gpio_port_t port, uint32_t mask) {
  (void)port;
  // Falls back to floating input - matches GPIO_DIR_INP's default (no
  // pull), consistent with every other port's PULLUP_DIS semantics.
  R32_PA_PU &= ~mask;
}

// GPIO INTERRUPTS (CONTRACTS.md #2) - ONE port, ONE shared vector
// (GPIOA_IRQn), per-pin edge/level select + per-pin enable + write-1-
// clear flags (datasheet-confirmed register names/positions, ch570.h).
//
// ANY-CHANGE EMULATION (new technique this port contributes - PLAN.md
// "each port strengthens the system"): the hardware's per-pin mode field
// is EDGE-XOR-LEVEL, and edge mode is single-polarity (rising OR falling,
// not both at once - datasheet R16_PA_INT_EDGE_TYPE, one bit per pin, no
// "either edge" encoding exists). CONTRACTS.md #2.6 requires "any pin
// CHANGE" semantics (the AVR PCINT reference: LIMIT/CONTROL must wake on
// press AND release). This port achieves it by ARMING edge mode at the
// CURRENT opposite-of-idle polarity, and then, in the ISR (handlers.c),
// FLIPPING that pin's EDGE_TYPE bit after each firing - so the next
// interrupt fires on whichever transition comes next, alternating
// forever. First-arm polarity here reads the pin's current level and
// arms the interrupt to fire on the transition AWAY from it (so the
// first interrupt is guaranteed to correspond to a real change, not a
// stale edge left over from before the enable call).
void hal_gpio_interrupt_enable(uint32_t mask) {
  uint16_t m = (uint16_t)mask;

  // Arm edge mode, polarity = away from the pin's CURRENT level (current
  // level HIGH -> arm for falling; LOW -> arm for rising). EDGE_TYPE bit
  // semantics (ch570.h): 1 = high/rising, 0 = low/falling.
  uint16_t cur_high = (uint16_t)(R32_PA_PIN & mask);
  R16_PA_INT_EDGE_TYPE = (uint16_t)((R16_PA_INT_EDGE_TYPE & ~m) | (~cur_high & m));
  R16_PA_INT_MODE     |= m;    // 1 = edge trigger
  R16_PA_INT_IF         = m;   // drop any stale pending bit (write-1-clear) before unmasking
  R16_PA_INT_EN        |= m;

  PFIC_EnableIRQ(GPIOA_IRQn);
}

void hal_gpio_interrupt_disable(uint32_t mask) {
  R16_PA_INT_EN &= (uint16_t)~mask;
}

// SYSTEM CLOCK BRING-UP (Step 1) - HSE (external 32MHz crystal, "X32M")
// -> fixed x18.75 PLL -> 600MHz internal -> /N divider -> Fsys.
// This port targets 60MHz (CLK_SOURCE_HSE_PLL_60MHz = 0x40 | 10, i.e.
// 600/10 = 60). Sequence mirrors the vendor SDK's own SetSysClock()
// (CH57x_sys.c) instruction-for-instruction, NOT re-derived from bit
// tables: the flash-timing register (R8_FLASH_CFG/R8_FLASH_SCK) written
// alongside the clock switch has no documented bit-meaning in the public
// datasheet beyond "RWA, flash ROM access config" - the vendor's own
// tested pairing of {this clock target, these two flash-config writes}
// is the authoritative source here, the same reasoning this port already
// applies to vendoring FLASH_EEPROM_CMD wholesale (ch570.h / vendor/).
// F_CPU=60000000 (Makefile CLOCK) must match this function's actual
// result - UNVERIFIED on real silicon (no CH570 emulator exists; PLAN.md
// hardware-validation item, same posture as every RISC-V port in this
// tree so far).
GRBL_BOOT_INIT void SystemClock_Config(void) {
  // 1. Bring up the external 32MHz crystal (X32M) if not already running
  //    - the vendor's own "warm nudge" sequence (brief over-drive pulse
  //    then restore tuning), SAM-gated throughout.
  if (!(R8_HFCK_PWR_CTRL & RB_CLK_XT32M_PON)) {
    uint8_t x32m_tune_save;
    uint8_t clk_sys_cfg_save;
    int i;

    x32m_tune_save = R8_XT32M_TUNE;
    { CH570_SAFE_ACCESS_BEGIN();
      R8_XT32M_TUNE |= 0x03;
      R8_HFCK_PWR_CTRL |= RB_CLK_XT32M_PON;
      CH570_SAFE_ACCESS_END();
    }
    clk_sys_cfg_save = R8_CLK_SYS_CFG;
    { CH570_SAFE_ACCESS_BEGIN();
      R8_CLK_SYS_CFG |= 0xC0;
      CH570_SAFE_ACCESS_END();
    }
    for (i = 0; i < 9; i++) { __asm volatile ("nop"); }
    { CH570_SAFE_ACCESS_BEGIN();
      R8_CLK_SYS_CFG = clk_sys_cfg_save;
      R8_XT32M_TUNE = x32m_tune_save;
      CH570_SAFE_ACCESS_END();
    }
  }

  // 2. Enable the PLL + the flash-timing pair the vendor pins to this
  //    exact clock family ("PLL div" branch of SetSysClock()).
  { CH570_SAFE_ACCESS_BEGIN();
    R8_HFCK_PWR_CTRL |= RB_CLK_PLL_PON;
    R8_FLASH_CFG = 0x01;
    R8_FLASH_SCK |= (1u << 4);
    CH570_SAFE_ACCESS_END();
  }

  // 3. Commit the divider (CLK_SYS_CFG = 0x40 | 10 -> Fsys = 600/10 = 60MHz).
  { CH570_SAFE_ACCESS_BEGIN();
    R8_SLP_POWER_CTRL |= 0x40;
    R8_CLK_SYS_CFG = 0x40u | 10u;
    CH570_SAFE_ACCESS_END();
  }
}

// STEPPER TIMER INIT (Step 3, CONTRACTS.md #3) - TMR0
uint32_t g_ch570_stepper_divisor = 1u;   // timer.h's software prescaler (no hw divider on TMR0)

void hal_timer_stepper_init(void) {
  TMR0->CTRL_MOD = RB_TMR_ALL_CLEAR;   // force-clear counter + FIFO first
  TMR0->CNT_END  = TMR_MAX_COUNT;      // full range until first PERIOD_SET
  TMR0->INT_FLAG = RB_TMR_IF_CYC_END;  // drop any stale flag (write-1-clear)
  TMR0->INTER_EN = 0;                  // cycle-end interrupt MASKED (contract)
  g_ch570_stepper_divisor = 1u;
  TMR0->CTRL_MOD = RB_TMR_COUNT_EN;    // counter running, timer mode (MODE_IN=0)

  PFIC_EnableIRQ(TMR_IRQn);
}

// PULSE-RESET TIMER INIT (STK) - identical shape to ch32v006's STK usage.
// AVR Timer0 semantics: interrupt source enabled, timer STOPPED.
void hal_timer_pulse_reset_init(void) {
  STK->CTLR  = STK_CTLR_STIE;   // STE=0 (stopped), STCLK=0 (HCLK/8), STRE=0, MODE=0
  STK->SR    = 0;                // clear CNTIF (write-0-to-clear)
  STK->CMPLR = 256u;             // fixed compare = the uint8 overflow point
  STK->CNTL  = 0;

  PFIC_EnableIRQ(SysTick_IRQn);
}

// SPINDLE PWM INIT (CONTRACTS.md #6) - PWM1, FIXED pin PA7 (no remap
// exists for PWM1-5 on this chip - datasheet pin table, ch570.h header).
// 8-bit cycle (256 steps) matches core's uint8_t duty domain 0-255
// EXACTLY - no rescale needed, unlike ch32v006's ATRLR=255 timer-compare
// approach (same numeric result, simpler mechanism here).
void hal_timer_spindle_pwm_init(void) {
  // PA7 needs no GPIO_DIR_OUT undo/remux step (unlike ch32v006's AF-mux
  // pins) - PWM1 drives PA7 directly once R8_PWM_OUT_EN's PWM1 bit is
  // set; the pin's own DIR/PU state set by spindle_control.c's
  // GPIO_DIR_OUT(SPINDLE_PWM) is irrelevant once the PWM peripheral owns
  // the pad (same class of behavior as every other port's AF pin mux,
  // just without a separate remap register to touch for this one).
  R8_PWM_CONFIG = RB_PWM_CYC_256;                 // 256-step (8-bit) cycle
  R16_PWM_CLOCK_DIV = (uint16_t)(F_CPU / (256u * 1000u));  // ~1kHz PWM base
  R8_PWM1_DATA = 0;
  R8_PWM_POLAR &= (uint8_t)~RB_PWM1_POLAR;         // default polarity: low idle, high-active
  R8_PWM_OUT_EN &= (uint8_t)~RB_PWM1_OUT_EN;        // disconnected until PWM_ENABLE()
}

// DELAYS - calibrated busy-wait (samd21/ch32v006 pattern: correct from
// reset onward, no peripheral state needed). STK and TMR0 are both
// already spoken for (pulse-reset timer / stepper timer respectively).
#define DELAY_LOOP_CYCLES        3u
#define DELAY_LOOP_ITERS_PER_US  (F_CPU / (DELAY_LOOP_CYCLES * 1000000uL))

static void delay_busy_loop(uint32_t iterations) {
  if (iterations == 0) { return; }
  __asm volatile (
    "1: addi %0, %0, -1 \n"
    "   bnez %0, 1b     \n"
    : "+r" (iterations)
  );
}

// Float-typed worker: everything past the ABI boundary is single
// precision (CONTRACTS.md #17 - see ch32v006/platform.c's comment for
// the full "one narrowing, not two" rationale; identical pattern here).
static void delay_us_f(float us) {
  uint32_t n = (uint32_t)us;
  if (n) { delay_busy_loop(n * DELAY_LOOP_ITERS_PER_US); }
}

void _delay_us(double __us) {
  delay_us_f((float)__us);
}

void _delay_ms(double __ms) {
  float    ms_f = (float)__ms;
  uint32_t ms   = (uint32_t)ms_f;

  for (uint32_t i = ms; i != 0; i--) {
    delay_busy_loop(1000u * DELAY_LOOP_ITERS_PER_US);
  }

  float rem = ms_f - (float)ms;
  if (rem > 0.0f) { delay_us_f(rem * 1000.0f); }
}
