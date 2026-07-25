/*
  config.h - Generic dsPIC33AK128MC102 board configuration
  Part of Grbl

  PLACEHOLDER PIN MAP - PORT-TODO before hardware bring-up: this is a
  paper pinout for the bare 28-pin chip (SOIC/SSOP/VQFN). The
  dsPIC33AK128MC102 bonds out exactly 19 GPIO (RA0-4, RB0-4, RC0-4,
  RD0-3 - verified from the DFP's own dsPIC33AK128MC102.atdf pin list),
  and GRBL needs 20 signals - the same squeeze the ATmega328p/Uno has,
  resolved the same way: SPINDLE_ENABLE and SPINDLE_PWM SHARE one pin
  under VARIABLE_SPINDLE (cpu_map.h:110-152 precedent, B3 on the Uno).
  The MC106 Curiosity community board should get its own boards/ dir.

  Pin-budget accounting (19/19 used):
    STEP x3 (RB0-2), DIR x3 (RC0-2), STEPPERS_DISABLE (RB3),
    LIMIT x3 (RD0-2), CONTROL x3 (RA0-2), PROBE (RA3),
    SPINDLE_ENABLE+PWM shared (RB4), SPINDLE_DIRECTION (RC3),
    COOLANT_FLOOD (RC4), UART RX (RA4) + TX (RD3).
  ENABLE_M7 (mist coolant) therefore CANNOT fit - #error below, not a
  silent drop.

  LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1/#14.8): STEP and
  DIRECTION groups sit on physical pins 0-2 of their ports, so logical
  bits (core's uint8_t port image) == physical bits and the stock
  common/gpio.h GPIO_MWO/GPIO_MRD formulas are exactly correct - no
  L2P/P2L dispatch needed ON THIS BOARD. A board that scatters STEP/DIR
  pins must add the samd21/ch32v006-style per-NAME dispatch in gpio.h.
  Input groups (LIMIT/CONTROL/PROBE) land in bits 0-3 (#1.3 satisfied).

  INTERRUPT MODEL (Step 6, next batch): dsPIC33AK Change Notification
  (CN) is per-PORT with a per-port vector - _CNDInterrupt for LIMIT
  (port D), _CNAInterrupt for CONTROL (port A). Unlike EXTI-class chips
  there is NO line/port collision constraint (CONTRACTS.md #14.12 does
  not apply) and no shared-vector dispatch is needed (#2.5): the two
  groups own separate vectors by construction. CNEN0x arms per-pin,
  CNCONx.ON gates the whole port - both runtime-writable (#2.1).

  PPS NOTE (Steps 3-4): UART and the SCCP PWM output reach pins via
  Peripheral Pin Select. RPn numbering (DFP header + datasheet pattern
  RPn = 16*port_index + pin + 1, UNVERIFIED against silicon):
  RA4 = RP5 (U1RX via RPINR), RD3 = RP52 (U1TX via RP52R),
  RB4 = RP21 (SCCP/PWM out via RP21R). Analog default: ANSELx resets to
  analog on analog-capable pins - platform.c's hal_gpio_* helpers clear
  ANSEL on every direction config (the "input reads zero forever" trap).
*/

#ifndef BOARD_GENERIC_DSPIC33AK128MC102_CONFIG_H
#define BOARD_GENERIC_DSPIC33AK128MC102_CONFIG_H

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================

#define BOARD_NAME "Generic dsPIC33AK128MC102 (PLACEHOLDER pinout, 28-pin)"
#define BOARD_MCU  "dsPIC33AK128MC102"
#define BOARD_URL  ""

// NOTE: *_PORT values are bare port LETTERS (A/B/C/D) consumed by the
// token-pasting register accessors in ../../gpio.h (GPIO_OREG(STEP) ->
// LATB etc.) and by GPIO_PIDX() for the function-call helpers.

// ============================================================================
// STEP PINS (RB0, RB1, RB2) - logical == physical (bits 0-2)
// ============================================================================

#define X_STEP_PORT         B
#define X_STEP_PIN          0
#define X_STEP_BIT          0   // logical
#define Y_STEP_PORT         B
#define Y_STEP_PIN          1
#define Y_STEP_BIT          1
#define Z_STEP_PORT         B
#define Z_STEP_PIN          2
#define Z_STEP_BIT          2

#define STEP_PORT           B
#define STEP_MASK           ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))

// ============================================================================
// DIRECTION PINS (RC0, RC1, RC2) - logical == physical (bits 0-2)
// ============================================================================

#define X_DIRECTION_PORT    C
#define X_DIRECTION_PIN     0
#define X_DIRECTION_BIT     0
#define Y_DIRECTION_PORT    C
#define Y_DIRECTION_PIN     1
#define Y_DIRECTION_BIT     1
#define Z_DIRECTION_PORT    C
#define Z_DIRECTION_PIN     2
#define Z_DIRECTION_BIT     2

#define DIRECTION_PORT      C
#define DIRECTION_MASK      ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))

// ============================================================================
// STEPPER ENABLE (RB3)
// ============================================================================

#define STEPPERS_DISABLE_PORT   B
#define STEPPERS_DISABLE_PIN    3
#define STEPPERS_DISABLE_BIT    3
#define STEPPERS_DISABLE_MASK   (1UL<<STEPPERS_DISABLE_BIT)

// ============================================================================
// COOLANT (flood RC4; NO mist pin exists on this 19-GPIO budget)
// ============================================================================

#define COOLANT_FLOOD_PORT      C
#define COOLANT_FLOOD_PIN       4
#define COOLANT_FLOOD_BIT       4

#ifdef ENABLE_M7
  #error "ENABLE_M7 (mist coolant) does not fit the 28-pin dsPIC33AK128MC102 pin budget (19 GPIO, all allocated - see file header)"
#endif

// ============================================================================
// LIMIT SWITCHES (RD0, RD1, RD2) - inputs in bits 0-2 (CONTRACTS.md #1.3),
// Change Notification port D -> _CNDInterrupt (own vector, no sharing)
// ============================================================================

#define X_LIMIT_PORT        D
#define X_LIMIT_PIN         0
#define X_LIMIT_BIT         0
#define Y_LIMIT_PORT        D
#define Y_LIMIT_PIN         1
#define Y_LIMIT_BIT         1
#define Z_LIMIT_PORT        D
#define Z_LIMIT_PIN         2
#define Z_LIMIT_BIT         2

#define LIMIT_PORT          D
#define LIMIT_MASK          ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

// GPIO_INT_ON/OFF plumbing (limits.c:53,67): core passes
// (name_PCMSK, name_INT, name_MASK); first argument here is the port
// INDEX (for the CN helper functions), second is the unused AVR PCIE bit
// - f103/ch32v006 precedent.
#define LIMIT_PCMSK         GPIO_PIDX(D)
#define LIMIT_INT           0

// ============================================================================
// CONTROL PINS (RA0, RA1, RA2) - CN port A -> _CNAInterrupt (own vector)
// ============================================================================

#define CONTROL_RESET_PORT       A
#define CONTROL_RESET_PIN        0
#define CONTROL_RESET_BIT        0
#define CONTROL_FEED_HOLD_PORT   A
#define CONTROL_FEED_HOLD_PIN    1
#define CONTROL_FEED_HOLD_BIT    1
#define CONTROL_CYCLE_START_PORT A
#define CONTROL_CYCLE_START_PIN  2
#define CONTROL_CYCLE_START_BIT  2
// Safety door shares the feed-hold pin (no dedicated input in the pin
// budget) - same convention as samd21/generic and ch32v006/generic.
#define CONTROL_SAFETY_DOOR_PORT A
#define CONTROL_SAFETY_DOOR_PIN  1
#define CONTROL_SAFETY_DOOR_BIT  1

#define CONTROL_PORT         A
#define CONTROL_MASK         ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK  CONTROL_MASK

#define CONTROL_PCMSK        GPIO_PIDX(A)
#define CONTROL_INT          0

// ============================================================================
// PROBE (RA3) - polled input, no CN use
// ============================================================================

#define PROBE_PORT           A
#define PROBE_PIN            3
#define PROBE_BIT            3
#define PROBE_MASK           (1UL<<PROBE_BIT)

// ============================================================================
// UART1 (U1RX = RA4/RP5 in, U1TX = RD3/RP52 out - both via PPS, Step 4)
// ============================================================================

#define SERIAL_RX_PORT      A
#define SERIAL_RX_PIN       4
#define SERIAL_TX_PORT      D
#define SERIAL_TX_PIN       3

// ============================================================================
// SPINDLE - AVR Uno precedent (cpu_map.h:110-152): under VARIABLE_SPINDLE
// the enable and PWM functions SHARE one pin (RB4 = RP21, SCCP output via
// PPS). SPINDLE_PWM_MAX_VALUE is 255 - core plumbs duty as uint8_t
// end-to-end (CONTRACTS.md #6.2); never raise this.
// ============================================================================

#define SPINDLE_ENABLE_PORT     B
#define SPINDLE_ENABLE_PIN      4
#define SPINDLE_ENABLE_BIT      4

#define SPINDLE_DIRECTION_PORT  C
#define SPINDLE_DIRECTION_PIN   3
#define SPINDLE_DIRECTION_BIT   3

#define SPINDLE_PWM_PORT        B
#define SPINDLE_PWM_PIN         4
#define SPINDLE_PWM_BIT         4

#define SPINDLE_PWM_MAX_VALUE   255
#define SPINDLE_PWM_MIN_VALUE   1
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

// ============================================================================
// PERIPHERAL ASSIGNMENTS (Steps 3-4, next batch - candidates from the
// DFP vector list, NOT yet allocated: every listed timer HAS a real
// interrupt vector, the CONTRACTS.md #14.11 audit passes on paper)
// ============================================================================
// Stepper timer:      Timer1 (_T1Interrupt) - the only classic timer.
// Pulse-reset timer:  SCCP1 timer half (_CCT1Interrupt).
// Spindle PWM:        SCCP2 in output-compare/PWM mode -> RP21R (RB4),
//                     or motor-control PWM PG1 - decide in Step 3.
// UART:               UART1 (_U1RXInterrupt/_U1TXInterrupt).

#endif // BOARD_GENERIC_DSPIC33AK128MC102_CONFIG_H
