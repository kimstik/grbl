/*
  regs.h - HC32F460 register definitions
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  HDSC/XHSC HC32F460JETA, ARM Cortex-M4F, up to 200MHz, up to 512KB Flash,
  up to 192KB SRAM.

  VERIFICATION METHODOLOGY (Phase 6 rolling port #3 - first HDSC/Huada
  vendor-exotic chip, neither ST/NXP/Atmel-family "familiar ARM" nor a
  previously-ported ISA). PORTING-CHECKLIST.md's reuse-first rule does not
  apply here: no donor port in this tree shares this vendor's peripheral IP
  at all (TIMER0/TIMERA/TIMER4/TIMER6, an INTC event router instead of a
  fixed NVIC vector map, EFM flash, PWC/CMU clock tree). Every fact below is
  sourced and graded honestly, same discipline as CONTRACTS.md sections 14/16
  (RISC-V/dsPIC first-time gaps):

  CONFIRMED sources this session:
    - HC32F460 Series Datasheet Rev1.3 (HDSC/Huada, official, English) TOC
      and feature list confirm peripheral EXISTENCE and section numbers:
      CMU 1.4.4 (p18), PWC 1.4.5 (p19), EFM 1.4.7 (p20), GPIO 1.4.9 (p21),
      INTC 1.4.10 (p22), TimerA 1.4.21/Timer0 1.4.22 (p27, "2 16bit basic
      Timer(Timer0)", "6 16bit universal Timer(TimerA)"), USART 1.4.25
      (p28, "4 USART"). This document is the datasheet, not the full
      register-level user manual (not available in extractable form this
      session) - it does NOT contain register bit-field tables.
    - Klipper3d/klipper `src/hc32f460` directory (github.com/Klipper3d/klipper,
      GPL-3.0 - license-compatible with this GPLv3 grbl core; real firmware
      shipping on Voxelab Aquila printers, not a vendor SDK) - fetched and
      cross-checked this session for CONCRETE facts: GPIO data-path register
      NAMES (PIDRx/PODRx/POSRx/PORRx/POTRx, offsetof-derived, "ports are in
      one M4_PORT - offset by 0x10" between port letters), the INTC event
      router mechanism (`M4_INTC->SEL[irqType].INTSEL = irqSrc` then
      `NVIC_SetPriority`/`NVIC_EnableIRQ(irqType)`, vector slots
      "Int000_IRQn through Int031_IRQn" - QUOTED VERBATIM from the fetched
      source, 32 shared peripheral vectors, NOT a fixed per-peripheral
      table like every STM32/SAMD21 donor in this tree), USART register
      access via `DR_f.RDR`/`DR_f.TDR` fields and `PWC_FcgxPeriphClockCmd()`
      clock-gate calls, TIMERA used for PWM (`M4_TMRA_TypeDef`,
      `stc_timera_base_init_t`/`stc_timera_compare_init_t`,
      `PORT_SetFunc(..., Func_Tima0, ...)` pin routing), and real clock-tree
      addresses from a Voxelab bootloader (CMU_XTALCFGR @ 0x40054410,
      CMU_PLLCFGR @ 0x40054100, CMU_CKSWR @ 0x40054026, PLL config value
      0x11102900 decoded to MPLLN=41/x1/x42/div2).
    - Vendor DDL (HDSC/XHSC `hc32f4a0_ddl`, github.com/Mmatsnev/hc32f4a0
      mirror): confirmed to EXIST (CMSISPack + DeviceDriverLibrary
      directories) but NO permissive license file was found this session
      (repo footer shows bare "(C) HDSC" copyright, no LICENSE/SPDX
      anywhere located) - unlike the dsPIC33AK DFP (Apache-2.0, CONTRACTS.md
      section 16 item 11) or the ch32v006 Zephyr dtsi cross-check
      (Apache-2.0, section 14 item 7). Per PORTING-CHECKLIST's own ordering
      ("vendor SDK only if permissively licensed; clean-room is the
      fallback, not a last resort"), this port does NOT vendor or transcribe
      the HDSC DDL - every struct/macro below is original clean-room code,
      informed by (not copied from) the facts above.

  RM-ONLY / UNVERIFIED this session (no register-level manual reachable):
  every base address below OTHER than the CMU sub-registers cited above,
  every bit-field position, the PCONR per-pin config layout, the EFM
  FAPRT unlock key value, and the exact numeric INTC source-ID values.
  Each is flagged at its definition with "UNVERIFIED" and a plain-language
  note of what hardware bring-up must confirm before trusting it - the
  same posture CONTRACTS.md sections 14/16 established for RISC-V/dsPIC
  fields with no locally-reachable RM. A struct-shaped placeholder that
  compiles is not evidence of correctness (CONTRACTS.md section 14 item 7's
  explicit lesson: "struct-shaped best-effort register layouts are worse
  than absent ones" when NOT flagged - so every guess here IS flagged).
*/

#ifndef HC32F460_REGS_H
#define HC32F460_REGS_H

#include <stdint.h>
#include <stdbool.h>

/* ============================================================================
 * CORE ARM CORTEX-M4F PRIMITIVES (architectural, not vendor-specific - same
 * confidence level as every other ARM port in this tree)
 * ==========================================================================*/

#define __enable_irq()    __asm__ volatile ("cpsie i" : : : "memory")
#define __disable_irq()   __asm__ volatile ("cpsid i" : : : "memory")
#define __NOP()           __asm__ volatile ("nop")
#define __get_PRIMASK()   ({ uint32_t primask; __asm__ volatile ("mrs %0, primask" : "=r" (primask)); primask; })
#define __set_PRIMASK(x)  __asm__ volatile ("msr primask, %0" : : "r" (x) : "memory")

#define __IO volatile

/* Memory barriers (BUG#12/BUG#13 lessons, CONTRACTS.md sections 12.1/12.4):
   startup.c needs __DSB() between .data copy / .bss zero phases, and
   nvmem.c needs one between filling a flash write buffer and issuing the
   EFM program/erase command. */
#define __DSB()  __asm__ volatile ("dsb" ::: "memory")
#define __DMB()  __asm__ volatile ("dmb" ::: "memory")
#define __ISB()  __asm__ volatile ("isb" ::: "memory")

/* ============================================================================
 * SCB (only VTOR - what makes the vector table a real code reference so
 * -flto's IPA cannot delete it before codegen, CONTRACTS.md section 18)
 * ==========================================================================*/

typedef struct {
  volatile uint32_t CPUID;
  volatile uint32_t ICSR;
  volatile uint32_t VTOR;
} SCB_Type;

#define SCB_BASE  (0xE000ED00UL)
#define SCB       ((SCB_Type*)SCB_BASE)

/* ============================================================================
 * SYSTICK (architectural Cortex-M4, address fixed by the ARMv7-M spec)
 * ==========================================================================*/

typedef struct {
  volatile uint32_t CTRL;
  volatile uint32_t LOAD;
  volatile uint32_t VAL;
  volatile uint32_t CALIB;
} SysTick_Type;

#define SysTick  ((SysTick_Type*)0xE000E010UL)

/* ============================================================================
 * NVIC (architectural layout, ARMv7-M). HC32F460 uses only the low 32 bits
 * of ISER/ICER/etc (32 shared "Int000_IRQn..Int031_IRQn" peripheral vectors,
 * confirmed via Klipper's real interrupts.c - see file header). This is a
 * materially different shape from every STM32/SAMD21 donor in this tree,
 * which hard-wire one physical IRQ number per peripheral: here, ALL
 * peripheral interrupt sources are routed through the INTC event router
 * (below) onto this same fixed pool of 32 vectors.
 * ==========================================================================*/

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

typedef enum {
  Int000_IRQn = 0,  Int001_IRQn,  Int002_IRQn,  Int003_IRQn,
  Int004_IRQn,      Int005_IRQn,  Int006_IRQn,  Int007_IRQn,
  Int008_IRQn,      Int009_IRQn,  Int010_IRQn,  Int011_IRQn,
  Int012_IRQn,      Int013_IRQn,  Int014_IRQn,  Int015_IRQn,
  Int016_IRQn,      Int017_IRQn,  Int018_IRQn,  Int019_IRQn,
  Int020_IRQn,      Int021_IRQn,  Int022_IRQn,  Int023_IRQn,
  Int024_IRQn,      Int025_IRQn,  Int026_IRQn,  Int027_IRQn,
  Int028_IRQn,      Int029_IRQn,  Int030_IRQn,  Int031_IRQn
} IRQn_Type;

#define HC32_NUM_SHARED_IRQ  32

static inline void NVIC_EnableIRQ(IRQn_Type IRQn) {
  NVIC->ISER[(uint32_t)IRQn >> 5] = (1UL << ((uint32_t)IRQn & 0x1F));
}

static inline void NVIC_DisableIRQ(IRQn_Type IRQn) {
  NVIC->ICER[(uint32_t)IRQn >> 5] = (1UL << ((uint32_t)IRQn & 0x1F));
}

static inline void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority) {
  NVIC->IP[(uint32_t)IRQn] = (uint8_t)(priority << 4);
}

/* ============================================================================
 * INTC - HC32-specific interrupt EVENT ROUTER. UNVERIFIED base address
 * (INTC_BASE below is a placeholder - no register-level manual reachable
 * this session; the ROUTING MECHANISM itself - one SEL register per shared
 * vector, written with a peripheral event-source id - is confirmed real via
 * Klipper's interrupts.c, quoted in the file header). Each SEL register is
 * modeled as 32-bit with the source id in the low byte; the real field
 * width/name (INTSEL) is not verified beyond Klipper's identifier, only its
 * existence and one-register-per-vector shape.
 * ==========================================================================*/

typedef struct {
  volatile uint32_t SEL;   /* UNVERIFIED bit width of the INTSEL field - modeled as the whole word */
} INTC_SEL_TypeDef;

#define INTC_SEL_BASE  0x40050000UL   /* UNVERIFIED - placeholder, confirm against HC32F460 user manual before hardware bring-up */
#define INTC_SEL  ((INTC_SEL_TypeDef*)INTC_SEL_BASE)   /* array of HC32_NUM_SHARED_IRQ, indexed by IRQn_Type (Klipper: "4u * irqType" byte stride) */

/* Peripheral event-source ids consumed by INTC_SEL[n].SEL. Real HDSC
   numbering is NOT available this session (no register manual reached);
   these are internally-consistent placeholder values assigned by this port
   in the order the peripherals are wired up, NOT the vendor's real
   numbering - functionally irrelevant to the routing MECHANISM (any code
   consistently using the same value to arm and to recognize a source
   works identically), but they must be replaced with real HDSC source-id
   constants before first hardware bring-up, alongside the INTC_SEL_BASE
   placeholder above. */
typedef enum {
  HC32_INT_SRC_TMR0_1_CMPA   = 0x00,   /* UNVERIFIED numeric id: stepper timer compare */
  HC32_INT_SRC_TMR0_2_CMPA   = 0x01,   /* UNVERIFIED numeric id: pulse-reset timer compare */
  HC32_INT_SRC_USART1_RI     = 0x02,   /* UNVERIFIED numeric id: USART1 RX */
  HC32_INT_SRC_USART1_TI     = 0x03,   /* UNVERIFIED numeric id: USART1 TX empty */
  HC32_INT_SRC_PORT_EIRQ0    = 0x10,   /* UNVERIFIED numeric id: external pin interrupt, EIRQ channel 0 */
  HC32_INT_SRC_PORT_EIRQ1    = 0x11,
  HC32_INT_SRC_PORT_EIRQ2    = 0x12,
  HC32_INT_SRC_PORT_EIRQ3    = 0x13,
  HC32_INT_SRC_PORT_EIRQ4    = 0x14,
  HC32_INT_SRC_PORT_EIRQ5    = 0x15,
  HC32_INT_SRC_PORT_EIRQ6    = 0x16,
} hc32_int_src_t;

static inline void intc_route(IRQn_Type vector, hc32_int_src_t src) {
  INTC_SEL[(uint32_t)vector].SEL = (uint32_t)src;
}

/* ============================================================================
 * PWC (Power/Clock control) - PWC_FPRC is the write-protect unlock this
 * port's brief calls out by name. HDSC's family-wide convention (cited
 * across multiple independent community sources for HC32F4xx-class parts,
 * NOT verified against this specific device's register manual this
 * session) is a single-byte register gating writes to CMU/RMU/PWC control
 * registers: write the unlock code, do the protected writes, write 0 to
 * relock. UNVERIFIED: exact base address, exact unlock byte value, exact
 * set of registers actually gated (FPRC0/FPRC1/FPRC3 bit-per-domain vs a
 * single flat unlock - both shapes exist across HDSC's F4 family).
 * ==========================================================================*/

typedef struct {
  volatile uint32_t FPRC;      /* 0x00 - UNVERIFIED offset. Write-protect code register */
  uint32_t RESERVED0[3];
  volatile uint32_t STPMCR;    /* 0x10 - UNVERIFIED. Stop-mode control, unused by this port */
} PWC_TypeDef;

#define PWC_BASE  0x40054000UL   /* UNVERIFIED placeholder - same peripheral block region as CMU per Klipper's addresses below */
#define PWC   ((PWC_TypeDef*)PWC_BASE)

#define PWC_FPRC_UNLOCK_CODE   0xA5U   /* UNVERIFIED exact value for this device - HDSC F4-family convention cited in community sources, not confirmed against the HC32F460 manual this session */
#define PWC_FPRC_LOCK_CODE     0x00U

/* ============================================================================
 * CMU (Clock control) - the three sub-register addresses below ARE
 * confirmed this session: quoted from a real Voxelab Aquila HC32F460
 * bootloader (see file header). They are absolute addresses, not struct
 * fields, deliberately: CMU's real register map is sparse (many independent
 * clock-domain sub-blocks at non-uniform spacing per the "6 independent
 * clock sources" feature list), so a single packed struct spanning them
 * would silently fabricate the gaps - the exact trap CONTRACTS.md section
 * 14 item 7 warns against. Every other CMU register this port does not
 * strictly need is left undefined rather than guessed.
 * ==========================================================================*/

#define CMU_XTALCFGR   (*(volatile uint32_t*)0x40054410UL)   /* CONFIRMED address (Klipper bootloader) - external main oscillator config */
#define CMU_PLLCFGR    (*(volatile uint32_t*)0x40054100UL)   /* CONFIRMED address (Klipper bootloader) - PLL config: PLLN[8:0] etc, UNVERIFIED bit positions beyond the one decoded value cited in the file header */
#define CMU_CKSWR      (*(volatile uint8_t *)0x40054026UL)   /* CONFIRMED address (Klipper bootloader) - system clock source select, byte register. 0x05 = MPLL (confirmed value from the same source) */
#define CMU_XTALCR     (*(volatile uint8_t *)0x40054400UL)   /* UNVERIFIED offset - XTAL enable/ready, modeled adjacent to XTALCFGR */
#define CMU_PLLCR      (*(volatile uint8_t *)0x40054103UL)   /* UNVERIFIED offset - PLL enable/ready, modeled adjacent to PLLCFGR */
#define CMU_SCFGR      (*(volatile uint32_t*)0x40054000UL)   /* UNVERIFIED - system clock (HCLK/PCLK) divider register, placeholder address */

#define CMU_CKSWR_MPLL   0x05U    /* CONFIRMED value (Klipper bootloader: "value 0x05 selects MPLL as system clock") */

#define CMU_XTALCR_XTALON     (1U << 0)   /* UNVERIFIED bit position */
#define CMU_XTALCR_XTALRDY    (1U << 4)   /* UNVERIFIED bit position */
#define CMU_PLLCR_PLLON       (1U << 0)   /* UNVERIFIED bit position */
#define CMU_PLLCR_PLLRDY      (1U << 4)   /* UNVERIFIED bit position */

/* PLLCFGR field positions - UNVERIFIED placeholder layout. The one real
   decoded example this session (Klipper bootloader, targeting a 168MHz
   configuration from an 8MHz XTAL): raw value 0x11102900 -> "MPLLN = 0x029
   (41 decimal), divide-by-1, multiply x42 / div2" per the file header -
   that decode does not cleanly resolve to the field positions below
   (the exact PLLM/PLLN/PLLP bit windows were not independently confirmed,
   only the fact that a multiply-by-N/divide-by-M/output-divide-by-P PLL
   exists and 0x11102900 is a real working value for a different target
   frequency). Field positions below are this port's own placeholder. */
#define CMU_PLLCFGR_PLLM_Pos   0    /* UNVERIFIED */
#define CMU_PLLCFGR_PLLN_Pos   8    /* UNVERIFIED */
#define CMU_PLLCFGR_PLLP_Pos   20   /* UNVERIFIED */

/* ============================================================================
 * EFM (Embedded Flash Module) - existence confirmed (datasheet section
 * 1.4.7, "0-wait program execution"). FAPRT is the flash-protect unlock
 * this port's brief names explicitly; register layout below is UNVERIFIED
 * placeholder modeled on the generic erase/program/status/key shape common
 * to this class of flash controller (same posture as ch32v006/stm32 flash
 * controllers, whose real layouts WERE verified - this one is not).
 * ==========================================================================*/

typedef struct {
  volatile uint32_t FAPRT;   /* 0x00 - UNVERIFIED. Flash protect unlock: write key sequence to open FRMC/FWMC for writes */
  volatile uint32_t FRMC;    /* 0x04 - UNVERIFIED. Read mode control (wait states, cache) */
  volatile uint32_t FWMC;    /* 0x08 - UNVERIFIED. Write mode control (program/erase op select) */
  volatile uint32_t FSTP;    /* 0x0C - UNVERIFIED. Operation start/stop trigger */
  volatile uint32_t FSR;     /* 0x10 - UNVERIFIED. Status (busy/ready, error flags) */
} EFM_TypeDef;

#define EFM_BASE  0x40040000UL   /* UNVERIFIED placeholder */
#define EFM   ((EFM_TypeDef*)EFM_BASE)

#define EFM_FAPRT_KEY1   0x0123UL   /* UNVERIFIED - placeholder unlock key pair, must be confirmed before hardware bring-up */
#define EFM_FAPRT_KEY2   0x3210UL

#define EFM_FWMC_PEMODE_PROGRAM   (1U << 0)   /* UNVERIFIED bit position */
#define EFM_FWMC_PEMODE_ERASE     (1U << 1)   /* UNVERIFIED bit position */
#define EFM_FSTP_START            (1U << 0)   /* UNVERIFIED bit position */
#define EFM_FSR_RDY               (1U << 0)   /* UNVERIFIED bit position */

/* ============================================================================
 * PORT (GPIO) - one peripheral instance covering every port letter, laid
 * out with a CONFIRMED 0x10 (16-byte) stride between consecutive port
 * letters (Klipper: "HC32F460 ports are in one M4_PORT - offset by 0x10").
 * The four register NAMES below (PIDR/PODR/POSR/PORR) are confirmed to
 * exist (Klipper offsetof() references); their exact byte sub-offset
 * WITHIN each port's 0x10 block is this port's own placeholder layout,
 * chosen so POSR/PORR give hardware atomic bit-set/bit-clear (matching the
 * BSRR-style semantic every other ARM port in this tree relies on for the
 * CONTRACTS.md section 1.2 mixed mainline/ISR writer contract) - UNVERIFIED
 * against the real sub-offsets. PORT base address is also UNVERIFIED.
 * ==========================================================================*/

typedef struct {
  volatile uint16_t PIDR;    /* 0x00 - input data (CONFIRMED name, UNVERIFIED sub-offset) */
  uint16_t RESERVED0;
  volatile uint16_t PODR;    /* 0x04 - output data (CONFIRMED name, UNVERIFIED sub-offset) */
  uint16_t RESERVED1;
  volatile uint16_t POSR;    /* 0x08 - output set: write 1 sets the pin (CONFIRMED name, UNVERIFIED sub-offset) */
  uint16_t RESERVED2;
  volatile uint16_t PORR;    /* 0x0C - output reset: write 1 clears the pin (CONFIRMED name, UNVERIFIED sub-offset) */
  uint16_t RESERVED3;
} HC32_PORT_TypeDef;   /* one instance per port letter; stride 0x10 (CONFIRMED) */

#define PORT_BASE  0x40053800UL   /* UNVERIFIED placeholder */

#define GPIOA  ((HC32_PORT_TypeDef*)(PORT_BASE + 0x00))
#define GPIOB  ((HC32_PORT_TypeDef*)(PORT_BASE + 0x10))
#define GPIOC  ((HC32_PORT_TypeDef*)(PORT_BASE + 0x20))

/* Per-pin configuration register (direction / pull-up / function select).
   Existence and the general "one config word per pin" shape are a common
   pattern across HDSC's PORT peripheral generations (see file header
   PCONR/PFSR references) but NO bit-field table was reachable this
   session. Modeled as one 32-bit word per pin, PCONR_BASE-relative, 4-byte
   stride, GLOBAL pin index = port_index*16 + pin_number (port_index: A=0,
   B=1, C=2). Bit positions below are placeholders. */

#define PCONR_BASE  0x40053C00UL   /* UNVERIFIED placeholder */

static inline volatile uint32_t *hc32_pconr(HC32_PORT_TypeDef *port, uint8_t pin) {
  uint32_t port_index = ((uint32_t)port - PORT_BASE) / 0x10U;
  return (volatile uint32_t *)(PCONR_BASE + (port_index * 16U + pin) * 4U);
}

#define PCONR_OUT_ENABLE   (1U << 0)   /* UNVERIFIED bit position: 1 = output, 0 = input */
#define PCONR_PULLUP_EN    (1U << 4)   /* UNVERIFIED bit position: 1 = pull-up enabled */

/* ============================================================================
 * PORT EIRQ - external pin interrupt flags. The INTC datasheet blurb
 * (section 1.4.10) explicitly names "interrupt control function of
 * external pin ... EIRQ" as a distinct source class from ordinary
 * peripheral events; modeled here as one flag register with one
 * write-1-to-clear bit per EIRQ channel (0-15), channel number == pin
 * number within whichever port is muxed to that channel (STM32 EXTI-style
 * assumption, UNVERIFIED for this chip - see platform.h's pin-map note on
 * why LIMIT+CONTROL share one port at non-colliding numbers regardless).
 * ==========================================================================*/

typedef struct {
  volatile uint32_t EIRQFR;   /* 0x00 - UNVERIFIED. One bit per EIRQx channel, write-1-to-clear */
} HC32_EIRQ_TypeDef;

#define EIRQ_BASE  0x40053E00UL   /* UNVERIFIED placeholder */
#define PORT_EIRQ  ((HC32_EIRQ_TypeDef*)EIRQ_BASE)

/* ============================================================================
 * TIMER0 - "2 16bit basic Timer(Timer0)" per datasheet 1.4.22. Used here as
 * the stepper timer (unit 1) and pulse-reset timer (unit 2): a basic
 * compare timer is exactly the AVR Timer1/Timer0 CTC-class shape CONTRACTS
 * section 3/4 wants, and the datasheet confirms each unit generates a
 * "compare match event" - i.e. it has a real interrupt source, satisfying
 * the PORTING-CHECKLIST Step 3 "audit IRQ capability before allocating"
 * rule (CONTRACTS.md section 14 item 11) at the confirmed-features level,
 * even though the exact register layout below is UNVERIFIED placeholder.
 * ==========================================================================*/

typedef struct {
  volatile uint32_t CR;       /* 0x00 - UNVERIFIED. Control: enable, clock source/prescale */
  volatile uint32_t CNTER;    /* 0x04 - UNVERIFIED. Counter */
  volatile uint32_t CMPAR;    /* 0x08 - UNVERIFIED. Compare A (period / stepper tick) */
  volatile uint32_t CMPBR;    /* 0x0C - UNVERIFIED. Compare B (unused by this port) */
  volatile uint32_t IER;      /* 0x10 - UNVERIFIED. Interrupt enable */
  volatile uint32_t STFLR;    /* 0x14 - UNVERIFIED. Status/flag, write-1-to-clear */
} HC32_TMR0_TypeDef;

#define TMR0_1_BASE  0x40008000UL   /* UNVERIFIED placeholder - stepper timer */
#define TMR0_2_BASE  0x40008040UL   /* UNVERIFIED placeholder - pulse-reset timer */
#define TMR0_1  ((HC32_TMR0_TypeDef*)TMR0_1_BASE)
#define TMR0_2  ((HC32_TMR0_TypeDef*)TMR0_2_BASE)

#define TMR0_CR_START       (1U << 0)   /* UNVERIFIED bit position */
#define TMR0_IER_CMPAIE      (1U << 0)   /* UNVERIFIED bit position */
#define TMR0_STFLR_CMAF      (1U << 0)   /* UNVERIFIED bit position, write-1-to-clear */

/* ============================================================================
 * TIMERA - "6 16bit universal Timer(TimerA)" per datasheet 1.4.21, and
 * CONFIRMED via Klipper's hard_pwm.c to be the real PWM peripheral this
 * chip family uses (M4_TMRA_TypeDef / stc_timera_base_init_t /
 * stc_timera_compare_init_t / PWC_Fcg2PeriphClockCmd(PWC_FCG2_PERIPH_TIMAx)
 * / PORT_SetFunc(..., Func_Tima0, ...)). Used here for spindle PWM. Layout
 * below is this port's own UNVERIFIED placeholder (period/compare register
 * existence is confirmed by name in Klipper; exact offsets are not).
 * ==========================================================================*/

typedef struct {
  volatile uint32_t CR;       /* 0x00 - UNVERIFIED. Control: enable, clock source */
  volatile uint32_t PERAR;    /* 0x04 - UNVERIFIED. Period register (u16PeriodVal in Klipper's stc_timera_base_init_t) */
  volatile uint32_t CMPAR1;   /* 0x08 - UNVERIFIED. Compare/duty register, channel 1 (u16CompareVal) */
  volatile uint32_t CCONR1;   /* 0x0C - UNVERIFIED. Channel 1 compare-output control (enable/polarity) */
} HC32_TMRA_TypeDef;

#define TMRA_1_BASE  0x40009000UL   /* UNVERIFIED placeholder - spindle PWM unit */
#define TMRA_1  ((HC32_TMRA_TypeDef*)TMRA_1_BASE)

#define TMRA_CR_START         (1U << 0)   /* UNVERIFIED bit position */
#define TMRA_CCONR_CH_ENABLE  (1U << 0)   /* UNVERIFIED bit position */

/* ============================================================================
 * USART - "4 USART" per datasheet 1.4.25. CONFIRMED via Klipper's serial.c
 * that USART1 is real and accessed via a data-register union field
 * (DR_f.RDR / DR_f.TDR) plus separate RI/TI/EI/TCI interrupt sources (a
 * SPLIT interrupt model, unlike every STM32 donor's single combined USART
 * vector) - this port therefore allocates one INTC vector each for RX and
 * TX rather than sharing one vector with an SR-flag dispatch. Register
 * layout below is UNVERIFIED placeholder.
 * ==========================================================================*/

typedef struct {
  volatile uint32_t SR;       /* 0x00 - UNVERIFIED. Status: RX-not-empty / TX-empty flags */
  volatile uint32_t DR;       /* 0x04 - UNVERIFIED. Data register (RDR/TDR share one address, direction implied by access) */
  volatile uint32_t BRR;      /* 0x08 - UNVERIFIED. Baud rate register */
  volatile uint32_t CR1;      /* 0x0C - UNVERIFIED. Control 1: RX/TX enable, RX/TX interrupt enable */
} HC32_USART_TypeDef;

#define USART1_BASE  0x4000A000UL   /* UNVERIFIED placeholder */
#define USART1  ((HC32_USART_TypeDef*)USART1_BASE)

#define USART_SR_RXNE   (1U << 0)   /* UNVERIFIED bit position */
#define USART_SR_TXE    (1U << 1)   /* UNVERIFIED bit position */
#define USART_CR1_RE    (1U << 0)   /* UNVERIFIED bit position */
#define USART_CR1_TE    (1U << 1)   /* UNVERIFIED bit position */
#define USART_CR1_RIE   (1U << 2)   /* UNVERIFIED bit position */
#define USART_CR1_TIE   (1U << 3)   /* UNVERIFIED bit position */

#endif /* HC32F460_REGS_H */
