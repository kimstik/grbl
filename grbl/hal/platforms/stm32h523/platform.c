/*
  platform.c - STM32H523 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  STM32H523 (Black Pill H5): 250MHz Cortex-M33, 32KB RAM, 128KB Flash
*/

#include "../../grbl_hal.h"
#include "platform.h"
#include "config.h"
#include "../stm32_common/stm32_timing.h"
#include "../stm32_common/stm32_nvmem.h"
#include "../stm32_common/stm32_watchdog.h"

// ============================================================================
// PLATFORM INFO
// ============================================================================

const hal_platform_info_t stm32_platform_info = {
  .platform_name  = "STM32H523CBT6",
  .cpu_name       = "ARM Cortex-M33",
  .arch_name      = "ARM",
  .cpu_freq       = 250000000,
  .ram_size       = 32768,
  .flash_size     = 131072,
  .has_fpu        = 1,
  .has_dma        = 1,
  .has_usb        = 1,
  .has_hw_eeprom  = 0
};

const hal_platform_info_t* hal_platform_get_info(void) {
  return &stm32_platform_info;
}

// ============================================================================
// PLATFORM CONFIGURATION INSTANCE
// ============================================================================

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

// ============================================================================
// CLOCK CONFIGURATION (250 MHz from HSE 8MHz)
// ============================================================================

void hal_clock_config(void) {
  // FIXME HIGH #3: Clock configuration not implemented
  // Current: Running at bootloader clock (probably HSI 64MHz)
  // Required: Configure HSE (8MHz) → PLL → 250MHz CPU
  //           Configure APB1/2/3 prescalers (125 MHz)
  //           Enable flash wait states (5WS @ 250MHz)
  // Impact: System may not run at full 250MHz performance
  // See REVIEW_H523.md "HIGH #3" for implementation details

  // Configure SysTick for 1ms interrupts
  // Will be done by stm32_timing_init()
}

// ============================================================================
// GPIO FUNCTIONS (H5 uses MODER/OTYPER model like F4)
// ============================================================================

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

void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask) {
  // FIXME HIGH #2: EXTI configuration not implemented
  // Required: 1. Map GPIO pins to EXTI lines
  //           2. Configure EXTI for falling edge (limit switches)
  //           3. Enable NVIC interrupts (EXTI0, EXTI1, EXTI3, EXTI4, etc.)
  // Impact: Limit switches and control buttons won't work
  // See REVIEW_H523.md "HIGH #2" for implementation
  // Note: H5 EXTI may differ from F1 (check reference manual)
}

void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask) {
  // FIXME HIGH #2: EXTI disable not implemented
  // TODO: Clear EXTI configuration for specified pins
}

void hal_gpio_init(void) {
  // FIXME HIGH #1: GPIO initialization not implemented
  // Required: 1. Enable RCC clocks for GPIOA, GPIOB, GPIOC
  //           2. Configure stepper pins (PA0-6) as outputs
  //           3. Configure limit switches (PB0,1,10) as inputs with pullup
  //           4. Configure control pins (PB3-6) as inputs
  // Impact: GPIO operations will fail, hardware won't function
  // Workaround: Bootloader may leave clocks enabled
  // Note: Use RCC->AHB2ENR (or check correct register for H5)
  // See REVIEW_H523.md "HIGH #1" for implementation
}

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

void hal_system_init(void) {
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
