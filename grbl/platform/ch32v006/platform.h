/*
  platform.h - CH32V006 platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for CH32V006.
  RISC-V2A (RV32EC), 48 MHz, 2KB RAM, 16KB Flash
  World's cheapest MCU (~$0.10)!
*/

#ifndef PLATFORM_CH32V006_H
#define PLATFORM_CH32V006_H

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

#define PLATFORM_NAME     "CH32V006"
#define PLATFORM_CPU      "RISC-V RV32EC"
#define PLATFORM_ARCH     "RISC-V"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           0   // RV32EC has no FPU
#define HAL_HAS_DMA           1   // 7 DMA channels
#define HAL_HAS_USB           0   // No USB
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   0   // RV32E has reduced registers, no HW multiply
#define HAL_HAS_HW_DIVIDE     0   // Software divide

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        48000000UL  // 48 MHz
#endif

#define HAL_RAM_SIZE          2048        // 2 KB (yes, only 2KB!)
#define HAL_FLASH_SIZE        16384       // 16 KB
#define HAL_EEPROM_SIZE       0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   20      // 20.8 ns @ 48 MHz

// ============================================================================
// CH32V006 INCLUDES
// ============================================================================

#include "ch32v00x.h"
// RISC-V core includes
// Note: CH32V uses custom RISC-V core, not standard RISC-V headers

// ============================================================================
// MEMORY CONSTRAINTS WARNING
// ============================================================================

/*
  IMPORTANT: CH32V006 has only 2KB RAM!

  Original GRBL uses ~1.5KB for buffers:
    - RX buffer: 128 bytes
    - TX buffer: 104 bytes
    - Planner blocks: 16 × ~100 bytes = 1600 bytes
    - Stepper segments: 6 × ~30 bytes = 180 bytes
    - Total: ~2KB

  For CH32V006, we need to reduce buffer sizes:
    - RX buffer: 64 bytes (instead of 128)
    - TX buffer: 64 bytes (instead of 104)
    - Planner blocks: 8 (instead of 16)
    - Stepper segments: 4 (instead of 6)

  This will work but with reduced lookahead capability.
*/

// Reduced buffer sizes for 2KB RAM
#define CH32V006_REDUCED_BUFFERS  1

#ifdef CH32V006_REDUCED_BUFFERS
  #undef RX_BUFFER_SIZE
  #undef TX_BUFFER_SIZE
  #define RX_BUFFER_SIZE    64    // Reduced from 128
  #define TX_BUFFER_SIZE    64    // Reduced from 104

  // These will be used in planner.h and stepper.h
  #define BLOCK_BUFFER_SIZE_OVERRIDE   8   // Reduced from 16
  #define SEGMENT_BUFFER_SIZE_OVERRIDE 4   // Reduced from 6
#endif

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS
// ============================================================================

/*
  CH32V006F4P6 (TSSOP-20 package) Pin Mapping for GRBL:

  Note: CH32V006 has only 18 I/O pins, so we need careful mapping.

  Step pins (PC0, PC1, PC2):
    X_STEP   → PC0  (Port C, Pin 0)
    Y_STEP   → PC1  (Port C, Pin 1)
    Z_STEP   → PC2  (Port C, Pin 2)

  Direction pins (PC3, PC4, PC6):
    X_DIR    → PC3  (Port C, Pin 3)
    Y_DIR    → PC4  (Port C, Pin 4)
    Z_DIR    → PC6  (Port C, Pin 6)

  Stepper enable (PC7):
    ENABLE   → PC7  (Port C, Pin 7)

  Limit switches (PD0, PD2, PD3):
    X_LIMIT  → PD0  (Port D, Pin 0)
    Y_LIMIT  → PD2  (Port D, Pin 2)
    Z_LIMIT  → PD3  (Port D, Pin 3)

  Control pins (PD4, PD5, PD6):
    RESET       → PD4  (Port D, Pin 4)
    FEED_HOLD   → PD5  (Port D, Pin 5)
    CYCLE_START → PD6  (Port D, Pin 6)
    SAFETY_DOOR → PD5  (Shared with FEED_HOLD)

  Spindle control:
    SPINDLE_PWM    → PD7  (Port D, Pin 7, TIM1_CH4)
    SPINDLE_ENABLE → PA1  (Port A, Pin 1)
    SPINDLE_DIR    → PA2  (Port A, Pin 2)

  Coolant control:
    COOLANT_FLOOD → PC5  (Port C, Pin 5)
    (COOLANT_MIST disabled due to pin constraints)

  Probe:
    PROBE → PD1  (Port D, Pin 1)

  UART (Serial):
    TX    → PD5  (USART1_TX)
    RX    → PD6  (USART1_RX)
*/

// --------------------------------------------------------------------------
// STEP PINS (Port C: PC0, PC1, PC2)
// --------------------------------------------------------------------------

#define STEP_PORT           GPIOC
#define STEP_PORT_ID        ((hal_gpio_port_t)GPIOC)
#define X_STEP_PIN          0
#define Y_STEP_PIN          1
#define Z_STEP_PIN          2
#define X_STEP_BIT          0
#define Y_STEP_BIT          1
#define Z_STEP_BIT          2
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))

// --------------------------------------------------------------------------
// DIRECTION PINS (Port C: PC3, PC4, PC6)
// --------------------------------------------------------------------------

#define DIRECTION_PORT      GPIOC
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)GPIOC)
#define X_DIRECTION_PIN     3
#define Y_DIRECTION_PIN     4
#define Z_DIRECTION_PIN     6
#define X_DIRECTION_BIT     3
#define Y_DIRECTION_BIT     4
#define Z_DIRECTION_BIT     6
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

// --------------------------------------------------------------------------
// STEPPER ENABLE PIN (Port C: PC7)
// --------------------------------------------------------------------------

#define STEPPERS_DISABLE_PORT   GPIOC
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)GPIOC)
#define STEPPERS_DISABLE_PIN    7
#define STEPPERS_DISABLE_BIT    7
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (Port D: PD0, PD2, PD3)
// --------------------------------------------------------------------------

#define LIMIT_PORT          GPIOD
#define LIMIT_PORT_ID       ((hal_gpio_port_t)GPIOD)
#define X_LIMIT_PIN         0
#define Y_LIMIT_PIN         2
#define Z_LIMIT_PIN         3
#define X_LIMIT_BIT         0
#define Y_LIMIT_BIT         2
#define Z_LIMIT_BIT         3
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))

// --------------------------------------------------------------------------
// CONTROL PINS (Port D: PD4, PD5, PD6)
// --------------------------------------------------------------------------

#define CONTROL_PORT              GPIOD
#define CONTROL_PORT_ID           ((hal_gpio_port_t)GPIOD)
#define CONTROL_RESET_PIN         4
#define CONTROL_FEED_HOLD_PIN     5
#define CONTROL_CYCLE_START_PIN   6
#define CONTROL_SAFETY_DOOR_PIN   5  // Shared with FEED_HOLD (pin limited)
#define CONTROL_RESET_BIT         4
#define CONTROL_FEED_HOLD_BIT     5
#define CONTROL_CYCLE_START_BIT   6
#define CONTROL_SAFETY_DOOR_BIT   5
#define CONTROL_MASK              ((1<<CONTROL_RESET_PIN)|(1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN))
#define CONTROL_INVERT_MASK       CONTROL_MASK

// --------------------------------------------------------------------------
// PROBE PIN (Port D: PD1)
// --------------------------------------------------------------------------

#define PROBE_PORT          GPIOD
#define PROBE_PORT_ID       ((hal_gpio_port_t)GPIOD)
#define PROBE_PIN           1
#define PROBE_BIT           1
#define PROBE_MASK          (1<<PROBE_PIN)

// --------------------------------------------------------------------------
// SPINDLE PINS
// --------------------------------------------------------------------------

// Spindle PWM (PD7, TIM1_CH4)
#define SPINDLE_PWM_PORT        GPIOD
#define SPINDLE_PWM_PIN         7
#define SPINDLE_PWM_BIT         7
#define SPINDLE_PWM_TIMER       TIM1
#define SPINDLE_PWM_CHANNEL     4

// Spindle enable/direction (Port A)
#define SPINDLE_ENABLE_PORT     GPIOA
#define SPINDLE_ENABLE_PIN      1
#define SPINDLE_ENABLE_BIT      1

#define SPINDLE_DIRECTION_PORT  GPIOA
#define SPINDLE_DIRECTION_PIN   2
#define SPINDLE_DIRECTION_BIT   2

// PWM resolution (16-bit timer)
#ifdef VARIABLE_SPINDLE
  #define SPINDLE_PWM_MAX_VALUE     1024   // Reduce to 10-bit to save cycles
  #define SPINDLE_PWM_MIN_VALUE     1
  #define SPINDLE_PWM_OFF_VALUE     0
  #define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)
#endif

// --------------------------------------------------------------------------
// COOLANT PINS (Port C)
// --------------------------------------------------------------------------

#define COOLANT_FLOOD_PORT      GPIOC
#define COOLANT_FLOOD_PIN       5
#define COOLANT_FLOOD_BIT       5

// COOLANT_MIST disabled (not enough pins)
#ifdef ENABLE_M7
  #warning "M7 (coolant mist) disabled on CH32V006 due to limited pins"
  #undef ENABLE_M7
#endif

// ============================================================================
// TIMER MAPPING
// ============================================================================

// Stepper timer: TIM2 (16-bit general purpose timer)
#define STEPPER_TIMER           TIM2
#define STEPPER_TIMER_IRQn      TIM2_IRQn
#define STEPPER_TIMER_IRQHandler TIM2_IRQHandler

// Step pulse reset timer: TIM3 (16-bit general purpose timer)
#define PULSE_TIMER             TIM3
#define PULSE_TIMER_IRQn        TIM3_IRQn
#define PULSE_TIMER_IRQHandler  TIM3_IRQHandler

// Spindle PWM timer: TIM1 (16-bit advanced timer)
// Already defined above

// ============================================================================
// SERIAL/UART MAPPING
// ============================================================================

#define GRBL_USART              USART1
#define GRBL_USART_IRQn         USART1_IRQn
#define GRBL_USART_IRQHandler   USART1_IRQHandler

// ============================================================================
// FLASH EMULATION FOR EEPROM
// ============================================================================

// Use last 1KB of flash for EEPROM emulation (minimal due to small flash)
#define HAL_NVMEM_FLASH_START   (0x00000000 + HAL_FLASH_SIZE - 1024)
#define HAL_NVMEM_FLASH_SIZE    1024
#define HAL_NVMEM_FLASH_PAGE_SIZE 64  // CH32V006 has 64-byte pages

// ============================================================================
// RISC-V SPECIFIC
// ============================================================================

// RISC-V interrupt handling
// CH32V uses custom fast interrupt system (not standard RISC-V PLIC)

// Critical section for RISC-V
static inline uint32_t hal_critical_enter(void) {
  uint32_t mstatus;
  __asm__ volatile("csrr %0, mstatus" : "=r"(mstatus));
  __asm__ volatile("csrci mstatus, 0x08");  // Clear MIE bit
  return mstatus;
}

static inline void hal_critical_exit(uint32_t state) {
  __asm__ volatile("csrw mstatus, %0" :: "r"(state));
}


// ============================================================================
// OPTIMIZATION NOTES FOR CH32V006
// ============================================================================

/*
  Due to limited resources (2KB RAM, 16KB flash), optimizations needed:

  1. Reduce buffer sizes (already done above)
  2. Disable optional features:
     - Disable M7 (coolant mist)
     - Disable dual axis support
     - Reduce variable spindle resolution to 10-bit
  3. Use compiler optimizations: -Os (optimize for size)
  4. Minimize printf usage (uses lots of flash)
  5. Consider removing some G-code commands if space is tight

  Despite limitations, CH32V006 can still run core GRBL functionality!
  At $0.10 per chip, this is the world's cheapest CNC controller.
*/

#endif // PLATFORM_CH32V006_H
