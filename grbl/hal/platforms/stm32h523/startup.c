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

  // Blink LED to indicate fault (if available on PC13)
  // Fault code encoded as blink pattern
  while (1) {
    for (uint32_t i = 0; i < fault_code; i++) {
      GPIOC->BSRR = (1 << (13 + 16));  // LED on
      for (volatile uint32_t d = 0; d < 200000; d++);
      GPIOC->BSRR = (1 << 13);         // LED off
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

// External interrupt handlers for limit switches
void EXTI0_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI1_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI2_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI3_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI4_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void EXTI9_5_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void EXTI15_10_IRQHandler(void)     __attribute__((weak, alias("Default_Handler")));

// DMA handlers (not used yet)
void DMA1_Channel1_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel2_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel3_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel4_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel5_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel6_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void DMA1_Channel7_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));

// Other peripheral handlers
void ADC1_2_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void USB_HP_CAN1_TX_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void USB_LP_CAN1_RX0_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void CAN1_RX1_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void CAN1_SCE_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void TIM1_BRK_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void TIM1_UP_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void TIM1_TRG_COM_IRQHandler(void)  __attribute__((weak, alias("Default_Handler")));
void TIM1_CC_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void TIM4_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void I2C1_EV_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void I2C1_ER_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void I2C2_EV_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void I2C2_ER_IRQHandler(void)       __attribute__((weak, alias("Default_Handler")));
void SPI1_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void SPI2_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));
void USART2_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void USART3_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void RTC_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void RTCAlarm_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void USBWakeUp_IRQHandler(void)     __attribute__((weak, alias("Default_Handler")));

// Interrupt vector table
__attribute__((section(".isr_vector")))
const void *vector_table[] = {
  // Cortex-M33 core interrupts
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

  // STM32H523 specific interrupts
  0,                           // 16: WWDG
  0,                           // 17: PVD
  0,                           // 18: TAMPER
  RTC_IRQHandler,              // 19: RTC
  0,                           // 20: FLASH
  0,                           // 21: RCC
  EXTI0_IRQHandler,            // 22: EXTI0 (X limit switch)
  EXTI1_IRQHandler,            // 23: EXTI1 (Y limit switch)
  EXTI2_IRQHandler,            // 24: EXTI2
  EXTI3_IRQHandler,            // 25: EXTI3 (Reset button)
  EXTI4_IRQHandler,            // 26: EXTI4 (Feed hold button)
  DMA1_Channel1_IRQHandler,    // 27: DMA1 Channel 1
  DMA1_Channel2_IRQHandler,    // 28: DMA1 Channel 2
  DMA1_Channel3_IRQHandler,    // 29: DMA1 Channel 3
  DMA1_Channel4_IRQHandler,    // 30: DMA1 Channel 4
  DMA1_Channel5_IRQHandler,    // 31: DMA1 Channel 5
  DMA1_Channel6_IRQHandler,    // 32: DMA1 Channel 6
  DMA1_Channel7_IRQHandler,    // 33: DMA1 Channel 7
  ADC1_2_IRQHandler,           // 34: ADC1 and ADC2
  USB_HP_CAN1_TX_IRQHandler,   // 35: USB High Priority or CAN1 TX
  USB_LP_CAN1_RX0_IRQHandler,  // 36: USB Low Priority or CAN1 RX0
  CAN1_RX1_IRQHandler,         // 37: CAN1 RX1
  CAN1_SCE_IRQHandler,         // 38: CAN1 SCE
  EXTI9_5_IRQHandler,          // 39: EXTI9_5 (Cycle start, safety door)
  TIM1_BRK_IRQHandler,         // 40: TIM1 Break
  TIM1_UP_IRQHandler,          // 41: TIM1 Update
  TIM1_TRG_COM_IRQHandler,     // 42: TIM1 Trigger and Commutation
  TIM1_CC_IRQHandler,          // 43: TIM1 Capture Compare
  TIM2_IRQHandler,             // 44: TIM2 (STEPPER ISR)
  TIM3_IRQHandler,             // 45: TIM3 (PULSE RESET ISR)
  TIM4_IRQHandler,             // 46: TIM4
  I2C1_EV_IRQHandler,          // 47: I2C1 Event
  I2C1_ER_IRQHandler,          // 48: I2C1 Error
  I2C2_EV_IRQHandler,          // 49: I2C2 Event
  I2C2_ER_IRQHandler,          // 50: I2C2 Error
  SPI1_IRQHandler,             // 51: SPI1
  SPI2_IRQHandler,             // 52: SPI2
  USART1_IRQHandler,           // 53: USART1 (SERIAL ISR)
  USART2_IRQHandler,           // 54: USART2
  USART3_IRQHandler,           // 55: USART3
  EXTI15_10_IRQHandler,        // 56: EXTI15_10 (Z limit switch)
  RTCAlarm_IRQHandler,         // 57: RTC Alarm
  USBWakeUp_IRQHandler,        // 58: USB Wakeup
};
