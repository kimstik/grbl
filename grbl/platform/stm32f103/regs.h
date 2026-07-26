/*
  regs.h - STM32F103 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#ifndef STM32F103_REGS_H
#define STM32F103_REGS_H

#include <stdint.h>
#include <stdbool.h>

// CORE ARM CORTEX-M3 DEFINITIONS

// CMSIS-compatible intrinsics
#define __enable_irq()    __asm__ volatile ("cpsie i" : : : "memory")
#define __disable_irq()   __asm__ volatile ("cpsid i" : : : "memory")
#define __NOP()           __asm__ volatile ("nop")
#define __get_PRIMASK()   ({ uint32_t primask; __asm__ volatile ("mrs %0, primask" : "=r" (primask)); primask; })
#define __set_PRIMASK(x)  __asm__ volatile ("msr primask, %0" : : "r" (x) : "memory")

// GPIO REGISTER STRUCTURES

typedef struct {
  volatile uint32_t CRL;      // Port configuration register low
  volatile uint32_t CRH;      // Port configuration register high
  volatile uint32_t IDR;      // Port input data register
  volatile uint32_t ODR;      // Port output data register
  volatile uint32_t BSRR;     // Port bit set/reset register
  volatile uint32_t BRR;      // Port bit reset register
  volatile uint32_t LCKR;     // Port configuration lock register
} GPIO_TypeDef;

#define GPIOA  ((GPIO_TypeDef*)0x40010800)
#define GPIOB  ((GPIO_TypeDef*)0x40010C00)
#define GPIOC  ((GPIO_TypeDef*)0x40011000)
#define GPIOD  ((GPIO_TypeDef*)0x40011400)

// RCC (Reset and Clock Control) REGISTERS

typedef struct {
  volatile uint32_t CR;       // Clock control register
  volatile uint32_t CFGR;     // Clock configuration register
  volatile uint32_t CIR;      // Clock interrupt register
  volatile uint32_t APB2RSTR; // APB2 peripheral reset register
  volatile uint32_t APB1RSTR; // APB1 peripheral reset register
  volatile uint32_t AHBENR;   // AHB peripheral clock enable register
  volatile uint32_t APB2ENR;  // APB2 peripheral clock enable register
  volatile uint32_t APB1ENR;  // APB1 peripheral clock enable register
  volatile uint32_t BDCR;     // Backup domain control register
  volatile uint32_t CSR;      // Control/status register
} RCC_TypeDef;

#define RCC  ((RCC_TypeDef*)0x40021000)

// RCC_CR bits
#define RCC_CR_HSEON    (1 << 16)
#define RCC_CR_HSERDY   (1 << 17)
#define RCC_CR_PLLON    (1 << 24)
#define RCC_CR_PLLRDY   (1 << 25)

// RCC_CFGR bits
#define RCC_CFGR_SW         (0x3 << 0)
#define RCC_CFGR_SW_PLL     (0x2 << 0)
#define RCC_CFGR_SWS        (0x3 << 2)
#define RCC_CFGR_SWS_PLL    (0x2 << 2)
#define RCC_CFGR_PLLSRC     (1 << 16)
#define RCC_CFGR_PLLMULL    (0xF << 18)
#define RCC_CFGR_PLLMULL9   (0x7 << 18)

// RCC_APB2ENR bits
#define RCC_APB2ENR_AFIOEN   (1 << 0)
#define RCC_APB2ENR_IOPAEN   (1 << 2)
#define RCC_APB2ENR_IOPBEN   (1 << 3)
#define RCC_APB2ENR_IOPCEN   (1 << 4)
#define RCC_APB2ENR_IOPDEN   (1 << 5)
#define RCC_APB2ENR_TIM1EN   (1 << 11)
#define RCC_APB2ENR_USART1EN (1 << 14)

// RCC_APB1ENR bits
#define RCC_APB1ENR_TIM2EN   (1 << 0)
#define RCC_APB1ENR_TIM3EN   (1 << 1)
#define RCC_APB1ENR_TIM4EN   (1 << 2)

// TIMER REGISTER STRUCTURES

typedef struct {
  volatile uint32_t CR1;      // Control register 1
  volatile uint32_t CR2;      // Control register 2
  volatile uint32_t SMCR;     // Slave mode control register
  volatile uint32_t DIER;     // DMA/Interrupt enable register
  volatile uint32_t SR;       // Status register
  volatile uint32_t EGR;      // Event generation register
  volatile uint32_t CCMR1;    // Capture/compare mode register 1
  volatile uint32_t CCMR2;    // Capture/compare mode register 2
  volatile uint32_t CCER;     // Capture/compare enable register
  volatile uint32_t CNT;      // Counter
  volatile uint32_t PSC;      // Prescaler
  volatile uint32_t ARR;      // Auto-reload register
  volatile uint32_t RCR;      // Repetition counter register (TIM1 only)
  volatile uint32_t CCR1;     // Capture/compare register 1
  volatile uint32_t CCR2;     // Capture/compare register 2
  volatile uint32_t CCR3;     // Capture/compare register 3
  volatile uint32_t CCR4;     // Capture/compare register 4
  volatile uint32_t BDTR;     // Break and dead-time register (TIM1 only)
  volatile uint32_t DCR;      // DMA control register
  volatile uint32_t DMAR;     // DMA address for full transfer
} TIM_TypeDef;

#define TIM1  ((TIM_TypeDef*)0x40012C00)
#define TIM2  ((TIM_TypeDef*)0x40000000)
#define TIM3  ((TIM_TypeDef*)0x40000400)
#define TIM4  ((TIM_TypeDef*)0x40000800)

// TIM_CR1 bits
#define TIM_CR1_CEN      (1 << 0)
#define TIM_CR1_ARPE     (1 << 7)

// TIM_DIER bits
#define TIM_DIER_UIE     (1 << 0)
#define TIM_DIER_CC1IE   (1 << 1)

// TIM_SR bits
#define TIM_SR_UIF       (1 << 0)
#define TIM_SR_CC1IF     (1 << 1)

// TIM_EGR bits
#define TIM_EGR_UG       (1 << 0)

// TIM_CCMR1 bits
#define TIM_CCMR1_OC1PE  (1 << 3)

// TIM_CCER bits
#define TIM_CCER_CC1E    (1 << 0)

// TIM_BDTR bits (TIM1 only)
#define TIM_BDTR_MOE     (1 << 15)

// USART REGISTER STRUCTURES

typedef struct {
  volatile uint32_t SR;       // Status register
  volatile uint32_t DR;       // Data register
  volatile uint32_t BRR;      // Baud rate register
  volatile uint32_t CR1;      // Control register 1
  volatile uint32_t CR2;      // Control register 2
  volatile uint32_t CR3;      // Control register 3
  volatile uint32_t GTPR;     // Guard time and prescaler register
} USART_TypeDef;

#define USART1  ((USART_TypeDef*)0x40013800)

// USART_SR bits
#define USART_SR_RXNE    (1 << 5)
#define USART_SR_TXE     (1 << 7)

// USART_CR1 bits
#define USART_CR1_UE     (1 << 13)
#define USART_CR1_TE     (1 << 3)
#define USART_CR1_RE     (1 << 2)
#define USART_CR1_RXNEIE (1 << 5)
#define USART_CR1_TXEIE  (1 << 7)

// FLASH REGISTER STRUCTURES

typedef struct {
  volatile uint32_t ACR;      // Access control register
  volatile uint32_t KEYR;     // Key register
  volatile uint32_t OPTKEYR;  // Option key register
  volatile uint32_t SR;       // Status register
  volatile uint32_t CR;       // Control register
  volatile uint32_t AR;       // Address register
  volatile uint32_t RESERVED; // Reserved
  volatile uint32_t OBR;      // Option byte register
  volatile uint32_t WRPR;     // Write protection register
} FLASH_TypeDef;

#define FLASH  ((FLASH_TypeDef*)0x40022000)

// FLASH_ACR bits
#define FLASH_ACR_LATENCY_2  (2 << 0)
#define FLASH_ACR_PRFTBE     (1 << 4)

// FLASH_SR bits
#define FLASH_SR_BSY         (1 << 0)
#define FLASH_SR_PGERR       (1 << 2)
#define FLASH_SR_WRPRTERR    (1 << 4)
#define FLASH_SR_EOP         (1 << 5)

// FLASH_CR bits
#define FLASH_CR_PG          (1 << 0)
#define FLASH_CR_PER         (1 << 1)
#define FLASH_CR_STRT        (1 << 6)
#define FLASH_CR_LOCK        (1 << 7)

// AFIO (Alternate Function I/O) REGISTERS

typedef struct {
  volatile uint32_t EVCR;     // Event control register
  volatile uint32_t MAPR;     // AF remap and debug I/O config register
  volatile uint32_t EXTICR[4];// External interrupt config registers 1-4
  volatile uint32_t RESERVED; // Reserved
  volatile uint32_t MAPR2;    // AF remap and debug I/O config register 2
} AFIO_TypeDef;

#define AFIO  ((AFIO_TypeDef*)0x40010000)

// EXTI (External Interrupt) REGISTERS

typedef struct {
  volatile uint32_t IMR;      // Interrupt mask register
  volatile uint32_t EMR;      // Event mask register
  volatile uint32_t RTSR;     // Rising trigger selection register
  volatile uint32_t FTSR;     // Falling trigger selection register
  volatile uint32_t SWIER;    // Software interrupt event register
  volatile uint32_t PR;       // Pending register
} EXTI_TypeDef;

#define EXTI  ((EXTI_TypeDef*)0x40010400)

// EXTI_PR bits
#define EXTI_PR_PR0      (1 << 0)
#define EXTI_PR_PR1      (1 << 1)
#define EXTI_PR_PR10     (1 << 10)

// SYSTICK REGISTER STRUCTURES

typedef struct {
  volatile uint32_t CTRL;     // Control and status register
  volatile uint32_t LOAD;     // Reload value register
  volatile uint32_t VAL;      // Current value register
  volatile uint32_t CALIB;    // Calibration value register
} SysTick_Type;

#define SysTick  ((SysTick_Type*)0xE000E010)

#define SysTick_Config(ticks) \
  ({ \
    SysTick->LOAD = (ticks) - 1; \
    SysTick->VAL = 0; \
    SysTick->CTRL = 0x07; \
    0; \
  })

// DWT (Data Watchpoint and Trace) FOR CYCLE COUNTING

typedef struct {
  volatile uint32_t CTRL;     // Control register
  volatile uint32_t CYCCNT;   // Cycle count register
  volatile uint32_t CPICNT;   // CPI count register
  volatile uint32_t EXCCNT;   // Exception overhead count register
  volatile uint32_t SLEEPCNT; // Sleep count register
  volatile uint32_t LSUCNT;   // LSU count register
  volatile uint32_t FOLDCNT;  // Folded-instruction count register
  volatile uint32_t PCSR;     // Program counter sample register
} DWT_Type;

#define DWT  ((DWT_Type*)0xE0001000)

#define DWT_CTRL_CYCCNTENA_Msk  (1 << 0)

// COREDEBUG FOR DWT ENABLE

typedef struct {
  volatile uint32_t DHCSR;    // Debug halting control and status register
  volatile uint32_t DCRSR;    // Debug core register selector register
  volatile uint32_t DCRDR;    // Debug core register data register
  volatile uint32_t DEMCR;    // Debug exception and monitor control register
} CoreDebug_Type;

#define CoreDebug  ((CoreDebug_Type*)0xE000EDF0)

#define CoreDebug_DEMCR_TRCENA_Msk  (1 << 24)

// SCB (System Control Block) - only the registers startup.c needs
// VTOR is what makes the vector table a *referenced* object: without a real
// code reference GCC's LTO deletes vector_table[] before codegen and the
// linker's KEEP(*(.isr_vector)) then matches nothing (see CONTRACTS.md S18).

typedef struct {
  volatile uint32_t CPUID;    // CPUID base register            (0xE000ED00)
  volatile uint32_t ICSR;     // Interrupt control and state    (0xE000ED04)
  volatile uint32_t VTOR;     // Vector table offset register   (0xE000ED08)
} SCB_Type;

#define SCB_BASE  (0xE000ED00UL)
#define SCB       ((SCB_Type*)SCB_BASE)

// NVIC (Nested Vectored Interrupt Controller)

typedef struct {
  volatile uint32_t ISER[8];  // Interrupt set-enable registers
  uint32_t RESERVED0[24];
  volatile uint32_t ICER[8];  // Interrupt clear-enable registers
  uint32_t RESERVED1[24];
  volatile uint32_t ISPR[8];  // Interrupt set-pending registers
  uint32_t RESERVED2[24];
  volatile uint32_t ICPR[8];  // Interrupt clear-pending registers
  uint32_t RESERVED3[24];
  volatile uint32_t IABR[8];  // Interrupt active bit registers
  uint32_t RESERVED4[56];
  volatile uint8_t  IP[240];  // Interrupt priority registers
  uint32_t RESERVED5[644];
  volatile uint32_t STIR;     // Software trigger interrupt register
} NVIC_Type;

#define NVIC  ((NVIC_Type*)0xE000E100)

// IRQ numbers for STM32F103
typedef enum {
  EXTI0_IRQn       = 6,
  EXTI1_IRQn       = 7,
  EXTI2_IRQn       = 8,
  EXTI3_IRQn       = 9,
  EXTI4_IRQn       = 10,
  EXTI9_5_IRQn     = 23,
  TIM1_BRK_IRQn    = 24,
  TIM1_UP_IRQn     = 25,
  TIM1_TRG_COM_IRQn= 26,
  TIM1_CC_IRQn     = 27,
  TIM2_IRQn        = 28,
  TIM3_IRQn        = 29,
  TIM4_IRQn        = 30,
  USART1_IRQn      = 37,
  EXTI15_10_IRQn   = 40
} IRQn_Type;

// NVIC helper functions
static inline void NVIC_EnableIRQ(IRQn_Type IRQn) {
  NVIC->ISER[IRQn >> 5] = (1 << (IRQn & 0x1F));
}

static inline void NVIC_DisableIRQ(IRQn_Type IRQn) {
  NVIC->ICER[IRQn >> 5] = (1 << (IRQn & 0x1F));
}

static inline void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority) {
  NVIC->IP[IRQn] = (priority << 4);
}

// IWDG - Independent Watchdog

typedef struct {
  volatile uint32_t KR;   // Key register
  volatile uint32_t PR;   // Prescaler register
  volatile uint32_t RLR;  // Reload register
  volatile uint32_t SR;   // Status register
} IWDG_TypeDef;

#define IWDG_BASE   0x40003000
#define IWDG        ((IWDG_TypeDef*)IWDG_BASE)

#endif // STM32F103_REGS_H
