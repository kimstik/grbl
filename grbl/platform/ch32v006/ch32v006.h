/*
  ch32v006.h - CH32V006 clean-room register definitions
  Part of Grbl

  Written from scratch against publicly documented WCH QingKe/CH32V00x
  peripheral facts (address map conventions shared across the V003/V005/
  V006/V007 family, and the well-known QingKe V2 PFIC/STK core-peripheral
  addresses) - NOT copied from any WCH-licensed header (EvtBoard, EVT,
  ch32v00x.h, etc). Modeled in shape on ../samd21/samd21.h: a minimal stub
  struct-per-peripheral header, not a full vendor CMSIS pack.

  VERIFICATION STATUS (read before trusting a number below):
  - GPIO/RCC/FLASH/AFIO/EXTI/USART1/TIM1/TIM2 base addresses: this is the
    STM32F1-style layout WCH's QingKe V00x line clones almost verbatim
    (public knowledge, matches every open community port of CH32V003 -
    e.g. the ch32fun/ch32v003fun family of clean-room bring-up projects).
    CH32V006-specific offsets are NOT independently re-verified against a
    real CH32V006 TRM in this session - treat every *_BASE below as
    PLAUSIBLE, not silicon-confirmed. GAP (see CONTRACTS.md's new RISC-V
    section, folded back from this port).
  - PFIC_BASE (0xE000E000) / STK_BASE (0xE000F000): well-known QingKe V2
    core-peripheral addresses (same across the whole QingKe V2 family per
    public knowledge) - higher confidence than the AHB/APB peripheral
    offsets above, still UNVERIFIED against the real CH32V006 TRM.
  - PFIC/STK *register layout* (field-for-field) is a best-effort
    approximation good enough to compile against; nothing in this batch
    (Phase 4 M1-M3) touches these fields at runtime - Step 3+ (timers/
    serial/handlers) MUST re-verify every field here before relying on it.
*/

#ifndef CH32V006_H
#define CH32V006_H

#include <stdint.h>

// ============================================================================
// MEMORY MAP
// ============================================================================

#define FLASH_BASE            0x00000000UL
#define SRAM_BASE              0x20000000UL
#define PERIPH_BASE            0x40000000UL

// ============================================================================
// PERIPHERAL BASE ADDRESSES (STM32F1-style layout - GAP: see file header)
// ============================================================================

#define TIM2_BASE              (PERIPH_BASE + 0x00000UL)
#define TIM3_BASE              (PERIPH_BASE + 0x00400UL)  // UNVERIFIED offset (family convention guess)
#define AFIO_BASE              (PERIPH_BASE + 0x10000UL)
#define EXTI_BASE              (PERIPH_BASE + 0x10400UL)
#define GPIOA_BASE             (PERIPH_BASE + 0x10800UL)
#define GPIOB_BASE             (PERIPH_BASE + 0x10C00UL)  // UNVERIFIED: may not be bonded out on this package
#define GPIOC_BASE             (PERIPH_BASE + 0x11000UL)
#define GPIOD_BASE             (PERIPH_BASE + 0x11400UL)
#define USART1_BASE            (PERIPH_BASE + 0x13800UL)
#define TIM1_BASE              (PERIPH_BASE + 0x12C00UL)
#define RCC_BASE               (PERIPH_BASE + 0x21000UL)
#define FLASH_R_BASE           (PERIPH_BASE + 0x22000UL)

// QingKe V2 core peripherals (higher-confidence, still unverified - see header)
#define PFIC_BASE              0xE000E000UL
#define STK_BASE               0xE000F000UL

// ============================================================================
// GPIO - CFGLR/CFGHR (4 bits/pin: CNF1 CNF0 MODE1 MODE0), INDR, OUTDR,
// BSHR (atomic set/reset, upper 16 bits = reset - identical shape to
// STM32F1 BSRR), BCR (reset-only), LCKR. Same register SHAPE as
// stm32f103/regs.h's GPIO_TypeDef (WCH clones the F1 GPIO block) - named
// per the CH32 datasheet's own register names (CFGLR not CRL, etc), which
// is why this is a distinct struct rather than a #include of stm32f103's.
// ============================================================================

typedef struct {
  volatile uint32_t CFGLR;   // 0x00 Port configuration low  (pins 0-7)
  volatile uint32_t CFGHR;   // 0x04 Port configuration high (pins 8-15)
  volatile uint32_t INDR;    // 0x08 Port input data
  volatile uint32_t OUTDR;   // 0x0C Port output data
  volatile uint32_t BSHR;    // 0x10 Port bit set/reset (low16=set, high16=reset)
  volatile uint32_t BCR;     // 0x14 Port bit reset only
  volatile uint32_t LCKR;    // 0x18 Port config lock
} GPIO_TypeDef;

#define GPIOA   ((GPIO_TypeDef*)GPIOA_BASE)
#define GPIOB   ((GPIO_TypeDef*)GPIOB_BASE)
#define GPIOC   ((GPIO_TypeDef*)GPIOC_BASE)
#define GPIOD   ((GPIO_TypeDef*)GPIOD_BASE)

// CFGLR/CFGHR per-pin nibble encoding (shared with STM32F1 - WCH clone):
//   CNF[1:0] MODE[1:0], 4 bits per pin, pin N's nibble at bit (N%8)*4
//   Output:  MODE = 0b01 (10MHz) - CNF = 0b00 push-pull / 0b01 open-drain
//   Input:   MODE = 0b00          - CNF = 0b01 floating / 0b10 pull-up-down
// Pull direction for CNF=0b10 input is set by ODR: 1 = pull-up, 0 = pull-down.
#define GPIO_CFG_MODE_INPUT        0x0u
#define GPIO_CFG_MODE_OUTPUT_10MHZ 0x1u
#define GPIO_CFG_CNF_IN_ANALOG     0x0u
#define GPIO_CFG_CNF_IN_FLOATING   0x1u
#define GPIO_CFG_CNF_IN_PULL       0x2u
#define GPIO_CFG_CNF_OUT_PUSHPULL  0x0u
#define GPIO_CFG_CNF_OUT_OPENDRAIN 0x1u

// AFIO - Alternate Function I/O (remap + EXTI line source select)
typedef struct {
  volatile uint32_t ECR;       // 0x00 Event control
  volatile uint32_t PCFR1;     // 0x04 Remap register
  volatile uint32_t EXTICR[4]; // 0x08-0x14 EXTI line source select
} AFIO_TypeDef;

#define AFIO ((AFIO_TypeDef*)AFIO_BASE)

// EXTI - External interrupt/event controller (same shape as STM32F1)
typedef struct {
  volatile uint32_t INTENR;  // 0x00 Interrupt enable
  volatile uint32_t EVENR;   // 0x04 Event enable
  volatile uint32_t RTENR;   // 0x08 Rising trigger enable
  volatile uint32_t FTENR;   // 0x0C Falling trigger enable
  volatile uint32_t SWIEVR;  // 0x10 Software interrupt event
  volatile uint32_t INTFR;   // 0x14 Pending flags (write-1-to-clear)
} EXTI_TypeDef;

#define EXTI ((EXTI_TypeDef*)EXTI_BASE)

// ============================================================================
// RCC - Reset and Clock Control
// ============================================================================

typedef struct {
  volatile uint32_t CTLR;       // 0x00 Clock control (HSION/HSIRDY/PLLON/PLLRDY/...)
  volatile uint32_t CFGR0;      // 0x04 Clock configuration (SW/SWS/PLLSRC/HPRE/...)
  volatile uint32_t INTR;       // 0x08 Clock interrupt
  volatile uint32_t APB2PRSTR;  // 0x0C APB2 peripheral reset
  volatile uint32_t APB1PRSTR;  // 0x10 APB1 peripheral reset
  volatile uint32_t AHBPCENR;   // 0x14 AHB peripheral clock enable
  volatile uint32_t APB2PCENR;  // 0x18 APB2 peripheral clock enable
  volatile uint32_t APB1PCENR;  // 0x1C APB1 peripheral clock enable
} RCC_TypeDef;

#define RCC ((RCC_TypeDef*)RCC_BASE)

// RCC_CTLR bits
#define RCC_CTLR_HSION_Pos      0
#define RCC_CTLR_HSION          (1UL << RCC_CTLR_HSION_Pos)
#define RCC_CTLR_HSIRDY_Pos     1
#define RCC_CTLR_HSIRDY         (1UL << RCC_CTLR_HSIRDY_Pos)
#define RCC_CTLR_PLLON_Pos      24
#define RCC_CTLR_PLLON         (1UL << RCC_CTLR_PLLON_Pos)
#define RCC_CTLR_PLLRDY_Pos     25
#define RCC_CTLR_PLLRDY         (1UL << RCC_CTLR_PLLRDY_Pos)

// RCC_CFGR0 bits. UNVERIFIED for V006: the V003 family's PLL is a FIXED x2
// multiplier (no PLLMUL field) per public bring-up references; assumed
// identical here (48MHz = 24MHz HSI * 2). If V006 has a real PLLMUL field
// (plausible - it has far more flash/RAM than V003, may be a beefier
// clock tree), this whole SystemInit() clock path needs re-deriving - GAP.
#define RCC_CFGR0_SW_Pos        0
#define RCC_CFGR0_SW_Msk        (0x3UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SW_HSI        (0x0UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SW_PLL        (0x2UL << RCC_CFGR0_SW_Pos)
#define RCC_CFGR0_SWS_Pos       2
#define RCC_CFGR0_SWS_Msk       (0x3UL << RCC_CFGR0_SWS_Pos)
#define RCC_CFGR0_SWS_PLL       (0x2UL << RCC_CFGR0_SWS_Pos)
#define RCC_CFGR0_HPRE_Pos      4
#define RCC_CFGR0_HPRE_DIV1     (0x0UL << RCC_CFGR0_HPRE_Pos)
#define RCC_CFGR0_PLLSRC_Pos    16
#define RCC_CFGR0_PLLSRC        (1UL << RCC_CFGR0_PLLSRC_Pos)  // 0=HSI/2->PLL(V003 quirk, see below), 1=HSE

// RCC_*PCENR bits actually used by this port
#define RCC_APB2PCENR_AFIOEN_Pos   0
#define RCC_APB2PCENR_AFIOEN       (1UL << RCC_APB2PCENR_AFIOEN_Pos)
#define RCC_APB2PCENR_IOPAEN_Pos   2
#define RCC_APB2PCENR_IOPAEN       (1UL << RCC_APB2PCENR_IOPAEN_Pos)
#define RCC_APB2PCENR_IOPCEN_Pos   4
#define RCC_APB2PCENR_IOPCEN       (1UL << RCC_APB2PCENR_IOPCEN_Pos)
#define RCC_APB2PCENR_IOPDEN_Pos   5
#define RCC_APB2PCENR_IOPDEN       (1UL << RCC_APB2PCENR_IOPDEN_Pos)
#define RCC_APB2PCENR_USART1EN_Pos 14
#define RCC_APB2PCENR_USART1EN     (1UL << RCC_APB2PCENR_USART1EN_Pos)
#define RCC_APB2PCENR_TIM1EN_Pos   11
#define RCC_APB2PCENR_TIM1EN       (1UL << RCC_APB2PCENR_TIM1EN_Pos)
#define RCC_APB1PCENR_TIM2EN_Pos   0
#define RCC_APB1PCENR_TIM2EN       (1UL << RCC_APB1PCENR_TIM2EN_Pos)
#define RCC_APB1PCENR_TIM3EN_Pos   1
#define RCC_APB1PCENR_TIM3EN       (1UL << RCC_APB1PCENR_TIM3EN_Pos)

// ============================================================================
// FLASH controller - wait-state register. WCH names it ACTLR (not ACR);
// bit position of the LATENCY field is assumed identical to STM32F1 (bits
// [2:0]) - UNVERIFIED for V006's larger 62KB flash macro.
// ============================================================================

typedef struct {
  volatile uint32_t ACTLR;   // 0x00 Access control (latency)
  volatile uint32_t KEYR;    // 0x04 Flash key
  volatile uint32_t OBKEYR;  // 0x08 Option byte key
  volatile uint32_t STATR;   // 0x0C Status
  volatile uint32_t CTLR;    // 0x10 Control
  volatile uint32_t ADDR;    // 0x14 Address
  uint32_t RESERVED0;
  volatile uint32_t OBR;     // 0x1C Option byte
  volatile uint32_t WPR;     // 0x20 Write protection
} FLASH_TypeDef;

#define FLASH ((FLASH_TypeDef*)FLASH_R_BASE)

#define FLASH_ACTLR_LATENCY_Pos  0
#define FLASH_ACTLR_LATENCY_Msk  (0x7UL << FLASH_ACTLR_LATENCY_Pos)
#define FLASH_ACTLR_LATENCY_1    (0x1UL << FLASH_ACTLR_LATENCY_Pos)

// ============================================================================
// USART1 (STM32F1-shape - SR/DR/BRR/CR1/CR2/CR3/GTPR)
// ============================================================================

typedef struct {
  volatile uint32_t STATR;  // 0x00 Status
  volatile uint32_t DATAR;  // 0x04 Data
  volatile uint32_t BRR;    // 0x08 Baud rate
  volatile uint32_t CTLR1;  // 0x0C Control 1
  volatile uint32_t CTLR2;  // 0x10 Control 2
  volatile uint32_t CTLR3;  // 0x14 Control 3
  volatile uint32_t GPR;    // 0x18 Guard time / prescaler
} USART_TypeDef;

#define USART1 ((USART_TypeDef*)USART1_BASE)

#define USART_STATR_RXNE_Pos   5
#define USART_STATR_RXNE       (1UL << USART_STATR_RXNE_Pos)
#define USART_STATR_TXE_Pos    7
#define USART_STATR_TXE        (1UL << USART_STATR_TXE_Pos)
#define USART_CTLR1_RE_Pos     2
#define USART_CTLR1_RE         (1UL << USART_CTLR1_RE_Pos)
#define USART_CTLR1_TE_Pos     3
#define USART_CTLR1_TE         (1UL << USART_CTLR1_TE_Pos)
#define USART_CTLR1_RXNEIE_Pos 5
#define USART_CTLR1_RXNEIE     (1UL << USART_CTLR1_RXNEIE_Pos)
#define USART_CTLR1_TXEIE_Pos  7
#define USART_CTLR1_TXEIE      (1UL << USART_CTLR1_TXEIE_Pos)
#define USART_CTLR1_UE_Pos     13
#define USART_CTLR1_UE         (1UL << USART_CTLR1_UE_Pos)

// ============================================================================
// TIM1 (advanced, PWM+deadtime) / TIM2 (general purpose) - fields this
// port will eventually need; STM32F1-shape 16-bit timer.
// ============================================================================

typedef struct {
  volatile uint32_t CTLR1;   // 0x00
  volatile uint32_t CTLR2;   // 0x04
  volatile uint32_t SMCFGR;  // 0x08
  volatile uint32_t DMAINTENR; // 0x0C
  volatile uint32_t INTFR;   // 0x10
  volatile uint32_t SWEVGR;  // 0x14
  volatile uint32_t CHCTLR1; // 0x18
  volatile uint32_t CHCTLR2; // 0x1C
  volatile uint32_t CCER;    // 0x20
  volatile uint32_t CNT;     // 0x24
  volatile uint32_t PSC;     // 0x28
  volatile uint32_t ATRLR;   // 0x2C  (ARR)
  volatile uint32_t RPTCR;   // 0x30  (TIM1 repetition counter only)
  volatile uint32_t CH1CVR;  // 0x34
  volatile uint32_t CH2CVR;  // 0x38
  volatile uint32_t CH3CVR;  // 0x3C
  volatile uint32_t CH4CVR;  // 0x40
  volatile uint32_t BDTR;    // 0x44  (TIM1 only)
  volatile uint32_t DMACFGR; // 0x48
  volatile uint32_t DMAADR;  // 0x4C
} TIM_TypeDef;

#define TIM1 ((TIM_TypeDef*)TIM1_BASE)
#define TIM2 ((TIM_TypeDef*)TIM2_BASE)
#define TIM3 ((TIM_TypeDef*)TIM3_BASE)

#define TIM_CTLR1_CEN_Pos   0
#define TIM_CTLR1_CEN       (1UL << TIM_CTLR1_CEN_Pos)
#define TIM_DMAINTENR_UIE_Pos 0
#define TIM_DMAINTENR_UIE   (1UL << TIM_DMAINTENR_UIE_Pos)
#define TIM_INTFR_UIF_Pos   0
#define TIM_INTFR_UIF       (1UL << TIM_INTFR_UIF_Pos)
#define TIM_BDTR_MOE_Pos    15
#define TIM_BDTR_MOE        (1UL << TIM_BDTR_MOE_Pos)

// ============================================================================
// PFIC - Programmable Fast Interrupt Controller (QingKe V2 core peripheral,
// NOT the RISC-V standard CLINT/PLIC). Register shape below is a
// best-effort approximation sized for compiling this batch's code
// (nothing calls into it yet - see file header). Re-verify field-by-field
// before Step 3+ (real IRQ enable/priority) relies on it.
// ============================================================================

typedef struct {
  volatile uint32_t ISR[8];      // 0x000 Interrupt status (pending, RO)
  volatile uint32_t IPR[8];      // 0x020 Interrupt pending (RO, per-source)
  volatile uint32_t ITHRESDR;    // 0x040 Interrupt priority threshold
  uint32_t RESERVED0;
  volatile uint32_t CFGR;        // 0x048 Configuration (key-gated system control)
  volatile uint32_t GISR;        // 0x04C Global interrupt status
  uint32_t RESERVED1[8];
  volatile uint32_t IENR[8];     // 0x100 Interrupt enable (write-1-to-set)
  uint32_t RESERVED2[24];
  volatile uint32_t IRER[8];     // 0x180 Interrupt enable clear (write-1-to-clear)
  uint32_t RESERVED3[24];
  volatile uint32_t IPSR[8];     // 0x200 Interrupt pending set
  uint32_t RESERVED4[24];
  volatile uint32_t IPRR[8];     // 0x280 Interrupt pending clear
  uint32_t RESERVED5[24];
  volatile uint32_t IACTR[8];    // 0x300 Interrupt active status (RO)
  uint32_t RESERVED6[56];
  volatile uint8_t  IPRIOR[256]; // 0x400 Per-IRQ priority byte
  uint32_t RESERVED7[516];
  volatile uint32_t SCTLR;       // 0xD10 System control (SLEEPONEXIT/SEVONPEND/SYSRESET/...)
} PFIC_TypeDef;

#define PFIC ((PFIC_TypeDef*)PFIC_BASE)

// ============================================================================
// STK - the QingKe "SysTick-analog" (64-bit free-running/compare counter,
// split into CNTL/CNTH and CMPLR/CMPHR halves because RV32E registers are
// 32 bits wide). NOT the ARM SysTick_Type - different register set
// entirely; kept as its own struct so no code accidentally assumes ARM
// SysTick semantics (24-bit down-counter, COUNTFLAG, etc - none of that
// applies here).
// ============================================================================

typedef struct {
  volatile uint32_t CTLR;    // 0x00 Control
  volatile uint32_t SR;      // 0x04 Status (COUNTFLAG-equivalent)
  volatile uint32_t CNTL;    // 0x08 Counter low 32 bits
  volatile uint32_t CNTH;    // 0x0C Counter high 32 bits
  volatile uint32_t CMPLR;   // 0x10 Compare low 32 bits
  volatile uint32_t CMPHR;   // 0x14 Compare high 32 bits
} STK_TypeDef;

#define STK ((STK_TypeDef*)STK_BASE)

#define STK_CTLR_STE_Pos    0   // counter enable
#define STK_CTLR_STE        (1UL << STK_CTLR_STE_Pos)
#define STK_CTLR_STIE_Pos   1   // interrupt enable
#define STK_CTLR_STIE       (1UL << STK_CTLR_STIE_Pos)
#define STK_CTLR_STCLK_Pos  2   // 0 = HCLK/8, 1 = HCLK
#define STK_CTLR_STCLK      (1UL << STK_CTLR_STCLK_Pos)

// ============================================================================
// IRQ NUMBERS - PFIC "external interrupt" indices (into ISR/IENR/IPRIOR).
// UNVERIFIED for V006 (see file header): the peripheral SET on V006 is
// richer than V003 (more flash/RAM implies a bigger part), so its IRQ
// table almost certainly does not match V003's 1:1. Left sparse/commented
// on purpose - Step 3+ (real timer/serial ISRs) must confirm the real
// numbers against a CH32V006 datasheet before enabling any of these in
// PFIC->IENR[]. Nothing in this batch (M1-M3) enables a peripheral IRQ.
// ============================================================================

typedef enum {
  ch32v006_IRQn_UNVERIFIED_PLACEHOLDER = 0  // see comment above
} IRQn_Type;

#endif // CH32V006_H
