/*
  startup.c - Startup code for STM32H523
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Interrupt vector table and reset handler for STM32H523C8T6.
*/

#include <stdint.h>
#include "platform.h"

// Linker symbols
extern uint32_t _estack;
extern uint32_t _sidata, _sdata, _edata;
extern uint32_t _sbss, _ebss;

// Main function
extern int main(void);

// Interrupt vector table (defined at the bottom of this file). Forward-declared
// here so Reset_Handler can take its address. KEEP() in script.ld runs at
// link time, but LTO's whole-program IPA deletes an unreferenced vector_table[]
// before codegen, so ltrans never emits a .isr_vector input section for KEEP()
// to match. This address-taking (paired with `used` on the definition below -
// two independently-sufficient, defense-in-depth mechanisms, not both
// required on this toolchain, see CONTRACTS.md S18) is what keeps the table
// alive under -flto. Without either: a RELEASE .bin whose first word is code,
// not the initial SP - the chip cannot boot. DEBUG (no LTO) looks fine.
extern const void *vector_table[];

// REVIEW: ERROR HANDLING - Improved fault handlers for debugging and safety
// Fault handler helper - safe shutdown and indicate fault
static void handle_fault(uint32_t fault_code) {
  // Disable interrupts to prevent further issues
  __disable_irq();

  // Try to safe the system - turn off outputs
  // PA4-6 = stepper enable (set high to disable)
  GPIOA->BSRR = (1 << 4) | (1 << 5) | (1 << 6);

  // PA8 = spindle PWM (set low to stop)
  GPIOA->BSRR = (1 << (8 + 16));

  // Blink LED to indicate fault (PB7 as defined in config.h)
  // Fault code encoded as blink pattern
  while (1) {
    for (uint32_t i = 0; i < fault_code; i++) {
      GPIOB->BSRR = (1 << (7 + 16));  // LED on (PB7)
      for (volatile uint32_t d = 0; d < 200000; d++);
      GPIOB->BSRR = (1 << 7);         // LED off (PB7)
      for (volatile uint32_t d = 0; d < 200000; d++);
    }
    for (volatile uint32_t d = 0; d < 2000000; d++);  // Long pause
  }
}

// Default handler (infinite loop)
void Default_Handler(void) {
  handle_fault(9);  // Fault code 9 = unhandled interrupt
}

// Reset handler - copies data, clears BSS, calls main
void Reset_Handler(void) {
  uint32_t *src, *dst;

  // Point VTOR at this image's vector table. Two jobs, both load-bearing:
  //   1. It is the real code reference that survives LTO and forces the table
  //      into .isr_vector (BUG #21).
  //   2. It makes the image bootloader-offset-robust: if something jumps here
  //      with VTOR still pointing at a bootloader table, we retarget it.
  SCB->VTOR = (uint32_t)vector_table;

  // Copy .data section from flash to RAM
  src = &_sidata;
  dst = &_sdata;
  while (dst < &_edata) {
    *dst++ = *src++;
  }

  // Zero .bss section
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }

  // Call main
  main();

  // Should never return
  while (1);
}

// Critical fault handlers with distinct codes
void HardFault_Handler(void)  { handle_fault(1); }  // HardFault = 1 blink
void MemManage_Handler(void)  { handle_fault(2); }  // MemManage = 2 blinks
void BusFault_Handler(void)   { handle_fault(3); }  // BusFault = 3 blinks
void UsageFault_Handler(void) { handle_fault(4); }  // UsageFault = 4 blinks

// Other handlers - less critical, use default
void NMI_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void DebugMon_Handler(void)         __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)           __attribute__((weak, alias("Default_Handler")));

// SysTick handler - implemented in platform.c
extern void SysTick_Handler(void);

// GRBL interrupt handlers - defined by HAL macros in GRBL code
extern void TIM2_IRQHandler(void);  // Stepper ISR
extern void TIM3_IRQHandler(void);  // Pulse reset ISR
extern void USART1_IRQHandler(void); // Serial ISR

// ============================================================================
// STM32H523 INTERRUPT HANDLERS
// ============================================================================
// All STM32H523-specific peripheral interrupt handlers
// Handlers not explicitly defined will use weak alias to Default_Handler

// External interrupt handlers (used for limit switches and control pins)
void EXTI0_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI1_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI2_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI3_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI4_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI5_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI6_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI7_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI8_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI9_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI10_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void EXTI11_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void EXTI12_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void EXTI13_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void EXTI14_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void EXTI15_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));

// System and peripheral handlers
void WWDG_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void PVD_AVD_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void RTC_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void RTC_S_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void TAMP_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void RAMCFG_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void FLASH_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void FLASH_S_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void GTZC_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void RCC_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void RCC_S_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));

// GPDMA handlers
void GPDMA1_Channel0_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel1_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel2_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel3_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel4_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel5_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel6_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void GPDMA1_Channel7_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));

// Other peripherals
void IWDG_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void SAES_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void ADC1_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void DAC1_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void FDCAN1_IT0_IRQHandler(void)    __attribute__((weak, alias("Default_Handler")));
void FDCAN1_IT1_IRQHandler(void)    __attribute__((weak, alias("Default_Handler")));

// Timer handlers
void TIM1_BRK_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void TIM1_UP_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void TIM1_TRG_COM_IRQHandler(void)  __attribute__((weak, alias("Default_Handler")));
void TIM1_CC_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void TIM4_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));

// I2C and SPI handlers
void I2C1_EV_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void I2C1_ER_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void SPI1_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));

// UART handlers
void USART2_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void LPUART1_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));

// Low-power timer
void LPTIM1_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));

// ============================================================================
// STM32H523 VECTOR TABLE
// ============================================================================
// Correct vector table for STM32H523 (Cortex-M33) with all peripheral IRQs
// Interrupt numbers match the IRQn_Type enum defined in regs.h

// `used` is belt to the VTOR write's braces: it tells LTO/IPA the object is
// live even though nothing in C reads its elements (BUG #21, CONTRACTS.md S18).
__attribute__((section(".isr_vector"), used))
const void *vector_table[] = {
  // ============================================================================
  // Cortex-M33 core interrupts (positions 0-15)
  // ============================================================================
  &_estack,                    // 0:  Initial stack pointer
  Reset_Handler,               // 1:  Reset handler
  NMI_Handler,                 // 2:  NMI handler
  HardFault_Handler,           // 3:  Hard fault handler
  MemManage_Handler,           // 4:  MPU fault handler
  BusFault_Handler,            // 5:  Bus fault handler
  UsageFault_Handler,          // 6:  Usage fault handler
  0,                           // 7:  Reserved
  0,                           // 8:  Reserved
  0,                           // 9:  Reserved
  0,                           // 10: Reserved
  SVC_Handler,                 // 11: SVCall handler
  DebugMon_Handler,            // 12: Debug monitor handler
  0,                           // 13: Reserved
  PendSV_Handler,              // 14: PendSV handler
  SysTick_Handler,             // 15: SysTick handler

  // ============================================================================
  // STM32H523 peripheral interrupts (IRQ 0-60+)
  // ============================================================================
  WWDG_IRQHandler,             // 16: IRQ 0  - Window watchdog
  PVD_AVD_IRQHandler,          // 17: IRQ 1  - PVD/AVD detector
  RTC_IRQHandler,              // 18: IRQ 2  - RTC global interrupt
  RTC_S_IRQHandler,            // 19: IRQ 3  - RTC secure interrupt
  TAMP_IRQHandler,             // 20: IRQ 4  - Tamper
  RAMCFG_IRQHandler,           // 21: IRQ 5  - RAM configuration
  FLASH_IRQHandler,            // 22: IRQ 6  - Flash global interrupt
  FLASH_S_IRQHandler,          // 23: IRQ 7  - Flash secure interrupt
  GTZC_IRQHandler,             // 24: IRQ 8  - Global TrustZone controller
  RCC_IRQHandler,              // 25: IRQ 9  - RCC global interrupt
  RCC_S_IRQHandler,            // 26: IRQ 10 - RCC secure interrupt
  EXTI0_IRQHandler,            // 27: IRQ 11 - EXTI line 0 (X limit switch)
  EXTI1_IRQHandler,            // 28: IRQ 12 - EXTI line 1 (Y limit switch)
  EXTI2_IRQHandler,            // 29: IRQ 13 - EXTI line 2
  EXTI3_IRQHandler,            // 30: IRQ 14 - EXTI line 3 (Reset button)
  EXTI4_IRQHandler,            // 31: IRQ 15 - EXTI line 4 (Feed hold button)
  EXTI5_IRQHandler,            // 32: IRQ 16 - EXTI line 5 (Cycle start button)
  EXTI6_IRQHandler,            // 33: IRQ 17 - EXTI line 6 (Safety door button)
  EXTI7_IRQHandler,            // 34: IRQ 18 - EXTI line 7
  EXTI8_IRQHandler,            // 35: IRQ 19 - EXTI line 8
  EXTI9_IRQHandler,            // 36: IRQ 20 - EXTI line 9
  EXTI10_IRQHandler,           // 37: IRQ 21 - EXTI line 10 (Z limit switch)
  EXTI11_IRQHandler,           // 38: IRQ 22 - EXTI line 11
  EXTI12_IRQHandler,           // 39: IRQ 23 - EXTI line 12
  EXTI13_IRQHandler,           // 40: IRQ 24 - EXTI line 13
  EXTI14_IRQHandler,           // 41: IRQ 25 - EXTI line 14
  EXTI15_IRQHandler,           // 42: IRQ 26 - EXTI line 15
  GPDMA1_Channel0_IRQHandler,  // 43: IRQ 27 - GPDMA1 channel 0
  GPDMA1_Channel1_IRQHandler,  // 44: IRQ 28 - GPDMA1 channel 1
  GPDMA1_Channel2_IRQHandler,  // 45: IRQ 29 - GPDMA1 channel 2
  GPDMA1_Channel3_IRQHandler,  // 46: IRQ 30 - GPDMA1 channel 3
  GPDMA1_Channel4_IRQHandler,  // 47: IRQ 31 - GPDMA1 channel 4
  GPDMA1_Channel5_IRQHandler,  // 48: IRQ 32 - GPDMA1 channel 5
  GPDMA1_Channel6_IRQHandler,  // 49: IRQ 33 - GPDMA1 channel 6
  GPDMA1_Channel7_IRQHandler,  // 50: IRQ 34 - GPDMA1 channel 7
  IWDG_IRQHandler,             // 51: IRQ 35 - Independent watchdog
  SAES_IRQHandler,             // 52: IRQ 36 - Secure AES
  ADC1_IRQHandler,             // 53: IRQ 37 - ADC1 global interrupt
  DAC1_IRQHandler,             // 54: IRQ 38 - DAC1 global interrupt
  FDCAN1_IT0_IRQHandler,       // 55: IRQ 39 - FDCAN1 interrupt 0
  FDCAN1_IT1_IRQHandler,       // 56: IRQ 40 - FDCAN1 interrupt 1
  TIM1_BRK_IRQHandler,         // 57: IRQ 41 - TIM1 break
  TIM1_UP_IRQHandler,          // 58: IRQ 42 - TIM1 update
  TIM1_TRG_COM_IRQHandler,     // 59: IRQ 43 - TIM1 trigger/commutation
  TIM1_CC_IRQHandler,          // 60: IRQ 44 - TIM1 capture/compare
  TIM2_IRQHandler,             // 61: IRQ 45 - TIM2 global (STEPPER ISR)
  TIM3_IRQHandler,             // 62: IRQ 46 - TIM3 global (PULSE RESET ISR)
  I2C1_EV_IRQHandler,          // 63: IRQ 47 - I2C1 event
  I2C1_ER_IRQHandler,          // 64: IRQ 48 - I2C1 error
  SPI1_IRQHandler,             // 65: IRQ 49 - SPI1 global
  0,                           // 66: IRQ 50 - Reserved
  0,                           // 67: IRQ 51 - Reserved
  0,                           // 68: IRQ 52 - Reserved
  USART1_IRQHandler,           // 69: IRQ 53 - USART1 global (SERIAL ISR)
  USART2_IRQHandler,           // 70: IRQ 54 - USART2 global
  0,                           // 71: IRQ 55 - Reserved
  0,                           // 72: IRQ 56 - Reserved
  0,                           // 73: IRQ 57 - Reserved
  LPUART1_IRQHandler,          // 74: IRQ 58 - LPUART1 global
  LPTIM1_IRQHandler,           // 75: IRQ 59 - LPTIM1 global
  TIM4_IRQHandler,             // 76: IRQ 60 - TIM4 global
};
