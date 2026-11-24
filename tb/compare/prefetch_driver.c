/* Deterministic control flow for the real spline driver, not stepper timing. */
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#ifndef MC_SOURCE
#error "MC_SOURCE must select the source snapshot"
#endif
#include MC_SOURCE

system_t sys;
settings_t settings;
static unsigned strategy, abort_mode, points, optional, realtime, waits, checks;
static unsigned full, credit;
static uint32_t events;

static void event(unsigned code)
{
  events = (events ^ code)*16777619u;
}

static void raw(float v)
{
  union { float f; uint32_t u; } b = {v};
  printf(" %08x", (unsigned)b.u);
}

uint8_t plan_check_full_buffer(void)
{
  checks++;
  event(0x10u + full);
  return full;
}

uint8_t plan_buffer_line(float *p, plan_line_data_t *data)
{
  points++;
  event(0x20);
  printf("p");
  for (unsigned k = 0; k < N_AXIS; k++) { raw(p[k]); }
  raw(data->feed_rate);
  printf(" %02x\n", data->condition);
  full = 1;
  credit = 12;
  return PLAN_OK;
}

void protocol_auto_cycle_start(void)
{
  waits++;
  event(0x30);
  assert(credit);
  if (!--credit) { full = 0; }
}

void protocol_execute_realtime(void)
{
  realtime++;
  event(0x40);
  assert(realtime < 1000000);
  if ((abort_mode == 1 && realtime == 1) || (abort_mode == 2 && points == 1)) {
    sys.abort = true;
  }
}

#ifdef BEZIER_Z_PREFETCH
uint8_t st_has_compute_reserve(void)
{
  uint8_t admit = strategy && spline_z.prefetch != 2;
  if (strategy == 1 && spline_z.prefetch != 0) { admit = false; }
  event(0x50u + admit);
  if (admit) { optional++; }
  return admit;
}
#endif

void limits_soft_check(float *p) { (void)p; assert(0); }
void spindle_sync(uint8_t state, float rpm) { (void)state; (void)rpm; assert(0); }

static void curve(unsigned id, float scale, float dz, int inverse, unsigned shape)
{
  float start[3] = {0, 0, 0};
  float first[3] = {0.3f*scale, 1.2f*scale, 0};
  float second[3] = {1.3f*scale, -1.2f*scale, dz};
  float target[3] = {scale, 0, dz};
  if (shape == 1) {
    first[0] = 68.0625f; first[1] = 49.5f;
    second[0] = 4.125f; second[1] = 3;
    target[0] = -191.8125f; target[1] = -139.5f;
  } else if (shape == 2) {
    first[0] = 100000; first[1] = 0;
    second[0] = 11; second[1] = 50000;
    target[0] = 10;
  } else if (shape == 3) {
    first[0] = second[0] = target[0] = 100;
    first[1] = second[1] = 0;
  } else if (shape == 4) {
    first[0] = first[1] = second[0] = second[1] = target[0] = 0;
  }
  plan_line_data_t data = {0};
  data.feed_rate = inverse ? 2.0f : 1000.0f;
  data.condition = inverse ? PL_COND_FLAG_INVERSE_TIME : 0;
  memset(&spline_z, 0, sizeof spline_z);
  memset(&bezier_z_trace, 0, sizeof bezier_z_trace);
  memset(&sys, 0, sizeof sys);
  points = optional = realtime = waits = checks = full = credit = 0;
  events = 2166136261u;
  printf("curve %u inv%d abort%u\n", id, inverse, abort_mode);
  mc_cubic_b_spline(target, &data, start, first, second);
  // A one-block pure-Z move has no later realtime call to inject the second abort.
  unsigned aborted = abort_mode == 1 || (abort_mode == 2 && shape != 4);
  assert(aborted == (sys.abort != 0));
  if (abort_mode == 1) { assert(points == 0); }
  if (abort_mode == 2) { assert(points == 1); }
  printf("trace %u %u %u %u %u %u", bezier_z_trace.estimates, bezier_z_trace.sums,
         bezier_z_trace.open, bezier_z_trace.ends, bezier_z_trace.pieces, bezier_z_trace.summed);
  raw(bezier_z_trace.bound); raw(bezier_z_trace.time); raw(bezier_z_trace.half);
  putchar('\n');
  fprintf(stderr, "case%u inv%d abort%u strategy%u points%u optional%u rt%u waits%u checks%u events%08x\n",
          id, inverse, abort_mode, strategy, points, optional, realtime, waits, checks, (unsigned)events);
}

int main(int argc, char **argv)
{
  strategy = argc > 1 ? (unsigned)atoi(argv[1]) : 0;
  abort_mode = argc > 2 ? (unsigned)atoi(argv[2]) : 0;
  settings.arc_tolerance = .002f;
  for (int inv = 0; inv < 2; inv++) {
    curve(0, 10, -30, inv, 0);
    curve(1, 20, -10, inv, 0);
    curve(2, 60, -30, inv, 0);
    curve(3, 1000, -500, inv, 0);
    curve(4, 1, 1000, inv, 1);
    curve(5, 1, 50, inv, 2);
    curve(6, .1f, 2, inv, 0);
    curve(7, 100, 1000, inv, 3);
    curve(8, 0, 10, inv, 4);
    curve(9, 10, 0, inv, 0);
  }
  return 0;
}
