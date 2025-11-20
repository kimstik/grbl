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
// CRITICAL SECTIONS
// ============================================================================

// ISSUE #10 (MINOR): Unused global variable - never referenced anywhere
// TODO: Remove or use properly
uint32_t _hal_critical_state = 0;

uint32_t hal_critical_enter(void) {
  uint32_t primask;
  __asm volatile ("MRS %0, primask" : "=r" (primask));
  __asm volatile ("cpsid i" : : : "memory");
  return primask;
}

void hal_critical_exit(uint32_t state) {
  __asm volatile ("MSR primask, %0" : : "r" (state) : "memory");
}

// ============================================================================
// PLATFORM INFO
// ============================================================================

const hal_platform_info_t samd21_platform_info = {
  .name = PLATFORM_NAME,
  .cpu = PLATFORM_CPU,
  .cpu_freq_hz = HAL_CPU_FREQ,
  .ram_bytes = HAL_RAM_SIZE,
  .flash_bytes = HAL_FLASH_SIZE
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

  // Enable DFLL48M in open-loop mode (simplest configuration)
  // Note: For production, use closed-loop mode with USB SOF or external 32kHz

  // ISSUE #11 (MINOR): Magic number needs explanation
  // 0x87 = ENABLE=1, PRESC=0 (no prescaling), ONDEMAND=0, RUNSTDBY=0
  SYSCTRL->OSC8M = 0x87;  // Enable OSC8M at 8MHz

  // Configure DFLL48M in open-loop mode
  SYSCTRL->DFLLCTRL = 0;  // Disable DFLL
  while (!(SYSCTRL->PCLKSR & (1 << 0)));  // Wait for ready

  // ISSUE #11 (MINOR): Magic address needs explanation
  // 0x00806020 = NVM Software Calibration Area (factory programmed)
  // Load factory calibration values for DFLL48M
  uint32_t coarse_cal = (*((uint32_t*)0x00806020) >> 26) & 0x3F;
  SYSCTRL->DFLLVAL = (coarse_cal << 10);

  // Enable DFLL in open-loop mode
  SYSCTRL->DFLLCTRL = SYSCTRL_DFLLCTRL_ENABLE;
  while (!(SYSCTRL->PCLKSR & (1 << 1)));  // Wait for DFLL ready

  // Configure GCLK Generator 0 to use DFLL48M
  GCLK->GENDIV = (0 << GCLK_GENCTRL_ID_Pos);  // Generator 0, no division
  GCLK->GENCTRL = (0 << GCLK_GENCTRL_ID_Pos) |
                  (GCLK_SOURCE_DFLL48M << GCLK_GENCTRL_SRC_Pos) |
                  GCLK_GENCTRL_GENEN;
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);
}

// ============================================================================
// GPIO INITIALIZATION
// ============================================================================

// ISSUE #5 (MAJOR): This entire function uses old-style direct PORT manipulation
// TODO: Rewrite using new GPIO_SET_OUT(), GPIO_BSET(), GPIO_BCLR() macros
// Example: Instead of PORT->Group[].DIRSET = (1 << PIN)
//          Use: GPIO_SET_OUT(X_DIRECTION)
//
// Lines to update:
// - 115-116: Direction pins (3 pins)
// - 119-120: Step pins (3 pins)
// - 123-124: Stepper enable (1 pin)
// - 127-131: Limit switches (3 pins)
// - 134-138: Control pins (3 pins)
// - 141-143: Probe pin (1 pin)
// - 146-147: Spindle direction (1 pin)
// - 152-157: Coolant pins (1-2 pins)

void hal_gpio_init(void) {
  // Initialize all GPIO pins used by GRBL

  // Enable PORT clock
  PM->APBBMASK |= PM_APBBMASK_PORT;

  // ISSUE #5: OLD STYLE - should use GPIO_SET_OUT(X_DIRECTION) etc.
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

  // ISSUE #1 (CRITICAL): SysTick timer is DISABLED!
  // This breaks hal_millis(), hal_micros(), and all timing functions
  // Dwell times, feed rates, delays won't work correctly
  // TODO: UNCOMMENT THIS LINE!
  // SysTick_Config(HAL_CPU_FREQ / 1000);

  // Initialize GPIO
  hal_gpio_init();

  // ISSUE #1 (CRITICAL): Interrupts are DISABLED!
  // This prevents SysTick and all other interrupts from working
  // TODO: UNCOMMENT THIS LINE!
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

bool hal_gpio_read_pin(hal_gpio_port_t port, uint8_t pin) {
  // Read pin state
  if (pin < 32) {
    return (PORT->Group[port].IN & (1UL << pin)) ? true : false;
  }
  return false;
}

uint32_t hal_gpio_read_port(hal_gpio_port_t port) {
  // Read entire port
  return PORT->Group[port].IN;
}

void hal_gpio_write_port(hal_gpio_port_t port, uint32_t mask, uint32_t value) {
  // ISSUE #9 (MODERATE): Thread-safety problem!
  // Read-modify-write is NOT atomic - can corrupt if called from ISR
  // TODO: Use OUTSET/OUTCLR instead, or wrap in critical section:
  //   if (value) PORT->Group[port].OUTSET = mask;
  //   else       PORT->Group[port].OUTCLR = mask;
  PORT->Group[port].OUT = (PORT->Group[port].OUT & ~mask) | (value & mask);
}

void hal_gpio_set_output(hal_gpio_port_t port, uint32_t mask) {
  // Set pins as outputs
  PORT->Group[port].DIRSET = mask;
}

void hal_gpio_set_input(hal_gpio_port_t port, uint32_t mask) {
  // Set pins as inputs
  PORT->Group[port].DIRCLR = mask;
}

void hal_gpio_set_bits(hal_gpio_port_t port, uint32_t mask) {
  // Set bits (output high)
  PORT->Group[port].OUTSET = mask;
}

void hal_gpio_clear_bits(hal_gpio_port_t port, uint32_t mask) {
  // Clear bits (output low)
  PORT->Group[port].OUTCLR = mask;
}

void hal_gpio_toggle_bits(hal_gpio_port_t port, uint32_t mask) {
  // Toggle bits
  PORT->Group[port].OUTTGL = mask;
}

void hal_gpio_pullup_enable(hal_gpio_port_t port, uint32_t mask) {
  // ISSUE #7 (MAJOR): Inefficient O(32) loop even for single bit!
  // TODO: Use __builtin_ctz() to iterate only set bits:
  //   while (mask) {
  //     uint8_t pin = __builtin_ctz(mask);
  //     PORT->Group[port].PINCFG[pin] |= PORT_PINCFG_PULLEN;
  //     PORT->Group[port].OUTSET = (1UL << pin);
  //     mask &= ~(1UL << pin);
  //   }
  for (uint8_t pin = 0; pin < 32; pin++) {
    if (mask & (1UL << pin)) {
      PORT->Group[port].PINCFG[pin] |= PORT_PINCFG_PULLEN;
      PORT->Group[port].OUTSET = (1UL << pin);  // Set OUT bit for pullup
    }
  }
}

void hal_gpio_pullup_disable(hal_gpio_port_t port, uint32_t mask) {
  // ISSUE #7 (MAJOR): Inefficient O(32) loop even for single bit!
  // TODO: Use __builtin_ctz() to iterate only set bits (see above)
  for (uint8_t pin = 0; pin < 32; pin++) {
    if (mask & (1UL << pin)) {
      PORT->Group[port].PINCFG[pin] &= ~PORT_PINCFG_PULLEN;
    }
  }
}

// ============================================================================
// TIMER FUNCTIONS (Stepper Timer)
// ============================================================================

void hal_stepper_timer_init(void) {
  // Initialize TC3 for stepper timing

  // Enable TC3 clock
  PM->APBCMASK |= PM_APBCMASK_TC3;

  // Configure GCLK for TC3
  GCLK->CLKCTRL = GCLK_CLKCTRL_ID_TC3_TC4 |
                  GCLK_CLKCTRL_CLKEN |
                  (0 << GCLK_CLKCTRL_GEN_Pos);  // Use GCLK0
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Reset TC3
  TC3->CTRLA = TC_CTRLA_SWRST;
  while (TC3->CTRLA & TC_CTRLA_SWRST);

  // Configure TC3: 16-bit mode, match frequency, no prescaler
  TC3->CTRLA = TC_CTRLA_MODE_COUNT16 |
               TC_CTRLA_WAVEGEN_MFRQ |
               TC_CTRLA_PRESCALER_DIV1;

  // Set initial period
  TC3->CC[0] = 1000;  // Default 1ms

  // Enable interrupt
  TC3->INTENSET = TC_INTFLAG_MC0;
}

void hal_stepper_timer_start(void) {
  // Start stepper timer
  TC3->CTRLA |= TC_CTRLA_ENABLE;
  while (TC3->STATUS & 0x80);  // Wait for sync
}

void hal_stepper_timer_stop(void) {
  // Stop stepper timer
  TC3->CTRLA &= ~TC_CTRLA_ENABLE;
  while (TC3->STATUS & 0x80);  // Wait for sync
}

void hal_stepper_timer_set_period(uint32_t period) {
  // Set timer period in ticks
  if (period > 0xFFFF) period = 0xFFFF;
  TC3->CC[0] = (uint16_t)period;
}

void hal_pulse_timer_init(void) {
  // Initialize TC4 for pulse reset

  // Enable TC4 clock
  PM->APBCMASK |= PM_APBCMASK_TC4;

  // GCLK already configured for TC3/TC4

  // Reset TC4
  TC4->CTRLA = TC_CTRLA_SWRST;
  while (TC4->CTRLA & TC_CTRLA_SWRST);

  // Configure TC4: 16-bit mode, match frequency
  TC4->CTRLA = TC_CTRLA_MODE_COUNT16 |
               TC_CTRLA_WAVEGEN_MFRQ |
               TC_CTRLA_PRESCALER_DIV1;

  // Set period for pulse width (in CPU ticks)
  TC4->CC[0] = 100;  // Short pulse

  // Enable interrupt
  TC4->INTENSET = TC_INTFLAG_MC0;
}

void hal_timer_pulse_reset_set_count(uint32_t count) {
  // Set pulse timer count value
  TC4->COUNT = (uint16_t)count;
}

// ============================================================================
// SERIAL/UART FUNCTIONS
// ============================================================================

void hal_serial_init(uint32_t baudrate) {
  // Initialize SERCOM3 for UART (PA23=RX/PAD1, PA24=TX/PAD2)

  // Enable SERCOM3 clock
  PM->APBCMASK |= PM_APBCMASK_SERCOM3;

  // Configure GCLK for SERCOM3
  GCLK->CLKCTRL = GCLK_CLKCTRL_ID_SERCOM3_CORE |
                  GCLK_CLKCTRL_CLKEN |
                  (0 << GCLK_CLKCTRL_GEN_Pos);  // Use GCLK0 (48MHz)
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Configure PA23 (RX) and PA24 (TX) for SERCOM3
  PORT->Group[PORT_GROUPA].PINCFG[23] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PINCFG[24] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PMUX[23 >> 1] = (0x2 << 4) | 0x2;  // Function C for both

  // Reset SERCOM3
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_SWRST;
  while (SERCOM3->CTRLA & SERCOM_USART_CTRLA_SWRST);

  // Configure SERCOM3 as USART with internal clock
  SERCOM3->CTRLA = SERCOM_USART_CTRLA_MODE_USART_INT_CLK |
                   SERCOM_USART_CTRLA_RXPO_PAD1 |   // RX on PAD1
                   (2 << SERCOM_USART_CTRLA_TXPO_Pos) |  // TX on PAD2
                   SERCOM_USART_CTRLA_DORD;         // LSB first

  // Configure 8N1
  SERCOM3->CTRLB = SERCOM_USART_CTRLB_CHSIZE_8BIT |
                   SERCOM_USART_CTRLB_TXEN |
                   SERCOM_USART_CTRLB_RXEN;
  while (SERCOM3->SYNCBUSY);

  // Calculate baud rate: BAUD = 65536 * (1 - 16 * (f_baud / f_ref))
  // For 115200 @ 48MHz: BAUD = 65536 * (1 - 16 * (115200 / 48000000)) = 63019
  uint16_t baud_value = 65536 - ((65536 * 16.0f * baudrate) / HAL_CPU_FREQ);
  SERCOM3->BAUD = baud_value;

  // Enable SERCOM3
  SERCOM3->CTRLA |= SERCOM_USART_CTRLA_ENABLE;
  while (SERCOM3->SYNCBUSY);
}

void hal_serial_write(uint8_t data) {
  // Write byte to UART
  while (!(SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_DRE));
  SERCOM3->DATA = data;
}

uint8_t hal_serial_read(void) {
  // Read byte from UART
  while (!(SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_RXC));
  return (uint8_t)SERCOM3->DATA;
}

uint8_t hal_serial_available(void) {
  // Check if data available
  return (SERCOM3->INTFLAG & SERCOM_USART_INTFLAG_RXC) ? 1 : 0;
}

void hal_serial_tx_interrupt_enable(void) {
  // Enable TX interrupt
  SERCOM3->INTENSET = SERCOM_USART_INTFLAG_DRE;
}

void hal_serial_tx_interrupt_disable(void) {
  // Disable TX interrupt
  SERCOM3->INTENCLR = SERCOM_USART_INTFLAG_DRE;
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

// ISSUE #2 (CRITICAL): NVMEM write NOT IMPLEMENTED!
// Settings cannot be saved to EEPROM - all configuration lost on reset
// GRBL settings ($0-$132) won't persist between power cycles
// This makes the system effectively unusable for production
//
// TODO: Implement SAMD21 NVM controller sequence:
// 1. Wait for NVMCTRL->INTFLAG.READY
// 2. Set NVMCTRL->ADDR to target address
// 3. Erase page: NVMCTRL->CTRLA = NVMCTRL_CMD_ER | NVMCTRL_CMDEX_KEY
// 4. Wait for completion
// 5. Write buffer: write to NVM memory space
// 6. Write page: NVMCTRL->CTRLA = NVMCTRL_CMD_WP | NVMCTRL_CMDEX_KEY
// 7. Wait for completion
//
// See SAMD21 datasheet section 22 (NVM Controller) for details
void hal_nvmem_write_byte(uint32_t addr, uint8_t value) {
  // TODO: Implement flash write with page erase logic
  (void)addr;
  (void)value;
}

// ============================================================================
// SPINDLE PWM FUNCTIONS
// ============================================================================

// ISSUE #3 (CRITICAL): Spindle PWM initialization INCOMPLETE!
// Variable spindle speed (M3 S1000-S12000) won't work
// Only on/off spindle control available
//
// TODO: Complete TCC0 configuration:
// 1. Reset TCC0: TCC0->CTRLA = TCC_CTRLA_SWRST
// 2. Set waveform mode: TCC0->WAVE = TCC_WAVE_WAVEGEN_NPWM
// 3. Set period: TCC0->PER = SPINDLE_PWM_MAX_VALUE
// 4. Set initial duty: TCC0->CC[0] = 0
// 5. Enable TCC0: TCC0->CTRLA = TCC_CTRLA_ENABLE
void hal_spindle_pwm_init(void) {
  // Initialize TCC0 for spindle PWM on PA6 (WO[0])

  // Enable TCC0 clock
  PM->APBCMASK |= PM_APBCMASK_TCC0;

  // Configure GCLK for TCC0
  GCLK->CLKCTRL = GCLK_CLKCTRL_ID_TCC0_TCC1 |
                  GCLK_CLKCTRL_CLKEN |
                  (0 << GCLK_CLKCTRL_GEN_Pos);  // Use GCLK0
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // ISSUE #13 (MINOR): Hard-coded magic numbers, hard to read
  // Better: #define PMUX_FUNC_E 0x4
  // Configure PA6 for TCC0/WO[0] (Function E)
  PORT->Group[PORT_GROUPA].PINCFG[SPINDLE_PWM_PIN] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PMUX[SPINDLE_PWM_PIN >> 1] |= (0x4 << ((SPINDLE_PWM_PIN & 1) * 4));  // Function E

  // Reset TCC0 (using TC structure as they're similar)
  // Note: TCC has more features but basic config is similar to TC
  // TODO: Add proper TCC structure to samd21.h if needed for advanced features
}

// ISSUE #3 (CRITICAL): Spindle PWM set NOT IMPLEMENTED!
// M3 S1000 (set spindle speed) won't do anything
// TODO: Implement: TCC0->CC[SPINDLE_PWM_CHANNEL] = value;
void hal_spindle_pwm_set(uint16_t value) {
  // TODO: Implement TCC0 PWM set
  (void)value;
}

// ISSUE #3 (CRITICAL): Spindle PWM duty NOT IMPLEMENTED!
// TODO: Implement: TCC0->CC[0] = duty;
void hal_timer_spindle_pwm_set_duty(uint16_t duty) {
  (void)duty;  // Not implemented yet
}

// ============================================================================
// WATCHDOG FUNCTIONS
// ============================================================================

void hal_watchdog_init(uint32_t timeout_ms) {
  // Initialize watchdog timer
  (void)timeout_ms;  // Not implemented yet
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

// ISSUE #6 (MAJOR): Inaccurate microsecond delay!
// NOP loop timing varies with compiler optimization level (-O0, -Os, -O2)
// The "/10" divisor is an arbitrary guess, not calibrated
// Step pulse timing will be incorrect, affecting machine accuracy
//
// TODO: Use SysTick or TC timer for precise delays:
// Option 1: Read SysTick->VAL and calculate elapsed ticks
// Option 2: Use TC5 as microsecond counter (configure for 1MHz)
// Option 3: Calibrate NOP loop at startup and adjust divisor
void hal_delay_us(uint32_t us) {
  // Simple delay loop - not accurate
  volatile uint32_t count = us * (HAL_CPU_FREQ / 1000000) / 10;
  while (count--) {
    __asm__ volatile ("nop");
  }
}

void _delay_ms(uint32_t ms) {
  // Millisecond delay
  while (ms--) {
    hal_delay_us(1000);
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

