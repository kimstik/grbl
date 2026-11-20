#!/usr/bin/env python3
"""Generate a test-only stepper TU from the actual firmware source.

No production source is modified. A speed snapshot accompanies each published
step segment. At the empty ISR branch the most recently consumed slot is the
last executed segment, so its *endpoint* speed distinguishes a planned stop
from a missing continuation. This is not a physical instantaneous speed sensor.
The copied source still executes the real ISR, planner and realtime protocol.
"""
import pathlib
import sys


def replace_once(source, old, new):
    if source.count(old) != 1:
        raise SystemExit("stepper observation anchor is not unique: " + old)
    return source.replace(old, new)


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: observe.py SOURCE/stepper.c OUTPUT.c")
    source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
    source = replace_once(source, "#include \"grbl.h\"", "#include \"grbl.h\"\n#include \"observe.h\"")
    source = replace_once(source, "static st_prep_t prep;", """static st_prep_t prep;

// These arrays are test-only. Publish the snapshot before segment_buffer_head.
volatile tb_observe_t tb_observe;
static volatile float tb_exit[SEGMENT_BUFFER_SIZE];
static volatile uint16_t tb_cycles[SEGMENT_BUFFER_SIZE];
static volatile uint8_t tb_amass[SEGMENT_BUFFER_SIZE];

void tb_observe_reset(void)
{
  memset((void *)&tb_observe, 0, sizeof(tb_observe));
  memset((void *)tb_exit, 0, sizeof(tb_exit));
  memset((void *)tb_cycles, 0, sizeof(tb_cycles));
  memset((void *)tb_amass, 0, sizeof(tb_amass));
}

static void __attribute__((noinline)) tb_empty(void)
{
  uint8_t last = segment_buffer_tail ? segment_buffer_tail - 1 : SEGMENT_BUFFER_SIZE - 1;
  float v = tb_exit[last];
  if (tb_observe.empty != 0xffff) { tb_observe.empty++; }
  if (plan_get_current_block() && tb_observe.queued != 0xffff) { tb_observe.queued++; }
  if (v > 0.0f) {
    if (tb_observe.moving != 0xffff) { tb_observe.moving++; }
    if (v > tb_observe.max_exit) {
      tb_observe.max_exit = v;
      tb_observe.cycles = tb_cycles[last];
      tb_observe.amass = tb_amass[last];
    }
  }
}
""")
    source = replace_once(source, "      // Segment buffer empty. Shutdown.",
                          "      // Segment buffer empty. Shutdown.\n      tb_empty();")
    source = replace_once(source, "    segment_buffer_head = segment_next_head;", """    tb_exit[segment_buffer_head] = prep.current_speed;
    tb_cycles[segment_buffer_head] = prep_segment->cycles_per_tick;
    #ifdef ADAPTIVE_MULTI_AXIS_STEP_SMOOTHING
      tb_amass[segment_buffer_head] = prep_segment->amass_level;
    #else
      tb_amass[segment_buffer_head] = 0;
    #endif
    segment_buffer_head = segment_next_head;""")
    pathlib.Path(sys.argv[2]).write_text(source, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
