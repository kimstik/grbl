/*
  platform.c - SAMD21 platform implementation
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  SAMD21G18A: ARM Cortex-M0+, 48MHz, 32KB RAM, 256KB Flash
*/

#include "platform.h"
#include "../hal.h"
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
// TIMER FUNCTIONS - Now implemented as macros in timer.h
// ============================================================================
// Timer initialization, control, and ISR definitions moved to timer.h
// All timer operations use platform-agnostic macros:
//   STP_TMR_*          - Stepper timer (TC3)
//   STP_PULSE_RESET_*  - Pulse reset timer (TC4)
//   PWM_*              - Spindle PWM (TCC0)
//   ISR_STEP, ISR_STEP_RESET, ISR_STEP_DELAY - Interrupt handlers

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
// // AVR <util/delay.h>	DELAY FUNCTIONS
// TODO: Use SysTick or TC timer for precise delays:
// Option 1: Read SysTick->VAL and calculate elapsed ticks
// Option 2: Use TC5 as microsecond counter (configure for 1MHz)
// Option 3: Calibrate NOP loop at startup and adjust divisor
void _delay_us(double __us) {}
void _delay_ms(double __ms) {}
// ============================================================================
// GPIO INTERRUPT INITIALIZATION
// ============================================================================

void hal_gpio_interrupt_init(void) {
  // Initialize EIC
  EIC_INIT();

  // Configure LIMIT pins (PA4, PA5, PA7)
  EIC_PIN_CONFIG(PORT_GROUPA, 4);   // X_LIMIT
  EIC_PIN_CONFIG(PORT_GROUPA, 5);   // Y_LIMIT
  EIC_PIN_CONFIG(PORT_GROUPA, 7);   // Z_LIMIT
  EIC_CONFIG_CHANNEL(4, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(5, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(7, EIC_CONFIG_SENSE_BOTH);
  EIC_INT_ENABLE(4);
  EIC_INT_ENABLE(5);
  EIC_INT_ENABLE(7);

  // Configure CONTROL pins (PA14, PA15, PA16)
  EIC_PIN_CONFIG(PORT_GROUPA, 14);  // RESET
  EIC_PIN_CONFIG(PORT_GROUPA, 15);  // FEED_HOLD
  EIC_PIN_CONFIG(PORT_GROUPA, 16);  // CYCLE_START
  EIC_CONFIG_CHANNEL(14, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(15, EIC_CONFIG_SENSE_BOTH);
  EIC_CONFIG_CHANNEL(0, EIC_CONFIG_SENSE_BOTH);  // PA16 -> EXTINT[0]
  EIC_INT_ENABLE(14);
  EIC_INT_ENABLE(15);
  EIC_INT_ENABLE(0);

  // NOTE: PROBE pin (PA19) is POLLED, not interrupt-driven (see probe.c)
  // Pin direction and pullup configured by probe_init() in probe.c
  // No EIC configuration needed here

  // Enable EIC interrupt in NVIC
  NVIC_EnableIRQ(EIC_IRQn);
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

