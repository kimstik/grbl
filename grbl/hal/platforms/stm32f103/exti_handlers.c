/*
  exti_handlers.c - External interrupt handlers for STM32F103
  Part of Grbl HAL

  Copyright (c) 2025 GRBL HAL Contributors

  REVIEW: MEDIUM #7 - EXTI interrupt handlers for limit switches and control pins
*/

#include "platform.h"

// Forward declarations of GRBL interrupt handlers
extern void limits_isr(void);     // Defined in limits.c
extern void control_isr(void);    // Defined in system.c

// ============================================================================
// LIMIT SWITCH INTERRUPT HANDLERS
// ============================================================================

// X limit switch (PB0, EXTI0)
void EXTI0_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR0) {
    EXTI->PR = EXTI_PR_PR0;  // Clear pending bit
    limits_isr();             // Call GRBL limit handler
  }
}

// Y limit switch (PB1, EXTI1)
void EXTI1_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR1) {
    EXTI->PR = EXTI_PR_PR1;
    limits_isr();
  }
}

// Z limit switch (PB10, EXTI10) and other pins on EXTI15_10
void EXTI15_10_IRQHandler(void) {
  if (EXTI->PR & EXTI_PR_PR10) {
    EXTI->PR = EXTI_PR_PR10;
    limits_isr();
  }
}

// ============================================================================
// CONTROL PIN INTERRUPT HANDLERS
// ============================================================================

// Reset button (PB3, EXTI3)
void EXTI3_IRQHandler(void) {
  if (EXTI->PR & (1 << 3)) {
    EXTI->PR = (1 << 3);
    control_isr();  // Call GRBL control pin handler
  }
}

// Feed hold button (PB4, EXTI4)
void EXTI4_IRQHandler(void) {
  if (EXTI->PR & (1 << 4)) {
    EXTI->PR = (1 << 4);
    control_isr();
  }
}

// Cycle start and safety door (PB5-6, EXTI9_5)
void EXTI9_5_IRQHandler(void) {
  uint32_t pr = EXTI->PR;

  // Check cycle start (PB5, EXTI5)
  if (pr & (1 << 5)) {
    EXTI->PR = (1 << 5);
    control_isr();
  }

  // Check safety door (PB6, EXTI6)
  if (pr & (1 << 6)) {
    EXTI->PR = (1 << 6);
    control_isr();
  }
}
