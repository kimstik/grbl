/*
  samd21.h - SAMD21 stub header
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Minimal stub header for SAMD21G18A
  TODO: Replace with official CMSIS headers from Microchip/Atmel
*/

#ifndef SAMD21_H
#define SAMD21_H

#include <stdint.h>

// ============================================================================
// PERIPHERAL BASE ADDRESSES
// ============================================================================

#define PERIPH_BASE           0x40000000UL

// AHB-APB Bridge A
#define PAC0_BASE             (0x40000000UL)
#define PM_BASE               (0x40000400UL)
#define SYSCTRL_BASE          (0x40000800UL)
#define GCLK_BASE             (0x40000C00UL)
#define WDT_BASE              (0x40001000UL)
#define RTC_BASE              (0x40001400UL)
#define EIC_BASE              (0x40001800UL)

// AHB-APB Bridge B
#define PAC1_BASE             (0x41000000UL)
#define DSU_BASE              (0x41002000UL)
#define NVMCTRL_BASE          (0x41004000UL)
#define PORT_BASE             (0x41004400UL)
#define DMAC_BASE             (0x41004800UL)
#define USB_BASE              (0x41005000UL)
#define MTB_BASE              (0x41006000UL)

// AHB-APB Bridge C
#define PAC2_BASE             (0x42000000UL)
#define EVSYS_BASE            (0x42000400UL)
#define SERCOM0_BASE          (0x42000800UL)
#define SERCOM1_BASE          (0x42000C00UL)
#define SERCOM2_BASE          (0x42001000UL)
#define SERCOM3_BASE          (0x42001400UL)
#define SERCOM4_BASE          (0x42001800UL)
#define SERCOM5_BASE          (0x42001C00UL)
#define TCC0_BASE             (0x42002000UL)
#define TCC1_BASE             (0x42002400UL)
#define TCC2_BASE             (0x42002800UL)
#define TC3_BASE              (0x42002C00UL)
#define TC4_BASE              (0x42003000UL)
#define TC5_BASE              (0x42003400UL)
#define TC6_BASE              (0x42003800UL)
#define TC7_BASE              (0x42003C00UL)
#define ADC_BASE              (0x42004000UL)
#define AC_BASE               (0x42004400UL)
#define DAC_BASE              (0x42004800UL)
#define PTC_BASE              (0x42004C00UL)
#define I2S_BASE              (0x42005000UL)

// GPIO Port groups
#define PORT_GROUPA           0
#define PORT_GROUPB           1

// ============================================================================
// INTERRUPT NUMBERS
// ============================================================================

typedef enum {
  Reset_IRQn              = -15,
  NonMaskableInt_IRQn     = -14,
  HardFault_IRQn          = -13,
  SVCall_IRQn             = -5,
  PendSV_IRQn             = -2,
  SysTick_IRQn            = -1,

  // SAMD21 Peripheral IRQs
  PM_IRQn                 = 0,
  SYSCTRL_IRQn            = 1,
  WDT_IRQn                = 2,
  RTC_IRQn                = 3,
  EIC_IRQn                = 4,
  NVMCTRL_IRQn            = 5,
  DMAC_IRQn               = 6,
  USB_IRQn                = 7,
  EVSYS_IRQn              = 8,
  SERCOM0_IRQn            = 9,
  SERCOM1_IRQn            = 10,
  SERCOM2_IRQn            = 11,
  SERCOM3_IRQn            = 12,
  SERCOM4_IRQn            = 13,
  SERCOM5_IRQn            = 14,
  TCC0_IRQn               = 15,
  TCC1_IRQn               = 16,
  TCC2_IRQn               = 17,
  TC3_IRQn                = 18,
  TC4_IRQn                = 19,
  TC5_IRQn                = 20,
  TC6_IRQn                = 21,
  TC7_IRQn                = 22,
  ADC_IRQn                = 23,
  AC_IRQn                 = 24,
  DAC_IRQn                = 25,
  PTC_IRQn                = 26,
  I2S_IRQn                = 27
} IRQn_Type;

// ============================================================================
// PERIPHERAL REGISTER STRUCTURES
// ============================================================================

// PORT - I/O Pin Controller
typedef struct {
  volatile uint32_t DIR;        // 0x00 Data Direction
  volatile uint32_t DIRCLR;     // 0x04 Data Direction Clear
  volatile uint32_t DIRSET;     // 0x08 Data Direction Set
  volatile uint32_t DIRTGL;     // 0x0C Data Direction Toggle
  volatile uint32_t OUT;        // 0x10 Data Output Value
  volatile uint32_t OUTCLR;     // 0x14 Data Output Value Clear
  volatile uint32_t OUTSET;     // 0x18 Data Output Value Set
  volatile uint32_t OUTTGL;     // 0x1C Data Output Value Toggle
  volatile uint32_t IN;         // 0x20 Data Input Value
  volatile uint32_t CTRL;       // 0x24 Control
  volatile uint32_t WRCONFIG;   // 0x28 Write Configuration
  uint32_t RESERVED[1];
  volatile uint8_t  PMUX[16];   // 0x30 Peripheral Multiplexing
  volatile uint8_t  PINCFG[32]; // 0x40 Pin Configuration
  uint32_t RESERVED2[16];
} PortGroup;

typedef struct {
  PortGroup Group[2];           // PORT has 2 groups (A and B)
} Port;

#define PORT ((Port*)PORT_BASE)

// PORT PINCFG bits
#define PORT_PINCFG_PMUXEN_Pos  0
#define PORT_PINCFG_PMUXEN      (1 << PORT_PINCFG_PMUXEN_Pos)
#define PORT_PINCFG_INEN_Pos    1
#define PORT_PINCFG_INEN        (1 << PORT_PINCFG_INEN_Pos)
#define PORT_PINCFG_PULLEN_Pos  2
#define PORT_PINCFG_PULLEN      (1 << PORT_PINCFG_PULLEN_Pos)
#define PORT_PINCFG_DRVSTR_Pos  6
#define PORT_PINCFG_DRVSTR      (1 << PORT_PINCFG_DRVSTR_Pos)

// PM - Power Manager
typedef struct {
  volatile uint8_t  CTRL;       // 0x00 Control
  volatile uint8_t  SLEEP;      // 0x01 Sleep Mode
  uint8_t RESERVED1[6];
  volatile uint8_t  CPUSEL;     // 0x08 CPU Clock Select
  volatile uint8_t  APBASEL;    // 0x09 APBA Clock Select
  volatile uint8_t  APBBSEL;    // 0x0A APBB Clock Select
  volatile uint8_t  APBCSEL;    // 0x0B APBC Clock Select
  uint8_t RESERVED2[8];
  volatile uint32_t AHBMASK;    // 0x14 AHB Mask
  volatile uint32_t APBAMASK;   // 0x18 APBA Mask
  volatile uint32_t APBBMASK;   // 0x1C APBB Mask
  volatile uint32_t APBCMASK;   // 0x20 APBC Mask
  uint8_t RESERVED3[16];
  volatile uint8_t  INTENCLR;   // 0x34 Interrupt Enable Clear
  volatile uint8_t  INTENSET;   // 0x35 Interrupt Enable Set
  volatile uint8_t  INTFLAG;    // 0x36 Interrupt Flag Status and Clear
  uint8_t RESERVED4[1];
  volatile uint8_t  RCAUSE;     // 0x38 Reset Cause
} Pm;

#define PM ((Pm*)PM_BASE)

// PM APBBMASK bits
#define PM_APBBMASK_PORT_Pos    3
#define PM_APBBMASK_PORT        (1 << PM_APBBMASK_PORT_Pos)

// PM APBCMASK bits
#define PM_APBCMASK_SERCOM0_Pos 2
#define PM_APBCMASK_SERCOM0     (1 << PM_APBCMASK_SERCOM0_Pos)
#define PM_APBCMASK_SERCOM3_Pos 5
#define PM_APBCMASK_SERCOM3     (1 << PM_APBCMASK_SERCOM3_Pos)
#define PM_APBCMASK_TCC0_Pos    8
#define PM_APBCMASK_TCC0        (1 << PM_APBCMASK_TCC0_Pos)
#define PM_APBCMASK_TC3_Pos     11
#define PM_APBCMASK_TC3         (1 << PM_APBCMASK_TC3_Pos)
#define PM_APBCMASK_TC4_Pos     12
#define PM_APBCMASK_TC4         (1 << PM_APBCMASK_TC4_Pos)

// GCLK - Generic Clock Controller
typedef struct {
  volatile uint8_t  CTRL;       // 0x00 Control
  volatile uint8_t  STATUS;     // 0x01 Status
  volatile uint16_t CLKCTRL;    // 0x02 Generic Clock Control
  volatile uint32_t GENCTRL;    // 0x04 Generic Clock Generator Control
  volatile uint32_t GENDIV;     // 0x08 Generic Clock Generator Division
} Gclk;

#define GCLK ((Gclk*)GCLK_BASE)

// GCLK CTRL bits
#define GCLK_CTRL_SWRST_Pos     0
#define GCLK_CTRL_SWRST         (1 << GCLK_CTRL_SWRST_Pos)

// GCLK STATUS bits
#define GCLK_STATUS_SYNCBUSY_Pos 7
#define GCLK_STATUS_SYNCBUSY    (1 << GCLK_STATUS_SYNCBUSY_Pos)

// GCLK CLKCTRL bits
#define GCLK_CLKCTRL_ID_Pos     0
#define GCLK_CLKCTRL_ID_Msk     (0x3F << GCLK_CLKCTRL_ID_Pos)
#define GCLK_CLKCTRL_GEN_Pos    8
#define GCLK_CLKCTRL_GEN_Msk    (0x0F << GCLK_CLKCTRL_GEN_Pos)
#define GCLK_CLKCTRL_CLKEN_Pos  14
#define GCLK_CLKCTRL_CLKEN      (1 << GCLK_CLKCTRL_CLKEN_Pos)
#define GCLK_CLKCTRL_WRTLOCK_Pos 15
#define GCLK_CLKCTRL_WRTLOCK    (1 << GCLK_CLKCTRL_WRTLOCK_Pos)

// GCLK Generator IDs
#define GCLK_CLKCTRL_ID_DFLL48  0
#define GCLK_CLKCTRL_ID_SERCOM3_CORE 23
#define GCLK_CLKCTRL_ID_TC3_TC4 27
#define GCLK_CLKCTRL_ID_TCC0_TCC1 26

// GCLK GENCTRL bits
#define GCLK_GENCTRL_ID_Pos     0
#define GCLK_GENCTRL_ID_Msk     (0x0F << GCLK_GENCTRL_ID_Pos)
#define GCLK_GENCTRL_SRC_Pos    8
#define GCLK_GENCTRL_SRC_Msk    (0x1F << GCLK_GENCTRL_SRC_Pos)
#define GCLK_GENCTRL_GENEN_Pos  16
#define GCLK_GENCTRL_GENEN      (1 << GCLK_GENCTRL_GENEN_Pos)
#define GCLK_GENCTRL_IDC_Pos    17
#define GCLK_GENCTRL_IDC        (1 << GCLK_GENCTRL_IDC_Pos)
#define GCLK_GENCTRL_OOV_Pos    18
#define GCLK_GENCTRL_OOV        (1 << GCLK_GENCTRL_OOV_Pos)
#define GCLK_GENCTRL_OE_Pos     19
#define GCLK_GENCTRL_OE         (1 << GCLK_GENCTRL_OE_Pos)
#define GCLK_GENCTRL_DIVSEL_Pos 20
#define GCLK_GENCTRL_DIVSEL     (1 << GCLK_GENCTRL_DIVSEL_Pos)
#define GCLK_GENCTRL_RUNSTDBY_Pos 21
#define GCLK_GENCTRL_RUNSTDBY   (1 << GCLK_GENCTRL_RUNSTDBY_Pos)

// GCLK Source selection
#define GCLK_SOURCE_XOSC        0
#define GCLK_SOURCE_GCLKIN      1
#define GCLK_SOURCE_GCLKGEN1    2
#define GCLK_SOURCE_OSCULP32K   3
#define GCLK_SOURCE_OSC32K      4
#define GCLK_SOURCE_XOSC32K     5
#define GCLK_SOURCE_OSC8M       6
#define GCLK_SOURCE_DFLL48M     7
#define GCLK_SOURCE_DPLL96M     8

// SYSCTRL - System Controller
typedef struct {
  volatile uint32_t INTENCLR;   // 0x00
  volatile uint32_t INTENSET;   // 0x04
  volatile uint32_t INTFLAG;    // 0x08
  volatile uint32_t PCLKSR;     // 0x0C Power and Clocks Status
  volatile uint16_t XOSC;       // 0x10 External Oscillator Control
  uint16_t RESERVED1[1];
  volatile uint16_t XOSC32K;    // 0x14 32kHz External Crystal Oscillator
  uint16_t RESERVED2[1];
  volatile uint32_t OSC32K;     // 0x18 32kHz Internal Oscillator
  volatile uint8_t  OSCULP32K;  // 0x1C 32kHz Ultra Low Power Internal Oscillator
  uint8_t RESERVED3[3];
  volatile uint32_t OSC8M;      // 0x20 8MHz Internal Oscillator
  volatile uint32_t DFLLCTRL;   // 0x24 DFLL48M Control
  volatile uint32_t DFLLVAL;    // 0x28 DFLL48M Value
  volatile uint32_t DFLLMUL;    // 0x2C DFLL48M Multiplier
  volatile uint32_t DFLLSYNC;   // 0x30 DFLL48M Synchronization
  volatile uint32_t BOD33;      // 0x34 3.3V Brown-Out Detector
  uint32_t RESERVED4[2];
  volatile uint16_t VREG;       // 0x3C Voltage Regulator System
  uint16_t RESERVED5[1];
  volatile uint32_t VREF;       // 0x40 Voltage References System
  volatile uint32_t DPLLCTRLA;  // 0x44 DPLL Control A
  volatile uint32_t DPLLRATIO;  // 0x48 DPLL Ratio Control
  volatile uint32_t DPLLCTRLB;  // 0x4C DPLL Control B
  volatile uint32_t DPLLSTATUS; // 0x50 DPLL Status
} Sysctrl;

#define SYSCTRL ((Sysctrl*)SYSCTRL_BASE)

// SYSCTRL DFLLCTRL bits
#define SYSCTRL_DFLLCTRL_ENABLE_Pos   1
#define SYSCTRL_DFLLCTRL_ENABLE       (1 << SYSCTRL_DFLLCTRL_ENABLE_Pos)
#define SYSCTRL_DFLLCTRL_MODE_Pos     2
#define SYSCTRL_DFLLCTRL_MODE         (1 << SYSCTRL_DFLLCTRL_MODE_Pos)
#define SYSCTRL_DFLLCTRL_STABLE_Pos   3
#define SYSCTRL_DFLLCTRL_STABLE       (1 << SYSCTRL_DFLLCTRL_STABLE_Pos)
#define SYSCTRL_DFLLCTRL_ONDEMAND_Pos 7
#define SYSCTRL_DFLLCTRL_ONDEMAND     (1 << SYSCTRL_DFLLCTRL_ONDEMAND_Pos)

// TC - Timer/Counter (16-bit mode)
typedef struct {
  volatile uint16_t CTRLA;      // 0x00 Control A
  volatile uint16_t READREQ;    // 0x02 Read Request
  volatile uint8_t  CTRLBCLR;   // 0x04 Control B Clear
  volatile uint8_t  CTRLBSET;   // 0x05 Control B Set
  volatile uint8_t  CTRLC;      // 0x06 Control C
  uint8_t RESERVED1[1];
  volatile uint8_t  DBGCTRL;    // 0x08 Debug Control
  uint8_t RESERVED2[1];
  volatile uint16_t EVCTRL;     // 0x0A Event Control
  volatile uint8_t  INTENCLR;   // 0x0C Interrupt Enable Clear
  volatile uint8_t  INTENSET;   // 0x0D Interrupt Enable Set
  volatile uint8_t  INTFLAG;    // 0x0E Interrupt Flag Status and Clear
  volatile uint8_t  STATUS;     // 0x0F Status
  volatile uint16_t COUNT;      // 0x10 Counter Value (16-bit mode)
  uint16_t RESERVED3[3];
  volatile uint16_t CC[2];      // 0x18 Compare/Capture (16-bit mode)
} Tc;

#define TC3 ((Tc*)TC3_BASE)
#define TC4 ((Tc*)TC4_BASE)

// TCC - Timer/Counter for Control (PWM)
typedef struct {
  volatile uint32_t CTRLA;      // 0x00 Control A
  volatile uint32_t CTRLBCLR;   // 0x04 Control B Clear
  volatile uint32_t CTRLBSET;   // 0x08 Control B Set
  volatile uint32_t SYNCBUSY;   // 0x0C Synchronization Busy
  volatile uint32_t FCTRLA;     // 0x10 Recoverable Fault A Configuration
  volatile uint32_t FCTRLB;     // 0x14 Recoverable Fault B Configuration
  volatile uint32_t WEXCTRL;    // 0x18 Waveform Extension Configuration
  volatile uint32_t DRVCTRL;    // 0x1C Driver Control
  uint32_t RESERVED1[2];
  volatile uint8_t  DBGCTRL;    // 0x28 Debug Control
  uint8_t RESERVED2[3];
  volatile uint32_t EVCTRL;     // 0x2C Event Control
  volatile uint32_t INTENCLR;   // 0x30 Interrupt Enable Clear
  volatile uint32_t INTENSET;   // 0x34 Interrupt Enable Set
  volatile uint32_t INTFLAG;    // 0x38 Interrupt Flag Status and Clear
  volatile uint32_t STATUS;     // 0x3C Status
  volatile uint32_t COUNT;      // 0x40 Counter Value
  volatile uint16_t PATT;       // 0x44 Pattern
  uint16_t RESERVED3[1];
  volatile uint32_t WAVE;       // 0x48 Waveform Control
  volatile uint32_t PER;        // 0x4C Period
  volatile uint32_t CC[4];      // 0x50-0x5C Compare/Capture
  uint32_t RESERVED4[16];
  volatile uint16_t PATTB;      // 0xA0 Pattern Buffer
  uint16_t RESERVED5[1];
  volatile uint32_t WAVEB;      // 0xA4 Waveform Control Buffer
  volatile uint32_t PERB;       // 0xA8 Period Buffer
  volatile uint32_t CCB[4];     // 0xAC-0xB8 Compare/Capture Buffer
} Tcc;

#define TCC0 ((Tcc*)TCC0_BASE)
#define TCC1 ((Tcc*)TCC1_BASE)
#define TCC2 ((Tcc*)TCC2_BASE)

// TC CTRLA bits
#define TC_CTRLA_SWRST_Pos      0
#define TC_CTRLA_SWRST          (1 << TC_CTRLA_SWRST_Pos)
#define TC_CTRLA_ENABLE_Pos     1
#define TC_CTRLA_ENABLE         (1 << TC_CTRLA_ENABLE_Pos)
#define TC_CTRLA_MODE_Pos       2
#define TC_CTRLA_MODE_Msk       (0x3 << TC_CTRLA_MODE_Pos)
#define TC_CTRLA_MODE_COUNT16   (0x0 << TC_CTRLA_MODE_Pos)
#define TC_CTRLA_WAVEGEN_Pos    5
#define TC_CTRLA_WAVEGEN_Msk    (0x3 << TC_CTRLA_WAVEGEN_Pos)
#define TC_CTRLA_WAVEGEN_MFRQ   (0x1 << TC_CTRLA_WAVEGEN_Pos)
#define TC_CTRLA_PRESCALER_Pos  8
#define TC_CTRLA_PRESCALER_Msk  (0x7 << TC_CTRLA_PRESCALER_Pos)
#define TC_CTRLA_PRESCALER_DIV1 (0x0 << TC_CTRLA_PRESCALER_Pos)

// TC INTFLAG bits
#define TC_INTFLAG_OVF_Pos      0
#define TC_INTFLAG_OVF          (1 << TC_INTFLAG_OVF_Pos)
#define TC_INTFLAG_MC0_Pos      4
#define TC_INTFLAG_MC0          (1 << TC_INTFLAG_MC0_Pos)

// TCC - Timer Counter for Control (PWM)
// Note: TCC uses similar structure to TC but with enhanced features
// Tcc type is forward declared earlier in this file

// TCC CTRLA bits
#define TCC_CTRLA_SWRST_Pos      0
#define TCC_CTRLA_SWRST          (1 << TCC_CTRLA_SWRST_Pos)
#define TCC_CTRLA_ENABLE_Pos     1
#define TCC_CTRLA_ENABLE         (1 << TCC_CTRLA_ENABLE_Pos)
#define TCC_CTRLA_PRESCALER_Pos  8
#define TCC_CTRLA_PRESCALER_Msk  (0x7 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV1  (0x0 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV2  (0x1 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV4  (0x2 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV8  (0x3 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV16 (0x4 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV64 (0x5 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV256 (0x6 << TCC_CTRLA_PRESCALER_Pos)
#define TCC_CTRLA_PRESCALER_DIV1024 (0x7 << TCC_CTRLA_PRESCALER_Pos)

// TCC WAVE bits (at offset similar to TC CTRLBSET but different function)
#define TCC_WAVE_WAVEGEN_Pos     0
#define TCC_WAVE_WAVEGEN_Msk     (0x7 << TCC_WAVE_WAVEGEN_Pos)
#define TCC_WAVE_WAVEGEN_NPWM    (0x2 << TCC_WAVE_WAVEGEN_Pos)  // Normal PWM

// GCLK CLKCTRL GEN field values
#define GCLK_CLKCTRL_GEN_GCLK0   (0x0 << GCLK_CLKCTRL_GEN_Pos)
#define GCLK_CLKCTRL_GEN_GCLK1   (0x1 << GCLK_CLKCTRL_GEN_Pos)

// SERCOM - Serial Communication Interface (USART mode)
typedef struct {
  volatile uint32_t CTRLA;      // 0x00 Control A
  volatile uint32_t CTRLB;      // 0x04 Control B
  uint32_t RESERVED1[1];
  volatile uint16_t BAUD;       // 0x0C Baud Rate
  volatile uint8_t  RXPL;       // 0x0E Receive Pulse Length
  uint8_t RESERVED2[5];
  volatile uint8_t  INTENCLR;   // 0x14 Interrupt Enable Clear
  uint8_t RESERVED3[1];
  volatile uint8_t  INTENSET;   // 0x16 Interrupt Enable Set
  uint8_t RESERVED4[1];
  volatile uint8_t  INTFLAG;    // 0x18 Interrupt Flag Status and Clear
  uint8_t RESERVED5[1];
  volatile uint16_t STATUS;     // 0x1A Status
  volatile uint32_t SYNCBUSY;   // 0x1C Synchronization Busy
  uint32_t RESERVED6[2];
  volatile uint16_t DATA;       // 0x28 Data
  uint16_t RESERVED7[1];
  volatile uint8_t  DBGCTRL;    // 0x30 Debug Control
} Sercom;

#define SERCOM3 ((Sercom*)SERCOM3_BASE)

// SERCOM CTRLA bits (USART mode)
#define SERCOM_USART_CTRLA_SWRST_Pos    0
#define SERCOM_USART_CTRLA_SWRST        (1 << SERCOM_USART_CTRLA_SWRST_Pos)
#define SERCOM_USART_CTRLA_ENABLE_Pos   1
#define SERCOM_USART_CTRLA_ENABLE       (1 << SERCOM_USART_CTRLA_ENABLE_Pos)
#define SERCOM_USART_CTRLA_MODE_Pos     2
#define SERCOM_USART_CTRLA_MODE_Msk     (0x7 << SERCOM_USART_CTRLA_MODE_Pos)
#define SERCOM_USART_CTRLA_MODE_USART_INT_CLK (0x1 << SERCOM_USART_CTRLA_MODE_Pos)
#define SERCOM_USART_CTRLA_TXPO_Pos     16
#define SERCOM_USART_CTRLA_TXPO_Msk     (0x3 << SERCOM_USART_CTRLA_TXPO_Pos)
#define SERCOM_USART_CTRLA_TXPO_PAD0    (0x0 << SERCOM_USART_CTRLA_TXPO_Pos)
#define SERCOM_USART_CTRLA_RXPO_Pos     20
#define SERCOM_USART_CTRLA_RXPO_Msk     (0x3 << SERCOM_USART_CTRLA_RXPO_Pos)
#define SERCOM_USART_CTRLA_RXPO_PAD1    (0x1 << SERCOM_USART_CTRLA_RXPO_Pos)
#define SERCOM_USART_CTRLA_DORD_Pos     30
#define SERCOM_USART_CTRLA_DORD         (1 << SERCOM_USART_CTRLA_DORD_Pos)

// SERCOM CTRLB bits (USART mode)
#define SERCOM_USART_CTRLB_CHSIZE_Pos   0
#define SERCOM_USART_CTRLB_CHSIZE_8BIT  (0x0 << SERCOM_USART_CTRLB_CHSIZE_Pos)
#define SERCOM_USART_CTRLB_TXEN_Pos     16
#define SERCOM_USART_CTRLB_TXEN         (1 << SERCOM_USART_CTRLB_TXEN_Pos)
#define SERCOM_USART_CTRLB_RXEN_Pos     17
#define SERCOM_USART_CTRLB_RXEN         (1 << SERCOM_USART_CTRLB_RXEN_Pos)

// SERCOM INTFLAG bits (USART mode)
#define SERCOM_USART_INTFLAG_DRE_Pos    0
#define SERCOM_USART_INTFLAG_DRE        (1 << SERCOM_USART_INTFLAG_DRE_Pos)
#define SERCOM_USART_INTFLAG_TXC_Pos    1
#define SERCOM_USART_INTFLAG_TXC        (1 << SERCOM_USART_INTFLAG_TXC_Pos)
#define SERCOM_USART_INTFLAG_RXC_Pos    2
#define SERCOM_USART_INTFLAG_RXC        (1 << SERCOM_USART_INTFLAG_RXC_Pos)

// NVMCTRL - Non-Volatile Memory Controller
typedef struct {
  volatile uint32_t CTRLA;      // 0x00 Control A
  volatile uint32_t CTRLB;      // 0x04 Control B
  volatile uint32_t PARAM;      // 0x08 NVM Parameter
  volatile uint8_t  INTENCLR;   // 0x0C Interrupt Enable Clear
  uint8_t RESERVED1[3];
  volatile uint8_t  INTENSET;   // 0x10 Interrupt Enable Set
  uint8_t RESERVED2[3];
  volatile uint8_t  INTFLAG;    // 0x14 Interrupt Flag Status and Clear
  uint8_t RESERVED3[3];
  volatile uint16_t STATUS;     // 0x18 Status
  uint16_t RESERVED4[1];
  volatile uint32_t ADDR;       // 0x1C Address
  volatile uint16_t LOCK;       // 0x20 Lock Section
} Nvmctrl;

#define NVMCTRL ((Nvmctrl*)NVMCTRL_BASE)

// NVMCTRL CTRLA bits
#define NVMCTRL_CTRLA_CMD_Pos   0
#define NVMCTRL_CTRLA_CMD_Msk   (0x7F << NVMCTRL_CTRLA_CMD_Pos)
#define NVMCTRL_CTRLA_CMDEX_Pos 8
#define NVMCTRL_CTRLA_CMDEX_Msk (0xFF << NVMCTRL_CTRLA_CMDEX_Pos)
#define NVMCTRL_CTRLA_CMDEX_KEY (0xA5 << NVMCTRL_CTRLA_CMDEX_Pos)

// NVMCTRL Commands
#define NVMCTRL_CMD_ER          0x02  // Erase Row
#define NVMCTRL_CMD_WP          0x04  // Write Page
#define NVMCTRL_CMD_EAR         0x05  // Erase Auxiliary Row
#define NVMCTRL_CMD_WAP         0x06  // Write Auxiliary Page
#define NVMCTRL_CMD_PBC         0x44  // Page Buffer Clear

// NVMCTRL INTFLAG bits
#define NVMCTRL_INTFLAG_READY_Pos 0
#define NVMCTRL_INTFLAG_READY   (1 << NVMCTRL_INTFLAG_READY_Pos)

// EIC - External Interrupt Controller
typedef struct {
  volatile uint8_t  CTRL;       // 0x00 Control
  volatile uint8_t  STATUS;     // 0x01 Status
  volatile uint8_t  NMICTRL;    // 0x02 NMI Control
  volatile uint8_t  NMIFLAG;    // 0x03 NMI Flag
  volatile uint32_t EVCTRL;     // 0x04 Event Control
  volatile uint32_t INTENCLR;   // 0x08 Interrupt Enable Clear
  volatile uint32_t INTENSET;   // 0x0C Interrupt Enable Set
  volatile uint32_t INTFLAG;    // 0x10 Interrupt Flag Status and Clear
  volatile uint32_t WAKEUP;     // 0x14 Wakeup Enable
  volatile uint32_t CONFIG[2];  // 0x18 Configuration 0-1
} Eic;

#define EIC ((Eic*)EIC_BASE)

// EIC CTRL bits
#define EIC_CTRL_SWRST_Pos      0
#define EIC_CTRL_SWRST          (1 << EIC_CTRL_SWRST_Pos)
#define EIC_CTRL_ENABLE_Pos     1
#define EIC_CTRL_ENABLE         (1 << EIC_CTRL_ENABLE_Pos)

// EIC CONFIG register - 4 bits per channel (SENSE0-7 in CONFIG[0], SENSE8-15 in CONFIG[1])
#define EIC_CONFIG_SENSE_Pos(n)     ((n) * 4)
#define EIC_CONFIG_SENSE_Msk(n)     (0xF << EIC_CONFIG_SENSE_Pos(n))
#define EIC_CONFIG_FILTEN_Pos(n)    (((n) * 4) + 3)
#define EIC_CONFIG_FILTEN(n)        (1 << EIC_CONFIG_FILTEN_Pos(n))

// EIC SENSE modes
#define EIC_CONFIG_SENSE_NONE       0x0
#define EIC_CONFIG_SENSE_RISE       0x1
#define EIC_CONFIG_SENSE_FALL       0x2
#define EIC_CONFIG_SENSE_BOTH       0x3
#define EIC_CONFIG_SENSE_HIGH       0x4
#define EIC_CONFIG_SENSE_LOW        0x5

// PM APBAMASK bits for EIC
#define PM_APBAMASK_EIC_Pos     2
#define PM_APBAMASK_EIC         (1 << PM_APBAMASK_EIC_Pos)

// GCLK ID for EIC
#define GCLK_CLKCTRL_ID_EIC     3

#endif // SAMD21_H
