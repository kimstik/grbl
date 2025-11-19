/*
  config.h - SG2002 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Platform-specific configuration for Sophgo SG2002
*/

#ifndef SG2002_CONFIG_H
#define SG2002_CONFIG_H

// ============================================================================
// SG2002 PLATFORM CONFIGURATION
// ============================================================================

// CPU frequency (700 MHz)
#define SG2002_CPU_FREQ  700000000UL

// UART configuration
#define SG2002_UART_CLK  100000000UL  // 100 MHz UART clock

// Timer configuration
#define SG2002_TIMER_CLK 100000000UL  // 100 MHz timer clock

// Memory configuration
#define SG2002_RAM_SIZE  (256 * 1024 * 1024)  // 256 MB DDR3

#endif // SG2002_CONFIG_H
