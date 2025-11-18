/*
  platform.c - STM32F103 platform implementation
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  STM32F103 (Blue Pill) implementation of HAL functions.
  ARM Cortex-M3, 72 MHz, 20KB RAM, 64-128KB Flash
*/

#include "../../grbl_hal.h"
#include "platform.h"

// ============================================================================
// PLATFORM INFO
// ============================================================================

const hal_platform_info_t stm32_platform_info = {
  .platform_name  = "STM32F103C8T6",
  .cpu_name       = "ARM Cortex-M3",
  .arch_name      = "ARM",
  .cpu_freq       = 72000000,
  .ram_size       = 20480,
  .flash_size     = 65536,
  .has_fpu        = 0,
  .has_dma        = 1,
  .has_usb        = 0,
  .has_hw_eeprom  = 0
};

const hal_platform_info_t* hal_platform_get_info(void) {
  return &stm32_platform_info;
}

// ============================================================================
// SYSTEM TIMING (SysTick-based millisecond counter)
// ============================================================================

static volatile uint32_t systick_millis = 0;

void SysTick_Handler(void) {
  systick_millis++;
}

uint32_t hal_millis(void) {
  return systick_millis;
}

uint64_t hal_micros(void) {
  uint32_t m, t;

  __disable_irq();
  m = systick_millis;
  t = SysTick->VAL;
  __enable_irq();

  // SysTick counts down from (72000000/1000 - 1) = 71999
  // Convert to microseconds
  return ((uint64_t)m * 1000) + ((71999 - t) / 72);
}

// ============================================================================
// CLOCK CONFIGURATION
// ============================================================================

void hal_clock_config(void) {
  // Enable HSE (8 MHz external crystal on Blue Pill)
  RCC->CR |= RCC_CR_HSEON;
  while (!(RCC->CR & RCC_CR_HSERDY));

  // Configure PLL: HSE * 9 = 72 MHz
  RCC->CFGR &= ~(RCC_CFGR_PLLMULL | RCC_CFGR_PLLSRC);
  RCC->CFGR |= RCC_CFGR_PLLMULL9 | RCC_CFGR_PLLSRC;

  // Enable PLL
  RCC->CR |= RCC_CR_PLLON;
  while (!(RCC->CR & RCC_CR_PLLRDY));

  // Flash latency 2 wait states for 72 MHz
  FLASH->ACR = FLASH_ACR_LATENCY_2 | FLASH_ACR_PRFTBE;

  // Select PLL as system clock
  RCC->CFGR &= ~RCC_CFGR_SW;
  RCC->CFGR |= RCC_CFGR_SW_PLL;
  while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL);

  // Configure SysTick for 1ms interrupts
  SysTick_Config(72000000 / 1000);
}

// ============================================================================
// GPIO FUNCTIONS
// ============================================================================

// Helper: Get pin position in CRL/CRH register (0-7 for CRL, 8-15 for CRH)
static inline uint32_t get_pin_config_shift(uint8_t pin) {
  return (pin & 0x07) << 2;  // Each pin uses 4 bits
}

// Helper: Configure single pin mode
static void gpio_config_pin(GPIO_TypeDef* port, uint8_t pin, uint32_t mode) {
  __IO uint32_t* config_reg = (pin < 8) ? &port->CRL : &port->CRH;
  uint32_t shift = get_pin_config_shift(pin);
  uint32_t mask = 0x0F << shift;

  *config_reg = (*config_reg & ~mask) | (mode << shift);
}

void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask) {
  // Configure pins as push-pull output, 50MHz
  // Mode: 0b0011 = Output mode, max speed 50 MHz, push-pull
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      gpio_config_pin(port, pin, 0x3);  // 50MHz push-pull output
    }
  }
}

void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask) {
  // Configure pins as floating input
  // Mode: 0b0100 = Input mode, floating
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      gpio_config_pin(port, pin, 0x4);  // Floating input
    }
  }
}

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask) {
  // Configure as input with pull-up
  // Mode: 0b1000 = Input mode, pull-up/pull-down
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      gpio_config_pin(port, pin, 0x8);  // Pull-up/pull-down input
      port->BSRR = (1 << pin);           // Set ODR bit = pull-up
    }
  }
}

void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask) {
  // Configure as floating input
  hal_gpio_set_input(port, mask);
}

void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  // REVIEW: HIGH #5 - Added AFIO configuration for proper EXTI mapping
  // Enable AFIO clock (should already be enabled in hal_gpio_init)
  RCC->APB2ENR |= RCC_APB2ENR_AFIOEN;

  // Determine port number for AFIO_EXTICR (A=0, B=1, C=2, D=3)
  uint8_t port_num = 0;
  if (port == GPIOB) port_num = 1;
  else if (port == GPIOC) port_num = 2;
  else if (port == GPIOD) port_num = 3;

  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      // Configure AFIO_EXTICRx to map this port to EXTI line
      uint8_t reg_idx = pin / 4;        // EXTICR1-4 (0-3)
      uint8_t bit_pos = (pin % 4) * 4;  // Bits 0,4,8,12 within register

      AFIO->EXTICR[reg_idx] &= ~(0xF << bit_pos);
      AFIO->EXTICR[reg_idx] |= (port_num << bit_pos);

      // Configure EXTI line
      EXTI->IMR |= (1 << pin);   // Unmask interrupt
      EXTI->RTSR |= (1 << pin);  // Rising edge trigger
      EXTI->FTSR |= (1 << pin);  // Falling edge trigger

      // Enable NVIC interrupt for this EXTI line
      if (pin <= 4) {
        NVIC_EnableIRQ(EXTI0_IRQn + pin);
      } else if (pin <= 9) {
        NVIC_EnableIRQ(EXTI9_5_IRQn);
      } else {
        NVIC_EnableIRQ(EXTI15_10_IRQn);
      }
    }
  }
}

void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask) {
  for (uint8_t pin = 0; pin < 16; pin++) {
    if (mask & (1 << pin)) {
      EXTI->IMR &= ~(1 << pin);  // Mask interrupt
    }
  }
}

void hal_gpio_init(void) {
  // Enable GPIO clocks
  RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_IOPBEN |
                  RCC_APB2ENR_IOPCEN | RCC_APB2ENR_AFIOEN;

  // Configure step pins (PA0, PA1, PA2) as outputs
  hal_gpio_set_output(GPIOA, STEP_MASK);
  HAL_GPIO_CLEAR_BITS(GPIOA, STEP_MASK);

  // Configure direction pins (PA3, PA4, PA5) as outputs
  hal_gpio_set_output(GPIOA, DIRECTION_MASK);
  HAL_GPIO_CLEAR_BITS(GPIOA, DIRECTION_MASK);

  // Configure stepper enable pin (PA6) as output
  hal_gpio_set_output(GPIOA, STEPPERS_DISABLE_MASK);
  HAL_GPIO_SET_BITS(GPIOA, STEPPERS_DISABLE_MASK);  // Disable steppers initially

  // Configure limit switch pins (PB0, PB1, PB10) as inputs with pull-ups
  hal_gpio_pullup_enable(GPIOB, LIMIT_MASK);

  // Configure control pins (PB3, PB4, PB5, PB6) as inputs with pull-ups
  hal_gpio_pullup_enable(GPIOB, CONTROL_MASK);

  // Configure probe pin (PC15) as input with pull-up
  hal_gpio_pullup_enable(GPIOC, PROBE_MASK);

  // Configure spindle enable/direction pins as outputs
  hal_gpio_set_output(GPIOB, (1 << SPINDLE_ENABLE_PIN) | (1 << SPINDLE_DIRECTION_PIN));
  HAL_GPIO_CLEAR_BITS(GPIOB, (1 << SPINDLE_ENABLE_PIN) | (1 << SPINDLE_DIRECTION_PIN));

  // Configure coolant pins as outputs
  hal_gpio_set_output(GPIOC, (1 << COOLANT_FLOOD_PIN));
#ifdef ENABLE_M7
  hal_gpio_set_output(GPIOC, (1 << COOLANT_MIST_PIN));
#endif

  // Configure spindle PWM pin (PA8) for TIM1 alternate function
  gpio_config_pin(GPIOA, 8, 0xB);  // 50MHz alternate function push-pull
}

// ============================================================================
// TIMER FUNCTIONS
// ============================================================================

void hal_timer_stepper_init(void) {
  // Enable TIM2 clock
  RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;

  // Configure TIM2 as upcounter with auto-reload
  TIM2->CR1 = 0;
  TIM2->PSC = 0;                    // No prescaler (72 MHz)
  TIM2->ARR = 0xFFFFFFFF;           // Max period (32-bit)
  TIM2->DIER = TIM_DIER_UIE;        // Enable update interrupt
  TIM2->CR1 = TIM_CR1_CEN;          // Enable counter

  // Enable TIM2 interrupt in NVIC
  NVIC_EnableIRQ(TIM2_IRQn);
  NVIC_SetPriority(TIM2_IRQn, 1);   // High priority
}

void hal_timer_stepper_set_prescaler(uint16_t prescaler) {
  TIM2->PSC = prescaler;
  TIM2->EGR = TIM_EGR_UG;  // Update generation (reload prescaler)
}

void hal_timer_pulse_reset_init(void) {
  // Enable TIM3 clock
  RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;

  // Configure TIM3 for pulse reset timing
  TIM3->CR1 = 0;
  TIM3->PSC = 71;                   // 72MHz / 72 = 1 MHz (1 µs tick)
  TIM3->ARR = 100;                  // Default period
  TIM3->DIER = TIM_DIER_UIE;        // Enable update interrupt

  // Enable TIM3 interrupt in NVIC
  NVIC_EnableIRQ(TIM3_IRQn);
  NVIC_SetPriority(TIM3_IRQn, 2);
}

#ifdef VARIABLE_SPINDLE
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
#endif

// ============================================================================
// SERIAL/UART FUNCTIONS
// ============================================================================

void hal_serial_init(uint32_t baud_rate) {
  // Enable USART1 clock
  RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

  // Configure PA9 (TX) as alternate function push-pull
  gpio_config_pin(GPIOA, 9, 0xB);   // 50MHz AF push-pull

  // Configure PA10 (RX) as input with pull-up
  gpio_config_pin(GPIOA, 10, 0x8);  // Input pull-up
  GPIOA->BSRR = (1 << 10);          // Enable pull-up

  // Calculate baud rate divisor (72 MHz APB2 clock)
  uint32_t div = (72000000 + (baud_rate / 2)) / baud_rate;

  // Configure USART1
  USART1->BRR = div;
  USART1->CR1 = USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;
  USART1->CR1 |= USART_CR1_UE;      // Enable USART

  // Enable USART1 interrupt in NVIC
  NVIC_EnableIRQ(USART1_IRQn);
  NVIC_SetPriority(USART1_IRQn, 3);
}

// ============================================================================
// DELAY FUNCTIONS
// ============================================================================

void hal_delay_ms(uint32_t ms) {
  uint32_t start = systick_millis;
  while ((systick_millis - start) < ms);
}

void hal_delay_us(uint32_t us) {
  // Use cycle counting for microsecond delays
  // 72 cycles per microsecond at 72 MHz
  uint32_t cycles = us * 72;

  // Simple cycle delay (not perfectly accurate but good enough)
  for (uint32_t i = 0; i < cycles / 4; i++) {
    __NOP();
  }
}

// ============================================================================
// NVMEM (Flash Emulation) FUNCTIONS
// ============================================================================

// Simple flash emulation using last 2KB of flash
// Real implementation would need wear leveling, but this is functional

static uint8_t nvmem_cache[HAL_NVMEM_FLASH_SIZE];
static bool nvmem_initialized = false;

void hal_nvmem_init(void) {
  // Read entire flash page into cache
  const uint8_t* flash_base = (const uint8_t*)HAL_NVMEM_FLASH_START;
  for (uint32_t i = 0; i < HAL_NVMEM_FLASH_SIZE; i++) {
    nvmem_cache[i] = flash_base[i];
  }
  nvmem_initialized = true;
}

unsigned char hal_nvmem_read_byte(unsigned int addr) {
  if (!nvmem_initialized) {
    hal_nvmem_init();
  }

  if (addr >= HAL_NVMEM_FLASH_SIZE) {
    return 0xFF;
  }

  return nvmem_cache[addr];
}

void hal_nvmem_write_byte(unsigned int addr, unsigned char data) {
  if (!nvmem_initialized) {
    hal_nvmem_init();
  }

  if (addr >= HAL_NVMEM_FLASH_SIZE) {
    return;
  }

  // Update cache
  nvmem_cache[addr] = data;

  // Write to flash (simplified - needs erase first in real implementation)
  // For now, just update cache. Full implementation would:
  // 1. Erase flash page
  // 2. Write entire cache back to flash
  // This is deferred for simplicity - settings won't persist across resets yet
}

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

void hal_system_init(void) {
  // Configure system clock
  hal_clock_config();

  // Initialize GPIO
  hal_gpio_init();

  // Initialize NVMEM
  hal_nvmem_init();

  // Timers and UART are initialized when needed
}
