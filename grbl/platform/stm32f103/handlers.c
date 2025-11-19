/*
  handlers.c - External interrupt handlers for STM32F103
  Part of Grbl

  Copyright (c) 2025 kimstik
  Intelligence assisted
  License: MIT

  EXTI interrupt handlers for limit switches and control pins (Blue Pill).
*/

#include "platform.h"
#include "regs.h"

// Include GRBL headers for system functions
#include "../../grbl.h"

// STM32 interrupt handlers for limits and control pins
void limits_isr(void) {
  // Check limit pin state
  if (sys.state != STATE_ALARM) {
    if (!(sys_rt_exec_alarm)) {
      // Check if any limit switch is triggered
      if (HAL_GPIO_READ_PORT(LIMIT_PIN, LIMIT_MASK)) {
        mc_reset(); // Initiate system kill
        system_set_exec_alarm(EXEC_ALARM_HARD_LIMIT); // Indicate hard limit event
      }
    }
  }
}

void control_isr(void) {
  // Read control pin states and set appropriate system flags
  uint8_t pin = HAL_GPIO_READ_PORT(CONTROL_PIN, CONTROL_MASK);

  if (pin) {
    // Invert because control pins are pulled high
    pin ^= CONTROL_MASK;

    // Check individual control bits and set flags
    if (pin & (1 << CONTROL_RESET_PIN)) {
      mc_reset();
    }
    if (pin & (1 << CONTROL_FEED_HOLD_PIN)) {
      system_set_exec_state_flag(EXEC_FEED_HOLD);
    }
    if (pin & (1 << CONTROL_CYCLE_START_PIN)) {
      system_set_exec_state_flag(EXEC_CYCLE_START);
    }
    if (pin & (1 << CONTROL_SAFETY_DOOR_PIN)) {
      system_set_exec_state_flag(EXEC_SAFETY_DOOR);
    }
  }
}

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
