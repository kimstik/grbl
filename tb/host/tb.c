/* tb.c - host test bench for G5/G5.1.

   Runs G-code through the real gc_execute_line -> mc_* -> mc_line ->
   plan_buffer_line path and checks properties that do not depend on how the
   curve is segmented. See ../README.md for the catalog.

   Usage:
     tb FILE.vec...            run vector files
     tb --random N SEED        N random curves, failures shrunk to a minimal line
     tb --hash LINES           segment count and hash per measured line of
                               tb/avr/lines.txt, as tb/avr/bench.c prints them
     tb --dump LINES OUT       check the segment targets that tb/avr dump.elf
                               printed under simavr (OUT) against the model

   Vector file syntax, one statement per line, '#' starts a comment:
     = name [@bug]             new test; machine at X-100 Y-100 Z-10 (mm), work
                               offsets zero, F unset.
                               @bug: known open defect, failures count as XFAIL
     set KEY VALUE             soft 0|1, check 0|1, laser 0|1, tol MM, maxseg N,
                               smooth 0|1, steps N (all axes), rate MM/MIN, accel MM/S^2
     reset                     soft reset: parser and planner re-initialized,
                               machine position kept
     GCODE [-> ok|error|error:N|any]   default expectation: ok
     pos X Y Z                 parser position (machine mm) within 1e-4
     same DX DY DZ             segments of the last curve equal those of the curve
                               before it shifted by DX DY DZ, within 1e-3 mm
     circle CX CY R DEV        segment ends of the last curve within DEV of the
                               circle (machine mm)
     junction V                some junction inside the last curve is limited to
                               at most V mm/min (a stop at a cusp)
     travel A MM               executed steps of axis A (X, Y or Z) on the last line,
                               summed without sign, are at most MM mm
     power S                   every segment of the last line was queued with
                               spindle (laser) speed S

   Checked on every line:
     rejected line: no segment queued and parser state byte-identical
   Checked on every accepted G5/G5.1:
     finite targets; last target == parser position (bit-exact); parser end ==
     model end; planner steps == parser position; segment count <= maxseg;
     two-sided distance between polyline and the double model <= tol;
     G93 time == 1/F; smooth 1: no sharper corner at the join with the
     previous curve than inside either curve. */
#include "grbl.h"
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>

extern int tb_soft_limit_hits;
extern float tb_coord[N_COORDINATE_SYSTEM + 2][N_AXIS];
uint8_t __real_plan_buffer_line(float *target, plan_line_data_t *pl_data);

#define MAXSEG 20000
typedef float pt_t[N_AXIS];
static pt_t seg[MAXSEG];                    /* targets queued by the current line */
static pt_t curve[2][MAXSEG];               /* last accepted curve and the one before */
static int nseg, ncurve[2];
static int32_t steps[N_AXIS];               /* executed (drained) step position */
static uint32_t travel[N_AXIS];             /* executed steps of the current line, unsigned */
static double line_time, min_junction;      /* minutes; mm/min */
static float power_min, power_max;          /* spindle speed of the segments of the current line */
static int checks, line_fails;
static double tol, maxseg;
static int smooth;
static double prev_dir[2], prev_turn;       /* last direction and sharpest turn of the previous curve */
static int prev_curve;

static const char *test = "";
static int lineno, bug;
static int n_pass, n_fail, n_xfail, n_xpass, test_fails, quiet;

uint8_t __wrap_plan_buffer_line(float *target, plan_line_data_t *pl_data)
{
  if (nseg < MAXSEG) { memcpy(seg[nseg], target, sizeof(pt_t)); }
  if (pl_data->spindle_speed < power_min) { power_min = pl_data->spindle_speed; }
  if (pl_data->spindle_speed > power_max) { power_max = pl_data->spindle_speed; }
  if (++nseg > 1000000) { sys.abort = true; }  /* runaway guard; reported by the count check */
  return __real_plan_buffer_line(target, pl_data);
}

/* Stand-in for the stepper: execute every queued block. */
void tb_drain(void)
{
  plan_block_t *b;
  while ((b = plan_get_current_block())) {
    for (int i = 0; i < N_AXIS; i++) {
      steps[i] += (b->direction_bits & (1 << i)) ? -(int32_t)b->steps[i] : (int32_t)b->steps[i];
      travel[i] += b->steps[i];
    }
    if (!(b->condition & PL_COND_FLAG_RAPID_MOTION)) { line_time += b->millimeters / b->programmed_rate; }
    double v = sqrt(b->max_junction_speed_sqr);
    if (v < min_junction) { min_junction = v; }
    plan_discard_current_block();
  }
  memcpy(sys_position, steps, sizeof(steps));
}

static void fail(const char *fmt, ...)
{
  va_list ap;
  line_fails++;
  if (quiet) { return; }
  printf("  %s %s:%d: ", bug ? "xfail" : "FAIL", test, lineno);
  va_start(ap, fmt); vprintf(fmt, ap); va_end(ap);
  printf("\n");
}

static void machine_reset(void)
{
  memset(&sys, 0, sizeof(sys));
  memset(&settings, 0, sizeof(settings));
  for (int i = 0; i < N_AXIS; i++) {
    settings.steps_per_mm[i] = 250; settings.max_rate[i] = 5000;
    settings.acceleration[i] = 10*60*60; settings.max_travel[i] = -200;
    steps[i] = -100 * 250;
  }
  steps[Z_AXIS] = -10 * 250;
  settings.junction_deviation = 0.01f; settings.arc_tolerance = 0.002f;
  memcpy(sys_position, steps, sizeof(steps));
  memset(tb_coord, 0, sizeof(tb_coord));      /* work offsets do not leak from the previous test */
  plan_reset(); plan_sync_position();
  gc_init(); gc_sync_position();
  tol = 0.1; maxseg = 2000; smooth = 0; prev_curve = 0; nseg = ncurve[0] = ncurve[1] = 0;
}

/* ---- independent model: LinuxCNC semantics of G5/G5.1 in the XY plane ---- */

static struct { int inch, incr, inv, motion; double pq[2], f; } m;  /* motion: 0, 50 (G5), 51 (G5.1) */
typedef struct { double p[4][N_AXIS]; int ok; } curve_t;

static double bez(const curve_t *c, int a, double t)
{
  double u = 1 - t;
  return u*u*u*c->p[0][a] + 3*u*u*t*c->p[1][a] + 3*u*t*t*c->p[2][a] + t*t*t*c->p[3][a];
}

/* Model of one normalized line; returns the curve when the line is a G5/G5.1 move. */
static curve_t model_line(const char *l, const float *start, const float *wco)
{
  curve_t c; memset(&c, 0, sizeof(c));
  double w[26]; int has[26] = {0}, g5 = 0, axis_cmd = 0;
  for (const char *s = l; *s; ) {
    char k = *s++; char *e; double v = strtod(s, &e);
    if (k < 'A' || k > 'Z' || e == s) { continue; }
    s = e;
    if (k == 'G') {
      int g = (int)lround(v * 10);
      if (g == 200) m.inch = 1; else if (g == 210) m.inch = 0;
      else if (g == 900) m.incr = 0; else if (g == 910) m.incr = 1;
      else if (g == 930) m.inv = 1; else if (g == 940) m.inv = 0;
      else if (g == 50 || g == 51) { m.motion = g; g5 = 1; }
      else if (g <= 30 || g == 800 || (g >= 382 && g <= 385)) m.motion = 0;
      else if (g == 100 || g == 280 || g == 300 || g == 920 || g == 431) axis_cmd = 1;  /* axis words are not a move target */
      continue;
    }
    w[k-'A'] = v; has[k-'A'] = 1;
  }
  #define HAS(ch) has[(ch)-'A']
  #define W(ch) w[(ch)-'A']
  if (HAS('F')) m.f = W('F');
  int axes = HAS('X') || HAS('Y') || HAS('Z');
  if (axis_cmd || !(m.motion && (g5 || axes))) return c;
  double u = m.inch ? 25.4 : 1, ij[2], pq[2];
  for (int a = 0; a < N_AXIS; a++) {
    int k = "XYZ"[a];
    c.p[0][a] = start[a];
    c.p[3][a] = !HAS(k) ? start[a] : m.incr ? start[a] + W(k)*u : W(k)*u + wco[a];
    c.p[1][a] = c.p[0][a]; c.p[2][a] = c.p[3][a];
  }
  if (HAS('I') || HAS('J')) { ij[0] = HAS('I') ? W('I')*u : 0; ij[1] = HAS('J') ? W('J')*u : 0; }
  else { ij[0] = -m.pq[0]; ij[1] = -m.pq[1]; }
  pq[0] = HAS('P') ? W('P')*u : 0; pq[1] = HAS('Q') ? W('Q')*u : 0;
  for (int a = 0; a < 2; a++) {
    if (m.motion == 50) { c.p[1][a] = c.p[0][a] + ij[a]; c.p[2][a] = c.p[3][a] + pq[a]; }
    else { double q = c.p[0][a] + ij[a]; c.p[1][a] = c.p[0][a] + 2.0/3*(q - c.p[0][a]); c.p[2][a] = c.p[3][a] + 2.0/3*(q - c.p[3][a]); }
  }
  if (m.motion == 50) { m.pq[0] = pq[0]; m.pq[1] = pq[1]; }
  c.ok = 1;
  return c;
}

static double seg_dist(const double *q, const double *a, const double *b)
{
  double dx = b[0] - a[0], dy = b[1] - a[1], l2 = dx*dx + dy*dy;
  double s = l2 > 0 ? ((q[0]-a[0])*dx + (q[1]-a[1])*dy) / l2 : 0;
  if (s < 0) s = 0;
  if (s > 1) s = 1;
  return hypot(a[0] + s*dx - q[0], a[1] + s*dy - q[1]);
}

static double dist_to_poly(const double *q, double (*pts)[2], int n)
{
  double best = hypot(pts[0][0] - q[0], pts[0][1] - q[1]);
  for (int k = 1; k < n; k++) { double d = seg_dist(q, pts[k-1], pts[k]); if (d < best) best = d; }
  return best;
}

static double turn(const double *d0, const double *d1)  /* angle between two directions, rad */
{
  return atan2(fabs(d0[0]*d1[1] - d0[1]*d1[0]), d0[0]*d1[0] + d0[1]*d1[1]);
}

#define DENSE 4000
static double dense[DENSE + 1][2], poly[MAXSEG + 1][2];

/* Two-sided distance in XY between the polyline start, pts[0..n) and the model curve. */
static double curve_dev(const curve_t *c, const float *start, pt_t *pts, int n)
{
  for (int k = 0; k <= DENSE; k++) { dense[k][0] = bez(c, 0, (double)k/DENSE); dense[k][1] = bez(c, 1, (double)k/DENSE); }
  poly[0][0] = start[0]; poly[0][1] = start[1];
  for (int k = 0; k < n; k++) { poly[k+1][0] = pts[k][0]; poly[k+1][1] = pts[k][1]; }
  double dev = 0;
  for (int k = 0; k <= DENSE; k++) { double d = dist_to_poly(dense[k], poly, n + 1); if (d > dev) dev = d; }
  for (int k = 0; k <= n; k++) { double d = dist_to_poly(poly[k], dense, DENSE + 1); if (d > dev) dev = d; }
  return dev;
}

static void check_curve(const curve_t *c, const float *start)
{
  int n = nseg < MAXSEG ? nseg : MAXSEG;
  checks++;
  if (nseg > maxseg) fail("segment count %d > %g", nseg, maxseg);
  if (n == 0) { fail("no segment queued for an accepted move"); return; }
  for (int k = 0; k < n; k++) for (int a = 0; a < N_AXIS; a++)
    if (!isfinite(seg[k][a])) { fail("non-finite target, segment %d axis %d", k, a); return; }
  for (int a = 0; a < N_AXIS; a++) {
    if (seg[n-1][a] != gc_state.position[a]) fail("last target != parser position, axis %d delta %g", a, seg[n-1][a] - gc_state.position[a]);
    if (fabs(gc_state.position[a] - c->p[3][a]) > 1e-4 + 1e-6*fabs(c->p[3][a])) fail("parser end %g != model end %g, axis %d", gc_state.position[a], c->p[3][a], a);
    int32_t want = (int32_t)lroundf(gc_state.position[a] * settings.steps_per_mm[a]);
    if (steps[a] != want) fail("planner steps %d != parser position steps %d, axis %d", steps[a], want, a);
  }
  double dev = curve_dev(c, start, seg, n);
  if (dev > tol) fail("deviation %.4f mm > tol %g (%d segments)", dev, tol, nseg);
  if (m.inv && m.f > 0 && fabs(line_time*m.f - 1) > 0.02) fail("G93 time %g min, expected %g", line_time, 1/m.f);
  /* Corners: sharpest turn inside this curve and at the join with the previous one. */
  double d0[2] = {0, 0}, first[2] = {0, 0}, sharpest = 0; int have = 0;
  for (int k = 1; k <= n; k++) {
    double d[2] = {poly[k][0] - poly[k-1][0], poly[k][1] - poly[k-1][1]};
    if (hypot(d[0], d[1]) < 1e-6) continue;
    if (have) { double t = turn(d0, d); if (t > sharpest) sharpest = t; } else { first[0] = d[0]; first[1] = d[1]; }
    d0[0] = d[0]; d0[1] = d[1]; have = 1;
  }
  if (smooth && prev_curve && have) {
    double j = turn(prev_dir, first), lim = (sharpest > prev_turn ? sharpest : prev_turn) + 1e-6;
    if (j > lim) fail("corner at the join %.3f deg > sharpest inside %.3f deg", j*180/M_PI, lim*180/M_PI);
  }
  prev_curve = have; prev_dir[0] = d0[0]; prev_dir[1] = d0[1]; prev_turn = sharpest;
  if (!quiet) printf("    %-44s segs %4d dev %.4f\n", test, nseg, dev);
}

static void normalize(const char *in, char *out)
{
  int paren = 0;
  for (; *in && *in != ';'; in++) {
    if (*in == '(') paren = 1; else if (*in == ')') paren = 0;
    else if (!paren && !isspace((unsigned char)*in)) *out++ = (char)toupper((unsigned char)*in);
  }
  *out = 0;
}

/* Run one G-code line; 'want' is ok, error, error:N or any. */
static void run_gcode(const char *src, const char *want)
{
  char line[256];
  normalize(src, line);
  float start[N_AXIS], wco[N_AXIS];
  memcpy(start, gc_state.position, sizeof start);
  for (int a = 0; a < N_AXIS; a++) wco[a] = gc_state.coord_system[a] + gc_state.coord_offset[a] + (a == Z_AXIS ? gc_state.tool_length_offset : 0);
  typeof(m) saved_model = m;
  static parser_state_t saved_state; saved_state = gc_state;
  curve_t c = model_line(line, start, wco);
  nseg = 0; line_time = 0; min_junction = 1e300;
  memset(travel, 0, sizeof travel); power_min = 1e30f; power_max = -1e30f;
  uint8_t st = gc_execute_line(line);
  tb_drain();
  char got[16]; if (st) snprintf(got, sizeof got, "error:%d", st); else strcpy(got, "ok");
  checks++;
  if (strcmp(want, "any") && strcmp(want, got) && !(!strcmp(want, "error") && st)) fail("'%s' -> %s, expected %s", line, got, want);
  if (st) {
    m = saved_model;
    if (nseg) fail("rejected line queued %d segments", nseg);
    if (memcmp(&saved_state, &gc_state, sizeof(gc_state))) fail("rejected line changed parser state");
    return;
  }
  if (sys.abort) {
    if (!quiet) printf("    %-44s abort after %d segments (soft limit hits %d)\n", test, nseg, tb_soft_limit_hits);
    sys.abort = 0; sys.soft_limit = 0; sys_rt_exec_alarm = 0;
    plan_reset(); plan_sync_position(); gc_sync_position();
    if (c.ok && nseg) fail("abort after %d segments were queued: the move was cut mid-curve", nseg);
    return;
  }
  if (c.ok && sys.state != STATE_CHECK_MODE) {
    check_curve(&c, start);
    int n = nseg < MAXSEG ? nseg : MAXSEG;
    memcpy(curve[1], curve[0], sizeof(pt_t) * ncurve[0]); ncurve[1] = ncurve[0];
    memcpy(curve[0], seg, sizeof(pt_t) * n); ncurve[0] = n;
  }
}

static void end_test(void)
{
  if (!*test) return;
  if (bug) { if (test_fails) n_xfail++; else { n_xpass++; printf("  XPASS %s (remove @bug)\n", test); } }
  else if (test_fails) n_fail++; else n_pass++;
}

static void run_file(const char *path)
{
  FILE *fp = fopen(path, "r");
  char raw[512];
  if (!fp) { perror(path); exit(2); }
  lineno = 0;
  while (fgets(raw, sizeof raw, fp)) {
    lineno++;
    char want[32] = "ok", *exp = strstr(raw, "->"), *hash = strchr(raw, '#');
    if (hash && (!exp || hash < exp)) *hash = 0;
    if (exp) { sscanf(exp + 2, "%31s", want); *exp = 0; }
    char *s = raw; while (isspace((unsigned char)*s)) s++;
    if (!*s) continue;
    line_fails = 0;
    if (*s == '=') {
      static char name[160];
      end_test();
      sscanf(s + 1, " %159[^\r\n]", name);
      char *b = strstr(name, "@bug"); bug = b != NULL; if (b) { *b = 0; }
      for (char *e = name + strlen(name); e > name && isspace((unsigned char)e[-1]); ) *--e = 0;
      test = name; test_fails = 0;
      machine_reset(); memset(&m, 0, sizeof m);
      continue;
    }
    double v[4] = {0};
    if (!strncmp(s, "set ", 4)) {
      char k[16]; sscanf(s + 4, "%15s %lf", k, &v[0]);
      if (!strcmp(k, "soft")) { if (v[0]) settings.flags |= BITFLAG_SOFT_LIMIT_ENABLE; else settings.flags &= ~BITFLAG_SOFT_LIMIT_ENABLE; }
      else if (!strcmp(k, "check")) sys.state = v[0] ? STATE_CHECK_MODE : STATE_IDLE;
      else if (!strcmp(k, "laser")) { if (v[0]) settings.flags |= BITFLAG_LASER_MODE; else settings.flags &= ~BITFLAG_LASER_MODE; }
      else if (!strcmp(k, "tol")) tol = v[0];
      else if (!strcmp(k, "maxseg")) maxseg = v[0];
      else if (!strcmp(k, "smooth")) smooth = (int)v[0];
      else if (!strcmp(k, "steps") || !strcmp(k, "rate") || !strcmp(k, "accel")) {
        for (int a = 0; a < N_AXIS; a++) {
          if (k[0] == 's') settings.steps_per_mm[a] = v[0];
          else if (k[0] == 'r') settings.max_rate[a] = v[0];
          else settings.acceleration[a] = v[0]*60*60;
        }
        for (int a = 0; a < N_AXIS; a++) steps[a] = (int32_t)lroundf(gc_state.position[a] * settings.steps_per_mm[a]);
        memcpy(sys_position, steps, sizeof(steps)); plan_sync_position();
      }
      else { fprintf(stderr, "%s:%d: unknown setting %s\n", path, lineno, k); exit(2); }
    } else if (!strncmp(s, "reset", 5)) {
      plan_reset(); plan_sync_position(); gc_init(); gc_sync_position(); memset(&m, 0, sizeof m); prev_curve = 0;
    } else if (!strncmp(s, "pos ", 4)) {
      sscanf(s + 4, "%lf %lf %lf", &v[0], &v[1], &v[2]); checks++;
      for (int a = 0; a < N_AXIS; a++) if (fabs(gc_state.position[a] - v[a]) > 1e-4) fail("position axis %d %g, expected %g", a, gc_state.position[a], v[a]);
    } else if (!strncmp(s, "same ", 5)) {
      sscanf(s + 5, "%lf %lf %lf", &v[0], &v[1], &v[2]); checks++;
      if (ncurve[0] != ncurve[1]) fail("same: %d segments vs %d", ncurve[0], ncurve[1]);
      else for (int k = 0; k < ncurve[0]; k++) for (int a = 0; a < N_AXIS; a++)
        if (fabs(curve[0][k][a] - (curve[1][k][a] + v[a])) > 1e-3) { fail("same: segment %d axis %d differs by %g", k, a, curve[0][k][a] - curve[1][k][a] - v[a]); k = ncurve[0]; break; }
    } else if (!strncmp(s, "circle ", 7)) {
      sscanf(s + 7, "%lf %lf %lf %lf", &v[0], &v[1], &v[2], &v[3]); checks++;
      for (int k = 0; k < nseg && k < MAXSEG; k++) {
        double e = fabs(hypot(seg[k][0] - v[0], seg[k][1] - v[1]) - v[2]);
        if (e > v[3]) { fail("circle: segment %d off by %g > %g", k, e, v[3]); break; }
      }
    } else if (!strncmp(s, "junction ", 9)) {
      sscanf(s + 9, "%lf", &v[0]); checks++;
      if (min_junction > v[0]) fail("junction: slowest %g mm/min > %g", min_junction, v[0]);
    } else if (!strncmp(s, "travel ", 7)) {
      char ax = 0; sscanf(s + 7, " %c %lf", &ax, &v[0]); checks++;
      int a = toupper((unsigned char)ax) - 'X';
      if (a < 0 || a >= N_AXIS) { fprintf(stderr, "%s:%d: bad axis %c\n", path, lineno, ax); exit(2); }
      double mm = travel[a] / settings.steps_per_mm[a];
      if (mm > v[0] + 1e-9) fail("travel: axis %c moved %g mm (%u steps) > %g", "XYZ"[a], mm, travel[a], v[0]);
    } else if (!strncmp(s, "power ", 6)) {
      sscanf(s + 6, "%lf", &v[0]); checks++;
      if (!nseg) fail("power: no segment queued");
      else if (power_min != v[0] || power_max != v[0]) fail("power: segments queued with %g..%g, expected %g", power_min, power_max, v[0]);
    } else {
      run_gcode(s, want);
    }
    test_fails += line_fails;
  }
  fclose(fp);
  end_test(); test = "";
}

/* ---- random curves ---- */

static uint64_t rng;
static double urand(void) { rng = rng * 6364136223846793005ULL + 1442695040888963407ULL; return (rng >> 11) * (1.0 / 9007199254740992.0); }

enum { RX, RY, RI, RJ, RP, RQ, RN };
typedef struct { double v[RN]; int quad; } rcase_t;

static void rcase_line(const rcase_t *r, char *out)
{
  if (r->quad) sprintf(out, "G5.1X%.4fY%.4fI%.4fJ%.4f", r->v[RX], r->v[RY], r->v[RI], r->v[RJ]);
  else sprintf(out, "G5X%.4fY%.4fI%.4fJ%.4fP%.4fQ%.4f", r->v[RX], r->v[RY], r->v[RI], r->v[RJ], r->v[RP], r->v[RQ]);
}

/* Returns the number of failed checks; known open defects are filtered out. */
static int rcase_run(const rcase_t *r)
{
  char line[160];
  rcase_line(r, line);
  if (!r->quad && r->v[RP] < 0) return 0;  /* #7: negative P rejected, open defect */
  if (r->quad && fabs(r->v[RI]) < 5e-5 && fabs(r->v[RJ]) < 5e-5) return 0;  /* G5.1 I=J=0 is an error by spec */
  quiet = 1; machine_reset(); memset(&m, 0, sizeof m);
  line_fails = 0;
  run_gcode("G10L20P1X0Y0Z0", "ok");
  run_gcode("F1000", "ok");
  run_gcode(line, "ok");
  quiet = 0;
  return line_fails;
}

static double rmag(double lo, double hi) { return pow(10, lo + (hi - lo) * urand()); }

static void run_random(long n, unsigned long seed)
{
  long failed = 0;
  rng = seed;
  test = "random";
  for (long i = 0; i < n; i++) {
    rcase_t r; memset(&r, 0, sizeof r);
    double scale = rmag(-2, 3);
    r.quad = urand() < 0.2;
    if (urand() > 0.1) { r.v[RX] = scale * (2*urand() - 1); r.v[RY] = scale * (2*urand() - 1); }
    for (int k = RI; k < RN; k++) if (urand() > 0.1) r.v[k] = (urand() < 0.5 ? -1 : 1) * scale * rmag(-1.5, 1);
    if (!rcase_run(&r)) continue;
    failed++;
    /* Shrink: zero, round, halve each value while the case keeps failing. */
    for (int changed = 1; changed; ) {
      changed = 0;
      for (int k = 0; k < RN; k++) {
        double was = r.v[k], cand[4] = {0, round(was), round(was * 10) / 10, was / 2};
        for (int j = 0; j < 4; j++) {
          if (cand[j] == r.v[k]) continue;
          r.v[k] = cand[j];
          if (rcase_run(&r)) { changed = 1; break; }
          r.v[k] = was;
        }
      }
    }
    char line[160]; rcase_line(&r, line);
    printf("  FAIL random case %ld, shrunk: %s\n", i, line);
    machine_reset(); memset(&m, 0, sizeof m);
    run_gcode("G10L20P1X0Y0Z0", "ok"); run_gcode("F1000", "ok"); run_gcode(line, "ok");
  }
  printf("random: %ld cases, %ld failed (seed %lu)\n", n, failed, seed);
  n_fail += failed > 0; n_pass += failed == 0;
}

/* Same lines and hash as tb/avr/bench.c, from machine zero: "line status seg hash". */
static void run_hash(const char *path)
{
  FILE *fp = fopen(path, "r");
  char raw[256];
  if (!fp) { perror(path); exit(2); }
  quiet = 1; machine_reset(); memset(&m, 0, sizeof m);
  memset(steps, 0, sizeof(steps)); memcpy(sys_position, steps, sizeof(steps));
  plan_sync_position(); gc_sync_position();
  while (fgets(raw, sizeof raw, fp)) {
    raw[strcspn(raw, "\r\n")] = 0;
    if (!*raw || *raw == '#') continue;
    int measure = *raw == '*';
    char *g = raw + measure;
    nseg = 0;
    uint8_t st = gc_execute_line(g);
    tb_drain();
    if (!measure) continue;
    uint32_t h = 2166136261u;
    for (int k = 0; k < nseg && k < MAXSEG; k++) {
      const uint8_t *b = (const uint8_t *)seg[k];
      for (size_t i = 0; i < sizeof(pt_t); i++) h = (h ^ b[i]) * 16777619u;
    }
    printf("%s %d %d %u\n", g, st, nseg, h);
  }
  fclose(fp);
  exit(0);
}

/* Segment targets printed by tb/avr dump.elf for the lines of LINES, checked
   against the model: "line host-seg host-dev avr-seg avr-dev". The host runs
   every line too, to follow the parser state the next model line starts from.
   Fails when an AVR curve misses its end or the tolerance; lines with a
   non-finite target are skipped. */
static pt_t avr[MAXSEG];

static void run_dump(const char *lines, const char *out)
{
  FILE *fl = fopen(lines, "r"), *fo = fopen(out, "rb");
  char raw[256], o[256];
  if (!fl) { perror(lines); exit(2); }
  if (!fo) { perror(out); exit(2); }
  quiet = 1; machine_reset(); memset(&m, 0, sizeof m);
  memset(steps, 0, sizeof(steps)); memcpy(sys_position, steps, sizeof(steps));
  plan_sync_position(); gc_sync_position();
  int bad = 0, curves = 0;
  while (fgets(raw, sizeof raw, fl)) {
    raw[strcspn(raw, "\r\n")] = 0;
    if (!*raw || *raw == '#') continue;
    int measure = *raw == '*';
    char *g = raw + measure;
    int found = 0, na = 0;          /* the AVR echoes the line, then its targets */
    while (!found && fgets(o, sizeof o, fo)) { o[strcspn(o, "\r\n")] = 0; found = !strcmp(o, g); }
    if (!found) { printf("%s: not in %s\n", g, out); exit(2); }
    long pos = ftell(fo);
    uint32_t b[N_AXIS];
    while (fgets(o, sizeof o, fo) && sscanf(o, "p %u %u %u", &b[0], &b[1], &b[2]) == N_AXIS) {
      if (na < MAXSEG) memcpy(avr[na], b, sizeof(pt_t));
      na++; pos = ftell(fo);
    }
    fseek(fo, pos, SEEK_SET);
    float start[N_AXIS], wco[N_AXIS];
    memcpy(start, gc_state.position, sizeof start);
    for (int a = 0; a < N_AXIS; a++) wco[a] = gc_state.coord_system[a] + gc_state.coord_offset[a] + (a == Z_AXIS ? gc_state.tool_length_offset : 0);
    curve_t c = model_line(g, start, wco);
    nseg = 0;
    uint8_t st = gc_execute_line(g);
    tb_drain();
    if (!measure || !c.ok || st) continue;
    int n = na < MAXSEG ? na : MAXSEG, fin = 1;
    for (int k = 0; k < n; k++) for (int a = 0; a < N_AXIS; a++) fin &= isfinite(avr[k][a]);
    if (!fin) { printf("%s: non-finite AVR target, skipped\n", g); continue; }
    curves++;
    double hd = curve_dev(&c, start, seg, nseg < MAXSEG ? nseg : MAXSEG);
    double ad = na ? curve_dev(&c, start, avr, n) : 1e300;
    int end = na && !memcmp(avr[n-1], gc_state.position, sizeof(pt_t));
    /* At the segment cap the tolerance is given up on purpose; the AVR must
       then still be as close as the host. */
    int cap = 0;
#ifdef BEZIER_MAX_SEGMENTS
    cap = na >= BEZIER_MAX_SEGMENTS;
#endif
    int ok = end && (ad <= tol || (cap && ad <= hd * 1.001 + 1e-4));
    printf("%s host %d %.4f avr %d %.4f%s%s\n", g, nseg, hd, na, ad, cap ? " (cap)" : "",
           ok ? "" : end ? "  FAIL tol" : "  FAIL end");
    bad += !ok;
  }
  fclose(fl); fclose(fo);
  printf("dump: %d curves, %d failed\n", curves, bad);
  exit(bad != 0 || curves == 0);
}

int main(int argc, char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  if (argc == 3 && !strcmp(argv[1], "--hash")) run_hash(argv[2]);
  if (argc == 4 && !strcmp(argv[1], "--dump")) run_dump(argv[2], argv[3]);
  if (argc == 4 && !strcmp(argv[1], "--random")) run_random(atol(argv[2]), strtoul(argv[3], NULL, 0));
  else for (int i = 1; i < argc; i++) run_file(argv[i]);
  printf("%d checks: %d pass, %d FAIL, %d xfail, %d XPASS\n", checks, n_pass, n_fail, n_xfail, n_xpass);
  return n_fail || n_xpass;
}
