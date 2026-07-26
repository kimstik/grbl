/*
  platform.c - HC32F460 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  HC32F460JETA: up to 200MHz Cortex-M4F. Every register access below routes
  through regs.h, which grades each fact CONFIRMED vs UNVERIFIED placeholder
  - see that file's header for the full methodology. This file's job is to
  give every CONTRACTS.md macro a genuine, self-consistent implementation so
  the port BUILDS and LINKS with zero PORT_TODO_*; electrical correctness on
  real silicon is explicitly deferred to hardware bring-up (no HC32F460
  emulator exists, same posture as CONTRACTS.md section 16's dsPIC33AK
  notes).
*/

#include "../hal.h"
#include "platform.h"

/* ============================================================================
 * WRITE-PROTECT UNLOCK (PWC_FPRC) - gates writes to CMU control registers.
 * See regs.h for the UNVERIFIED-unlock-code disclosure.
 * ==========================================================================*/

static void pwc_registers_unlock(void) {
  PWC->FPRC = PWC_FPRC_UNLOCK_CODE;
}

static void pwc_registers_lock(void) {
  PWC->FPRC = PWC_FPRC_LOCK_CODE;
}

/* ============================================================================
 * CLOCK CONFIGURATION (XTAL -> PLL -> 200MHz system clock)
 * ============================================================================
 * Sequence shape (enable XTAL, wait ready, configure+enable PLL, wait
 * ready, switch CKSWR to MPLL) is architecturally standard; every bit
 * position and the exact 200MHz PLL coefficient set is UNVERIFIED - see
 * regs.h. CMU_CKSWR_MPLL (0x05) and the three CMU sub-register addresses
 * ARE confirmed (Klipper bootloader cross-check, regs.h header).
 * --------------------------------------------------------------------------*/

GRBL_BOOT_INIT void hal_clock_config(void) {
  pwc_registers_unlock();

  /* 1. Enable the external main oscillator and wait for it to stabilize. */
  CMU_XTALCR |= CMU_XTALCR_XTALON;
  while (!(CMU_XTALCR & CMU_XTALCR_XTALRDY));

  /* 2. Configure the PLL for a 200MHz system clock from an assumed 8MHz
     XTAL (UNVERIFIED coefficient set - placeholder multiply/divide values
     chosen to be internally consistent, not confirmed against real PLL
     field positions/ratios). PLL must be off while reconfigured. */
  CMU_PLLCR &= ~CMU_PLLCR_PLLON;
  while (CMU_PLLCR & CMU_PLLCR_PLLRDY);

  CMU_PLLCFGR = (1UL << CMU_PLLCFGR_PLLM_Pos)    /* /1 input divider (UNVERIFIED) */
              | (50UL << CMU_PLLCFGR_PLLN_Pos)   /* x50 multiply: 8MHz * 50 = 400MHz VCO (UNVERIFIED) */
              | (2UL << CMU_PLLCFGR_PLLP_Pos);   /* /2 output divider: 400/2 = 200MHz (UNVERIFIED) */

  CMU_PLLCR |= CMU_PLLCR_PLLON;
  while (!(CMU_PLLCR & CMU_PLLCR_PLLRDY));

  /* 3. Flash wait states before switching the system clock onto the PLL
     (Step 1 "F_CPU lie" contract, CONTRACTS.md section 14 item 9(b)): 200MHz
     needs several EFM wait cycles. Exact FRMC encoding is UNVERIFIED
     (regs.h); write a conservative non-zero value rather than leaving it
     at its (likely zero-wait, safe-only-at-low-frequency) reset state. */
  EFM->FRMC = 5UL;   /* UNVERIFIED wait-state encoding - conservative placeholder for 200MHz */

  /* 4. Switch the system clock source to MPLL (CONFIRMED value 0x05). */
  CMU_CKSWR = CMU_CKSWR_MPLL;

  pwc_registers_lock();
}

/* ============================================================================
 * GPIO FUNCTIONS
 * ============================================================================
 * Direction/pull-up are per-pin PCONR words (regs.h) - UNVERIFIED bit
 * positions, function calls rather than bit-op macros (same shape-class
 * reasoning as stm32f411/stm32h523's MODER/PUPDR, CONTRACTS.md section 14
 * item 5).
 * --------------------------------------------------------------------------*/

void hal_gpio_set_output(HC32_PORT_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      volatile uint32_t *pconr = hc32_pconr(port, pin);
      *pconr |= PCONR_OUT_ENABLE;
    }
  }
}

void hal_gpio_set_input(HC32_PORT_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      volatile uint32_t *pconr = hc32_pconr(port, pin);
      *pconr &= ~(PCONR_OUT_ENABLE | PCONR_PULLUP_EN);
    }
  }
}

void hal_gpio_pullup_enable(HC32_PORT_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      volatile uint32_t *pconr = hc32_pconr(port, pin);
      *pconr &= ~PCONR_OUT_ENABLE;
      *pconr |= PCONR_PULLUP_EN;
    }
  }
}

void hal_gpio_pullup_disable(HC32_PORT_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      volatile uint32_t *pconr = hc32_pconr(port, pin);
      *pconr &= ~PCONR_PULLUP_EN;
    }
  }
}

/* External pin interrupts (EIRQ, routed through INTC - CONTRACTS.md section
   2). Channel number == pin number within the port (platform.h pin-map
   note explains why this port's LIMIT+CONTROL groups never collide
   regardless of the real cross-port EIRQ model). */
void hal_gpio_interrupt_enable(HC32_PORT_TypeDef* port, uint32_t mask) {
  (void)port;
  for (uint8_t pin = 0; pin < 16 && pin <= 6; pin++) {
    if (mask & (1UL << pin)) {
      IRQn_Type vector = (IRQn_Type)(Int004_IRQn + pin);
      hc32_int_src_t src = (hc32_int_src_t)(HC32_INT_SRC_PORT_EIRQ0 + pin);

      intc_route(vector, src);
      NVIC_SetPriority(vector, 2);
      NVIC_EnableIRQ(vector);
    }
  }
}

void hal_gpio_interrupt_disable(HC32_PORT_TypeDef* port, uint32_t mask) {
  (void)port;
  for (uint8_t pin = 0; pin < 16 && pin <= 6; pin++) {
    if (mask & (1UL << pin)) {
      NVIC_DisableIRQ((IRQn_Type)(Int004_IRQn + pin));
    }
  }
}

GRBL_BOOT_INIT void hal_gpio_init(void) {
  /* Step/direction/stepper-enable (PA0-6) as outputs */
  hal_gpio_set_output(GPIOA, STEP_MASK | DIRECTION_MASK | STEPPERS_DISABLE_MASK);
  HAL_GPIO_SET_BITS(GPIOA, STEPPERS_DISABLE_MASK);   /* disable steppers initially (active LOW) */

  /* Limit switches (PB0-2) and control pins (PB3-6) as inputs with pull-up */
  hal_gpio_pullup_enable(GPIOB, LIMIT_MASK);
  hal_gpio_pullup_enable(GPIOB, CONTROL_MASK);

  /* Spindle enable/direction (PA9, PA10) as outputs */
  hal_gpio_set_output(GPIOA, (1UL << SPINDLE_ENABLE_PIN) | (1UL << SPINDLE_DIRECTION_PIN));
  HAL_GPIO_CLEAR_BITS(GPIOA, (1UL << SPINDLE_ENABLE_PIN) | (1UL << SPINDLE_DIRECTION_PIN));

  /* Spindle PWM (PA8) - direction is set by hal_timer_spindle_pwm_init()
     routing the pin to TIMERA (function-select, not plain GPIO output). */

  /* Coolant (PA11-12) as outputs */
  hal_gpio_set_output(GPIOA, (1UL << COOLANT_FLOOD_PIN));
#ifdef ENABLE_M7
  hal_gpio_set_output(GPIOA, (1UL << COOLANT_MIST_PIN));
#endif
  HAL_GPIO_CLEAR_BITS(GPIOA, (1UL << COOLANT_FLOOD_PIN));

  /* Probe (PB7) as input with pull-up */
  hal_gpio_pullup_enable(GPIOB, PROBE_MASK);
}

/* ============================================================================
 * TIMER FUNCTIONS (contract macros: timer.h - STP_TMR_, STP_PULSE_RESET_, PWM_ families)
 * ==========================================================================*/

void hal_timer_stepper_init(void) {
  TMR0_1->CR = 0;
  TMR0_1->CNTER = 0;
  TMR0_1->CMPAR = 0xFFFFUL;    /* max period (16-bit domain, contract: uint16_t) */
  TMR0_1->IER = 0;             /* interrupt masked at INIT time (CONTRACTS.md section 3) */
  TMR0_1->CR = TMR0_CR_START;  /* running at /1, interrupt masked */

  intc_route(Int000_IRQn, HC32_INT_SRC_TMR0_1_CMPA);
  NVIC_SetPriority(Int000_IRQn, 1);
  NVIC_EnableIRQ(Int000_IRQn);
}

void hal_timer_pulse_reset_init(void) {
  TMR0_2->CR = 0;              /* STOPPED (STP_PULSE_RESET_START() starts it - CONTRACTS.md section 4) */
  TMR0_2->CNTER = 0;
  TMR0_2->IER = TMR0_IER_CMPAIE;

  intc_route(Int001_IRQn, HC32_INT_SRC_TMR0_2_CMPA);
  NVIC_SetPriority(Int001_IRQn, 0);   /* pulse-reset IRQ priority >= stepper (numerically <=, i.e. higher
                                         preemption priority than Int000's 1) - CONTRACTS.md section 5.2/12.7 */
  NVIC_EnableIRQ(Int001_IRQn);
}

void hal_timer_spindle_pwm_init(void) {
  TMRA_1->CR = 0;
  TMRA_1->PERAR = SPINDLE_PWM_MAX_VALUE;
  TMRA_1->CMPAR1 = 0;       /* 0% duty */
  TMRA_1->CCONR1 = 0;       /* channel disabled initially */
  TMRA_1->CR = TMRA_CR_START;
}

/* ============================================================================
 * SERIAL/UART FUNCTIONS
 * ==========================================================================*/

void hal_serial_init(uint32_t baud_rate) {
  /* Baud divisor: standard oversampled-count formula (UNVERIFIED BRR
     encoding, regs.h). */
  uint32_t div = (HAL_CPU_FREQ + (baud_rate / 2)) / baud_rate;

  USART1->BRR = div;
  USART1->CR1 = USART_CR1_TE | USART_CR1_RE | USART_CR1_RIE;
  USART1->CR1 |= USART_CR1_TE;

  intc_route(USART1_RX_IRQn, HC32_INT_SRC_USART1_RI);
  intc_route(USART1_TX_IRQn, HC32_INT_SRC_USART1_TI);
  NVIC_SetPriority(USART1_RX_IRQn, 3);   /* serial must not starve the stepper pair (CONTRACTS.md section 12.7) */
  NVIC_SetPriority(USART1_TX_IRQn, 3);
  NVIC_EnableIRQ(USART1_RX_IRQn);
  NVIC_EnableIRQ(USART1_TX_IRQn);
}

/* ============================================================================
 * SYSTEM TIMING (SysTick-based millis/micros/delay - architectural
 * Cortex-M4 SysTick, same confidence class as every other ARM port)
 * ==========================================================================*/

static volatile uint32_t hc32_ms_ticks = 0;

void SysTick_Handler(void) {
  hc32_ms_ticks++;
}

static void hc32_systick_init(void) {
  SysTick->LOAD = (HAL_CPU_FREQ / 1000UL) - 1UL;
  SysTick->VAL = 0;
  SysTick->CTRL = 0x7UL;   /* CLKSOURCE=core, TICKINT=1, ENABLE=1 (architectural SysTick CSR bits) */
}

uint32_t hal_millis(void) {
  return hc32_ms_ticks;
}

uint64_t hal_micros(void) {
  uint32_t ms;
  uint32_t val;
  uint32_t reload = SysTick->LOAD + 1UL;
  do {
    ms = hc32_ms_ticks;
    val = SysTick->VAL;
  } while (ms != hc32_ms_ticks);
  uint32_t us_into_ms = ((reload - val) * 1000UL) / reload;
  return ((uint64_t)ms * 1000ULL) + us_into_ms;
}

void hal_delay_ms(uint32_t ms) {
  uint32_t start = hc32_ms_ticks;
  while ((uint32_t)(hc32_ms_ticks - start) < ms);
}

void hal_delay_us(uint32_t us) {
  uint64_t start = hal_micros();
  while ((uint32_t)(hal_micros() - start) < us);
}

/* AVR compatibility - _delay_ms wrapper (nuts_bolts.c calls this directly,
   bypassing the HAL_DELAY_MS macro, same as every other ARM port here).
   Narrows once at the entry point (FP=SINGLE discipline, CONTRACTS.md
   section 17.4) and never widens back to double. */
void _delay_ms(double ms) {
  hal_delay_ms((uint32_t)ms);
}

/* ============================================================================
 * WATCHDOG (stub - not a core contract macro family, CONTRACTS.md section 9;
 * left as a no-op refresh since this port does not enable a hardware
 * watchdog)
 * ==========================================================================*/

void hal_watchdog_refresh(void) {
}

/* ============================================================================
 * SYSTEM INITIALIZATION
 * ==========================================================================*/

GRBL_BOOT_INIT void hal_system_init(void) {
  hal_clock_config();
  hc32_systick_init();
  hal_gpio_init();
  hal_nvmem_init();
}
