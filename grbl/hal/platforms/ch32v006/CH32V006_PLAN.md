# CH32V006 Platform Implementation Plan

**Platform**: CH32V006 (RISC-V RV32EC)
**Vendor**: WCH (Nanjing Qinheng Microelectronics)
**Status**: 🚧 Planning Phase
**Priority**: HIGH (First RISC-V port)

---

## 1. HARDWARE OVERVIEW

### Target MCU: CH32V003F4P6
- **Architecture**: RISC-V RV32EC (Embedded, Compressed instructions)
- **Core**: QingKe V2A (WCH proprietary RISC-V)
- **Frequency**: 48MHz (internal oscillator, ±1%)
- **Flash**: 16KB
- **RAM**: 2KB SRAM
- **Package**: TSSOP-20, SOP-16, or SOP-8
- **Voltage**: 3.3V or 5V operation
- **Cost**: ~$0.10 USD in volume (ultra-low-cost!)

### Key Features:
- ✅ 1x USART (for GCode input)
- ✅ 1x SPI
- ✅ 1x I2C
- ✅ 2x 16-bit timers (TIM1, TIM2) for stepper timing
- ✅ 1x watchdog timer
- ✅ 10-bit ADC (8 channels)
- ✅ 18 GPIO pins (TSSOP-20 package)
- ❌ No hardware FPU (software emulation)
- ❌ No DMA (must use interrupts)

### Development Board:
- **Recommended**: CH32V003F4P6-R0 EVT board
- **Programmer**: WCH-LinkE (USB debugging/programming)
- **Bootloader**: Built-in UART/USB bootloader

---

## 2. GRBL FEASIBILITY ANALYSIS

### Memory Constraints:
- **Flash**: 16KB total
  - GRBL core: ~20KB (original AVR)
  - **CHALLENGE**: Must fit in 16KB!
  - **Solution**: Aggressive LTO optimization, feature reduction
  - **Estimated**: 14-15KB with `-Os -flto` and minimal features

- **RAM**: 2KB total
  - GRBL core: ~1.5KB (buffers, state)
  - Stack: ~512 bytes
  - **Remaining**: ~512 bytes
  - **CHALLENGE**: Very tight memory budget
  - **Solution**: Reduce buffer sizes, optimize data structures

### Feature Set (Minimal):
To fit in 16KB Flash and 2KB RAM, implement minimal GRBL feature set:
- ✅ 3-axis stepper control (X, Y, Z)
- ✅ GCode parsing (G0, G1, G2, G3, basic M-codes)
- ✅ Linear and arc motion
- ✅ Feed rate control
- ✅ Limit switches (3 axes)
- ✅ Spindle control (PWM)
- ✅ Coolant control (2 outputs)
- ❌ Probing (can add later if space permits)
- ❌ SD card support (no space)
- ❌ Advanced features (tool change, M6)

**Verdict**: ✅ Feasible with careful optimization

---

## 3. TOOLCHAIN SETUP

### Required Tools:
```bash
# RISC-V GCC toolchain (8.2.0 or newer)
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
tar -xzf xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
export PATH=$PATH:$PWD/xpack-riscv-none-elf-gcc-13.2.0-2/bin

# WCH OpenOCD (for debugging via WCH-LinkE)
git clone https://github.com/kprasadvnsi/riscv-openocd-wch.git
cd riscv-openocd-wch
./bootstrap
./configure --prefix=/usr/local
make && sudo make install

# WCH-LinkE utility (optional, for easy flashing)
# Download from WCH website: https://www.wch.cn/downloads/WCH-LinkUtility_ZIP.html
```

### Compiler Flags:
```makefile
# RISC-V specific flags
CPU = rv32ec_zicsr
ARCH = -march=$(CPU) -mabi=ilp32e
CFLAGS = $(ARCH) -msmall-data-limit=8 -mno-save-restore

# Optimization (critical for 16KB limit!)
CFLAGS += -Os -flto -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections -flto

# No FPU, use soft-float
CFLAGS += -msoft-float
```

---

## 4. REGISTER DEFINITIONS (regs.h)

The CH32V006 uses WCH-specific register layout (not standard CMSIS):

```c
// Base addresses
#define FLASH_BASE   0x00000000  // Flash memory
#define SRAM_BASE    0x20000000  // SRAM
#define PERIPH_BASE  0x40000000  // Peripherals

// GPIO ports
#define GPIOA_BASE   (PERIPH_BASE + 0x10800)
#define GPIOC_BASE   (PERIPH_BASE + 0x11000)
#define GPIOD_BASE   (PERIPH_BASE + 0x11400)

// GPIO registers (different from STM32!)
typedef struct {
  volatile uint32_t CFGLR;   // Port config low register
  volatile uint32_t CFGHR;   // Port config high register (if available)
  volatile uint32_t INDR;    // Port input data register
  volatile uint32_t OUTDR;   // Port output data register
  volatile uint32_t BSHR;    // Port bit set/reset register
  volatile uint32_t BCR;     // Port bit clear register
  volatile uint32_t LCKR;    // Port config lock register
} GPIO_TypeDef;

// RCC (Reset and Clock Control)
#define RCC_BASE     (PERIPH_BASE + 0x21000)

typedef struct {
  volatile uint32_t CTLR;    // Clock control register
  volatile uint32_t CFGR0;   // Clock configuration register
  volatile uint32_t INTR;    // Clock interrupt register
  volatile uint32_t APB2PRSTR; // APB2 peripheral reset register
  volatile uint32_t APB1PRSTR; // APB1 peripheral reset register
  volatile uint32_t AHBPCENR;  // AHB peripheral clock enable register
  volatile uint32_t APB2PCENR; // APB2 peripheral clock enable register
  volatile uint32_t APB1PCENR; // APB1 peripheral clock enable register
} RCC_TypeDef;

// TIM (Timers)
#define TIM1_BASE    (PERIPH_BASE + 0x12C00)
#define TIM2_BASE    (PERIPH_BASE + 0x00000)

typedef struct {
  volatile uint16_t CTLR1;   // Control register 1
  uint16_t RESERVED0;
  volatile uint16_t CTLR2;   // Control register 2
  uint16_t RESERVED1;
  volatile uint16_t SMCFGR;  // Slave mode control register
  uint16_t RESERVED2;
  volatile uint16_t DMAINTENR; // DMA/Interrupt enable register
  uint16_t RESERVED3;
  volatile uint16_t INTFR;   // Interrupt flag register
  uint16_t RESERVED4;
  volatile uint16_t SWEVGR;  // Software event generation register
  uint16_t RESERVED5;
  volatile uint16_t CHCTLR1; // Capture/compare mode register 1
  uint16_t RESERVED6;
  volatile uint16_t CHCTLR2; // Capture/compare mode register 2
  uint16_t RESERVED7;
  volatile uint16_t CCER;    // Capture/compare enable register
  uint16_t RESERVED8;
  volatile uint16_t CNT;     // Counter
  uint16_t RESERVED9;
  volatile uint16_t PSC;     // Prescaler
  uint16_t RESERVED10;
  volatile uint16_t ATRLR;   // Auto-reload register
  uint16_t RESERVED11;
} TIM_TypeDef;

// USART
#define USART1_BASE  (PERIPH_BASE + 0x13800)

typedef struct {
  volatile uint16_t STATR;   // Status register
  uint16_t RESERVED0;
  volatile uint16_t DATAR;   // Data register
  uint16_t RESERVED1;
  volatile uint16_t BRR;     // Baud rate register
  uint16_t RESERVED2;
  volatile uint16_t CTLR1;   // Control register 1
  uint16_t RESERVED3;
  volatile uint16_t CTLR2;   // Control register 2
  uint16_t RESERVED4;
  volatile uint16_t CTLR3;   // Control register 3
  uint16_t RESERVED5;
  volatile uint16_t GPR;     // Guard time and prescaler register
  uint16_t RESERVED6;
} USART_TypeDef;

// RISC-V interrupt controller (PFIC - Programmable Fast Interrupt Controller)
#define PFIC_BASE    0xE000E000

typedef struct {
  volatile uint32_t ISR[8];      // Interrupt status registers
  volatile uint32_t IPR[8];      // Interrupt pending registers
  volatile uint32_t ITHRESDR;    // Interrupt threshold register
  volatile uint32_t CFGR;        // Configuration register
  volatile uint32_t GISR;        // Global interrupt status register
  volatile uint32_t VTFIDR;      // VTF interrupt ID register
  uint32_t RESERVED[3];
  volatile uint32_t VTFADDR[4];  // VTF interrupt addresses
  uint32_t RESERVED1[0x3EC];
  volatile uint32_t IENR[8];     // Interrupt enable registers
  volatile uint32_t IRER[8];     // Interrupt reset enable registers
  volatile uint32_t IPSR[8];     // Interrupt pending set registers
  volatile uint32_t IPRR[8];     // Interrupt pending reset registers
  volatile uint32_t IACTR[8];    // Interrupt active registers
  volatile uint32_t IPRIOR[64];  // Interrupt priority registers
  volatile uint32_t SCTLR;       // System control register
} PFIC_TypeDef;
```

---

## 5. STARTUP CODE (startup.c)

RISC-V startup is different from ARM:

```c
// Linker symbols
extern uint32_t _estack;
extern uint32_t _data_lma, _data_vma, _edata;
extern uint32_t _bss_start, _bss_end;

// Main function
extern int main(void);

// Reset handler
__attribute__((naked))
__attribute__((section(".init")))
void _start(void) {
  // Disable interrupts
  asm volatile ("csrci mstatus, 8");

  // Copy .data section
  uint32_t *src = &_data_lma;
  uint32_t *dst = &_data_vma;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // Zero .bss section
  dst = &_bss_start;
  while (dst < &_bss_end) {
    *dst++ = 0;
  }

  // Initialize stack pointer
  asm volatile ("la sp, _estack");

  // Enable global interrupts (MIE bit in mstatus)
  asm volatile ("csrsi mstatus, 8");

  // Call main
  main();

  // Infinite loop if main returns
  while (1);
}

// Default interrupt handler
void Default_Handler(void) {
  while (1);  // Trap
}

// RISC-V interrupt vector table
__attribute__((section(".vector")))
void (*const vector_table[])(void) = {
  0,                      // 0: Reserved
  0,                      // 1: Reserved
  NMI_Handler,            // 2: NMI
  HardFault_Handler,      // 3: Hard fault
  0,                      // 4-11: Reserved
  0, 0, 0, 0, 0, 0, 0, 0,
  SysTick_Handler,        // 12: SysTick (if available)
  0,                      // 13: Reserved
  SWI_Handler,            // 14: Software interrupt
  0,                      // 15: Reserved
  // CH32V003 peripheral interrupts
  WWDG_IRQHandler,        // 16: Window watchdog
  PVD_IRQHandler,         // 17: PVD through EXTI
  FLASH_IRQHandler,       // 18: Flash
  RCC_IRQHandler,         // 19: RCC
  EXTI7_0_IRQHandler,     // 20: EXTI Line 0-7
  AWU_IRQHandler,         // 21: Auto wake-up
  DMA1_Channel1_IRQHandler, // 22: DMA1 Channel 1
  DMA1_Channel2_IRQHandler, // 23: DMA1 Channel 2
  DMA1_Channel3_IRQHandler, // 24: DMA1 Channel 3
  DMA1_Channel4_IRQHandler, // 25: DMA1 Channel 4
  DMA1_Channel5_IRQHandler, // 26: DMA1 Channel 5
  DMA1_Channel6_IRQHandler, // 27: DMA1 Channel 6
  DMA1_Channel7_IRQHandler, // 28: DMA1 Channel 7
  ADC_IRQHandler,         // 29: ADC
  I2C1_EV_IRQHandler,     // 30: I2C1 Event
  I2C1_ER_IRQHandler,     // 31: I2C1 Error
  USART1_IRQHandler,      // 32: USART1 (SERIAL ISR)
  SPI1_IRQHandler,        // 33: SPI1
  TIM1_BRK_IRQHandler,    // 34: TIM1 Break
  TIM1_UP_IRQHandler,     // 35: TIM1 Update
  TIM1_TRG_COM_IRQHandler,// 36: TIM1 Trigger and Commutation
  TIM1_CC_IRQHandler,     // 37: TIM1 Capture Compare
  TIM2_IRQHandler,        // 38: TIM2 (STEPPER ISR)
};
```

---

## 6. CLOCK CONFIGURATION

CH32V006 uses internal 48MHz RC oscillator (no external crystal needed):

```c
void hal_clock_config(void) {
  // CH32V003 boots with internal 24MHz HSI
  // We need to switch to 48MHz by configuring PLL

  // 1. Enable HSI (should already be enabled)
  RCC->CTLR |= RCC_HSION;
  while (!(RCC->CTLR & RCC_HSIRDY));

  // 2. Configure flash latency (1 wait state for 48MHz)
  FLASH->ACTLR = FLASH_ACTLR_LATENCY_1;

  // 3. Configure PLL: HSI/2 * 12 = 24MHz/2 * 12 = 144MHz, then /3 = 48MHz
  // Actually, CH32V003 uses a simpler approach:
  // Set HCLK prescaler to get 48MHz
  RCC->CFGR0 = RCC_HPRE_DIV1;  // AHB prescaler = 1 (48MHz)

  // 4. Update SystemCoreClock variable
  SystemCoreClock = 48000000;
}
```

---

## 7. GPIO CONFIGURATION

```c
void hal_gpio_init(void) {
  // Enable GPIO clocks
  RCC->APB2PCENR |= RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOC | RCC_APB2Periph_GPIOD;

  // Configure stepper pins (PC0-5) as outputs
  // CH32V uses 4-bit config: [CNF1 CNF0 MODE1 MODE0]
  // 0b0011 = Push-pull output, 50MHz
  GPIOC->CFGLR = 0x33333333;  // PC0-7 all outputs

  // Configure limit switches (PD2, PD3, PD4) as inputs with pull-up
  // 0b1000 = Input with pull-up
  GPIOD->CFGLR |= (0x8 << 8) | (0x8 << 12) | (0x8 << 16);
  GPIOD->OUTDR |= (1 << 2) | (1 << 3) | (1 << 4);  // Enable pull-ups

  // Initialize outputs to safe state
  GPIOC->BSHR = (1 << 6) << 16;  // Disable steppers (PC6 = disable, active LOW)
}
```

---

## 8. TIMER CONFIGURATION (Stepper ISR)

```c
void hal_timer_init(void) {
  // Enable TIM2 clock
  RCC->APB1PCENR |= RCC_APB1Periph_TIM2;

  // Configure TIM2 for stepper timing
  // 48MHz / 1 = 48MHz timer clock
  TIM2->PSC = 0;  // No prescaler
  TIM2->ATRLR = 1000;  // Initial period (will be updated dynamically)

  // Enable update interrupt
  TIM2->DMAINTENR = TIM_UIE;

  // Enable TIM2 interrupt in PFIC
  PFIC->IENR[TIM2_IRQn / 32] = (1 << (TIM2_IRQn % 32));

  // Start timer
  TIM2->CTLR1 = TIM_CEN;
}

// Stepper ISR (defined in GRBL core)
void TIM2_IRQHandler(void) {
  if (TIM2->INTFR & TIM_UIF) {
    TIM2->INTFR = ~TIM_UIF;  // Clear interrupt flag
    // Call GRBL stepper ISR
    STEPPER_ISR();
  }
}
```

---

## 9. MEMORY OPTIMIZATION STRATEGIES

To fit GRBL in 16KB Flash and 2KB RAM:

### Flash Optimization:
```makefile
# Aggressive optimization flags
CFLAGS += -Os                      # Optimize for size
CFLAGS += -flto                    # Link-time optimization
CFLAGS += -ffunction-sections      # Each function in own section
CFLAGS += -fdata-sections          # Each data in own section
CFLAGS += -fno-unwind-tables       # Remove exception tables
CFLAGS += -fno-asynchronous-unwind-tables
LDFLAGS += -Wl,--gc-sections       # Remove unused sections
LDFLAGS += -Wl,--print-memory-usage # Show memory usage
```

### Code Reductions:
```c
// In grbl/config.h, add CH32V006-specific defines:
#ifdef PLATFORM_CH32V006
  // Reduce buffer sizes
  #define RX_BUFFER_SIZE 64      // was 128
  #define TX_BUFFER_SIZE 64      // was 128
  #define BLOCK_BUFFER_SIZE 12   // was 18
  #define LINE_BUFFER_SIZE 80    // was 256

  // Disable optional features
  #define DISABLE_HOMING_CYCLE
  #define DISABLE_LIMITS_PIN_INVERSION
  #define DISABLE_PROBE_PIN_PULL_UP
  #define DISABLE_VARIABLE_SPINDLE

  // Use integer math where possible
  #define USE_INTEGER_SQRT
#endif
```

### RAM Optimization:
```c
// Use flash for constant data
const char MSG_WELCOME[] __attribute__((section(".rodata"))) = "Grbl 1.1";

// Pack structures
struct step_segment {
  uint16_t n_step;
  uint8_t  st_block_index;
  uint16_t amass_level : 8;
  uint16_t flag : 8;
} __attribute__((packed));
```

---

## 10. PIN MAPPING (config.h)

```c
// Stepper motors (GPIOC)
#define X_STEP_PIN          0   // PC0
#define Y_STEP_PIN          1   // PC1
#define Z_STEP_PIN          2   // PC2
#define X_DIRECTION_PIN     3   // PC3
#define Y_DIRECTION_PIN     4   // PC4
#define Z_DIRECTION_PIN     5   // PC5
#define STEPPERS_DISABLE_PIN 6  // PC6

// Limit switches (GPIOD)
#define X_LIMIT_PIN         2   // PD2
#define Y_LIMIT_PIN         3   // PD3
#define Z_LIMIT_PIN         4   // PD4

// Spindle control (GPIOD)
#define SPINDLE_ENABLE_PIN  5   // PD5
#define SPINDLE_PWM_PIN     6   // PD6 (TIM1 CH1)
#define SPINDLE_DIRECTION_PIN 7 // PD7

// Coolant (GPIOC)
#define COOLANT_FLOOD_PIN   7   // PC7
#define COOLANT_MIST_PIN    0   // PA0 (if available)

// Serial (USART1)
#define SERIAL_TX_PIN       5   // PD5 (USART1_TX)
#define SERIAL_RX_PIN       6   // PD6 (USART1_RX)
```

---

## 11. BUILD SYSTEM (Makefile)

```makefile
PLATFORM_NAME  = ch32v006
DEVICE         = CH32V003
ARCH           = rv32ec_zicsr
MABI           = ilp32e

# RISC-V toolchain
PREFIX = riscv-none-elf-
CC = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size

# Architecture flags
ARCHFLAGS = -march=$(ARCH) -mabi=$(MABI)
ARCHFLAGS += -msmall-data-limit=8 -mno-save-restore

# Memory layout
LDSCRIPT = script.ld

# Platform sources (minimal for CH32V)
PLATFORM_SOURCES = \
  platform.c \
  startup.c \
  handlers.c \
  flash.c

# Common sources (if reusable)
COMMON_SOURCES = \
  ../common/watchdog_common.c

# Compiler flags (AGGRESSIVE OPTIMIZATION!)
CFLAGS = $(ARCHFLAGS)
CFLAGS += -DPLATFORM_$(DEVICE)
CFLAGS += -DF_CPU=48000000UL
CFLAGS += -Wall -Wextra
CFLAGS += -Os -flto
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -fno-unwind-tables -fno-asynchronous-unwind-tables
CFLAGS += -msoft-float

# Linker flags
LDFLAGS = $(ARCHFLAGS)
LDFLAGS += -T$(LDSCRIPT)
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--print-memory-usage
LDFLAGS += -flto
LDFLAGS += -nostdlib
LDFLAGS += -specs=nano.specs
LDFLAGS += -specs=nosys.specs

# Targets
all: grbl.elf grbl.bin grbl.hex

grbl.elf: $(SOURCES)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

grbl.bin: grbl.elf
	$(OBJCOPY) -O binary $< $@

grbl.hex: grbl.elf
	$(OBJCOPY) -O ihex $< $@

flash: grbl.bin
	# Using WCH-LinkE programmer
	wlink flash grbl.bin

clean:
	rm -f *.elf *.bin *.hex *.o
```

---

## 12. LINKER SCRIPT (script.ld)

```ld
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 16K
  RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 2K
}

ENTRY(_start)

SECTIONS
{
  /* Vector table */
  .vector : ALIGN(4)
  {
    KEEP(*(.vector))
  } > FLASH

  /* Startup code */
  .init : ALIGN(4)
  {
    KEEP(*(.init))
  } > FLASH

  /* Program code */
  .text : ALIGN(4)
  {
    *(.text .text.*)
    *(.rodata .rodata.*)
    . = ALIGN(4);
  } > FLASH

  /* Data (initialized) - LMA in flash, VMA in RAM */
  .data : ALIGN(4)
  {
    _data_vma = .;
    *(.data .data.*)
    . = ALIGN(4);
    _edata = .;
  } > RAM AT > FLASH

  _data_lma = LOADADDR(.data);

  /* BSS (uninitialized) */
  .bss : ALIGN(4)
  {
    _bss_start = .;
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(4);
    _bss_end = .;
  } > RAM

  /* Stack (grows downward from end of RAM) */
  . = ORIGIN(RAM) + LENGTH(RAM);
  _estack = .;
}
```

---

## 13. IMPLEMENTATION TIMELINE

### Week 1: Setup and Foundation
- **Day 1-2**: Toolchain setup (RISC-V GCC, OpenOCD, WCH-Link)
- **Day 3-4**: Create regs.h with CH32V register definitions
- **Day 5-6**: Implement startup.c and linker script
- **Day 7**: Test basic blink program to verify toolchain

### Week 2: HAL Implementation
- **Day 8-9**: Implement GPIO functions (hal_gpio_*)
- **Day 10-11**: Implement timer configuration (TIM2 for stepper ISR)
- **Day 12-13**: Implement USART for serial communication
- **Day 14**: Test GPIO toggling and timer interrupts

### Week 3: Integration and Optimization
- **Day 15-16**: Integrate with GRBL core, fix compilation errors
- **Day 17-18**: Memory optimization (reduce buffers, enable LTO)
- **Day 19-20**: Test on hardware with real stepper motors
- **Day 21**: Final debugging and documentation

**Estimated**: 3 weeks full-time (or 6-8 weeks part-time)

---

## 14. TESTING PLAN

### Phase 1: Basic Hardware Test
1. Flash LED blink program → Verify toolchain
2. Test GPIO output (toggle stepper pins) → Verify GPIO HAL
3. Test timer interrupt (1kHz) → Verify timer HAL
4. Test USART echo → Verify serial communication

### Phase 2: GRBL Integration Test
1. Upload GRBL firmware → Check flash/RAM usage
2. Connect via serial terminal → Verify boot and prompt
3. Send simple GCode (`G0 X10`) → Verify motion planning
4. Test limit switches → Verify interrupt handling
5. Test spindle PWM → Verify timer PWM output

### Phase 3: Real-World Test
1. Connect to CNC machine (small 3-axis plotter)
2. Run homing cycle
3. Run test GCode file (square, circle, text)
4. Stress test (long continuous operation)

---

## 15. KNOWN LIMITATIONS

1. **Memory Constraints**:
   - 16KB Flash: Must disable some GRBL features
   - 2KB RAM: Smaller buffers, reduced look-ahead

2. **No Hardware FPU**:
   - Slower floating-point math (software emulation)
   - May impact feed rate calculations

3. **No DMA**:
   - All I/O must use interrupts
   - Higher CPU usage for USART

4. **Limited GPIO**:
   - Only 18 pins (TSSOP-20 package)
   - May need I/O expander for more features

5. **No Hardware USB**:
   - USB-serial requires external CH340/FTDI chip
   - Or use CH32V003's software USB (experimental)

---

## 16. FUTURE ENHANCEMENTS

Once basic GRBL is working:
- [ ] Add back probing support (if flash space permits)
- [ ] Implement software USB for direct USB connection
- [ ] Add support for 4th axis (A-axis rotary)
- [ ] Optimize assembly critical sections (stepper ISR)
- [ ] Port to CH32V203 (64KB flash, 20KB RAM) for full GRBL feature set

---

## 17. REFERENCES

- [CH32V003 Datasheet](https://www.wch.cn/products/CH32V003.html)
- [CH32V003 Reference Manual](https://www.wch-ic.com/downloads/CH32V00x_RM_PDF.html)
- [RISC-V Spec](https://riscv.org/technical/specifications/)
- [WCH OpenOCD](https://github.com/kprasadvnsi/riscv-openocd-wch)
- [CH32V003 Community Projects](https://github.com/openwch/ch32v003)

---

**Status**: 📋 Ready for implementation
**Next Step**: Set up RISC-V toolchain and acquire CH32V003 development board
