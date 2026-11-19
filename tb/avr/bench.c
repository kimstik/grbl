/*
  bench.c - AVR cycle-count bench for G5 splines, run under simavr.

  Links the real firmware sources (gcode.c, motion_control.c, planner.c, ...)
  and feeds G-code lines through gc_execute_line(). plan_buffer_line() is
  renamed to tb_plan_buffer_line() in planner.c at compile time so every
  segment passes through the probe below, which timestamps it with Timer1
  (prescaler 1, 16 MHz) and keeps the planner buffer one block short of full,
  as a running stepper would. No motion is executed.

  Columns per measured line:
    seg    segments queued
    total  cycles spent in gc_execute_line()
    plan   cycles spent inside the real planner
    gen    total - plan: parsing + segment generation + mc_line overhead
    first  cycles from line start to the first segment entering the planner
    gap    worst cycles between two consecutive segments, planner excluded

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

static uint32_t t_start, t_exit, plan, first, gap;
static uint16_t seg;

uint8_t plan_buffer_line(float *target, plan_line_data_t *pl_data)
{
  uint32_t t0 = now();
  uint32_t d = t0 - (seg ? t_exit : t_start);
  if (seg == 0) { first = d; } else if (d > gap) { gap = d; }
  uint8_t r = tb_plan_buffer_line(target, pl_data);
  if (plan_check_full_buffer()) { plan_discard_current_block(); }
  seg++;
  t_exit = now();
  plan += t_exit - t0;
  return r;
}

static void field(uint32_t v) { serial_write(' '); print_uint32_base10(v); }

// Lines are in the form the protocol hands to the parser: upper case, no spaces.
// A leading '*' marks a line to measure; the rest only set up state.
// Curves mostly run toward -X because the parser rejects a negative P (error:4).
static const char vectors[] PROGMEM =
  "G21G90G94G17F1000\0"
  "G0X0Y0Z0\0"
  "*G1X10Y0\0"           // one plain segment, reference cost
  "G0X0Y0\0"
  "*G2X20Y0I10J0\0"      // R10 half circle, reference arc
  "G0X0Y0\0"
  "*G5I-5J5P5Q-5X-20Y0\0"      // gentle S
  "G0X0Y0\0"
  "*G5I-50J100P50Q100X-100Y0\0" // large bulge
  "G0X0Y0\0"
  "*G5I-10J0P10Q0X-30Y0\0"     // collinear controls: straight line
  "G0X0Y0\0"
  "*G5I30J30P30Q-30X0Y0\0"     // closed loop, end == start
  "G0X0Y0\0"
  "*G5I-0.1J0.1P0.1Q0.1X-0.5Y0\0" // tiny
  "G0X0Y0\0"
  "*G5I0J40P0Q40X1Y0\0"        // near cusp
#ifdef ENABLE_QUADRATIC_SPLINES
  "G0X0Y0\0"
  "*G5.1I10J20X20Y0\0"
#endif
  ;

int main(void)
{
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
  const char *p = vectors;
  while (pgm_read_byte(p)) {
    strncpy_P(line, p, sizeof(line));
    p += strlen(line) + 1;
    uint8_t measure = (line[0] == '*');
    char *g = line + measure;
    while (serial_get_tx_buffer_count()) { } // No UART interrupts inside a measurement.
    seg = 0; plan = 0; first = 0; gap = 0;
    t_start = now();
    uint8_t status = gc_execute_line(g);
    uint32_t total = now() - t_start;
    if (!measure && !status) { continue; }
    printString(g);
    field(status); field(seg); field(total); field(plan); field(total - plan);
    field(first); field(gap);
    printPgmString(PSTR("\r\n"));
  }
  printPgmString(PSTR("done\r\n"));
  while (serial_get_tx_buffer_count()) { }
  _delay_ms(2); // Let the last byte leave the shift register.
  cli();
  sleep_mode(); // simavr exits on sleep with interrupts disabled.
  return 0;
}
