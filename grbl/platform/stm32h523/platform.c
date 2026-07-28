/*
  platform.c - STM32H523 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include "../hal.h"
#include "platform.h"
#include "config.h"
#include "../common/stm32/stm32_timing.h"
#include "../common/stm32/stm32_nvmem.h"
#include "../common/stm32/stm32_watchdog.h"

// PLATFORM CONFIGURATION INSTANCE

const stm32_platform_config_t stm32_config = {
  // Clock configuration
  .cpu_freq               = STM32H523_CPU_FREQ,
  .apb1_freq              = STM32H523_APB1_FREQ,
  .apb2_freq              = STM32H523_APB2_FREQ,

  // Flash parameters
  .flash_page_size        = STM32H523_FLASH_PAGE_SIZE,
  .flash_base_addr        = STM32H523_FLASH_BASE_ADDR,
  .flash_num_pages        = STM32H523_FLASH_NUM_PAGES,

  // Memory sizes
  .ram_size               = STM32H523_RAM_SIZE,
  .flash_size             = STM32H523_FLASH_SIZE,

  // Hardware capabilities
  .has_fpu                = STM32H523_HAS_FPU,
  .has_32bit_timers       = STM32H523_HAS_32BIT_TIMERS,
  .gpio_model             = STM32H523_GPIO_MODEL,
};

// Ratchet for BUG #20: stm32_nvmem.c's static cache buffer is sized from
// NVMEM_WINDOW_SIZE (Makefile define, defaults to 4096 - see stm32_nvmem.h).
// If this platform's actual flash window ever grows past whatever
// NVMEM_WINDOW_SIZE the Makefile supplies, fail the build instead of letting
// stm32_nvmem_init() silently reject the write and every setting read back
// as 0xFF at runtime.
_Static_assert(STM32H523_FLASH_PAGE_SIZE * STM32H523_FLASH_NUM_PAGES <= NVMEM_WINDOW_SIZE,
               "STM32H523 NVMEM window exceeds stm32_nvmem.c cache buffer (NVMEM_WINDOW_SIZE) - BUG #20 class");

// CLOCK CONFIGURATION (250 MHz from HSE 8MHz)

GRBL_BOOT_INIT void hal_clock_config(void) {
  // STM32H523 Clock Configuration: HSE 8MHz → PLL → 250MHz CPU
  // Target clocks:
  // - CPU: 250 MHz (from PLL1)
  // - APB1/2/3: 125 MHz (CPU/2)
  // - Flash latency: 5 wait states @ 250MHz
  //
  // PLL1 configuration:
  // - Input: HSE 8 MHz
  // - VCO input (after /M): 8 MHz (M=1, range: 4-16 MHz recommended)
  // - VCO output (×N): 500 MHz (N=62.5, but must be integer, use N=125)
  //   Actual: 8 MHz / 1 * 125 = 1000 MHz VCO (valid range: 192-836 MHz for H5)
  //   Wait, that's too high. Let's recalculate:
  //   Target: 250 MHz output
  //   VCO range: 192-836 MHz (wide range VCO for H5)
  //   Let's use: VCO = 500 MHz, then divide by 2 to get 250 MHz
  //   Formula: Fvco = (Fin / M) * N
  //   500 = (8 / M) * N
  //   If M=2: N=125, Fvco=500MHz, CPU=500/2=250MHz ✓
  //
  // PLL dividers:
  //   M=2 (VCO input = 4 MHz)
  //   N=125 (VCO freq = 500 MHz)
  //   P=2 (CPU freq = 250 MHz)

  // 1. Enable HSE oscillator and wait for ready
  RCC->CR |= RCC_CR_HSEON;
  while (!(RCC->CR & RCC_CR_HSERDY));

  // 2. Configure flash latency BEFORE increasing frequency
  // STM32H5 at 250MHz requires 5 wait states (from datasheet)
  // FLASH->ACR latency field is bits [2:0]
  FLASH->ACR = (FLASH->ACR & ~0x7) | 5;  // 5 wait states

  // 3. Configure PLL1
  // First, disable PLL1
  RCC->CR &= ~RCC_CR_PLL1ON;
  while (RCC->CR & RCC_CR_PLL1RDY);  // Wait until PLL1 is disabled

  // PLL1 source = HSE
  // PLL1CFGR register layout for H5 (check reference manual):
  // Bits [1:0]: PLL1SRC (00=none, 01=HSI, 10=CSI, 11=HSE)
  // Bits [5:2]: PLL1M divider (value 0-63, actual divider = value)
  //             For M=2, write value 1 (divider = value+1)
  // Bit 16: PLL1REN (R output enable)
  // Bit 17: PLL1QEN (Q output enable)
  // Bit 18: PLL1PEN (P output enable - this is what we need for CPU)

  // Set PLL1 source to HSE (11b), M=2 (value 1)
  RCC->PLL1CFGR = (3 << 0) |   // PLL1SRC = HSE
                  (1 << 2) |   // PLL1M = 2 (value = M-1 = 1)
                  (1 << 18);   // PLL1PEN = enable P output

  // Configure PLL1 dividers N and P
  // PLL1DIVR register layout:
  // Bits [8:0]: PLL1N (multiply factor, value 4-512, actual = value)
  // Bits [20:16]: PLL1P (P divider, value 1-128, actual = value)
  // For N=125 (multiply by 125): write 124 (value = N-1)
  // For P=2 (divide by 2): write 1 (value = P-1)
  RCC->PLL1DIVR = (124 << 0) |  // PLL1N = 125 (value = 124)
                  (1 << 16);     // PLL1P = 2 (value = 1)

  // 4. Enable PLL1 and wait for lock
  RCC->CR |= RCC_CR_PLL1ON;
  while (!(RCC->CR & RCC_CR_PLL1RDY));

  // 5. Configure APB prescalers (divide by 2 to get 125 MHz from 250 MHz)
  // CFGR2 register contains APB prescalers
  // Bits [6:4]: PPRE1 (APB1 prescaler)
  // Bits [10:8]: PPRE2 (APB2 prescaler)
  // Bits [14:12]: PPRE3 (APB3 prescaler)
  // Value 100b = divide by 2
  RCC->CFGR2 = (4 << 4) |   // PPRE1 = /2
               (4 << 8) |   // PPRE2 = /2
               (4 << 12);   // PPRE3 = /2

  // 6. Switch system clock to PLL1
  // CFGR1 register bits [1:0] = SW (system clock switch)
  // 00 = HSI, 01 = CSI, 10 = HSE, 11 = PLL1
  RCC->CFGR1 = (RCC->CFGR1 & ~0x3) | 3;  // SW = PLL1

  // Wait for clock switch to complete
  // SWS field (bits [3:2]) should match SW
  while ((RCC->CFGR1 & (3 << 2)) != (3 << 2));

  // Clock configuration complete
  // CPU now running at 250 MHz, APB1/2/3 at 125 MHz

  // Configure SysTick for 1ms interrupts
  // Will be done by stm32_timing_init()
}

// GPIO FUNCTIONS (H5 uses MODER/OTYPER model like F4)

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask) {
  // H5 uses MODER register (2 bits per pin)
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Set mode to output (01)
      port->MODER &= ~(0x3 << (pin * 2));
      port->MODER |= (0x1 << (pin * 2));

      // Set output type to push-pull (0)
      port->OTYPER &= ~(1 << pin);

      // Set speed to high (10)
      port->OSPEEDR &= ~(0x3 << (pin * 2));
      port->OSPEEDR |= (0x2 << (pin * 2));
    }
  }
}

void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Set mode to input (00)
      port->MODER &= ~(0x3 << (pin * 2));

      // No pull-up/pull-down (00)
      port->PUPDR &= ~(0x3 << (pin * 2));
    }
  }
}

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Set mode to input
      port->MODER &= ~(0x3 << (pin * 2));

      // Enable pull-up (01)
      port->PUPDR &= ~(0x3 << (pin * 2));
      port->PUPDR |= (0x1 << (pin * 2));
    }
  }
}

void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask) {
  hal_gpio_set_input(port, mask);
}

// Configure a single pin for an alternate function (MODER=0b10 + AFR nibble).
// H5's MODER/AFR model has no single-pin AF helper of its own (unlike F1's
// gpio_config_pin(port, pin, 0xB) which f103 uses for the same purpose) -
// used by hal_timer_spindle_pwm_init() (PA8/TIM1_CH1, AF1) and
// hal_serial_init() (PA9/PA10 USART1, AF7).
static void hal_gpio_set_af(GPIO_TypeDef* port, uint8_t pin, uint8_t af) {
  port->MODER &= ~(0x3u << (pin * 2));
  port->MODER |= (0x2u << (pin * 2));          // Alternate function mode (10)

  uint8_t reg_idx = pin / 8;                    // AFR[0]=AFRL (pins 0-7), AFR[1]=AFRH (pins 8-15)
  uint8_t shift = (pin % 8) * 4;
  port->AFR[reg_idx] &= ~(0xFu << shift);
  port->AFR[reg_idx] |= ((uint32_t)af << shift);
}

void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  // Enable SYSCFG clock (needed for EXTI configuration)
  RCC->APB3ENR |= RCC_APB3ENR_SYSCFGEN;

  // Determine port code for SYSCFG
  uint32_t port_code = SYSCFG_EXTICR_PA;
  if (port == GPIOB) port_code = SYSCFG_EXTICR_PB;
  else if (port == GPIOC) port_code = SYSCFG_EXTICR_PC;

  // Configure each pin in the mask
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Map GPIO pin to EXTI line using SYSCFG
      uint8_t reg_idx = pin / 4;           // Which EXTICR register (0-3)
      uint8_t field_pos = (pin % 4) * 4;   // Position within register (0, 4, 8, 12)

      SYSCFG->EXTICR[reg_idx] &= ~(0xF << field_pos);     // Clear field
      SYSCFG->EXTICR[reg_idx] |= (port_code << field_pos); // Set port code

      // Configure EXTI for falling edge trigger (limit switches and buttons)
      EXTI->FTSR1 |= (1 << pin);  // Falling edge trigger
      EXTI->RTSR1 &= ~(1 << pin); // Disable rising edge trigger

      // Unmask the EXTI line
      EXTI->IMR1 |= (1 << pin);

      // Enable NVIC interrupt for this EXTI line
      IRQn_Type irqn;
      switch (pin) {
        case 0:  irqn = EXTI0_IRQn; break;
        case 1:  irqn = EXTI1_IRQn; break;
        case 2:  irqn = EXTI2_IRQn; break;
        case 3:  irqn = EXTI3_IRQn; break;
        case 4:  irqn = EXTI4_IRQn; break;
        case 5:  irqn = EXTI5_IRQn; break;
        case 6:  irqn = EXTI6_IRQn; break;
        case 7:  irqn = EXTI7_IRQn; break;
        case 8:  irqn = EXTI8_IRQn; break;
        case 9:  irqn = EXTI9_IRQn; break;
        case 10: irqn = EXTI10_IRQn; break;
        case 11: irqn = EXTI11_IRQn; break;
        case 12: irqn = EXTI12_IRQn; break;
        case 13: irqn = EXTI13_IRQn; break;
        case 14: irqn = EXTI14_IRQn; break;
        case 15: irqn = EXTI15_IRQn; break;
        default: continue;
      }
      NVIC_EnableIRQ(irqn);
    }
  }
}

void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask) {
  // Disable each pin in the mask
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Mask the EXTI line
      EXTI->IMR1 &= ~(1 << pin);

      // Clear trigger selection
      EXTI->FTSR1 &= ~(1 << pin);
      EXTI->RTSR1 &= ~(1 << pin);

      // Disable NVIC interrupt
      IRQn_Type irqn;
      switch (pin) {
        case 0:  irqn = EXTI0_IRQn; break;
        case 1:  irqn = EXTI1_IRQn; break;
        case 2:  irqn = EXTI2_IRQn; break;
        case 3:  irqn = EXTI3_IRQn; break;
        case 4:  irqn = EXTI4_IRQn; break;
        case 5:  irqn = EXTI5_IRQn; break;
        case 6:  irqn = EXTI6_IRQn; break;
        case 7:  irqn = EXTI7_IRQn; break;
        case 8:  irqn = EXTI8_IRQn; break;
        case 9:  irqn = EXTI9_IRQn; break;
        case 10: irqn = EXTI10_IRQn; break;
        case 11: irqn = EXTI11_IRQn; break;
        case 12: irqn = EXTI12_IRQn; break;
        case 13: irqn = EXTI13_IRQn; break;
        case 14: irqn = EXTI14_IRQn; break;
        case 15: irqn = EXTI15_IRQn; break;
        default: continue;
      }
      NVIC_DisableIRQ(irqn);
    }
  }
}

// BUG #25 (CONTRACTS.md #gpio-pin-map-single-owner): this function used to
// hardcode every pin as a raw literal ("(1 << 7)  // PB7: Spindle enable")
// instead of consuming platform.h's *_PIN/*_MASK macros at all - so its pin
// map was decorative: it happened to numerically agree with config.h's
// (now-deleted) SPINDLE_ENABLE_PIN=7/SPINDLE_DIRECTION_PIN=9 rather than
// with platform.h's SPINDLE_ENABLE_PIN=12/SPINDLE_DIRECTION_PIN=13 (the
// values GPIO_BSET/GPIO_BCLR actually drive, via the *_BIT macros, which
// were never split). The direction pin was hardcoded onto GPIOA too, while
// platform.h's SPINDLE_DIRECTION_PORT is GPIOB - a port mismatch, not just a
// bit mismatch. Every mask below is now derived from platform.h's macros so
// there is exactly one place left to update this port's pin map.
GRBL_BOOT_INIT void hal_gpio_init(void) {
  // Enable GPIO clocks for ports A, B, C
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN;

  // Small delay after clock enable
  __NOP(); __NOP(); __NOP();

  // Configure stepper pins (PA0-6) as outputs: step/direction/disable
  hal_gpio_set_output(GPIOA, STEP_MASK | DIRECTION_MASK | STEPPERS_DISABLE_MASK);

  // Configure limit switches (PB0, PB1, PB10) as inputs with pull-up
  hal_gpio_pullup_enable(GPIOB, LIMIT_MASK);

  // Configure control pins (PB3-6) as inputs with pull-up
  hal_gpio_pullup_enable(GPIOB, CONTROL_MASK);

  // Configure spindle enable/direction pins as outputs (both on GPIOB per
  // platform.h's SPINDLE_ENABLE_PORT/SPINDLE_DIRECTION_PORT)
  hal_gpio_set_output(SPINDLE_ENABLE_PORT,
                       (1u << SPINDLE_ENABLE_BIT) | (1u << SPINDLE_DIRECTION_BIT));

  // PA8 (spindle PWM, TIM1_CH1): route to TIM1 alternate function AF1
  // (RM0481 GPIO AF table - AF1 is TIM1 on every general-purpose/advanced
  // timer STM32 family, F1 through H5). hal_timer_spindle_pwm_init() does
  // not touch GPIO mode - see timer.h note.
  hal_gpio_set_af(SPINDLE_PWM_PORT, SPINDLE_PWM_PIN, 1);

  // Configure coolant pins as outputs
  hal_gpio_set_output(COOLANT_FLOOD_PORT, (1u << COOLANT_FLOOD_BIT));
#ifdef ENABLE_M7
  hal_gpio_set_output(COOLANT_MIST_PORT, (1u << COOLANT_MIST_BIT));
#endif

  // Configure probe pin (PC15) as input with pull-up
  hal_gpio_pullup_enable(PROBE_PORT, PROBE_MASK);

  // Initialize outputs to safe state
  GPIOA->BSRR = STEPPERS_DISABLE_MASK;  // Disable steppers (active LOW, so set HIGH)
  SPINDLE_ENABLE_PORT->BSRR = (1u << (SPINDLE_ENABLE_BIT + 16)); // Spindle off (active HIGH, so set LOW)
  COOLANT_FLOOD_PORT->BSRR = (1u << (COOLANT_FLOOD_BIT + 16));   // Coolant off
#ifdef ENABLE_M7
  COOLANT_FLOOD_PORT->BSRR |= (1u << (COOLANT_MIST_BIT + 16));
#endif
}

// TIMER FUNCTIONS (contract macros: timer.h - STP_TMR_*/STP_PULSE_RESET_*/PWM_*)

void hal_timer_stepper_init(void) {
  // Enable TIM2 clock
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;

  // Configure TIM2 as upcounter with auto-reload (32-bit on H523)
  TIM2->CR1 = 0;
  TIM2->PSC = 0;                    // No prescaler
  TIM2->ARR = 0xFFFFFFFF;           // Max period (32-bit)
  TIM2->DIER = TIM_DIER_UIE;        // Enable update interrupt
  TIM2->CR1 = TIM_CR1_CEN;          // Enable counter

  // Enable TIM2 interrupt in NVIC
  NVIC_EnableIRQ(TIM2_IRQn);
  NVIC_SetPriority(TIM2_IRQn, 1);   // CONTRACTS.md section 12.7 - stepper IRQ,
                                    // numerically below serial so it is not
                                    // starved, numerically above pulse-reset
                                    // so pulse-reset can preempt it. Also the
                                    // fix for st_go_idle()'s delay_ms(): with
                                    // every IRQ left at its NVIC reset default
                                    // (equal priority, no preemption), SysTick
                                    // could never preempt this timer's ISR, so
                                    // stm32_delay_ms() (common/stm32/
                                    // stm32_timing.c) polling systick_millis
                                    // from inside st_go_idle() <- ISR_STEP
                                    // (stepper.c:401,266) span forever - the
                                    // machine hangs at the end of every move
                                    // whenever settings.stepper_idle_lock_time
                                    // != 0xff (25 ms is the DEFAULTS_GENERIC
                                    // default, defaults.h:49 - not an edge
                                    // case). Demoting this IRQ below SysTick's
                                    // untouched (higher) default priority
                                    // restores the nesting stm32f411/hc32f460
                                    // already rely on for the same reason.
}

void hal_timer_pulse_reset_init(void) {
  // Enable TIM3 clock
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM3EN;

  // Configure TIM3 for pulse reset timing (STOPPED, per CONTRACTS.md
  // section 4 - STP_PULSE_RESET_START() is what starts it)
  TIM3->CR1 = 0;
  TIM3->PSC = 0;
  TIM3->DIER = TIM_DIER_UIE;        // Enable update interrupt

  // Enable TIM3 interrupt in NVIC
  NVIC_EnableIRQ(TIM3_IRQn);
  NVIC_SetPriority(TIM3_IRQn, 0);   // Pulse-reset IRQ priority >= stepper
                                    // (numerically <=, i.e. higher preemption
                                    // priority than TIM2's 1) - CONTRACTS.md
                                    // section 5.2/12.7, matching
                                    // stm32f411/platform.c:244.
}

// Spindle PWM timer initialization (TIM1, advanced-control timer - needs
// BDTR.MOE, see timer.h/regs.h notes)
void hal_timer_spindle_pwm_init(void) {
  // Enable TIM1 clock
  RCC->APB2ENR |= RCC_APB2ENR_TIM1EN;

  // Configure TIM1 for PWM mode on channel 1
  TIM1->CR1 = 0;
  TIM1->PSC = 0;                    // No prescaler
  TIM1->ARR = SPINDLE_PWM_MAX_VALUE;

  // PWM mode 1 on channel 1
  TIM1->CCMR1 = (6 << 4) | TIM_CCMR1_OC1PE;  // PWM mode 1, preload enable
  TIM1->CCER = 0;                   // Channel disabled initially
  TIM1->BDTR = TIM_BDTR_MOE;        // Main output enable (required for TIM1)
  TIM1->CCR1 = 0;                   // 0% duty cycle

  TIM1->CR1 = TIM_CR1_CEN;          // Enable counter
}

// SERIAL/UART FUNCTIONS

void hal_serial_init(uint32_t baud_rate) {
  // Enable USART1 clock
  RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

  // Configure PA9 (TX) and PA10 (RX) as USART1 alternate function (AF7,
  // RM0481 GPIO AF table - same AF number as F4/F7/H7 for USART1/2/3)
  hal_gpio_set_af(GPIOA, 9, 7);
  hal_gpio_set_af(GPIOA, 10, 7);

  // Calculate baud rate divisor (USART1 is on APB2, 125 MHz per config.h)
  uint32_t div = (stm32_config.apb2_freq + (baud_rate / 2)) / baud_rate;

  // Configure USART1
  USART1->BRR = div;
  USART1->CR1 = USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;
  USART1->CR1 |= USART_CR1_UE;      // Enable USART

  // Enable USART1 interrupt in NVIC
  NVIC_EnableIRQ(USART1_IRQn);
  NVIC_SetPriority(USART1_IRQn, 3); // Serial must not starve the stepper pair
                                    // (CONTRACTS.md section 12.7), matching
                                    // stm32f411/platform.c:283.
}

// Forward declarations for serial ISR helpers (defined in serial.c)
extern void stm32_usart1_rx_handler(void);
extern void stm32_usart1_tx_handler(void);

// USART1 interrupt handler
// This is the actual ISR that dispatches to RX/TX handlers based on status
// flags (H5 USART: ISR register, not the classic F1 SR)
void USART1_IRQHandler(void) {
  // Check for RX not empty (data received)
  if (USART1->ISR & USART_ISR_RXNE) {
    stm32_usart1_rx_handler();
  }

  // Check for TX empty (ready to transmit)
  if (USART1->ISR & USART_ISR_TXE) {
    stm32_usart1_tx_handler();
  }
}

// SYSTEM TIMING (thin wrappers over common/stm32/stm32_timing.c)

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

// AVR compatibility - _delay_ms wrapper (nuts_bolts.c:124,133 call this
// directly, bypassing the HAL_DELAY_MS macro, same as f103/platform.c)
void _delay_ms(double ms) {
  hal_delay_ms((uint32_t)ms);
}

// NVMEM (thin wrappers over common/stm32/stm32_nvmem.c - link-level API
// expected by platform.h's eeprom_get_char/put_char macros, CONTRACTS.md
// section 10)

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

// SYSTEM INITIALIZATION

GRBL_BOOT_INIT void hal_system_init(void) {
  // Configure system clock
  hal_clock_config();

  // Initialize common timing (DWT + SysTick)
  stm32_timing_init();

  // Initialize watchdog (optional)
  #ifdef ENABLE_WATCHDOG
    stm32_watchdog_init(1600);  // 1.6s timeout
  #endif

  // Initialize GPIO
  hal_gpio_init();

  // Initialize NVMEM
  stm32_nvmem_init();

  // Timers and UART initialized when needed
}
