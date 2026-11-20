/*
  bench.c - AVR bench for G5 splines, run under simavr.

  Links the real firmware sources (gcode.c, motion_control.c, planner.c, ...)
  and feeds the lines of lines.txt through gc_execute_line().
  plan_buffer_line() is renamed to
  tb_plan_buffer_line() in planner.c at compile time so every segment passes
  through the probe below, which timestamps it with Timer1 (prescaler 1,
  16 MHz) and keeps the planner buffer one block short of full, as a running
  stepper would. No motion is executed.

  Columns per measured line:
    status  returned status code
    seg     segments queued
    total   cycles spent in the line
    plan    cycles spent inside the real planner
    gen     total - plan: parsing + segment generation + mc_line overhead
    first   cycles from line start to the first segment entering the planner
    gap     worst cycles between two consecutive segments, planner excluded
    exact   1 if the last segment equals the parser position bit for bit
    nonfin  segments with a non-finite coordinate
    hash    FNV-1a of all segment targets, comparable with `tb --hash`
  Last line: stack bytes never touched during the whole run.

  Built with -DTB_DUMP (make dump), the bench also prints every segment
  target as "p X Y Z", each axis as the raw bits of its float in decimal,
  after the line text on a line of its own. `tb --dump` checks those points
  against the curve model on the host. Cycle counts are then not valid.

  Part of Grbl. License: GPLv3, see grbl/grbl.h.
*/

#include "grbl.h"
#include <avr/sleep.h>

uint8_t tb_plan_buffer_line(float *target, plan_line_data_t *pl_data);

static volatile uint16_t ovf;
ISR(TIMER1_OVF_vect) { ovf++; }

static uint32_t now(void)
{
  uint8_t sreg = SREG;
  cli();
  uint16_t lo = TCNT1;
  uint16_t hi = ovf;
  if ((TIFR1 & _BV(TOV1)) && lo < 0x8000) { hi++; } // Overflow pending, not yet counted.
  SREG = sreg;
  return ((uint32_t)hi << 16) | lo;
}

static uint32_t t_start, t_exit, plan, first, gap, hash;
static uint16_t seg, nonfin;
static float last[N_AXIS];

static void field(uint32_t v) { serial_write(' '); print_uint32_base10(v); }

uint8_t plan_buffer_line(float *target, plan_line_data_t *pl_data)
{
  uint32_t t0 = now();
  uint32_t d = t0 - (seg ? t_exit : t_start);
  if (seg == 0) { first = d; } else if (d > gap) { gap = d; }
  // Bookkeeping outside the timed planner call; its cycles land in gen.
  const uint8_t *b = (const uint8_t *)target;
  for (uint8_t i = 0; i < sizeof(last); i++) { hash = (hash ^ b[i]) * 16777619UL; }
  for (uint8_t i = 0; i < N_AXIS; i++) {
    if ((((const uint16_t *)&target[i])[1] & 0x7f80) == 0x7f80) { nonfin++; break; } // Exponent all ones.
  }
  memcpy(last, target, sizeof(last));
#ifdef TB_DUMP
  serial_write('p');
  for (uint8_t i = 0; i < N_AXIS; i++) { field(((const uint32_t *)target)[i]); }
  printPgmString(PSTR("\r\n"));
#endif
  uint32_t t1 = now();
  uint8_t r = tb_plan_buffer_line(target, pl_data);
  if (plan_check_full_buffer()) { plan_discard_current_block(); }
  seg++;
  t_exit = now();
  plan += t_exit - t1;
  return r;
}

#define L(s) s "\0"
static const char lines[] PROGMEM =
#include "lines.h"
  ;

// Stack watermark: everything between the heap start and the stack pointer
// is painted at start-up; bytes still holding the paint were never used.
extern uint8_t __heap_start;
#define PAINT 0xa5

static void paint(void)
{
  uint8_t *p = &__heap_start, *end = (uint8_t *)SP - 16;
  while (p < end) { *p++ = PAINT; }
}

static uint16_t untouched(void)
{
  uint8_t *p = &__heap_start;
  while (*p == PAINT && p < (uint8_t *)RAMEND) { p++; }
  return p - &__heap_start;
}

int main(void)
{
  paint();
  serial_init();
  settings_init();
  memset(sys_position, 0, sizeof(sys_position));
  sys.state = STATE_IDLE;
  gc_init();
  plan_reset();

  TCCR1A = 0;
  TCCR1B = _BV(CS10);
  TIMSK1 = _BV(TOIE1);
  sei();

  // Calibration: a known delay must read back as its cycle count plus a small overhead.
  while (serial_get_tx_buffer_count()) { } // settings_init() may still be printing.
  uint32_t t = now();
  __builtin_avr_delay_cycles(1000000);
  printPgmString(PSTR("calib"));
  field(now() - t);
  printPgmString(PSTR("\r\n"));

  char line[LINE_BUFFER_SIZE];
  const char *p = lines;
  while (pgm_read_byte(p)) {
    strncpy_P(line, p, sizeof(line));
    p += strlen(line) + 1;
    uint8_t measure = (line[0] == '*');
    char *g = line + measure;
    printString(g);
#ifdef TB_DUMP
    printPgmString(PSTR("\r\n"));
#endif
    while (serial_get_tx_buffer_count()) { } // No UART interrupts inside a measurement.
    seg = 0; nonfin = 0; plan = 0; first = 0; gap = 0; hash = 2166136261UL;
    t_start = now();
    uint8_t status = gc_execute_line(g);
    uint32_t total = now() - t_start;
    if (measure || status) {
      field(status); field(seg); field(total); field(plan); field(total - plan);
      field(first); field(gap);
      field(seg && !memcmp(last, gc_state.position, sizeof(last)));
      field(nonfin); field(hash);
    }
    printPgmString(PSTR("\r\n"));
  }
  printPgmString(PSTR("stack"));
  field(untouched());
  printPgmString(PSTR("\r\ndone\r\n"));
  while (serial_get_tx_buffer_count()) { }
  _delay_ms(2); // Let the last byte leave the shift register.
  cli();
  sleep_mode(); // simavr exits on sleep with interrupts disabled.
  return 0;
}
