/*
  startup.c - Startup code for STM32F411
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  Interrupt vector table and reset handler for STM32F411CEU6. ARM Cortex-M
  hardware-vector-fetch model (PORTING-CHECKLIST.md's non-ARM warning does
  not apply here). IRQ numbering verified this session against the published
  STM32F411 CMSIS vector table for every slot this port actually enables
  (EXTI0-4, EXTI9_5, EXTI15_10, TIM2, TIM3, USART1) - see regs.h header
  comment. Slots for peripherals absent on F411 silicon (CAN, USART3, TIM6/7/
  8, FSMC, UART4/5, DAC - this is ST's cost-reduced "Cat.1 access line", not
  the full F405/407 family) are left as 0 (reserved) rather than guessed.
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

// Fault handler helper - safe shutdown and indicate fault via blink pattern
static void handle_fault(uint32_t fault_code) {
  __disable_irq();

  // Stepper enable pin (PA6) high = disabled
  GPIOA->BSRR = (1UL << STEPPERS_DISABLE_PIN);
  // Spindle PWM pin (PA8) low = stopped
  GPIOA->BSRR = (1UL << (SPINDLE_PWM_PIN + 16));

  while (1) {
    for (uint32_t i = 0; i < fault_code; i++) {
      GPIOC->BSRR = (1UL << (COOLANT_FLOOD_PIN + 16));  // onboard-adjacent LED-style pin off pattern reused
      for (volatile uint32_t d = 0; d < 200000; d++);
      GPIOC->BSRR = (1UL << COOLANT_FLOOD_PIN);
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
  __DSB();  // BUG#13-class: ensure the copy loop's stores land before .bss zeroing (CONTRACTS.md section 12.4)

  // Zero .bss section
  dst = &_sbss;
  while (dst < &_ebss) {
    *dst++ = 0;
  }
  __DSB();

  main();

  while (1);
}

// Critical fault handlers with distinct codes
void HardFault_Handler(void)  { handle_fault(1); }
void MemManage_Handler(void)  { handle_fault(2); }
void BusFault_Handler(void)   { handle_fault(3); }
void UsageFault_Handler(void) { handle_fault(4); }

void NMI_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void)              __attribute__((weak, alias("Default_Handler")));
void DebugMon_Handler(void)         __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void)           __attribute__((weak, alias("Default_Handler")));

// SysTick handler - implemented in platform.c (thin wrapper over
// common/stm32/stm32_timing.c's stm32_systick_handler)
extern void SysTick_Handler(void);

// GRBL interrupt handlers - defined by HAL macros in GRBL code
extern void TIM2_IRQHandler(void);   // Stepper ISR
extern void TIM3_IRQHandler(void);   // Pulse reset ISR
extern void USART1_IRQHandler(void); // Serial ISR
extern void EXTI0_IRQHandler(void);
extern void EXTI1_IRQHandler(void);
extern void EXTI3_IRQHandler(void);
extern void EXTI4_IRQHandler(void);
extern void EXTI9_5_IRQHandler(void);
extern void EXTI15_10_IRQHandler(void);

// EXTI2 is not wired to a limit/control pin on this board's pin map -
// weak-alias it like any other unused vector.
void EXTI2_IRQHandler(void)          __attribute__((weak, alias("Default_Handler")));

// Peripherals present on F411 silicon but unused by this port
void DMA1_Stream0_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream1_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream2_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream3_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream4_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream5_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void DMA1_Stream6_IRQHandler(void)   __attribute__((weak, alias("Default_Handler")));
void ADC_IRQHandler(void)            __attribute__((weak, alias("Default_Handler")));
void TIM1_BRK_TIM9_IRQHandler(void)  __attribute__((weak, alias("Default_Handler")));
void TIM1_UP_TIM10_IRQHandler(void)  __attribute__((weak, alias("Default_Handler")));
void TIM1_TRG_COM_TIM11_IRQHandler(void) __attribute__((weak, alias("Default_Handler")));
void TIM1_CC_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void TIM4_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void I2C1_EV_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void I2C1_ER_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void I2C2_EV_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void I2C2_ER_IRQHandler(void)        __attribute__((weak, alias("Default_Handler")));
void SPI1_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void SPI2_IRQHandler(void)           __attribute__((weak, alias("Default_Handler")));
void USART2_IRQHandler(void)         __attribute__((weak, alias("Default_Handler")));
void RTC_Alarm_IRQHandler(void)      __attribute__((weak, alias("Default_Handler")));
void OTG_FS_WKUP_IRQHandler(void)    __attribute__((weak, alias("Default_Handler")));

// Interrupt vector table (positions match the real STM32F411 CMSIS layout;
// 0 = reserved slot for a peripheral absent on this part - see file header)
// `used` is belt to the VTOR write's braces: it tells LTO/IPA the object is
// live even though nothing in C reads its elements (BUG #21, CONTRACTS.md S18).
__attribute__((section(".isr_vector"), used))
const void *vector_table[] = {
  // Cortex-M4 core interrupts
  &_estack,                    // 0:  Initial stack pointer
  Reset_Handler,                // 1:  Reset handler
  NMI_Handler,                  // 2:  NMI handler
  HardFault_Handler,            // 3:  Hard fault handler
  MemManage_Handler,            // 4:  MPU fault handler
  BusFault_Handler,              // 5:  Bus fault handler
  UsageFault_Handler,           // 6:  Usage fault handler
  0,                             // 7:  Reserved
  0,                             // 8:  Reserved
  0,                             // 9:  Reserved
  0,                             // 10: Reserved
  SVC_Handler,                   // 11: SVCall handler
  DebugMon_Handler,              // 12: Debug monitor handler
  0,                             // 13: Reserved
  PendSV_Handler,                // 14: PendSV handler
  SysTick_Handler,               // 15: SysTick handler

  // STM32F411 peripheral interrupts (IRQ0 = index 16)
  Default_Handler,               // 16: IRQ0  WWDG
  Default_Handler,               // 17: IRQ1  PVD
  Default_Handler,               // 18: IRQ2  TAMP_STAMP
  Default_Handler,               // 19: IRQ3  RTC_WKUP
  Default_Handler,               // 20: IRQ4  FLASH
  Default_Handler,               // 21: IRQ5  RCC
  EXTI0_IRQHandler,               // 22: IRQ6  EXTI0  (X limit switch)
  EXTI1_IRQHandler,               // 23: IRQ7  EXTI1  (Y limit switch)
  EXTI2_IRQHandler,               // 24: IRQ8  EXTI2  (unused)
  EXTI3_IRQHandler,               // 25: IRQ9  EXTI3  (Reset button)
  EXTI4_IRQHandler,               // 26: IRQ10 EXTI4  (Feed hold button)
  DMA1_Stream0_IRQHandler,        // 27: IRQ11 DMA1 Stream0
  DMA1_Stream1_IRQHandler,        // 28: IRQ12 DMA1 Stream1
  DMA1_Stream2_IRQHandler,        // 29: IRQ13 DMA1 Stream2
  DMA1_Stream3_IRQHandler,        // 30: IRQ14 DMA1 Stream3
  DMA1_Stream4_IRQHandler,        // 31: IRQ15 DMA1 Stream4
  DMA1_Stream5_IRQHandler,        // 32: IRQ16 DMA1 Stream5
  DMA1_Stream6_IRQHandler,        // 33: IRQ17 DMA1 Stream6
  ADC_IRQHandler,                 // 34: IRQ18 ADC
  0,                              // 35: IRQ19 (CAN1_TX - absent on F411)
  0,                              // 36: IRQ20 (CAN1_RX0 - absent on F411)
  0,                              // 37: IRQ21 (CAN1_RX1 - absent on F411)
  0,                              // 38: IRQ22 (CAN1_SCE - absent on F411)
  EXTI9_5_IRQHandler,             // 39: IRQ23 EXTI9_5 (Cycle start, safety door)
  TIM1_BRK_TIM9_IRQHandler,       // 40: IRQ24 TIM1_BRK_TIM9
  TIM1_UP_TIM10_IRQHandler,       // 41: IRQ25 TIM1_UP_TIM10
  TIM1_TRG_COM_TIM11_IRQHandler,  // 42: IRQ26 TIM1_TRG_COM_TIM11
  TIM1_CC_IRQHandler,             // 43: IRQ27 TIM1_CC
  TIM2_IRQHandler,                // 44: IRQ28 TIM2 (STEPPER ISR)
  TIM3_IRQHandler,                // 45: IRQ29 TIM3 (PULSE RESET ISR)
  TIM4_IRQHandler,                // 46: IRQ30 TIM4
  I2C1_EV_IRQHandler,             // 47: IRQ31 I2C1 Event
  I2C1_ER_IRQHandler,             // 48: IRQ32 I2C1 Error
  I2C2_EV_IRQHandler,             // 49: IRQ33 I2C2 Event
  I2C2_ER_IRQHandler,             // 50: IRQ34 I2C2 Error
  SPI1_IRQHandler,                // 51: IRQ35 SPI1
  SPI2_IRQHandler,                // 52: IRQ36 SPI2
  USART1_IRQHandler,              // 53: IRQ37 USART1 (SERIAL ISR)
  USART2_IRQHandler,              // 54: IRQ38 USART2
  0,                              // 55: IRQ39 (USART3 - absent on F411)
  EXTI15_10_IRQHandler,           // 56: IRQ40 EXTI15_10 (Z limit switch)
  RTC_Alarm_IRQHandler,           // 57: IRQ41 RTC Alarm
  OTG_FS_WKUP_IRQHandler,         // 58: IRQ42 OTG_FS Wakeup
};
