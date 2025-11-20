/*
  hal_gpio.h - GPIO HAL (pins, ports, interrupts)
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors
*/

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

#ifdef __AVR__
  // ============================================================================
  // AVR IMPLEMENTATION - ZERO OVERHEAD MACROS
  // ============================================================================

  #include <avr/io.h>
  #include <avr/interrupt.h>

  // Port IDs (just for type safety, evaluate to nothing)
  #define HAL_GPIO_PORT_B  PORTB
  #define HAL_GPIO_PORT_C  PORTC
  #define HAL_GPIO_PORT_D  PORTD

  // Pin IDs (bit numbers)
  #define HAL_GPIO_PIN_0   0
  #define HAL_GPIO_PIN_1   1
  #define HAL_GPIO_PIN_2   2
  #define HAL_GPIO_PIN_3   3
  #define HAL_GPIO_PIN_4   4
  #define HAL_GPIO_PIN_5   5
  #define HAL_GPIO_PIN_6   6
  #define HAL_GPIO_PIN_7   7

  // Port manipulation - CRITICAL: These must be identical to original GRBL!
  // Write multiple pins atomically with mask
  #define HAL_GPIO_WRITE_PORT(port, mask, value) \
    ((port) = ((port) & ~(mask)) | ((value) & (mask)))

  // Write single pin
  #define HAL_GPIO_WRITE_PIN(port, pin, value) \
    do { \
      if (value) \
        (port) |= (1 << (pin)); \
      else \
        (port) &= ~(1 << (pin)); \
    } while(0)

  // Read port - defined in platform-specific header (e.g., atmega328p/platform.h)
  // #define HAL_GPIO_READ_PORT(pin_reg)  (pin_reg)  // REMOVED - conflicts with 2-arg platform version

  // Read single pin
  #define HAL_GPIO_READ_PIN(pin_reg, pin)  (((pin_reg) >> (pin)) & 0x01)

  // Set pin(s) high
  #define HAL_GPIO_SET_BITS(port, mask)    ((port) |= (mask))

  // Clear pin(s) low
  #define HAL_GPIO_CLEAR_BITS(port, mask)  ((port) &= ~(mask))

  // Toggle pin(s)
  #define HAL_GPIO_TOGGLE_BITS(port, mask) ((port) ^= (mask))

  // Direction control (DDR)
  #define HAL_GPIO_SET_OUTPUT(ddr, mask)   ((ddr) |= (mask))
  #define HAL_GPIO_SET_INPUT(ddr, mask)    ((ddr) &= ~(mask))

  // Pull-up control (for inputs: write to PORT register)
  #define HAL_GPIO_PULLUP_ENABLE(port, mask)   ((port) |= (mask))
  #define HAL_GPIO_PULLUP_DISABLE(port, mask)  ((port) &= ~(mask))

#else
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

#ifdef __AVR__
  // AVR: Pin change interrupts are configured in platform code
  // Just provide enable/disable macros

  // These will be defined in platform.h for specific PCINT groups
  #define HAL_GPIO_IRQ_ENABLE(irq_mask)   /* Defined by platform */
  #define HAL_GPIO_IRQ_DISABLE(irq_mask)  /* Defined by platform */

  // Interrupt vector macros (for ISR definitions)
  // Usage: HAL_GPIO_IRQ_HANDLER(LIMIT_INT)
  #define HAL_GPIO_IRQ_HANDLER(name)  ISR(name##_vect)

#else
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
// SIMPLIFIED SINGLE-BIT GPIO OPERATIONS
// ============================================================================

/*
  Simplified macros for common single-bit GPIO operations.
  Reduces verbosity and improves readability.

  Usage:
    GPIO_BSET(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_BIT);  // Set bit
    GPIO_BCLR(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_BIT);  // Clear bit
    GPIO_BTGL(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_BIT);  // Toggle bit

  Old verbose style:
    HAL_GPIO_SET_BITS(STEPPERS_DISABLE_PORT, (1<<STEPPERS_DISABLE_BIT));

  New concise style:
    GPIO_BSET(STEPPERS_DISABLE_PORT, STEPPERS_DISABLE_BIT);
*/

// Set single bit (bit = 1)
#define GPIO_BSET(port, bit)  HAL_GPIO_SET_BITS(port, (1<<(bit)))

// Clear single bit (bit = 0)
#define GPIO_BCLR(port, bit)  HAL_GPIO_CLEAR_BITS(port, (1<<(bit)))

// Toggle single bit
#define GPIO_BTGL(port, bit)  HAL_GPIO_TOGGLE_BITS(port, (1<<(bit)))

// Helper macro for pin definition (concatenates PORT and BIT)
// Usage: #define PIN_X_STEP  X_STEP_PORT, X_STEP_BIT
//        GPIO_BSET(PIN_X_STEP);
#define PIN(name)  name##_PORT, name##_BIT

// ============================================================================
// SHORTER ALIASES (OPTIONAL - Issue #5)
// ============================================================================

/*
  Optional shorter names for frequently used operations.
  Use whichever style you prefer - both work identically.

  Verbose style (explicit):    HAL_GPIO_SET_OUTPUT(...)
  Concise style (shorter):     GPIO_OUT(...)
*/

// GPIO direction shortcuts
#define GPIO_OUT(port, mask)     HAL_GPIO_SET_OUTPUT(port, mask)
#define GPIO_IN(port, mask)      HAL_GPIO_SET_INPUT(port, mask)

// GPIO read/write shortcuts
// Note: GPIO_RD signature varies: AVR uses (port, mask), others use (port)
#define GPIO_RD(...)                   HAL_GPIO_READ_PORT(__VA_ARGS__)
#define GPIO_WR(port, mask, value)     HAL_GPIO_WRITE_PORT(port, mask, value)
#define GPIO_PIN_RD(port, pin)         HAL_GPIO_READ_PIN(port, pin)

// GPIO set/clear (multi-bit)
#define GPIO_SET(port, mask)     HAL_GPIO_SET_BITS(port, mask)
#define GPIO_CLR(port, mask)     HAL_GPIO_CLEAR_BITS(port, mask)
#define GPIO_TGL(port, mask)     HAL_GPIO_TOGGLE_BITS(port, mask)

// GPIO pullup shortcuts
#define GPIO_PULLUP_ON(port, mask)   HAL_GPIO_PULLUP_ENABLE(port, mask)
#define GPIO_PULLUP_OFF(port, mask)  HAL_GPIO_PULLUP_DISABLE(port, mask)

// GPIO interrupt shortcuts
#define GPIO_INT_ON(pcmsk, int_flag, mask)   HAL_GPIO_INTERRUPT_ENABLE(pcmsk, int_flag, mask)
#define GPIO_INT_OFF(pcmsk, int_flag, mask)  HAL_GPIO_INTERRUPT_DISABLE(pcmsk, int_flag, mask)

// GPIO ISR handler
#define GPIO_ISR(name)  HAL_GPIO_IRQ_HANDLER(name)

// Direct port write (bypasses port manipulation)
#define GPIO_WR_DIRECT(port, value)  HAL_GPIO_WRITE_DIRECT(port, value)

#endif // HAL_GPIO_H
