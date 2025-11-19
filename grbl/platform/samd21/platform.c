/*
  platform.c - SAMD21 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  SAMD21G18A: ARM Cortex-M0+, 48MHz, 32KB RAM, 256KB Flash
*/

#include "../hal.h"
#include "platform.h"
#include "config.h"

// ============================================================================
// PLATFORM INFO
// ============================================================================

const hal_platform_info_t samd21_platform_info = {
  .name = PLATFORM_NAME,
  .cpu = PLATFORM_CPU,
  .architecture = PLATFORM_ARCH,
  .cpu_freq = HAL_CPU_FREQ,
  .ram_size = HAL_RAM_SIZE,
  .flash_size = HAL_FLASH_SIZE,
  .eeprom_size = HAL_EEPROM_SIZE,
  .has_fpu = HAL_HAS_FPU,
  .has_dma = HAL_HAS_DMA,
  .has_usb = HAL_HAS_USB,
  .has_hw_eeprom = HAL_HAS_HW_EEPROM
};

const hal_platform_info_t* hal_platform_get_info(void) {
  return &samd21_platform_info;
}

// ============================================================================
// SYSTEM TIMING
// ============================================================================

static volatile uint32_t system_milliseconds = 0;
static volatile uint64_t system_microseconds = 0;

// SysTick Handler (called every 1ms)
void SysTick_Handler(void) {
  system_milliseconds++;
  system_microseconds += 1000;
}

uint32_t hal_millis(void) {
  return system_milliseconds;
}

uint64_t hal_micros(void) {
  // Simple approximation - actual implementation would use TC counter
  return system_microseconds;
}

// ============================================================================
// CLOCK CONFIGURATION
// ============================================================================

void hal_clock_config(void) {
  // SAMD21 clock configuration for 48 MHz
  // This is a placeholder - actual implementation would:
  // 1. Configure GCLK (Generic Clock Controller)
  // 2. Set up DFLL48M (Digital Frequency Locked Loop)
  // 3. Configure peripheral clocks
  // 4. Enable necessary clock sources

  // For now, assume bootloader/startup has configured clocks
  // TODO: Implement full clock tree configuration
}

// ============================================================================
// GPIO INITIALIZATION
// ============================================================================

void hal_gpio_init(void) {
  // Initialize all GPIO pins used by GRBL

  // Enable PORT clock
  // PM->APBBMASK.reg |= PM_APBBMASK_PORT;

  // Configure step pins as outputs
  // Configure direction pins as outputs
  // Configure enable pin as output
  // Configure limit switch pins as inputs with pullups
  // Configure control pins as inputs with pullups
  // Configure spindle pins
  // Configure coolant pins
  // Configure probe pin

  // This is a placeholder - actual implementation would use
  // PORT->Group[0].DIRSET.reg, DIRCLR.reg, PINCFG[], etc.

  // TODO: Implement full GPIO configuration
}

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

void hal_system_init(void) {
  // Initialize system
  hal_clock_config();

  // Configure SysTick for 1ms interrupts
  // SysTick_Config(HAL_CPU_FREQ / 1000);

  // Initialize GPIO
  hal_gpio_init();

  // Enable interrupts
  // __enable_irq();
}

// ============================================================================
// GPIO FUNCTIONS
// ============================================================================

void hal_gpio_set_pin(hal_gpio_port_t port, uint8_t pin) {
  // Set pin high
  // PORT->Group[port_index].OUTSET.reg = (1 << pin);
}

void hal_gpio_clear_pin(hal_gpio_port_t port, uint8_t pin) {
  // Set pin low
  // PORT->Group[port_index].OUTCLR.reg = (1 << pin);
}

void hal_gpio_toggle_pin(hal_gpio_port_t port, uint8_t pin) {
  // Toggle pin
  // PORT->Group[port_index].OUTTGL.reg = (1 << pin);
}

uint8_t hal_gpio_read_pin(hal_gpio_port_t port, uint8_t pin) {
  // Read pin state
  // return (PORT->Group[port_index].IN.reg & (1 << pin)) ? 1 : 0;
  return 0;
}

// ============================================================================
// TIMER FUNCTIONS (Stepper Timer)
// ============================================================================

void hal_stepper_timer_init(void) {
  // Initialize TC3 for stepper timing
  // TODO: Implement TC3 configuration
}

void hal_stepper_timer_start(void) {
  // Start stepper timer
}

void hal_stepper_timer_stop(void) {
  // Stop stepper timer
}

void hal_stepper_timer_set_period(uint32_t period) {
  // Set timer period in microseconds
}

// ============================================================================
// SERIAL/UART FUNCTIONS
// ============================================================================

void hal_serial_init(uint32_t baudrate) {
  // Initialize SERCOM3 for UART
  // TODO: Implement SERCOM configuration
}

void hal_serial_write(uint8_t data) {
  // Write byte to UART
}

uint8_t hal_serial_read(void) {
  // Read byte from UART
  return 0;
}

uint8_t hal_serial_available(void) {
  // Check if data available
  return 0;
}

// ============================================================================
// NVMEM (Flash Emulation) FUNCTIONS
// ============================================================================

uint8_t hal_nvmem_read_byte(uint32_t addr) {
  // Read from flash emulation area
  if (addr >= HAL_NVMEM_FLASH_SIZE) return 0xFF;

  uint8_t* flash_addr = (uint8_t*)(HAL_NVMEM_FLASH_START + addr);
  return *flash_addr;
}

void hal_nvmem_write_byte(uint32_t addr, uint8_t value) {
  // Write to flash emulation area
  // SAMD21 flash write requires:
  // 1. Unlock NVM
  // 2. Erase page if needed
  // 3. Write data
  // 4. Lock NVM

  // TODO: Implement flash write with page erase logic
}

// ============================================================================
// SPINDLE PWM FUNCTIONS
// ============================================================================

void hal_spindle_pwm_init(void) {
  // Initialize TCC0 for spindle PWM
  // TODO: Implement TCC0 configuration for WO[5]
}

void hal_spindle_pwm_set(uint16_t value) {
  // Set PWM duty cycle
  // TCC0->CC[SPINDLE_PWM_CHANNEL].reg = value;
}

// ============================================================================
// WATCHDOG FUNCTIONS
// ============================================================================

void hal_watchdog_init(void) {
  // Initialize watchdog timer
}

void hal_watchdog_feed(void) {
  // Reset watchdog timer
}

// ============================================================================
// DELAY FUNCTIONS
// ============================================================================

void hal_delay_ms(uint32_t ms) {
  uint32_t start = hal_millis();
  while ((hal_millis() - start) < ms) {
    // Wait
  }
}

void hal_delay_us(uint32_t us) {
  // Simple delay loop - not accurate
  // TODO: Implement precise microsecond delay using timer
  volatile uint32_t count = us * (HAL_CPU_FREQ / 1000000) / 10;
  while (count--) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// INTERRUPT CONTROL
// ============================================================================

void hal_system_enable_interrupts(void) {
  __enable_irq();
}

void hal_system_disable_interrupts(void) {
  __disable_irq();
}

