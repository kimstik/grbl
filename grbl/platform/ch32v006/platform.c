/*
  platform.c - CH32V006 chip bring-up + peripheral init functions
  Part of Grbl
*/

#include <stdint.h>
#include "ch32v006.h"
#include "platform.h"

// GPIO PIN CONFIG (Step 2)
/*
  CFGLR only - V00X ports are 8 pins wide, there is no CFGHR (RM 7.3.1).
  Per-pin nibble: CNF[3:2] | reserved[1] | MODE[0]; MODE is a SINGLE bit
  (1 = output 30MHz, 0 = input) - not F1's 2-bit speed field. Init-context
  RMW only (CONTRACTS.md gpio contract - direction/pull config never runs
  from ISRs).
*/
void hal_gpio_config_pin(GPIO_TypeDef* port, uint8_t pin, uint32_t cfg4) {
  uint32_t shift = (uint32_t)(pin & 7u) * 4u;
  uint32_t mask = 0xFUL << shift;

  port->CFGLR = (port->CFGLR & ~mask) | ((cfg4 & 0xFUL) << shift);
}

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 8; pin++) {
    if (mask & (1UL << pin)) { hal_gpio_config_pin(port, pin, GPIO_CFG_OUT_PP); }
  }
}

void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask) {
  // Floating input (CONTRACTS.md #1.4: pull-up is a SEPARATE call the
  // core makes via GPIO_MPULLUP_EN/DIS).
  for (uint8_t pin = 0; pin < 8; pin++) {
    if (mask & (1UL << pin)) { hal_gpio_config_pin(port, pin, GPIO_CFG_IN_FLOATING); }
  }
}

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask) {
  // CNF=10 input + ODR bit = 1 selects pull-UP (RM 7.3.1.3: "For with
  // pull-up input mode: 1: Pull-up input; 0: Pull-down input"). This is a
  // genuine hardware pull-up - CONTRACTS.md #1.4 satisfied for real,
  // unlike the SAMD21 reference's known-wrong PORT.CTRL mapping.
  for (uint8_t pin = 0; pin < 8; pin++) {
    if (mask & (1UL << pin)) { hal_gpio_config_pin(port, pin, GPIO_CFG_IN_PULL); }
  }
  port->BSHR = mask & 0xFFu;   // ODR=1 -> pull-up (atomic set, init context anyway)
}

void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask) {
  // Falls back to floating input - matches GPIO_DIR_INP's default.
  for (uint8_t pin = 0; pin < 8; pin++) {
    if (mask & (1UL << pin)) { hal_gpio_config_pin(port, pin, GPIO_CFG_IN_FLOATING); }
  }
}

// GPIO EXTERNAL INTERRUPTS (Step 6, CONTRACTS.md #2)
/*
  EXTI line N serves pin N of ONE port, selected by AFIO_EXTICR's 2-bit
  field per line (RM 7.3.2.1: 00=PA 01=PB 10=PC 11=PD). Both edges armed -
  core treats any pin CHANGE as a trigger (#2.6). All lines 0-7 funnel
  into the single EXTI7_0 PFIC vector (handlers.c dispatches both core
  groups, #2.5).

  Runtime contract (#2.1): these are called repeatedly (homing/settings
  writes). enable is idempotent; disable masks ONLY the given lines in
  EXTI_INTENR, so the other group keeps working. The PFIC channel is left
  enabled - delivery is gated per line.
*/
static uint32_t exti_port_code(GPIO_TypeDef* port) {
  if (port == GPIOA) { return 0u; }
  if (port == GPIOB) { return 1u; }
  if (port == GPIOC) { return 2u; }
  return 3u; // GPIOD
}

void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  uint32_t code = exti_port_code(port);

  RCC->PB2PCENR |= RCC_PB2PCENR_AFIOEN;

  for (uint8_t pin = 0; pin < 8; pin++) {
    if (mask & (1UL << pin)) {
      uint32_t field_shift = (uint32_t)pin * 2u;
      AFIO->EXTICR = (AFIO->EXTICR & ~(0x3UL << field_shift)) | (code << field_shift);
      EXTI->RTENR |= (1UL << pin);   // both edges (#2.6)
      EXTI->FTENR |= (1UL << pin);
      EXTI->INTFR  = (1UL << pin);   // drop any stale edge before unmasking
      EXTI->INTENR |= (1UL << pin);
    }
  }

  PFIC_EnableIRQ(EXTI7_0_IRQn);
}

void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask) {
  (void)port;  // line<->port mapping already fixed by enable; masking is per line
  EXTI->INTENR &= ~(mask & 0xFFu);
}

// SYSTEM CLOCK BRING-UP (Step 1) - HSI 24 MHz -> PLL x2 -> 48 MHz
/*
  All register facts TRM-verified this session (RM 3.3/3.4):
  - HSI = 24 MHz internal RC, on and selected at reset.
  - PLL = FIXED x2 (no PLLMUL field exists); PLLSRC=0 feeds HSI undivided.
  - FLASH_ACTLR LATENCY must be 0b10 (2 waits) for 24 < SYSCLK <= 48 MHz
    (RM 18.3.1) - the M1-M3 draft's 1-wait guess was only good to 24 MHz.
  - HPRE[3:0] RESETS TO 0b0010 = SYSCLK/3 (RM 3.4.2)! It must be cleared
    or HCLK (= every peripheral clock + the STK tick + USART baud source)
    runs at F_CPU/3 while the firmware believes F_CPU - the exact
    "F_CPU lie" failure PORTING-CHECKLIST Step 1 warns about. Gap logged
    in CONTRACTS.md #14.
*/
GRBL_BOOT_INIT void SystemClock_Config(void) {
  // 1. HSI on + ready (power-on default, belt-and-braces).
  RCC->CTLR |= RCC_CTLR_HSION;
  while (!(RCC->CTLR & RCC_CTLR_HSIRDY)) { /* spin */ }

  // 2. Flash wait states BEFORE raising the clock: 2 waits for 48 MHz.
  FLASH->ACTLR = (FLASH->ACTLR & ~FLASH_ACTLR_LATENCY_Msk) | FLASH_ACTLR_LATENCY_2;

  // 3. HB prescaler OFF (clear the /3 reset default) + PLL source = HSI.
  RCC->CFGR0 = (RCC->CFGR0 & ~(RCC_CFGR0_HPRE_Msk | RCC_CFGR0_PLLSRC));

  // 4. PLL on (fixed x2 -> 48 MHz), wait ready.
  RCC->CTLR |= RCC_CTLR_PLLON;
  while (!(RCC->CTLR & RCC_CTLR_PLLRDY)) { /* spin */ }

  // 5. Switch SYSCLK to PLL, confirm via SWS.
  RCC->CFGR0 = (RCC->CFGR0 & ~RCC_CFGR0_SW_Msk) | RCC_CFGR0_SW_PLL;
  while ((RCC->CFGR0 & RCC_CFGR0_SWS_Msk) != RCC_CFGR0_SWS_PLL) { /* spin */ }
}

// STEPPER TIMER INIT (Step 3, CONTRACTS.md #3) - TIM2
/*
  Post-INIT state contract: running, /1, compare interrupt masked (AVR
  Timer1 CTC semantics; INIT+STP_TMR_PRESCALER_RESET together). UIE stays
  0 here - STP_TMR_INT_ENA() (st_wake_up) unmasks it; the PFIC channel is
  enabled once, delivery gated by UIE. TIM2 is clocked at HCLK = F_CPU
  (single HB clock domain on V00X - no APB doubler).
*/
void hal_timer_stepper_init(void) {
  RCC->PB1PCENR |= RCC_PB1PCENR_TIM2EN;

  TIM2->CTLR1 = 0;
  TIM2->PSC = 0;                    // /1 (STP_TMR_PRESCALER_RESET-equivalent)
  TIM2->ATRLR = 0xFFFF;             // full 16-bit range until first PERIOD_SET
  TIM2->SWEVGR = TIM_SWEVGR_UG;     // latch PSC/ARR preloads now
  TIM2->INTFR = 0;                  // drop the UIF the UG event just set (RW0: write 0 clears)
  TIM2->DMAINTENR = 0;              // update interrupt MASKED (contract)
  TIM2->CTLR1 = TIM_CTLR1_CEN;      // counter running

  PFIC_EnableIRQ(TIM2_IRQn);
}

// PULSE-RESET TIMER INIT (Step 4 of the timer trio, CONTRACTS.md #4) - STK
/*
  AVR Timer0 semantics: interrupt source enabled, timer STOPPED. STK
  configured for HCLK/8 (STCLK=0) = the AVR F_CPU/8 tick exactly; STRE=0
  (no auto-reload - the ISR stops the counter, stepper.c:503); CMPLR fixed
  at 256 so a COUNT_SET(val) preload fires the compare after exactly
  (256 - val) ticks - the 8-bit overflow horizon on a 32-bit counter.
*/
void hal_timer_pulse_reset_init(void) {
  STK->CTLR = STK_CTLR_STIE;        // STE=0 (stopped), STCLK=0 (HCLK/8), STRE=0
  STK->SR = 0;                      // clear CNTIF (write-0-to-clear, RM 6.5.4.2)
  STK->CMPLR = 256u;                // fixed compare = the uint8 overflow point
  STK->CNTL = 0;

  PFIC_EnableIRQ(SysTick_IRQn);
}

// SPINDLE PWM INIT (CONTRACTS.md #6) - TIM1 CH1 on PA3 (TIM1_RM=0100)
/*
  ATRLR = SPINDLE_PWM_MAX_VALUE (255, fits core's uint8_t duty domain,
  #6.2); PSC = 191 -> 48MHz/192/256 = 976.6 Hz PWM - the AVR Timer2
  fast-PWM base frequency (16MHz/64/256), so spindle behavior matches the
  origin. PWM mode 1 + OC1PE preload; BDTR.MOE set once here (TIM1-class
  master output gate); CCER.CC1E is the PWM_ENABLE/DISABLE connect switch.
  PA3 is re-muxed to AF push-pull HERE, after core's GPIO_DIR_OUT left it
  a plain GPIO (f103 pattern, timer.h note).
*/
void hal_timer_spindle_pwm_init(void) {
  RCC->PB2PCENR |= RCC_PB2PCENR_TIM1EN | RCC_PB2PCENR_AFIOEN | RCC_PB2PCENR_IOPAEN;

  // TIM1 partial remap: CH1 -> PA3 (RM table 7-8, TIM1_RM=0100).
  AFIO->PCFR1 = (AFIO->PCFR1 & ~AFIO_PCFR1_TIM1_RM_Msk)
              | ((uint32_t)SPINDLE_PWM_TIM1_RM << AFIO_PCFR1_TIM1_RM_Pos);

  hal_gpio_config_pin(SPINDLE_PWM_PORT, SPINDLE_PWM_PIN, GPIO_CFG_OUT_AF_PP);

  TIM1->CTLR1 = 0;
  TIM1->PSC = 191;                  // 48 MHz / 192 = 250 kHz tick -> 976.6 Hz PWM
  TIM1->ATRLR = SPINDLE_PWM_MAX_VALUE;
  TIM1->CHCTLR1 = TIM_CHCTLR1_OC1M_PWM1 | TIM_CHCTLR1_OC1PE;
  TIM1->CCER = 0;                   // channel disconnected until PWM_ENABLE()
  TIM1->BDTR = TIM_BDTR_MOE;        // master output enable (advanced timer)
  TIM1->CH1CVR = 0;
  TIM1->SWEVGR = TIM_SWEVGR_UG;     // latch preloads
  TIM1->CTLR1 = TIM_CTLR1_CEN;
}

// DELAYS (Step 6; CONTRACTS.md #13 "closed" note - empty stubs are the
// canonical silent killer of homing debounce / spindle ramp)
/*
  Calibrated busy-wait, samd21/platform.c pattern (counted inline-asm
  loop: correct from reset onward, no peripheral state, times identically
  at -O0 and -Os). The STK is NOT usable here - it is the pulse-reset
  timer (this port's equivalent of "SysTick is taken").

  Cycle assumption: addi(1) + taken bnez(2) = 3 cycles/iteration on the
  QingKe V2C 2-stage pipeline. UNVERIFIED against silicon (no per-
  instruction cycle table in the public RM; flash wait states can stretch
  it) - delays err LONG, never short, which is the safe direction for
  debounce/dwell. Hardware-validation item, flagged in CONTRACTS.md #14.
*/
#define DELAY_LOOP_CYCLES        3u
#define DELAY_LOOP_ITERS_PER_US  (F_CPU / (DELAY_LOOP_CYCLES * 1000000uL))  // 16 @ 48 MHz

static void delay_busy_loop(uint32_t iterations) {
  if (iterations == 0) { return; }
  __asm volatile (
    "1: addi %0, %0, -1 \n"
    "   bnez %0, 1b     \n"
    : "+r" (iterations)
  );
}

// Float-typed worker: everything past the ABI boundary is single precision.
// samd21/platform.c pattern (CONTRACTS.md #17) - narrowing at the entry
// point is NECESSARY but NOT SUFFICIENT: the sub-ms remainder below was
// originally computed in double (`__ms - (double)ms`, `rem * 1000.0`)
// *behind* an already-narrowed `(uint32_t)__us` cast, which relinked
// __adddf3/__subdf3/__muldf3 and their DP libm neighbors under
// FP=SINGLE even though every call site "looked" narrowed. Keeping the
// whole worker in float, with exactly ONE double->float narrowing at
// each public entry point, is what tools/assert_no_double.sh enforces.
static void delay_us_f(float us) {
  uint32_t n = (uint32_t)us;     // truncates, SP->int
  if (n) { delay_busy_loop(n * DELAY_LOOP_ITERS_PER_US); }
}

void _delay_us(double __us) {
  delay_us_f((float)__us);       // the ONE narrowing
}

void _delay_ms(double __ms) {
  float    ms_f = (float)__ms;   // the ONE narrowing
  uint32_t ms   = (uint32_t)ms_f;

  for (uint32_t i = ms; i != 0; i--) {
    delay_busy_loop(1000u * DELAY_LOOP_ITERS_PER_US);
  }

  // Sub-1ms remainder: stays in float - see comment above delay_us_f().
  float rem = ms_f - (float)ms;
  if (rem > 0.0f) { delay_us_f(rem * 1000.0f); }
}
