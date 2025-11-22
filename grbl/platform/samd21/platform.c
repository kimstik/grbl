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
  PORT->Group[PORT_GROUPA].PINCFG[SPINDLE_PWM_BIT] = PORT_PINCFG_PMUXEN;
  PORT->Group[PORT_GROUPA].PMUX[SPINDLE_PWM_BIT >> 1] |= (0x4 << ((SPINDLE_PWM_BIT & 1) * 4));  // Function E

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
// // AVR <util/delay.h>	DELAY FUNCTIONS
// TODO: Use SysTick or TC timer for precise delays:
// Option 1: Read SysTick->VAL and calculate elapsed ticks
// Option 2: Use TC5 as microsecond counter (configure for 1MHz)
// Option 3: Calibrate NOP loop at startup and adjust divisor
void _delay_us(double __us) {}
void _delay_ms(double __ms) {}
// ============================================================================
// INTERRUPT CONTROL
// ============================================================================

void hal_system_enable_interrupts(void) {
  __enable_irq();
}

void hal_system_disable_interrupts(void) {
  __disable_irq();
}

