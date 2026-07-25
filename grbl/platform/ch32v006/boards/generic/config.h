/*
  config.h - Generic CH32V006 board configuration
  Part of Grbl

  PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up: peripheral
  FUNCTION mappings below (USART1 default pins, TIM1_CH1 remap options,
  EXTI line/port sharing rules) are verified against CH32V00X RM V1.5;
  the choice of which package pin carries which GRBL signal is still a
  paper exercise (no hardware this session). QFN32/QSOP24-oriented: uses
  PB3-5, which the TSSOP20 package may not bond out - copy this directory
  to boards/yourboard and re-pin for real silicon.

  LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1/#14.8): X/Y/Z
  STEP and DIRECTION _BIT values are LOGICAL bits 0,1,2 (core's native
  uint8_t port image); the real silicon pin lives in *_PIN. gpio.h's
  GPIO_MWO/GPIO_MRD/GPIO_MDIR_OUT dispatch through the *_MASK_PHYS /
  *_L2P / *_P2L definitions below (samd21/generic/config.h pattern -
  contiguous pins, so L2P/P2L collapse to a pure shift).

  EXTI CONSTRAINT (found authoring Step 6, folded into CONTRACTS.md #14):
  on F1/CH32-style EXTI, line N serves ALL ports' pin N - ONE port per
  line via AFIO_EXTICR. LIMIT (PD0-2, lines 0-2) and CONTROL therefore
  MUST NOT use pin numbers 0-2 on another port; CONTROL sits on PB3-5
  (lines 3-5). All 6 inputs share the single EXTI7_0 vector (handlers.c
  dispatches both groups per CONTRACTS.md #2.5).
*/

#ifndef BOARD_GENERIC_CH32V006_CONFIG_H
#define BOARD_GENERIC_CH32V006_CONFIG_H

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "Generic CH32V006 (PLACEHOLDER pinout, QFN32-class)"
#define BOARD_MCU  "CH32V006"
#define BOARD_URL  ""

// ============================================================================
// STEP PINS (GPIOC: PC0, PC1, PC2) - physical == logical (shift 0)
// ============================================================================

#define X_STEP_PORT         GPIOC
#define X_STEP_PIN          0
#define X_STEP_BIT          0   // logical
#define Y_STEP_PORT         GPIOC
#define Y_STEP_PIN          1
#define Y_STEP_BIT          1
#define Z_STEP_PORT         GPIOC
#define Z_STEP_PIN          2
#define Z_STEP_BIT          2

#define STEP_PORT           GPIOC
#define STEP_MASK           ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))       // logical
#define STEP_MASK_PHYS      ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))       // physical
#define STEP_L2P(v)         ((uint32_t)(v) << X_STEP_PIN)   // shift 0 - identity
#define STEP_P2L(v)         ((uint32_t)(v) >> X_STEP_PIN)

// ============================================================================
// DIRECTION PINS (GPIOC: PC3, PC4, PC5) - logical bits 0-2, physical 3-5
// ============================================================================

#define X_DIRECTION_PORT    GPIOC
#define X_DIRECTION_PIN     3
#define X_DIRECTION_BIT     0   // logical (BUG #17 - was physical 3 in M1-M3)
#define Y_DIRECTION_PORT    GPIOC
#define Y_DIRECTION_PIN     4
#define Y_DIRECTION_BIT     1
#define Z_DIRECTION_PORT    GPIOC
#define Z_DIRECTION_PIN     5
#define Z_DIRECTION_BIT     2

#define DIRECTION_PORT      GPIOC
#define DIRECTION_MASK      ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))  // logical 0x07
#define DIRECTION_MASK_PHYS ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))  // physical 0x38
#define DIRECTION_L2P(v)    ((uint32_t)(v) << X_DIRECTION_PIN)
#define DIRECTION_P2L(v)    ((uint32_t)(v) >> X_DIRECTION_PIN)

// ============================================================================
// STEPPER ENABLE (GPIOC: PC6)
// ============================================================================

#define STEPPERS_DISABLE_PORT   GPIOC
#define STEPPERS_DISABLE_PIN    6
#define STEPPERS_DISABLE_BIT    6
#define STEPPERS_DISABLE_MASK   (1UL<<STEPPERS_DISABLE_BIT)

// ============================================================================
// COOLANT (flood PC7; mist PA7 under ENABLE_M7)
// ============================================================================

#define COOLANT_FLOOD_PORT      GPIOC
#define COOLANT_FLOOD_PIN       7
#define COOLANT_FLOOD_BIT       7

#ifdef ENABLE_M7
  #define COOLANT_MIST_PORT     GPIOA
  #define COOLANT_MIST_PIN      7
  #define COOLANT_MIST_BIT      7
#endif

// ============================================================================
// LIMIT SWITCHES (GPIOD: PD0, PD1, PD2) - inputs, bits 0-7 (CONTRACTS.md
// #1.3), EXTI lines 0-2 mapped to port D
// ============================================================================

#define X_LIMIT_PORT        GPIOD
#define X_LIMIT_PIN         0
#define X_LIMIT_BIT         0
#define Y_LIMIT_PORT        GPIOD
#define Y_LIMIT_PIN         1
#define Y_LIMIT_BIT         1
#define Z_LIMIT_PORT        GPIOD
#define Z_LIMIT_PIN         2
#define Z_LIMIT_BIT         2

#define LIMIT_PORT          GPIOD
#define LIMIT_MASK          ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

// GPIO_INT_ON/OFF plumbing (limits.c:53,67): core passes
// (name_PCMSK, name_INT, name_MASK); on this chip the first argument is
// the GPIO port, the second is unused (AVR PCIE bit) - f103 precedent.
#define LIMIT_PCMSK         LIMIT_PORT
#define LIMIT_INT           0

// ============================================================================
// CONTROL PINS (GPIOB: PB3, PB4, PB5) - EXTI lines 3-5 mapped to port B
// (MUST NOT collide with LIMIT's lines 0-2 - see file header). PB exists
// as PB0-PB6 on QFN32 (RM: GPIOB is 7 pins); NOT bonded on TSSOP20.
// ============================================================================

#define CONTROL_RESET_PORT       GPIOB
#define CONTROL_RESET_PIN        3
#define CONTROL_RESET_BIT        3
#define CONTROL_FEED_HOLD_PORT   GPIOB
#define CONTROL_FEED_HOLD_PIN    4
#define CONTROL_FEED_HOLD_BIT    4
#define CONTROL_CYCLE_START_PORT GPIOB
#define CONTROL_CYCLE_START_PIN  5
#define CONTROL_CYCLE_START_BIT  5
// Safety door shares the feed-hold pin (no dedicated input on this generic
// board) - same convention as samd21/generic/config.h.
#define CONTROL_SAFETY_DOOR_PORT GPIOB
#define CONTROL_SAFETY_DOOR_PIN  4
#define CONTROL_SAFETY_DOOR_BIT  4

#define CONTROL_PORT         GPIOB
#define CONTROL_MASK         ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK  CONTROL_MASK

#define CONTROL_PCMSK        CONTROL_PORT
#define CONTROL_INT          0

// ============================================================================
// USART1 (GPIOD: PD5=TX, PD6=RX) - RM table 7-10 DEFAULT mapping
// (USART1_RM=0000), no AFIO remap needed.
// ============================================================================

#define SERIAL_TX_PORT      GPIOD
#define SERIAL_TX_PIN       5
#define SERIAL_RX_PORT      GPIOD
#define SERIAL_RX_PIN       6

// ============================================================================
// PROBE (GPIOA: PA0) - polled input, no EXTI use
// ============================================================================

#define PROBE_PORT           GPIOA
#define PROBE_PIN            0
#define PROBE_BIT            0
#define PROBE_MASK           (1UL<<PROBE_BIT)

// ============================================================================
// SPINDLE (PA3 = TIM1_CH1 via TIM1_RM=0100 partial remap - RM table 7-8;
// the DEFAULT CH1 pin PD2 collides with Z_LIMIT, hence the remap.
// PA4 = enable, PA5 = direction.)
// SPINDLE_PWM_MAX_VALUE must be <= 255 - core plumbs duty as uint8_t
// end-to-end (CONTRACTS.md #6.2).
// ============================================================================

#define SPINDLE_ENABLE_PORT     GPIOA
#define SPINDLE_ENABLE_PIN      4
#define SPINDLE_ENABLE_BIT      4

#define SPINDLE_DIRECTION_PORT  GPIOA
#define SPINDLE_DIRECTION_PIN   5
#define SPINDLE_DIRECTION_BIT   5

#define SPINDLE_PWM_PORT        GPIOA
#define SPINDLE_PWM_PIN         3
#define SPINDLE_PWM_BIT         3
#define SPINDLE_PWM_TIMER       TIM1
#define SPINDLE_PWM_CHANNEL     1
#define SPINDLE_PWM_TIM1_RM     0x4u   // TIM1_RM=0100: CH1 -> PA3 (RM table 7-8)

#define SPINDLE_PWM_MAX_VALUE   255
#define SPINDLE_PWM_MIN_VALUE   1
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// ============================================================================
// PERIPHERAL ASSIGNMENTS (Step 3/4)
// ============================================================================
// Stepper timer: TIM2 (IRQ 38). Pulse-reset timer: the QingKe STK
// ("SysTick", IRQ 12) at HCLK/8 - NOT TIM3: RM 13's TIM3 is a compare-only
// "streamlined" timer with no interrupt output at all (CONTRACTS.md #14).

#define STEPPER_TIMER           TIM2
#define GRBL_USART              USART1

#endif // BOARD_GENERIC_CH32V006_CONFIG_H
