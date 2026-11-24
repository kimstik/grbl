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
     tb --dump-strict LINES OUT  compare with the control net captured at the host
                               mc_cubic_b_spline call; no cap or float-grid waiver.
                               Budget: TB_XY_BUDGET, default BEZIER_SIGMA. This is a
                               sampled distance check, not a geometric proof.

   Vector file syntax, one statement per line, '#' starts a comment:
     = name [@bug] [@OPT]...   new test; machine at X-100 Y-100 Z-10 (mm), work
                               offsets zero, F unset.
                               @bug: known open defect, failures count as XFAIL
                               @OPT, @!OPT: only for a firmware built with, without
                               the option: tol (BEZIER_SIGMA is a variable, as with
                               settings.arc_tolerance), z (BEZIER_Z_LINEAR), zpar,
                               zlen, zaim (BEZIER_Z_LINEAR 1, 2, 3), loose
                               (BEZIER_Z_LOOSE), zsigma (BEZIER_Z_SIGMA is not
                               BEZIER_SIGMA), g93 (BEZIER_EXACT_INVERSE_TIME)
     set KEY VALUE             soft 0|1, check 0|1, laser 0|1, tol MM, maxseg N,
                               smooth 0|1, steps N (all axes), rate MM/MIN, accel MM/S^2,
                               arctol MM ($12)
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
     minutes LO HI             the blocks of the last line take LO to HI minutes at
                               their programmed rates
     zlen LO HI                Z of the last curve is off the line in the length
     zarc LO HI                travelled (zlen) or in the arc length of the model
                               (zarc) by LO to HI of the Z travel at its worst point
     zmm LO HI                 the same as zlen, in mm
     zaim N SUMS OPEN ENDS     BEZIER_Z_LINEAR 3 made N estimates of the length ahead
                               for the last curve, SUMS of them by summing the
                               segments; left OPEN of them too wide to vouch for
                               Z, and brought Z to its end early ENDS times

   Checked on every line:
     rejected line: no segment queued and parser state byte-identical
   Checked on every accepted G5/G5.1:
     finite targets; last target == parser position (bit-exact); parser end ==
     model end; planner steps == parser position; segment count <= maxseg;
     two-sided distance between polyline and the double model <= tol, by
     default BEZIER_SIGMA as the firmware has it, or what the segment cap
     leaves of it; Z never reverses, stays put without a Z word, and is linear
     in the length travelled (BEZIER_Z_LINEAR 2) or in the segment number (1),
     or off that line by no more than the brackets of the firmware allow, and
     than BEZIER_Z_SIGMA if it left no estimate open, which it may only with
     BEZIER_Z_LOOSE (3); G93 time == 1/F, with 3 within the bracket of the
     estimate; the line ends; G94 feed as programmed; smooth 1: no
     sharper corner at the join with the previous curve than inside either curve. */
#include "grbl.h"
#include <ctype.h>
#include <float.h>
#include <stdarg.h>
#include <stdio.h>

extern int tb_soft_limit_hits, tb_realtime_calls;
extern float tb_coord[N_COORDINATE_SYSTEM + 2][N_AXIS];
uint8_t __real_plan_buffer_line(float *target, plan_line_data_t *pl_data);

#define MAXSEG 20000
#define TB_STR(x) #x
#define TB_XSTR(x) TB_STR(x)                /* the text that a macro stands for */
typedef float pt_t[N_AXIS];
static pt_t seg[MAXSEG];                    /* targets queued by the current line */
static float seg_feed[MAXSEG];              /* and the feed and condition they were queued with */
static uint8_t seg_cond[MAXSEG];
static pt_t curve[2][MAXSEG];               /* last accepted curve and the one before */
static int nseg, ncurve[2];
static int32_t steps[N_AXIS];               /* executed (drained) step position */
static uint32_t travel[N_AXIS];             /* executed steps of the current line, unsigned */
static double line_time, min_junction;      /* minutes; mm/min */
static float power_min, power_max;          /* spindle speed of the segments of the current line */
static int checks, line_fails;
static double tol, maxseg;                  /* tol < 0: BEZIER_SIGMA */
static int smooth;
static double prev_dir[2], prev_turn;       /* last direction and sharpest turn of the previous curve */
static int prev_curve;

static const char *test = "";
static int lineno, bug, skip;
static int n_pass, n_fail, n_xfail, n_xpass, test_fails, quiet;

uint8_t __wrap_plan_buffer_line(float *target, plan_line_data_t *pl_data)
{
  if (nseg < MAXSEG) {
    memcpy(seg[nseg], target, sizeof(pt_t));
    seg_feed[nseg] = pl_data->feed_rate; seg_cond[nseg] = pl_data->condition;
  }
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
#ifdef TB_ARC_TOLERANCE
  settings.arc_tolerance = TB_ARC_TOLERANCE;
#endif
  memcpy(sys_position, steps, sizeof(steps));
  memset(tb_coord, 0, sizeof(tb_coord));      /* work offsets do not leak from the previous test */
  plan_reset(); plan_sync_position();
  gc_init(); gc_sync_position();
  tol = -1; maxseg = 2000; smooth = 0; prev_curve = 0; nseg = ncurve[0] = ncurve[1] = 0;
}

/* ---- independent model: LinuxCNC semantics of G5/G5.1 in the XY plane ---- */

static struct { int inch, incr, inv, motion; double pq[2], f; } m;  /* motion: 0, 50 (G5), 51 (G5.1) */
typedef struct { double p[4][N_AXIS]; int ok; } curve_t;

/* Capture the actual host float net, after read_float and parser arithmetic.
   This link-time probe does not alter the firmware or its AVR code generation. */
static curve_t parsed;
#ifdef ENABLE_CUBIC_SPLINES
void __real_mc_cubic_b_spline(float *target, plan_line_data_t *pl_data, float *position, float *first, float *second);
void __wrap_mc_cubic_b_spline(float *target, plan_line_data_t *pl_data, float *position, float *first, float *second)
{
  for (int a = 0; a < N_AXIS; a++) {
    parsed.p[0][a] = position[a]; parsed.p[3][a] = target[a];
    parsed.p[1][a] = a < 2 ? first[a] : position[a];
    parsed.p[2][a] = a < 2 ? second[a] : target[a];
  }
  parsed.ok = 1;
  __real_mc_cubic_b_spline(target, pl_data, position, first, second);
}
#endif

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

#ifndef TB_DENSE
  #define TB_DENSE 4000
#endif
#define DENSE TB_DENSE
static double dense[DENSE + 1][2], poly[MAXSEG + 1][2];

/* Dense curve to XY polyline, and emitted vertices to dense curve (not chord interiors). */
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

/* Largest second difference of the control polygon in XY: max|B''| / 6. */
static double bend(const curve_t *c)
{
  double b = 0;
  for (int k = 0; k < 2; k++) {
    double d = hypot(c->p[k][0] - 2*c->p[k+1][0] + c->p[k+2][0], c->p[k][1] - 2*c->p[k+1][1] + c->p[k+2][1]);
    if (d > b) b = d;
  }
  return b;
}

static double reach(const curve_t *c)  /* largest XY coordinate of the control points */
{
  double big = 0;
  for (int k = 0; k < 4; k++) for (int a = 0; a < 2; a++) if (fabs(c->p[k][a]) > big) big = fabs(c->p[k][a]);
  return big;
}

/* Deviation allowed for the curve: what the test set, else the tolerance in
   force or what the segment cap leaves of it, plus the float grid. maxseg
   equal steps of the parameter can promise no less than Wang's bound
   0.75*bend/maxseg^2, and float arithmetic no less than a few last bits. */
static double tol_for(const curve_t *c)
{
  double t = BEZIER_SIGMA, cap = 0.75*bend(c)/(maxseg*maxseg);
  return tol >= 0 ? tol : (cap > t ? cap : t) + 4*FLT_EPSILON*reach(c);
}

static double speed(const curve_t *c, double t)  /* |B'(t)| in XY */
{
  double u = 1 - t, d[2];
  for (int a = 0; a < 2; a++)
    d[a] = 3*(u*u*(c->p[1][a] - c->p[0][a]) + 2*u*t*(c->p[2][a] - c->p[1][a]) + t*t*(c->p[3][a] - c->p[2][a]));
  return hypot(d[0], d[1]);
}

/* Arc length of the model curve at its point nearest to q: the first close
   local minimum of the distance from piece *at of dense[] on, so that a loop
   or a cusp does not jump to another branch; the nearest piece if none is close. */
static double arc[DENSE + 1];

static double arc_at(const double *q, int *at, double close)
{
  int best = *at;
  double bd = 1e300, prev = 1e300;
  for (int i = *at; i < DENSE; i++) {
    double d = seg_dist(q, dense[i], dense[i+1]);
    if (d > prev && prev <= close) { best = i - 1; break; }
    if (d < bd) { bd = d; best = i; }
    prev = d;
  }
  const double *a = dense[best], *b = dense[best+1];
  double dx = b[0] - a[0], dy = b[1] - a[1], l2 = dx*dx + dy*dy;
  double u = l2 > 0 ? ((q[0]-a[0])*dx + (q[1]-a[1])*dy) / l2 : 0;
  if (u < 0) u = 0;
  if (u > 1) u = 1;
  *at = best;
  return arc[best] + u*(arc[best+1] - arc[best]);
}

/* Z of the polyline start, pts[0..n) as a fraction of the Z travel, worst point:
   len    off the line in the XY length travelled along the emitted polyline
   ref    off the line in the double model polyline at the same k/n (not emitted XY)
   arc    off the line in the arc length of the model curve
   par    off the line in the segment number
   shrt   what the polyline is shorter than the curve, as a fraction of the curve
   noise  what the float grid of Z, and of XY against the length, explains
   back   segments that move Z against the travel, or at all without any
   dz, xy the Z travel and the length of the polyline, mm.
   Uses poly[] and dense[] as curve_dev left them. */
typedef struct { double len, ref, arc, par, shrt, noise, dz, xy; int back, moves; } zerr_t;

/* What a firmware built with BEZIER_Z_TRACE tells of a curve under BEZIER_Z_LINEAR 3:
   estimates of the length ahead that it made; of them, sums of the segments, which
   are exact; those it left too wide to vouch for Z within BEZIER_Z_SIGMA; Z brought to
   its end before the last point; pieces gone through and segments summed for all the
   estimates; the bound of the Z error that follows from its brackets, mm; the half
   bracket of the estimate behind the G93 feed, as a share of the length; and that of
   the latest estimate. */
typedef struct { uint16_t estimates, sums, open, ends, pieces, summed; float bound, time, half; } ztrace_t;

/* What a piece of an estimate, a segment summed by mode 3 and a segment of the
   first pass of mode 2 take on the ATmega328P at 16 MHz, ms: measured with
   avr-gcc 16.2 under simavr on S-shaped curves, see README.md; soft float
   takes less with zeros and more with large numbers. --random turns the
   counts of the trace into the delay before the first point that they stand for. */
#ifndef TB_PIECE_MS
  #define TB_PIECE_MS 1.12
#endif
#ifndef TB_SUMMED_MS
  #define TB_SUMMED_MS 0.415
#endif
#ifndef TB_PASS_MS
  #define TB_PASS_MS 0.385
#endif
#if BEZIER_Z_LINEAR == 3
extern ztrace_t bezier_z_trace;
#else
static ztrace_t bezier_z_trace;
#endif

static zerr_t z_check(const curve_t *c, const float *start, pt_t *pts, int n, const ztrace_t *t)
{
  zerr_t r; memset(&r, 0, sizeof r);
  double z0 = start[Z_AXIS], dz = pts[n-1][Z_AXIS] - z0;
  double close = 1e-5 + 4e-6*reach(c) + 1.5*bend(c)/((double)DENSE*DENSE), h = 1.0/DENSE, len = 0, s = 0, zp = z0;
  static double ref[MAXSEG + 1];              /* double B(k/n), including the same start/end */
  ref[0] = 0;
  double prev[2] = { c->p[0][0], c->p[0][1] };
  for (int k = 1; k <= n; k++) {
    double q[2] = { bez(c, 0, (double)k/n), bez(c, 1, (double)k/n) };
    ref[k] = ref[k-1] + hypot(q[0] - prev[0], q[1] - prev[1]);
    memcpy(prev, q, sizeof prev);
  }
  arc[0] = 0;
  for (int k = 0; k < DENSE; k++) arc[k+1] = arc[k] + h/6*(speed(c, k*h) + 4*speed(c, (k + 0.5)*h) + speed(c, (k + 1)*h));
  for (int k = 1; k <= n; k++) len += hypot(poly[k][0] - poly[k-1][0], poly[k][1] - poly[k-1][1]);
  r.moves = dz != 0; r.dz = dz; r.xy = len;
  if (len < arc[DENSE]) r.shrt = 1 - len/arc[DENSE];
  if (r.moves) r.noise = 4*FLT_EPSILON*((fabs(z0) + fabs(dz))/fabs(dz) + (len > 0 ? reach(c)/len : 0));
#if BEZIER_Z_LINEAR == 2
  /* Mode 2 sums the chords between the very points that it then travels, the
     target included, twice by the same additions. What is left is rounding,
     taken all one way and at FLT_EPSILON an operation: half a term of the sum
     for what the sum at a point and the whole sum do not share; 8 for the
     chords, the division, the product and the last addition; and the hair of
     2.4e-7 that the whole length is stretched by. */
  if (r.moves) r.noise = FLT_EPSILON*(0.5*n + 8 + fmax(fabs(z0), fabs(z0 + dz))/fabs(dz)) + 2.4e-7;
#endif
#if BEZIER_Z_LINEAR == 3
  /* Mode 3 estimates the length between the very points that it then travels,
     the target included, so the float grid of XY is not in the error. What is
     left is the rounding of its running sums, taken all one way and at
     FLT_EPSILON an operation: two a point for the Z left, as its error grows by
     the rounding of the length left and of its own step, and shrinks with it
     (2n + 2); one a term for the sum behind the estimate, the chords of the
     segments or three legs a piece; 5.5 for the chords, the hair at the start
     and the last subtraction. Ending Z early gives up 1e-6 of what is left. */
  if (r.moves) r.noise = FLT_EPSILON*(2*n + 2 + (t->sums ? n - 1 : fmin(n - 1, 3*BEZIER_Z_PIECES_MAX)) + 5.5 + fmax(fabs(z0), fabs(z0 + dz))/fabs(dz)) + 1e-6;
#endif
  (void)t;
  int at = 0;
  for (int k = 1; k <= n; k++) {
    double z = pts[k-1][Z_AXIS], e;
    s += hypot(poly[k][0] - poly[k-1][0], poly[k][1] - poly[k-1][1]);
    if (r.moves ? (z - zp)*dz < 0 : z != z0) r.back++;
    zp = z;
    if (!r.moves) continue;
    if (len > 0 && (e = fabs(z - (z0 + dz*s/len))/fabs(dz)) > r.len) r.len = e;
    if (ref[n] > 0 && (e = fabs(z - (z0 + dz*ref[k]/ref[n]))/fabs(dz)) > r.ref) r.ref = e;
    if ((e = fabs(z - (z0 + dz*k/n))/fabs(dz)) > r.par) r.par = e;
    if (arc[DENSE] > 0 && (e = fabs(z - (z0 + dz*(k < n ? arc_at(poly[k], &at, close)/arc[DENSE] : 1)))/fabs(dz)) > r.arc) r.arc = e;
  }
  return r;
}

/* What z_check found wrong for the firmware as built, or NULL. */
static const char *z_fail(const zerr_t *z, const ztrace_t *t)
{
  if (z->back) return "Z reverses, or moves without a Z word";
#if BEZIER_Z_LINEAR == 2
  if (z->len > z->noise) return "Z not linear in the length travelled";
  if (z->arc > z->shrt + 2e-4 + z->noise) return "Z off the arc length by more than the polyline is short";
#elif BEZIER_Z_LINEAR == 1
  if (z->par > 1e-5 + z->noise) return "Z not linear in the segment number";
#elif BEZIER_Z_LINEAR == 3
  /* Z is between its ends, so it is never off by more than the travel. */
  double mm = z->len*fabs(z->dz), grid = z->noise*fabs(z->dz), bound = t->bound < fabs(z->dz) ? t->bound : fabs(z->dz);
  if (z->moves && mm > bound + grid) return "Z off the line in the length travelled by more than the brackets of the firmware allow";
  if (z->moves && !t->open && mm > BEZIER_Z_SIGMA + grid) return "Z off the line in the length travelled by more than BEZIER_Z_SIGMA, which the firmware vouched for";
  if (!t->open && t->bound > BEZIER_Z_SIGMA*1.0001) return "the firmware vouched for Z with brackets wider than BEZIER_Z_SIGMA";
#ifndef BEZIER_Z_LOOSE
  if (t->open) return "an estimate of the length was left open";
#endif
#endif
  (void)t;
  return NULL;
}

#ifdef BEZIER_EXACT_INVERSE_TIME
/* Minutes the segments were commanded to take; *one: all at one feed in mm/min. */
static double feed_time(const float *start, pt_t *pts, const float *feed, const uint8_t *cond, int n, int *one, double *len)
{
  double t = 0;
  *one = 1; *len = 0;
  for (int k = 0; k < n; k++) {
    const float *a = k ? pts[k-1] : start;
    double d = sqrt(pow(pts[k][0] - a[0], 2) + pow(pts[k][1] - a[1], 2) + pow(pts[k][2] - a[2], 2));
    if (cond[k] & PL_COND_FLAG_INVERSE_TIME) { t += 1.0/feed[k]; *one = 0; }
    else t += d/feed[k];
    if (feed[k] != feed[0]) *one = 0;
    *len += d;
  }
  return t;
}

/* What is wrong with the time of a G93 curve, or NULL. */
static double time_off;                     /* of the last G93 curve, as a share of 1/F */

static const char *g93_fail(const curve_t *c, const float *start, pt_t *pts, const float *feed, const uint8_t *cond, int n, const ztrace_t *tr)
{
  static char why[80];
  int one;
  double len, t = feed_time(start, pts, feed, cond, n, &one, &len), slack;
  if (len <= 0) return NULL;
#if BEZIER_Z_LINEAR == 3
  /* The length is an estimate within its bracket, between the points travelled;
     its sums take three legs a piece at most, at FLT_EPSILON a term. */
  slack = tr->time + (3*BEZIER_Z_PIECES_MAX + 8)*FLT_EPSILON;
  (void)c;
#else
  /* The length is the sum of the chords between the points travelled: half a
     term of it for the rounding, and 8 for the chords, the Z travel and the feed. */
  slack = (0.5*n + 8)*FLT_EPSILON;
  (void)c;
#endif
  (void)tr;
  time_off = fabs(t*m.f - 1);
  if (time_off > slack) { sprintf(why, "G93 commanded time %.6g min, expected %g", t, 1/m.f); return why; }
  return one || n == 1 ? NULL : "G93 feed differs between the segments of the curve";
}
#endif

enum { Z_LEN, Z_ARC, Z_PAR, Z_REF, Z_MM, Z_REF_MM, Z_LEAD, Z_OPEN, Z_SUMS, Z_EST, Z_ENDS, Z_MS, Z_PASS_MS, Z_STATS };
static double *z_stat[Z_STATS];             /* --random: z_check of every curve with a Z move */
static double *t_stat;                      /* and the time error of every G93 curve */
static long n_stat, n_time, max_stat;
static zerr_t last_z;
static ztrace_t last_t;

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
  if (dev > tol_for(c)) fail("deviation %.4f mm > tol %g (%d segments)", dev, tol_for(c), nseg);
  ztrace_t t = last_t = bezier_z_trace;
  zerr_t z = last_z = z_check(c, start, seg, n, &t);
  if (z_fail(&z, &t)) fail("%s: len %.2e arc %.2e par %.2e short %.2e, %.2e mm, bound %.2e mm, estimates %d sums %d open %d (%d segments)", z_fail(&z, &t), z.len, z.arc, z.par, z.shrt, z.len*fabs(z.dz), t.bound, t.estimates, t.sums, t.open, nseg);
  if (z.moves && n_stat < max_stat) {
    z_stat[Z_LEN][n_stat] = z.len; z_stat[Z_ARC][n_stat] = z.arc; z_stat[Z_PAR][n_stat] = z.par; z_stat[Z_REF][n_stat] = z.ref;
    z_stat[Z_MM][n_stat] = z.len*fabs(z.dz); z_stat[Z_REF_MM][n_stat] = z.ref*fabs(z.dz);
    z_stat[Z_LEAD][n_stat] = z.xy > 0 ? fabs(z.dz)/z.xy : 1e300;
    z_stat[Z_MS][n_stat] = TB_PIECE_MS*t.pieces + TB_SUMMED_MS*t.summed; z_stat[Z_PASS_MS][n_stat] = TB_PASS_MS*n;
    z_stat[Z_OPEN][n_stat] = t.open; z_stat[Z_SUMS][n_stat] = t.sums; z_stat[Z_EST][n_stat] = t.estimates; z_stat[Z_ENDS][n_stat++] = t.ends;
  }
  /* The planner times the step-rounded blocks: up to a step each way per segment. */
  double path = 0;
  for (int k = 0; k < n; k++) { const float *a = k ? seg[k-1] : start; path += sqrt(pow(seg[k][0] - a[0], 2) + pow(seg[k][1] - a[1], 2) + pow(seg[k][2] - a[2], 2)); }
  if (m.inv && m.f > 0 && line_time > 0 && fabs(line_time*m.f - 1) > 0.02 + 2*n/settings.steps_per_mm[0]/path) fail("G93 time %g min, expected %g", line_time, 1/m.f);
  if (!m.inv) for (int k = 0; k < n; k++) if (seg_feed[k] != gc_state.feed_rate || (seg_cond[k] & PL_COND_FLAG_INVERSE_TIME)) { fail("G94 feed %g at segment %d, expected %g", seg_feed[k], k, gc_state.feed_rate); break; }
#ifdef BEZIER_EXACT_INVERSE_TIME
  if (m.inv && m.f > 0) {
    const char *why = g93_fail(c, start, seg, seg_feed, seg_cond, n, &t);
    if (why) fail("%s (half bracket %.2e)", why, t.time);
    else if (path > 0 && n_time < max_stat) t_stat[n_time++] = time_off;
  }
#endif
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
  if (!quiet) {
    printf("    %-44s segs %4d dev %.4f", test, nseg, dev);
    if (z.moves) printf(" z len %.1e arc %.1e par %.1e", z.len, z.arc, z.par);
#if BEZIER_Z_LINEAR == 3
    if (t.estimates) printf(" aim %d %d %d %d bound %.1e work %d %d", t.estimates, t.sums, t.open, t.ends, t.bound, t.pieces, t.summed);
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
    if (m.inv && m.f > 0 && path > 0) printf(" time %.1e", time_off);
#endif
    printf("\n");
  }
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
  memset(&bezier_z_trace, 0, sizeof bezier_z_trace);
  tb_realtime_calls = 0;
  uint8_t st = gc_execute_line(line);
  tb_drain();
  if (tb_realtime_calls > 1000000) fail("'%s' does not end: a million rounds of realtime work, then aborted", line);
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
      const struct { const char *tag; int on; } opt[] = {
        { "tol", !__builtin_constant_p(BEZIER_SIGMA) },
#if BEZIER_Z_LINEAR == 3
        { "zsigma", strcmp(TB_XSTR(BEZIER_Z_SIGMA), TB_XSTR(BEZIER_SIGMA)) != 0 },
#else
        { "zsigma", 0 },
#endif
#ifdef BEZIER_Z_LINEAR
        { "z", 1 }, { "zpar", BEZIER_Z_LINEAR == 1 }, { "zlen", BEZIER_Z_LINEAR == 2 }, { "zaim", BEZIER_Z_LINEAR == 3 },
#else
        { "z", 0 }, { "zpar", 0 }, { "zlen", 0 }, { "zaim", 0 },
#endif
#ifdef BEZIER_Z_LOOSE
        { "loose", 1 },
#else
        { "loose", 0 },
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
        { "g93", 1 },
#else
        { "g93", 0 },
#endif
      };
      bug = skip = 0;
      for (char *t = strchr(name, '@'); t; t = strchr(t + 1, '@')) {
        char tag[16] = ""; sscanf(t + 1, "%15s", tag);
        int not = tag[0] == '!', k = 0, nopt = sizeof opt / sizeof *opt;
        if (!strcmp(tag, "bug")) { bug = 1; continue; }
        while (k < nopt && strcmp(tag + not, opt[k].tag)) k++;
        if (k == nopt) { fprintf(stderr, "%s:%d: unknown tag @%s\n", path, lineno, tag); exit(2); }
        if (opt[k].on == not) skip = 1;
      }
      if (strchr(name, '@')) *strchr(name, '@') = 0;
      for (char *e = name + strlen(name); e > name && isspace((unsigned char)e[-1]); ) *--e = 0;
      test = skip ? "" : name; test_fails = 0;
      machine_reset(); memset(&m, 0, sizeof m); memset(&last_z, 0, sizeof last_z); memset(&last_t, 0, sizeof last_t);
      continue;
    }
    if (skip) continue;
    double v[4] = {0};
    if (!strncmp(s, "set ", 4)) {
      char k[16]; sscanf(s + 4, "%15s %lf", k, &v[0]);
      if (!strcmp(k, "soft")) { if (v[0]) settings.flags |= BITFLAG_SOFT_LIMIT_ENABLE; else settings.flags &= ~BITFLAG_SOFT_LIMIT_ENABLE; }
      else if (!strcmp(k, "check")) sys.state = v[0] ? STATE_CHECK_MODE : STATE_IDLE;
      else if (!strcmp(k, "laser")) { if (v[0]) settings.flags |= BITFLAG_LASER_MODE; else settings.flags &= ~BITFLAG_LASER_MODE; }
      else if (!strcmp(k, "tol")) tol = v[0];
      else if (!strcmp(k, "arctol")) settings.arc_tolerance = v[0];
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
    } else if (!strncmp(s, "minutes ", 8)) {
      sscanf(s + 8, "%lf %lf", &v[0], &v[1]); checks++;
      if (line_time < v[0] || line_time > v[1]) fail("minutes: %g, expected %g to %g", line_time, v[0], v[1]);
    } else if (!strncmp(s, "zlen ", 5) || !strncmp(s, "zarc ", 5)) {
      double e = s[1] == 'l' ? last_z.len : last_z.arc;
      sscanf(s + 5, "%lf %lf", &v[0], &v[1]); checks++;
      if (!last_z.moves) fail("%.4s: no Z travel", s);
      else if (e < v[0] || e > v[1]) fail("%.4s: %.2e of the Z travel, expected %g to %g", s, e, v[0], v[1]);
    } else if (!strncmp(s, "zmm ", 4)) {
      double e = last_z.len*fabs(last_z.dz);
      sscanf(s + 4, "%lf %lf", &v[0], &v[1]); checks++;
      if (!last_z.moves) fail("zmm: no Z travel");
      else if (e < v[0] || e > v[1]) fail("zmm: %.2e mm, expected %g to %g", e, v[0], v[1]);
    } else if (!strncmp(s, "zaim ", 5)) {
      double w = -1;
      sscanf(s + 5, "%lf %lf %lf %lf", &v[0], &v[1], &v[2], &w); checks++;
      if (last_t.estimates != v[0] || last_t.sums != v[1] || last_t.open != v[2] || last_t.ends != w)
        fail("zaim: %d estimates, %d of them sums, %d left open, %d early ends, expected %g %g %g %g", last_t.estimates, last_t.sums, last_t.open, last_t.ends, v[0], v[1], v[2], w);
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

enum { RX, RY, RI, RJ, RP, RQ, RZ, RN };
typedef struct { double v[RN]; int quad, z, inv; } rcase_t;

static void rcase_line(const rcase_t *r, char *out)
{
  if (r->quad) out += sprintf(out, "G5.1X%.4fY%.4fI%.4fJ%.4f", r->v[RX], r->v[RY], r->v[RI], r->v[RJ]);
  else out += sprintf(out, "G5X%.4fY%.4fI%.4fJ%.4fP%.4fQ%.4f", r->v[RX], r->v[RY], r->v[RI], r->v[RJ], r->v[RP], r->v[RQ]);
  if (r->z) out += sprintf(out, "Z%.4f", r->v[RZ]);
  if (r->inv) sprintf(out, "F2");
}

static void rcase_gcode(const rcase_t *r, const char *line)
{
  machine_reset(); memset(&m, 0, sizeof m);
  run_gcode("G10L20P1X0Y0Z0", "ok");
  run_gcode("F1000", "ok");
  if (r->inv) run_gcode("G93", "ok");
  run_gcode(line, "ok");
}

/* Returns the number of failed checks; known open defects are filtered out. */
static int rcase_run(const rcase_t *r)
{
  char line[160];
  rcase_line(r, line);
  if (!r->quad && r->v[RP] < 0) return 0;  /* #7: negative P rejected, open defect */
  if (r->quad && fabs(r->v[RI]) < 5e-5 && fabs(r->v[RJ]) < 5e-5) return 0;  /* G5.1 I=J=0 is an error by spec */
  long stats = n_stat, times = n_time;
  quiet = 1; line_fails = 0;
  rcase_gcode(r, line);
  quiet = 0;
  if (line_fails) { n_stat = stats; n_time = times; }
  return line_fails;
}

static int cmp_double(const void *a, const void *b) { return (*(double *)a > *(double *)b) - (*(double *)a < *(double *)b); }

static double rmag(double lo, double hi) { return pow(10, lo + (hi - lo) * urand()); }

static void run_random(long n, unsigned long seed)
{
  long failed = 0;
  rng = seed;
  test = "random";
  for (int k = 0; k < Z_STATS; k++) if (!(z_stat[k] = malloc(n * sizeof(double)))) exit(2);
  if (!(t_stat = malloc(n * sizeof(double)))) exit(2);
  max_stat = n;
  for (long i = 0; i < n; i++) {
    rcase_t r; memset(&r, 0, sizeof r);
    double scale = rmag(-2, 3);
    r.quad = urand() < 0.2;
    if (urand() > 0.1) { r.v[RX] = scale * (2*urand() - 1); r.v[RY] = scale * (2*urand() - 1); }
    for (int k = RI; k < RZ; k++) if (urand() > 0.1) r.v[k] = (urand() < 0.5 ? -1 : 1) * scale * rmag(-1.5, 1);
#ifdef BEZIER_Z_LINEAR
    if ((r.z = urand() < 0.8)) r.v[RZ] = (urand() < 0.5 ? -1 : 1) * rmag(-1, 2);
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
    r.inv = urand() < 0.3;
#endif
    if (!rcase_run(&r)) continue;
    failed++;
    /* Shrink: zero, round, halve each value while the case keeps failing. Only toward
       zero: rounding 0.05 up to 0.1 would undo a halving, and the two would alternate forever. */
    for (int changed = 1; changed; ) {
      changed = 0;
      for (int k = 0; k < RN; k++) {
        double was = r.v[k], cand[4] = {0, round(was), round(was * 10) / 10, was / 2};
        for (int j = 0; j < 4; j++) {
          if (fabs(cand[j]) >= fabs(was)) continue;
          r.v[k] = cand[j];
          if (rcase_run(&r)) { changed = 1; break; }
          r.v[k] = was;
        }
      }
    }
    char line[160]; rcase_line(&r, line);
    printf("  FAIL random case %ld, shrunk: %s%s\n", i, r.inv ? "G93 " : "", line);
    rcase_gcode(&r, line);
    n_stat = n_time = max_stat;             /* the statistics cover only what passed */
  }
  printf("random: %ld cases, %ld failed (seed %lu)\n", n, failed, seed);
#ifdef BEZIER_Z_LINEAR
  /* Errors from emitted XY, and separately from double B(k/n), with NO grid
     allowance deducted. A curve is open if an estimate of it was left open,
     else summed if its length is a sum of the segments, else its bracket was
     accepted, which is not float-certified. All curves are counted against
     BEZIER_SIGMA, the three kinds against what mode 3 goes by, BEZIER_Z_SIGMA. */
  double beta = BEZIER_SIGMA;
#if BEZIER_Z_LINEAR == 3
  beta = BEZIER_Z_SIGMA;
#endif
  static const double lead[] = { 0, 0.1, 1, 1e301 };
  for (int k = -1; k < 3 && n_stat && !failed; k++) {
    long in = 0, sure = 0, over = 0, zover = 0, accepted_over = 0, ref_over = 0, est = 0, most = 0, ends = 0, summed = 0, summed_over = 0;
    double mm = 0, part = 0, ref_mm = 0, ref_part = 0, accepted_max = 0, summed_max = 0;
    for (long i = 0; i < n_stat; i++) {
      double l = z_stat[Z_LEAD][i];
      if (k >= 0 && !(l > lead[k] && l <= lead[k+1])) continue;
      int off = z_stat[Z_MM][i] > beta, open = z_stat[Z_OPEN][i] > 0, sum = !open && z_stat[Z_SUMS][i] > 0;
      in++; over += z_stat[Z_MM][i] > BEZIER_SIGMA; zover += off;
      sure += !open && !sum; accepted_over += off && !open && !sum; summed += sum; summed_over += off && sum;
      ref_over += z_stat[Z_REF_MM][i] > BEZIER_SIGMA;
      if (!open && !sum && z_stat[Z_MM][i] > accepted_max) accepted_max = z_stat[Z_MM][i];
      if (sum && z_stat[Z_MM][i] > summed_max) summed_max = z_stat[Z_MM][i];
      if (z_stat[Z_REF_MM][i] > ref_mm) ref_mm = z_stat[Z_REF_MM][i];
      if (z_stat[Z_REF][i] > ref_part) ref_part = z_stat[Z_REF][i];
      est += (long)z_stat[Z_EST][i]; ends += (long)z_stat[Z_ENDS][i];
      if (z_stat[Z_EST][i] > most) most = (long)z_stat[Z_EST][i];
      if (z_stat[Z_MM][i] > mm) mm = z_stat[Z_MM][i];
      if (z_stat[Z_LEN][i] > part) part = z_stat[Z_LEN][i];
    }
    if (!in) continue;
    if (k < 0) printf("  Z off the line in the length, BEZIER_SIGMA %g: %ld curves, by more %.1f%%, most %.1e mm, %.1e of the Z travel\n",
                      (double)BEZIER_SIGMA, in, 100.0*over/in, mm, part);
    else printf("    lead %g to %g: %ld curves, by more %.1f%%, most %.1e mm, %.1e of the Z travel\n",
                lead[k], lead[k+1] > 1e300 ? INFINITY : lead[k+1], in, 100.0*over/in, mm, part);
    printf("      double XY reference: over %.1f%%, most %.1e mm, %.1e of Z travel\n", 100.0*ref_over/in, ref_mm, ref_part);
#if BEZIER_Z_LINEAR == 3
    long open = in - sure - summed;
    printf("      bracket-accepted %.1f%%, summed %.1f%%, open %.1f%%, open over %.1f%%; estimates mean %.2f most %ld, early ends %ld\n",
           100.0*sure/in, 100.0*summed/in, 100.0*open/in,
           open ? 100.0*(zover - accepted_over - summed_over)/open : 0, (double)est/in, most, ends);
    if (beta != BEZIER_SIGMA) printf("      BEZIER_Z_SIGMA %g: by more %.1f%%\n", beta, 100.0*zover/in);
    printf("      accepted AND emitted error > beta: %ld/%ld, accepted max %.6g mm (no allowance)\n", accepted_over, sure, accepted_max);
    printf("      summed AND emitted error > beta: %ld/%ld, summed max %.6g mm (no allowance)\n", summed_over, summed, summed_max);
#endif
#if BEZIER_Z_LINEAR >= 2
    /* The delay that finding the length stands for: from the counts of the
       trace for mode 3, and from the segments for the first pass of mode 2,
       which the same curves would take there. */
    double *ms = malloc(sizeof(double)*(n_stat + 1));
    for (int s = BEZIER_Z_LINEAR == 2 ? Z_PASS_MS : Z_MS; ms && s <= Z_PASS_MS; s++) {
      long nm = 0;
      double sum = 0;
      for (long i = 0; i < n_stat; i++) {
        double l = z_stat[Z_LEAD][i];
        if (k >= 0 && !(l > lead[k] && l <= lead[k+1])) continue;
        sum += ms[nm++] = z_stat[s][i];
      }
      qsort(ms, nm, sizeof(double), cmp_double);
      if (s == Z_MS) printf("      finding the length, %g ms a piece and %g a segment summed", (double)TB_PIECE_MS, (double)TB_SUMMED_MS);
      else printf("      a first pass over all segments, %g ms each", (double)TB_PASS_MS);
      printf(": mean %.1f ms, half under %.1f, 99%% under %.0f, most %.0f\n", sum/nm, ms[nm/2], ms[nm - 1 - nm/100], ms[nm-1]);
    }
    free(ms);
#endif
  }
#endif
  if (n_time && !failed) {
    qsort(t_stat, n_time, sizeof(double), cmp_double);
    printf("  G93 time off by median %.1e  max %.1e of 1/F (%ld curves)\n", t_stat[n_time/2], t_stat[n_time-1], n_time);
  }
  static const char *const name[] = { "polyline length", "arc length", "segment number", "double XY reference" };
  for (int k = 0; k <= Z_REF && n_stat && !failed; k++) {
    qsort(z_stat[k], n_stat, sizeof(double), cmp_double);
    printf("  Z off the line in the %-15s median %.1e  max %.1e of the Z travel (%ld curves)\n",
           name[k], z_stat[k][n_stat/2], z_stat[k][n_stat-1], n_stat);
  }
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
    memset(&bezier_z_trace, 0, sizeof bezier_z_trace);
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
   Fails when an AVR curve misses its end, the tolerance, the Z line or the
   G93 time; lines with a non-finite target are skipped. */
static pt_t avr[MAXSEG];
static float avr_feed[MAXSEG];
static uint8_t avr_cond[MAXSEG];

#ifndef TB_XY_BUDGET
  #define TB_XY_BUDGET BEZIER_SIGMA
#endif

static void run_dump(const char *lines, const char *out, int strict)
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
    uint32_t b[N_AXIS], f;
    unsigned cond;
    while (fgets(o, sizeof o, fo) && sscanf(o, "p %u %u %u %u %u", &b[0], &b[1], &b[2], &f, &cond) == N_AXIS + 2) {
      if (na < MAXSEG) { memcpy(avr[na], b, sizeof(pt_t)); memcpy(&avr_feed[na], &f, sizeof(float)); avr_cond[na] = cond; }
      na++; pos = ftell(fo);
    }
    unsigned avr_status = 0, at[6] = {0, 0, 0, 0, 0, 0};
    uint32_t ab[2] = {0, 0};                /* the trace follows the ten columns of bench.c, if built in */
    int got = sscanf(o, " %u %*u %*u %*u %*u %*u %*u %*u %*u %*u %u %u %u %u %u %u %u %u", &avr_status, &at[0], &at[1], &at[2], &at[3], &at[4], &at[5], &ab[0], &ab[1]);
    int summary = got >= 1;
    ztrace_t t = { at[0], at[1], at[2], at[3], at[4], at[5], 0, 0, 0 };
    memcpy(&t.bound, &ab[0], sizeof(float)); memcpy(&t.time, &ab[1], sizeof(float));
    fseek(fo, pos, SEEK_SET);
    float start[N_AXIS], wco[N_AXIS];
    memcpy(start, gc_state.position, sizeof start);
    for (int a = 0; a < N_AXIS; a++) wco[a] = gc_state.coord_system[a] + gc_state.coord_offset[a] + (a == Z_AXIS ? gc_state.tool_length_offset : 0);
    curve_t c = model_line(g, start, wco);
    nseg = 0; parsed.ok = 0;
    memset(&bezier_z_trace, 0, sizeof bezier_z_trace);
    uint8_t st = gc_execute_line(g);
    tb_drain();
    if (!measure) continue;
    if (strict && (st || !summary || avr_status || !c.ok || !parsed.ok || !na || na > MAXSEG)) {
      printf("%s: FAIL status host %u avr %u (summary %d), model %d, parsed %d, targets %d\n", g, st, avr_status, summary, c.ok, parsed.ok, na);
      curves++; bad++; continue;
    }
    if (!c.ok || st) continue;
    if (strict) {
      c = parsed;
      printf("net");
      for (int k = 0; k < 4; k++) printf(" (%.9g,%.9g)", c.p[k][0], c.p[k][1]);
      printf(" budget %.9g dense %d\n", (double)TB_XY_BUDGET, DENSE);
    }
    int n = na < MAXSEG ? na : MAXSEG, fin = 1;
    for (int k = 0; k < n; k++) for (int a = 0; a < N_AXIS; a++) fin &= isfinite(avr[k][a]);
    if (!fin) {
      printf("%s: non-finite AVR target, %s\n", g, strict ? "FAIL" : "skipped");
      if (strict) { curves++; bad++; }
      continue;
    }
    curves++;
    double hd = curve_dev(&c, start, seg, nseg < MAXSEG ? nseg : MAXSEG);
    double ad = na ? curve_dev(&c, start, avr, n) : 1e300;
    int end = na && na <= MAXSEG && !memcmp(avr[n-1], gc_state.position, sizeof(pt_t));
    /* At the segment cap the tolerance is given up on purpose; the AVR must
       then still be as close as the host. */
    int cap = 0;
#ifdef BEZIER_MAX_SEGMENTS
    cap = na >= BEZIER_MAX_SEGMENTS;
#endif
    const char *why = !end ? "end" : strict ? (ad <= TB_XY_BUDGET ? NULL : "tol") :
      ad <= tol_for(&c) || (cap && ad <= hd * 1.001 + 1e-4) ? NULL : "tol";
    zerr_t z; memset(&z, 0, sizeof z);
    if (na) {                               /* poly[] is the AVR polyline now */
      z = z_check(&c, start, avr, n, &t);
#if BEZIER_Z_LINEAR == 3
      if (!why && got < 9) why = "no trace of Z in the dump";
#endif
      if (!why) why = z_fail(&z, &t);
#ifdef BEZIER_EXACT_INVERSE_TIME
      time_off = -1;
      if (!why && m.inv && m.f > 0) why = g93_fail(&c, start, avr, avr_feed, avr_cond, n, &t);
#endif
    }
    if (strict) printf("%s host %d %.9g avr %d %.9g%s", g, nseg, hd, na, ad, cap ? " (cap)" : "");
    else printf("%s host %d %.4f avr %d %.4f%s", g, nseg, hd, na, ad, cap ? " (cap)" : "");
    if (z.moves) printf(" z len %.1e arc %.1e par %.1e", z.len, z.arc, z.par);
#if BEZIER_Z_LINEAR == 3
    if (z.moves) printf(" mm %.1e bound %.1e", z.len*fabs(z.dz), t.bound);
    printf(" estimates %d sums %d open %d ends %d work %d %d", t.estimates, t.sums, t.open, t.ends, t.pieces, t.summed);
    if (t.estimates != bezier_z_trace.estimates || t.sums != bezier_z_trace.sums || t.open != bezier_z_trace.open || t.ends != bezier_z_trace.ends
        || t.pieces != bezier_z_trace.pieces || t.summed != bezier_z_trace.summed)
      printf(" (host %d %d %d %d work %d %d)", bezier_z_trace.estimates, bezier_z_trace.sums, bezier_z_trace.open, bezier_z_trace.ends, bezier_z_trace.pieces, bezier_z_trace.summed);
#endif
#ifdef BEZIER_EXACT_INVERSE_TIME
    if (time_off >= 0) printf(" time %.1e", time_off);
#endif
    if (why) printf("  FAIL %s", why);
    printf("\n");
    bad += why != NULL;
  }
  fclose(fl); fclose(fo);
  printf("dump: %d curves, %d failed\n", curves, bad);
  exit(bad != 0 || curves == 0);
}

int main(int argc, char **argv)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  if (argc == 3 && !strcmp(argv[1], "--hash")) run_hash(argv[2]);
  if (argc == 4 && !strcmp(argv[1], "--dump")) run_dump(argv[2], argv[3], 0);
  if (argc == 4 && !strcmp(argv[1], "--dump-strict")) run_dump(argv[2], argv[3], 1);
  if (argc == 4 && !strcmp(argv[1], "--random")) run_random(atol(argv[2]), strtoul(argv[3], NULL, 0));
  else for (int i = 1; i < argc; i++) run_file(argv[i]);
  printf("%d checks: %d pass, %d FAIL, %d xfail, %d XPASS\n", checks, n_pass, n_fail, n_xfail, n_xpass);
  return n_fail || n_xpass;
}
