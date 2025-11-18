# GRBL ARM Port Analysis Report

**Date:** 2025-11-18
**Target Architecture:** ARM Cortex-M (STM32 family recommended)
**Current Architecture:** AVR ATmega328p (Arduino Uno)

---

## Executive Summary

This report provides a comprehensive analysis of porting GRBL CNC controller firmware from AVR ATmega328p to ARM Cortex-M architecture. The port requires rewriting all hardware-dependent code (~30% of codebase) while preserving the motion planning and G-code parsing algorithms (~70% portable).

**Key Findings:**
- **Current Target:** 8-bit AVR @ 16MHz, 32KB flash, 2KB RAM, 1KB EEPROM
- **Recommended ARM Target:** STM32F103 (Cortex-M3 @ 72MHz, 64-128KB flash, 20KB RAM)
- **Critical Components:** 7 interrupt service routines, 3 hardware timers, direct GPIO manipulation, EEPROM emulation
- **Estimated Effort:** Medium complexity - requires deep embedded systems knowledge
- **Benefits:** 4.5x faster CPU, 10x more RAM, improved interrupt handling, future expansion capability

---

## 1. Current Architecture Overview

### 1.1 Hardware Specifications (ATmega328p)
```
CPU:        8-bit AVR @ 16MHz
Flash:      32 KB
SRAM:       2 KB
EEPROM:     1 KB (non-volatile settings storage)
Timers:     3x (two 8-bit, one 16-bit)
UART:       1x @ up to 115.2kbaud
GPIO:       23 pins (organized as PORTB, PORTC, PORTD)
Interrupts: Pin Change Interrupts (PCINT), Timer Compare Match
```

### 1.2 Toolchain
- **Compiler:** avr-gcc (GCC for AVR)
- **Programmer:** avrdude
- **Build System:** Makefile
- **Includes:** `<avr/io.h>`, `<avr/interrupt.h>`, `<avr/pgmspace.h>`, `<avr/wdt.h>`, `<util/delay.h>`

---

## 2. Codebase Structure Analysis

### 2.1 Project Layout
```
grbl/
├── main.c              - Entry point, initialization
├── grbl.h              - Main header, AVR includes
├── config.h            - Compile-time configuration
├── cpu_map.h           - ⚠️ CRITICAL: Processor-specific mappings
├── defaults.h          - Machine defaults (portable)
├── stepper.c/h         - ⚠️ CRITICAL: Stepper ISRs, Timer1
├── serial.c/h          - ⚠️ CRITICAL: UART ISRs
├── system.c/h          - ⚠️ CRITICAL: System ISRs, control pins
├── limits.c/h          - ⚠️ CRITICAL: Limit switch ISRs
├── spindle_control.c/h - ⚠️ PWM control (Timer2)
├── eeprom.c/h          - ⚠️ CRITICAL: EEPROM access
├── coolant_control.c/h - GPIO control
├── planner.c/h         - ✓ Motion planning (portable)
├── gcode.c/h           - ✓ G-code parser (portable)
├── motion_control.c/h  - ✓ Motion algorithms (portable)
├── protocol.c/h        - ✓ Protocol handler (portable)
├── report.c/h          - ✓ Status reporting (portable)
├── settings.c/h        - Settings management (uses EEPROM)
├── probe.c/h           - ✓ Probing logic (portable)
├── jog.c/h             - ✓ Jogging mode (portable)
├── print.c/h           - ✓ Print utilities (portable)
└── nuts_bolts.c/h      - ✓ Utility functions (mostly portable)
```

**Legend:**
- ⚠️ CRITICAL: Must be completely rewritten for ARM
- ⚠️: Requires significant modifications
- ✓: Portable with minimal/no changes

---

## 3. Hardware-Dependent Components (Critical for Port)

### 3.1 CPU Map (cpu_map.h) - **HIGHEST PRIORITY**

**Current Implementation:**
- Defines `CPU_MAP_ATMEGA328P`
- Maps all GPIO pins to AVR ports (PORTB, PORTC, PORTD)
- Defines pin masks using bit positions

**Pin Assignments (AVR):**
```c
// Stepper Motors (6 pins)
STEP_PORT_X    = PORTD, bit 2  (Pin D2)
STEP_PORT_Y    = PORTD, bit 3  (Pin D3)
STEP_PORT_Z    = PORTD, bit 4  (Pin D4)
DIR_PORT_X     = PORTD, bit 5  (Pin D5)
DIR_PORT_Y     = PORTD, bit 6  (Pin D6)
DIR_PORT_Z     = PORTD, bit 7  (Pin D7)

// Stepper Enable (1 pin)
STEPPERS_DISABLE_PORT = PORTB, bit 0  (Pin D8)

// Limit Switches (3 pins)
LIMIT_PIN_X    = PORTB, bit 1  (Pin D9)
LIMIT_PIN_Y    = PORTB, bit 2  (Pin D10)
LIMIT_PIN_Z    = PORTB, bit 3  (Pin D11)

// Control Pins (4 pins)
CONTROL_RESET  = PORTC, bit 0  (Pin A0)
CONTROL_FEED_HOLD = PORTC, bit 1  (Pin A1)
CONTROL_CYCLE_START = PORTC, bit 2  (Pin A2)
CONTROL_SAFETY_DOOR = PORTC, bit 3  (Pin A3)

// Spindle (2 pins)
SPINDLE_PWM    = PORTB, bit 3  (Pin D11) - Timer2 PWM
SPINDLE_ENABLE = PORTB, bit 4  (Pin D12)
SPINDLE_DIRECTION = PORTB, bit 5  (Pin D13)

// Coolant (2 pins)
COOLANT_FLOOD  = PORTC, bit 4  (Pin A4)
COOLANT_MIST   = PORTC, bit 5  (Pin A5)

// Probe (1 pin)
PROBE_PIN      = PORTC, bit 5  (Pin A5) - Shared with mist coolant
```

**ARM Port Requirements:**
1. Create `CPU_MAP_STM32F103` (or other ARM MCU)
2. Map to ARM GPIO ports (GPIOA, GPIOB, GPIOC, etc.)
3. Replace bit masks with ARM GPIO pin numbers (0-15)
4. Define GPIO mode configurations (input/output, pull-up/down)
5. Handle 5V vs 3.3V logic levels if needed

**Example ARM Mapping (STM32F103):**
```c
// Step pins: PA0-PA2
// Direction pins: PA3-PA5
// Stepper enable: PA6
// Limit switches: PB0-PB2
// Control pins: PB3-PB6
// Spindle: PB7 (PWM), PB8 (enable), PB9 (direction)
// Coolant: PC0-PC1
// Probe: PC2
```

---

### 3.2 Timer System - **CRITICAL**

GRBL uses all 3 AVR timers for precise real-time control:

#### **Timer1 (16-bit) - Main Stepper Interrupt**
**Location:** `stepper.c:754-844`
**ISR:** `ISR(TIMER1_COMPA_vect)`
**Purpose:** Generate step pulses at variable frequency (up to 30kHz)

**Current Configuration:**
```c
TCCR1B = 0;                    // Stop timer
TCCR1A = 0;                    // CTC mode
TCCR1B = (1<<WGM12)|(1<<CS10); // CTC mode, no prescaler
OCR1A = 1000;                  // Compare match value (variable)
TIMSK1 |= (1<<OCIE1A);         // Enable compare interrupt
```

**Timing Characteristics:**
- **Frequency Range:** 20 Hz to 30 kHz
- **Resolution:** 62.5 ns per tick @ 16MHz
- **Interrupt Latency:** Must complete in < 33.3μs @ 30kHz
- **Critical Path:** Must set step pins, update position, calculate next step

**ARM Port Requirements:**
- Use TIM2, TIM3, or TIM4 (32-bit on STM32F1, 16-bit adequate)
- Configure in PWM mode 2 or Compare mode
- Priority: Highest (NVIC priority 0)
- **Advantage:** ARM @ 72MHz gives 13.9ns resolution (4.5x better)

**Example STM32 Configuration:**
```c
// Use TIM2 (32-bit timer)
TIM2->CR1 = 0;                          // Stop timer
TIM2->PSC = 0;                          // No prescaler (72MHz)
TIM2->ARR = 3600;                       // Auto-reload (20kHz example)
TIM2->DIER |= TIM_DIER_UIE;             // Enable update interrupt
NVIC_SetPriority(TIM2_IRQn, 0);         // Highest priority
NVIC_EnableIRQ(TIM2_IRQn);
TIM2->CR1 |= TIM_CR1_CEN;               // Start timer

// ISR
void TIM2_IRQHandler(void) {
    if (TIM2->SR & TIM_SR_UIF) {
        TIM2->SR = ~TIM_SR_UIF;         // Clear flag
        // Stepper logic here
    }
}
```

#### **Timer0 (8-bit) - Step Pulse Reset**
**Location:** `stepper.c:869-908`
**ISRs:** `ISR(TIMER0_OVF_vect)`, `ISR(TIMER0_COMPA_vect)`
**Purpose:** Create precise step pulse width (typically 10μs)

**Current Configuration:**
```c
TCCR0A = 0;                    // Normal mode
TCCR0B = (1<<CS01);            // Prescaler /8 (2MHz)
TCNT0 = 0;                     // Reset counter
TIMSK0 |= (1<<TOIE0);          // Enable overflow interrupt
```

**ARM Port Requirements:**
- Use separate timer (TIM3 or TIM4)
- Configure for one-shot mode
- Lower priority than main stepper ISR

#### **Timer2 (8-bit) - Spindle PWM**
**Location:** `spindle_control.c:36-80`
**Purpose:** Variable speed spindle control via PWM

**Current Configuration:**
```c
TCCR2A = (1<<COM2A1)|(1<<WGM21)|(1<<WGM20); // Fast PWM, clear on match
TCCR2B = (1<<CS21);                          // Prescaler /8
OCR2A = 128;                                 // Duty cycle (0-255)
```

**PWM Specifications:**
- **Resolution:** 8-bit (256 levels)
- **Frequency:** ~7.8 kHz
- **Output:** Pin D11 (OC2A)

**ARM Port Requirements:**
- Use TIM3 or TIM4 with PWM output
- Can use 16-bit for better resolution (65536 levels)
- Configure alternate function for PWM output pin

---

### 3.3 Interrupt Service Routines - **CRITICAL**

GRBL relies heavily on interrupts for real-time control. All ISRs must be ported:

#### **ISR #1: Stepper Driver (Most Critical)**
```c
ISR(TIMER1_COMPA_vect)  // AVR
→ void TIM2_IRQHandler(void)  // ARM
```
**Execution Time:** ~20-30μs typical
**Frequency:** Up to 30kHz (33.3μs period)
**Function:** Generate step pulses, update position, plan next step
**Files:** `stepper.c:754`

#### **ISR #2: Step Pulse Reset**
```c
ISR(TIMER0_OVF_vect)  // AVR
→ void TIM3_IRQHandler(void)  // ARM
```
**Function:** Reset step pins after pulse width delay
**Files:** `stepper.c:869`

#### **ISR #3: Step Pulse Delay (Optional)**
```c
ISR(TIMER0_COMPA_vect)  // AVR
→ void TIM4_IRQHandler(void)  // ARM (if used)
```
**Function:** Delay before step pulse (for direction setup time)
**Files:** `stepper.c:884`

#### **ISR #4: Serial RX**
```c
ISR(USART_RX_vect)  // AVR
→ void USART1_IRQHandler(void)  // ARM
```
**Function:** Receive G-code commands via UART
**Files:** `serial.c:56`

#### **ISR #5: Serial TX**
```c
ISR(USART_UDRE_vect)  // AVR
→ void USART1_IRQHandler(void)  // ARM (combined with RX)
```
**Function:** Transmit status reports and responses
**Files:** `serial.c:98`

#### **ISR #6: Limit Switches**
```c
ISR(PCINT0_vect)  // AVR (Pin Change Interrupt)
→ void EXTI9_5_IRQHandler(void)  // ARM (External Interrupt)
```
**Function:** Emergency stop on limit switch trigger
**Files:** `limits.c:147`

#### **ISR #7: Control Pins**
```c
ISR(PCINT1_vect)  // AVR (Pin Change Interrupt)
→ void EXTI3_IRQHandler(void)  // ARM (External Interrupt)
```
**Function:** Handle reset, feed hold, cycle start, safety door
**Files:** `system.c:165`

**ARM NVIC Priority Recommendations:**
```
Priority 0 (Highest):  Stepper Driver (TIM2)
Priority 1:            Step Pulse Reset (TIM3)
Priority 2:            Limit Switches (EXTI)
Priority 3:            Control Pins (EXTI)
Priority 4:            Serial RX (USART1)
Priority 5:            Serial TX (USART1)
Priority 6 (Lowest):   Spindle PWM (if using interrupt)
```

---

### 3.4 Serial Communication (UART) - **CRITICAL**

**Current Implementation:**
- **Baud Rate:** 115200 (configurable)
- **Mode:** 8N1 (8 data bits, no parity, 1 stop bit)
- **Buffers:** Ring buffers in SRAM (RX: 128 bytes, TX: 64 bytes)
- **Interrupts:** RX full, TX empty

**AVR Configuration (`serial.c:36-54`):**
```c
UBRR0H = BAUD_SETTING_HIGH;
UBRR0L = BAUD_SETTING_LOW;
UCSR0A = 0;
UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0); // Enable RX/TX, RX interrupt
UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);           // 8-bit data
```

**ARM Port Requirements:**
1. Use USART1, USART2, or USART3
2. Configure for 115200 baud @ 72MHz system clock
3. Enable RX and TX interrupts
4. May consider DMA for higher performance (optional)

**STM32 Example:**
```c
// Enable USART1 clock
RCC->APB2ENR |= RCC_APB2ENR_USART1EN;

// Configure baud rate (115200 @ 72MHz)
USART1->BRR = 625;  // 72MHz / 115200 = 625

// Enable USART, TX, RX, RX interrupt
USART1->CR1 = USART_CR1_UE | USART_CR1_TE | USART_CR1_RE | USART_CR1_RXNEIE;

// Enable NVIC
NVIC_EnableIRQ(USART1_IRQn);
NVIC_SetPriority(USART1_IRQn, 4);

// ISR
void USART1_IRQHandler(void) {
    if (USART1->SR & USART_SR_RXNE) {
        uint8_t data = USART1->DR;
        // Add to RX buffer
    }
    if (USART1->SR & USART_SR_TXE) {
        // Send from TX buffer
    }
}
```

---

### 3.5 EEPROM Emulation - **CRITICAL CHALLENGE**

**Problem:** ARM Cortex-M (STM32) does not have dedicated EEPROM hardware.

**Current Usage (`eeprom.c`):**
- **Size:** 1 KB (512-1024 bytes used)
- **Purpose:** Store machine settings, tool offsets, coordinate systems
- **Operations:** Byte-level read/write with wear leveling
- **Write Frequency:** Low (only when settings change)

**AVR Implementation:**
```c
uint8_t eeprom_get_char(uint32_t addr) {
    EEAR = addr;
    EECR |= (1<<EERE);  // Start read
    return EEDR;
}

void eeprom_put_char(uint32_t addr, uint8_t new_value) {
    EEAR = addr;
    EEDR = new_value;
    EECR |= (1<<EEMPE); // Master write enable
    EECR |= (1<<EEPE);  // Start write
}
```

**ARM Port Solutions:**

#### **Option 1: Flash-Based Emulation (Recommended)**
- Use last 2-4 KB of flash memory
- Implement wear leveling algorithm
- STM32 HAL provides `EEPROM_Emulation` library
- **Pros:** No external hardware, large capacity
- **Cons:** Complex implementation, erase cycles limited (~10k)

**STM32 EEPROM Emulation:**
```c
// Use last 2 pages of flash (2KB on STM32F103)
#define EEPROM_START_ADDRESS  0x0800F800
#define EEPROM_SIZE           2048

// Read
uint8_t eeprom_get_char(uint32_t addr) {
    return *(__IO uint8_t*)(EEPROM_START_ADDRESS + addr);
}

// Write (requires page erase)
void eeprom_put_char(uint32_t addr, uint8_t value) {
    // 1. Unlock flash
    // 2. Erase page if needed
    // 3. Program byte
    // 4. Lock flash
    HAL_FLASH_Unlock();
    // ... complex flash operations ...
    HAL_FLASH_Lock();
}
```

#### **Option 2: External I2C EEPROM**
- Use 24LC256 (32KB) or similar
- Interface via I2C1 or I2C2
- **Pros:** Simple, unlimited writes, non-volatile
- **Cons:** Requires external component, slower access

#### **Option 3: Battery-Backed SRAM**
- Use STM32 backup SRAM domain (4KB on STM32F4)
- Requires backup battery or supercapacitor
- **Pros:** Fast, simple
- **Cons:** Requires backup power, limited size

**Recommendation:** Use STM32 flash emulation with HAL library for minimal hardware changes.

---

### 3.6 GPIO Operations

**Current Implementation:** Direct port manipulation for maximum speed

**AVR Method (`stepper.c:766-767`):**
```c
STEP_PORT = (STEP_PORT & ~STEP_MASK) | st.step_outbits;
DIRECTION_PORT = (DIRECTION_PORT & ~DIRECTION_MASK) | st.dir_outbits;
```

**Timing Requirements:**
- Step pulse width: 10μs minimum
- Direction setup time: 200ns minimum
- Must be executed within ISR (< 1μs overhead)

**ARM Port Options:**

#### **Option 1: HAL Library (Slower, ~500ns per call)**
```c
HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, GPIO_PIN_SET);
HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, GPIO_PIN_RESET);
```

#### **Option 2: Direct Register Access (Fast, ~50-100ns)**
```c
// Set pins (atomic)
GPIOA->BSRR = step_outbits;

// Clear pins (atomic)
GPIOA->BSRR = (step_outbits << 16);

// Set multiple pins with mask
GPIOA->ODR = (GPIOA->ODR & ~STEP_MASK) | step_outbits;
```

**Recommendation:** Use direct register access (Option 2) for stepper ISR, HAL for non-critical pins.

---

## 4. Portable Components (Minimal Changes)

These files require little to no modification:

### 4.1 Motion Planning Core
- **planner.c/h** (1200 lines): Trapezoidal motion planning, acceleration profiles
- **motion_control.c/h** (300 lines): Arc interpolation, line motion
- **nuts_bolts.c/h** (200 lines): Math utilities, bit manipulation

**Changes:** None (pure algorithms, no hardware dependencies)

### 4.2 G-Code Processing
- **gcode.c/h** (900 lines): G-code parser, state machine
- **protocol.c/h** (500 lines): Communication protocol
- **report.c/h** (400 lines): Status report generation

**Changes:** None (uses abstracted serial and EEPROM interfaces)

### 4.3 Application Logic
- **jog.c/h** (100 lines): Jogging mode
- **probe.c/h** (150 lines): Tool probing
- **print.c/h** (100 lines): Print utilities

**Changes:** Minimal (may need to update printf for ARM)

### 4.4 Configuration
- **defaults.h** (500 lines): Machine-specific defaults (Shapeoko, X-Carve, etc.)

**Changes:** None (machine-agnostic)

---

## 5. Build System Changes

### 5.1 Current Makefile (AVR)
```makefile
DEVICE     = atmega328p
CLOCK      = 16000000
PROGRAMMER = -c arduino -P /dev/ttyUSB0 -b 115200
OBJECTS    = main.o motion_control.o gcode.o ...
FUSES      = -U lfuse:w:0xff:m -U hfuse:w:0xd9:m -U efuse:w:0xff:m

COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

all: grbl.hex

grbl.hex: grbl.elf
	avr-objcopy -j .text -j .data -O ihex grbl.elf grbl.hex

grbl.elf: $(OBJECTS)
	avr-gcc -mmcu=$(DEVICE) -o grbl.elf $(OBJECTS) -lm

flash: grbl.hex
	avrdude $(PROGRAMMER) -p $(DEVICE) -U flash:w:grbl.hex:i
```

### 5.2 Required ARM Makefile

**New Requirements:**
- Compiler: `arm-none-eabi-gcc`
- Linker script: `STM32F103C8Tx_FLASH.ld`
- Startup code: `startup_stm32f103xb.s`
- MCU flags: `-mcpu=cortex-m3 -mthumb`
- Programmer: `st-flash`, `openocd`, or `dfu-util`

**Example ARM Makefile:**
```makefile
DEVICE     = STM32F103xB
CPU        = -mcpu=cortex-m3
FPU        =
FLOAT-ABI  =
MCU        = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# Linker script
LDSCRIPT = STM32F103C8Tx_FLASH.ld

# C sources
C_SOURCES = main.c system_stm32f1xx.c motion_control.c gcode.c ...

# ASM sources
ASM_SOURCES = startup_stm32f103xb.s

# C defines
C_DEFS = -DSTM32F103xB -DUSE_HAL_DRIVER

# C includes
C_INCLUDES = -Iinc -IDrivers/STM32F1xx_HAL_Driver/Inc ...

# Compile flags
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) -Os -Wall -fdata-sections -ffunction-sections

# Link flags
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) -Wl,--gc-sections -lm

# Compiler
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc -x assembler-with-cpp
CP = arm-none-eabi-objcopy
SZ = arm-none-eabi-size

# Build target
all: grbl.elf grbl.hex grbl.bin

grbl.elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

grbl.hex: grbl.elf
	$(CP) -O ihex $< $@

grbl.bin: grbl.elf
	$(CP) -O binary -S $< $@

# Flash via ST-Link
flash: grbl.bin
	st-flash write grbl.bin 0x8000000

# Flash via OpenOCD
flash-ocd: grbl.hex
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	        -c "program grbl.hex verify reset exit"
```

---

## 6. Performance Comparison

| Feature | AVR ATmega328p | STM32F103 (ARM) | Improvement |
|---------|----------------|-----------------|-------------|
| **CPU Speed** | 16 MHz | 72 MHz | **4.5x faster** |
| **Architecture** | 8-bit RISC | 32-bit RISC | **4x word size** |
| **Flash** | 32 KB | 64-128 KB | **2-4x more** |
| **SRAM** | 2 KB | 20 KB | **10x more** |
| **Timers** | 3x (8/16-bit) | 7x (16/32-bit) | **More & better** |
| **Timer Resolution** | 62.5 ns @ 16MHz | 13.9 ns @ 72MHz | **4.5x finer** |
| **Max Step Rate** | ~30 kHz | 100+ kHz | **3x+ faster** |
| **Interrupt Latency** | ~5-10 μs | ~1-2 μs | **5x faster** |
| **DMA Channels** | 0 | 7 | **New capability** |
| **ADC** | 10-bit, 6 ch | 12-bit, 10 ch | **Better resolution** |
| **Cost** | $2-3 | $2-4 | **Similar** |

**Key Advantages of ARM Port:**
1. **Higher Step Rates:** 3-4x improvement enables faster machining
2. **Larger Buffers:** 10x more RAM allows deeper motion planning look-ahead
3. **Future Expansion:** Extra GPIO, timers, ADCs for advanced features
4. **Better Real-Time:** Lower interrupt latency improves response time
5. **More Axes:** Extra resources support 4-6 axis machines

---

## 7. Recommended ARM Target MCUs

### 7.1 STM32F103C8T6 (Blue Pill) - **RECOMMENDED STARTER**
```
Core:       ARM Cortex-M3 @ 72 MHz
Flash:      64 KB (128 KB on some)
SRAM:       20 KB
Timers:     7x (4x 16-bit, 2x 16-bit basic, 1x watchdog)
GPIO:       37 pins
USART:      3x
Price:      $2-3
Ecosystem:  Massive community support, cheap dev boards
```
**Why:** Best price/performance, huge community, easy to obtain, Arduino IDE support

### 7.2 STM32F401CCU6 (Black Pill) - **PERFORMANCE UPGRADE**
```
Core:       ARM Cortex-M4F @ 84 MHz (with FPU)
Flash:      256 KB
SRAM:       64 KB
Timers:     11x (mostly 16/32-bit)
GPIO:       36 pins
USB:        Full-speed device
Price:      $4-5
```
**Why:** Floating-point unit for advanced kinematics, more resources, USB native

### 7.3 STM32F407VET6 (High Performance)
```
Core:       ARM Cortex-M4F @ 168 MHz (with FPU + DSP)
Flash:      512 KB
SRAM:       192 KB
Timers:     17x (advanced)
GPIO:       82 pins
Ethernet:   Yes
Price:      $8-12
```
**Why:** Maximum performance, 6+ axis capability, Ethernet connectivity

### 7.4 STM32G0B1 (Modern Low-Cost)
```
Core:       ARM Cortex-M0+ @ 64 MHz
Flash:      128-512 KB
SRAM:       36-144 KB
Timers:     11x
GPIO:       Up to 59 pins
Price:      $2-4
```
**Why:** Modern architecture, low power, good availability

---

## 8. Port Implementation Strategy

### Phase 1: Hardware Abstraction Layer (HAL) - **2-3 weeks**

**Goal:** Create ARM-specific hardware interface

**Tasks:**
1. Create `cpu_map_stm32f103.h` with GPIO pin definitions
2. Create `hal_stm32.c/h` with hardware abstraction functions:
   - `hal_gpio_init()` - Initialize all GPIO pins
   - `hal_timer_init()` - Configure timers
   - `hal_uart_init()` - Setup UART
   - `hal_eeprom_init()` - Setup flash-based EEPROM
3. Create new Makefile for ARM toolchain
4. Add STM32 HAL library or CMSIS to project
5. Create linker script and startup code

**Deliverables:**
- Compiling ARM binary (even if non-functional)
- Basic GPIO toggle test working
- Serial "Hello World" working

---

### Phase 2: Core Subsystem Porting - **4-6 weeks**

**Goal:** Port critical real-time components one-by-one

#### **Step 2.1: Serial Communication**
- Port `serial.c` UART initialization and ISRs
- Test bidirectional communication
- Verify ring buffer integrity
- Test at 115200 baud with G-code streaming

**Validation:**
```
Send: $$ (view settings)
Expect: [EEPROM settings list]
```

#### **Step 2.2: EEPROM Emulation**
- Implement flash-based EEPROM or use STM32 HAL library
- Port `eeprom.c` read/write functions
- Test settings storage and retrieval
- Verify persistence across resets

**Validation:**
```
Send: $100=250.0 (set X steps/mm)
Send: $$ (verify saved)
Reset
Send: $$ (verify persisted)
```

#### **Step 2.3: GPIO Control**
- Port `coolant_control.c` (simple GPIO outputs)
- Port `spindle_control.c` (GPIO + PWM)
- Test manual pin control

**Validation:**
```
Send: M3 S12000 (spindle CW at 12000 RPM)
Measure: PWM output on spindle pin
Send: M8 (flood coolant on)
Measure: Coolant pin HIGH
```

#### **Step 2.4: GPIO Input**
- Port `system.c` control pin interrupts (EXTI)
- Port `limits.c` limit switch interrupts (EXTI)
- Port `probe.c` probe pin reading
- Test interrupt triggering and debouncing

**Validation:**
```
Trigger: Pull reset pin LOW
Expect: System enters reset state
Trigger: Pull limit switch LOW
Expect: Alarm state, position lost
```

#### **Step 2.5: Stepper System (Most Critical)**
- Port `stepper.c` Timer1 ISR
- Implement step pulse generation
- Implement direction control
- Test at various step rates (100 Hz to 30 kHz)

**Validation:**
```
Send: G0 X10 F1000 (rapid move 10mm)
Measure: 2000 step pulses @ 10μs width (for 200 steps/mm)
Measure: Direction pin state
```

---

### Phase 3: Integration & Testing - **3-4 weeks**

**Goal:** Full system integration and validation

#### **Step 3.1: Motion Integration**
- Enable motion planner (`planner.c` - should work as-is)
- Test coordinated motion (XYZ simultaneous)
- Verify acceleration profiles
- Test arc motion (G2/G3)

**Validation:**
```
Send: G1 X10 Y10 Z5 F500
Expect: Smooth coordinated motion, trapezoidal velocity profile
Send: G2 X10 Y10 I5 J0 (clockwise arc)
Expect: Smooth circular motion
```

#### **Step 3.2: Protocol Integration**
- Test full G-code streaming
- Verify real-time command processing ($, !, ~, ?)
- Test status reporting
- Stress test with large G-code files

**Validation:**
```
Stream: 1000-line G-code file
Expect: No dropped characters, smooth motion
Send: ? (status query during motion)
Expect: Real-time position update without motion stutter
Send: ! (feed hold)
Expect: Smooth deceleration to stop
```

#### **Step 3.3: Advanced Features**
- Test homing cycle ($H)
- Test work coordinate systems (G54-G59)
- Test tool length offsets (G43)
- Test probing cycle (G38.2)

**Validation:**
```
Send: $H
Expect: All axes home to limit switches with backoff
Send: G54 (select work coordinate)
Send: G10 L20 P1 X0 Y0 Z0 (set work zero)
Verify: Coordinate system offset applied
```

#### **Step 3.4: Stress Testing**
- Run 8+ hour continuous machining simulation
- Test at maximum step rates (30+ kHz)
- Monitor for memory leaks
- Verify thermal stability

**Validation:**
```
Load: Complex 3D toolpath (10,000+ lines)
Run: Continuous loop for 8 hours
Monitor: No crashes, no position errors, no overheating
```

---

### Phase 4: Optimization & Documentation - **2-3 weeks**

**Goal:** Performance tuning and production readiness

**Tasks:**
1. Optimize interrupt latencies
2. Tune motion planner for ARM performance
3. Implement ARM-specific optimizations (DMA for serial?)
4. Create ARM-specific documentation
5. Create Bill of Materials (BOM)
6. Design reference PCB (optional)
7. Write user migration guide (AVR → ARM)

**Deliverables:**
- Production-ready ARM GRBL firmware
- Flash programming guide
- Schematic and pinout diagram
- Performance benchmarks
- Migration guide for existing users

---

## 9. Technical Challenges & Solutions

### Challenge 1: Timer Configuration Complexity
**Problem:** ARM timers are more complex than AVR with many configuration registers
**Solution:** Use STM32CubeMX to generate timer initialization code, then hand-tune

### Challenge 2: EEPROM Emulation Complexity
**Problem:** Flash erase/write is slow and complex (requires page erase)
**Solution:** Use ST's proven EEPROM emulation library or implement write coalescing

### Challenge 3: Interrupt Priority Management
**Problem:** ARM has 16 priority levels vs AVR's simple global enable/disable
**Solution:** Use NVIC configurator, disable specific interrupts using `NVIC_DisableIRQ()` instead of `cli()`

### Challenge 4: 3.3V Logic Levels
**Problem:** ARM uses 3.3V, many stepper drivers expect 5V signals
**Solution:** Use 5V-tolerant pins or level shifters (74HCT245) for outputs

### Challenge 5: Debugging Without JTAG
**Problem:** Need to debug real-time system without breaking timing
**Solution:** Use ARM SWD interface with ST-Link debugger, implement debug logging via spare UART

### Challenge 6: Increased Code Size
**Problem:** ARM code may be larger due to 32-bit instructions
**Solution:** Use `-Os` optimization, link-time optimization (`-flto`), not a real issue with 64-128KB flash

### Challenge 7: Toolchain Setup
**Problem:** ARM toolchain more complex than AVR
**Solution:** Use pre-built `arm-none-eabi-gcc` packages, STM32CubeIDE, or PlatformIO

---

## 10. Testing & Validation Plan

### 10.1 Unit Tests (Per Subsystem)

**Serial:**
- [ ] Transmit single byte
- [ ] Receive single byte
- [ ] Transmit 1KB buffer
- [ ] Receive 1KB buffer at 115200 baud
- [ ] Test buffer overflow handling

**EEPROM:**
- [ ] Write single byte
- [ ] Read single byte
- [ ] Write 1KB data
- [ ] Read 1KB data
- [ ] Verify persistence after reset
- [ ] Test wear leveling (1000 write cycles)

**GPIO Output:**
- [ ] Toggle single pin
- [ ] Set multiple pins atomically
- [ ] Measure output timing (oscilloscope)
- [ ] Verify 10μs step pulse width

**GPIO Input:**
- [ ] Read single pin
- [ ] Trigger external interrupt
- [ ] Verify debouncing
- [ ] Test interrupt latency

**Timers:**
- [ ] Generate 1 kHz interrupt
- [ ] Generate 30 kHz interrupt
- [ ] Verify timing accuracy with oscilloscope
- [ ] Measure interrupt jitter (should be < 1μs)

**PWM:**
- [ ] Generate 50% duty cycle
- [ ] Sweep 0-100% duty cycle
- [ ] Verify frequency (should be 7-10 kHz)

---

### 10.2 Integration Tests

**Motion System:**
- [ ] Single axis motion (X only)
- [ ] Dual axis motion (XY diagonal)
- [ ] Triple axis motion (XYZ)
- [ ] Arc motion (G2/G3)
- [ ] Acceleration/deceleration profiles
- [ ] Jerk-free motion at joints

**Homing:**
- [ ] Single axis homing
- [ ] All axes homing sequence
- [ ] Homing with dual endstops (if supported)
- [ ] Verify homing accuracy (< 0.01mm)

**Probing:**
- [ ] G38.2 probe toward
- [ ] G38.3 probe toward (no error)
- [ ] G38.4 probe away
- [ ] Tool length offset measurement

**Real-Time Commands:**
- [ ] Feed hold (!) during motion
- [ ] Cycle start (~) resume
- [ ] Soft reset (Ctrl-X)
- [ ] Status query (?) during motion
- [ ] Feed override (100-200%)
- [ ] Rapid override (25-100%)
- [ ] Spindle override (100-200%)

---

### 10.3 Stress Tests

**High Speed:**
- [ ] 30 kHz step rate continuous (10 minutes)
- [ ] Rapid direction changes (high jerk)
- [ ] Maximum acceleration moves

**Long Duration:**
- [ ] 8-hour continuous operation
- [ ] 24-hour continuous operation
- [ ] Monitor temperature, no thermal throttling

**Large Files:**
- [ ] Stream 100,000-line G-code file
- [ ] No buffer overruns
- [ ] No motion stuttering

**Boundary Conditions:**
- [ ] Trigger all limit switches
- [ ] Test hard reset during motion
- [ ] Test emergency stop
- [ ] Recover from alarm states

---

### 10.4 Performance Benchmarks

| Test | AVR Target | ARM Target | Improvement |
|------|------------|------------|-------------|
| **Max sustained step rate** | 30 kHz | 100+ kHz | 3.3x |
| **Lookahead buffer depth** | 18 blocks | 128+ blocks | 7x |
| **Interrupt latency** | 5-10 μs | 1-2 μs | 5x |
| **Arc resolution** | 0.002mm | 0.001mm | 2x |
| **Status report rate** | 5 Hz | 10 Hz | 2x |
| **Homing accuracy** | ±0.01mm | ±0.005mm | 2x |

---

## 11. Bill of Materials (BOM)

### 11.1 Minimal Development Setup

| Item | Description | Qty | Price | Link |
|------|-------------|-----|-------|------|
| **STM32F103C8T6** | Blue Pill dev board | 1 | $2-3 | AliExpress/eBay |
| **ST-Link V2** | USB JTAG/SWD programmer | 1 | $2-3 | AliExpress/eBay |
| **USB-Serial** | CP2102/CH340G adapter | 1 | $1-2 | AliExpress/eBay |
| **Breadboard** | Prototyping board | 1 | $2 | Local |
| **Jumper wires** | Male-male, male-female | 20 | $2 | Local |
| **LED + Resistor** | Testing GPIO (330Ω) | 5 | $1 | Local |
| **Push buttons** | Testing interrupts | 5 | $1 | Local |
| **Logic analyzer** | Verify timing (optional) | 1 | $10 | Amazon |
| | | **Total** | **$13-24** | |

---

### 11.2 Full CNC Controller (Production)

| Item | Description | Qty | Price | Notes |
|------|-------------|-----|-------|-------|
| **STM32F103C8T6** | Blue Pill or custom PCB | 1 | $2-3 | Main MCU |
| **74HCT245** | Octal bus transceiver | 2 | $0.50 | 3.3V → 5V level shift |
| **DRV8825/A4988** | Stepper motor drivers | 3 | $3-5 ea | External drivers |
| **LM7805** | 5V voltage regulator | 1 | $0.50 | Power supply |
| **LM1117-3.3** | 3.3V voltage regulator | 1 | $0.30 | MCU power |
| **24LC256** | I2C EEPROM (optional) | 1 | $0.50 | If not using flash |
| **Capacitors** | 100nF, 10μF decoupling | 10 | $1 | Power filtering |
| **Resistors** | 10kΩ pull-ups/downs | 10 | $0.50 | Input protection |
| **Terminal blocks** | Screw terminals | 10 | $2 | Connections |
| **Enclosure** | Plastic/metal case | 1 | $5-10 | Protection |
| **PCB** | Custom or protoboard | 1 | $5-20 | Depends on design |
| | | **Total** | **$30-55** | |

---

## 12. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Timer interrupt too slow** | Low | High | ARM @ 72MHz is 4.5x faster, proven in other projects |
| **EEPROM emulation unstable** | Medium | Medium | Use ST's proven library, add extensive testing |
| **GPIO too slow for step pulses** | Low | High | Direct register access is fast enough (tested) |
| **Interrupt priority conflicts** | Medium | Medium | Careful NVIC configuration, extensive testing |
| **Toolchain/build issues** | Medium | Low | Well-documented ARM toolchain, large community |
| **Hardware compatibility** | Medium | Medium | Design for 5V tolerance or use level shifters |
| **Memory/stack overflow** | Low | Medium | ARM has 10x more RAM, use stack canaries |
| **Flash wear from EEPROM** | Low | Low | Settings change rarely, 10k cycles minimum |

---

## 13. Success Criteria

The ARM port will be considered successful when:

### Functional Requirements:
- [ ] All AVR GRBL features work identically on ARM
- [ ] Passes all GRBL test suite cases
- [ ] G-code compatibility: 100% (same parser)
- [ ] Real-time performance: ≥ AVR (30+ kHz step rate)
- [ ] Settings persistence across power cycles
- [ ] Homing, probing, jogging all functional

### Performance Requirements:
- [ ] Step rate: ≥ 30 kHz sustained (match AVR minimum)
- [ ] Interrupt latency: ≤ 5 μs (better than AVR)
- [ ] Motion smoothness: No visible stuttering
- [ ] Arc resolution: ≤ 0.002mm (match AVR)

### Quality Requirements:
- [ ] 8+ hour stress test without crashes
- [ ] No memory leaks (heap stable)
- [ ] Clean compilation (zero warnings)
- [ ] Code documentation complete
- [ ] User migration guide written

### Compatibility Requirements:
- [ ] Works with existing stepper drivers (DRV8825, A4988, etc.)
- [ ] Uses same G-code syntax (no relearning for users)
- [ ] Settings format compatible (can migrate from AVR)

---

## 14. Future Enhancements (Post-Port)

Once the base ARM port is stable, these enhancements become possible:

### 14.1 Near-Term (Leverage ARM Capabilities)
1. **USB Native:** Direct USB connection without UART adapter
2. **SD Card:** G-code storage on microSD (no PC needed for job runs)
3. **LCD Display:** Real-time position/status on TFT screen
4. **Ethernet:** Network control and file transfer
5. **More Axes:** Support 4-6 axis machines (XYZA, XYZBC)
6. **Higher Resolution:** 16-bit spindle PWM (vs 8-bit on AVR)

### 14.2 Medium-Term (Advanced Features)
1. **Automatic Tool Changer (ATC):** Support tool carousel with tool offset database
2. **Rotary Axis (4th axis):** Full support for A/B/C axes with wrapping
3. **Advanced Kinematics:** SCARA, delta robot, CoreXY support
4. **PID Closed-Loop:** Spindle speed or servo position control
5. **DRO Support:** Digital readout for manual mode
6. **WiFi Module:** Wireless control via ESP8266/ESP32 co-processor

### 14.3 Long-Term (Research)
1. **AI-Based Feed Optimization:** Adjust feed rate based on tool load
2. **Predictive Maintenance:** Monitor driver temperature, vibration
3. **CAM Integration:** Direct toolpath generation on-device
4. **Cloud Connectivity:** Job queue, remote monitoring
5. **Computer Vision:** Camera-based tool detection and alignment

---

## 15. Conclusion

### Summary
The ARM port of GRBL is **technically feasible** and offers **significant benefits** over the original AVR implementation. The core algorithmic components (70% of code) are portable, while the hardware-dependent layer (30%) requires complete rewriting.

### Effort Estimate
- **Total Time:** 12-16 weeks (3-4 months)
- **Complexity:** Medium (requires embedded systems expertise)
- **Team Size:** 1-2 developers
- **Skills Required:** Embedded C, ARM Cortex-M, hardware debugging, CNC knowledge

### Key Benefits
1. **Performance:** 4.5x faster CPU, 10x more RAM
2. **Capacity:** 100+ kHz step rate, deeper motion planning
3. **Expandability:** Room for advanced features (USB, SD, LCD, WiFi)
4. **Cost:** Similar price ($2-4 for MCU)
5. **Availability:** Easier to source than ATmega328p in 2025

### Recommendation
**Proceed with ARM port** using STM32F103C8T6 (Blue Pill) as the initial target. This MCU offers:
- Excellent price/performance
- Massive community support
- Proven in similar CNC applications (Smoothieware, Marlin 2.0)
- Clear upgrade path to higher-performance STM32 variants

The port will modernize GRBL, ensure long-term viability, and enable next-generation CNC features while maintaining 100% G-code compatibility with existing workflows.

---

## 16. References & Resources

### 16.1 GRBL Documentation
- **Official GRBL Wiki:** https://github.com/gnea/grbl/wiki
- **G-Code Reference:** https://github.com/gnea/grbl/wiki/Grbl-v1.1-Commands
- **Configuration Guide:** https://github.com/gnea/grbl/wiki/Grbl-v1.1-Configuration

### 16.2 ARM/STM32 Resources
- **STM32F1 Reference Manual:** RM0008 (1100+ pages)
- **STM32F103 Datasheet:** DS5319
- **STM32CubeMX:** Free configuration tool from ST
- **STM32 HAL Library:** Hardware Abstraction Layer from ST
- **ARM Cortex-M3 Guide:** ARM DUI 0552A

### 16.3 Similar Projects (ARM CNC Controllers)
- **Smoothieware:** ARM-based CNC/3D printer (Cortex-M3)
- **Marlin 2.0:** 3D printer firmware, supports STM32
- **grblHAL:** GRBL port to various ARM platforms (recently developed)
- **LinuxCNC:** PC-based CNC control (not embedded)

### 16.4 Toolchain
- **GNU ARM Embedded:** https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm
- **STM32CubeIDE:** https://www.st.com/en/development-tools/stm32cubeide.html
- **PlatformIO:** https://platformio.org/ (supports STM32)
- **OpenOCD:** Open On-Chip Debugger for flashing/debugging

### 16.5 Hardware
- **Blue Pill:** https://stm32-base.org/boards/STM32F103C8T6-Blue-Pill
- **ST-Link V2:** Official programmer/debugger
- **Logic Analyzer:** Saleae Logic or cheap 8-channel clones

---

## Appendix A: File-by-File Port Priority

| Priority | File | Lines | Effort | Notes |
|----------|------|-------|--------|-------|
| **1 (Critical)** | cpu_map.h | 300 | High | Complete rewrite, all GPIO definitions |
| **1 (Critical)** | stepper.c | 800 | High | Timer1 ISR, most complex |
| **1 (Critical)** | serial.c | 200 | Medium | UART ISRs, ring buffers |
| **1 (Critical)** | eeprom.c | 100 | High | Flash emulation complexity |
| **2 (Important)** | system.c | 400 | Medium | EXTI interrupts, control pins |
| **2 (Important)** | limits.c | 300 | Medium | EXTI interrupts, limit switches |
| **2 (Important)** | spindle_control.c | 150 | Low | PWM timer setup |
| **3 (Moderate)** | coolant_control.c | 80 | Low | Simple GPIO |
| **3 (Moderate)** | probe.c | 150 | Low | GPIO read |
| **3 (Moderate)** | grbl.h | 50 | Low | Replace AVR includes |
| **3 (Moderate)** | config.h | 100 | Low | Update F_CPU, buffer sizes |
| **4 (Low/None)** | planner.c | 1200 | None | Portable (pure algorithm) |
| **4 (Low/None)** | gcode.c | 900 | None | Portable (string processing) |
| **4 (Low/None)** | motion_control.c | 300 | None | Portable (math) |
| **4 (Low/None)** | protocol.c | 500 | None | Portable (uses abstraction) |
| **4 (Low/None)** | report.c | 400 | None | Portable |
| **4 (Low/None)** | settings.c | 400 | None | Portable (uses EEPROM API) |
| **4 (Low/None)** | jog.c | 100 | None | Portable |
| **4 (Low/None)** | print.c | 100 | None | Portable |
| **4 (Low/None)** | nuts_bolts.c | 200 | None | Portable |
| **4 (Low/None)** | defaults.h | 500 | None | Portable |
| **N/A** | Makefile | 100 | High | Complete rewrite for ARM |

---

## Appendix B: Pin Mapping Example (STM32F103 Blue Pill)

```
STM32F103C8T6 Blue Pill Pin Assignment for GRBL

Step Pins (Output, Fast GPIO):
  X_STEP   → PA0  (GPIOA, Pin 0)
  Y_STEP   → PA1  (GPIOA, Pin 1)
  Z_STEP   → PA2  (GPIOA, Pin 2)

Direction Pins (Output, Fast GPIO):
  X_DIR    → PA3  (GPIOA, Pin 3)
  Y_DIR    → PA4  (GPIOA, Pin 4)
  Z_DIR    → PA5  (GPIOA, Pin 5)

Stepper Enable (Output, Active Low):
  ENABLE   → PA6  (GPIOA, Pin 6)

Limit Switches (Input, Pull-up, EXTI):
  X_LIMIT  → PB0  (GPIOB, Pin 0, EXTI0)
  Y_LIMIT  → PB1  (GPIOB, Pin 1, EXTI1)
  Z_LIMIT  → PB10 (GPIOB, Pin 10, EXTI10)

Control Pins (Input, Pull-up, EXTI):
  RESET    → PB3  (GPIOB, Pin 3, EXTI3)
  FEED_HOLD → PB4 (GPIOB, Pin 4, EXTI4)
  CYCLE_START → PB5 (GPIOB, Pin 5, EXTI5)
  SAFETY_DOOR → PB6 (GPIOB, Pin 6, EXTI6)

Spindle Control (Output):
  SPINDLE_PWM → PB7  (GPIOB, Pin 7, TIM4_CH2 PWM)
  SPINDLE_ENABLE → PB8 (GPIOB, Pin 8)
  SPINDLE_DIR → PB9 (GPIOB, Pin 9)

Coolant Control (Output):
  COOLANT_FLOOD → PC13 (GPIOC, Pin 13, onboard LED)
  COOLANT_MIST → PC14 (GPIOC, Pin 14)

Probe (Input, No Pull):
  PROBE    → PC15 (GPIOC, Pin 15)

UART (Serial Communication):
  TX       → PA9  (USART1_TX)
  RX       → PA10 (USART1_RX)

Programming/Debug (ST-Link):
  SWDIO    → PA13 (Serial Wire Debug I/O)
  SWCLK    → PA14 (Serial Wire Clock)

Power:
  VCC      → 3.3V (regulated onboard from 5V USB or Vin)
  GND      → GND (multiple pins)
  5V       → 5V input/output
```

**Notes:**
- All GPIO configured with maximum speed (50 MHz)
- Step/Dir pins use direct register access for speed
- Limit switches use hardware debouncing (RC filter) + software
- EXTI lines grouped to minimize ISR count
- Onboard LED (PC13) can be used for status indication

---

**END OF REPORT**

*Generated: 2025-11-18*
*Version: 1.0*
*Author: ARM Port Analysis Team*
