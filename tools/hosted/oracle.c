/*
  oracle.c - replay a captured segment stream through the FROZEN stepper ISR.

  Part of Grbl / Intelligence assisted / License: MIT

  The frozen core is the specification. This program does not reimplement the
  Bresenham/AMASS/pulse semantics anywhere - it links grbl/stepper.c straight
  out of the tree, injects canonical SEGX/1 frames into the real rings through
  the seam's TU exports, and calls the real ISR_STEP()/ISR_STEP_RESET() in
  virtual time (hosted_rt.h). Whatever comes out IS the golden trace, by
  definition. A candidate executor is conformant iff it reproduces this byte for
  byte (ci/seg_conformance.py).

  usage: seg_oracle <vector.gvec>          -> trace on stdout
*/

#include "prelude.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_SEGS 4096
#define MAX_BLKS 256

typedef struct {
  char     name[64];
  uint64_t f_tick;
  uint32_t pulse_ticks;
  uint8_t  step_invert, dir_invert, idle_lock, pulse_us;
  uint8_t  invert_st_enable;
  uint8_t  homing, homing_lock;
  uint32_t probe_from_tick;      /* 0 = probe never armed */
  int32_t  pos0[3];
  uint32_t max_ticks;
  grbl_blk_frame_t blk[MAX_BLKS];
  int nblk;
  grbl_seg_frame_t seg[MAX_SEGS];
  int nseg;
} vec_t;

uint32_t hosted_tick_no;
extern uint8_t hosted_probe_pin_triggered;
extern uint32_t hosted_probe_tick;

static void die(const char *msg, const char *det)
{
  fprintf(stderr, "seg_oracle: %s%s%s\n", msg, det ? ": " : "", det ? det : "");
  exit(2);
}

/* ---- vector parsing ---------------------------------------------------- */

static int blk_seen[256];

static void parse(const char *path, vec_t *v)
{
  FILE *f = fopen(path, "r");
  char line[512];
  int magic = 0, lineno = 0;
  if (!f) { die("cannot open vector", path); }
  memset(v, 0, sizeof(*v));
  memset(blk_seen, 0, sizeof(blk_seen));
  v->f_tick = 16000000ull;
  v->pulse_ticks = 160;
  v->pulse_us = 10;
  v->idle_lock = 25;
  v->max_ticks = 2000000u;
  while (fgets(line, sizeof(line), f)) {
    char kw[32];
    char *p = line;
    lineno++;
    while (*p == ' ' || *p == '\t') { p++; }
    if (*p == '#' || *p == '\n' || *p == '\0') { continue; }
    if (sscanf(p, "%31s", kw) != 1) { continue; }
    p += strlen(kw);
    if (!strcmp(kw, "gvec")) {
      int ver = 0;
      if (sscanf(p, "%d", &ver) != 1 || ver != SEGX_VERSION) { die("bad gvec version", path); }
      magic = 1;
    } else if (!strcmp(kw, "name")) {
      sscanf(p, " %63[^\n]", v->name);
    } else if (!strcmp(kw, "f_tick")) {
      sscanf(p, "%llu", (unsigned long long *)&v->f_tick);
    } else if (!strcmp(kw, "pulse_ticks")) {
      sscanf(p, "%u", &v->pulse_ticks);
    } else if (!strcmp(kw, "pulse_us")) {
      unsigned u; sscanf(p, "%u", &u); v->pulse_us = (uint8_t)u;
    } else if (!strcmp(kw, "step_invert")) {
      unsigned u; sscanf(p, "%i", (int *)&u); v->step_invert = (uint8_t)u;
    } else if (!strcmp(kw, "dir_invert")) {
      unsigned u; sscanf(p, "%i", (int *)&u); v->dir_invert = (uint8_t)u;
    } else if (!strcmp(kw, "invert_st_enable")) {
      unsigned u; sscanf(p, "%u", &u); v->invert_st_enable = (uint8_t)u;
    } else if (!strcmp(kw, "idle_lock")) {
      unsigned u; sscanf(p, "%u", &u); v->idle_lock = (uint8_t)u;
    } else if (!strcmp(kw, "homing")) {
      unsigned u; sscanf(p, "%u", &u); v->homing = (uint8_t)u;
    } else if (!strcmp(kw, "homing_lock")) {
      unsigned u; sscanf(p, "%i", (int *)&u); v->homing_lock = (uint8_t)u;
    } else if (!strcmp(kw, "probe_from_tick")) {
      sscanf(p, "%u", &v->probe_from_tick);
    } else if (!strcmp(kw, "max_ticks")) {
      sscanf(p, "%u", &v->max_ticks);
    } else if (!strcmp(kw, "pos")) {
      long a, b, c;
      if (sscanf(p, "%ld %ld %ld", &a, &b, &c) != 3) { die("bad pos line", path); }
      v->pos0[0] = (int32_t)a; v->pos0[1] = (int32_t)b; v->pos0[2] = (int32_t)c;
    } else if (!strcmp(kw, "blk")) {
      unsigned gen, dir, flags; unsigned long s0, s1, s2, sec;
      grbl_blk_frame_t *b;
      if (sscanf(p, "%u %lu %lu %lu %lu %i %i", &gen, &s0, &s1, &s2, &sec,
                 (int *)&dir, (int *)&flags) != 7) { die("bad blk line", path); }
      if (v->nblk >= MAX_BLKS) { die("too many blk lines", path); }
      if (gen == 0 || gen > 255) { die("blk_gen must be 1..255", path); }
      b = &v->blk[v->nblk++];
      b->blk_gen = (uint8_t)gen;
      b->steps[0] = (uint32_t)s0; b->steps[1] = (uint32_t)s1; b->steps[2] = (uint32_t)s2;
      b->step_event_count = (uint32_t)sec;
      b->direction_bits = (uint8_t)dir; b->flags = (uint8_t)flags;
      blk_seen[gen] = 1;
    } else if (!strcmp(kw, "seg")) {
      unsigned n, cpt, gen, amass, pwm;
      grbl_seg_frame_t *s;
      if (sscanf(p, "%u %u %u %u %u", &n, &cpt, &gen, &amass, &pwm) != 5) {
        die("bad seg line", path);
      }
      if (v->nseg >= MAX_SEGS) { die("too many seg lines", path); }
      if (!blk_seen[gen & 0xff]) { die("SEG references a blk_gen not yet declared (SEGX/1 F1)", path); }
      s = &v->seg[v->nseg];
      s->n_step = (uint16_t)n; s->cycles_per_tick = (uint16_t)cpt;
      s->blk_gen = (uint8_t)gen; s->amass_level = (uint8_t)amass;
      s->spindle_pwm = (uint8_t)pwm; s->seq = (uint8_t)(v->nseg & 0xff);
      v->nseg++;
    } else {
      die("unknown keyword in vector", kw);
    }
  }
  fclose(f);
  if (!magic) { die("missing 'gvec 1' header", path); }
  if (v->nseg == 0) { die("vector has no seg lines", path); }
}

/* ---- wire round-trip --------------------------------------------------- */

/* Every frame goes out through the canonical little-endian encoder and back in
   through the decoder before it reaches a ring. The oracle therefore proves the
   codec on every vector it replays: a codec bug cannot hide behind the fact
   that both sides are the same struct. */
static void wire_roundtrip_seg(grbl_seg_frame_t *s)
{
  uint8_t w[SEGX_SEG_WIRE_LEN];
  segx_seg_encode(s, w);
  memset(s, 0, sizeof(*s));
  segx_seg_decode(w, s);
}

static void wire_roundtrip_blk(grbl_blk_frame_t *b)
{
  uint8_t w[SEGX_BLK_WIRE_LEN];
  segx_blk_encode(b, w);
  memset(b, 0, sizeof(*b));
  segx_blk_decode(w, b);
}

/* ---- replay ------------------------------------------------------------ */

static const grbl_blk_frame_t *find_blk(const vec_t *v, uint8_t gen)
{
  int i;
  for (i = v->nblk - 1; i >= 0; i--) {
    if (v->blk[i].blk_gen == gen) { return &v->blk[i]; }
  }
  return NULL;
}

int main(int argc, char **argv)
{
  vec_t v;
  uint8_t next_head, fill_slot, loaded_gen[256];
  int pending = 0;
  uint64_t clk = 0;
  uint32_t tick = 0;
  uint8_t rest_step, rest_dir;

  if (argc != 2) { fprintf(stderr, "usage: seg_oracle <vector.gvec>\n"); return 2; }
  parse(argv[1], &v);
  memset(loaded_gen, 0, sizeof(loaded_gen));

  settings.pulse_microseconds = v.pulse_us;
  settings.stepper_idle_lock_time = v.idle_lock;
  settings.step_invert_mask = v.step_invert;
  settings.dir_invert_mask = v.dir_invert;
  settings.flags = v.invert_st_enable ? BITFLAG_INVERT_ST_ENABLE : 0;

  hrt_reset();
  memset(&sys, 0, sizeof(sys));
  memcpy(sys_position, v.pos0, sizeof(sys_position));
  memset(sys_probe_position, 0, sizeof(sys_probe_position));
  sys_probe_state = v.probe_from_tick ? PROBE_ACTIVE : PROBE_OFF;
  sys_rt_exec_state = 0;
  hosted_probe_pin_triggered = 0;
  hosted_probe_tick = 0;
  hosted_tick_no = 0;

  st_reset();                     /* rings zeroed, ports driven to invert masks */
  rest_step = hrt.port[HRT_PORT_STEP];
  rest_dir  = hrt.port[HRT_PORT_DIRECTION];

  sys.state = v.homing ? STATE_HOMING : STATE_CYCLE;
  sys.homing_axis_lock = v.homing ? v.homing_lock : 0xff;

  st_wake_up();                   /* step_outbits := invert mask; pulse timing */
  grbl_seg_next_head_set(1);
  next_head = 1;
  fill_slot = 0;

  printf("# gtrace/%d\n", SEGX_VERSION);
  printf("V %s\n", v.name[0] ? v.name : "(unnamed)");
  printf("C f_tick=%llu pulse_ticks=%u step_invert=0x%02x dir_invert=0x%02x "
         "rest_step=0x%02x rest_dir=0x%02x homing=%u homing_lock=0x%02x\n",
         (unsigned long long)v.f_tick, v.pulse_ticks, v.step_invert, v.dir_invert,
         rest_step, rest_dir, v.homing, v.homing ? v.homing_lock : 0xff);

  for (;;) {
    /* Admit as much as the ring physically holds. W=5 is the ring, not a
       separate knob: full is tail == next_head (stepper.c:690). */
    while (pending < v.nseg && grbl_seg_tail_get() != next_head) {
      grbl_seg_frame_t s = v.seg[pending];
      const grbl_blk_frame_t *bsrc;
      wire_roundtrip_seg(&s);
      bsrc = find_blk(&v, s.blk_gen);
      if (!bsrc) { die("SEG references unknown blk_gen", v.name); }
      if (!loaded_gen[s.blk_gen]) {          /* F1: BLK before referencing SEG */
        grbl_blk_frame_t b = *bsrc;
        wire_roundtrip_blk(&b);
        grbl_blk_write(&b);
        loaded_gen[s.blk_gen] = 1;
      }
      /* Slot discipline is stock's, exactly: the producer fills the slot HEAD
         currently points at (stepper.c:867 - head lags one behind next_head),
         then the strobe moves head to next_head (stepper.c:1049+seam). */
      grbl_seg_write(fill_slot, &s);
      grbl_seg_head_set(next_head);          /* THE publish strobe */
      fill_slot = next_head;
      next_head = (uint8_t)((next_head + 1u) % SEGMENT_BUFFER_SIZE);
      grbl_seg_next_head_set(next_head);
      pending++;
    }

    if (v.probe_from_tick && tick + 1u >= v.probe_from_tick) {
      hosted_probe_pin_triggered = 1;
    }

    hrt.cycle_stop = 0;
    hrt.pwm_written = 0;
    hosted_tick_no = tick;
    grbl_hosted_isr_step();
    tick++;

    printf("T %u %llu %u 0x%02x 0x%02x %u %ld %ld %ld\n",
           tick, (unsigned long long)clk, hrt.period,
           hrt.port[HRT_PORT_DIRECTION], hrt.port[HRT_PORT_STEP], hrt.pwm,
           (long)sys_position[0], (long)sys_position[1], (long)sys_position[2]);

    /* Falling edge: the pulse-reset one-shot the ISR armed this tick. */
    grbl_hosted_isr_step_reset();

    if (hosted_probe_tick == tick) {
      printf("X %u %llu PROBE %ld %ld %ld\n", tick, (unsigned long long)clk,
             (long)sys_probe_position[0], (long)sys_probe_position[1],
             (long)sys_probe_position[2]);
    }
    if (hrt.cycle_stop) {
      printf("X %u %llu DRAIN pwm=%u idle=%u\n", tick, (unsigned long long)clk,
             hrt.pwm, hrt.idle_called);
      clk += (uint64_t)hrt.period + 1u;
      break;
    }
    clk += (uint64_t)hrt.period + 1u;
    if (tick >= v.max_ticks) {
      printf("X %u %llu TICK_LIMIT\n", tick, (unsigned long long)clk);
      break;
    }
  }

  printf("Z ticks=%u clk=%llu pos=%ld,%ld,%ld probe=%ld,%ld,%ld probe_tick=%u\n",
         tick, (unsigned long long)clk,
         (long)sys_position[0], (long)sys_position[1], (long)sys_position[2],
         (long)sys_probe_position[0], (long)sys_probe_position[1],
         (long)sys_probe_position[2], hosted_probe_tick);
  return 0;
}
