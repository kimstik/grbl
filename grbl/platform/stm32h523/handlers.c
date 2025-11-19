/*
  handlers.c - External interrupt handlers for STM32H523
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  EXTI interrupt handlers for limit switches and control pins.
  STM32H5 uses separate FPR1/RPR1 registers instead of combined PR register.
*/

#include "platform.h"
#include "regs.h"

// Forward declarations of GRBL interrupt handlers
extern void limits_isr(void);     // Defined in limits.c
extern void control_isr(void);    // Defined in system.c

// ============================================================================
// LIMIT SWITCH INTERRUPT HANDLERS
// ============================================================================
// Limit switches are configured for falling edge trigger (button press)

// X limit switch (PB0, EXTI0)
void EXTI0_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 0)) {  // Check falling edge pending
    EXTI->FPR1 = (1 << 0);       // Clear pending bit by writing 1
    limits_isr();                 // Call GRBL limit handler
  }
}

// Y limit switch (PB1, EXTI1)
void EXTI1_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 1)) {
    EXTI->FPR1 = (1 << 1);
    limits_isr();
  }
}

// Z limit switch (PB10, EXTI10)
void EXTI10_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 10)) {
    EXTI->FPR1 = (1 << 10);
    limits_isr();
  }
}

// ============================================================================
// CONTROL PIN INTERRUPT HANDLERS
// ============================================================================
// Control buttons are configured for falling edge trigger (button press)

// Reset button (PB3, EXTI3)
void EXTI3_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 3)) {
    EXTI->FPR1 = (1 << 3);
    control_isr();  // Call GRBL control pin handler
  }
}

// Feed hold button (PB4, EXTI4)
void EXTI4_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 4)) {
    EXTI->FPR1 = (1 << 4);
    control_isr();
  }
}

// Cycle start button (PB5, EXTI5)
void EXTI5_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 5)) {
    EXTI->FPR1 = (1 << 5);
    control_isr();
  }
}

// Safety door button (PB6, EXTI6)
void EXTI6_IRQHandler(void) {
  if (EXTI->FPR1 & (1 << 6)) {
    EXTI->FPR1 = (1 << 6);
    control_isr();
  }
}
