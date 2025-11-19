/*
  platform.h - SG2002 platform HAL definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Sophgo SG2002 (RISC-V C906) HAL implementation for LicheeRV-Nano
*/

#ifndef SG2002_PLATFORM_H
#define SG2002_PLATFORM_H

#include <stdint.h>
#include <stdbool.h>
#include "regs.h"

// Define platform identifier
#define PLATFORM_SG2002 1

// ============================================================================
// PIN MAPPING - GPIO DEFINITIONS (LicheeRV-Nano)
// ============================================================================

// Stepper motor step pins (GPIO0)
#define X_STEP_PORT      GPIO0
#define X_STEP_PIN       0
#define Y_STEP_PORT      GPIO0
#define Y_STEP_PIN       1
#define Z_STEP_PORT      GPIO0
#define Z_STEP_PIN       2

// Stepper motor direction pins (GPIO0)
#define X_DIR_PORT       GPIO0
#define X_DIR_PIN        3
#define Y_DIR_PORT       GPIO0
#define Y_DIR_PIN        4
#define Z_DIR_PORT       GPIO0
#define Z_DIR_PIN        5

// Stepper enable pin (all axes)
#define STEPPERS_DISABLE_PORT  GPIO0
#define STEPPERS_DISABLE_PIN   6

// Limit switch pins (GPIO1)
#define X_LIMIT_PORT     GPIO1
#define X_LIMIT_PIN      0
#define Y_LIMIT_PORT     GPIO1
#define Y_LIMIT_PIN      1
#define Z_LIMIT_PORT     GPIO1
#define Z_LIMIT_PIN      2

// Control pins (GPIO1)
#define CONTROL_RESET_PORT       GPIO1
#define CONTROL_RESET_PIN        3
#define CONTROL_FEED_HOLD_PORT   GPIO1
#define CONTROL_FEED_HOLD_PIN    4
#define CONTROL_CYCLE_START_PORT GPIO1
#define CONTROL_CYCLE_START_PIN  5
#define CONTROL_SAFETY_DOOR_PORT GPIO1
#define CONTROL_SAFETY_DOOR_PIN  6

// Spindle pins (GPIO2)
#define SPINDLE_ENABLE_PORT      GPIO2
#define SPINDLE_ENABLE_PIN       0
#define SPINDLE_DIRECTION_PORT   GPIO2
#define SPINDLE_DIRECTION_PIN    1
#define SPINDLE_PWM_PORT         GPIO2
#define SPINDLE_PWM_PIN          2

// Coolant pins (GPIO2)
#define COOLANT_FLOOD_PORT       GPIO2
#define COOLANT_FLOOD_PIN        3
#define COOLANT_MIST_PORT        GPIO2
#define COOLANT_MIST_PIN         4

// Probe pin (GPIO2)
#define PROBE_PORT               GPIO2
#define PROBE_PIN                5

// Pin masks
#define STEP_MASK          ((1UL << X_STEP_PIN) | (1UL << Y_STEP_PIN) | (1UL << Z_STEP_PIN))
#define DIRECTION_MASK     ((1UL << X_DIR_PIN) | (1UL << Y_DIR_PIN) | (1UL << Z_DIR_PIN))
#define STEPPERS_DISABLE_MASK  (1UL << STEPPERS_DISABLE_PIN)
#define LIMIT_MASK         ((1UL << X_LIMIT_PIN) | (1UL << Y_LIMIT_PIN) | (1UL << Z_LIMIT_PIN))
#define CONTROL_MASK       ((1UL << CONTROL_RESET_PIN) | (1UL << CONTROL_FEED_HOLD_PIN) | \
                            (1UL << CONTROL_CYCLE_START_PIN) | (1UL << CONTROL_SAFETY_DOOR_PIN))
#define PROBE_MASK         (1UL << PROBE_PIN)

// ============================================================================
// HAL GPIO MACROS
// ============================================================================

// GPIO port type
typedef GPIO_TypeDef* hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// GPIO direction
#define HAL_GPIO_SET_OUTPUT(port, mask)  ((port)->SWPORTA_DDR |= (mask))
#define HAL_GPIO_SET_INPUT(port, mask)   ((port)->SWPORTA_DDR &= ~(mask))

// GPIO write
#define HAL_GPIO_SET_BITS(port, mask)    ((port)->SWPORTA_DR |= (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)  ((port)->SWPORTA_DR &= ~(mask))
#define HAL_GPIO_TOGGLE_BITS(port, mask) ((port)->SWPORTA_DR ^= (mask))

// GPIO read
#define HAL_GPIO_READ_PORT(port, mask)   ((port)->SWPORTA_DR & (mask))
#define HAL_GPIO_READ_PIN(port, pin)     (((port)->SWPORTA_DR >> (pin)) & 1)

// GPIO write port with mask
#define HAL_GPIO_WRITE_PORT(port, mask, value) \
  do { \
    uint32_t _tmp = (port)->SWPORTA_DR; \
    _tmp = (_tmp & ~(mask)) | ((value) & (mask)); \
    (port)->SWPORTA_DR = _tmp; \
  } while(0)

// ============================================================================
// HAL SERIAL (UART) MACROS
// ============================================================================

// Use UART0 for GRBL communication
#define HAL_SERIAL_UART  UART0

// Serial initialization
void hal_serial_init(uint32_t baud_rate);
#define HAL_SERIAL_INIT()  hal_serial_init(115200)

// Serial data access
#define HAL_SERIAL_WRITE_DATA(data)  (HAL_SERIAL_UART->RBR_THR_DLL = (data))
#define HAL_SERIAL_READ_DATA()       (HAL_SERIAL_UART->RBR_THR_DLL)

// Serial status
#define HAL_SERIAL_RX_READY()        (HAL_SERIAL_UART->LSR & UART_LSR_DR)
#define HAL_SERIAL_TX_READY()        (HAL_SERIAL_UART->LSR & UART_LSR_THRE)

// Serial interrupts
#define HAL_SERIAL_RX_INTERRUPT_ENABLE()   (HAL_SERIAL_UART->DLH_IER |= UART_IER_ERBFI)
#define HAL_SERIAL_RX_INTERRUPT_DISABLE()  (HAL_SERIAL_UART->DLH_IER &= ~UART_IER_ERBFI)
#define HAL_SERIAL_TX_INTERRUPT_ENABLE()   (HAL_SERIAL_UART->DLH_IER |= UART_IER_ETBEI)
#define HAL_SERIAL_TX_INTERRUPT_DISABLE()  (HAL_SERIAL_UART->DLH_IER &= ~UART_IER_ETBEI)

// Serial ISR definitions
#define HAL_SERIAL_RX_ISR()  void uart0_rx_handler(void)
#define HAL_SERIAL_TX_ISR()  void uart0_tx_handler(void)

// ============================================================================
// HAL TIMER MACROS (for stepper interrupt)
// ============================================================================

// Use TIMER0 channel 0 for stepper interrupt
#define HAL_TIMER_STEPPER  (&TIMER0->TIMER[0])

// Timer initialization
void hal_timer_stepper_init(void);
#define HAL_TIMER_STEPPER_INIT()  hal_timer_stepper_init()

// Timer control
void hal_timer_stepper_start(void);
void hal_timer_stepper_stop(void);
void hal_timer_stepper_set_period(uint32_t ticks);
uint32_t hal_timer_stepper_get_count(void);

#define HAL_TIMER_STEPPER_START()         hal_timer_stepper_start()
#define HAL_TIMER_STEPPER_STOP()          hal_timer_stepper_stop()
#define HAL_TIMER_STEPPER_SET_PERIOD(t)   hal_timer_stepper_set_period(t)
#define HAL_TIMER_STEPPER_GET_COUNT()     hal_timer_stepper_get_count()

// Timer ISR
#define HAL_TIMER_STEPPER_ISR()  void timer0_ch0_handler(void)

// ============================================================================
// HAL SYSTEM MACROS
// ============================================================================

// Critical section
uint32_t hal_critical_enter(void);
void hal_critical_exit(uint32_t state);
extern uint32_t _hal_critical_state;

#define HAL_CRITICAL_SECTION_BEGIN()  _hal_critical_state = hal_critical_enter()
#define HAL_CRITICAL_SECTION_END()    hal_critical_exit(_hal_critical_state)

// Interrupts
#define HAL_ENABLE_INTERRUPTS()   enable_interrupts()
#define HAL_DISABLE_INTERRUPTS()  disable_interrupts()

// Delay functions
void hal_delay_ms(uint32_t ms);
void hal_delay_us(uint32_t us);

#define HAL_DELAY_MS(ms)  hal_delay_ms(ms)
#define HAL_DELAY_US(us)  hal_delay_us(us)

// System reset
void hal_system_reset(void);
#define HAL_SYSTEM_RESET()  hal_system_reset()

// ============================================================================
// HAL NVMEM MACROS (Non-volatile memory emulation)
// ============================================================================

#define HAL_NVMEM_SIZE  1024  // 1KB NVMEM for settings

void hal_nvmem_init(void);
uint8_t hal_nvmem_read_byte(uint32_t addr);
void hal_nvmem_write_byte(uint32_t addr, uint8_t data);

#define HAL_NVMEM_INIT()              hal_nvmem_init()
#define HAL_NVMEM_READ_BYTE(addr)     hal_nvmem_read_byte(addr)
#define HAL_NVMEM_WRITE_BYTE(addr, d) hal_nvmem_write_byte(addr, d)

// ============================================================================
// PLATFORM CONFIGURATION
// ============================================================================

// CPU frequency (700 MHz)
#define F_CPU  700000000UL

// Timer tick frequency
#define TIMER_PRESCALER  1
#define TIMER_TICKS_PER_MICROSECOND  (F_CPU / 1000000UL / TIMER_PRESCALER)

// Stepper pulse timing (microseconds)
#define STEP_PULSE_DELAY  10  // 10us step pulse

// Platform info
const char* hal_platform_get_name(void);
const char* hal_platform_get_cpu(void);
uint32_t hal_platform_get_cpu_freq(void);

// ============================================================================
// HAL INITIALIZATION
// ============================================================================

void hal_platform_init(void);

#endif // SG2002_PLATFORM_H
