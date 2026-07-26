/*
  ch570.h - CH570 register definitions
  Part of Grbl

  SOURCING (PLAN.md Phase 6 rolling #4 Part B - "state which and why"):
  register FACTS below (addresses, bit positions, reset values) are
  transcribed from TWO independent, cross-checked sources, both
  Apache-2.0 and both explicitly permitting vendoring:
    1. The CH572/CH570 Datasheet V1.1 (Nanjing Qinheng / WCH, English,
       vendored as `vendor/` siblings' attribution note references it;
       the datasheet text itself is not reproduced here, only facts cited
       inline by section/line where useful).
    2. openwch/ch570's own SDK headers (`CH572SFR.h`, `RVMSIS/core_riscv.h`),
       Apache-2.0, LICENSE copied to vendor/LICENSE-openwch-ch570-Apache-2.0.txt.
  The EXPRESSION here (struct shapes, macro names, comments) is written
  fresh in this project's own idiom - matching ch32v006.h's and
  samd21.h's minimal struct-per-peripheral style, not a vendor CMSIS-style
  full pack - the same choice CONTRACTS.md #14's ch32v006.h header made
  against the CH32V00X RM. This is NOT a clean-room-from-datasheet-alone
  header (unlike ch32v006.h): the SDK was consulted directly because it
  is Apache-2.0 and vendorable (PLAN.md's own recon conclusion), so cross-
  checking register offsets against real, compiled vendor code (rather
  than prose alone) was possible and done.

  CHIP: CH570 (QingKe V3C core, RV32IMC + Zicsr on this toolchain), same
  SFR map as CH572 (CH572SFR.h's own file banner: "head file(ch572/ch570)";
  R8_CHIP_ID distinguishes ID_CH570=0x70 from ID_CH572=0x72 at runtime,
  not compile time - this port never reads it, it targets CH570 by Makefile
  selection only, same as every other port in this tree). Real, datasheet-
  confirmed facts used by this port:
    - Flash: 240KB user code (0x00000-0x3BFFF), BOOT ROM area at 0x3C000+
      (datasheet: `FLASH_ROM_MAX_SIZE 0x03C000`, `BOOT_LOAD_ADDR 0x3C000`).
    - RAM: 12KB (`SZ_RAM 0x00003000`).
    - GPIO: ONE port, "PA" - datasheet ch572ds.txt: "The chip provides a
      group of GPIO ports PA with 12 general input and output pins, all
      of which have interrupt...". The SDK's own GPIO_Pin_0..23 defines
      (up to 24 bits) are shared boilerplate across the whole CH5xx family
      tree (bigger siblings bond out more pins) - THIS chip only actually
      has PA0-PA11 wired. boards/generic/config.h's own header flags this
      explicitly (12-pin real budget vs the fuller placeholder map it
      uses for consistency with every other port's "generic" board).
    - PWM1-5 are FIXED-function pins, not remappable (unlike UART/TMR):
      PWM1=PA7, PWM2=PA2, PWM3=PA3, PWM4=PA4, PWM5=PA8 (datasheet pin
      table). UART TX/RX default to PA3/PA2 (remappable via
      R16_PIN_ALTERNATE_H, default value 0 used by this port).
*/

#ifndef CH570_H
#define CH570_H

#include <stdint.h>
#include <stddef.h>

// ============================================================================
// MEMORY MAP
// ============================================================================
#define FLASH_BASE          0x00000000UL
#define FLASH_USER_SIZE     0x0003C000UL   // 240 KB user code area
#define BOOT_LOAD_ADDR      0x0003C000UL   // boot-ROM area starts here (not ours)
#define SRAM_BASE           0x20000000UL
#define SRAM_SIZE           0x00003000UL   // 12 KB

#define PERIPH_BASE          0x40000000UL

// ============================================================================
// SYSTEM / CLOCK / SAFE-ACCESS block (base 0x40001000)
// ============================================================================

#define R32_SAFE_ACCESS       (*(volatile uint32_t*)0x40001040UL)
#define R8_SAFE_ACCESS_SIG    (*(volatile uint8_t *)0x40001040UL)
#define SAFE_ACCESS_SIG1      0x57u
#define SAFE_ACCESS_SIG2      0xA8u

// "Safe access" (SAM-marked registers - RWA) unlock bracket: write SIG1
// then SIG2 within the same ~112-cycle window (PLAN.md recon), disabling
// interrupts around it so nothing can stretch the window past its
// hardware timeout. Deliberately built on THIS project's own sei()/cli()
// (common/wch/wch_critical.h) rather than reproducing the vendor SDK's
// separate raw-CSR-0x800 __risc_v_enable_irq/disable_irq helpers - see
// wch_critical.h's header for why one interrupt-gate primitive is enough
// and preferred over trusting a second, less-independently-verified one.
// Usage mirrors HAL_CRITICAL_SECTION_BEGIN/END: no braces of its own,
// caller wraps in `{ }` (this file's own users always do).
#define CH570_SAFE_ACCESS_BEGIN() \
  HAL_CRITICAL_SECTION_BEGIN(); \
  R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1; \
  R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2

#define CH570_SAFE_ACCESS_END() \
  R8_SAFE_ACCESS_SIG = 0; \
  HAL_CRITICAL_SECTION_END()

#define R8_CHIP_ID            (*(volatile uint8_t *)0x40001041UL)
#define ID_CH570              0x70u
#define ID_CH572              0x72u

#define R8_RESET_STATUS       (*(volatile uint8_t *)0x40001044UL)
#define R8_GLOB_ROM_CFG       R8_RESET_STATUS   // RWA (SAM), aliases the same byte
#define RB_ROM_CODE_WE        0xC0u   // X0=protect, 01=enable 129-240K erase/write, 11=enable 0-240K
#define RB_ROM_CTRL_EN        0x20u   // enable flash control-register interface access

#define R8_CLK_SYS_CFG        (*(volatile uint8_t *)0x40001008UL)  // RWA (SAM)
#define RB_CLK_SYS_MOD        0xC0u   // [7:6]: 00/10=32M div, 01=PLL div, 11=LSI
#define R8_HFCK_PWR_CTRL      (*(volatile uint8_t *)0x4000100AUL)  // RWA (SAM)
#define RB_CLK_PLL_PON        0x01u
#define RB_CLK_XT32M_PON      0x02u
#define R8_XT32M_TUNE         (*(volatile uint8_t *)0x4000104EUL)  // RWA (SAM)

#define R8_SLP_POWER_CTRL     (*(volatile uint8_t *)0x4000100FUL)  // RWA (SAM)

#define R16_PIN_ALTERNATE     (*(volatile uint16_t*)0x40001018UL)
#define RB_PIN_DEBUG_EN       0x4000u
#define R16_PIN_ALTERNATE_H   (*(volatile uint16_t*)0x4000101AUL)
#define RB_UART_TXD           0x0038u   // 3-bit field, TX remap select
#define RB_UART_RXD           0x0007u   // 3-bit field, RX remap select

// ============================================================================
// FLASH-ROM access-control block (base 0x40001800). The datasheet
// EXPLICITLY declines to document this block's register-level protocol
// ("This datasheet does not provide the introductions to FlashROM word
// data registers and FlashROM control registers" - §4.3/4.4) and directs
// callers to the vendor's own subprograms instead - the actual program/
// erase algorithm lives in vendor/ISP572.o (FLASH_EEPROM_CMD, a normal
// linked function, NOT a boot-ROM call - see that file's header,
// corrected this batch after an adversarial review caught the earlier
// "boot-ROM" mischaracterization). This port only ever writes
// R8_FLASH_CFG per the vendor's own documented SetSysClock() sequence
// when raising the clock, and R8_GLOB_ROM_CFG (above) to gate write/erase
// permission before calling FLASH_EEPROM_CMD - never the registers in
// this block directly.
// ============================================================================
#define R8_FLASH_CFG          (*(volatile uint8_t *)0x40001807UL)  // RWA (SAM)
#define R8_FLASH_SCK          (*(volatile uint8_t *)0x40001805UL)  // RW

// ============================================================================
// GPIO port PA (base 0x400010A0) - discrete registers, AVR-style, ONE port.
// Real chip only bonds PA0-PA11 (datasheet: "12 general input and output
// pins") - GPIO_Pin_12..23-class values that appear in the vendor SDK's
// shared header exist for bigger CH5xx siblings, not this one.
// ============================================================================

#define R32_PA_DIR            (*(volatile uint32_t*)0x400010A0UL)  // 0=in, 1=out
#define R32_PA_PIN             (*(volatile uint32_t*)0x400010A4UL) // RO, input level
#define R32_PA_OUT            (*(volatile uint32_t*)0x400010A8UL)  // output latch
#define R32_PA_CLR            (*(volatile uint32_t*)0x400010ACUL)  // WZ, 1=clear that output bit
#define R32_PA_PU             (*(volatile uint32_t*)0x400010B0UL)  // pull-up enable
#define R32_PA_PD_DRV         (*(volatile uint32_t*)0x400010B4UL)  // pull-down (input) / drive strength (output)
#define R32_PA_SET            (*(volatile uint32_t*)0x400010B8UL)  // WZ, 1=set that output bit high

// GPIO interrupt block (base 0x40001090). Registers are 16-bit (only
// bits 0-11 meaningful on this chip - PA0-PA11); NOTE the vendor SDK also
// exposes 32-bit-wide aliases at the SAME addresses (R32_GPIO_INT_*, for
// bigger CH5xx siblings with a second port packed into the upper half) -
// this port uses the 16-bit view since CH570 only has one 12-pin port.
// Offsets are NOT sequential 32-bit words: EN@0x90, MODE@0x94 (skips
// 0x92/0x93), EDGE_TYPE@0x96, IF@0x9C (skips 0x98-0x9B) - verified against
// both R16_PA_INT_* and R32_GPIO_INT_* entries in the vendor SFR header,
// which agree on every one of these four addresses.
#define R16_PA_INT_EN         (*(volatile uint16_t*)0x40001090UL)
#define R16_PA_INT_MODE       (*(volatile uint16_t*)0x40001094UL)  // 1=edge, 0=level
#define R16_PA_INT_EDGE_TYPE  (*(volatile uint16_t*)0x40001096UL)  // per-bit: 1=high/rising, 0=low/falling
#define R16_PA_INT_IF         (*(volatile uint16_t*)0x4000109CUL)  // RW1 (write-1-to-clear)

// ============================================================================
// UART (base 0x40003400) - 16550-style: MCR/IER/FCR/LCR/IIR/LSR/RBR/THR/
// DLL/DLM/DIV, WCH register names but classic National-16550 shape and
// bit positions (PLAN.md recon: "16550-style UART", confirmed against
// the vendor SDK - genuinely NOT the F1-style STATR/DATAR/BRR shape
// ch32v006 used, so that port's serial.c is not reusable here).
// ============================================================================

typedef struct {
  volatile uint8_t  MCR;    // 0x00 modem control
  volatile uint8_t  IER;    // 0x01 interrupt enable
  volatile uint8_t  FCR;    // 0x02 FIFO control
  volatile uint8_t  LCR;    // 0x03 line control
  volatile uint8_t  IIR;    // 0x04 interrupt identification (RO)
  volatile uint8_t  LSR;    // 0x05 line status (RO)
  uint8_t           RESERVED0[2];   // 0x06-0x07
  volatile uint8_t  RBR_THR;        // 0x08 RBR (read) / THR (write)
  uint8_t           RESERVED1;      // 0x09
  volatile uint8_t  RFC;    // 0x0A RX FIFO count (RO)
  volatile uint8_t  TFC;    // 0x0B TX FIFO count (RO)
  volatile uint8_t  DLL;    // 0x0C divisor latch LSB
  volatile uint8_t  DLM;    // 0x0D divisor latch MSB
  volatile uint8_t  DIV;    // 0x0E pre-divisor (low 7 bits, 1..127, 0==128)
} UART_TypeDef;

#define UART1   ((UART_TypeDef*)0x40003400UL)

#define RB_IER_RECV_RDY   0x01u
#define RB_IER_LINE_STAT  0x04u
#define RB_IER_TXD_EN     0x40u   // must be set for TX to actually drive out

#define RB_FCR_FIFO_EN       0x01u
#define RB_FCR_FIFO_TRIG_1B  0x00u

#define RB_LCR_WORD_SZ_8  0x03u   // word length [1:0] = 11 -> 8 bits

#define RB_LSR_TX_FIFO_EMP 0x20u
#define RB_LSR_DATA_RDY    0x01u

// ============================================================================
// TMR - the ONE FIFO/DMA-capable general timer (base 0x40002400). 26-bit
// up-counter, auto-reloads at CNT_END, cycle-end IRQ. NO hardware clock
// divider - counts at Fsys directly (PLAN.md recon: "audit IRQ capability
// per timer before assigning roles" - this is the only timer on this chip
// with an interrupt at all besides SysTick/STK and PWMX; used here as the
// stepper timer).
// ============================================================================

typedef struct {
  volatile uint8_t  CTRL_MOD;   // 0x00
  volatile uint8_t  CTRL_DMA;   // 0x01
  volatile uint8_t  INTER_EN;   // 0x02
  uint8_t           RESERVED0;  // 0x03
  uint8_t           RESERVED1;  // 0x04
  uint8_t           RESERVED2;  // 0x05
  volatile uint8_t  INT_FLAG;   // 0x06 (RW1 - write-1-to-clear)
  volatile uint8_t  FIFO_COUNT; // 0x07 (RO)
  volatile uint32_t COUNT;      // 0x08 (RO), 26-bit
  volatile uint32_t CNT_END;    // 0x0C, 26-bit reload/compare value
  volatile uint32_t FIFO;       // 0x10
  volatile uint32_t DMA_NOW;    // 0x14
  volatile uint32_t DMA_BEG;    // 0x18
  volatile uint32_t DMA_END;    // 0x1C
} TMR_TypeDef;

#define TMR0   ((TMR_TypeDef*)0x40002400UL)

#define RB_TMR_MODE_IN      0x01u   // 0 = timer/PWM, 1 = capture/count
#define RB_TMR_ALL_CLEAR    0x02u   // force clear FIFO + counter
#define RB_TMR_COUNT_EN     0x04u
#define RB_TMR_OUT_EN       0x08u

#define RB_TMR_IE_CYC_END   0x01u
#define RB_TMR_IF_CYC_END   0x01u

#define TMR_MAX_COUNT       0x03FFFFFFu   // 26-bit

// ============================================================================
// PWMX - 5 simple PWM channels (base 0x40005000), FIXED pins (datasheet):
// PWM1=PA7, PWM2=PA2, PWM3=PA3, PWM4=PA4, PWM5=PA8. This port uses PWM1
// (PA7) for the spindle - avoids the UART pins (PA2/PA3) entirely.
// ============================================================================

#define R8_PWM_OUT_EN    (*(volatile uint8_t*)0x40005000UL)
#define RB_PWM1_OUT_EN   0x01u

#define R8_PWM_POLAR     (*(volatile uint8_t*)0x40005001UL)
#define RB_PWM1_POLAR    0x01u

#define R8_PWM_CONFIG    (*(volatile uint8_t*)0x40005002UL)
// [1:0]: 00=256-step/255-step select bit0, bit1 chooses 256/128/64 family;
// datasheet-confirmed encoding for 8-bit mode: 0x00 = 256 steps (this port's
// choice - matches core's uint8_t duty domain 0-255 with no rescale).
#define RB_PWM_CYC_256   0x00u

#define R8_PWM1_DATA     (*(volatile uint8_t*)0x40005004UL)  // duty, 0-255

#define R16_PWM_CLOCK_DIV (*(volatile uint16_t*)0x40005018UL)

// ============================================================================
// QingKe V3C core peripherals - PFIC (common/wch/wch_pfic.h, IRQ bank
// width 8 words = 256 IRQ numbers on this core) and STK (SysTick analog).
// ============================================================================

#define WCH_PFIC_IRQ_WORDS 8
#include "../common/wch/wch_pfic.h"

// STK ("SysTick") at 0xE000F000 - PLAN.md CH570 recon, cross-checked
// against openwch/ch570 RVMSIS/core_riscv.h SysTick_Type (identical
// offsets/bit positions to ch32v006's STK - CONTRACTS.md §14 item 7).
typedef struct {
  volatile uint32_t CTLR;    // 0x00
  volatile uint32_t SR;      // 0x04 CNTIF bit0, write-0-to-clear
  volatile uint32_t CNTL;    // 0x08 32-bit counter
  uint32_t RESERVED0;        // 0x0C
  volatile uint32_t CMPLR;   // 0x10 32-bit compare
  uint32_t RESERVED1;        // 0x14
} STK_TypeDef;

#define STK_BASE    0xE000F000UL
#define STK         ((STK_TypeDef*)STK_BASE)

#define STK_CTLR_STE     (1UL << 0)   // counter enable
#define STK_CTLR_STIE    (1UL << 1)   // interrupt enable
#define STK_CTLR_STCLK   (1UL << 2)   // 0 = HCLK/8, 1 = HCLK
#define STK_CTLR_STRE    (1UL << 3)   // auto-reload to 0 on compare
#define STK_CTLR_MODE    (1UL << 4)   // count direction (left at 0, up-count - matches vendor SysTick_Config usage)
#define STK_SR_SWIE      (1UL << 31)

// ============================================================================
// IRQ NUMBERS (datasheet interrupt table / vendor startup_CH572.S vector
// order - both agree). Highest vector this port wires = 27 (UART).
// ============================================================================

typedef enum {
  SysTick_IRQn   = 12,
  SW_IRQn        = 14,
  GPIOA_IRQn     = 17,   // ALL PA pins share this one vector
  SPI_IRQn       = 19,
  BLEB_IRQn      = 20,
  BLEL_IRQn      = 21,
  USB_IRQn       = 22,
  TMR_IRQn       = 24,   // TMR0 cycle-end - this port's stepper timer
  UART_IRQn      = 27,   // UART1 RX/TX
  RTC_IRQn       = 28,
  CMP_IRQn       = 29,
  I2C_IRQn       = 30,
  PWMX_IRQn      = 31,
  KEYSCAN_IRQn   = 33,
  ENCODER_IRQn   = 34,
  WDOG_BAT_IRQn  = 35,
} IRQn_Type;

#define PFIC_VECTOR_COUNT   36   // vectors 0..35

#endif // CH570_H
