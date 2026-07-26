/*
  config.h - Generic SG2002 (C906L runtime core) board configuration
  Part of Grbl

  PLACEHOLDER PIN MAP - a compile/link target, not a hardware-fit claim, the
  same posture every other "generic" board in this tree ships with. On this
  chip that caveat is stronger than usual: which pads are bonded out, which
  are already claimed by Linux, and which GPIO bit a given pad lands on are
  ALL board-level facts, and SG2002 boards differ wildly (Milk-V Duo,
  LicheeRV Nano, Duo S ... each expose a different subset). This map is
  internally consistent and satisfies every contract; it is not a claim
  about any shipping board.

  A REAL BOARD MUST, BEFORE BRING-UP:
   - reconcile every pin here with the Linux device tree, so no pad is driven
     by both a Linux driver and this firmware;
   - correct SG2002_PAD_PULL_REG below to the real pad-control register index
     of each input pad (see sg2002.h's pad-block banner - the index follows
     package pad order, NOT the GPIO bit number, so the contiguity assumed
     here is the single least defensible line in this file);
   - confirm the PWM channel and its pad mux.

  ============================================================================
  LOGICAL PORT-IMAGE CONTRACT (BUG #17, CONTRACTS.md #1)
  ============================================================================
  X/Y/Z STEP and DIRECTION *_BIT values are LOGICAL bits 0,1,2 - core's
  native uint8_t port image - and the real silicon bit lives in *_PIN. They
  are placed PAST bit 7 on purpose (STEP on bank-0 bits 8-10, DIRECTION on
  bank-0 bits 11-13) so this port genuinely exercises the L2P/P2L machinery
  rather than carrying it unused. gpio.h dispatches GPIO_MWO/GPIO_MRD/
  GPIO_MDIR_OUT through the MASK_PHYS / L2P / P2L definitions below.

  Input groups (LIMIT/CONTROL/PROBE) are kept in bits 0-7 per #1.3 - core
  truncates those reads to uint8_t, and the SAMD21 port's dead control-pin
  input is what that clause exists to prevent.
*/

#ifndef BOARD_GENERIC_SG2002_CONFIG_H
#define BOARD_GENERIC_SG2002_CONFIG_H

// ============================================================================
// BOARD IDENTIFICATION
// ============================================================================
#define BOARD_NAME "Generic SG2002 C906L (PLACEHOLDER pinout - see file header)"
#define BOARD_MCU  "SG2002"
#define BOARD_URL  ""

// ============================================================================
// PAD PULL-CONFIGURATION MAPPING (CONTRACTS.md #1.4)
//
// UNVERIFIED, AND THE WEAKEST LINE IN THIS FILE. DesignWare apb_gpio has no
// pull registers; pulls live in the SoC pad block, one 32-bit register per
// PAD, ordered by package pad number. This placeholder assumes the pads are
// laid out contiguously in GPIO (bank, bit) order, which real silicon
// generally does NOT do. platform.c performs a real write through this macro
// - a no-op would be a contract violation (#1.4), a wrong address is a
// bring-up defect whose symptom is floating inputs and spurious ALARMs.
// ============================================================================
#define SG2002_PAD_PULL_REG(bank, bit) \
  (SG2002_PINMUX_BASE + (((uint32_t)(bank) * 32u + (uint32_t)(bit)) * 4u))

// ============================================================================
// STEP PINS - GPIO bank 0, physical bits 8/9/10, logical bits 0/1/2
// ============================================================================
#define STEP_PORT           0
#define X_STEP_PIN          8
#define X_STEP_BIT          0   // logical
#define Y_STEP_PIN          9
#define Y_STEP_BIT          1
#define Z_STEP_PIN          10
#define Z_STEP_BIT          2

#define STEP_MASK           ((1UL<<X_STEP_BIT)|(1UL<<Y_STEP_BIT)|(1UL<<Z_STEP_BIT))   // logical 0x07
#define STEP_MASK_PHYS      ((1UL<<X_STEP_PIN)|(1UL<<Y_STEP_PIN)|(1UL<<Z_STEP_PIN))   // physical 0x700
#define STEP_L2P(v)         ((uint32_t)(v) << X_STEP_PIN)
#define STEP_P2L(v)         ((uint32_t)(v) >> X_STEP_PIN)

// ============================================================================
// DIRECTION PINS - GPIO bank 0, physical bits 11/12/13, logical bits 0/1/2
// ============================================================================
#define DIRECTION_PORT      0
#define X_DIRECTION_PIN     11
#define X_DIRECTION_BIT     0   // logical
#define Y_DIRECTION_PIN     12
#define Y_DIRECTION_BIT     1
#define Z_DIRECTION_PIN     13
#define Z_DIRECTION_BIT     2

#define DIRECTION_MASK      ((1UL<<X_DIRECTION_BIT)|(1UL<<Y_DIRECTION_BIT)|(1UL<<Z_DIRECTION_BIT))
#define DIRECTION_MASK_PHYS ((1UL<<X_DIRECTION_PIN)|(1UL<<Y_DIRECTION_PIN)|(1UL<<Z_DIRECTION_PIN))
#define DIRECTION_L2P(v)    ((uint32_t)(v) << X_DIRECTION_PIN)
#define DIRECTION_P2L(v)    ((uint32_t)(v) >> X_DIRECTION_PIN)

// Core packs step_outbits/dir_outbits/axislock into a uint8_t (BUG #17,
// CONTRACTS.md #1) - only the LOGICAL bits feed that byte; the PHYS masks
// are hardware-side and exempt.
_Static_assert(X_STEP_BIT <= 7 && Y_STEP_BIT <= 7 && Z_STEP_BIT <= 7 &&
               X_DIRECTION_BIT <= 7 && Y_DIRECTION_BIT <= 7 && Z_DIRECTION_BIT <= 7,
               "STEP/DIRECTION logical bits must fit core's uint8_t port image "
               "(BUG #17 class, CONTRACTS.md #1)");

// ============================================================================
// STEPPER ENABLE - GPIO bank 1. Deliberately a DIFFERENT bank from
// STEP/DIRECTION: this bit is written from st_go_idle(), which runs inside
// ISR_STEP (stepper.c:401), while SPINDLE_*/COOLANT_* on the same bank are
// written from mainline. Keeping the ISR-only step image out of that bank
// narrows the shared-register surface; gpio.h's critical-sectioned
// read-modify-write covers what remains (CONTRACTS.md #1.2).
// ============================================================================
#define STEPPERS_DISABLE_PORT   1
#define STEPPERS_DISABLE_PIN    0
#define STEPPERS_DISABLE_BIT    0
#define STEPPERS_DISABLE_MASK   (1UL<<STEPPERS_DISABLE_BIT)

// ============================================================================
// LIMIT SWITCHES - GPIO bank 0, bits 0/1/2. Physical == logical, inside
// bits 0-7 (CONTRACTS.md #1.3). Interrupt-capable: DesignWare apb_gpio
// gives every bank one PLIC line covering all 32 pins, so the shared-vector
// dispatch rule (#2.5) applies and handlers.c implements it.
// ============================================================================
#define LIMIT_PORT          0
#define X_LIMIT_PIN         0
#define X_LIMIT_BIT         0
#define Y_LIMIT_PIN         1
#define Y_LIMIT_BIT         1
#define Z_LIMIT_PIN         2
#define Z_LIMIT_BIT         2

#define LIMIT_MASK          ((1UL<<X_LIMIT_BIT)|(1UL<<Y_LIMIT_BIT)|(1UL<<Z_LIMIT_BIT))

// GPIO_INT_ON/OFF plumbing (limits.c/system.c): core passes
// (name_PCMSK, name_INT, name_MASK). platform.h's macros take the BANK in
// the first slot and ignore the second, so PCMSK carries the bank index.
#define LIMIT_PCMSK         LIMIT_PORT
#define LIMIT_INT           0

// ============================================================================
// CONTROL PINS - GPIO bank 0, bits 3/4/5. Safety door shares feed hold, the
// same consolidation every generic board in this tree makes.
// ============================================================================
#define CONTROL_PORT              0
#define CONTROL_RESET_PIN         3
#define CONTROL_RESET_BIT         3
#define CONTROL_FEED_HOLD_PIN     4
#define CONTROL_FEED_HOLD_BIT     4
#define CONTROL_CYCLE_START_PIN   5
#define CONTROL_CYCLE_START_BIT   5
#define CONTROL_SAFETY_DOOR_PIN   4
#define CONTROL_SAFETY_DOOR_BIT   4

#define CONTROL_MASK        ((1UL<<CONTROL_RESET_BIT)|(1UL<<CONTROL_FEED_HOLD_BIT)|(1UL<<CONTROL_CYCLE_START_BIT))
#define CONTROL_INVERT_MASK CONTROL_MASK

#define CONTROL_PCMSK       CONTROL_PORT
#define CONTROL_INT         0

_Static_assert((LIMIT_MASK & CONTROL_MASK) == 0,
               "LIMIT and CONTROL share a GPIO bank and one PLIC line - their masks must be "
               "disjoint or handlers.c cannot separate the two groups (CONTRACTS.md #2.5)");
_Static_assert((LIMIT_MASK | CONTROL_MASK) <= 0xFFUL,
               "LIMIT/CONTROL inputs must live in bits 0-7 - core truncates these reads to "
               "uint8_t (CONTRACTS.md #1.3, the SAMD21 dead-control-input gap)");

// ============================================================================
// PROBE - GPIO bank 0, bit 6. Polled, no interrupt use.
// ============================================================================
#define PROBE_PORT          0
#define PROBE_PIN           6
#define PROBE_BIT           6
#define PROBE_MASK          (1UL<<PROBE_BIT)

_Static_assert(PROBE_MASK <= 0xFFUL,
               "PROBE input must live in bits 0-7 (CONTRACTS.md #1.3)");

// ============================================================================
// COOLANT - GPIO bank 1
//
// COOLANT_MIST is NOT gated on `#ifdef ENABLE_M7`: this file is reached
// through the build prelude (-include boards/$(BOARD)/prelude.h,
// CONTRACTS.md #0), which runs before grbl.h's own #include "config.h" ever
// defines ENABLE_M7 - a guard here can never observe it set, silently
// dropping this pin even when the user enables the feature (CONTRACTS.md
// #19 "guard that certifies instead of checking", wrong-phase variant; same
// class as this port's own STEP_PULSE_DELAY-unconditional-definition
// precedent in ../../timer.h, and the identical fix already landed on
// ch32v006/ch570's own boards/generic/config.h). Defining the pins
// unconditionally is free - core's own (correctly-timed) `#ifdef ENABLE_M7`
// in coolant_control.c is the only place that ever reads them.
// ============================================================================
#define COOLANT_FLOOD_PORT      1
#define COOLANT_FLOOD_PIN       4
#define COOLANT_FLOOD_BIT       4

#define COOLANT_MIST_PORT       1
#define COOLANT_MIST_PIN        5
#define COOLANT_MIST_BIT        5

// ============================================================================
// SPINDLE - enable/direction are plain GPIO on bank 1; the PWM pad is owned
// by the PWM peripheral once PWM_ENABLE() routes it (spindle_control.c still
// calls GPIO_DIR_OUT on it at init, which is harmless on a pad the PWM block
// subsequently drives - the same behaviour every AF-muxed port in this tree
// has).
//
// SPINDLE_PWM_MAX_VALUE must be <= 255: core plumbs duty as uint8_t
// end-to-end (CONTRACTS.md #6.2, the BUG #22 defect). 255 with PERIOD scaled
// by the same factor as HLPERIOD (platform.c) makes the ratio exact.
// ============================================================================
#define SPINDLE_ENABLE_PORT     1
#define SPINDLE_ENABLE_PIN      1
#define SPINDLE_ENABLE_BIT      1

#define SPINDLE_DIRECTION_PORT  1
#define SPINDLE_DIRECTION_PIN   2
#define SPINDLE_DIRECTION_BIT   2

#define SPINDLE_PWM_PORT        1
#define SPINDLE_PWM_PIN         3
#define SPINDLE_PWM_BIT         3

#define SPINDLE_PWM_CH          0        // cvitek PWM block 0, channel 0 (UNVERIFIED pad mux)
#define SPINDLE_PWM_FREQUENCY   1000UL   // Hz - platform.c derives the scale factor from F_CPU

#define SPINDLE_PWM_MAX_VALUE   255
#define SPINDLE_PWM_MIN_VALUE   1
#define SPINDLE_PWM_OFF_VALUE   0
#define SPINDLE_PWM_RANGE       (SPINDLE_PWM_MAX_VALUE - SPINDLE_PWM_MIN_VALUE)

_Static_assert(SPINDLE_PWM_MAX_VALUE <= 255,
               "SPINDLE_PWM_MAX_VALUE must fit core's uint8_t duty domain (CONTRACTS.md #6.2)");

#endif // BOARD_GENERIC_SG2002_CONFIG_H
