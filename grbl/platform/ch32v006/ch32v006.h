/*
  ch32v006.h - CH32V006 clean-room register definitions
  Part of Grbl

  Written from scratch against the publicly available CH32V00X Reference
  Manual V1.5 (wch-ic.com, covers CH32V002/004/005/006/007) and the
  CH32V006 datasheet - register FACTS transcribed from documentation,
  NOT copied from any WCH-licensed header (EVT, ch32v00x.h, etc).
  Modeled in shape on ../samd21/samd21.h: a minimal struct-per-peripheral
  header, not a full vendor CMSIS pack.

  VERIFICATION STATUS (Phase 4 Step 3 re-verification pass - supersedes
  the M1-M3 "best-effort placeholder" state):
  - Peripheral base addresses, PFIC/STK register offsets, the interrupt
    vector table, RCC/FLASH/GPIO/AFIO/EXTI/USART/TIM bit positions below
    were all read out of CH32V00X RM V1.5 directly (section numbers cited
    inline). Items that could NOT be verified are marked UNVERIFIED
    individually - the blanket "everything here is a guess" caveat from
    M1-M3 no longer applies.
  - Cross-check: Zephyr's community ch32v006.dtsi (Apache-2.0) agrees on
    every base address and IRQ number used by this port.
*/

#ifndef CH32V006_H
#define CH32V006_H

#include <stdint.h>
#include <stddef.h>

// ============================================================================
// MEMORY MAP (RM figure 1-8)
// ============================================================================
// Code flash physically lives at 0x08000000 and is aliased at 0x00000000
// (boot configuration). Code links/runs at the 0x0 alias (script.ld);
// the FLASH controller's ADDR register and programming pointer writes use
// the PHYSICAL 0x08000000 address (RM 18.4.5 example uses 0x08000000).

#define FLASH_BASE             0x00000000UL   // execution alias
#define FLASH_PHYS_BASE        0x08000000UL   // physical main-flash base (programming)
#define SRAM_BASE              0x20000000UL
#define PERIPH_BASE            0x40000000UL

// ============================================================================
// PERIPHERAL BASE ADDRESSES (RM register lists, cited per block below)
// ============================================================================

#define TIM2_BASE              (PERIPH_BASE + 0x00000UL)  // RM 12: R16_TIM2_* at 0x40000000
#define TIM3_BASE              (PERIPH_BASE + 0x00800UL)  // RM 13 "streamlined timer" - NO interrupt output
#define USART2_BASE            (PERIPH_BASE + 0x04400UL)
#define AFIO_BASE              (PERIPH_BASE + 0x10000UL)  // RM 7.3.2: EXTICR at 0x40010008
#define EXTI_BASE              (PERIPH_BASE + 0x10400UL)  // RM 6.5.1
#define GPIOA_BASE             (PERIPH_BASE + 0x10800UL)  // RM 7.3.1 (8 pins)
#define GPIOB_BASE             (PERIPH_BASE + 0x10C00UL)  // 7 pins bonded (PB0-PB6)
#define GPIOC_BASE             (PERIPH_BASE + 0x11000UL)  // 8 pins
#define GPIOD_BASE             (PERIPH_BASE + 0x11400UL)  // 8 pins
#define TIM1_BASE              (PERIPH_BASE + 0x12C00UL)  // RM 11: R16_TIM1_* at 0x40012C00
#define USART1_BASE            (PERIPH_BASE + 0x13800UL)  // RM 14: 0x40013800
#define RCC_BASE               (PERIPH_BASE + 0x21000UL)  // RM 3.4
#define FLASH_R_BASE           (PERIPH_BASE + 0x22000UL)  // RM 18.3

// QingKe V2 core peripherals (RM 6.5.2 / 6.5.4 - address-verified)
// PFIC_BASE now comes from common/wch/wch_pfic.h (same value, 0xE000E000UL).
#define STK_BASE               0xE000F000UL

// ============================================================================
// GPIO (RM 7.3.1). V00X ports are 8-pin wide: there is NO CFGHR - CFGLR
// covers pins 0-7 and offset 0x04 is reserved. Per-pin nibble in CFGLR:
//   [3:2] CNF, [1] reserved, [0] MODE   (DIFFERENT from STM32F1: MODE is
//   a single bit here - 1 = output (max 30MHz), 0 = input; F1's 2-bit
//   speed field does not exist)
//   input  (MODE=0): CNF 00 analog, 01 floating, 10 pull-up/down
//                    (pull direction via OUTDR bit: 1 = up, 0 = down),
//                    11 reserved
//   output (MODE=1): CNF 00 GP push-pull, 01 GP open-drain,
//                    10 AF push-pull, 11 AF open-drain
// ============================================================================

typedef struct {
  volatile uint32_t CFGLR;   // 0x00 Port configuration (pins 0-7)
  uint32_t RESERVED0;        // 0x04 (no CFGHR on V00X - 8-pin ports)
  volatile uint32_t INDR;    // 0x08 Input data (bits 0-7)
  volatile uint32_t OUTDR;   // 0x0C Output data (bits 0-7; pull select on CNF=10 inputs)
  volatile uint32_t BSHR;    // 0x10 BS[7:0] set, BR[23:16] reset
  volatile uint32_t BCR;     // 0x14 Bit reset only
  volatile uint32_t LCKR;    // 0x18 Config lock
} GPIO_TypeDef;

#define GPIOA   ((GPIO_TypeDef*)GPIOA_BASE)
#define GPIOB   ((GPIO_TypeDef*)GPIOB_BASE)
#define GPIOC   ((GPIO_TypeDef*)GPIOC_BASE)
#define GPIOD   ((GPIO_TypeDef*)GPIOD_BASE)

// Whole 4-bit config nibbles (CNF<<2 | MODE) - see table above
#define GPIO_CFG_IN_ANALOG      0x0u
#define GPIO_CFG_OUT_PP         0x1u  // GP push-pull output, 30MHz
#define GPIO_CFG_IN_FLOATING    0x4u
#define GPIO_CFG_OUT_OD         0x5u
#define GPIO_CFG_IN_PULL        0x8u  // + OUTDR bit: 1 = pull-up, 0 = pull-down
#define GPIO_CFG_OUT_AF_PP      0x9u  // alternate-function push-pull (USART TX, TIM1 CH1)

// AFIO (RM 7.3.2) - registers start at offset 0x08
typedef struct {
  uint32_t RESERVED0[2];     // 0x00-0x04
  volatile uint32_t EXTICR;  // 0x08 EXTI line source select: 2 bits/line x 8 lines
                             //      00=PA 01=PB 10=PC 11=PD (RM 7.3.2.1)
  volatile uint32_t PCFR1;   // 0x0C Remap register 1 (RM 7.3.2.2)
} AFIO_TypeDef;

#define AFIO ((AFIO_TypeDef*)AFIO_BASE)

// PCFR1 fields this port uses (RM 7.3.2.2 bit layout:
// TIM2_RM[1:0]@15:14, TIM1_RM[3:0]@13:10, USART1_RM[3:0]@9:6,
// I2C1_RM[2:0]@5:3, SPI1_RM[2:0]@2:0)
#define AFIO_PCFR1_TIM1_RM_Pos    10
#define AFIO_PCFR1_TIM1_RM_Msk    (0xFUL << AFIO_PCFR1_TIM1_RM_Pos)
#define AFIO_PCFR1_USART1_RM_Pos  6
#define AFIO_PCFR1_USART1_RM_Msk  (0xFUL << AFIO_PCFR1_USART1_RM_Pos)

// EXTI (RM 6.5.1) - 10 lines: 0-7 = GPIO pins 0-7, 8/9 internal (PVD/AWU)
typedef struct {
  volatile uint32_t INTENR;  // 0x00 Interrupt enable
  volatile uint32_t EVENR;   // 0x04 Event enable
  volatile uint32_t RTENR;   // 0x08 Rising trigger enable
  volatile uint32_t FTENR;   // 0x0C Falling trigger enable
  volatile uint32_t SWIEVR;  // 0x10 Software interrupt event
  volatile uint32_t INTFR;   // 0x14 IF[9:0], write-1-to-clear (RM 6.5.1.6)
} EXTI_TypeDef;

#define EXTI ((EXTI_TypeDef*)EXTI_BASE)

// ============================================================================
// RCC (RM 3.4)
// ============================================================================

typedef struct {
  volatile uint32_t CTLR;       // 0x00 Clock control
  volatile uint32_t CFGR0;      // 0x04 Clock configuration
  volatile uint32_t INTR;       // 0x08 Clock interrupt
  volatile uint32_t PB2PRSTR;   // 0x0C PB2 (APB2-analog) peripheral reset
  volatile uint32_t PB1PRSTR;   // 0x10 PB1 peripheral reset
  volatile uint32_t HBPCENR;    // 0x14 HB peripheral clock enable (DMA/SRAM)
  volatile uint32_t PB2PCENR;   // 0x18 PB2 peripheral clock enable
  volatile uint32_t PB1PCENR;   // 0x1C PB1 peripheral clock enable
  uint32_t RESERVED0;           // 0x20
  volatile uint32_t RSTSCKR;    // 0x24 Control/status (reset flags, LSI)
} RCC_TypeDef;

#define RCC ((RCC_TypeDef*)RCC_BASE)

// RCC_CTLR bits (RM 3.4.1)
#define RCC_CTLR_HSION          (1UL << 0)
#define RCC_CTLR_HSIRDY         (1UL << 1)
#define RCC_CTLR_PLLON          (1UL << 24)
#define RCC_CTLR_PLLRDY         (1UL << 25)

// RCC_CFGR0 bits (RM 3.4.2). PLL is a FIXED x2 multiplier (clock-tree
// figure: HSI/HSE -> "*2" -> PLLCLK, 48MHz max) - there is no PLLMUL
// field on V00X. HSI = 24 MHz (RM 3.3.2 "internal 24MHz RC oscillator").
// TRAP (found this session): HPRE[3:0] RESET VALUE is 0b0010 = SYSCLK/3,
// NOT /1 - clock init MUST clear HPRE or HCLK is 3x slower than F_CPU.
#define RCC_CFGR0_SW_Pos        0
#define RCC_CFGR0_SW_Msk        (0x3UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SW_HSI        (0x0UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SW_PLL        (0x2UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SWS_Pos       2
#define RCC_CFGR0_SWS_Msk       (0x3UL << RCC_CFGR0_SWS_Pos)
#define RCC_CFGR0_SWS_PLL       (0x2UL << RCC_CFGR0_SWS_Pos)
#define RCC_CFGR0_HPRE_Pos      4
#define RCC_CFGR0_HPRE_Msk      (0xFUL << RCC_CFGR0_HPRE_Pos)   // 0000 = prescaler off
#define RCC_CFGR0_PLLSRC        (1UL << 16)   // 0 = HSI (undivided), 1 = HSE

// RCC_PB2PCENR bits (RM 3.4.7)
#define RCC_PB2PCENR_AFIOEN     (1UL << 0)
#define RCC_PB2PCENR_IOPAEN     (1UL << 2)
#define RCC_PB2PCENR_IOPBEN     (1UL << 3)
#define RCC_PB2PCENR_IOPCEN     (1UL << 4)
#define RCC_PB2PCENR_IOPDEN     (1UL << 5)
#define RCC_PB2PCENR_TIM1EN     (1UL << 11)
#define RCC_PB2PCENR_USART1EN   (1UL << 14)

// RCC_PB1PCENR bits (RM 3.4.8). NOTE: TIM3EN is bit 2, not bit 1.
#define RCC_PB1PCENR_TIM2EN     (1UL << 0)
#define RCC_PB1PCENR_TIM3EN     (1UL << 2)

// ============================================================================
// FLASH controller (RM 18.3). Main flash: 62KB, 256-byte pages (0-247).
// Programming model: fast page program/erase ONLY (no F1-style halfword
// PG bit) - unlock LOCK (KEYR) then FLOCK (MODEKEYR), FTPG/FTER + STRT.
// ============================================================================

typedef struct {
  volatile uint32_t ACTLR;     // 0x00 LATENCY[1:0]
  volatile uint32_t KEYR;      // 0x04 FPEC key
  volatile uint32_t OBKEYR;    // 0x08 Option byte key
  volatile uint32_t STATR;     // 0x0C Status
  volatile uint32_t CTLR;      // 0x10 Control
  volatile uint32_t ADDR;      // 0x14 Address (physical 0x08xxxxxx)
  uint32_t RESERVED0;          // 0x18
  volatile uint32_t OBR;       // 0x1C Option byte
  volatile uint32_t WPR;       // 0x20 Write protection
  volatile uint32_t MODEKEYR;  // 0x24 Fast-mode key (RM 18.3.9)
} FLASH_TypeDef;

#define FLASH ((FLASH_TypeDef*)FLASH_R_BASE)

// ACTLR (RM 18.3.1): 00 <=15MHz, 01 <=24MHz, 10 <=48MHz
#define FLASH_ACTLR_LATENCY_Msk  (0x3UL << 0)
#define FLASH_ACTLR_LATENCY_0    (0x0UL << 0)
#define FLASH_ACTLR_LATENCY_1    (0x1UL << 0)
#define FLASH_ACTLR_LATENCY_2    (0x2UL << 0)   // required at 48 MHz

// STATR (RM 18.3.4)
#define FLASH_STATR_BSY          (1UL << 0)
#define FLASH_STATR_WRPRTERR     (1UL << 4)   // write 1 to clear
#define FLASH_STATR_EOP          (1UL << 5)   // write 1 to clear

// CTLR (RM 18.3.5)
#define FLASH_CTLR_PER           (1UL << 1)   // 1K sector erase
#define FLASH_CTLR_MER           (1UL << 2)
#define FLASH_CTLR_OBER          (1UL << 5)
#define FLASH_CTLR_STRT          (1UL << 6)
#define FLASH_CTLR_LOCK          (1UL << 7)
#define FLASH_CTLR_FLOCK         (1UL << 15)  // fast-mode lock
#define FLASH_CTLR_FTPG          (1UL << 16)  // fast page (256B) program
#define FLASH_CTLR_FTER          (1UL << 17)  // fast page (256B) erase
#define FLASH_CTLR_BUFLOAD       (1UL << 18)
#define FLASH_CTLR_BUFRST        (1UL << 19)

#define FLASH_KEY1               0x45670123UL
#define FLASH_KEY2               0xCDEF89ABUL

#define FLASH_PAGE_SIZE_BYTES    256u

// ============================================================================
// USART (RM 14) - F1-shape SR/DR/BRR/CR1..., WCH names. Baud (RM 14.3):
// baud = HCLK / (16 * USARTDIV), BRR = mantissa[15:4] + fraction[3:0]/16.
// USART1 default pin map (RM table 7-10, USART1_RM=0000): TX=PD5, RX=PD6.
// ============================================================================

typedef struct {
  volatile uint32_t STATR;  // 0x00 Status
  volatile uint32_t DATAR;  // 0x04 Data (read clears RXNE, write clears TXE)
  volatile uint32_t BRR;    // 0x08 Baud rate
  volatile uint32_t CTLR1;  // 0x0C Control 1
  volatile uint32_t CTLR2;  // 0x10 Control 2
  volatile uint32_t CTLR3;  // 0x14 Control 3
  volatile uint32_t GPR;    // 0x18 Guard time / prescaler
} USART_TypeDef;

#define USART1 ((USART_TypeDef*)USART1_BASE)

// STATR bits (RM 14.8.1)
#define USART_STATR_RXNE       (1UL << 5)
#define USART_STATR_TC         (1UL << 6)
#define USART_STATR_TXE        (1UL << 7)
// CTLR1 bits (RM 14.8.4)
#define USART_CTLR1_RE         (1UL << 2)
#define USART_CTLR1_TE         (1UL << 3)
#define USART_CTLR1_RXNEIE     (1UL << 5)
#define USART_CTLR1_TCIE       (1UL << 6)
#define USART_CTLR1_TXEIE      (1UL << 7)
#define USART_CTLR1_UE         (1UL << 13)

// ============================================================================
// TIM1 (advanced, RM 11) / TIM2 (general purpose, RM 12) - 16-bit, F1-shape
// register order confirmed against RM register lists (offsets identical for
// both; RPTCR/BDTR are TIM1-only, reserved on TIM2).
// TIM3 (RM 13) is a "streamlined" compare-only timer with NO interrupt
// output - it is deliberately NOT given a macro here so nobody wires an ISR
// to it by mistake (this port's pulse-reset timer is the core STK instead).
// ============================================================================

typedef struct {
  volatile uint32_t CTLR1;     // 0x00
  volatile uint32_t CTLR2;     // 0x04
  volatile uint32_t SMCFGR;    // 0x08
  volatile uint32_t DMAINTENR; // 0x0C  (DIER)
  volatile uint32_t INTFR;     // 0x10  (SR) - UIF etc, write-0-to-clear (RW0)
  volatile uint32_t SWEVGR;    // 0x14  (EGR)
  volatile uint32_t CHCTLR1;   // 0x18  (CCMR1)
  volatile uint32_t CHCTLR2;   // 0x1C  (CCMR2)
  volatile uint32_t CCER;      // 0x20
  volatile uint32_t CNT;       // 0x24
  volatile uint32_t PSC;       // 0x28
  volatile uint32_t ATRLR;     // 0x2C  (ARR) - reset value 0xFFFF
  volatile uint32_t RPTCR;     // 0x30  (TIM1 only)
  volatile uint32_t CH1CVR;    // 0x34  (CCR1)
  volatile uint32_t CH2CVR;    // 0x38
  volatile uint32_t CH3CVR;    // 0x3C
  volatile uint32_t CH4CVR;    // 0x40
  volatile uint32_t BDTR;      // 0x44  (TIM1 only; TIM2 has DTCR here)
  volatile uint32_t DMACFGR;   // 0x48
  volatile uint32_t DMAADR;    // 0x4C
} TIM_TypeDef;

#define TIM1 ((TIM_TypeDef*)TIM1_BASE)
#define TIM2 ((TIM_TypeDef*)TIM2_BASE)

#define TIM_CTLR1_CEN          (1UL << 0)
#define TIM_DMAINTENR_UIE      (1UL << 0)
#define TIM_INTFR_UIF          (1UL << 0)
#define TIM_SWEVGR_UG          (1UL << 0)
#define TIM_CHCTLR1_OC1PE      (1UL << 3)
#define TIM_CHCTLR1_OC1M_PWM1  (0x6UL << 4)   // OC1M[2:0]=110 PWM mode 1 (RM 11.4.7)
#define TIM_CCER_CC1E          (1UL << 0)
#define TIM_BDTR_MOE           (1UL << 15)

// ============================================================================
// PFIC (RM 6.5.2) - offsets confirmed against the RM register list.
// Two 32-bit words cover all sources (<= 64 IRQs on QingKe V2).
//
// EXTRACTED (Phase 6 rolling #4, Part A): the struct + enable/disable
// helpers moved to common/wch/wch_pfic.h verbatim (same offsets, same
// fence.i) once the CH570 recon proved QingKe V3C shares this exact
// layout, differing only in IRQ-bank width (WCH_PFIC_IRQ_WORDS below) -
// see that file's header for the byte-identity gate this extraction was
// held to.
// ============================================================================

#define WCH_PFIC_IRQ_WORDS 2
#include "../common/wch/wch_pfic.h"

// ============================================================================
// STK - QingKe V2 SysTick (RM 6.5.4). 32-bit up-counter + 32-bit compare.
// SR.CNTIF is WRITE-0-TO-CLEAR (RW0) - the opposite polarity of most W1C
// flag registers on this chip; `STK->SR = 0` is the whole clear idiom.
// ============================================================================

typedef struct {
  volatile uint32_t CTLR;    // 0x00 Control
  volatile uint32_t SR;      // 0x04 CNTIF (bit 0, write-0-clear)
  volatile uint32_t CNTL;    // 0x08 Counter (32-bit)
  uint32_t RESERVED0;        // 0x0C (CNTH on 64-bit QingKe cores - absent on V2)
  volatile uint32_t CMPLR;   // 0x10 Compare (32-bit)
  uint32_t RESERVED1;        // 0x14 (CMPHR - absent on V2)
} STK_TypeDef;

#define STK ((STK_TypeDef*)STK_BASE)

#define STK_CTLR_STE        (1UL << 0)   // counter enable
#define STK_CTLR_STIE       (1UL << 1)   // interrupt enable
#define STK_CTLR_STCLK      (1UL << 2)   // 0 = HCLK/8, 1 = HCLK
#define STK_CTLR_STRE       (1UL << 3)   // auto-reload to 0 on compare
#define STK_CTLR_SWIE       (1UL << 31)  // software interrupt trigger

// ============================================================================
// IRQ NUMBERS (RM table 6-1, CH32V00X series vector table - VERIFIED).
// 25 peripheral channels + 4 kernel channels; entry address = number * 4.
// ============================================================================

typedef enum {
  SysTick_IRQn      = 12,   // STK compare - this port's pulse-reset timer
  SW_IRQn           = 14,
  WWDG_IRQn         = 16,
  PVD_IRQn          = 17,
  FLASH_IRQn        = 18,
  RCC_IRQn          = 19,
  EXTI7_0_IRQn      = 20,   // ALL GPIO lines 0-7 share this one vector
  AWU_IRQn          = 21,
  DMA1_CH1_IRQn     = 22,
  DMA1_CH2_IRQn     = 23,
  DMA1_CH3_IRQn     = 24,
  DMA1_CH4_IRQn     = 25,
  DMA1_CH5_IRQn     = 26,
  DMA1_CH6_IRQn     = 27,
  DMA1_CH7_IRQn     = 28,
  ADC_IRQn          = 29,
  I2C1_EV_IRQn      = 30,
  I2C1_ER_IRQn      = 31,
  USART1_IRQn       = 32,
  SPI1_IRQn         = 33,
  TIM1_BRK_IRQn     = 34,
  TIM1_UP_IRQn      = 35,
  TIM1_TRG_IRQn     = 36,
  TIM1_CC_IRQn      = 37,
  TIM2_IRQn         = 38,
  USART2_IRQn       = 39,
  OPCM_IRQn         = 40,
  // NOTE: no TIM3 vector exists - RM 13's streamlined timer has no
  // interrupt line at all. Highest vector number = 40.
} IRQn_Type;

#define PFIC_VECTOR_COUNT   41   // vectors 0..40 per RM table 6-1

// PFIC_EnableIRQ/PFIC_DisableIRQ (with the RM-mandated fence.i on disable)
// now live in common/wch/wch_pfic.h (Phase 6 rolling #4, Part A extraction)
// - IRQn_Type above converts implicitly to that header's uint32_t parameter.

#endif // CH32V006_H
