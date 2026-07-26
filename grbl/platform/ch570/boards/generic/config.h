/*
  config.h - Generic CH570 board configuration
  Part of Grbl
*/

#ifndef BOARD_GENERIC_CH570_CONFIG_H
#define BOARD_GENERIC_CH570_CONFIG_H

// BOARD IDENTIFICATION

#define BOARD_NAME "Generic CH570 (PLACEHOLDER pinout, exceeds real 12-pin PA budget - see file header)"
#define BOARD_MCU  "CH570"
#define BOARD_URL  ""

// STEP PINS (PA8, PA9, PA10) - logical bits 0,1,2, physical 8,9,10

#define X_STEP_PIN          8
#define X_STEP_BIT          0   // logical
#define Y_STEP_PIN          9
#define Y_STEP_BIT          1
#define Z_STEP_PIN          10
#define Z_STEP_BIT          2

#define STEP_MASK           ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))          // logical, 0x07
#define STEP_MASK_PHYS      ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))           // physical, 0x700
#define STEP_L2P(v)         ((uint32_t)(v) << X_STEP_PIN)   // shift by 8
#define STEP_P2L(v)         ((uint32_t)(v) >> X_STEP_PIN)

// DIRECTION PINS (PA11, PA12, PA13) - logical bits 0,1,2, physical 11,12,13

#define X_DIRECTION_PIN     11
#define X_DIRECTION_BIT     0   // logical
#define Y_DIRECTION_PIN     12
#define Y_DIRECTION_BIT     1
#define Z_DIRECTION_PIN     13
#define Z_DIRECTION_BIT     2

#define DIRECTION_MASK      ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))  // logical 0x07
#define DIRECTION_MASK_PHYS ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))  // physical 0x3800
#define DIRECTION_L2P(v)    ((uint32_t)(v) << X_DIRECTION_PIN)
#define DIRECTION_P2L(v)    ((uint32_t)(v) >> X_DIRECTION_PIN)

// PLAN.md Phase 2 static-assert sweep: core packs step_outbits/dir_outbits/
// axislock into a uint8_t (BUG #17, CONTRACTS.md #1) - only the LOGICAL
// bits feed that byte (PHYS masks above are hardware-side and exempt).
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image (BUG #17 class, CONTRACTS.md #1)");

// STEPPER ENABLE (PA14) - single shared line (12-pin-budget consolidation
// already applied, see file header)

#define STEPPERS_DISABLE_PIN    14
#define STEPPERS_DISABLE_BIT    14
#define STEPPERS_DISABLE_MASK   (1UL<<STEPPERS_DISABLE_BIT)

// COOLANT (flood PA18; mist PA19 under ENABLE_M7)

#define COOLANT_FLOOD_PIN       18
#define COOLANT_FLOOD_BIT       18

// NOT gated on `#ifdef ENABLE_M7`: this file arrives via the build prelude
// (-include, CONTRACTS.md #0), processed before grbl.h's own #include
// "config.h" ever defines ENABLE_M7 - a guard here can never observe it,
// silently dropping this pin even when the user enables the feature
// (CONTRACTS.md #19 "guard that certifies instead of checking", wrong-
// phase variant - see grbl/CONTRACTS.md gap log). Defining the pin
// unconditionally costs nothing; core's own (correctly-timed) `#ifdef
// ENABLE_M7` in coolant_control.c is the only place that ever reads it.
#define COOLANT_MIST_PIN      19
#define COOLANT_MIST_BIT      19

// LIMIT SWITCHES (PA0, PA1, PA5) - inputs, physical==logical (CONTRACTS.md
// #1.3), GPIOA interrupt-capable (ch570.h - single-port chip, no EXTI
// line/port collision class exists here, unlike F1/CH32-style parts).

#define X_LIMIT_PIN         0
#define X_LIMIT_BIT         0
#define Y_LIMIT_PIN         1
#define Y_LIMIT_BIT         1
#define Z_LIMIT_PIN         5
#define Z_LIMIT_BIT         5

#define LIMIT_MASK          ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

// GPIO_INT_ON/OFF plumbing (limits.c): core passes (name_PCMSK, name_INT,
// name_MASK); this chip has one port and no PCIE-equivalent bit, so both
// arguments are unused placeholders (platform.h's
// HAL_GPIO_INTERRUPT_ENABLE/DISABLE macros discard them) - f103/ch32v006
// precedent.
#define LIMIT_PCMSK         0
#define LIMIT_INT           0

// CONTROL PINS (PA15, PA16, PA17) - safety door shares feed-hold (no
// dedicated input in this pin-starved placeholder - same convention as
// every other generic board in this tree).

#define CONTROL_RESET_PIN         15
#define CONTROL_RESET_BIT         15
#define CONTROL_FEED_HOLD_PIN     16
#define CONTROL_FEED_HOLD_BIT     16
#define CONTROL_CYCLE_START_PIN   17
#define CONTROL_CYCLE_START_BIT   17
#define CONTROL_SAFETY_DOOR_PIN   16
#define CONTROL_SAFETY_DOOR_BIT   16

#define CONTROL_MASK         ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK  CONTROL_MASK

#define CONTROL_PCMSK        0
#define CONTROL_INT          0

// UART1 (PA2=RX, PA3=TX) - REAL hardware fact: this is the chip's DEFAULT
// pin-alternate remap (remap code 0), not a placeholder choice.

#define SERIAL_TX_PIN       3
#define SERIAL_RX_PIN       2

// PROBE (PA6) - polled input, no GPIO interrupt use

#define PROBE_PIN            6
#define PROBE_BIT             6
#define PROBE_MASK           (1UL<<PROBE_BIT)

// SPINDLE - PWM1 is a FIXED-function pin on this chip: PA7. NOT a
// placeholder choice (datasheet pin table, ch570.h). Enable/direction are
// plain GPIO (PA20/PA21, placeholder).
// SPINDLE_PWM_MAX_VALUE must be <= 255 - core plumbs duty as uint8_t
// end-to-end (CONTRACTS.md #6.2). This chip's PWM1 IS an 8-bit/256-step
// counter (ch570.h RB_PWM_CYC_256) - 255 is a perfect, non-rescaled fit.

#define SPINDLE_ENABLE_PIN      20
#define SPINDLE_ENABLE_BIT      20

#define SPINDLE_DIRECTION_PIN   21
#define SPINDLE_DIRECTION_BIT   21

#define SPINDLE_PWM_PIN         7   // REAL fixed PWM1 pin, not placeholder
#define SPINDLE_PWM_BIT         7

#define SPINDLE_PWM_MAX_VALUE   255
#define SPINDLE_PWM_MIN_VALUE   1
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2, duty-cap-twins class)");

// PERIPHERAL ASSIGNMENTS
// Stepper timer: TMR0 (IRQ 24, the ONE FIFO/DMA-capable general timer on
// this chip). Pulse-reset timer: the QingKe STK ("SysTick", IRQ 12) at
// HCLK/8 - same role ch32v006 gives it, and for the same reason: no
// second interrupt-capable timer exists.

#define GRBL_USART              UART1

#endif // BOARD_GENERIC_CH570_CONFIG_H
