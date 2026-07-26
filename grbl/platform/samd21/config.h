/*
  config.h - SAMD21 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef PLATFORM_SAMD21_CONFIG_H
#define PLATFORM_SAMD21_CONFIG_H

// GRBL CONFIGURATION OVERRIDES

// Serial baud rate
#ifndef BAUD_RATE
  #define BAUD_RATE 115200
#endif

// Default step pulse width in microseconds
#ifndef DEFAULT_STEP_PULSE_MICROSECONDS
  #define DEFAULT_STEP_PULSE_MICROSECONDS 10
#endif

// Stepper idle lock time in milliseconds
#ifndef DEFAULT_STEPPER_IDLE_LOCK_TIME
  #define DEFAULT_STEPPER_IDLE_LOCK_TIME 25
#endif

// PLATFORM-SPECIFIC SETTINGS

// Enable USB support (optional)
// #define HAL_USE_USB

// Enable watchdog (for production)
// #define ENABLE_WATCHDOG

// DEBUG OPTIONS

// Enable debug output (uses RAM)
// #define DEBUG_ENABLED

#endif // PLATFORM_SAMD21_CONFIG_H
