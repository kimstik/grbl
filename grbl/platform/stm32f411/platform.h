/*
  platform.h - STM32F411 platform HAL interface
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef PLATFORM_STM32F411_H
#define PLATFORM_STM32F411_H

// PLATFORM IDENTIFICATION

// hal.h pre-defines PLATFORM_NAME "STM32F411" before including this file;
// the board-specific name below is the intended final value.
#undef PLATFORM_NAME
#define PLATFORM_NAME     "STM32F411CEU6"
#define PLATFORM_CPU      "ARM Cortex-M4F"
#define PLATFORM_ARCH     "ARM"

// PLATFORM CAPABILITIES

#define HAL_HAS_FPU           1   // Cortex-M4F: single-precision FPU (fpv4-sp-d16)
#define HAL_HAS_DMA           1   // 2x DMA controllers, 16 streams total
#define HAL_HAS_USB           1   // USB OTG FS present in silicon (not wired by this port)
#define HAL_HAS_HW_EEPROM     0   // No hardware EEPROM (use flash emulation)
#define HAL_HAS_HW_MULTIPLY   1   // 32-bit hardware multiplier
#define HAL_HAS_HW_DIVIDE     1   // Hardware divider

// PLATFORM SPECIFICATIONS

#ifndef HAL_CPU_FREQ
  #define HAL_CPU_FREQ        96000000UL  // 96 MHz (Makefile CLOCK must match - Step 1 F_CPU lie trap)
#endif

#define HAL_RAM_SIZE          131072      // 128 KB
#define HAL_FLASH_SIZE        524288      // 512 KB
#define HAL_EEPROM_SIZE       0           // No hardware EEPROM

// Timer resolution
#define HAL_TIMER_RESOLUTION_NS   10      // ~10.4 ns @ 96 MHz

// STM32 REGISTER DEFINITIONS

// Minimal register definitions (no CMSIS dependency) - see regs.h header
// comment for the F1-vs-F4 base-address traps this file avoids.
#include "regs.h"

// Timer primitives with contract naming (STP_*/PWM_*/ISR_*), see CONTRACTS.md.
// Shared by every STM32 port here: the TIM2/TIM3/TIM1 macro encodings were
// 100% code-identical across f103/f411/h523 - only the base addresses differ,
// and those come from this port's own regs.h (included above, and by name
// from the shared header via -I.).
#include "../common/stm32/stm32_timer.h"

// GRBL_BOOT_INIT - the anchor attribute on the pre-main init chain (BUG #23)
#include "common/boot_init.h"

// Define hal_gpio_port_t before hal_gpio.h includes it
// This ensures our GPIO_TypeDef* is used instead of void*
typedef GPIO_TypeDef* hal_gpio_port_t;
#define HAL_GPIO_PORT_T_DEFINED

// PIN MAPPING - GPIO DEFINITIONS

/*
  STM32F411CEU6 ("Black Pill") Pin Mapping for GRBL (same pin layout as the
  stm32f103/stm32h523 "Blue/Black Pill" boards this port reuses - the
  physical wiring convention, not the electrical register model, is shared):

  Step pins (GPIOA: PA0, PA1, PA2)
  Direction pins (GPIOA: PA3, PA4, PA5)
  Stepper enable (GPIOA: PA6, active low)
  Limit switches with EXTI (GPIOB: PB0, PB1, PB10)
  Control pins with EXTI (GPIOB: PB3-PB6: reset/feed hold/cycle start/safety door)
  Spindle PWM (GPIOA: PA8, TIM1_CH1, AF1)
  Spindle enable/direction (GPIOB: PB12, PB13)
  Coolant flood/mist (GPIOC: PC13, PC14)
  Probe (GPIOC: PC15)
  UART: TX PA9 / RX PA10 (USART1, AF7)
*/

// STEP PINS (GPIOA: PA0, PA1, PA2)

#define STEP_PORT           GPIOA
#define STEP_PORT_ID        ((hal_gpio_port_t)GPIOA)
#define X_STEP_PIN          0
#define Y_STEP_PIN          1
#define Z_STEP_PIN          2
#define X_STEP_BIT          0
#define Y_STEP_BIT          1
#define Z_STEP_BIT          2
#define STEP_MASK           ((1<<X_STEP_PIN)|(1<<Y_STEP_PIN)|(1<<Z_STEP_PIN))

// DIRECTION PINS (GPIOA: PA3, PA4, PA5)

#define DIRECTION_PORT      GPIOA
#define DIRECTION_PORT_ID   ((hal_gpio_port_t)GPIOA)
#define X_DIRECTION_PIN     3
#define Y_DIRECTION_PIN     4
#define Z_DIRECTION_PIN     5
#define X_DIRECTION_BIT     3
#define Y_DIRECTION_BIT     4
#define Z_DIRECTION_BIT     5
#define DIRECTION_MASK      ((1<<X_DIRECTION_PIN)|(1<<Y_DIRECTION_PIN)|(1<<Z_DIRECTION_PIN))

// PLAN.md Phase 2 static-assert sweep (2026-07-26): core packs
// step_outbits/dir_outbits/axislock into a uint8_t (BUG #17, CONTRACTS.md
// #1) - every *_STEP_BIT/*_DIRECTION_BIT must fit that byte.
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image (BUG #17 class, CONTRACTS.md #1)");

// STEPPER ENABLE PIN (GPIOA: PA6)

#define STEPPERS_DISABLE_PORT   GPIOA
#define STEPPERS_DISABLE_PORT_ID ((hal_gpio_port_t)GPIOA)
#define STEPPERS_DISABLE_PIN    6
#define STEPPERS_DISABLE_BIT    6
#define STEPPERS_DISABLE_MASK   (1<<STEPPERS_DISABLE_PIN)

// LIMIT SWITCH PINS (GPIOB: PB0, PB1, PB10) - all bits 0-7 land in the
// low byte except Z (bit10); core truncates GPIO_MRD reads to uint8_t
// (CONTRACTS.md section 1.3) - Z_LIMIT_BIT=10 would be silently invisible
// if it were ever read through the truncated group path the way SAMD21's
// CONTROL bits are (megarm/config.h, known gap). It is NOT read that way
// here: limits.c reads LIMIT_MASK/IREG as a group (GPIO_MRD), and the X/Y/Z
// bits below ARE all consumed individually as single-bit tests too
// (limits.c per-axis loop uses 1<<axis against the SAME LIMIT_MASK group
// read) - X_LIMIT_BIT/Y_LIMIT_BIT/Z_LIMIT_BIT must match the *logical* axis
// order the core assumes (X=bit0,Y=bit1,Z=bit2) if BUG#17's logical/physical
// split applied here. It does not: this board wires the limit switches
// directly to GPIOB0/1/10 and the core only ever masks/tests via
// LIMIT_MASK and the per-name BIT, both defined consistently below - same
// pattern already proven correct on stm32f103/h523 (BUG#17 was a SAMD21-
// specific hazard from a *different* physical/logical pin split, not
// present in this direct-wiring board.md).

#define LIMIT_PORT          GPIOB
#define LIMIT_PORT_ID       ((hal_gpio_port_t)GPIOB)
#define X_LIMIT_PIN         0
#define Y_LIMIT_PIN         1
#define Z_LIMIT_PIN         10
#define X_LIMIT_BIT         0
#define Y_LIMIT_BIT         1
#define Z_LIMIT_BIT         10
#define LIMIT_MASK          ((1<<X_LIMIT_PIN)|(1<<Y_LIMIT_PIN)|(1<<Z_LIMIT_PIN))

// GPIO_INT_ON/OFF plumbing: core passes (name_PCMSK, name_INT, name_MASK) to
// HAL_GPIO_INTERRUPT_ENABLE/DISABLE; on STM32 the first argument is the port,
// the second is unused (AVR PCIE bit).
#define LIMIT_PCMSK         LIMIT_PORT
#define LIMIT_INT           0

// CONTROL PINS (GPIOB: PB3, PB4, PB5, PB6)

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

// GPIO_INT_ON plumbing (see LIMIT_PCMSK note above)
#define CONTROL_PCMSK             CONTROL_PORT
#define CONTROL_INT               0

// PROBE PIN (GPIOC: PC15)

#define PROBE_PORT          GPIOC
#define PROBE_PORT_ID       ((hal_gpio_port_t)GPIOC)
#define PROBE_PIN           15
#define PROBE_BIT           15
#define PROBE_MASK          (1<<PROBE_PIN)

// SPINDLE PINS

// Spindle PWM (PA8, TIM1_CH1, AF1)
#define SPINDLE_PWM_PORT        GPIOA
#define SPINDLE_PWM_PIN         8
#define SPINDLE_PWM_BIT         8
#define SPINDLE_PWM_TIMER       TIM1
#define SPINDLE_PWM_CHANNEL     1
#define SPINDLE_PWM_AF          1   // AF1 = TIM1/TIM2 on every F1/F4/H5 GPIO AF table

// Spindle enable/direction (GPIOB: PB12, PB13)
#define SPINDLE_ENABLE_PORT     GPIOB
#define SPINDLE_ENABLE_PIN      12
#define SPINDLE_ENABLE_BIT      12
#define SPINDLE_DIRECTION_PORT  GPIOB
#define SPINDLE_DIRECTION_PIN   13
#define SPINDLE_DIRECTION_BIT   13

// PWM duty domain: core plumbs duty as uint8_t end-to-end
// (spindle_control.c:122, CONTRACTS.md section 6.2) - full scale MUST fit
// uint8_t. TIM1 runs with ARR = SPINDLE_PWM_MAX_VALUE (platform.c). The
// prior skeleton's 65535 (a "16-bit PWM" comment) was the exact duty-cap
// defect already fixed on stm32f103/h523 (config.h vs platform.h dual-canon
// bug, PLAN.md commits 6e75218/5a56a5a) - this port starts from 255 so the
// bug class cannot recur. config.h below MUST NOT redefine this macro.
#define SPINDLE_PWM_MAX_VALUE     255
#define SPINDLE_PWM_MIN_VALUE     1
#define SPINDLE_PWM_OFF_VALUE     0
#define SPINDLE_PWM_RANGE         (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// PLAN.md Phase 2 static-assert sweep (2026-07-26): codify the CONTRACTS.md
// #6.2 duty-domain contract in code - the sibling ports (h523/f103) both
// shipped the "duty-cap-twins" regression (SPINDLE_PWM_MAX_VALUE=1000
// against a uint8_t core duty) before a comment-only contract caught it.
_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2, duty-cap-twins class)");

// COOLANT PINS (GPIOC: PC13, PC14)

#define COOLANT_FLOOD_PORT      GPIOC
#define COOLANT_FLOOD_PIN       13
#define COOLANT_FLOOD_BIT       13

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     GPIOC
  #define COOLANT_MIST_PIN      14
  #define COOLANT_MIST_BIT      14
#endif

// TIMER MAPPING

// Stepper timer: TIM2 (32-bit general purpose timer)
#define STEPPER_TIMER           TIM2
#define STEPPER_TIMER_IRQn      TIM2_IRQn
#define STEPPER_TIMER_IRQHandler TIM2_IRQHandler

// Step pulse reset timer: TIM3 (16-bit general purpose timer)
#define PULSE_TIMER             TIM3
#define PULSE_TIMER_IRQn        TIM3_IRQn
#define PULSE_TIMER_IRQHandler  TIM3_IRQHandler

// Spindle PWM timer: TIM1 (16-bit advanced timer) - already defined above

// SERIAL/UART MAPPING

#define GRBL_USART              USART1
#define GRBL_USART_IRQn         USART1_IRQn
#define GRBL_USART_IRQHandler   USART1_IRQHandler

// FLASH EMULATION FOR EEPROM

// F411CE (512KB) sector map: sectors 0-3 = 16KB, sector 4 = 64KB, sectors
// 5-7 = 128KB each (total 4*16+64+3*128 = 512KB). Sector 7 (last 128KB
// sector, base 0x08060000) is reserved for NVMEM - erasing it never touches
// code (code lives in sectors 0-6, well under 384KB). Unlike F1/H5's page
// model, a single F4 sector erase always wipes the WHOLE 128KB sector
// regardless of how many "logical" bytes NVMEM actually uses - see flash.c.
//
// IMPORTANT (gap found porting this platform, folded back to CONTRACTS.md
// section 14): the logical NVMEM window size below (4096) is deliberately
// SMALLER than the real 128KB erase granularity. common/stm32/stm32_nvmem.c's
// cache is a single static `cache_buffer[4096]` shared by every STM32 port;
// stm32h523's config (8192 = FLASH_PAGE_SIZE * NUM_PAGES) exceeds that
// buffer and silently fails stm32_nvmem_init()'s own
// STM32_VALIDATE_PARAM(nvmem_size <= sizeof(cache_buffer)) check every time
// (hal_nvmem_read_byte/write_byte in stm32h523/platform.c do not check the
// return value, so this degrades to "every NVMEM read returns 0xFF" with no
// build or link error - the "compiles but dead" class). This port avoids
// the same defect by keeping its logical window at 4096 bytes even though
// the real hardware sector is 32x larger; flash.c's erase_page still erases
// the full physical sector (F4 has no smaller granularity), it just leaves
// the unused tail of the sector as erased 0xFF, which is harmless.
#define HAL_NVMEM_FLASH_START   0x08060000
#define HAL_NVMEM_FLASH_SIZE    4096
#define HAL_NVMEM_FLASH_PAGE_SIZE 4096

// HAL GPIO MACROS

// Basic GPIO operations (optimized for STM32 BSRR register)
#define HAL_GPIO_SET_BITS(port, mask)           ((port)->BSRR = (mask))
#define HAL_GPIO_CLEAR_BITS(port, mask)         ((port)->BSRR = ((uint32_t)(mask) << 16))
#define HAL_GPIO_TOGGLE_BITS(port, mask)        ((port)->ODR ^= (mask))
#define HAL_GPIO_WRITE_PORT(port, mask, value)  ((port)->BSRR = (((port)->ODR & (mask)) << 16) | ((value) & (mask)))
#define HAL_GPIO_READ_PORT(port, mask)          ((port)->ODR & (mask))
#define HAL_GPIO_READ_PIN(pin, mask)            ((pin)->IDR & (mask))
#define HAL_GPIO_WRITE_DIRECT(port, value)      ((port)->ODR = (value))

// GPIO direction configuration - functions, not macros (MODER is 2 bits/pin)
void hal_gpio_set_output(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_set_input(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_SET_OUTPUT(port, mask)         hal_gpio_set_output((port), (mask))
#define HAL_GPIO_SET_INPUT(port, mask)          hal_gpio_set_input((port), (mask))

void hal_gpio_pullup_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_pullup_disable(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_PULLUP_ENABLE(port, mask)      hal_gpio_pullup_enable((port), (mask))
#define HAL_GPIO_PULLUP_DISABLE(port, mask)     hal_gpio_pullup_disable((port), (mask))

// EXTI interrupt configuration
void hal_gpio_interrupt_enable(GPIO_TypeDef* port, uint32_t mask);
void hal_gpio_interrupt_disable(GPIO_TypeDef* port, uint32_t mask);

#define HAL_GPIO_INTERRUPT_ENABLE(port, pcie, mask)   hal_gpio_interrupt_enable((port), (mask))
#define HAL_GPIO_INTERRUPT_DISABLE(port, pcie, mask)  hal_gpio_interrupt_disable((port), (mask))

// HAL TIMER MACROS
// Stepper (TIM2), pulse reset (TIM3) and spindle PWM (TIM1) primitives live
// in timer.h under the contract names STP_TMR_*/STP_PULSE_RESET_*/PWM_*
// (included above). Vector wrappers with flag-clear-first are in handlers.c.

// HAL SERIAL/UART MACROS

#define HAL_SERIAL_RX_BUFFER_SIZE               128
#define HAL_SERIAL_TX_BUFFER_SIZE               64

// On STM32, RX and TX share USART1_IRQHandler, so we define helper functions;
// the actual USART1_IRQHandler is in platform.c and calls these based on
// SR flags (F4 uses the classic SR register, not H5's ISR).
#define HAL_SERIAL_RX_ISR()                     void stm32_usart1_rx_handler(void)
#define HAL_SERIAL_TX_ISR()                     void stm32_usart1_tx_handler(void)

void hal_serial_init(uint32_t baud_rate);
#define HAL_SERIAL_INIT()                       hal_serial_init(BAUD_RATE)

// Serial data register access (F4 USART: classic SR/DR, same as F1 - NOT
// H5's ISR/RDR/TDR split)
#define HAL_SERIAL_WRITE_DATA(data)             (USART1->DR = (data))
#define HAL_SERIAL_READ_DATA()                  (USART1->DR)

#define HAL_SERIAL_TX_INTERRUPT_ENABLE()        (USART1->CR1 |= USART_CR1_TXEIE)
#define HAL_SERIAL_TX_INTERRUPT_DISABLE()       (USART1->CR1 &= ~USART_CR1_TXEIE)

// HAL_SERIAL_RX_READY()/HAL_SERIAL_TX_READY() removed (cross-port
// consistency audit, 2026-07-26): defined here and in stm32f103/h523/
// hc32f460/sg2002 but called by nothing in grbl core (grep grbl/*.c) and
// absent from CONTRACTS.md §7's serial macro table - core drives serial
// entirely off the RX/TX ISR + INTERRUPT_ENABLE/DISABLE pair, never polls
// a ready flag. Dead since the macros were written. Reintroduce with a
// real caller if a future polling-mode serial path ever needs it.

// HAL SYSTEM MACROS

// Interrupt control + critical sections (CONTRACTS.md #8.2/#11) live in
// common/cortexm/cortexm_critical.h, shared verbatim with stm32f103,
// stm32h523 and hc32f460 - it also carries this port's sei()/cli(), which
// is why prelude.h (not this file) is what includes it: grbl.h needs those
// two before it reaches platform.h. See that header for the full ordering
// argument.

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

// HAL NVMEM MACROS (Flash emulation)

unsigned char hal_nvmem_read_byte(unsigned int addr);
void hal_nvmem_write_byte(unsigned int addr, unsigned char data);

// Map to standard eeprom function names (CONTRACTS.md section 10)
#define eeprom_get_char(addr)                   hal_nvmem_read_byte(addr)
#define eeprom_put_char(addr, data)              hal_nvmem_write_byte(addr, data)

// PLATFORM-SPECIFIC FUNCTIONS

// BOOT INIT CHAIN (BUG #23). Called from Reset_Handler in startup.c before
// main() - core grbl/main.c is the golden gate and never calls platform
// init. GRBL_BOOT_INIT (== noinline, common/boot_init.h) keeps each of
// these three a real out-of-line symbol so common/init_check.sh can prove
// post-link that they SURVIVED the -flto + --gc-sections link, i.e. that
// something still reaches them. Deliberately not `used`: that would force
// the symbols in whether called or not and blind the check. Every name
// here must stay in sync with INIT_SYMBOLS in this port's Makefile.
GRBL_BOOT_INIT void hal_system_init(void);
GRBL_BOOT_INIT void hal_clock_config(void);       // HSE 25MHz -> PLL 96MHz
GRBL_BOOT_INIT void hal_gpio_init(void);

void hal_nvmem_init(void);
void hal_nvmem_flush(void);        // Flush dirty cache to flash

#endif // PLATFORM_STM32F411_H
