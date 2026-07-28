/*
  regs.h - STM32H5 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef STM32H523_REGS_H
#define STM32H523_REGS_H

#include <stdint.h>
#include <stdbool.h>

// GPIO

typedef struct {
  volatile uint32_t MODER;    // Mode register
  volatile uint32_t OTYPER;   // Output type register
  volatile uint32_t OSPEEDR;  // Output speed register
  volatile uint32_t PUPDR;    // Pull-up/pull-down register
  volatile uint32_t IDR;      // Input data register
  volatile uint32_t ODR;      // Output data register
  volatile uint32_t BSRR;     // Bit set/reset register
  volatile uint32_t LCKR;     // Configuration lock register
  volatile uint32_t AFR[2];   // Alternate function registers
} GPIO_TypeDef;

#define GPIOA_BASE  0x42020000
#define GPIOB_BASE  0x42020400
#define GPIOC_BASE  0x42020800

#define GPIOA   ((GPIO_TypeDef*)GPIOA_BASE)
#define GPIOB   ((GPIO_TypeDef*)GPIOB_BASE)
#define GPIOC   ((GPIO_TypeDef*)GPIOC_BASE)

// FLASH

typedef struct {
  volatile uint32_t ACR;      // Access control register
  volatile uint32_t KEYR;     // Key register
  volatile uint32_t OPTKEYR;  // Option key register
  volatile uint32_t CR;       // Control register
  volatile uint32_t SR;       // Status register
  volatile uint32_t CCR;      // Clear control register
} FLASH_TypeDef;

#define FLASH_BASE  0x52002000
#define FLASH   ((FLASH_TypeDef*)FLASH_BASE)

// Flash CR register bits
#define FLASH_CR_LOCK       (1 << 0)
#define FLASH_CR_PG         (1 << 1)
#define FLASH_CR_PER        (1 << 2)
#define FLASH_CR_STRT       (1 << 6)
#define FLASH_CR_PNB_Pos    3

// Flash SR register bits
#define FLASH_SR_BSY        (1 << 0)
#define FLASH_SR_WRPERR     (1 << 4)
#define FLASH_SR_PGSERR     (1 << 5)
#define FLASH_SR_EOP        (1 << 16)

// RCC (Reset and Clock Control)

typedef struct {
  volatile uint32_t CR;         // Clock control register
  volatile uint32_t ICSCR1;     // Internal clock sources calibration register 1
  volatile uint32_t ICSCR2;     // Internal clock sources calibration register 2
  volatile uint32_t ICSCR3;     // Internal clock sources calibration register 3
  volatile uint32_t CRRCR;      // Clock recovery RC register
  uint32_t RESERVED1;
  volatile uint32_t CFGR1;      // Clock configuration register 1
  volatile uint32_t CFGR2;      // Clock configuration register 2
  volatile uint32_t CFGR3;      // Clock configuration register 3
  volatile uint32_t PLL1CFGR;   // PLL1 configuration register
  volatile uint32_t PLL2CFGR;   // PLL2 configuration register (if available)
  volatile uint32_t PLL3CFGR;   // PLL3 configuration register (if available)
  volatile uint32_t PLL1DIVR;   // PLL1 dividers register
  volatile uint32_t PLL1FRACR;  // PLL1 fractional divider register
  volatile uint32_t PLL2DIVR;   // PLL2 dividers register
  volatile uint32_t PLL2FRACR;  // PLL2 fractional divider register
  volatile uint32_t PLL3DIVR;   // PLL3 dividers register
  volatile uint32_t PLL3FRACR;  // PLL3 fractional divider register
  uint32_t RESERVED2;
  volatile uint32_t CIER;       // Clock interrupt enable register
  volatile uint32_t CIFR;       // Clock interrupt flag register
  volatile uint32_t CICR;       // Clock interrupt clear register
  uint32_t RESERVED3;
  volatile uint32_t AHB1RSTR;   // AHB1 peripheral reset register
  volatile uint32_t AHB2RSTR;   // AHB2 peripheral reset register
  volatile uint32_t AHB3RSTR;   // AHB3 peripheral reset register (if available)
  uint32_t RESERVED4;
  volatile uint32_t APB1RSTR1;  // APB1 peripheral reset register 1
  volatile uint32_t APB1RSTR2;  // APB1 peripheral reset register 2
  volatile uint32_t APB2RSTR;   // APB2 peripheral reset register
  volatile uint32_t APB3RSTR;   // APB3 peripheral reset register
  uint32_t RESERVED5;
  volatile uint32_t AHB1ENR;    // AHB1 peripheral clock enable register
  volatile uint32_t AHB2ENR;    // AHB2 peripheral clock enable register
  volatile uint32_t AHB3ENR;    // AHB3 peripheral clock enable register (if available)
  uint32_t RESERVED6;
  volatile uint32_t APB1ENR1;   // APB1 peripheral clock enable register 1
  volatile uint32_t APB1ENR2;   // APB1 peripheral clock enable register 2
  volatile uint32_t APB2ENR;    // APB2 peripheral clock enable register
  volatile uint32_t APB3ENR;    // APB3 peripheral clock enable register
} RCC_TypeDef;

#define RCC_BASE  0x44020C00
#define RCC   ((RCC_TypeDef*)RCC_BASE)

// RCC AHB2ENR register bits (GPIO clocks)
#define RCC_AHB2ENR_GPIOAEN  (1 << 0)
#define RCC_AHB2ENR_GPIOBEN  (1 << 1)
#define RCC_AHB2ENR_GPIOCEN  (1 << 2)

// RCC APB1ENR1 register bits (TIM2, TIM3, USART2, USART3)
#define RCC_APB1ENR1_TIM2EN   (1 << 0)
#define RCC_APB1ENR1_TIM3EN   (1 << 1)
#define RCC_APB1ENR1_USART2EN (1 << 17)
#define RCC_APB1ENR1_USART3EN (1 << 18)

// RCC APB2ENR register bits (USART1, TIM1)
#define RCC_APB2ENR_USART1EN  (1 << 14)
#define RCC_APB2ENR_TIM1EN    (1 << 11)

// RCC CR register bits
#define RCC_CR_HSION    (1 << 0)   // HSI oscillator enable
#define RCC_CR_HSIRDY   (1 << 1)   // HSI oscillator ready
#define RCC_CR_HSEON    (1 << 16)  // HSE oscillator enable
#define RCC_CR_HSERDY   (1 << 17)  // HSE oscillator ready
#define RCC_CR_PLL1ON   (1 << 24)  // PLL1 enable
#define RCC_CR_PLL1RDY  (1 << 25)  // PLL1 ready

// EXTI (External Interrupts)
// Note: STM32H5 uses EXTI_CxIMR1/2 model (C1 = CPU1)

typedef struct {
  volatile uint32_t RTSR1;      // Rising trigger selection register 1
  volatile uint32_t FTSR1;      // Falling trigger selection register 1
  volatile uint32_t SWIER1;     // Software interrupt event register 1
  volatile uint32_t RPR1;       // Rising edge pending register 1
  volatile uint32_t FPR1;       // Falling edge pending register 1
  uint32_t RESERVED1[3];
  volatile uint32_t RTSR2;      // Rising trigger selection register 2
  volatile uint32_t FTSR2;      // Falling trigger selection register 2
  volatile uint32_t SWIER2;     // Software interrupt event register 2
  volatile uint32_t RPR2;       // Rising edge pending register 2
  volatile uint32_t FPR2;       // Falling edge pending register 2
  uint32_t RESERVED2[11];
  volatile uint32_t EXTICR[4];  // External interrupt configuration registers
  uint32_t RESERVED3[4];
  volatile uint32_t IMR1;       // Interrupt mask register 1
  volatile uint32_t EMR1;       // Event mask register 1
  uint32_t RESERVED4[2];
  volatile uint32_t IMR2;       // Interrupt mask register 2
  volatile uint32_t EMR2;       // Event mask register 2
} EXTI_TypeDef;

#define EXTI_BASE  0x44022000
#define EXTI   ((EXTI_TypeDef*)EXTI_BASE)

// EXTI line definitions (0-15 for GPIO pins)
#define EXTI_LINE_0   (1 << 0)
#define EXTI_LINE_1   (1 << 1)
#define EXTI_LINE_2   (1 << 2)
#define EXTI_LINE_3   (1 << 3)
#define EXTI_LINE_4   (1 << 4)
#define EXTI_LINE_5   (1 << 5)
#define EXTI_LINE_6   (1 << 6)
#define EXTI_LINE_10  (1 << 10)

// SYSCFG (System Configuration)
// Needed for GPIO to EXTI line mapping

typedef struct {
  uint32_t RESERVED1[2];
  volatile uint32_t EXTICR[4];  // External interrupt configuration registers
} SYSCFG_TypeDef;

#define SYSCFG_BASE  0x44000400
#define SYSCFG   ((SYSCFG_TypeDef*)SYSCFG_BASE)

#define RCC_APB3ENR_SYSCFGEN  (1 << 1)  // SYSCFG clock enable in APB3ENR

// SYSCFG_EXTICR register field positions
#define SYSCFG_EXTICR1_EXTI0_Pos  0
#define SYSCFG_EXTICR1_EXTI1_Pos  4
#define SYSCFG_EXTICR1_EXTI2_Pos  8
#define SYSCFG_EXTICR1_EXTI3_Pos  12
#define SYSCFG_EXTICR2_EXTI4_Pos  0
#define SYSCFG_EXTICR2_EXTI5_Pos  4
#define SYSCFG_EXTICR2_EXTI6_Pos  8
#define SYSCFG_EXTICR3_EXTI10_Pos 8

// GPIO port codes for SYSCFG_EXTICR
#define SYSCFG_EXTICR_PA  0x0
#define SYSCFG_EXTICR_PB  0x1
#define SYSCFG_EXTICR_PC  0x2

// NVIC (Nested Vectored Interrupt Controller)

// SCB (System Control Block) - only the registers startup.c needs
// VTOR is what makes the vector table a *referenced* object: without a real
// code reference GCC's LTO deletes vector_table[] before codegen and the
// linker's KEEP(*(.isr_vector)) then matches nothing (see CONTRACTS.md S18).

typedef struct {
  volatile uint32_t CPUID;      // CPUID base register            (0xE000ED00)
  volatile uint32_t ICSR;       // Interrupt control and state    (0xE000ED04)
  volatile uint32_t VTOR;       // Vector table offset register   (0xE000ED08)
} SCB_TypeDef;

#define SCB_BASE  0xE000ED00
#define SCB    ((SCB_TypeDef*)SCB_BASE)

typedef struct {
  volatile uint32_t ISER[16];   // Interrupt set-enable registers
  uint32_t RESERVED1[16];
  volatile uint32_t ICER[16];   // Interrupt clear-enable registers
  uint32_t RESERVED2[16];
  volatile uint32_t ISPR[16];   // Interrupt set-pending registers
  uint32_t RESERVED3[16];
  volatile uint32_t ICPR[16];   // Interrupt clear-pending registers
  uint32_t RESERVED4[16];
  volatile uint32_t IABR[16];   // Interrupt active bit registers
  uint32_t RESERVED5[16];
  volatile uint32_t IPR[124];   // Interrupt priority registers
} NVIC_TypeDef;

#define NVIC_BASE  0xE000E100
#define NVIC   ((NVIC_TypeDef*)NVIC_BASE)

// Helper macros for NVIC
#define NVIC_EnableIRQ(IRQn)   (NVIC->ISER[(uint32_t)IRQn >> 5] = (1 << ((uint32_t)IRQn & 0x1F)))
#define NVIC_DisableIRQ(IRQn)  (NVIC->ICER[(uint32_t)IRQn >> 5] = (1 << ((uint32_t)IRQn & 0x1F)))
// NVIC_SetPriority is declared after IRQn_Type below (it takes IRQn_Type by
// name, which is not defined until the enum further down this file).

// TIM (Timers)

typedef struct {
  volatile uint32_t CR1;        // Control register 1
  volatile uint32_t CR2;        // Control register 2
  volatile uint32_t SMCR;       // Slave mode control register
  volatile uint32_t DIER;       // DMA/Interrupt enable register
  volatile uint32_t SR;         // Status register
  volatile uint32_t EGR;        // Event generation register
  volatile uint32_t CCMR1;      // Capture/compare mode register 1
  volatile uint32_t CCMR2;      // Capture/compare mode register 2
  volatile uint32_t CCER;       // Capture/compare enable register
  volatile uint32_t CNT;        // Counter
  volatile uint32_t PSC;        // Prescaler
  volatile uint32_t ARR;        // Auto-reload register
  volatile uint32_t RCR;        // Repetition counter register
  volatile uint32_t CCR1;       // Capture/compare register 1
  volatile uint32_t CCR2;       // Capture/compare register 2
  volatile uint32_t CCR3;       // Capture/compare register 3
  volatile uint32_t CCR4;       // Capture/compare register 4
  volatile uint32_t BDTR;       // Break and dead-time register
  volatile uint32_t DCR;        // DMA control register
  volatile uint32_t DMAR;       // DMA address for full transfer
} TIM_TypeDef;

// TIM1 (APB2, advanced-control timer - RM0481 memory map table): same
// register shape as TIM2/TIM3 above (CCMR1/2, CCER, RCR, CCR1-4, BDTR are
// already part of TIM_TypeDef), only the base address and the
// advanced-timer-only bits (BDTR.MOE) are TIM1-specific.
#define TIM1_BASE  0x40012C00
#define TIM2_BASE  0x40000000
#define TIM3_BASE  0x40000400

#define TIM1   ((TIM_TypeDef*)TIM1_BASE)
#define TIM2   ((TIM_TypeDef*)TIM2_BASE)
#define TIM3   ((TIM_TypeDef*)TIM3_BASE)

// TIM CR1 register bits
#define TIM_CR1_CEN   (1 << 0)   // Counter enable
#define TIM_CR1_UDIS  (1 << 1)   // Update disable
#define TIM_CR1_URS   (1 << 2)   // Update request source
#define TIM_CR1_OPM   (1 << 3)   // One-pulse mode
#define TIM_CR1_ARPE  (1 << 7)   // Auto-reload preload enable

// TIM DIER register bits
#define TIM_DIER_UIE  (1 << 0)   // Update interrupt enable
#define TIM_DIER_CC1IE (1 << 1)  // Capture/Compare 1 interrupt enable

// TIM SR register bits
#define TIM_SR_UIF    (1 << 0)   // Update interrupt flag
#define TIM_SR_CC1IF  (1 << 1)   // Capture/Compare 1 interrupt flag

// TIM CCMR1 bits (output compare mode, channel 1)
#define TIM_CCMR1_OC1PE  (1 << 3)   // Output compare 1 preload enable

// TIM CCER bits
#define TIM_CCER_CC1E    (1 << 0)   // Capture/compare 1 output enable

// TIM BDTR bits (TIM1 only - advanced-control timer main output enable)
#define TIM_BDTR_MOE     (1 << 15)  // Main output enable: without this the
                                    // OCx outputs stay disconnected even with
                                    // CCER.CC1E set (RM0481 advanced timer ch.)

// USART

typedef struct {
  volatile uint32_t CR1;        // Control register 1
  volatile uint32_t CR2;        // Control register 2
  volatile uint32_t CR3;        // Control register 3
  volatile uint32_t BRR;        // Baud rate register
  volatile uint32_t GTPR;       // Guard time and prescaler register
  volatile uint32_t RTOR;       // Receiver timeout register
  volatile uint32_t RQR;        // Request register
  volatile uint32_t ISR;        // Interrupt and status register
  volatile uint32_t ICR;        // Interrupt flag clear register
  volatile uint32_t RDR;        // Receive data register
  volatile uint32_t TDR;        // Transmit data register
  volatile uint32_t PRESC;      // Prescaler register
} USART_TypeDef;

#define USART1_BASE  0x40011000
#define USART1   ((USART_TypeDef*)USART1_BASE)

// USART CR1 register bits
#define USART_CR1_UE     (1 << 0)   // USART enable
#define USART_CR1_RE     (1 << 2)   // Receiver enable
#define USART_CR1_TE     (1 << 3)   // Transmitter enable
#define USART_CR1_RXNEIE (1 << 5)   // RXNE interrupt enable
#define USART_CR1_TCIE   (1 << 6)   // Transmission complete interrupt enable
#define USART_CR1_TXEIE  (1 << 7)   // TXE interrupt enable

// USART ISR register bits
#define USART_ISR_PE     (1 << 0)   // Parity error
#define USART_ISR_FE     (1 << 1)   // Framing error
#define USART_ISR_NE     (1 << 2)   // Noise error
#define USART_ISR_ORE    (1 << 3)   // Overrun error
#define USART_ISR_IDLE   (1 << 4)   // Idle line detected
#define USART_ISR_RXNE   (1 << 5)   // Read data register not empty
#define USART_ISR_TC     (1 << 6)   // Transmission complete
#define USART_ISR_TXE    (1 << 7)   // Transmit data register empty

// IRQ Numbers for STM32H523

typedef enum {
  WWDG_IRQn              = 0,
  PVD_AVD_IRQn           = 1,
  RTC_IRQn               = 2,
  RTC_S_IRQn             = 3,
  TAMP_IRQn              = 4,
  RAMCFG_IRQn            = 5,
  FLASH_IRQn             = 6,
  FLASH_S_IRQn           = 7,
  GTZC_IRQn              = 8,
  RCC_IRQn               = 9,
  RCC_S_IRQn             = 10,
  EXTI0_IRQn             = 11,
  EXTI1_IRQn             = 12,
  EXTI2_IRQn             = 13,
  EXTI3_IRQn             = 14,
  EXTI4_IRQn             = 15,
  EXTI5_IRQn             = 16,
  EXTI6_IRQn             = 17,
  EXTI7_IRQn             = 18,
  EXTI8_IRQn             = 19,
  EXTI9_IRQn             = 20,
  EXTI10_IRQn            = 21,
  EXTI11_IRQn            = 22,
  EXTI12_IRQn            = 23,
  EXTI13_IRQn            = 24,
  EXTI14_IRQn            = 25,
  EXTI15_IRQn            = 26,
  GPDMA1_Channel0_IRQn   = 27,
  GPDMA1_Channel1_IRQn   = 28,
  GPDMA1_Channel2_IRQn   = 29,
  GPDMA1_Channel3_IRQn   = 30,
  GPDMA1_Channel4_IRQn   = 31,
  GPDMA1_Channel5_IRQn   = 32,
  GPDMA1_Channel6_IRQn   = 33,
  GPDMA1_Channel7_IRQn   = 34,
  IWDG_IRQn              = 35,
  SAES_IRQn              = 36,
  ADC1_IRQn              = 37,
  DAC1_IRQn              = 38,
  FDCAN1_IT0_IRQn        = 39,
  FDCAN1_IT1_IRQn        = 40,
  TIM1_BRK_IRQn          = 41,
  TIM1_UP_IRQn           = 42,
  TIM1_TRG_COM_IRQn      = 43,
  TIM1_CC_IRQn           = 44,
  TIM2_IRQn              = 45,
  TIM3_IRQn              = 46,
  I2C1_EV_IRQn           = 47,
  I2C1_ER_IRQn           = 48,
  SPI1_IRQn              = 49,
  USART1_IRQn            = 53,
  USART2_IRQn            = 54,
  LPUART1_IRQn           = 58,
  LPTIM1_IRQn            = 59,
  TIM4_IRQn              = 60
} IRQn_Type;

// NVIC_SetPriority - IPR[] above is declared word-packed (4 IRQs/register,
// matching RM0481's IPR0..IPRn naming) rather than CMSIS's byte-array `IP[240]`
// (stm32f103/f411 regs.h). Same memory-mapped region either way, little-endian
// Cortex-M byte order makes the two views equivalent - reinterpreting as a
// byte array here reproduces stm32f411/regs.h:373-375's NVIC->IP[IRQn] write
// without redeclaring NVIC_TypeDef. 4 priority bits implemented (upper nibble
// of each byte), matching every other STM32 port in this tree.
static inline void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority) {
  ((volatile uint8_t*)NVIC->IPR)[(uint32_t)IRQn] = (uint8_t)(priority << 4);
}

// Core M33 Functions
// Macros (not static inline functions): common/stm32/stm32_platform.h
// #ifndef-guards these same names for its own fallback definitions, and an
// #ifndef only sees prior MACRO definitions, not function declarations - a
// static-inline version here would silently redefine when a TU pulls in both
// headers (platform.c does, via stm32_timing.h/stm32_nvmem.h/stm32_watchdog.h).

#define __disable_irq()   __asm__ volatile ("cpsid i" : : : "memory")
#define __enable_irq()    __asm__ volatile ("cpsie i" : : : "memory")
#define __get_PRIMASK()   ({ uint32_t primask; __asm__ volatile ("mrs %0, primask" : "=r" (primask)); primask; })
#define __set_PRIMASK(x)  __asm__ volatile ("msr primask, %0" : : "r" (x) : "memory")

// COMMON MACROS

#define __IO volatile
#define __NOP() __asm__ volatile ("nop")

#endif // STM32H523_REGS_H
