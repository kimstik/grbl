/*
  samd21.h - SAMD21 stub header
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal stub header for SAMD21G18A
  TODO: Replace with official CMSIS headers from Microchip/Atmel
*/

#ifndef SAMD21_H
#define SAMD21_H

#include <stdint.h>

// ============================================================================
// PERIPHERAL BASE ADDRESSES (placeholder values)
// ============================================================================

#define PERIPH_BASE           0x40000000UL

// GPIO Port groups
#define PORT_GROUPA           0
#define PORT_GROUPB           1

// Placeholder typedefs
typedef void* hal_gpio_port_t;

// ============================================================================
// INTERRUPT NUMBERS
// ============================================================================

typedef enum {
  Reset_IRQn              = -15,
  NonMaskableInt_IRQn     = -14,
  HardFault_IRQn          = -13,
  SVCall_IRQn             = -5,
  PendSV_IRQn             = -2,
  SysTick_IRQn            = -1,

  // SAMD21 Peripheral IRQs
  PM_IRQn                 = 0,
  SYSCTRL_IRQn            = 1,
  WDT_IRQn                = 2,
  RTC_IRQn                = 3,
  EIC_IRQn                = 4,
  NVMCTRL_IRQn            = 5,
  DMAC_IRQn               = 6,
  USB_IRQn                = 7,
  EVSYS_IRQn              = 8,
  SERCOM0_IRQn            = 9,
  SERCOM1_IRQn            = 10,
  SERCOM2_IRQn            = 11,
  SERCOM3_IRQn            = 12,
  SERCOM4_IRQn            = 13,
  SERCOM5_IRQn            = 14,
  TCC0_IRQn               = 15,
  TCC1_IRQn               = 16,
  TCC2_IRQn               = 17,
  TC3_IRQn                = 18,
  TC4_IRQn                = 19,
  TC5_IRQn                = 20,
  TC6_IRQn                = 21,
  TC7_IRQn                = 22,
  ADC_IRQn                = 23,
  AC_IRQn                 = 24,
  DAC_IRQn                = 25,
  PTC_IRQn                = 26,
  I2S_IRQn                = 27
} IRQn_Type;

#endif // SAMD21_H
