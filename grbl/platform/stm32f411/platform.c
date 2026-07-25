/*
  platform.c - STM32F411 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  STM32F411CEU6 ("Black Pill"): 96MHz Cortex-M4F, 128KB RAM, 512KB Flash.
  GPIO/clock code ported from stm32h523/platform.c (same MODER/OTYPER/PUPDR
  model - CONTRACTS.md notes this is F4-style, and H5 kept it); EXTI/SYSCFG
  wiring reverts to stm32f103's single-PR-register model (F4 does NOT have
  H5's RPR1/FPR1 split); USART uses the classic SR/DR register pair (F4 is
  NOT H5's ISR/RDR/TDR - see regs.h and platform.h HAL_SERIAL_* comments).
*/

#include "../hal.h"
#include "platform.h"
#include "config.h"
#include "../common/stm32/stm32_timing.h"
#include "../common/stm32/stm32_nvmem.h"
#include "../common/stm32/stm32_watchdog.h"

// ============================================================================
// PLATFORM CONFIGURATION INSTANCE
// ============================================================================

const stm32_platform_config_t stm32_config = {
  .cpu_freq               = STM32F411_CPU_FREQ,
  .apb1_freq              = STM32F411_APB1_FREQ,
  .apb2_freq              = STM32F411_APB2_FREQ,

  .flash_page_size        = STM32F411_FLASH_PAGE_SIZE,
  .flash_base_addr        = STM32F411_FLASH_BASE_ADDR,
  .flash_num_pages        = STM32F411_FLASH_NUM_PAGES,

  .ram_size               = STM32F411_RAM_SIZE,
  .flash_size             = STM32F411_FLASH_SIZE,

  .has_fpu                = STM32F411_HAS_FPU,
  .has_32bit_timers       = STM32F411_HAS_32BIT_TIMERS,
  .gpio_model             = STM32F411_GPIO_MODEL,
};

// ============================================================================
// CLOCK CONFIGURATION (HSE 25MHz -> PLL -> 96MHz, Black Pill crystal)
// ============================================================================
// PLLM=25, PLLN=192, PLLP=/2, PLLSRC=HSE: VCO_in = 25/25 = 1MHz (within the
// 1-2MHz recommended range for jitter), VCO_out = 1MHz*192 = 192MHz (within
// the 192-432MHz valid VCO range), SYSCLK = 192/2 = 96MHz. This is the
// widely-used stock configuration for the 25MHz-HSE Black Pill (also yields
// 48MHz on PLLQ=4 for USB, not wired up by this port but left correct in
// case a future USB CDC port wants it).
void hal_clock_config(void) {
  // 1. Enable HSE and wait for ready.
  RCC->CR |= RCC_CR_HSEON;
  while (!(RCC->CR & RCC_CR_HSERDY));

  // 2. Flash latency BEFORE raising the clock (Step 1 "F_CPU lie" contract:
  // 96MHz at 2.7-3.6V needs 3 wait states, RM0383 Table 15). Enable
  // prefetch/I-cache/D-cache too (standard F4 practice, harmless on debug
  // builds and helps release-build step timing headroom).
  FLASH->ACR = FLASH_ACR_LATENCY_3WS | FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN;

  // 3. Configure and enable PLL1 (must be OFF while reconfiguring PLLCFGR).
  RCC->CR &= ~RCC_CR_PLLON;
  while (RCC->CR & RCC_CR_PLLRDY);

  RCC->PLLCFGR = (25UL << RCC_PLLCFGR_PLLM_Pos)   // PLLM = 25
               | (192UL << RCC_PLLCFGR_PLLN_Pos)  // PLLN = 192
               | (0UL << RCC_PLLCFGR_PLLP_Pos)    // PLLP = /2 (00b)
               | RCC_PLLCFGR_PLLSRC_HSE           // PLL source = HSE
               | (4UL << RCC_PLLCFGR_PLLQ_Pos);   // PLLQ = 4 (48MHz USB, unused)

  RCC->CR |= RCC_CR_PLLON;
  while (!(RCC->CR & RCC_CR_PLLRDY));

  // 4. Bus prescalers: AHB /1 (explicit - the ch32v006 HPRE lesson,
  // CONTRACTS.md section 14.9, is "clear the prescaler explicitly, never
  // assume the reset default is /1 without checking"; F4's RCC_CFGR reset
  // value for HPRE genuinely IS 0000=/1 per RM0383, but this line makes that
  // fact load-bearing instead of implicit). APB1 /2 (APB1 max is 50MHz;
  // 96/2=48MHz), APB2 /1 (APB2 max is 100MHz; 96/1=96MHz).
  RCC->CFGR = (RCC->CFGR & ~(0xFUL << RCC_CFGR_HPRE_Pos)) | (RCC_CFGR_HPRE_DIV1 << 0);
  RCC->CFGR = (RCC->CFGR & ~(0x7UL << RCC_CFGR_PPRE1_Pos)) | (RCC_CFGR_PPRE_DIV2 << RCC_CFGR_PPRE1_Pos);
  RCC->CFGR = (RCC->CFGR & ~(0x7UL << RCC_CFGR_PPRE2_Pos)) | (RCC_CFGR_PPRE_DIV1 << RCC_CFGR_PPRE2_Pos);

  // 5. Switch SYSCLK to PLL and wait for the switch to land.
  RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW_Msk) | RCC_CFGR_SW_PLL;
  while ((RCC->CFGR & RCC_CFGR_SWS_Msk) != RCC_CFGR_SWS_PLL);
}

// ============================================================================
// GPIO FUNCTIONS (F4 uses MODER/OTYPER model, same shape as H5)
// ============================================================================

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      port->MODER &= ~(0x3UL << (pin * 2));
      port->MODER |= (0x1UL << (pin * 2));   // Output mode (01)

      port->OTYPER &= ~(1UL << pin);         // Push-pull (0)

      port->OSPEEDR &= ~(0x3UL << (pin * 2));
      port->OSPEEDR |= (0x2UL << (pin * 2)); // High speed (10)
    }
  }
}

void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      port->MODER &= ~(0x3UL << (pin * 2));  // Input mode (00)
      port->PUPDR &= ~(0x3UL << (pin * 2));  // No pull
    }
  }
}

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      port->MODER &= ~(0x3UL << (pin * 2));  // Input mode
      port->PUPDR &= ~(0x3UL << (pin * 2));
      port->PUPDR |= (0x1UL << (pin * 2));   // Pull-up (01)
    }
  }
}

void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask) {
  hal_gpio_set_input(port, mask);
}

// Configure a single pin for an alternate function (MODER=0b10 + AFR
// nibble). Used by hal_timer_spindle_pwm_init() (PA8/TIM1_CH1, AF1) and
// hal_serial_init() (PA9/PA10 USART1, AF7).
static void hal_gpio_set_af(GPIO_TypeDef* port, uint8_t pin, uint8_t af) {
  port->MODER &= ~(0x3UL << (pin * 2));
  port->MODER |= (0x2UL << (pin * 2));          // Alternate function mode (10)

  uint8_t reg_idx = pin / 8;                    // AFR[0]=AFRL (pins 0-7), AFR[1]=AFRH (pins 8-15)
  uint8_t shift = (pin % 8) * 4;
  port->AFR[reg_idx] &= ~(0xFUL << shift);
  port->AFR[reg_idx] |= ((uint32_t)af << shift);
}

// EXTI/SYSCFG wiring: F4 keeps the classic single-pending-register EXTI
// model (PR, write-1-to-clear) - unlike stm32h523's RPR1/FPR1 split, which
// is H5-specific. This function (and handlers.c's dispatch) follows
// stm32f103/platform.c's shape instead of stm32h523's.
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;

  uint32_t port_code = SYSCFG_EXTICR_PA;
  if (port == GPIOB) port_code = SYSCFG_EXTICR_PB;
  else if (port == GPIOC) port_code = SYSCFG_EXTICR_PC;

  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      uint8_t reg_idx = pin / 4;
      uint8_t bit_pos = (pin % 4) * 4;

      SYSCFG->EXTICR[reg_idx] &= ~(0xFUL << bit_pos);
      SYSCFG->EXTICR[reg_idx] |= (port_code << bit_pos);

      EXTI->IMR |= (1UL << pin);   // Unmask interrupt
      EXTI->RTSR |= (1UL << pin);  // Rising edge
      EXTI->FTSR |= (1UL << pin);  // Falling edge (core treats any change as trigger, CONTRACTS.md section 2.6)

      if (pin <= 4) {
        NVIC_EnableIRQ((IRQn_Type)(EXTI0_IRQn + pin));
      } else if (pin <= 9) {
        NVIC_EnableIRQ(EXTI9_5_IRQn);
      } else {
        NVIC_EnableIRQ(EXTI15_10_IRQn);
      }
    }
  }
}

void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask) {
  (void)port;
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1UL << pin)) {
      EXTI->IMR &= ~(1UL << pin);
    }
  }
}

void hal_gpio_init(void) {
  RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN | RCC_AHB1ENR_GPIOBEN | RCC_AHB1ENR_GPIOCEN;
  __NOP(); __NOP(); __NOP();

  // Step/direction/stepper-enable (PA0-6) as outputs
  hal_gpio_set_output(GPIOA, STEP_MASK | DIRECTION_MASK | STEPPERS_DISABLE_MASK);
  HAL_GPIO_SET_BITS(GPIOA, STEPPERS_DISABLE_MASK);  // Disable steppers initially (active LOW)

  // Limit switches (PB0, PB1, PB10) as inputs with pull-up
  hal_gpio_pullup_enable(GPIOB, LIMIT_MASK);

  // Control pins (PB3-6) as inputs with pull-up
  hal_gpio_pullup_enable(GPIOB, CONTROL_MASK);

  // Spindle enable/direction (PB12, PB13) as outputs
  hal_gpio_set_output(GPIOB, (1UL << SPINDLE_ENABLE_PIN) | (1UL << SPINDLE_DIRECTION_PIN));
  HAL_GPIO_CLEAR_BITS(GPIOB, (1UL << SPINDLE_ENABLE_PIN) | (1UL << SPINDLE_DIRECTION_PIN));

  // PA8 (spindle PWM, TIM1_CH1): route to TIM1 alternate function AF1.
  // hal_timer_spindle_pwm_init() does not touch GPIO mode - see timer.h note.
  hal_gpio_set_af(GPIOA, 8, 1);

  // Coolant (PC13, PC14) as outputs
  hal_gpio_set_output(GPIOC, (1UL << COOLANT_FLOOD_PIN));
#ifdef ENABLE_M7
  hal_gpio_set_output(GPIOC, (1UL << COOLANT_MIST_PIN));
#endif
  HAL_GPIO_CLEAR_BITS(GPIOC, (1UL << COOLANT_FLOOD_PIN));

  // Probe (PC15) as input with pull-up
  hal_gpio_pullup_enable(GPIOC, PROBE_MASK);
}

// ============================================================================
// TIMER FUNCTIONS (contract macros: timer.h - STP_TMR_*/STP_PULSE_RESET_*/PWM_*)
// ============================================================================

void hal_timer_stepper_init(void) {
  RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;

  TIM2->CR1 = 0;
  TIM2->PSC = 0;                    // No prescaler (STP_TMR_INIT + PRESCALER_RESET => running, /1)
  TIM2->ARR = 0xFFFFFFFFUL;         // Max period (32-bit)
  TIM2->DIER = 0;                   // Interrupt masked at INIT time (CONTRACTS.md section 3) -
                                    // STP_TMR_INT_ENA() unmasks it later from st_wake_up()
  TIM2->CR1 = TIM_CR1_CEN;          // Enable counter, running at /1, interrupt masked

  NVIC_EnableIRQ(TIM2_IRQn);
  NVIC_SetPriority(TIM2_IRQn, 1);
}

void hal_timer_pulse_reset_init(void) {
  RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;

  TIM3->CR1 = 0;                    // STOPPED (STP_PULSE_RESET_START() starts it - CONTRACTS.md section 4)
  TIM3->PSC = 0;
  TIM3->DIER = TIM_DIER_UIE;

  NVIC_EnableIRQ(TIM3_IRQn);
  NVIC_SetPriority(TIM3_IRQn, 0);   // Pulse-reset IRQ priority >= stepper (numerically <=, i.e. higher
                                    // preemption priority than TIM2's 1) - CONTRACTS.md section 5.2/12.7
}

// Spindle PWM timer initialization (TIM1, advanced-control timer - needs
// BDTR.MOE, see timer.h/regs.h notes)
void hal_timer_spindle_pwm_init(void) {
  RCC->APB2ENR |= RCC_APB2ENR_TIM1EN;

  TIM1->CR1 = 0;
  TIM1->PSC = 0;
  TIM1->ARR = SPINDLE_PWM_MAX_VALUE;

  TIM1->CCMR1 = (6UL << 4) | TIM_CCMR1_OC1PE;  // PWM mode 1, preload enable
  TIM1->CCER = 0;                   // Channel disabled initially
  TIM1->BDTR = TIM_BDTR_MOE;        // Main output enable (required for TIM1's OCx pins)
  TIM1->CCR1 = 0;                   // 0% duty cycle

  TIM1->CR1 = TIM_CR1_CEN;
}

// ============================================================================
// SERIAL/UART FUNCTIONS (F4 classic SR/DR model)
// ============================================================================

void hal_serial_init(uint32_t baud_rate) {
  RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

  // PA9 (TX) / PA10 (RX) as USART1 alternate function (AF7, standard across
  // F1/F4/H5 GPIO AF tables for USART1/2/3).
  hal_gpio_set_af(GPIOA, 9, 7);
  hal_gpio_set_af(GPIOA, 10, 7);

  // Baud divisor: USART1 is on APB2, 96MHz per config.h/hal_clock_config.
  uint32_t div = (stm32_config.apb2_freq + (baud_rate / 2)) / baud_rate;

  USART1->BRR = div;
  USART1->CR1 = USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;
  USART1->CR1 |= USART_CR1_UE;

  NVIC_EnableIRQ(USART1_IRQn);
  NVIC_SetPriority(USART1_IRQn, 3);  // Serial must not starve the stepper pair (CONTRACTS.md section 12.7)
}

// Forward declarations for serial ISR helpers (defined in serial.c via the
// HAL_SERIAL_RX_ISR/TX_ISR macro-route, platform.h)
extern void stm32_usart1_rx_handler(void);
extern void stm32_usart1_tx_handler(void);

// USART1 interrupt handler - dispatches to RX/TX handlers based on SR flags
// (F4: classic SR, not H5's ISR).
void USART1_IRQHandler(void) {
  if (USART1->SR & USART_SR_RXNE) {
    stm32_usart1_rx_handler();
  }
  if (USART1->SR & USART_SR_TXE) {
    stm32_usart1_tx_handler();
  }
}

// ============================================================================
// SYSTEM TIMING (thin wrappers over common/stm32/stm32_timing.c)
// ============================================================================

void SysTick_Handler(void) {
  stm32_systick_handler();
}

uint32_t hal_millis(void) {
  return stm32_millis();
}

uint64_t hal_micros(void) {
  return stm32_micros();
}

void hal_delay_ms(uint32_t ms) {
  stm32_delay_ms(ms);
}

void hal_delay_us(uint32_t us) {
  stm32_delay_us(us);
}

// AVR compatibility - _delay_ms wrapper (nuts_bolts.c calls this directly,
// bypassing the HAL_DELAY_MS macro, same as f103/h523 platform.c)
void _delay_ms(double ms) {
  hal_delay_ms((uint32_t)ms);
}

// ============================================================================
// NVMEM (thin wrappers over common/stm32/stm32_nvmem.c - link-level API
// expected by platform.h's eeprom_get_char/put_char macros, CONTRACTS.md
// section 10)
// ============================================================================

unsigned char hal_nvmem_read_byte(unsigned int addr) {
  uint8_t data = 0xFF;
  stm32_nvmem_read_byte((uint32_t)addr, &data);
  return data;
}

void hal_nvmem_write_byte(unsigned int addr, unsigned char data) {
  stm32_nvmem_write_byte((uint32_t)addr, data);
}

void hal_nvmem_flush(void) {
  stm32_nvmem_flush();
}

void hal_nvmem_init(void) {
  stm32_nvmem_init();
}

// ============================================================================
// WATCHDOG (thin wrapper - stm32_watchdog.c is 100% shared, CONTRACTS.md
// section 9: not a core contract macro family here, opt-in via -DENABLE_WATCHDOG)
// ============================================================================

void hal_watchdog_refresh(void) {
  stm32_watchdog_refresh();
}

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

void hal_system_init(void) {
  hal_clock_config();

  stm32_timing_init();

#ifdef ENABLE_WATCHDOG
  stm32_watchdog_init(1600);  // 1.6s timeout
#endif

  hal_gpio_init();

  stm32_nvmem_init();
}
