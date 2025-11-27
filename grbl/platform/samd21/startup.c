/*
  startup.c - SAMD21 startup code
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Startup code for SAMD21G18A
  - Reset handler
  - Vector table
  - BSS/Data initialization
  - Clock initialization (48 MHz from DFLL48M)
*/

#include <stdint.h>
#include "samd21.h"

// ============================================================================
// EXTERNAL SYMBOLS (from linker script)
// ============================================================================

extern uint32_t _estack;      // End of stack (initial SP value)
extern uint32_t _sdata;       // Start of .data in RAM
extern uint32_t _edata;       // End of .data in RAM
extern uint32_t _sidata;      // Start of .data in ROM
extern uint32_t _sbss;        // Start of .bss
extern uint32_t _ebss;        // End of .bss

// ============================================================================
// FUNCTION PROTOTYPES
// ============================================================================

extern int main(void);

void Reset_Handler(void);
void Default_Handler(void);

// Cortex-M0+ Core Handlers
void NMI_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void HardFault_Handler(void)          __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)             __attribute__((weak, alias("Default_Handler")));
void SysTick_Handler(void)            __attribute__((weak, alias("Default_Handler")));

// SAMD21 Peripheral Handlers
void PM_Handler(void)                 __attribute__((weak, alias("Default_Handler")));
void SYSCTRL_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void WDT_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void RTC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void EIC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void NVMCTRL_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void DMAC_Handler(void)               __attribute__((weak, alias("Default_Handler")));
void USB_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void EVSYS_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void SERCOM0_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void SERCOM1_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void SERCOM2_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void SERCOM3_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void SERCOM4_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void SERCOM5_Handler(void)            __attribute__((weak, alias("Default_Handler")));
void TCC0_Handler(void)               __attribute__((weak, alias("Default_Handler")));
void TCC1_Handler(void)               __attribute__((weak, alias("Default_Handler")));
void TCC2_Handler(void)               __attribute__((weak, alias("Default_Handler")));
void TC3_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void TC4_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void TC5_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void TC6_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void TC7_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void ADC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void AC_Handler(void)                 __attribute__((weak, alias("Default_Handler")));
void DAC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void PTC_Handler(void)                __attribute__((weak, alias("Default_Handler")));
void I2S_Handler(void)                __attribute__((weak, alias("Default_Handler")));

// ============================================================================
// VECTOR TABLE
// ============================================================================

__attribute__((section(".isr_vector")))
void (* const vector_table[])(void) = {
  // Cortex-M0+ System Handlers
  (void (*)(void))&_estack,             // 0  Initial Stack Pointer
  Reset_Handler,                         // 1  Reset Handler
  NMI_Handler,                          // 2  NMI Handler
  HardFault_Handler,                    // 3  Hard Fault Handler
  0,                                    // 4  Reserved
  0,                                    // 5  Reserved
  0,                                    // 6  Reserved
  0,                                    // 7  Reserved
  0,                                    // 8  Reserved
  0,                                    // 9  Reserved
  0,                                    // 10 Reserved
  SVC_Handler,                          // 11 SVCall Handler
  0,                                    // 12 Reserved
  0,                                    // 13 Reserved
  PendSV_Handler,                       // 14 PendSV Handler
  SysTick_Handler,                      // 15 SysTick Handler

  // SAMD21 Peripheral Handlers
  PM_Handler,                           // 16 Power Manager
  SYSCTRL_Handler,                      // 17 System Control
  WDT_Handler,                          // 18 Watchdog Timer
  RTC_Handler,                          // 19 Real Time Counter
  EIC_Handler,                          // 20 External Interrupt Controller
  NVMCTRL_Handler,                      // 21 Non-Volatile Memory Controller
  DMAC_Handler,                         // 22 Direct Memory Access Controller
  USB_Handler,                          // 23 Universal Serial Bus
  EVSYS_Handler,                        // 24 Event System
  SERCOM0_Handler,                      // 25 Serial Communication Interface 0
  SERCOM1_Handler,                      // 26 Serial Communication Interface 1
  SERCOM2_Handler,                      // 27 Serial Communication Interface 2
  SERCOM3_Handler,                      // 28 Serial Communication Interface 3
  SERCOM4_Handler,                      // 29 Serial Communication Interface 4
  SERCOM5_Handler,                      // 30 Serial Communication Interface 5
  TCC0_Handler,                         // 31 Timer Counter Control 0
  TCC1_Handler,                         // 32 Timer Counter Control 1
  TCC2_Handler,                         // 33 Timer Counter Control 2
  TC3_Handler,                          // 34 Timer Counter 3
  TC4_Handler,                          // 35 Timer Counter 4
  TC5_Handler,                          // 36 Timer Counter 5
  TC6_Handler,                          // 37 Timer Counter 6
  TC7_Handler,                          // 38 Timer Counter 7
  ADC_Handler,                          // 39 Analog-to-Digital Converter
  AC_Handler,                           // 40 Analog Comparator
  DAC_Handler,                          // 41 Digital-to-Analog Converter
  PTC_Handler,                          // 42 Peripheral Touch Controller
  I2S_Handler,                          // 43 Inter-IC Sound Interface
};

// ============================================================================
// SYSTEM INITIALIZATION (Clock configuration)
// ============================================================================

void SystemInit(void) {
  // Configure NVM wait states for 48 MHz operation (1 wait state required)
  NVMCTRL->CTRLB = (NVMCTRL->CTRLB & ~(0xF << 1)) | (1 << 1);

  // Step 1: Configure OSC8M to run at 8 MHz (always on, not on-demand)
  // Bit 4 = ONDEMAND (0 = always on), Bit 5 = RUNSTDBY (1 = run in standby)
  SYSCTRL->OSC8M = SYSCTRL_OSC8M_ENABLE | SYSCTRL_OSC8M_PRESC_DIV1 | (0x2 << 4);
  while (!(SYSCTRL->PCLKSR & (1 << 3))); // Wait for OSC8M ready

  // Step 2: Configure GCLK_GEN1 to use OSC8M (temporary source for DFLL reference)
  GCLK->GENDIV = (1 << GCLK_GENCTRL_ID_Pos) | (1 << 16); // GEN1, div=1
  GCLK->GENCTRL = (1 << GCLK_GENCTRL_ID_Pos) |
                  (GCLK_SOURCE_OSC8M << GCLK_GENCTRL_SRC_Pos) |
                  GCLK_GENCTRL_GENEN;
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Step 3: Enable DFLL48M in open-loop mode first
  SYSCTRL->DFLLCTRL = 0; // Ensure disabled
  while (!(SYSCTRL->PCLKSR & SYSCTRL_PCLKSR_DFLLRDY));

  // Load calibration values from NVM (factory calibration at 0x00806020)
  uint32_t coarse = (*(uint32_t*)NVMCTRL_CALIBRATION_AREA_ADDR >> 26) & 0x3F;
  SYSCTRL->DFLLVAL = (coarse << SYSCTRL_DFLLVAL_COARSE_Pos) | (512 << SYSCTRL_DFLLVAL_FINE_Pos);

  // Enable DFLL in open-loop mode
  SYSCTRL->DFLLCTRL = SYSCTRL_DFLLCTRL_ENABLE;
  while (!(SYSCTRL->PCLKSR & SYSCTRL_PCLKSR_DFLLRDY));

  // Step 4: Configure GCLK_GEN0 to use DFLL48M as source
  GCLK->GENDIV = (0 << GCLK_GENCTRL_ID_Pos); // GEN0, div=1
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  GCLK->GENCTRL = (0 << GCLK_GENCTRL_ID_Pos) |
                  (GCLK_SOURCE_DFLL48M << GCLK_GENCTRL_SRC_Pos) |
                  GCLK_GENCTRL_GENEN |
                  GCLK_GENCTRL_IDC;
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Now running at 48 MHz!
}

// ============================================================================
// RESET HANDLER
// ============================================================================

void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Copy .data section from Flash to RAM
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // Zero-initialize .bss section
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  // Initialize system clocks (48 MHz)
  SystemInit();

  // Call main program
  main();

  // Infinite loop if main returns
  while (1) {
    __asm__ volatile ("nop");
  }
}

// ============================================================================
// DEFAULT HANDLER
// ============================================================================

void Default_Handler(void) {
  // Infinite loop on unhandled interrupt
  while (1) {
    __asm__ volatile ("nop");
  }
}
