/*
  platform.h - STM32F103 platform configuration
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  This file provides platform-specific definitions for STM32F103 (Blue Pill).
  ARM Cortex-M3, 72 MHz, 20KB RAM, 64-128KB Flash
*/

#ifndef PLATFORM_STM32F103_H
#define PLATFORM_STM32F103_H

// ============================================================================
// PLATFORM IDENTIFICATION
// ============================================================================

#define PLATFORM_NAME     "STM32F103C8T6"
#define PLATFORM_CPU      "ARM Cortex-M3"
#define PLATFORM_ARCH     "ARM"

// ============================================================================
// PLATFORM CAPABILITIES
// ============================================================================

#define HAL_HAS_FPU           0   // Cortex-M3 has no FPU
#define HAL_HAS_DMA           1   // 7 DMA channels
#define HAL_HAS_USB           0   // No USB (F103x8/xB)
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define HAL_HAS_HW_DIVIDE     1   // Hardware divider

// ============================================================================
// PLATFORM SPECIFICATIONS
// ============================================================================

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        72000000UL  // 72 MHz
#endif

#define HAL_RAM_SIZE          20480       // 20 KB
#define HAL_FLASH_SIZE        65536       // 64 KB (or 128KB on some chips)
#define HAL_EEPROM_SIZE       0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   13      // 13.9 ns @ 72 MHz

// ============================================================================
// STM32 REGISTER DEFINITIONS
// ============================================================================

// REVIEW: CRITICAL #2 - Use minimal register definitions to avoid CMSIS dependency
// This allows GRBL to build standalone without external CMSIS pack
#include "regs.h"

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS
// ============================================================================

/*
  STM32F103C8T6 (Blue Pill) Pin Mapping for GRBL:

  Step pins (fast GPIO):
    X_STEP   → PA0  (GPIOA, Pin 0)
    Y_STEP   → PA1  (GPIOA, Pin 1)
    Z_STEP   → PA2  (GPIOA, Pin 2)

  Direction pins:
    X_DIR    → PA3  (GPIOA, Pin 3)
    Y_DIR    → PA4  (GPIOA, Pin 4)
    Z_DIR    → PA5  (GPIOA, Pin 5)

  Stepper enable:
    ENABLE   → PA6  (GPIOA, Pin 6, active low)

  Limit switches (with EXTI interrupts):
    X_LIMIT  → PB0  (GPIOB, Pin 0, EXTI0)
    Y_LIMIT  → PB1  (GPIOB, Pin 1, EXTI1)
    Z_LIMIT  → PB10 (GPIOB, Pin 10, EXTI10)

  Control pins (with EXTI interrupts):
    RESET       → PB3  (GPIOB, Pin 3, EXTI3)
    FEED_HOLD   → PB4  (GPIOB, Pin 4, EXTI4)
    CYCLE_START → PB5  (GPIOB, Pin 5, EXTI5)
    SAFETY_DOOR → PB6  (GPIOB, Pin 6, EXTI6)

  Spindle control:
    SPINDLE_PWM    → PA8  (GPIOA, Pin 8, TIM1_CH1 PWM)
    SPINDLE_ENABLE → PB12 (GPIOB, Pin 12)
    SPINDLE_DIR    → PB13 (GPIOB, Pin 13)

  Coolant control:
    COOLANT_FLOOD → PC13 (GPIOC, Pin 13, onboard LED)
    COOLANT_MIST  → PC14 (GPIOC, Pin 14)

  Probe:
    PROBE → PC15 (GPIOC, Pin 15)

  UART (Serial):
    TX    → PA9  (USART1_TX)
    RX    → PA10 (USART1_RX)

  Programming/Debug:
    SWDIO → PA13 (Serial Wire Debug)
    SWCLK → PA14 (Serial Wire Clock)
*/

// --------------------------------------------------------------------------
// STEP PINS (GPIOA: PA0, PA1, PA2)
// --------------------------------------------------------------------------

#define STEP_PORT           GPIOA
#define STEP_PORT_ID        ((hal_gpio_port_t)GPIOA)
#define X_STEP_PIN          0
#define Y_STEP_PIN          1
#define Z_STEP_PIN          2
#define X_STEP_BIT          0
#define Y_STEP_BIT          1
#define Z_STEP_BIT          2
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))

// --------------------------------------------------------------------------
// DIRECTION PINS (GPIOA: PA3, PA4, PA5)
// --------------------------------------------------------------------------

#define DIRECTION_PORT      GPIOA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)GPIOA)
#define X_DIRECTION_PIN     3
#define Y_DIRECTION_PIN     4
#define Z_DIRECTION_PIN     5
#define X_DIRECTION_BIT     3
#define Y_DIRECTION_BIT     4
#define Z_DIRECTION_BIT     5
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

// --------------------------------------------------------------------------
// STEPPER ENABLE PIN (GPIOA: PA6)
// --------------------------------------------------------------------------

#define STEPPERS_DISABLE_PORT   GPIOA
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)GPIOA)
#define STEPPERS_DISABLE_PIN    6
#define STEPPERS_DISABLE_BIT    6
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// --------------------------------------------------------------------------
// LIMIT SWITCH PINS (GPIOB: PB0, PB1, PB10)
// --------------------------------------------------------------------------

#define LIMIT_PORT          GPIOB
#define LIMIT_PORT_ID       ((hal_gpio_port_t)GPIOB)
#define X_LIMIT_PIN         0
#define Y_LIMIT_PIN         1
#define Z_LIMIT_PIN         10
#define X_LIMIT_BIT         0
#define Y_LIMIT_BIT         1
#define Z_LIMIT_BIT         10
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))

// EXTI lines for limit switches
#define LIMIT_EXTI_LINE_X   EXTI_Line0
#define LIMIT_EXTI_LINE_Y   EXTI_Line1
#define LIMIT_EXTI_LINE_Z   EXTI_Line10

// --------------------------------------------------------------------------
// CONTROL PINS (GPIOB: PB3, PB4, PB5, PB6)
// --------------------------------------------------------------------------

#define CONTROL_PORT              GPIOB
#define CONTROL_PORT_ID           ((hal_gpio_port_t)GPIOB)
#define CONTROL_RESET_PIN         3
#define CONTROL_FEED_HOLD_PIN     4
#define CONTROL_CYCLE_START_PIN   5
#define CONTROL_SAFETY_DOOR_PIN   6
#define CONTROL_RESET_BIT         3
#define CONTROL_FEED_HOLD_BIT     4
#define CONTROL_CYCLE_START_BIT   5
#define CONTROL_SAFETY_DOOR_BIT   6
#define CONTROL_MASK              ((1<<CONTROL_RESET_PIN)|(1<<CONTROL_FEED_HOLD_PIN)|(1<<CONTROL_CYCLE_START_PIN)|(1<<CONTROL_SAFETY_DOOR_PIN))
#define CONTROL_INVERT_MASK       CONTROL_MASK

// EXTI lines for control pins
#define CONTROL_EXTI_LINE_RESET       EXTI_Line3
#define CONTROL_EXTI_LINE_FEED_HOLD   EXTI_Line4
#define CONTROL_EXTI_LINE_CYCLE_START EXTI_Line5
#define CONTROL_EXTI_LINE_SAFETY_DOOR EXTI_Line6

// --------------------------------------------------------------------------
// PROBE PIN (GPIOC: PC15)
// --------------------------------------------------------------------------

#define PROBE_PORT          GPIOC
#define PROBE_PORT_ID       ((hal_gpio_port_t)GPIOC)
#define PROBE_PIN           15
#define PROBE_BIT           15
#define PROBE_MASK          (1<<PROBE_PIN)

// --------------------------------------------------------------------------
// SPINDLE PINS
// --------------------------------------------------------------------------

// Spindle PWM (PA8, TIM1_CH1)
#define SPINDLE_PWM_PORT        GPIOA
#define SPINDLE_PWM_PIN         8
#define SPINDLE_PWM_BIT         8
#define SPINDLE_PWM_TIMER       TIM1
#define SPINDLE_PWM_CHANNEL     1
#define SPINDLE_PWM_AF          GPIO_AF1_TIM1  // Alternate function

// Spindle enable/direction (GPIOB: PB12, PB13)
#define SPINDLE_ENABLE_PORT     GPIOB
#define SPINDLE_ENABLE_PIN      12
#define SPINDLE_ENABLE_BIT      12
#define SPINDLE_DIRECTION_PORT  GPIOB
#define SPINDLE_DIRECTION_PIN   13
#define SPINDLE_DIRECTION_BIT   13

// PWM resolution (16-bit timer)
#ifdef VARIABLE_SPINDLE
  #define SPINDLE_PWM_MAX_VALUE     65535  // 16-bit PWM
  #define SPINDLE_PWM_MIN_VALUE     1
  #define SPINDLE_PWM_OFF_VALUE     0
  #define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)
#endif

// --------------------------------------------------------------------------
// COOLANT PINS (GPIOC: PC13, PC14)
// --------------------------------------------------------------------------

#define COOLANT_FLOOD_PORT      GPIOC
#define COOLANT_FLOOD_PIN       13
#define COOLANT_FLOOD_BIT       13

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     GPIOC
  #define COOLANT_MIST_PIN      14
  #define COOLANT_MIST_BIT      14
#endif

// ============================================================================
// TIMER MAPPING
// ============================================================================

// Stepper timer: TIM2 (32-bit general purpose timer)
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

// Use last 2 pages of flash for EEPROM emulation
#define HAL_NVMEM_FLASH_START   0x0800F800  // Last 2KB of 64KB flash
#define HAL_NVMEM_FLASH_SIZE    2048
#define HAL_NVMEM_FLASH_PAGE_SIZE 1024

// ============================================================================
// PLATFORM INFO STRUCTURE
// ============================================================================

extern const hal_platform_info_t stm32_platform_info;

const hal_platform_info_t* hal_platform_get_info(void);

// ============================================================================
// HAL GPIO MACROS
// ============================================================================

// Basic GPIO operations (optimized for STM32 BSRR register)
#define HAL_GPIO_SET_BITS(port, mask)           ((port)->BSRR = (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)         ((port)->BSRR = ((uint32_t)(mask) << 16))
#define HAL_GPIO_TOGGLE_BITS(port, mask)        ((port)->ODR ^= (mask))
#define HAL_GPIO_WRITE_PORT(port, mask, value)  ((port)->BSRR = (((port)->ODR & (mask)) << 16) | ((value) & (mask)))
#define HAL_GPIO_READ_PORT(port, mask)          ((port)->ODR & (mask))
#define HAL_GPIO_READ_PIN(pin, mask)            ((pin)->IDR & (mask))
#define HAL_GPIO_WRITE_DIRECT(port, value)      ((port)->ODR = (value))

// GPIO direction configuration (via CRL/CRH registers)
// For STM32, we need functions not macros
void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_SET_OUTPUT(port, mask)         hal_gpio_set_output((port), (mask))
#define HAL_GPIO_SET_INPUT(port, mask)          hal_gpio_set_input((port), (mask))

// Pull-up resistor control (STM32 uses CRL/CRH config)
void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_PULLUP_ENABLE(port, mask)      hal_gpio_pullup_enable((port), (mask))
#define HAL_GPIO_PULLUP_DISABLE(port, mask)     hal_gpio_pullup_disable((port), (mask))

// EXTI interrupt configuration
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_INTERRUPT_ENABLE(port, pcie, mask)   hal_gpio_interrupt_enable((port), (mask))
#define HAL_GPIO_INTERRUPT_DISABLE(port, pcie, mask)  hal_gpio_interrupt_disable((port), (mask))

// ============================================================================
// HAL TIMER MACROS
// ============================================================================

// ----------------------------------------------------------------------------
// TIM2: Stepper Driver Interrupt (32-bit timer for high resolution)
// ----------------------------------------------------------------------------

#define HAL_TIMER_STEPPER_ISR()                 void TIM2_IRQHandler(void)

void hal_timer_stepper_init(void);
#define HAL_TIMER_STEPPER_INIT()                hal_timer_stepper_init()

#define HAL_TIMER_STEPPER_SET_PERIOD(cycles)    (TIM2->ARR = (cycles))
#define HAL_TIMER_STEPPER_GET_PERIOD()          (TIM2->ARR)
#define HAL_TIMER_STEPPER_GET_COUNT()           (TIM2->CNT)

void hal_timer_stepper_set_prescaler(uint16_t prescaler);
#define HAL_TIMER_STEPPER_SET_PRESCALER(prescaler)  hal_timer_stepper_set_prescaler(prescaler)
#define HAL_TIMER_STEPPER_RESET_PRESCALER()         hal_timer_stepper_set_prescaler(0)

#define HAL_TIMER_STEPPER_INTERRUPT_ENABLE()    (TIM2->DIER |= TIM_DIER_UIE)
#define HAL_TIMER_STEPPER_INTERRUPT_DISABLE()   (TIM2->DIER &= ~TIM_DIER_UIE)

// Clear interrupt flag in ISR
// FIXED: Was (TIM2->SR = ~TIM_SR_UIF) which SETS all other flags causing interrupt storm!
// REVIEW: CRITICAL #3 - Timer interrupt flag clearing bug
#define HAL_TIMER_STEPPER_CLEAR_FLAG()          (TIM2->SR = 0)

// ----------------------------------------------------------------------------
// TIM3: Step Pulse Reset Interrupt
// ----------------------------------------------------------------------------

#define HAL_TIMER_PULSE_RESET_ISR()             void TIM3_IRQHandler(void)

void hal_timer_pulse_reset_init(void);
#define HAL_TIMER_PULSE_RESET_INIT()            hal_timer_pulse_reset_init()

#define HAL_TIMER_PULSE_RESET_SET_COUNT(count)  (TIM3->CNT = (count))
#define HAL_TIMER_PULSE_RESET_SET_COMPARE(val)  (TIM3->ARR = (val))
#define HAL_TIMER_PULSE_RESET_START()           (TIM3->CR1 |= TIM_CR1_CEN)
#define HAL_TIMER_PULSE_RESET_STOP()            (TIM3->CR1 &= ~TIM_CR1_CEN)

// Clear interrupt flag
// FIXED: Was (TIM3->SR = ~TIM_SR_UIF) - same interrupt storm bug as TIM2
// REVIEW: CRITICAL #3 - Timer interrupt flag clearing bug
#define HAL_TIMER_PULSE_RESET_CLEAR_FLAG()      (TIM3->SR = 0)

// Step pulse delay (if STEP_PULSE_DELAY is defined)
#ifdef STEP_PULSE_DELAY
  #define HAL_TIMER_PULSE_DELAY_ISR()           void TIM4_IRQHandler(void)
  void hal_timer_pulse_delay_init(void);
  #define HAL_TIMER_PULSE_DELAY_INIT()          hal_timer_pulse_delay_init()
#endif

// ----------------------------------------------------------------------------
// TIM1: Spindle PWM (16-bit advanced timer with PWM on CH1)
// ----------------------------------------------------------------------------

#ifdef VARIABLE_SPINDLE

void hal_timer_spindle_pwm_init(void);
#define HAL_TIMER_SPINDLE_PWM_INIT()            hal_timer_spindle_pwm_init()

#define HAL_TIMER_SPINDLE_PWM_SET_DUTY(duty)    (TIM1->CCR1 = (duty))
#define HAL_TIMER_SPINDLE_PWM_GET_DUTY()        (TIM1->CCR1)

#define HAL_TIMER_SPINDLE_PWM_ENABLE()          (TIM1->CCER |= TIM_CCER_CC1E)
#define HAL_TIMER_SPINDLE_PWM_DISABLE()         (TIM1->CCER &= ~TIM_CCER_CC1E)
#define HAL_TIMER_SPINDLE_PWM_IS_ENABLED()      (TIM1->CCER & TIM_CCER_CC1E)

#endif // VARIABLE_SPINDLE

// ============================================================================
// HAL SERIAL/UART MACROS
// ============================================================================

#define HAL_SERIAL_RX_BUFFER_SIZE               128
#define HAL_SERIAL_TX_BUFFER_SIZE               64

// Serial ISR definitions
#define HAL_SERIAL_RX_ISR()                     void USART1_IRQHandler(void)
#define HAL_SERIAL_TX_ISR()                     void USART1_IRQHandler(void)

// Serial initialization
void hal_serial_init(uint32_t baud_rate);
#define HAL_SERIAL_INIT()                       hal_serial_init(BAUD_RATE)

// Serial data register access
#define HAL_SERIAL_WRITE_DATA(data)             (USART1->DR = (data))
#define HAL_SERIAL_READ_DATA()                  (USART1->DR)

// Serial interrupt control
#define HAL_SERIAL_TX_INTERRUPT_ENABLE()        (USART1->CR1 |= USART_CR1_TXEIE)
#define HAL_SERIAL_TX_INTERRUPT_DISABLE()       (USART1->CR1 &= ~USART_CR1_TXEIE)

// Serial status flags
#define HAL_SERIAL_RX_READY()                   (USART1->SR & USART_SR_RXNE)
#define HAL_SERIAL_TX_READY()                   (USART1->SR & USART_SR_TXE)

// ============================================================================
// HAL SYSTEM MACROS
// ============================================================================

// Interrupt control
#define HAL_ENABLE_INTERRUPTS()                 __enable_irq()
#define HAL_DISABLE_INTERRUPTS()                __disable_irq()

// Critical section
#define HAL_CRITICAL_SECTION_START()            uint32_t __primask = __get_PRIMASK(); __disable_irq()
#define HAL_CRITICAL_SECTION_END()              __set_PRIMASK(__primask)

// Delay functions
void hal_delay_ms(uint32_t ms);
void hal_delay_us(uint32_t us);

#define HAL_DELAY_MS(ms)                        hal_delay_ms(ms)
#define HAL_DELAY_US(us)                        hal_delay_us(us)

// System time (milliseconds since boot)
uint32_t hal_millis(void);
uint64_t hal_micros(void);

#define HAL_MILLIS()                            hal_millis()
#define HAL_MICROS()                            hal_micros()

// Watchdog timer (optional, enable with -DENABLE_WATCHDOG)
void hal_watchdog_init(void);
void hal_watchdog_refresh(void);

#define HAL_WATCHDOG_REFRESH()                  hal_watchdog_refresh()

// ============================================================================
// HAL NVMEM MACROS (Flash emulation)
// ============================================================================

// Implemented in hal/hal_nvmem.h, but functions are platform-specific
unsigned char hal_nvmem_read_byte(unsigned int addr);
void hal_nvmem_write_byte(unsigned int addr, unsigned char data);

// Map to standard eeprom function names
#define eeprom_get_char(addr)                   hal_nvmem_read_byte(addr)
#define eeprom_put_char(addr, data)             hal_nvmem_write_byte(addr, data)

// ============================================================================
// PLATFORM-SPECIFIC FUNCTIONS
// ============================================================================

// Platform initialization
void hal_system_init(void);

// Clock configuration (HSE 8MHz → PLL 72MHz)
void hal_clock_config(void);

// GPIO initialization (all pins for GRBL)
void hal_gpio_init(void);

// NVMEM (Flash emulation) functions
void hal_nvmem_init(void);
void hal_nvmem_flush(void);  // Flush dirty cache to flash

// ============================================================================
// PLATFORM INFO STRUCTURE
// ============================================================================

typedef struct {
  const char* platform_name;
  const char* cpu_name;
  const char* arch_name;
  uint32_t cpu_freq;
  uint32_t ram_size;
  uint32_t flash_size;
  uint8_t has_fpu;
  uint8_t has_dma;
  uint8_t has_usb;
  uint8_t has_hw_eeprom;
} hal_platform_info_t;

extern const hal_platform_info_t stm32_platform_info;
const hal_platform_info_t* hal_platform_get_info(void);

#endif // PLATFORM_STM32F103_H
