/*
  regs.h - STM32F411 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal register definitions for STM32F411CEU6 ("Black Pill"), ARM
  Cortex-M4F. For production use, recommend using official CMSIS headers.

  F411 is F4-family, NOT F1: GPIO is the MODER/OTYPER/OSPEEDR/PUPDR/AFR model
  (same shape as stm32h523/regs.h, ported from there), but the peripheral
  BASE ADDRESSES differ from both F1 and H5 - this is the trap flagged in
  PORTING-CHECKLIST.md's reuse-first guidance: "same family resemblance" is
  not "same memory map". Verified against RM0383 citations below (web search
  this session, since no CMSIS pack is vendored here):
    - TIM1 is at 0x40010000 on F4 (NOT stm32f103/stm32h523's 0x40012C00 -
      that address is F1's TIM1 base; blindly reusing it would silently
      misdirect every TIM1 register access, including BDTR/CCR1, to whatever
      lives at 0x40012C00 on F4 (SDIO), a "compiles, links, destroys the
      machine at runtime" class bug the CONTRACTS.md cautionary tale warns
      against generalizing).
    - RCC_APB2ENR: TIM1EN=bit0, USART1EN=bit4, SYSCFGEN=bit14 (confirmed via
      STM32F412 RM cross-reference + community citations - F412/F411 share
      the APB2ENR layout in this range).
    - RCC_AHB1ENR: GPIOAEN=bit0, GPIOBEN=bit1, GPIOCEN=bit2 (standard F4).
    - RCC_PLLCFGR: PLLM[5:0]=bits0-5, PLLN[8:0]=bits6-14, PLLSRC=bit22,
      PLLP[1:0]=bits16-17, PLLQ[3:0]=bits24-27 (RM0383).
    - EXTI/SYSCFG: F4 keeps the classic single-PR-register EXTI model
      (write-1-to-clear on one pending register), UNLIKE stm32h523's
      RPR1/FPR1 split (that split is H5-specific) - handlers.c below follows
      the stm32f103 shared-vector dispatch pattern (EXTI9_5/EXTI15_10), not
      h523's per-line vectors.
    - IRQn positions (EXTI9_5=23, EXTI15_10=40, TIM2=28, TIM3=29, USART1=37,
      USART2=38) verified via search this session against the published
      STM32F411 CMSIS vector table - identical numbering to stm32f103/h523
      for these entries (coincidental overlap in the low IRQ range across
      F1/F4 families; NOT to be assumed for peripherals not cited here).
*/

#ifndef STM32F411_REGS_H
#define STM32F411_REGS_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// CORE ARM CORTEX-M4F DEFINITIONS
// ============================================================================

#define __enable_irq()    __asm__ volatile ("cpsie i" : : : "memory")
#define __disable_irq()   __asm__ volatile ("cpsid i" : : : "memory")
#define __NOP()           __asm__ volatile ("nop")
#define __get_PRIMASK()   ({ uint32_t primask; __asm__ volatile ("mrs %0, primask" : "=r" (primask)); primask; })
#define __set_PRIMASK(x)  __asm__ volatile ("msr primask, %0" : : "r" (x) : "memory")

#define __IO volatile

// Memory barriers (BUG#12/BUG#13 lessons, CONTRACTS.md sections 12.1/12.4):
// startup.c needs __DSB() between the .data copy and .bss zero phases, and
// between .bss zero and calling main() (mirrors samd21/startup.c:184-194).
// flash.c/nvmem indirection gets its own copy via common/stm32/
// stm32_platform.h; this one lets startup.c stand alone without pulling in
// the whole common/stm32 chain just for a compiler barrier + instruction.
#define __DSB()  __asm__ volatile ("dsb" ::: "memory")
#define __DMB()  __asm__ volatile ("dmb" ::: "memory")
#define __ISB()  __asm__ volatile ("isb" ::: "memory")

// ============================================================================
// GPIO (F4 model: MODER/OTYPER/OSPEEDR/PUPDR/IDR/ODR/BSRR/LCKR/AFR[2])
// ============================================================================

typedef struct {
  volatile uint32_t MODER;    // Mode register
  volatile uint32_t OTYPER;   // Output type register
  volatile uint32_t OSPEEDR;  // Output speed register
  volatile uint32_t PUPDR;    // Pull-up/pull-down register
  volatile uint32_t IDR;      // Input data register
  volatile uint32_t ODR;      // Output data register
  volatile uint32_t BSRR;     // Bit set/reset register
  volatile uint32_t LCKR;     // Configuration lock register
  volatile uint32_t AFR[2];   // Alternate function registers (low/high)
} GPIO_TypeDef;

#define GPIOA_BASE  0x40020000UL
#define GPIOB_BASE  0x40020400UL
#define GPIOC_BASE  0x40020800UL

#define GPIOA  ((GPIO_TypeDef*)GPIOA_BASE)
#define GPIOB  ((GPIO_TypeDef*)GPIOB_BASE)
#define GPIOC  ((GPIO_TypeDef*)GPIOC_BASE)

// ============================================================================
// RCC (Reset and Clock Control) - F4 layout, distinct from F1/H5
// ============================================================================

typedef struct {
  volatile uint32_t CR;         // 0x00 Clock control register
  volatile uint32_t PLLCFGR;    // 0x04 PLL configuration register
  volatile uint32_t CFGR;       // 0x08 Clock configuration register
  volatile uint32_t CIR;        // 0x0C Clock interrupt register
  volatile uint32_t AHB1RSTR;   // 0x10
  volatile uint32_t AHB2RSTR;   // 0x14
  uint32_t RESERVED0[2];        // 0x18, 0x1C (AHB3RSTR n/a on F411)
  volatile uint32_t APB1RSTR;   // 0x20
  volatile uint32_t APB2RSTR;   // 0x24
  uint32_t RESERVED1[2];        // 0x28, 0x2C
  volatile uint32_t AHB1ENR;    // 0x30
  volatile uint32_t AHB2ENR;    // 0x34
  uint32_t RESERVED2[2];        // 0x38, 0x3C
  volatile uint32_t APB1ENR;    // 0x40
  volatile uint32_t APB2ENR;    // 0x44
} RCC_TypeDef;

#define RCC_BASE  0x40023800UL
#define RCC   ((RCC_TypeDef*)RCC_BASE)

// RCC_CR bits
#define RCC_CR_HSION    (1UL << 0)
#define RCC_CR_HSIRDY   (1UL << 1)
#define RCC_CR_HSEON    (1UL << 16)
#define RCC_CR_HSERDY   (1UL << 17)
#define RCC_CR_PLLON    (1UL << 24)
#define RCC_CR_PLLRDY   (1UL << 25)

// RCC_PLLCFGR bits (RM0383 6.3.2)
#define RCC_PLLCFGR_PLLM_Pos   0
#define RCC_PLLCFGR_PLLN_Pos   6
#define RCC_PLLCFGR_PLLP_Pos   16
#define RCC_PLLCFGR_PLLSRC_HSE (1UL << 22)
#define RCC_PLLCFGR_PLLQ_Pos   24

// RCC_CFGR bits
#define RCC_CFGR_SW_Msk      (0x3UL << 0)
#define RCC_CFGR_SW_PLL      (0x2UL << 0)
#define RCC_CFGR_SWS_Msk     (0x3UL << 2)
#define RCC_CFGR_SWS_PLL     (0x2UL << 2)
#define RCC_CFGR_HPRE_Pos    4    // AHB prescaler field
#define RCC_CFGR_HPRE_DIV1   (0x0UL << RCC_CFGR_HPRE_Pos)
#define RCC_CFGR_PPRE1_Pos   10   // APB1 (low-speed) prescaler field
#define RCC_CFGR_PPRE2_Pos   13   // APB2 (high-speed) prescaler field
#define RCC_CFGR_PPRE_DIV1   0x0UL
#define RCC_CFGR_PPRE_DIV2   0x4UL

// RCC_AHB1ENR bits
#define RCC_AHB1ENR_GPIOAEN  (1UL << 0)
#define RCC_AHB1ENR_GPIOBEN  (1UL << 1)
#define RCC_AHB1ENR_GPIOCEN  (1UL << 2)

// RCC_APB1ENR bits
#define RCC_APB1ENR_TIM2EN   (1UL << 0)
#define RCC_APB1ENR_TIM3EN   (1UL << 1)

// RCC_APB2ENR bits
#define RCC_APB2ENR_TIM1EN   (1UL << 0)
#define RCC_APB2ENR_USART1EN (1UL << 4)
#define RCC_APB2ENR_SYSCFGEN (1UL << 14)

// ============================================================================
// FLASH interface (F4: sector erase, distinct register layout from F1/H5)
// ============================================================================

typedef struct {
  volatile uint32_t ACR;      // 0x00 Access control register
  volatile uint32_t KEYR;     // 0x04 Key register
  volatile uint32_t OPTKEYR;  // 0x08 Option key register
  volatile uint32_t SR;       // 0x0C Status register
  volatile uint32_t CR;       // 0x10 Control register
  volatile uint32_t OPTCR;    // 0x14 Option control register
} FLASH_TypeDef;

#define FLASH_BASE  0x40023C00UL
#define FLASH  ((FLASH_TypeDef*)FLASH_BASE)

// FLASH_ACR bits
#define FLASH_ACR_LATENCY_Msk  (0xFUL << 0)
#define FLASH_ACR_LATENCY_3WS  (0x3UL << 0)
#define FLASH_ACR_PRFTEN       (1UL << 8)
#define FLASH_ACR_ICEN         (1UL << 9)
#define FLASH_ACR_DCEN         (1UL << 10)

// FLASH_SR bits
#define FLASH_SR_EOP      (1UL << 0)
#define FLASH_SR_OPERR    (1UL << 1)
#define FLASH_SR_WRPERR   (1UL << 4)
#define FLASH_SR_PGAERR   (1UL << 5)
#define FLASH_SR_PGPERR   (1UL << 6)
#define FLASH_SR_PGSERR   (1UL << 7)
#define FLASH_SR_BSY      (1UL << 16)

// FLASH_CR bits
#define FLASH_CR_PG        (1UL << 0)
#define FLASH_CR_SER       (1UL << 1)
#define FLASH_CR_MER       (1UL << 2)
#define FLASH_CR_SNB_Pos   3         // sector number field, bits 3-6
#define FLASH_CR_PSIZE_Pos 8         // program size field, bits 8-9
#define FLASH_CR_PSIZE_WORD (0x2UL << FLASH_CR_PSIZE_Pos)
#define FLASH_CR_STRT      (1UL << 16)
#define FLASH_CR_LOCK      (1UL << 31)

// ============================================================================
// SYSCFG (GPIO-to-EXTI line mapping; F4 keeps this on APB2, same idea as H5's
// SYSCFG but a different base address / enable bit)
// ============================================================================

typedef struct {
  uint32_t RESERVED0;           // 0x00 MEMRMP
  volatile uint32_t PMC;        // 0x04
  volatile uint32_t EXTICR[4];  // 0x08-0x14
} SYSCFG_TypeDef;

#define SYSCFG_BASE  0x40013800UL
#define SYSCFG  ((SYSCFG_TypeDef*)SYSCFG_BASE)

#define SYSCFG_EXTICR_PA  0x0UL
#define SYSCFG_EXTICR_PB  0x1UL
#define SYSCFG_EXTICR_PC  0x2UL

// ============================================================================
// EXTI (classic single-pending-register model, same shape as stm32f103)
// ============================================================================

typedef struct {
  volatile uint32_t IMR;    // Interrupt mask register
  volatile uint32_t EMR;    // Event mask register
  volatile uint32_t RTSR;   // Rising trigger selection register
  volatile uint32_t FTSR;   // Falling trigger selection register
  volatile uint32_t SWIER;  // Software interrupt event register
  volatile uint32_t PR;     // Pending register (write-1-to-clear)
} EXTI_TypeDef;

#define EXTI_BASE  0x40013C00UL
#define EXTI  ((EXTI_TypeDef*)EXTI_BASE)

// ============================================================================
// TIM (Timers) - TIM1 is APB2 advanced-control, TIM2/TIM3 are APB1
// general-purpose. Register shape identical to stm32f103/h523's TIM_TypeDef;
// only base addresses differ per family.
// ============================================================================

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

// TIM1 base is 0x40010000 on F4 - NOT F1/H5's 0x40012C00 (see file header note).
#define TIM1_BASE  0x40010000UL
#define TIM2_BASE  0x40000000UL
#define TIM3_BASE  0x40000400UL

#define TIM1   ((TIM_TypeDef*)TIM1_BASE)
#define TIM2   ((TIM_TypeDef*)TIM2_BASE)
#define TIM3   ((TIM_TypeDef*)TIM3_BASE)

// TIM_CR1 bits
#define TIM_CR1_CEN      (1UL << 0)
#define TIM_CR1_ARPE     (1UL << 7)

// TIM_DIER bits
#define TIM_DIER_UIE     (1UL << 0)
#define TIM_DIER_CC1IE   (1UL << 1)

// TIM_SR bits
#define TIM_SR_UIF       (1UL << 0)
#define TIM_SR_CC1IF     (1UL << 1)

// TIM_EGR bits
#define TIM_EGR_UG       (1UL << 0)

// TIM_CCMR1 bits
#define TIM_CCMR1_OC1PE  (1UL << 3)

// TIM_CCER bits
#define TIM_CCER_CC1E    (1UL << 0)

// TIM_BDTR bits (TIM1 advanced-control timer only - without MOE the OC1
// output stays disconnected even with CCER.CC1E set, same lesson as
// stm32f103/stm32h523 - CONTRACTS.md porting-checklist Step 3 BDTR.MOE note)
#define TIM_BDTR_MOE     (1UL << 15)

// ============================================================================
// USART - F4 uses the classic SR/DR model (like F1), NOT H5's ISR/RDR/TDR.
// ============================================================================

typedef struct {
  volatile uint32_t SR;       // Status register
  volatile uint32_t DR;       // Data register
  volatile uint32_t BRR;      // Baud rate register
  volatile uint32_t CR1;      // Control register 1
  volatile uint32_t CR2;      // Control register 2
  volatile uint32_t CR3;      // Control register 3
  volatile uint32_t GTPR;     // Guard time and prescaler register
} USART_TypeDef;

#define USART1_BASE  0x40011000UL
#define USART1   ((USART_TypeDef*)USART1_BASE)

// USART_SR bits
#define USART_SR_RXNE    (1UL << 5)
#define USART_SR_TXE     (1UL << 7)

// USART_CR1 bits
#define USART_CR1_RE     (1UL << 2)
#define USART_CR1_TE     (1UL << 3)
#define USART_CR1_RXNEIE (1UL << 5)
#define USART_CR1_TXEIE  (1UL << 7)
#define USART_CR1_UE     (1UL << 13)

// ============================================================================
// SYSTICK
// ============================================================================

typedef struct {
  volatile uint32_t CTRL;
  volatile uint32_t LOAD;
  volatile uint32_t VAL;
  volatile uint32_t CALIB;
} SysTick_Type;

#define SysTick  ((SysTick_Type*)0xE000E010UL)

// ============================================================================
// DWT (cycle counter) + CoreDebug (DWT enable) - standard on every Cortex-M
// with a debug unit (M3/M4/M33)
// ============================================================================

typedef struct {
  volatile uint32_t CTRL;
  volatile uint32_t CYCCNT;
} DWT_Type;

#define DWT  ((DWT_Type*)0xE0001000UL)
#define DWT_CTRL_CYCCNTENA_Msk  (1UL << 0)

typedef struct {
  volatile uint32_t DHCSR;
  volatile uint32_t DCRSR;
  volatile uint32_t DCRDR;
  volatile uint32_t DEMCR;
} CoreDebug_Type;

#define CoreDebug  ((CoreDebug_Type*)0xE000EDF0UL)
#define CoreDebug_DEMCR_TRCENA_Msk  (1UL << 24)

// ============================================================================
// NVIC
// ============================================================================

typedef struct {
  volatile uint32_t ISER[8];
  uint32_t RESERVED0[24];
  volatile uint32_t ICER[8];
  uint32_t RESERVED1[24];
  volatile uint32_t ISPR[8];
  uint32_t RESERVED2[24];
  volatile uint32_t ICPR[8];
  uint32_t RESERVED3[24];
  volatile uint32_t IABR[8];
  uint32_t RESERVED4[56];
  volatile uint8_t  IP[240];
} NVIC_Type;

#define NVIC  ((NVIC_Type*)0xE000E100UL)

// IRQ numbers for STM32F411 (verified this session against the published
// F411 CMSIS vector table for the entries actually used by this port - see
// file header note. Numbering matches the general F4-family layout).
typedef enum {
  EXTI0_IRQn       = 6,
  EXTI1_IRQn       = 7,
  EXTI2_IRQn       = 8,
  EXTI3_IRQn       = 9,
  EXTI4_IRQn       = 10,
  EXTI9_5_IRQn     = 23,
  TIM1_BRK_TIM9_IRQn     = 24,
  TIM1_UP_TIM10_IRQn     = 25,
  TIM1_TRG_COM_TIM11_IRQn = 26,
  TIM1_CC_IRQn     = 27,
  TIM2_IRQn        = 28,
  TIM3_IRQn        = 29,
  USART1_IRQn      = 37,
  USART2_IRQn      = 38,
  EXTI15_10_IRQn   = 40
} IRQn_Type;

static inline void NVIC_EnableIRQ(IRQn_Type IRQn) {
  NVIC->ISER[(uint32_t)IRQn >> 5] = (1UL << ((uint32_t)IRQn & 0x1F));
}

static inline void NVIC_DisableIRQ(IRQn_Type IRQn) {
  NVIC->ICER[(uint32_t)IRQn >> 5] = (1UL << ((uint32_t)IRQn & 0x1F));
}

static inline void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority) {
  NVIC->IP[(uint32_t)IRQn] = (uint8_t)(priority << 4);
}

// ============================================================================
// IWDG - Independent Watchdog (identical register layout across STM32
// families - common/stm32/stm32_watchdog.c owns the implementation)
// ============================================================================

typedef struct {
  volatile uint32_t KR;
  volatile uint32_t PR;
  volatile uint32_t RLR;
  volatile uint32_t SR;
} IWDG_TypeDef;

#define IWDG_BASE   0x40003000UL
#define IWDG        ((IWDG_TypeDef*)IWDG_BASE)

#endif // STM32F411_REGS_H
