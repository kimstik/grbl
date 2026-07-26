/*
  startup.c - SAMD21 startup code
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT
*/

#include <stdint.h>
#include "samd21.h"
#include "core_cm0plus.h"

// EXTERNAL SYMBOLS (from linker script)

extern uint32_t _estack;      // End of stack (initial SP value)
extern uint32_t _sdata;       // Start of .data in RAM
extern uint32_t _edata;       // End of .data in RAM
extern uint32_t _sidata;      // Start of .data in ROM
extern uint32_t _sbss;        // Start of .bss
extern uint32_t _ebss;        // End of .bss

// FUNCTION PROTOTYPES

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

// VECTOR TABLE

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

// SYSTEM INITIALIZATION (Clock configuration)

// GRBL_BOOT_INIT (== noinline) - with a single call site (Reset_Handler
// below) LTO used to inline this whole function away, leaving no symbol in
// the RELEASE ELF: byte-for-byte the same `nm` output as a port whose
// clock init is never called at all (BUG #23). Keeping it out-of-line is
// what lets common/init_check.sh prove post-link that the bring-up is
// really in the image. See common/boot_init.h for why this is noinline
// and NOT `used`.
GRBL_BOOT_INIT void SystemInit(void) {
  // Configure NVM wait states for 48 MHz operation (1 wait state required)
  NVMCTRL->CTRLB = (NVMCTRL->CTRLB & ~(0xF << 1)) | (1 << 1);

  // Step 1: Configure OSC8M to run at 8 MHz (always on, not on-demand)
  // Bit 4 = ONDEMAND (0 = always on), Bit 5 = RUNSTDBY (1 = run in standby)
  SYSCTRL->OSC8M = SYSCTRL_OSC8M_ENABLE | SYSCTRL_OSC8M_PRESC_DIV1 | (0x2 << 4);
  while (!(SYSCTRL->PCLKSR & (1 << 3))); // Wait for OSC8M ready

  // Step 2: Enable DFLL48M in open-loop mode
  SYSCTRL->DFLLCTRL = 0; // Ensure disabled
  while (!(SYSCTRL->PCLKSR & SYSCTRL_PCLKSR_DFLLRDY));

  // Load calibration values from NVM (factory calibration at 0x00806020)
  uint32_t coarse = (*(uint32_t*)NVMCTRL_CALIBRATION_AREA_ADDR >> 26) & 0x3F;
  SYSCTRL->DFLLVAL = (coarse << SYSCTRL_DFLLVAL_COARSE_Pos) | (512 << SYSCTRL_DFLLVAL_FINE_Pos);

  // Enable DFLL in open-loop mode
  SYSCTRL->DFLLCTRL = SYSCTRL_DFLLCTRL_ENABLE;
  while (!(SYSCTRL->PCLKSR & SYSCTRL_PCLKSR_DFLLRDY));

  // Step 3: Configure GCLK_GEN0 to use DFLL48M as source
  GCLK->GENDIV = (0 << GCLK_GENCTRL_ID_Pos); // GEN0, div=1
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  GCLK->GENCTRL = (0 << GCLK_GENCTRL_ID_Pos) |
                  (GCLK_SOURCE_DFLL48M << GCLK_GENCTRL_SRC_Pos) |
                  GCLK_GENCTRL_GENEN |
                  GCLK_GENCTRL_IDC;
  while (GCLK->STATUS & GCLK_STATUS_SYNCBUSY);

  // Now running at 48 MHz!
}

// RESET HANDLER

void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Copy .data section from Flash to RAM
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // Data Synchronization Barrier - ensure .data copy completes before BSS init (BUG #13 fix)
  __DSB();

  // Zero-initialize .bss section
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  // Data Synchronization Barrier - ensure BSS init completes before SystemInit (BUG #13 fix)
  __DSB();

  // Point VTOR at this image's vector table (the app links above the rSamba
  // bootloader, so out of reset VTOR still targets the bootloader's table at
  // 0x0). Done before SystemInit so any fault during clock bring-up - and any
  // IRQ enabled later - vectors into this image; linker symbol, not a
  // hard-coded address, so the code works at any (256-byte aligned) link base.
  SCB->VTOR = (uint32_t)vector_table;
  __DSB();

  // Initialize system clocks (48 MHz)
  SystemInit();

  // Start the 1 kHz system timebase now that GCLK0 runs at 48 MHz (SysTick
  // counts CPU cycles, CLKSOURCE=1): feeds SysTick_Handler/hal_millis() and
  // lets _delay_ms() take its tick-polling path instead of the busy-wait
  // fallback. Safe here: VTOR already points at this image's vector table.
  SysTick_Config(CPU_FREQ / 1000u);

  // Demote SysTick to the lowest ARMv6-M priority (3). Every device IRQ in
  // this port (TC3/TC4 stepper, SERCOM3 serial, EIC limits/controls) stays at
  // default priority 0; ARMv6-M does not preempt between equal priorities, so
  // the only effect of priorities is simultaneous-arrival arbitration - which
  // must always favor motion/serial over a bookkeeping tick. A postponed tick
  // merely delays a counter increment (hal_millis tolerates jitter).
  SCB->SHP[1] = (SCB->SHP[1] & ~(0xFFul << 24)) | (0xC0ul << 24); // SHPR3.PRI_15 (SysTick) = 3

  // Call main program
  main();

  // Infinite loop if main returns
  while (1) {
    __asm__ volatile ("nop");
  }
}

// DEFAULT HANDLER

void Default_Handler(void) {
  // Infinite loop on unhandled interrupt
  while (1) {
    __asm__ volatile ("nop");
  }
}
