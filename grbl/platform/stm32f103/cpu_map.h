/*
  cpu_map.h - STM32F103 stub (pin mapping is in platform.h)
  Part of Grbl STM32 port

  This file is a stub for AVR cpu_map.h compatibility.
  All pin mappings for STM32F103 are defined in platform.h
*/

#ifndef cpu_map_h
#define cpu_map_h

// Map AVR pin definitions to STM32 GPIO ports
// GPIOB/GPIOC will be defined in regs.h (included before this)
#define LIMIT_DDR     0      // Not used on STM32 (DDR is for AVR only)
#define LIMIT_PORT    0      // Not used on STM32 (PORT is for AVR pullup)
#define LIMIT_PCMSK   0      // Not used on STM32
#define LIMIT_INT     0      // Not used on STM32
#define LIMIT_PIN     GPIOB  // Used for reading limit switches
#define LIMIT_MASK    ((1<<0)|(1<<1)|(1<<10))  // PB0, PB1, PB10

#define CONTROL_DDR   0      // Not used on STM32
#define CONTROL_PORT  0      // Not used on STM32
#define CONTROL_PCMSK 0      // Not used on STM32
#define CONTROL_INT   0      // Not used on STM32
#define CONTROL_PIN   GPIOB  // Used for reading control pins
#define CONTROL_MASK  ((1<<3)|(1<<4)|(1<<5)|(1<<6))  // PB3-PB6

#define PROBE_DDR     0      // Not used on STM32
#define PROBE_PORT    0      // Not used on STM32
#define PROBE_PIN     GPIOC  // Used for reading probe pin
#define PROBE_MASK    (1<<15)    // PC15

// Override HAL_GPIO_PULLUP macros to be no-ops (STM32 configures pullups at init)
#undef HAL_GPIO_PULLUP_ENABLE
#undef HAL_GPIO_PULLUP_DISABLE
#define HAL_GPIO_PULLUP_ENABLE(port, mask)  do {} while(0)
#define HAL_GPIO_PULLUP_DISABLE(port, mask) do {} while(0)

#endif
