/*
  hal_gpio.h - GPIO HAL (pins, ports, interrupts)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

// -- FIXME: THIS useless file have to disappear --


#ifndef HAL_GPIO_H
#define HAL_GPIO_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// GPIO MACROS - Platform-specific implementations
// ============================================================================

/*
  For AVR: These macros expand to original GRBL code - ZERO overhead!

  Example:
    HAL_GPIO_WRITE_PORT(STEP_PORT_ID, STEP_MASK, step_bits)

    Expands on AVR to:
    PORTD = (PORTD & ~STEP_MASK) | step_bits

    Same machine code as original GRBL!
*/

#ifndef __AVR__  // For non-AVR platforms only - AVR uses atmega328p/platform.h
  // ============================================================================
  // OTHER PLATFORMS - Function-based or inline implementations
  // ============================================================================

  // Port/pin types
  #ifndef HAL_GPIO_PORT_T_DEFINED
    typedef void* hal_gpio_port_t;
  #endif
  typedef uint32_t hal_gpio_pin_t;

  // Port manipulation
  void hal_gpio_write_port(hal_gpio_port_t port, uint32_t mask, uint32_t value);
  uint32_t hal_gpio_read_port(hal_gpio_port_t port);

  #ifndef HAL_GPIO_WRITE_PORT
    #define HAL_GPIO_WRITE_PORT(port, mask, value)  hal_gpio_write_port(port, mask, value)
  #endif
  #ifndef HAL_GPIO_READ_PORT
    #define HAL_GPIO_READ_PORT(port)                hal_gpio_read_port(port)
  #endif

  // Pin manipulation
  void hal_gpio_write_pin(hal_gpio_port_t port, uint8_t pin, bool value);
  bool hal_gpio_read_pin(hal_gpio_port_t port, uint8_t pin);

  #ifndef HAL_GPIO_WRITE_PIN
    #define HAL_GPIO_WRITE_PIN(port, pin, value)  hal_gpio_write_pin(port, pin, value)
  #endif
  #ifndef HAL_GPIO_READ_PIN
    #define HAL_GPIO_READ_PIN(port, pin)          hal_gpio_read_pin(port, pin)
  #endif

  // Bit operations
  void hal_gpio_set_bits(hal_gpio_port_t port, uint32_t mask);
  void hal_gpio_clear_bits(hal_gpio_port_t port, uint32_t mask);
  void hal_gpio_toggle_bits(hal_gpio_port_t port, uint32_t mask);

  #ifndef HAL_GPIO_SET_BITS
    #define HAL_GPIO_SET_BITS(port, mask)    hal_gpio_set_bits(port, mask)
  #endif
  #ifndef HAL_GPIO_CLEAR_BITS
    #define HAL_GPIO_CLEAR_BITS(port, mask)  hal_gpio_clear_bits(port, mask)
  #endif
  #ifndef HAL_GPIO_TOGGLE_BITS
    #define HAL_GPIO_TOGGLE_BITS(port, mask) hal_gpio_toggle_bits(port, mask)
  #endif

  // Direction control
  void hal_gpio_set_output(hal_gpio_port_t port, uint32_t mask);
  void hal_gpio_set_input(hal_gpio_port_t port, uint32_t mask);

  #ifndef HAL_GPIO_SET_OUTPUT
    #define HAL_GPIO_SET_OUTPUT(port, mask)  hal_gpio_set_output(port, mask)
  #endif
  #ifndef HAL_GPIO_SET_INPUT
    #define HAL_GPIO_SET_INPUT(port, mask)   hal_gpio_set_input(port, mask)
  #endif

  // Pull-up control
  void hal_gpio_pullup_enable(hal_gpio_port_t port, uint32_t mask);
  void hal_gpio_pullup_disable(hal_gpio_port_t port, uint32_t mask);

  #ifndef HAL_GPIO_PULLUP_ENABLE
    #define HAL_GPIO_PULLUP_ENABLE(port, mask)   hal_gpio_pullup_enable(port, mask)
  #endif
  #ifndef HAL_GPIO_PULLUP_DISABLE
    #define HAL_GPIO_PULLUP_DISABLE(port, mask)  hal_gpio_pullup_disable(port, mask)
  #endif

#endif

// ============================================================================
// GPIO INITIALIZATION
// ============================================================================

// Initialize GPIO subsystem
// For AVR: No-op (ports are ready at boot)
// For others: Enable GPIO clocks, configure ports
void hal_gpio_init(void);

// ============================================================================
// GPIO INTERRUPTS (External Interrupts / Pin Change Interrupts)
// ============================================================================

// Interrupt trigger modes
typedef enum {
  HAL_GPIO_IRQ_RISING,
  HAL_GPIO_IRQ_FALLING,
  HAL_GPIO_IRQ_BOTH,
  HAL_GPIO_IRQ_LOW,
  HAL_GPIO_IRQ_HIGH
} hal_gpio_irq_mode_t;

#ifndef __AVR__  // For non-AVR platforms only
  // Other platforms: Configure EXTI or equivalent
  void hal_gpio_irq_config(hal_gpio_port_t port, uint8_t pin,
                           hal_gpio_irq_mode_t mode, uint8_t priority);
  void hal_gpio_irq_enable(hal_gpio_port_t port, uint8_t pin);
  void hal_gpio_irq_disable(hal_gpio_port_t port, uint8_t pin);

  #define HAL_GPIO_IRQ_ENABLE(port, pin)   hal_gpio_irq_enable(port, pin)
  #define HAL_GPIO_IRQ_DISABLE(port, pin)  hal_gpio_irq_disable(port, pin)

  // Interrupt handler definition
  #define HAL_GPIO_IRQ_HANDLER(name)  void name##_IRQHandler(void)
#endif

// ============================================================================
// PIN MAPPING
// ============================================================================

/*
  Pin mapping is defined in platform.h for each platform.

  Example for AVR (in platforms/atmega328p/platform.h):

    #define STEP_PORT       PORTD
    #define STEP_DDR        DDRD
    #define STEP_PIN        PIND
    #define STEP_MASK       ((1<<2)|(1<<3)|(1<<4))

    #define X_STEP_BIT      2
    #define Y_STEP_BIT      3
    #define Z_STEP_BIT      4

  Example for STM32:

    #define STEP_PORT       GPIOA
    #define STEP_MASK       ((1<<0)|(1<<1)|(1<<2))

    #define X_STEP_PIN      0
    #define Y_STEP_PIN      1
    #define Z_STEP_PIN      2
*/

// ============================================================================
// GPIO HELPER MACROS
// ============================================================================

// Helper macro for pin definition (concatenates PORT and BIT as two separate args)
#define PIN(name)  name##_PORT, name##_BIT

// ============================================================================
// GPIO INTERRUPT MACROS (AVR-specific)
// ============================================================================

// GPIO interrupt shortcuts
#define GPIO_INT_ON(pcmsk, int_flag, mask)   HAL_GPIO_INTERRUPT_ENABLE(pcmsk, int_flag, mask)
#define GPIO_INT_OFF(pcmsk, int_flag, mask)  HAL_GPIO_INTERRUPT_DISABLE(pcmsk, int_flag, mask)

// GPIO ISR handler
#define GPIO_ISR(name)  HAL_GPIO_IRQ_HANDLER(name)

#endif // HAL_GPIO_H
