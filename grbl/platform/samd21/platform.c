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
  PM->APBBMASK |= PM_APBBMASK_PORT;

  // Configure direction pins as outputs (PA0, PA1, PA2)
  PORT->Group[PORT_GROUPA].DIRSET = DIRECTION_MASK;
  PORT->Group[PORT_GROUPA].OUTCLR = DIRECTION_MASK;  // Start low

  // Configure step pins as outputs (PA25, PA27, PA28)
  PORT->Group[PORT_GROUPA].DIRSET = STEP_MASK;
  PORT->Group[PORT_GROUPA].OUTCLR = STEP_MASK;  // Start low

  // Configure stepper enable pin as output (PA3)
  PORT->Group[PORT_GROUPA].DIRSET = STEPPERS_DISABLE_MASK;
  PORT->Group[PORT_GROUPA].OUTSET = STEPPERS_DISABLE_MASK;  // Start disabled (active low)

  // Configure limit switch pins as inputs with pullups (PA4, PA5, PA7)
  PORT->Group[PORT_GROUPA].DIRCLR = LIMIT_MASK_A;
  PORT->Group[PORT_GROUPA].PINCFG[X_LIMIT_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].PINCFG[Y_LIMIT_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].PINCFG[Z_LIMIT_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].OUTSET = LIMIT_MASK_A;  // Enable pullups

  // Configure control pins as inputs with pullups (PA14, PA15, PA16)
  PORT->Group[PORT_GROUPA].DIRCLR = CONTROL_MASK_A;
  PORT->Group[PORT_GROUPA].PINCFG[CONTROL_RESET_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].PINCFG[CONTROL_FEED_HOLD_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].PINCFG[CONTROL_CYCLE_START_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].OUTSET = CONTROL_MASK_A;  // Enable pullups

  // Configure probe pin as input with pullup (PA19)
  PORT->Group[PORT_GROUPA].DIRCLR = PROBE_MASK;
  PORT->Group[PORT_GROUPA].PINCFG[PROBE_PIN] = PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
  PORT->Group[PORT_GROUPA].OUTSET = PROBE_MASK;  // Enable pullup

  // Configure spindle direction/enable pin as output (PA8)
  PORT->Group[PORT_GROUPA].DIRSET = (1 << SPINDLE_DIRECTION_PIN);
  PORT->Group[PORT_GROUPA].OUTCLR = (1 << SPINDLE_DIRECTION_PIN);  // Start low

  // Spindle PWM pin will be configured by hal_spindle_pwm_init()

  // Configure coolant pins as outputs (PA17, PA18)
  PORT->Group[PORT_GROUPA].DIRSET = (1 << COOLANT_FLOOD_PIN);
  PORT->Group[PORT_GROUPA].OUTCLR = (1 << COOLANT_FLOOD_PIN);  // Start off
#ifdef ENABLE_M7
  PORT->Group[PORT_GROUPA].DIRSET = (1 << COOLANT_MIST_PIN);
  PORT->Group[PORT_GROUPA].OUTCLR = (1 << COOLANT_MIST_PIN);  // Start off
#endif
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
  if (pin < 32) {
    PORT->Group[port].OUTSET = (1UL << pin);
  }
}

void hal_gpio_clear_pin(hal_gpio_port_t port, uint8_t pin) {
  // Set pin low
  if (pin < 32) {
    PORT->Group[port].OUTCLR = (1UL << pin);
  }
}

void hal_gpio_toggle_pin(hal_gpio_port_t port, uint8_t pin) {
  // Toggle pin
  if (pin < 32) {
    PORT->Group[port].OUTTGL = (1UL << pin);
  }
}

uint8_t hal_gpio_read_pin(hal_gpio_port_t port, uint8_t pin) {
  // Read pin state
  if (pin < 32) {
    return (PORT->Group[port].IN & (1UL << pin)) ? 1 : 0;
  }
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

