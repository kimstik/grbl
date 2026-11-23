/*
  dyn.c - AVR dynamic bench for G5 splines with the real stepper, run under simavr.

  Links the real firmware sources like bench.c and runs the real main() and
  protocol_main_loop(). serial_read() is renamed in serial.c, the one below
  plays the host instead of the RX buffer. It streams generated programs at
  115200 baud, one line at a time: after each line it returns SERIAL_NO_DATA
  once, as the RX buffer is empty while the host waits for the "ok", then
  waits a host latency before the next line comes in.
  plan_buffer_line() is renamed to tb_plan_buffer_line() in planner.c, so every
  block passes through the probe below.

  TB_DYN_SPLINES_ONLY omits the G1/G2 reference programs and their chord
  generator so the larger spline prototypes fit. All G5 runs then include
  Z-0.2 when enabled. len_um and feed are projected X travel and speed, not
  path length and feed; the firmware, planner and ISRs are unchanged.

  Timer2 keeps the setup of spindle_init() (fast PWM, prescaler 64), its
  overflow is a 1.024 ms clock, and the spindle stays off. Its ISR paces the
  host, injects feed hold and cycle start, and stops a program that hangs.

  Output lines (simavr prints UART lines to stderr, mixed with grbl's "ok"):
    run    kind size_um F accel lat_ms seg len_um t_ms feed peak min min_full low stops cut cut_F dx dy stack
      kind      G5 cubic S-curves, G1 the same curves as straight segments
                (same block count), G2 alternating G2/G3 half circles
      seg       blocks queued, len_um the programmed path length
      feed      len / t in mm/min, t from the first line to the end of motion
      peak      most planner blocks seen
      min       fewest planner blocks seen while cycling before the last line
      min_full  the same, counted only after the buffer was first full (- if never)
      low       times the planner fell to 0 or 1 block (same window as min)
      stops     times the machine went idle mid-program
      cut       stops with blocks still queued: the main loop was too busy to
                refill the step segment buffer, and the stepper stopped with
                no deceleration
      cut_F     the highest feed it was cut at, mm/min (entry speed of the
                block in progress)
      dx dy     final sys_position minus the parser target, in steps
      stack     most stack used, in bytes below RAMEND, ISRs included
    hold   delay_ms state@hold x@hold state@resume suspend@resume dx dy dz t_ms stack
      x@hold    steps from the program start; 1250 steps per 5 mm curve
                Built with BEZIER_Z_LINEAR, these curves also move Z, 0.2 mm each.
    stack  most stack used in all programs, bytes never touched
    timeout     a program hung, the bench stops

  Part of Grbl. License: GPLv3, see grbl/grbl.h.
*/

#include "grbl.h"
#include <avr/sleep.h>

#define STEPS_PER_MM 250    // 6000 mm/min max rate -> 25 kHz step rate per axis
#define MAX_RATE     6000
#define CURVES       12     // curves per program
#define RESUME_MS    400    // hold to resume, longer than any hold deceleration here
#define TIMEOUT_MS   30000
#define TICKS(ms)    ((ms) * 1000UL / 1024)
#define BAUD_CREDIT  118    // tenths of a character per tick at 115200 baud
#define PATTERN      0xA5

uint8_t tb_plan_buffer_line(float *target, plan_line_data_t *pl_data);

int grbl_main(void);
int main(void) { return grbl_main(); }

// No $ commands are sent; left out to fit in the flash (renamed in system.c).
// Calling read_float() as the real one does keeps it out of gc_execute_line(),
// whose stack frame then stays as in the firmware.
uint8_t system_execute_line(char *line)
{
  uint8_t i = 0;
  float v;
  read_float(line, &i, &v);
  return STATUS_INVALID_STATEMENT;
}

// Paints the free RAM before anything runs; the untouched part is the stack margin.
extern uint8_t __heap_start;
static void __attribute__((naked, used, section(".init3"))) paint(void)
{
  for (uint8_t *p = &__heap_start; p <= (uint8_t *)RAMEND; p++) { *p = PATTERN; }
}

// Program parameters.
enum { G5, G1, G2 };
static uint8_t kind, k, lat, prog;
static uint16_t pi, lines;
static uint16_t size, feed, accel, hold_ms;
static uint32_t len;

// Timer2 clock since the program start, host pacing, hold injection.
static volatile uint16_t tick;
static volatile int16_t credit;
static uint16_t hold_at, resume_at;
static int32_t hold_x;
static uint8_t hold_state, resume_state, resume_suspend;

ISR(TIMER2_OVF_vect)
{
  uint16_t t = ++tick;
  if (credit < 1000) { credit += BAUD_CREDIT; }
  if (t == hold_at) {
    sys_rt_exec_state |= EXEC_FEED_HOLD; // Interrupts are off in here.
    hold_state = sys.state;
    hold_x = sys_position[X_AXIS];
  }
  if (t == resume_at) {
    resume_state = sys.state;
    resume_suspend = sys.suspend;
    sys_rt_exec_state |= EXEC_CYCLE_START;
  }
  if (t > TICKS(TIMEOUT_MS)) {
    for (const char *s = PSTR("\r\ntimeout\r\n"); pgm_read_byte(s); s++) {
      while (!(UCSR0A & _BV(UDRE0))) { }
      UDR0 = pgm_read_byte(s);
    }
    sleep_mode(); // Interrupts are off, simavr exits.
  }
}

// Probe state for one program.
static uint8_t sampling, cycling, filled, low_now;
static uint8_t peak, run_min, full_min, low, stops, cut;
static uint16_t seg, cut_feed;

// Not inlined: the probe below keeps the frame it has without this.
static void __attribute__((noinline)) cut_off(void)
{
  uint16_t f = lround(sqrtf(plan_get_current_block()->entry_speed_sqr));
  cut++;
  if (f > cut_feed) { cut_feed = f; }
}

// Called through a pointer, as with one caller left it would be inlined, and
// the stack would no longer match the firmware's.
static uint8_t (* volatile planner)(float *, plan_line_data_t *) = tb_plan_buffer_line;

uint8_t __attribute__((noinline)) plan_buffer_line(float *target, plan_line_data_t *pl_data)
{
  // The count only drops between two blocks, so its minimum is seen here.
  uint8_t n = plan_get_block_buffer_count();
  if (n >= peak) { peak = n + 1; }
  if (n + 2 == BLOCK_BUFFER_SIZE) { filled = 1; }
  if (sampling) {
    if (sys.state == STATE_CYCLE) {
      cycling = 1;
      if (n < run_min) { run_min = n; }
      if (filled && n < full_min) { full_min = n; }
      if (n <= 1) { low += !low_now; low_now = 1; } else { low_now = 0; }
    } else if (cycling) {
      stops++;
      if (n) { cut_off(); }
      cycling = 0;
    }
  }
  seg++;
  return planner(target, pl_data);
}

#ifndef TB_DYN_SPLINES_ONLY
// Cubic S-curve toward -X: P0 (0,0), P1 (-h,h), P2 (-h,-h), P3 (-s,0) with h = s/2.
// The tangent at both ends is (-1,1), so implicit I,J continue it. P stays positive.
// At t = j/n: x = -s (3/2 u t + t^3), y = 3/2 s u t (u - t), u = 1 - t.
// Chord j of n, in um.
static int32_t dx, dy;

static void chord(uint8_t j, uint8_t n)
{
  int32_t d = 2L * n * n * n;
  dx = dy = 0;
  for (uint8_t i = 0; i < 2; i++, j--) {
    int32_t a = (int32_t)size * (n - j) * j, x = a * 3 * n + 2L * size * j * j * j, y = a * 3 * (n - 2 * j);
    x = -(x + d / 2) / d;
    y = (y + (y < 0 ? -d / 2 : d / 2)) / d;
    if (i) { dx -= x; dy -= y; } else { dx = x; dy = y; }
  }
}

#endif

// Line builder.
static char line[48]; // The longest is G5I-2.500J2.500P2.500Q-2.500Z-0.200X-5.000
static char *lp = line;

static void put(const char *s) { while ((*lp = pgm_read_byte(s++))) { lp++; } }

// Number, or a word with a value in um printed in mm when letter is set.
static void put_u(char letter, int32_t v)
{
  char d[10];
  uint8_t i = 0;
  if (letter) {
    *lp++ = letter;
    if (v < 0) { *lp++ = '-'; v = -v; }
  }
  do { d[i++] = '0' + v % 10; v /= 10; } while (v || (letter && i < 4));
  while (i) {
    *lp++ = d[--i];
    if (letter && i == 3) { *lp++ = '.'; }
  }
}

// Writes line pi of the program into line[].
static void make_line(void)
{
  int16_t h = size / 2;
  lp = line;
  if (pi == 0) {
    put(PSTR("G91G1F"));
    put_u(0, feed);
#ifndef TB_DYN_SPLINES_ONLY
  } else if (kind == G1) {
    chord((pi - 1) % k + 1, k);
    put_u('X', dx);
    put_u('Y', dy);
#endif
  } else {
#ifndef TB_DYN_SPLINES_ONLY
    if (kind == G5) {
#endif
      put(PSTR("G5"));
      if (pi == 1) { put_u('I', -h); put_u('J', h); }
      put_u('P', h);
      put_u('Q', -h);
#ifdef BEZIER_Z_LINEAR
#ifdef TB_DYN_SPLINES_ONLY
      put_u('Z', -200);
#else
      if (hold_ms) { put_u('Z', -200); }
#endif
#endif
#ifndef TB_DYN_SPLINES_ONLY
    } else {
      put((pi & 1) ? PSTR("G2") : PSTR("G3"));
      put_u('I', -h);
    }
#endif
    put_u('X', -(int32_t)size);
  }
  *lp++ = '\n';
  *lp = 0;
  lp = line;
  if (pi == lines - 1) { sampling = 0; }
}

// Program list.
static const uint16_t feeds[] PROGMEM = { 1000, 2000, 3000, 4000, 5000 };
static const uint16_t sizes[] PROGMEM = { 2000, 5000 };
static const uint16_t accels[] PROGMEM = { 500, 2000 };
// Host turnaround after the ok in ms: a quick USB serial adapter, an FTDI one
// with its default 16 ms latency timer.
static const uint8_t lats[] PROGMEM = { 2, 16 };
static const uint16_t holds[] PROGMEM = { 60, 150, 333, 500, 777, 1000 };
#define N(a) (sizeof(a) / sizeof(a[0]))
#ifdef TB_DYN_SPLINES_ONLY
  #define KINDS 1
#else
  #define KINDS 3
#endif
#define SWEEP (KINDS * N(lats) * N(feeds) * N(sizes) * N(accels))

// Sets up program prog (from 1), returns 0 past the end.
static uint8_t setup(void)
{
  uint8_t p = prog - 1;
  hold_ms = 0;
  if (p < SWEEP) {
    kind = p % KINDS; p /= KINDS;
    lat = pgm_read_byte(lats + p % N(lats)); p /= N(lats);
    feed = pgm_read_word(feeds + p % N(feeds)); p /= N(feeds);
    size = pgm_read_word(sizes + p % N(sizes)); p /= N(sizes);
    accel = pgm_read_word(accels + p);
  } else if ((p -= SWEEP) < N(holds)) {
    kind = G5; lat = 2; feed = 3000; size = 5000; accel = 500;
    hold_ms = pgm_read_word(holds + p);
  } else {
    return 0;
  }
#ifdef TB_DYN_SPLINES_ONLY
  lines = 1 + CURVES;
  len = (uint32_t)CURVES * size; // Projected X travel, not path length.
#else
  if (kind == G1) { k = (seg + CURVES / 2) / CURVES; } // Blocks per curve of the G5 run before.
  lines = 1 + CURVES * (kind == G1 ? k : 1);
  float l = M_PI * size / 2;
  if (kind != G2) {
    uint8_t n = kind == G1 ? k : 32;
    l = 0;
    for (uint8_t j = 1; j <= n; j++) {
      chord(j, n);
      l += sqrtf((float)dx * dx + (float)dy * dy);
    }
  }
  len = CURVES * l;
#endif
#ifdef TB_ARC_TOLERANCE
  settings.arc_tolerance = TB_ARC_TOLERANCE;
#endif
  for (uint8_t i = 0; i < N_AXIS; i++) {
    settings.steps_per_mm[i] = STEPS_PER_MM;
    settings.max_rate[i] = MAX_RATE;
    settings.acceleration[i] = accel * 3600.0f;
  }
  // Restart from zero, as main() does after a reset.
  memset(sys_position, 0, sizeof(sys_position));
  plan_sync_position();
  gc_sync_position();
  sampling = 1; cycling = 0; filled = 0; low_now = 0;
  peak = 0; run_min = 255; full_min = 255; low = 0; stops = 0; cut = 0; cut_feed = 0;
  seg = 0; pi = 0;
  cli();
  tick = 0;
  TIMSK2 |= _BV(TOIE2);
  // simavr stops a CTC timer whose top is 0, the chip interrupts at once: give
  // the first stepper interrupt a period, the ISR sets its own from then on.
  if (!OCR1A) { OCR1A = 100; }
  hold_at = hold_ms ? TICKS(hold_ms) : 0;
  resume_at = hold_ms ? hold_at + TICKS(RESUME_MS) : 0;
  sei();
  return 1;
}

static void field(int32_t v) { serial_write(' '); printInteger(v); }

// Stack used since the last call, in bytes below RAMEND, then paints again.
static uint16_t depth_max;

static uint16_t stack_used(void)
{
  uint8_t *p = &__heap_start;
  while (*p == PATTERN) { p++; }
  uint16_t d = RAMEND + 1 - (uint16_t)p;
  if (d > depth_max) { depth_max = d; }
  for (p = &__heap_start; p < (uint8_t *)SP - 32; p++) { *p = PATTERN; }
  return d;
}

static void report(void)
{
  cli();
  uint32_t t = tick * 1024UL / 1000;
  sei();
  if (!hold_ms) {
    static const char kinds[] PROGMEM = "G5\0G1\0G2";
    printPgmString(PSTR("run "));
    printPgmString(kinds + 3 * kind);
    field(size); field(feed); field(accel); field(lat); field(seg);
    field(len); field(t); field(len * 60 / t);
    field(peak); field(run_min);
    if (filled) { field(full_min); } else { printPgmString(PSTR(" -")); }
    field(low); field(stops); field(cut); field(cut_feed);
  } else {
    printPgmString(PSTR("hold"));
    field(hold_ms);
    field(hold_state); field(hold_x);
    field(resume_state); field(resume_suspend);
  }
  for (uint8_t i = 0; i < (hold_ms ? N_AXIS : 2); i++) {
    field(sys_position[i] - lround(gc_state.position[i] * settings.steps_per_mm[i]));
  }
  if (hold_ms) { field(t); }
  field(stack_used());
  printPgmString(PSTR("\r\n"));
}

static void finish(void)
{
  printPgmString(PSTR("stack"));
  field(depth_max); field(RAMEND + 1 - (uint16_t)&__heap_start - depth_max);
  printPgmString(PSTR("\r\ndone\r\n"));
  while (serial_get_tx_buffer_count()) { }
  _delay_ms(2); // Let the last byte leave the shift register.
  cli();
  sleep_mode(); // simavr exits on sleep with interrupts disabled.
}

// The host: grbl reads its lines here.
static uint8_t waiting;

uint8_t __attribute__((noinline)) serial_read(void) // Keeps its frame out of main().
{
  uint8_t c;
  if (!*lp) {
    if (waiting) { waiting = 0; return SERIAL_NO_DATA; } // The ok goes out first.
    if (pi == lines) {
      if (plan_get_block_buffer_count() || sys.state != STATE_IDLE) { return SERIAL_NO_DATA; }
      if (prog) { report(); }
      prog++;
      if (!setup()) { finish(); }
    }
    make_line();
    pi++;
    waiting = 1;
    cli();
    credit = -(int16_t)(lat * BAUD_CREDIT); // Turnaround, then the line at the baud rate.
    sei();
  }
  cli();
  c = credit >= 10;
  if (c) { credit -= 10; }
  sei();
  return c ? *lp++ : SERIAL_NO_DATA;
}
