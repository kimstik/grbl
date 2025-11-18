# GRBL Platform-Agnostic HAL Architecture

**Date:** 2025-11-18
**Goal:** Create hardware abstraction layer for multi-platform GRBL port
**Supported Platforms:** ARM Cortex-M, RISC-V, ESP32/ESP8266, and future architectures

---

## Executive Summary

Instead of creating ARM-specific port, we design **platform-agnostic Hardware Abstraction Layer (HAL)** that separates hardware-dependent code from GRBL core algorithms. This allows porting to:

- **ARM Cortex-M**: STM32, LPC, SAM, Kinetis, etc.
- **RISC-V**: GD32VF103, CH32V103/203/307, SiFive, etc.
- **ESP32/ESP8266**: Xtensa architecture, WiFi-enabled CNC
- **Future platforms**: Easy to add new targets

**Key Principle:** Write HAL interface once, implement platform drivers, GRBL core remains unchanged.

---

## 1. Architecture Overview

### 1.1 Three-Layer Design

```
┌─────────────────────────────────────────────────────┐
│                  GRBL CORE LAYER                    │
│  (Platform-Independent Algorithm Code)              │
│                                                      │
│  planner.c, gcode.c, protocol.c, motion_control.c   │
│  settings.c, report.c, jog.c, probe.c               │
│                                                      │
│  NO hardware-specific code, only HAL API calls      │
└──────────────────┬──────────────────────────────────┘
                   │ HAL API (grbl_hal.h)
┌──────────────────▼──────────────────────────────────┐
│              HARDWARE ABSTRACTION LAYER              │
│  (Platform-Independent Interface Definition)        │
│                                                      │
│  grbl_hal.h - API specification                     │
│  grbl_hal_timer.h, grbl_hal_gpio.h, etc.           │
│                                                      │
│  Defines WHAT, not HOW                              │
└──────────────────┬──────────────────────────────────┘
                   │ Platform Implementation
┌──────────────────▼──────────────────────────────────┐
│              PLATFORM DRIVER LAYER                   │
│  (Platform-Specific Implementations)                 │
│                                                      │
│  ┌─────────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ STM32F103   │ │ GD32VF103│ │ ESP32            │ │
│  │ (ARM M3)    │ │ (RISC-V) │ │ (Xtensa dual)    │ │
│  │             │ │          │ │                  │ │
│  │ hal_stm32.c │ │hal_riscv.c│ │ hal_esp32.c     │ │
│  └─────────────┘ └──────────┘ └──────────────────┘ │
│                                                      │
│  Each implements same HAL API for their hardware    │
└─────────────────────────────────────────────────────┘
```

### 1.2 Project Structure

```
grbl/
├── core/                          # Platform-independent GRBL core
│   ├── planner.c/h               # Motion planning (portable)
│   ├── gcode.c/h                 # G-code parser (portable)
│   ├── protocol.c/h              # Protocol handler
│   ├── motion_control.c/h        # Motion algorithms
│   ├── settings.c/h              # Settings management
│   ├── report.c/h                # Status reporting
│   ├── jog.c/h                   # Jogging mode
│   ├── probe.c/h                 # Probing
│   ├── print.c/h                 # Print utilities
│   ├── nuts_bolts.c/h            # Utility functions
│   └── grbl.h                    # Main header (no platform includes!)
│
├── hal/                           # Hardware Abstraction Layer
│   ├── grbl_hal.h                # Main HAL API specification
│   ├── grbl_hal_timer.h          # Timer HAL interface
│   ├── grbl_hal_gpio.h           # GPIO HAL interface
│   ├── grbl_hal_serial.h         # Serial HAL interface
│   ├── grbl_hal_nvmem.h          # Non-volatile memory HAL
│   ├── grbl_hal_system.h         # System HAL (reset, interrupts)
│   └── grbl_hal_types.h          # Common type definitions
│
├── platforms/                     # Platform-specific implementations
│   ├── stm32f103/                # ARM Cortex-M3 (STM32F103)
│   │   ├── hal_platform.c        # Platform HAL implementation
│   │   ├── hal_timer.c           # Timer implementation
│   │   ├── hal_gpio.c            # GPIO implementation
│   │   ├── hal_serial.c          # UART implementation
│   │   ├── hal_nvmem.c           # Flash EEPROM emulation
│   │   ├── platform_config.h     # Platform-specific config
│   │   ├── pin_map.h             # Pin mapping definitions
│   │   ├── Makefile              # Build configuration
│   │   └── startup.s             # Startup code
│   │
│   ├── gd32vf103/                # RISC-V (GigaDevice)
│   │   ├── hal_platform.c
│   │   ├── hal_timer.c
│   │   ├── hal_gpio.c
│   │   ├── hal_serial.c
│   │   ├── hal_nvmem.c
│   │   ├── platform_config.h
│   │   ├── pin_map.h
│   │   ├── Makefile
│   │   └── startup.s
│   │
│   ├── esp32/                    # ESP32 (Xtensa, dual-core)
│   │   ├── hal_platform.c
│   │   ├── hal_timer.c
│   │   ├── hal_gpio.c
│   │   ├── hal_serial.c
│   │   ├── hal_nvmem.c           # Uses ESP32 NVS
│   │   ├── hal_wifi.c            # ESP32-specific: WiFi support
│   │   ├── platform_config.h
│   │   ├── pin_map.h
│   │   └── CMakeLists.txt        # ESP-IDF build
│   │
│   ├── avr_atmega328p/           # Original AVR platform
│   │   ├── hal_platform.c        # AVR HAL wrapper (legacy)
│   │   ├── hal_timer.c
│   │   ├── hal_gpio.c
│   │   ├── hal_serial.c
│   │   ├── hal_nvmem.c
│   │   ├── platform_config.h
│   │   ├── pin_map.h
│   │   └── Makefile
│   │
│   └── template/                 # Template for new platforms
│       ├── README.md             # Porting guide
│       ├── hal_platform.c        # Skeleton implementation
│       ├── hal_timer.c
│       ├── hal_gpio.c
│       ├── hal_serial.c
│       ├── hal_nvmem.c
│       └── checklist.md          # Porting checklist
│
├── config/                        # Machine configurations
│   ├── defaults_generic.h        # Generic machine
│   ├── defaults_shapeoko.h       # Shapeoko 2
│   ├── defaults_xcarve.h         # X-Carve
│   └── ...
│
├── main.c                         # Main entry point (calls HAL init)
└── Makefile                       # Top-level build system

```

---

## 2. HAL API Specification

### 2.1 Timer HAL (`hal/grbl_hal_timer.h`)

Timers are the most critical component - must provide precise interrupt timing for stepper control.

```c
#ifndef GRBL_HAL_TIMER_H
#define GRBL_HAL_TIMER_H

#include <stdint.h>
#include <stdbool.h>

/* Timer Handle Type */
typedef void* hal_timer_handle_t;

/* Timer Callback Function Type */
typedef void (*hal_timer_callback_t)(void);

/* Timer Configuration */
typedef struct {
    uint32_t frequency_hz;      // Desired interrupt frequency
    uint8_t priority;           // Interrupt priority (0=highest)
    hal_timer_callback_t callback; // ISR callback function
} hal_timer_config_t;

/* Timer IDs for GRBL */
typedef enum {
    HAL_TIMER_STEPPER,          // Main stepper interrupt (TIMER1 on AVR)
    HAL_TIMER_STEP_PULSE_RESET, // Step pulse reset (TIMER0 on AVR)
    HAL_TIMER_SPINDLE_PWM,      // Spindle PWM (TIMER2 on AVR)
    HAL_TIMER_COUNT
} hal_timer_id_t;

/* Initialize timer subsystem */
void hal_timer_init(void);

/* Configure and start a timer */
hal_timer_handle_t hal_timer_create(hal_timer_id_t timer_id,
                                     const hal_timer_config_t* config);

/* Set timer frequency (for variable stepper rate) */
void hal_timer_set_frequency(hal_timer_handle_t timer, uint32_t frequency_hz);

/* Start timer */
void hal_timer_start(hal_timer_handle_t timer);

/* Stop timer */
void hal_timer_stop(hal_timer_handle_t timer);

/* Set timer compare value (for step pulse timing) */
void hal_timer_set_compare(hal_timer_handle_t timer, uint32_t ticks);

/* Get current timer tick count */
uint32_t hal_timer_get_ticks(hal_timer_handle_t timer);

/* Get timer resolution in nanoseconds per tick */
uint32_t hal_timer_get_resolution_ns(hal_timer_handle_t timer);

/* PWM-specific functions */
void hal_timer_pwm_set_duty(hal_timer_handle_t timer, uint16_t duty_cycle);
void hal_timer_pwm_enable(hal_timer_handle_t timer, bool enable);

#endif // GRBL_HAL_TIMER_H
```

**Platform Implementation Requirements:**
- Stepper timer must support 20 Hz to 100+ kHz
- Interrupt latency < 5 μs
- Timer resolution ≤ 100 ns (better than AVR's 62.5 ns)
- Priority configurable via NVIC/equivalent

---

### 2.2 GPIO HAL (`hal/grbl_hal_gpio.h`)

GPIO must support fast pin manipulation for step/direction signals.

```c
#ifndef GRBL_HAL_GPIO_H
#define GRBL_HAL_GPIO_H

#include <stdint.h>
#include <stdbool.h>

/* GPIO Pin Handle */
typedef void* hal_gpio_pin_t;

/* GPIO Direction */
typedef enum {
    HAL_GPIO_INPUT,
    HAL_GPIO_OUTPUT
} hal_gpio_direction_t;

/* GPIO Pull Mode */
typedef enum {
    HAL_GPIO_PULL_NONE,
    HAL_GPIO_PULL_UP,
    HAL_GPIO_PULL_DOWN
} hal_gpio_pull_t;

/* GPIO Interrupt Trigger */
typedef enum {
    HAL_GPIO_IRQ_RISING,
    HAL_GPIO_IRQ_FALLING,
    HAL_GPIO_IRQ_BOTH
} hal_gpio_irq_trigger_t;

/* GPIO Interrupt Callback */
typedef void (*hal_gpio_irq_callback_t)(hal_gpio_pin_t pin);

/* GPIO Configuration */
typedef struct {
    hal_gpio_direction_t direction;
    hal_gpio_pull_t pull;
    bool initial_state;         // For outputs
} hal_gpio_config_t;

/* GPIO Interrupt Configuration */
typedef struct {
    hal_gpio_irq_trigger_t trigger;
    uint8_t priority;           // Interrupt priority
    hal_gpio_irq_callback_t callback;
} hal_gpio_irq_config_t;

/* Initialize GPIO subsystem */
void hal_gpio_init(void);

/* Configure a GPIO pin */
hal_gpio_pin_t hal_gpio_config(uint32_t pin_id, const hal_gpio_config_t* config);

/* Write to output pin (single pin) */
void hal_gpio_write(hal_gpio_pin_t pin, bool state);

/* Read from input pin */
bool hal_gpio_read(hal_gpio_pin_t pin);

/* Toggle output pin */
void hal_gpio_toggle(hal_gpio_pin_t pin);

/* Fast multi-pin write (for stepper step/direction) */
void hal_gpio_write_port(uint32_t port_id, uint32_t mask, uint32_t value);

/* Configure interrupt on GPIO pin */
void hal_gpio_irq_config(hal_gpio_pin_t pin, const hal_gpio_irq_config_t* config);

/* Enable/disable GPIO interrupt */
void hal_gpio_irq_enable(hal_gpio_pin_t pin, bool enable);

#endif // GRBL_HAL_GPIO_H
```

**Platform Implementation Requirements:**
- `hal_gpio_write_port()` must be atomic and fast (< 1 μs)
- Support interrupt on any pin
- Debouncing in hardware or software

---

### 2.3 Serial HAL (`hal/grbl_hal_serial.h`)

Serial communication for G-code streaming and status reports.

```c
#ifndef GRBL_HAL_SERIAL_H
#define GRBL_HAL_SERIAL_H

#include <stdint.h>
#include <stdbool.h>

/* Serial Port Handle */
typedef void* hal_serial_handle_t;

/* Serial Configuration */
typedef struct {
    uint32_t baud_rate;         // Baud rate (115200 default)
    uint8_t data_bits;          // 7, 8, 9
    uint8_t stop_bits;          // 1, 2
    uint8_t parity;             // 0=none, 1=odd, 2=even
    uint16_t rx_buffer_size;    // RX ring buffer size
    uint16_t tx_buffer_size;    // TX ring buffer size
} hal_serial_config_t;

/* Serial Event Callback */
typedef enum {
    HAL_SERIAL_EVENT_RX_CHAR,   // Character received
    HAL_SERIAL_EVENT_TX_EMPTY,  // TX buffer empty
    HAL_SERIAL_EVENT_ERROR      // Error occurred
} hal_serial_event_t;

typedef void (*hal_serial_callback_t)(hal_serial_event_t event, uint8_t data);

/* Initialize serial subsystem */
void hal_serial_init(void);

/* Open serial port */
hal_serial_handle_t hal_serial_open(uint8_t port_num,
                                     const hal_serial_config_t* config,
                                     hal_serial_callback_t callback);

/* Close serial port */
void hal_serial_close(hal_serial_handle_t serial);

/* Write single byte (non-blocking) */
bool hal_serial_write(hal_serial_handle_t serial, uint8_t data);

/* Write buffer (non-blocking, returns bytes written) */
uint16_t hal_serial_write_buffer(hal_serial_handle_t serial,
                                  const uint8_t* data, uint16_t length);

/* Read single byte (non-blocking, returns false if no data) */
bool hal_serial_read(hal_serial_handle_t serial, uint8_t* data);

/* Get number of bytes available in RX buffer */
uint16_t hal_serial_available(hal_serial_handle_t serial);

/* Get free space in TX buffer */
uint16_t hal_serial_tx_free(hal_serial_handle_t serial);

/* Flush TX buffer (wait for transmission complete) */
void hal_serial_flush_tx(hal_serial_handle_t serial);

/* Clear RX buffer */
void hal_serial_flush_rx(hal_serial_handle_t serial);

/* Optional: DMA support for high-performance platforms */
#ifdef HAL_SERIAL_DMA_SUPPORT
void hal_serial_dma_enable(hal_serial_handle_t serial, bool enable);
#endif

#endif // GRBL_HAL_SERIAL_H
```

**Platform Implementation Requirements:**
- Interrupt-driven RX/TX
- Ring buffer implementation
- Optionally use DMA on capable platforms (ESP32, STM32)
- Handle 115200 baud without data loss

---

### 2.4 Non-Volatile Memory HAL (`hal/grbl_hal_nvmem.h`)

Platform-agnostic persistent storage for settings.

```c
#ifndef GRBL_HAL_NVMEM_H
#define GRBL_HAL_NVMEM_H

#include <stdint.h>
#include <stdbool.h>

/* NV Memory Configuration */
typedef struct {
    uint32_t size_bytes;        // Total available size
    uint32_t page_size;         // Erase page size (0 if byte-level)
    uint32_t write_time_us;     // Typical write time per byte
} hal_nvmem_info_t;

/* Initialize non-volatile memory */
void hal_nvmem_init(void);

/* Get NV memory information */
hal_nvmem_info_t hal_nvmem_get_info(void);

/* Read byte from NV memory */
uint8_t hal_nvmem_read_byte(uint32_t address);

/* Write byte to NV memory */
void hal_nvmem_write_byte(uint32_t address, uint8_t value);

/* Read buffer from NV memory */
void hal_nvmem_read_buffer(uint32_t address, uint8_t* buffer, uint32_t length);

/* Write buffer to NV memory */
void hal_nvmem_write_buffer(uint32_t address, const uint8_t* buffer, uint32_t length);

/* Commit changes (for platforms that buffer writes) */
void hal_nvmem_commit(void);

/* Erase page (for flash-based implementations) */
void hal_nvmem_erase_page(uint32_t page_address);

#endif // GRBL_HAL_NVMEM_H
```

**Platform Implementation Examples:**
- **AVR**: Direct EEPROM access
- **STM32**: Flash emulation (last 2 pages)
- **ESP32**: NVS (Non-Volatile Storage) partition
- **External**: I2C EEPROM (24LC256)

---

### 2.5 System HAL (`hal/grbl_hal_system.h`)

System-level functions: initialization, interrupts, timing, reset.

```c
#ifndef GRBL_HAL_SYSTEM_H
#define GRBL_HAL_SYSTEM_H

#include <stdint.h>
#include <stdbool.h>

/* Platform information */
typedef struct {
    const char* platform_name;  // "STM32F103", "GD32VF103", "ESP32"
    const char* cpu_arch;       // "ARM Cortex-M3", "RISC-V RV32IMAC"
    uint32_t cpu_freq_hz;       // CPU frequency
    uint32_t ram_size_kb;       // Total RAM
    uint32_t flash_size_kb;     // Total flash
} hal_platform_info_t;

/* Initialize platform (called first) */
void hal_platform_init(void);

/* Get platform information */
hal_platform_info_t hal_platform_get_info(void);

/* System reset */
void hal_system_reset(void);

/* Enable/disable global interrupts */
void hal_interrupts_enable(void);
void hal_interrupts_disable(void);

/* Critical section (save/restore interrupt state) */
uint32_t hal_critical_enter(void);
void hal_critical_exit(uint32_t state);

/* Delay functions */
void hal_delay_ms(uint32_t milliseconds);
void hal_delay_us(uint32_t microseconds);

/* Get system tick count (milliseconds since boot) */
uint32_t hal_millis(void);

/* Get high-resolution tick count (microseconds since boot) */
uint64_t hal_micros(void);

/* Watchdog timer */
void hal_watchdog_init(uint32_t timeout_ms);
void hal_watchdog_reset(void);

/* Optional: Get CPU usage percentage (if platform supports) */
#ifdef HAL_SYSTEM_CPU_MONITOR
uint8_t hal_system_get_cpu_usage(void);
#endif

#endif // GRBL_HAL_SYSTEM_H
```

---

### 2.6 Platform Configuration (`platforms/xxx/platform_config.h`)

Each platform defines hardware capabilities and pin mappings.

```c
#ifndef PLATFORM_CONFIG_H
#define PLATFORM_CONFIG_H

/* Platform Identification */
#define PLATFORM_NAME       "STM32F103C8T6 Blue Pill"
#define PLATFORM_CPU        "ARM Cortex-M3"
#define PLATFORM_CPU_FREQ   72000000UL  // 72 MHz
#define PLATFORM_RAM_SIZE   20          // KB
#define PLATFORM_FLASH_SIZE 64          // KB

/* Timer Capabilities */
#define HAL_TIMER_COUNT             7
#define HAL_TIMER_MAX_FREQ_HZ       1000000UL  // 1 MHz max
#define HAL_TIMER_RESOLUTION_NS     14         // 13.9 ns @ 72MHz

/* GPIO Capabilities */
#define HAL_GPIO_COUNT              37
#define HAL_GPIO_PORTS              3   // GPIOA, GPIOB, GPIOC

/* Serial Capabilities */
#define HAL_SERIAL_PORTS            3   // USART1, USART2, USART3
#define HAL_SERIAL_MAX_BAUD         2000000  // 2 Mbaud max

/* Non-Volatile Memory */
#define HAL_NVMEM_TYPE              HAL_NVMEM_FLASH_EMULATED
#define HAL_NVMEM_SIZE              1024    // Bytes
#define HAL_NVMEM_PAGE_SIZE         1024    // Flash page size

/* Feature Flags */
#define HAL_SUPPORT_DMA             1
#define HAL_SUPPORT_FPU             0   // Cortex-M3 has no FPU
#define HAL_SUPPORT_USB             0
#define HAL_SUPPORT_ETHERNET        0
#define HAL_SUPPORT_WIFI            0

#endif // PLATFORM_CONFIG_H
```

---

## 3. Platform Comparison Matrix

| Feature | AVR ATmega328p | STM32F103 (ARM M3) | GD32VF103 (RISC-V) | ESP32 (Xtensa) |
|---------|----------------|--------------------|--------------------|----------------|
| **CPU Speed** | 16 MHz | 72 MHz | 108 MHz | 240 MHz (dual-core) |
| **Architecture** | 8-bit RISC | 32-bit ARM | 32-bit RISC-V | 32-bit Xtensa + dual |
| **Flash** | 32 KB | 64-128 KB | 128 KB | 4 MB |
| **RAM** | 2 KB | 20 KB | 32 KB | 520 KB |
| **FPU** | No | No | No | Yes (single-precision) |
| **Timers** | 3x | 7x | 5x | 4x (+ RTC) |
| **UART** | 1x | 3x | 3x | 3x |
| **DMA** | No | 7 channels | 5 channels | 13 channels |
| **Native EEPROM** | Yes (1KB) | No (flash emul.) | No (flash emul.) | No (NVS) |
| **USB** | No | No | Yes (OTG) | No |
| **WiFi** | No | No | No | **Yes (802.11 b/g/n)** |
| **Bluetooth** | No | No | No | **Yes (BLE)** |
| **Cost** | $2-3 | $2-3 | $2-4 | $3-5 |
| **Availability** | Good | Excellent | Good | Excellent |
| **Ecosystem** | Huge (Arduino) | Huge (STM32Cube) | Growing | Huge (ESP-IDF) |

---

## 4. Platform-Specific Implementations

### 4.1 STM32F103 (ARM Cortex-M3)

**Advantages:**
- Huge ecosystem, excellent documentation
- 4.5x faster than AVR
- 10x more RAM
- Hardware FPU on F4 series

**Implementation Notes:**
```c
// hal_timer.c - Using TIM2 for stepper interrupt
void hal_timer_stepper_init(void) {
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;

    TIM2->PSC = 0;                      // No prescaler (72 MHz)
    TIM2->ARR = 3600;                   // 20 kHz initial
    TIM2->DIER |= TIM_DIER_UIE;         // Enable interrupt

    NVIC_SetPriority(TIM2_IRQn, 0);     // Highest priority
    NVIC_EnableIRQ(TIM2_IRQn);

    TIM2->CR1 |= TIM_CR1_CEN;           // Start timer
}

void TIM2_IRQHandler(void) {
    if (TIM2->SR & TIM_SR_UIF) {
        TIM2->SR = ~TIM_SR_UIF;
        stepper_driver_isr();            // Call GRBL stepper ISR
    }
}

// hal_gpio.c - Fast port write using BSRR
void hal_gpio_write_port(uint32_t port_id, uint32_t mask, uint32_t value) {
    GPIO_TypeDef* port = (GPIO_TypeDef*)port_id;

    // Atomic operation: set and reset in one register write
    uint32_t bsrr = (value & mask) | ((~value & mask) << 16);
    port->BSRR = bsrr;
}
```

**Flash EEPROM Emulation:**
Use ST's AN4061 EEPROM emulation library (page-based).

---

### 4.2 GD32VF103 (RISC-V)

**Advantages:**
- 108 MHz RISC-V core (faster than STM32F103)
- Pin-compatible with STM32F103
- Lower cost
- **Open architecture (RISC-V)**

**Implementation Notes:**
```c
// hal_system.c - RISC-V specific interrupt handling
#include "riscv_encoding.h"

void hal_critical_enter(void) {
    clear_csr(mstatus, MSTATUS_MIE);  // Disable machine interrupts
}

void hal_critical_exit(void) {
    set_csr(mstatus, MSTATUS_MIE);    // Enable machine interrupts
}

// Timer implementation similar to STM32 (GD32 timers compatible)
// GPIO implementation similar to STM32 (register-compatible)
```

**Key Difference:** RISC-V uses CSR (Control and Status Registers) instead of ARM's NVIC, but timer/GPIO peripherals are STM32-compatible.

---

### 4.3 ESP32 (Xtensa + Dual Core)

**Advantages:**
- 240 MHz dual-core CPU
- **Built-in WiFi** - wireless G-code streaming!
- **Built-in Bluetooth** - smartphone control
- Huge flash (4 MB)
- Huge RAM (520 KB)
- Hardware FPU

**Unique Features:**
```c
// hal_wifi.c - ESP32-specific WiFi support
#include "esp_wifi.h"
#include "esp_http_server.h"

void hal_wifi_init(const char* ssid, const char* password) {
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    esp_wifi_init(&cfg);
    esp_wifi_set_mode(WIFI_MODE_STA);
    // Connect to WiFi...
}

// Serve G-code over HTTP
httpd_handle_t start_gcode_server(void) {
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    httpd_handle_t server = NULL;
    httpd_start(&server, &config);

    httpd_uri_t gcode_upload = {
        .uri = "/upload",
        .method = HTTP_POST,
        .handler = gcode_upload_handler
    };
    httpd_register_uri_handler(server, &gcode_upload);

    return server;
}
```

**Dual-Core Utilization:**
- **Core 0**: GRBL real-time tasks (stepper, motion planning)
- **Core 1**: WiFi, Bluetooth, web server, display

**Timer Implementation:**
```c
// hal_timer.c - Using ESP32 hardware timer
#include "driver/timer.h"

void hal_timer_stepper_init(void) {
    timer_config_t config = {
        .divider = 80,              // 80 MHz / 80 = 1 MHz
        .counter_dir = TIMER_COUNT_UP,
        .counter_en = TIMER_PAUSE,
        .alarm_en = TIMER_ALARM_EN,
        .auto_reload = true
    };

    timer_init(TIMER_GROUP_0, TIMER_0, &config);
    timer_set_counter_value(TIMER_GROUP_0, TIMER_0, 0);
    timer_set_alarm_value(TIMER_GROUP_0, TIMER_0, 1000); // 1 kHz initial
    timer_enable_intr(TIMER_GROUP_0, TIMER_0);
    timer_isr_register(TIMER_GROUP_0, TIMER_0, stepper_isr, NULL, 0, NULL);
    timer_start(TIMER_GROUP_0, TIMER_0);
}
```

**NVS for Settings:**
```c
// hal_nvmem.c - Using ESP32 NVS (Non-Volatile Storage)
#include "nvs_flash.h"

void hal_nvmem_init(void) {
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES) {
        nvs_flash_erase();
        nvs_flash_init();
    }
}

void hal_nvmem_write_byte(uint32_t address, uint8_t value) {
    nvs_handle_t handle;
    nvs_open("grbl_settings", NVS_READWRITE, &handle);
    nvs_set_u8(handle, address_to_key(address), value);
    nvs_commit(handle);
    nvs_close(handle);
}
```

---

### 4.4 AVR ATmega328p (Legacy Support)

**Keep AVR platform using HAL:**
```c
// platforms/avr_atmega328p/hal_timer.c
void hal_timer_stepper_init(void) {
    // Wrap existing AVR code
    TCCR1B = 0;
    TCCR1A = 0;
    TCCR1B = (1<<WGM12)|(1<<CS10);
    TIMSK1 |= (1<<OCIE1A);
}

ISR(TIMER1_COMPA_vect) {
    stepper_driver_isr();  // Call platform-independent ISR
}
```

This maintains backward compatibility while using new architecture.

---

## 5. GRBL Core Modifications

### 5.1 Remove Hardware Dependencies

**Before (cpu_map.h):**
```c
#define STEP_PORT       PORTD
#define STEP_MASK       ((1<<2)|(1<<3)|(1<<4))
```

**After (core/stepper.c):**
```c
#include "grbl_hal.h"

static hal_gpio_pin_t step_pins[N_AXIS];
static hal_gpio_pin_t dir_pins[N_AXIS];

void stepper_init(void) {
    // Get pin handles from platform
    step_pins[X_AXIS] = hal_gpio_config(PIN_X_STEP, &output_config);
    step_pins[Y_AXIS] = hal_gpio_config(PIN_Y_STEP, &output_config);
    step_pins[Z_AXIS] = hal_gpio_config(PIN_Z_STEP, &output_config);
    // ...
}

// In ISR
void stepper_driver_isr(void) {
    // Platform-agnostic pin writes
    if (step_bits & X_STEP_BIT) {
        hal_gpio_write(step_pins[X_AXIS], true);
    }
    // Or use fast port write:
    hal_gpio_write_port(STEP_PORT_ID, step_mask, step_bits);
}
```

### 5.2 Abstract EEPROM Access

**Before (eeprom.c):**
```c
uint8_t eeprom_get_char(uint32_t addr) {
    EEAR = addr;
    EECR |= (1<<EERE);
    return EEDR;
}
```

**After (core/settings.c):**
```c
#include "grbl_hal.h"

uint8_t settings_read_byte(uint32_t addr) {
    return hal_nvmem_read_byte(addr);
}

void settings_write_byte(uint32_t addr, uint8_t value) {
    hal_nvmem_write_byte(addr, value);
}
```

### 5.3 Abstract Serial Communication

**Before (serial.c):**
```c
void serial_write(uint8_t data) {
    uint8_t next_head = serial_tx_buffer_head + 1;
    if (next_head == TX_RING_BUFFER) next_head = 0;

    while (next_head == serial_tx_buffer_tail) {}

    serial_tx_buffer[serial_tx_buffer_head] = data;
    serial_tx_buffer_head = next_head;

    UCSR0B |= (1 << UDRIE0);
}
```

**After (core/protocol.c):**
```c
#include "grbl_hal.h"

static hal_serial_handle_t grbl_serial;

void protocol_init(void) {
    hal_serial_config_t config = {
        .baud_rate = 115200,
        .data_bits = 8,
        .stop_bits = 1,
        .parity = 0,
        .rx_buffer_size = 128,
        .tx_buffer_size = 104
    };

    grbl_serial = hal_serial_open(0, &config, serial_event_callback);
}

void protocol_send_char(uint8_t data) {
    hal_serial_write(grbl_serial, data);
}
```

---

## 6. Build System

### 6.1 Platform Selection

```makefile
# Top-level Makefile

# Select platform (default: stm32f103)
PLATFORM ?= stm32f103

# Available platforms
PLATFORMS := avr_atmega328p stm32f103 gd32vf103 esp32

# Include platform-specific Makefile
include platforms/$(PLATFORM)/Makefile

# Core sources (platform-independent)
CORE_SRCS := \
    core/planner.c \
    core/gcode.c \
    core/protocol.c \
    core/motion_control.c \
    core/settings.c \
    core/report.c \
    core/jog.c \
    core/probe.c \
    core/print.c \
    core/nuts_bolts.c \
    main.c

# HAL sources (from platform Makefile)
HAL_SRCS := $(PLATFORM_HAL_SRCS)

# Combine
SRCS := $(CORE_SRCS) $(HAL_SRCS)

# Compile
all: grbl.bin
```

### 6.2 Platform-Specific Makefiles

**platforms/stm32f103/Makefile:**
```makefile
# STM32F103 Platform Makefile

# Toolchain
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# MCU
MCU = -mcpu=cortex-m3 -mthumb

# Platform HAL sources
PLATFORM_HAL_SRCS := \
    platforms/stm32f103/hal_platform.c \
    platforms/stm32f103/hal_timer.c \
    platforms/stm32f103/hal_gpio.c \
    platforms/stm32f103/hal_serial.c \
    platforms/stm32f103/hal_nvmem.c \
    platforms/stm32f103/startup.s

# Includes
INCLUDES := \
    -Icore \
    -Ihal \
    -Iplatforms/stm32f103 \
    -Iplatforms/stm32f103/CMSIS/Include \
    -Iplatforms/stm32f103/STM32F1xx_HAL_Driver/Inc

# Defines
DEFINES := -DSTM32F103xB -DUSE_HAL_DRIVER

# Flags
CFLAGS := $(MCU) $(DEFINES) $(INCLUDES) -Os -Wall -fdata-sections -ffunction-sections
LDFLAGS := $(MCU) -Tplatforms/stm32f103/linker.ld -Wl,--gc-sections -lm

# Build targets
grbl.elf: $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) $(LDFLAGS) -o $@

grbl.bin: grbl.elf
	$(OBJCOPY) -O binary $< $@
	$(SIZE) grbl.elf

flash: grbl.bin
	st-flash write grbl.bin 0x8000000
```

**platforms/esp32/CMakeLists.txt:**
```cmake
# ESP32 Platform CMakeLists.txt (ESP-IDF)

cmake_minimum_required(VERSION 3.5)

set(COMPONENT_SRCS
    "../../core/planner.c"
    "../../core/gcode.c"
    "../../core/protocol.c"
    # ... more core sources
    "hal_platform.c"
    "hal_timer.c"
    "hal_gpio.c"
    "hal_serial.c"
    "hal_nvmem.c"
    "hal_wifi.c"
)

set(COMPONENT_ADD_INCLUDEDIRS
    "../../core"
    "../../hal"
    "."
)

register_component()
```

---

## 7. Porting Guide (New Platform)

### 7.1 Checklist

To port GRBL to a new platform:

- [ ] **Step 1:** Copy `platforms/template/` to `platforms/your_platform/`
- [ ] **Step 2:** Fill in `platform_config.h` with your hardware specs
- [ ] **Step 3:** Define pin mappings in `pin_map.h`
- [ ] **Step 4:** Implement HAL functions in order of priority:
  - [ ] `hal_platform.c` - System initialization
  - [ ] `hal_system.c` - Critical sections, delays
  - [ ] `hal_gpio.c` - GPIO control
  - [ ] `hal_timer.c` - Timer interrupts (**most critical**)
  - [ ] `hal_serial.c` - UART communication
  - [ ] `hal_nvmem.c` - Settings storage
- [ ] **Step 5:** Create Makefile or CMakeLists.txt for your toolchain
- [ ] **Step 6:** Test each HAL component individually
- [ ] **Step 7:** Integrate with GRBL core and test motion

### 7.2 Validation Tests

Each platform implementation must pass:

1. **GPIO Test**: Toggle LED at 1 kHz
2. **Timer Test**: Generate 10 kHz interrupt, measure with oscilloscope
3. **Serial Test**: Echo characters at 115200 baud
4. **NVMEM Test**: Write/read 1 KB, verify after reset
5. **Stepper Test**: Generate step pulses from G-code
6. **Motion Test**: Execute full 3-axis toolpath

---

## 8. Future Platform Candidates

### 8.1 RP2040 (Raspberry Pi Pico)

**Specifications:**
- Dual Cortex-M0+ @ 133 MHz
- 264 KB RAM
- 2 MB flash
- **PIO (Programmable I/O)** - can generate step pulses in hardware!
- **Cost:** $1-4

**Killer Feature:** PIO state machines can generate perfectly timed step pulses without CPU intervention - offload entire stepper timing to hardware!

### 8.2 CH32V307 (RISC-V)

**Specifications:**
- RISC-V @ 144 MHz
- 64 KB RAM
- 256 KB flash
- Ethernet MAC
- USB OTG
- **Cost:** $2-3

### 8.3 Nordic nRF52840 (ARM M4 + Bluetooth)

**Specifications:**
- Cortex-M4F @ 64 MHz
- 256 KB RAM
- 1 MB flash
- **Bluetooth 5.0 LE** - wireless control
- **Cost:** $3-5

**Use Case:** Wireless CNC pendant control

### 8.4 STM32H7 (High Performance)

**Specifications:**
- Cortex-M7 @ 480 MHz
- 1 MB RAM
- 2 MB flash
- Double-precision FPU
- Ethernet, USB, CAN
- **Cost:** $10-15

**Use Case:** Industrial 6+ axis CNC, complex kinematics

---

## 9. Benefits of Platform-Agnostic Design

### 9.1 For Users

- **Choice**: Select platform based on needs (WiFi? Low cost? High performance?)
- **Future-Proof**: Easy migration to newer/better platforms
- **Availability**: If one chip has supply issues, use another
- **Cost**: Competition between platforms drives prices down

### 9.2 For Developers

- **Maintainability**: Fix bugs in core once, all platforms benefit
- **Testability**: Can test algorithms on fast platform (ESP32), deploy on cheap platform (STM32)
- **Collaboration**: Multiple developers can work on different platforms simultaneously
- **Innovation**: New platforms can add unique features (WiFi on ESP32) without breaking core

### 9.3 For Project

- **Wider Adoption**: More platforms = more users
- **Longevity**: Not tied to single manufacturer
- **Community**: Each platform brings its own community

---

## 10. Implementation Roadmap

### Phase 1: HAL Definition (2 weeks)
- [ ] Finalize HAL API specifications
- [ ] Create header files with full documentation
- [ ] Define platform configuration structure
- [ ] Create porting template and guide

### Phase 2: Reference Implementation - STM32F103 (4-6 weeks)
- [ ] Implement all HAL functions for STM32F103
- [ ] Migrate GRBL core to use HAL (remove AVR dependencies)
- [ ] Test and validate on Blue Pill hardware
- [ ] Document performance benchmarks

### Phase 3: Second Platform - ESP32 (3-4 weeks)
- [ ] Implement HAL for ESP32
- [ ] Add WiFi support (ESP32-specific feature)
- [ ] Validate HAL abstraction works for different architecture
- [ ] Create web interface for G-code upload

### Phase 4: Third Platform - RISC-V GD32VF103 (2-3 weeks)
- [ ] Implement HAL for RISC-V
- [ ] Validate cross-architecture portability
- [ ] Performance comparison

### Phase 5: Legacy Support - AVR Wrapper (1 week)
- [ ] Wrap existing AVR code with HAL
- [ ] Verify backward compatibility
- [ ] Regression testing

### Phase 6: Documentation & Community (Ongoing)
- [ ] Create porting guide with examples
- [ ] Document platform-specific optimizations
- [ ] Create platform comparison matrix
- [ ] Video tutorials for each platform

---

## 11. Conclusion

Platform-agnostic HAL design provides:

✅ **Flexibility**: Support ARM, RISC-V, ESP32, and future architectures
✅ **Maintainability**: Core algorithms separate from hardware
✅ **Scalability**: Easy to add new platforms
✅ **Future-Proof**: Not locked to single vendor
✅ **Innovation**: Platforms can add unique features (WiFi, Bluetooth)

**Recommendation:** Start with STM32F103 (familiar, well-documented), then ESP32 (demonstrates WiFi capability), then RISC-V (demonstrates open architecture).

This approach creates **GRBL 2.0** - a truly portable, modern CNC controller firmware for the next decade.

---

**END OF HAL DESIGN DOCUMENT**

*Generated: 2025-11-18*
*Version: 1.0*
