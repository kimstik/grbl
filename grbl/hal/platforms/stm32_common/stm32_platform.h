/*
  stm32_platform.h - Common platform abstraction for all STM32 families
  Part of Grbl

  Copyright (c) 2025 kimstik
  License: MIT
  Intelligence assisted

  Platform-independent configuration interface for STM32 MCUs.
  Each platform (F103/F411/H5) provides its own configuration.
*/

#ifndef STM32_PLATFORM_H
#define STM32_PLATFORM_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// PLATFORM CONFIGURATION STRUCTURE
// ============================================================================
//
// Each platform must define a `stm32_platform_config` struct with these fields.
// This allows common code to work with any STM32 variant.

typedef struct {
  // Clock configuration
  uint32_t cpu_freq;              // CPU frequency in Hz (e.g., 72000000 for F103)
  uint32_t apb1_freq;             // APB1 peripheral frequency
  uint32_t apb2_freq;             // APB2 peripheral frequency

  // Flash parameters (for NVMEM emulation)
  uint32_t flash_page_size;       // Flash page/sector size in bytes
                                  // F103: 1024 (1KB pages)
                                  // F411: 16384 or larger (sectors)
                                  // H523: 8192 (8KB pages)
  uint32_t flash_base_addr;       // Start address of NVMEM flash area
  uint32_t flash_num_pages;       // Number of pages/sectors to use for NVMEM

  // Memory sizes
  uint32_t ram_size;              // RAM size in bytes
  uint32_t flash_size;            // Flash size in bytes

  // Hardware capabilities
  bool has_fpu;                   // FPU available
  bool has_32bit_timers;          // 32-bit timers (TIM2/TIM5)
  uint8_t gpio_model;             // GPIO model: 1=F1 (CRL/CRH), 2=F4/H5 (MODER)

} stm32_platform_config_t;

// External reference - defined by each platform (stm32f103/platform.c, etc)
extern const stm32_platform_config_t stm32_config;

// ============================================================================
// COMMON REGISTER ACCESS MACROS
// ============================================================================

// These work across all STM32 families (defined in CMSIS)
#ifndef __IO
#define __IO volatile
#endif

#ifndef __I
#define __I volatile const
#endif

#ifndef __O
#define __O volatile
#endif

// ============================================================================
// COMMON ERROR CODES
// ============================================================================

typedef enum {
  STM32_OK = 0,
  STM32_ERROR_INVALID_PARAM,
  STM32_ERROR_TIMEOUT,
  STM32_ERROR_FLASH_LOCKED,
  STM32_ERROR_FLASH_ERASE,
  STM32_ERROR_FLASH_WRITE,
  STM32_ERROR_NOT_INITIALIZED,
  STM32_ERROR_OUT_OF_RANGE
} stm32_status_t;

// ============================================================================
// COMMON INLINE UTILITIES
// ============================================================================

// Compiler barriers and intrinsics (work on all ARM)
#define __DSB()  __asm__ volatile ("dsb" ::: "memory")
#define __ISB()  __asm__ volatile ("isb" ::: "memory")
#define __DMB()  __asm__ volatile ("dmb" ::: "memory")
#define __NOP()  __asm__ volatile ("nop")

// Interrupt control (CMSIS standard)
static inline void __disable_irq(void) {
  __asm__ volatile ("cpsid i" ::: "memory");
}

static inline void __enable_irq(void) {
  __asm__ volatile ("cpsie i" ::: "memory");
}

// ============================================================================
// VALIDATION HELPERS (for 98% reliability)
// ============================================================================

#define STM32_VALIDATE_PARAM(cond, ret) \
  do { if (!(cond)) return (ret); } while(0)

#define STM32_VALIDATE_INIT(initialized, ret) \
  do { if (!(initialized)) return (ret); } while(0)

#define STM32_VALIDATE_RANGE(val, min, max, ret) \
  do { if ((val) < (min) || (val) > (max)) return (ret); } while(0)

#endif // STM32_PLATFORM_H
