/*
  regs.h - STM32H5 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal register definitions for STM32H523.
  For production use, recommend using official CMSIS headers.
*/

#ifndef STM32H523_REGS_H
#define STM32H523_REGS_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// GPIO
// ============================================================================

typedef struct {
  volatile uint32_t MODER;    // Mode register
  volatile uint32_t OTYPER;   // Output type register
  volatile uint32_t OSPEEDR;  // Output speed register
  volatile uint32_t PUPDR;    // Pull-up/pull-down register
  volatile uint32_t IDR;      // Input data register
  volatile uint32_t ODR;      // Output data register
  volatile uint32_t BSRR;     // Bit set/reset register
  volatile uint32_t LCKR;     // Configuration lock register
  volatile uint32_t AFR[2];   // Alternate function registers
} GPIO_TypeDef;

#define GPIOA_BASE  0x42020000
#define GPIOB_BASE  0x42020400
#define GPIOC_BASE  0x42020800

#define GPIOA   ((GPIO_TypeDef*)GPIOA_BASE)
#define GPIOB   ((GPIO_TypeDef*)GPIOB_BASE)
#define GPIOC   ((GPIO_TypeDef*)GPIOC_BASE)

// ============================================================================
// FLASH
// ============================================================================

typedef struct {
  volatile uint32_t ACR;      // Access control register
  volatile uint32_t KEYR;     // Key register
  volatile uint32_t OPTKEYR;  // Option key register
  volatile uint32_t CR;       // Control register
  volatile uint32_t SR;       // Status register
  volatile uint32_t CCR;      // Clear control register
} FLASH_TypeDef;

#define FLASH_BASE  0x52002000
#define FLASH   ((FLASH_TypeDef*)FLASH_BASE)

// Flash CR register bits
#define FLASH_CR_LOCK       (1 << 0)
#define FLASH_CR_PG         (1 << 1)
#define FLASH_CR_PER        (1 << 2)
#define FLASH_CR_STRT       (1 << 6)
#define FLASH_CR_PNB_Pos    3

// Flash SR register bits
#define FLASH_SR_BSY        (1 << 0)
#define FLASH_SR_WRPERR     (1 << 4)
#define FLASH_SR_PGSERR     (1 << 5)
#define FLASH_SR_EOP        (1 << 16)

// ============================================================================
// COMMON MACROS
// ============================================================================

#define __IO volatile
#define __NOP() __asm__ volatile ("nop")

#endif // STM32H523_REGS_H
