/* Test-only snapshots at the step-segment publication and empty-ISR sites.
   The observed build changes timing/RAM/stack. Use the normal dyn build for
   production stack and throughput comparisons. */
#ifndef TB_AVR_OBSERVE_H
#define TB_AVR_OBSERVE_H

typedef struct {
  uint16_t empty;          /* All ISR empty-buffer shutdowns, including the end. */
  uint16_t queued;         /* A planner block was still available at shutdown. */
  uint16_t moving;         /* The last published segment had nonzero exit speed. */
  float max_exit;          /* Planned endpoint speed of that segment, mm/min. */
  uint16_t cycles;         /* Timer ticks per ISR at the largest moving exit. */
  uint8_t amass;           /* Its AMASS level, or zero when AMASS is disabled. */
} tb_observe_t;

extern volatile tb_observe_t tb_observe;
void tb_observe_reset(void);  /* Call with interrupts disabled, between programs. */
#endif
