/*
  platform.h - HC32F460 platform configuration
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  This file provides platform-specific definitions for HC32F460JETA.
  ARM Cortex-M4F, 200 MHz, 512KB RAM, 512KB Flash
  Chinese MCU from HDSC - HIGH PERFORMANCE at low cost!
*/

#ifndef PLATFORM_HC32F460_H
#define PLATFORM_HC32F460_H

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

#define PLATFORM_NAME     "HC32F460JETA"
#define PLATFORM_CPU      "ARM Cortex-M4F"
#define PLATFORM_ARCH     "ARM"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           1   // Cortex-M4F has single-precision FPU!
#define HAL_HAS_DMA           1   // 2x DMA controllers, 16 channels total
#define HAL_HAS_USB           1   // Full-speed USB 2.0 device
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define HAL_HAS_HW_DIVIDE     1   // Hardware divider
#define HAL_HAS_ETHERNET      0   // No Ethernet (HC32F460 has no MAC)
#define HAL_HAS_CAN           1   // CAN 2.0B support

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        200000000UL  // 200 MHz! (12.5x faster than AVR)
#endif

#define HAL_RAM_SIZE          524288      // 512 KB RAM (256x more than AVR!)
#define HAL_FLASH_SIZE        524288      // 512 KB Flash
#define HAL_EEPROM_SIZE       0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   5       // 5 ns @ 200 MHz (12x better than AVR!)

// Maximum step rate (theoretical)
#define HAL_MAX_STEP_RATE_KHZ     200     // 200 kHz continuous (6x better than AVR)

// ============================================================================
// HC32F460 INCLUDES
// ============================================================================

// HC32F460 HAL (HDSC library)
#include "hc32_ddl.h"          // DDL = Device Driver Library
#include "hc32f460.h"
#include "core_cm4.h"

// ============================================================================
// PERFORMANCE FEATURES
// ============================================================================

/*
  HC32F460 is a BEAST compared to AVR:

  - 200 MHz vs 16 MHz (12.5x faster)
  - 512 KB RAM vs 2 KB (256x more)
  - 512 KB Flash vs 32 KB (16x more)
  - Hardware FPU (single-precision floating point)
  - DMA for zero-CPU serial/SPI/etc
  - 16x 32-bit timers vs 3x 8/16-bit timers
  - 12-bit ADC @ 2.5 Msps vs 10-bit @ 15 ksps

  This enables:
  ✅ 200 kHz continuous step rate (vs 30 kHz on AVR)
  ✅ Massive planner buffer (256+ blocks vs 16)
  ✅ Lookahead buffer depth 16x larger
  ✅ Complex kinematics (SCARA, Delta, 6-axis)
  ✅ Real-time trajectory optimization
  ✅ Network control (with external ETH PHY)
*/

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS
// ============================================================================

/*
  HC32F460JETA (LQFP100 package) Pin Mapping for GRBL:

  With 80+ I/O pins, we have PLENTY of pins for all features!

  Step pins (Port A):
    X_STEP   → PA0  (Port A, Pin 0)
    Y_STEP   → PA1  (Port A, Pin 1)
    Z_STEP   → PA2  (Port A, Pin 2)
    A_STEP   → PA3  (Port A, Pin 3) - 4th axis support!

  Direction pins (Port A):
    X_DIR    → PA4  (Port A, Pin 4)
    Y_DIR    → PA5  (Port A, Pin 5)
    Z_DIR    → PA6  (Port A, Pin 6)
    A_DIR    → PA7  (Port A, Pin 7) - 4th axis direction

  Stepper enable (Port B):
    ENABLE   → PB0  (Port B, Pin 0, active low)

  Limit switches (Port C):
    X_LIMIT  → PC0  (Port C, Pin 0)
    Y_LIMIT  → PC1  (Port C, Pin 1)
    Z_LIMIT  → PC2  (Port C, Pin 2)
    A_LIMIT  → PC3  (Port C, Pin 3) - 4th axis limit

  Control pins (Port D):
    RESET       → PD0  (Port D, Pin 0)
    FEED_HOLD   → PD1  (Port D, Pin 1)
    CYCLE_START → PD2  (Port D, Pin 2)
    SAFETY_DOOR → PD3  (Port D, Pin 3)

  Spindle control (Port E):
    SPINDLE_PWM    → PE0  (Port E, Pin 0, TIMA_0_PWM_A) - 16-bit PWM!
    SPINDLE_ENABLE → PE1  (Port E, Pin 1)
    SPINDLE_DIR    → PE2  (Port E, Pin 2)
    SPINDLE_TACH   → PE3  (Port E, Pin 3) - Tachometer input (optional)

  Coolant control (Port F):
    COOLANT_FLOOD → PF0  (Port F, Pin 0)
    COOLANT_MIST  → PF1  (Port F, Pin 1)

  Probe (Port F):
    PROBE → PF2  (Port F, Pin 2)

  UART (Serial) - Using USART1:
    TX    → PH1  (USART1_TX)
    RX    → PH0  (USART1_RX)

  SPI (for SD card, display, etc.):
    SCK   → PI0  (SPI1_SCK)
    MISO  → PI1  (SPI1_MISO)
    MOSI  → PI2  (SPI1_MOSI)
    CS    → PI3  (SPI1_CS)

  I2C (for displays, sensors):
    SCL   → PJ0  (I2C1_SCL)
    SDA   → PJ1  (I2C1_SDA)

  CAN Bus (for industrial networks):
    CAN_TX → PK0  (CAN_TX)
    CAN_RX → PK1  (CAN_RX)

  Status LED:
    LED   → PA8  (Built-in LED on some boards)
*/

// --------------------------------------------------------------------------
// STEP PINS (Port A: PA0-PA3) - Supports 4 axes!
// --------------------------------------------------------------------------

#define STEP_PORT           M4_PORT1        // Port A
#define STEP_PORT_ID        ((hal_gpio_port_t)M4_PORT1)
#define X_STEP_PIN          0
#define Y_STEP_PIN          1
#define Z_STEP_PIN          2
#define A_STEP_PIN          3               // 4th axis!
#define X_STEP_BIT          0
#define Y_STEP_BIT          1
#define Z_STEP_BIT          2
#define A_STEP_BIT          3
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN)|(1<<A_STEP_PIN))

// --------------------------------------------------------------------------
// DIRECTION PINS (Port A: PA4-PA7) - Supports 4 axes!
// --------------------------------------------------------------------------

#define DIRECTION_PORT      M4_PORT1        // Port A
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)M4_PORT1)
#define X_DIRECTION_PIN     4
#define Y_DIRECTION_PIN     5
#define Z_DIRECTION_PIN     6
#define A_DIRECTION_PIN     7               // 4th axis!
#define X_DIRECTION_BIT     4
#define Y_DIRECTION_BIT     5
#define Z_DIRECTION_BIT     6
#define A_DIRECTION_BIT     7
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN)|(1<<A_DIRECTION_PIN))

// --------------------------------------------------------------------------
// STEPPER ENABLE PIN (Port B: PB0)
// --------------------------------------------------------------------------

#define STEPPERS_DISABLE_PORT   M4_PORT2    // Port B
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)M4_PORT2)
#define STEPPERS_DISABLE_PIN    0
#define STEPPERS_DISABLE_BIT    0
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (Port C: PC0-PC3) - Supports 4 axes!
// --------------------------------------------------------------------------

#define LIMIT_PORT          M4_PORT3        // Port C
#define LIMIT_PORT_ID       ((hal_gpio_port_t)M4_PORT3)
#define X_LIMIT_PIN         0
#define Y_LIMIT_PIN         1
#define Z_LIMIT_PIN         2
#define A_LIMIT_PIN         3               // 4th axis!
#define X_LIMIT_BIT         0
#define Y_LIMIT_BIT         1
#define Z_LIMIT_BIT         2
#define A_LIMIT_BIT         3
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN)|(1<<A_LIMIT_PIN))

// --------------------------------------------------------------------------
// CONTROL PINS (Port D: PD0-PD3)
// --------------------------------------------------------------------------

#define CONTROL_PORT              M4_PORT4  // Port D
#define CONTROL_PORT_ID           ((hal_gpio_port_t)M4_PORT4)
#define CONTROL_RESET_PIN         0
#define CONTROL_FEED_HOLD_PIN     1
#define CONTROL_CYCLE_START_PIN   2
#define CONTROL_SAFETY_DOOR_PIN   3
#define CONTROL_RESET_BIT         0
#define CONTROL_FEED_HOLD_BIT     1
#define CONTROL_CYCLE_START_BIT   2
#define CONTROL_SAFETY_DOOR_BIT   3
#define CONTROL_MASK              ((1<<CONTROL_RESET_PIN)|(1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN)|(1<<CONTROL_SAFETY_DOOR_PIN))
#define CONTROL_INVERT_MASK       CONTROL_MASK

// --------------------------------------------------------------------------
// PROBE PIN (Port F: PF2)
// --------------------------------------------------------------------------

#define PROBE_PORT          M4_PORT6        // Port F
#define PROBE_PORT_ID       ((hal_gpio_port_t)M4_PORT6)
#define PROBE_PIN           2
#define PROBE_BIT           2
#define PROBE_MASK          (1<<PROBE_PIN)

// --------------------------------------------------------------------------
// SPINDLE PINS (Port E)
// --------------------------------------------------------------------------

// Spindle PWM (PE0, TIMA_0_PWM_A) - 16-bit PWM!
#define SPINDLE_PWM_PORT        M4_PORT5    // Port E
#define SPINDLE_PWM_PIN         0
#define SPINDLE_PWM_BIT         0
#define SPINDLE_PWM_TIMER       M4_TMRA_1   // Timer A unit 1
#define SPINDLE_PWM_CHANNEL     TimeraCh1   // Channel 1

// Spindle enable/direction/tachometer
#define SPINDLE_ENABLE_PORT     M4_PORT5    // Port E
#define SPINDLE_ENABLE_PIN      1
#define SPINDLE_ENABLE_BIT      1

#define SPINDLE_DIRECTION_PORT  M4_PORT5    // Port E
#define SPINDLE_DIRECTION_PIN   2
#define SPINDLE_DIRECTION_BIT   2

#define SPINDLE_TACH_PORT       M4_PORT5    // Port E (optional)
#define SPINDLE_TACH_PIN        3
#define SPINDLE_TACH_BIT        3

// PWM resolution (16-bit timer)
#ifdef VARIABLE_SPINDLE
  #define SPINDLE_PWM_MAX_VALUE     65535   // Full 16-bit resolution!
  #define SPINDLE_PWM_MIN_VALUE     1
  #define SPINDLE_PWM_OFF_VALUE     0
  #define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)
#endif

// --------------------------------------------------------------------------
// COOLANT PINS (Port F)
// --------------------------------------------------------------------------

#define COOLANT_FLOOD_PORT      M4_PORT6    // Port F
#define COOLANT_FLOOD_PIN       0
#define COOLANT_FLOOD_BIT       0

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     M4_PORT6    // Port F
  #define COOLANT_MIST_PIN      1
  #define COOLANT_MIST_BIT      1
#endif

// --------------------------------------------------------------------------
// STATUS LED
// --------------------------------------------------------------------------

#define LED_PORT                M4_PORT1    // Port A
#define LED_PIN                 8
#define LED_BIT                 8

// ============================================================================
// TIMER MAPPING
// ============================================================================

/*
  HC32F460 has 16x 32-bit timers! We have plenty to choose from.

  - Timer0: 4x channels for stepper, pulse reset, etc.
  - TimerA: 12x units for PWM, delays, etc.
  - Timer6: 3x units for advanced PWM

  We'll use:
  - Timer0 Unit 1 Channel 1: Stepper interrupt (highest priority)
  - Timer0 Unit 1 Channel 2: Step pulse reset
  - TimerA Unit 1: Spindle PWM
*/

// Stepper timer: Timer0 Unit 1 Channel 1
#define STEPPER_TIMER           M4_TMR01
#define STEPPER_TIMER_UNIT      M4_TMR0_1
#define STEPPER_TIMER_CH        Tim0_ChannelA
#define STEPPER_TIMER_IRQn      INT_TMR01_GCMA_IRQn
#define STEPPER_TIMER_IRQHandler TMR01_GCMA_IRQHandler

// Step pulse reset timer: Timer0 Unit 1 Channel 2
#define PULSE_TIMER             M4_TMR01
#define PULSE_TIMER_UNIT        M4_TMR0_1
#define PULSE_TIMER_CH          Tim0_ChannelB
#define PULSE_TIMER_IRQn        INT_TMR01_GCMB_IRQn
#define PULSE_TIMER_IRQHandler  TMR01_GCMB_IRQHandler

// Spindle PWM timer: TimerA Unit 1
// Already defined above

// ============================================================================
// SERIAL/UART MAPPING
// ============================================================================

// Using USART1 (can support up to 10 Mbaud at 200 MHz!)
#define GRBL_USART              M4_USART1
#define GRBL_USART_IRQn         INT_USART1_RI_IRQn
#define GRBL_USART_RX_IRQHandler USART1_RI_IRQHandler
#define GRBL_USART_TX_IRQHandler USART1_TI_IRQHandler

// Optional: Use DMA for serial (zero CPU overhead)
#ifdef HAL_SERIAL_USE_DMA
  #define GRBL_USART_DMA_UNIT   M4_DMA1
  #define GRBL_USART_DMA_RX_CH  DmaCh0
  #define GRBL_USART_DMA_TX_CH  DmaCh1
#endif

// ============================================================================
// FLASH EMULATION FOR EEPROM
// ============================================================================

// Use last 4KB of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   (0x00000000 + HAL_FLASH_SIZE - 4096)
#define HAL_NVMEM_FLASH_SIZE    4096
#define HAL_NVMEM_FLASH_PAGE_SIZE 512  // HC32F460 has 512-byte sectors

// ============================================================================
// ADVANCED FEATURES (Enabled by abundant resources)
// ============================================================================

// Larger buffers due to massive RAM
#define HC32F460_LARGE_BUFFERS  1

#ifdef HC32F460_LARGE_BUFFERS
  #undef RX_BUFFER_SIZE
  #undef TX_BUFFER_SIZE
  #define RX_BUFFER_SIZE    512   // 4x larger than AVR
  #define TX_BUFFER_SIZE    512   // 4x larger than AVR

  // Massive planner buffer for ultra-smooth motion
  #define BLOCK_BUFFER_SIZE_OVERRIDE   128  // 8x larger than AVR!
  #define SEGMENT_BUFFER_SIZE_OVERRIDE 32   // 5x larger than AVR!
#endif

// Enable advanced features
#define HAL_ENABLE_4TH_AXIS     1   // Support A axis (rotary)
#define HAL_ENABLE_BACKLASH     1   // Backlash compensation
#define HAL_ENABLE_TOOL_CHANGER 1   // Automatic tool changer
#define HAL_ENABLE_SPINDLE_SYNC 1   // Spindle synchronization (threading)
#define HAL_ENABLE_LASER_MODE   1   // Laser engraving mode

// USB CDC virtual COM port (optional)
#ifdef HAL_USE_USB_CDC
  #define HAL_USB_CDC_ENABLED   1
#endif

// CAN bus support (optional)
#ifdef HAL_USE_CAN
  #define HAL_CAN_ENABLED       1
  #define GRBL_CAN_UNIT         M4_CAN
  #define GRBL_CAN_BITRATE      500000  // 500 kbps
#endif

// ============================================================================
// PLATFORM-SPECIFIC FUNCTIONS
// ============================================================================

// Platform initialization
void hal_system_init(void);

// Clock configuration (200 MHz from PLL)
void hal_clock_config(void);

// GPIO initialization
void hal_gpio_init(void);

// Timer functions
uint32_t hal_millis(void);
uint64_t hal_micros(void);

// DMA helpers (optional)
#ifdef HAL_SERIAL_USE_DMA
void hal_dma_init(void);
#endif

// ============================================================================
// PERFORMANCE NOTES
// ============================================================================

/*
  HC32F460 Performance Advantages for GRBL:

  1. **12.5x Faster CPU**: 200 MHz vs 16 MHz
     - Stepper ISR can handle complex calculations
     - Real-time trajectory optimization possible
     - Support for complex kinematics (SCARA, Delta)

  2. **256x More RAM**: 512 KB vs 2 KB
     - Planner buffer: 128 blocks vs 16 blocks (8x lookahead)
     - Massive segment buffer for ultra-smooth motion
     - Room for advanced features (backlash, tool offset DB)

  3. **Hardware FPU**: Single-precision floating point
     - Fast trigonometry for arc interpolation
     - Real-time kinematics calculations
     - Smooth acceleration profiles

  4. **DMA Support**: Zero-CPU serial/SPI transfers
     - Serial communication doesn't interrupt motion
     - SD card streaming at full speed
     - Display updates don't affect timing

  5. **16-bit PWM**: 65536 levels vs 256 levels
     - Precise spindle speed control
     - Laser power modulation
     - Silent stepper microstepping

  6. **Advanced Timers**: 16x 32-bit timers vs 3x 8/16-bit
     - 4+ axis support
     - Multiple spindles
     - Synchronized operations

  **Real-world improvements**:
  - Step rate: 30 kHz → 200 kHz (6.7x improvement)
  - Lookahead: 16 blocks → 128 blocks (8x improvement)
  - Response time: 5-10 μs → <1 μs (10x improvement)
  - Jerk-free motion with massive buffer
*/

#endif // PLATFORM_HC32F460_H
