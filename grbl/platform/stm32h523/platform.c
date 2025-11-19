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
#include "../common/stm32/stm32_timing.h"
#include "../common/stm32/stm32_nvmem.h"
#include "../common/stm32/stm32_watchdog.h"

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
  // ============================================================================
  // STM32H523 Clock Configuration: HSE 8MHz → PLL → 250MHz CPU
  // ============================================================================
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
  // ============================================================================

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

void hal_gpio_init(void) {
  // Enable GPIO clocks for ports A, B, C
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN;

  // Small delay after clock enable
  __NOP(); __NOP(); __NOP();

  // Configure stepper pins (PA0-6) as outputs
  // PA0-2: Step pins (X, Y, Z)
  // PA3-5: Direction pins (X, Y, Z)
  // PA6: Steppers disable pin
  hal_gpio_set_output(GPIOA, (1 << 0) | (1 << 1) | (1 << 2) |  // Step pins
                              (1 << 3) | (1 << 4) | (1 << 5) |  // Direction pins
                              (1 << 6));                         // Disable pin

  // Configure limit switches (PB0, PB1, PB10) as inputs with pull-up
  hal_gpio_pullup_enable(GPIOB, (1 << 0) | (1 << 1) | (1 << 10));

  // Configure control pins (PB3-6) as inputs with pull-up
  // PB3: Reset, PB4: Feed hold, PB5: Cycle start, PB6: Safety door
  hal_gpio_pullup_enable(GPIOB, (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6));

  // Configure spindle pins
  hal_gpio_set_output(GPIOB, (1 << 7));  // PB7: Spindle enable
  hal_gpio_set_output(GPIOA, (1 << 9));  // PA9: Spindle direction
  // PA8 (spindle PWM) will be configured by timer HAL when needed

  // Configure coolant pins (PC0, PC1) as outputs
  hal_gpio_set_output(GPIOC, (1 << 0) | (1 << 1));

  // Configure probe pin (PC15) as input with pull-up
  hal_gpio_pullup_enable(GPIOC, (1 << 15));

  // Initialize outputs to safe state
  GPIOA->BSRR = (1 << 6);        // Disable steppers (active LOW, so set HIGH)
  GPIOB->BSRR = (1 << (7 + 16)); // Spindle off (active HIGH, so set LOW)
  GPIOC->BSRR = (1 << (0 + 16)) | (1 << (1 + 16)); // Coolant off
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
