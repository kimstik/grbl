/*
  prelude.h - build prelude for the HOSTED ORACLE (x86 replay of the frozen ISR)

  Part of Grbl / Intelligence assisted / License: MIT

  This is NOT a platform and never becomes one: it has no root platform.h, it is
  not under grbl/platform/, it builds no firmware, and it is never listed in
  tools/build_artifacts.py. It exists so that grbl/stepper.c - the FROZEN file,
  compiled from the tree, not a copy - can be executed on the host as the
  executable specification of the segment boundary.

  It substitutes for grbl/platform/hal.h wholesale by predefining that header's
  own guard, GRBL_HAL_H. hal.h's job is to pick a PLATFORM_xxx and pull in its
  platform.h; the oracle has no silicon to pick, and adding a PLATFORM_HOSTED
  branch to hal.h would shift line numbers in a header every port compiles,
  churning nine DEBUG .elf hashes for a file no firmware build ever reads.
  Suppressing it is one line, is visible right here, and touches nothing shared.

  What the oracle deliberately does NOT do: it does not compile st_prep_buffer's
  float producer path into the corpus. Vectors are authored, not generated from
  x86 floating point (SEGMENT-RUNTIME-PLAN §4 stage 3) - the whole point is that
  the consumer path is integer-only and therefore bit-exact on any host.
*/

#ifndef GRBL_HOSTED_PRELUDE_H
#define GRBL_HOSTED_PRELUDE_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>

#define GRBL_PRELUDE 1
#define GRBL_HAL_H          /* suppress grbl/platform/hal.h - see header comment */
#define PLATFORM_NAME "hosted-oracle"
#define PLATFORM_HOSTED 1

#define __flash const
#define sei()  ((void)0)
#define cli()  ((void)0)

#include "hosted_rt.h"

/* --- pin map (SEGX/1 CONFIG "pin-position map"): logical, X=0 Y=1 Z=2 ------
   The oracle's map is the canonical one, not any board's. direction_bits and
   step_outbits on the wire are pin positions in THIS map; a Profile F executor
   receives the real board's map at CONFIG time and the conformance corpus is
   map-independent as a result. */
#define X_STEP_BIT       0
#define Y_STEP_BIT       1
#define Z_STEP_BIT       2
#define X_DIRECTION_BIT  0
#define Y_DIRECTION_BIT  1
#define Z_DIRECTION_BIT  2
#define STEP_MASK        ((1<<X_STEP_BIT)|(1<<Y_STEP_BIT)|(1<<Z_STEP_BIT))
#define DIRECTION_MASK   ((1<<X_DIRECTION_BIT)|(1<<Y_DIRECTION_BIT)|(1<<Z_DIRECTION_BIT))
#define STEPPERS_DISABLE_BIT 3
#define STEPPERS_DISABLE_MASK (1<<STEPPERS_DISABLE_BIT)

#define TICKS_PER_MICROSECOND (F_CPU/1000000)

/* Normally supplied by the AVR cpu_map.h this build shadows. */
#define SPINDLE_PWM_MAX_VALUE 255
#define SPINDLE_PWM_MIN_VALUE 1
#define SPINDLE_PWM_OFF_VALUE 0
#define SPINDLE_PWM_RANGE     (SPINDLE_PWM_MAX_VALUE-SPINDLE_PWM_MIN_VALUE)

/* --- GPIO / timer HAL, every macro stepper.c reaches for ------------------ */
#define HRT_PORT_ID_STEP             HRT_PORT_STEP
#define HRT_PORT_ID_DIRECTION        HRT_PORT_DIRECTION
#define HRT_PORT_ID_STEPPERS_DISABLE HRT_PORT_ENABLE

#define GPIO_MWO(name, v)      hrt_port_write(HRT_PORT_ID_##name, (uint8_t)(v))
#define GPIO_MRD(name, reg)    hrt_port_read(HRT_PORT_ID_##name)
#define GPIO_OREG(name)        (hrt.port[HRT_PORT_ID_##name])
#define GPIO_BSET(name)        hrt_bit_set(HRT_PORT_ID_##name, name##_MASK)
#define GPIO_BCLR(name)        hrt_bit_clear(HRT_PORT_ID_##name, name##_MASK)
#define GPIO_MDIR_OUT(name)    ((void)0)
#define GPIO_DIR_OUT(name)     ((void)0)

#define STP_TMR_INIT()              ((void)0)
#define STP_TMR_INT_ENA()           hrt_timer_enable()
#define STP_TMR_INT_DIS()           hrt_timer_disable()
#define STP_TMR_PERIOD_SET(v)       hrt_period_set((uint16_t)(v))
#define STP_TMR_PRESCALER_SET(v)    ((void)(v))
#define STP_TMR_PRESCALER_RESET()   ((void)0)
#define STP_PULSE_RESET_INIT()      ((void)0)
#define STP_PULSE_RESET_COUNT_SET(v) hrt_pulse_count_set((uint8_t)(v))
#define STP_PULSE_RESET_COMPARE_SET(v) ((void)(v))
#define STP_PULSE_RESET_START()     hrt_pulse_start()
#define STP_PULSE_RESET_STOP()      hrt_pulse_stop()
#define STP_PULSE_DELAY_INIT()      ((void)0)

#define ISR_STEP()        void grbl_hosted_isr_step(void)
#define ISR_STEP_RESET()  void grbl_hosted_isr_step_reset(void)
#define ISR_STEP_DELAY()  void grbl_hosted_isr_step_delay(void)

void delay_ms(uint16_t ms);
void delay_us(uint32_t us);

/* Pull the whole core in HERE, after every HAL macro above is in place and
   before seg_tap.h needs to test the config tuple. config.h cannot be included
   on its own (it #includes grbl.h at its top under grbl.h's guard, so a bare
   config.h include leaves HOMING_CYCLE_0 undefined and grbl.h's own
   compile-time checks fire). stepper.c's later #include "grbl.h" is a no-op. */
#include "../../grbl/grbl.h"

/* --- the seam ------------------------------------------------------------
   GRBL_SEG_PUBLISH is left at its in-file default: the oracle drives the ring
   from the consumer side and must not perturb the producer's strobe. Only the
   TU-export hook is claimed, with the loader fragment added because replaying a
   captured stream means writing slots the frozen producer would have written. */
#include "seg_tap.h"
#define GRBL_STEPPER_TU_EXPORTS SEG_TAP_CAT2(SEG_TAP_READERS, SEG_TAP_LOADERS)

#endif /* GRBL_HOSTED_PRELUDE_H */
