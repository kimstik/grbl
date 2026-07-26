/*
  platform.h - HC32F460 platform HAL interface
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Platform-specific HAL interface for HC32F460JETA (HDSC/Huada, ARM
  Cortex-M4F, up to 200 MHz, up to 512KB Flash, up to 192KB SRAM).

  NOTE (Phase 6 rolling port #3): the file this replaces was a
  documentation skeleton only - marketing-comment blocks ("BEAST", "12.5x
  faster"), `#include "hc32_ddl.h"`/`"hc32f460.h"`/`"core_cm4.h"` pointing
  at a vendor SDK never vendored into this tree, and no Makefile/gpio.h/
  timer.h/regs.h/startup.c/platform.c/handlers.c/script.ld anywhere in the
  directory (`ls grbl/platform/hc32f460/` before this port: only a stub
  `avr/io.h` and this 460-line doc-only header). It never built. Per
  PORTING-CHECKLIST.md's "trust only builds" rule (three prior "complete"
  claims in this tree - stm32f103, stm32h523, stm32f411 - never having
  compiled before their real ports landed), none of its claims were
  carried forward without re-verification; this file replaces it entirely.

  Vendor-exotic disclosure: HC32F460 is HDSC/Huada silicon, not an
  STM32/SAMD clone. Its peripheral IP (TIMER0/TIMERA, GPIO PORT model,
  INTC event router, EFM flash, PWC/CMU clock tree) has no donor port in
  this tree. See regs.h's file header for the full verification
  methodology - facts are graded CONFIRMED (datasheet TOC + Klipper3d/
  klipper's real shipped GPL-3.0 firmware, cross-checked, not copied) vs
  UNVERIFIED placeholder (no register-level manual reachable this
  session).
*/

#ifndef PLATFORM_HC32F460_H
#define PLATFORM_HC32F460_H

/* hal.h pre-defines PLATFORM_NAME "HC32F460" before including this file;
   the board-specific name below is the intended final value. */
#undef PLATFORM_NAME
#define PLATFORM_NAME     "HC32F460JETA"
#define PLATFORM_CPU      "ARM Cortex-M4F"
#define PLATFORM_ARCH     "ARM"

/* ============================================================================
 * PLATFORM CAPABILITIES
 * ==========================================================================*/

#define HAL_HAS_FPU           1   /* Cortex-M4F: single-precision FPU */
#define HAL_HAS_DMA           1   /* 2x DMA controllers present in silicon, not wired by this port */
#define HAL_HAS_USB           1   /* USB FS present in silicon, not wired by this port */
#define HAL_HAS_HW_EEPROM     0   /* No hardware EEPROM - flash (EFM) emulation used */
#define HAL_HAS_HW_MULTIPLY   1
#define HAL_HAS_HW_DIVIDE     1

/* ============================================================================
 * PLATFORM SPECIFICATIONS
 * ==========================================================================*/

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        200000000UL   /* 200 MHz (Makefile CLOCK must match - Step 1 F_CPU lie trap) */
#endif

#define HAL_RAM_SIZE          131072    /* 128KB - conservative: smallest confirmed variant, see platform.md */
#define HAL_FLASH_SIZE        524288    /* 512KB - datasheet "up to 512KB Flash" */
#define HAL_EEPROM_SIZE       0

#define HAL_TIMER_RESOLUTION_NS   5     /* 5 ns @ 200 MHz */

/* ============================================================================
 * REGISTER DEFINITIONS (clean-room, see regs.h file header)
 * ==========================================================================*/

#include "regs.h"
#include "timer.h"

/* Define hal_gpio_port_t before hal_gpio.h includes it */
typedef HC32_PORT_TypeDef* hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

/* ============================================================================
 * PIN MAPPING - GPIO DEFINITIONS
 * ============================================================================
 *
 * Generic reference board (no specific commercial HC32F460 CNC board is
 * targeted - "generic" posture, same as ch32v006/boards/generic):
 *
 *   Step:               PA0, PA1, PA2  (X, Y, Z)
 *   Direction:           PA3, PA4, PA5
 *   Steppers disable:    PA6 (active low)
 *   Spindle PWM:         PA8  (TIMERA1 channel 1)
 *   Spindle enable/dir:  PA9, PA10
 *   Coolant flood/mist:  PA11, PA12 (mist optional, ENABLE_M7)
 *   Limits:              PB0, PB1, PB2 (X, Y, Z) - all bits 0-7 (section 1.3)
 *   Control:             PB3-PB6 (reset/feed hold/cycle start/safety door)
 *   Probe:               PB7
 *   Serial (USART1):     PC0 (TX), PC1 (RX) - matches Klipper's documented
 *                         alternate USART1 pin pair for this exact chip
 *                         ("Alternate: PC0/PC1 via LCD connector")
 *
 * LIMIT and CONTROL deliberately share ONE port (B) at non-overlapping bit
 * numbers 0-6, sidestepping the section 14 item 12 "EXTI/EIRQ line-number
 * collision" class entirely regardless of whether this chip's EIRQ model
 * turns out to be per-pin-number-shared-across-ports (STM32-style) or
 * fully independent - a defensive choice made because the real EIRQ model
 * is UNVERIFIED this session (regs.h).
 * --------------------------------------------------------------------------*/

#define STEP_PORT           GPIOA
#define STEP_PORT_ID        ((hal_gpio_port_t)GPIOA)
#define X_STEP_PIN          0
#define Y_STEP_PIN          1
#define Z_STEP_PIN          2
#define X_STEP_BIT          0
#define Y_STEP_BIT          1
#define Z_STEP_BIT          2
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))

#define DIRECTION_PORT      GPIOA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)GPIOA)
#define X_DIRECTION_PIN     3
#define Y_DIRECTION_PIN     4
#define Z_DIRECTION_PIN     5
#define X_DIRECTION_BIT     3
#define Y_DIRECTION_BIT     4
#define Z_DIRECTION_BIT     5
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

#define STEPPERS_DISABLE_PORT     GPIOA
#define STEPPERS_DISABLE_PORT_ID  ((hal_gpio_port_t)GPIOA)
#define STEPPERS_DISABLE_PIN      6
#define STEPPERS_DISABLE_BIT      6
#define STEPPERS_DISABLE_MASK     (1<<STEPPERS_DISABLE_PIN)

#define LIMIT_PORT          GPIOB
#define LIMIT_PORT_ID       ((hal_gpio_port_t)GPIOB)
#define X_LIMIT_PIN         0
#define Y_LIMIT_PIN         1
#define Z_LIMIT_PIN         2
#define X_LIMIT_BIT         0
#define Y_LIMIT_BIT         1
#define Z_LIMIT_BIT         2
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))

/* GPIO_INT_ON/OFF plumbing: core passes (name_PCMSK, name_INT, name_MASK) to
   HAL_GPIO_INTERRUPT_ENABLE/DISABLE; on this platform the first argument is
   the port, the second is unused (AVR PCIE bit). */
#define LIMIT_PCMSK         LIMIT_PORT
#define LIMIT_INT           0

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

#define CONTROL_PCMSK             CONTROL_PORT
#define CONTROL_INT               0

#define PROBE_PORT          GPIOB
#define PROBE_PORT_ID       ((hal_gpio_port_t)GPIOB)
#define PROBE_PIN           7
#define PROBE_BIT           7
#define PROBE_MASK          (1<<PROBE_PIN)

/* --------------------------------------------------------------------------
 * SPINDLE PINS
 * ------------------------------------------------------------------------*/

#define SPINDLE_PWM_PORT        GPIOA
#define SPINDLE_PWM_PIN         8
#define SPINDLE_PWM_BIT         8

#define SPINDLE_ENABLE_PORT     GPIOA
#define SPINDLE_ENABLE_PIN      9
#define SPINDLE_ENABLE_BIT      9
#define SPINDLE_DIRECTION_PORT  GPIOA
#define SPINDLE_DIRECTION_PIN   10
#define SPINDLE_DIRECTION_BIT   10

/* PWM duty domain: core plumbs duty as uint8_t end-to-end
   (spindle_control.c:122, CONTRACTS.md section 6.2) - full scale MUST fit
   uint8_t. SINGLE canon: config.h below must not redefine this macro
   (the "duty-cap twins" bug class that hit two prior ports). */
#define SPINDLE_PWM_MAX_VALUE     255
#define SPINDLE_PWM_MIN_VALUE     1
#define SPINDLE_PWM_OFF_VALUE     0
#define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

#define COOLANT_FLOOD_PORT      GPIOA
#define COOLANT_FLOOD_PIN       11
#define COOLANT_FLOOD_BIT       11

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     GPIOA
  #define COOLANT_MIST_PIN      12
  #define COOLANT_MIST_BIT      12
#endif

/* ============================================================================
 * TIMER MAPPING (see timer.h)
 * ==========================================================================*/

#define STEPPER_TIMER_IRQn        Int000_IRQn
#define PULSE_TIMER_IRQn          Int001_IRQn

/* ============================================================================
 * SERIAL/UART MAPPING
 * ==========================================================================*/

#define GRBL_USART              USART1
#define USART1_RX_IRQn          Int002_IRQn
#define USART1_TX_IRQn          Int003_IRQn

/* ============================================================================
 * FLASH EMULATION FOR EEPROM (EFM)
 * ============================================================================
 * Logical NVMEM window: a small flat window in the last flash page/sector
 * this port's linker script reserves - separate implementation from every
 * STM32 port (no common/stm32 code shared, different flash controller
 * entirely). See nvmem.c.
 * --------------------------------------------------------------------------*/

#define HAL_NVMEM_FLASH_START     0x0007F800UL   /* last 2KB page of a 512KB image (UNVERIFIED page size - EFM erase granularity not confirmed this session, see nvmem.c) */
#define HAL_NVMEM_FLASH_SIZE      2048
#define HAL_NVMEM_FLASH_PAGE_SIZE 2048

/* ============================================================================
 * HAL GPIO MACROS
 * ==========================================================================*/

#define HAL_GPIO_SET_BITS(port, mask)           ((port)->POSR = (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)         ((port)->PORR = (mask))
#define HAL_GPIO_WRITE_PORT(port, mask, value)  ((port)->PODR = ((port)->PODR & ~(mask)) | ((value) & (mask)))
#define HAL_GPIO_READ_PORT(port, mask)          ((port)->PODR & (mask))
#define HAL_GPIO_READ_PIN(pin, mask)            ((pin)->PIDR & (mask))
#define HAL_GPIO_WRITE_DIRECT(port, value)      ((port)->PODR = (value))

void hal_gpio_set_output(HC32_PORT_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(HC32_PORT_TypeDef* port, uint32_t mask);

#define HAL_GPIO_SET_OUTPUT(port, mask)         hal_gpio_set_output((port), (mask))
#define HAL_GPIO_SET_INPUT(port, mask)          hal_gpio_set_input((port), (mask))

void hal_gpio_pullup_enable(HC32_PORT_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(HC32_PORT_TypeDef* port, uint32_t mask);

#define HAL_GPIO_PULLUP_ENABLE(port, mask)      hal_gpio_pullup_enable((port), (mask))
#define HAL_GPIO_PULLUP_DISABLE(port, mask)     hal_gpio_pullup_disable((port), (mask))

void hal_gpio_interrupt_enable(HC32_PORT_TypeDef* port, uint32_t mask);
void hal_gpio_interrupt_disable(HC32_PORT_TypeDef* port, uint32_t mask);

#define HAL_GPIO_INTERRUPT_ENABLE(port, pcie, mask)   hal_gpio_interrupt_enable((port), (mask))
#define HAL_GPIO_INTERRUPT_DISABLE(port, pcie, mask)  hal_gpio_interrupt_disable((port), (mask))

/* ============================================================================
 * HAL SERIAL/UART MACROS
 * ==========================================================================*/

#define HAL_SERIAL_RX_BUFFER_SIZE               128
#define HAL_SERIAL_TX_BUFFER_SIZE               64

/* RX and TX are SEPARATE interrupt sources on this chip (CONFIRMED via
   Klipper's serial.c: distinct RI/TI event ids) - unlike every STM32 donor
   in this tree, which share one combined USART vector. Two real vectors,
   not one dispatcher. */
#define HAL_SERIAL_RX_ISR()                     void hc32_usart1_rx_handler(void)
#define HAL_SERIAL_TX_ISR()                     void hc32_usart1_tx_handler(void)

void hal_serial_init(uint32_t baud_rate);
#define HAL_SERIAL_INIT()                       hal_serial_init(BAUD_RATE)

#define HAL_SERIAL_WRITE_DATA(data)             (USART1->DR = (data))
#define HAL_SERIAL_READ_DATA()                  (USART1->DR)

#define HAL_SERIAL_TX_INTERRUPT_ENABLE()        (USART1->CR1 |= USART_CR1_TIE)
#define HAL_SERIAL_TX_INTERRUPT_DISABLE()       (USART1->CR1 &= ~USART_CR1_TIE)

#define HAL_SERIAL_RX_READY()                   (USART1->SR & USART_SR_RXNE)
#define HAL_SERIAL_TX_READY()                   (USART1->SR & USART_SR_TXE)

/* ============================================================================
 * HAL SYSTEM MACROS
 * ==========================================================================*/

#define HAL_ENABLE_INTERRUPTS()                 __enable_irq()
#define HAL_DISABLE_INTERRUPTS()                __disable_irq()

/* Critical section (save/restore, ISR-safe: CONTRACTS.md section 8.2) */
#define HAL_CRITICAL_SECTION_BEGIN()            uint32_t __primask = __get_PRIMASK(); __disable_irq()
#define HAL_CRITICAL_SECTION_END()               __set_PRIMASK(__primask)

void hal_delay_ms(uint32_t ms);
void hal_delay_us(uint32_t us);

#define HAL_DELAY_MS(ms)                        hal_delay_ms(ms)
#define HAL_DELAY_US(us)                        hal_delay_us(us)

uint32_t hal_millis(void);
uint64_t hal_micros(void);

#define HAL_MILLIS()                            hal_millis()
#define HAL_MICROS()                            hal_micros()

void hal_watchdog_refresh(void);
#define HAL_WATCHDOG_REFRESH()                  hal_watchdog_refresh()

/* ============================================================================
 * HAL NVMEM MACROS (EFM flash emulation, nvmem.c - TU replacement, core
 * nvmem.c excluded from the build, CONTRACTS.md section 10)
 * ==========================================================================*/

unsigned char hal_nvmem_read_byte(unsigned int addr);
void hal_nvmem_write_byte(unsigned int addr, unsigned char data);

#define eeprom_get_char(addr)                   hal_nvmem_read_byte(addr)
#define eeprom_put_char(addr, data)              hal_nvmem_write_byte(addr, data)

/* ============================================================================
 * PLATFORM-SPECIFIC FUNCTIONS
 * ==========================================================================*/

void hal_system_init(void);
void hal_clock_config(void);
void hal_gpio_init(void);

void hal_nvmem_init(void);
void hal_nvmem_flush(void);

#endif /* PLATFORM_HC32F460_H */
