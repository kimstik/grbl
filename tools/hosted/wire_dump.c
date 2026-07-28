/*
  wire_dump.c - run the REAL host shipper over the REAL frozen ring and write
  the Profile F byte stream it produces.

  Part of Grbl / Intelligence assisted / License: MIT

    seg_wire <vector.gvec> > stream.gwire

  This is the stage-4 half of the loop. oracle.c proves the frozen ISR is a
  specification; tb_segx proves an executor can meet it. Neither touches the
  host's serialiser - and the serialiser is where the one genuine
  reconstruction lives (ring slot -> 8-bit generation counter, seg_link.h).

  So: fill the frozen ring exactly as st_prep_buffer would, call the seam's
  publish strobe, and let grbl/platform/extensions/seg-link/seg_link.c - the
  same file the firmware compiles - read the ring back through the seam exports
  and serialise it. What comes out is fed to the Verilated executor, which must
  reproduce the golden trace. If the shipper mislabels a generation, drops a
  BLK, or gets the sequence wrong, the executor faults or steps differently and
  the trace moves.

  What this does NOT exercise, stated so the claim is not overread: the
  producer. st_prep_buffer is linked and never called (its float path is out of
  scope by design, SEGMENT-RUNTIME-PLAN §4 stage 3). The ring contents come
  from the committed vector, same as the oracle's.
*/

#include "prelude.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../../grbl/platform/extensions/seg-link/seg_link.h"

#define MAX_SEGS 4096
#define MAX_BLKS 256

typedef struct {
  char     name[64];
  uint8_t  step_invert, dir_invert, homing, homing_lock;
  uint32_t pulse_ticks;
  uint32_t probe_from_tick;
  int32_t  pos0[3];
  grbl_blk_frame_t blk[MAX_BLKS];
  int nblk;
  grbl_seg_frame_t seg[MAX_SEGS];
  int nseg;
} vec_t;

static void die(const char *m, const char *d)
{
  fprintf(stderr, "seg_wire: %s%s%s\n", m, d ? ": " : "", d ? d : "");
  exit(2);
}

/* stubs.c's probe_state_monitor reads this; the oracle owns it there, and a
   second program linking the same stubs has to supply it too. */
uint32_t hosted_tick_no;

/* ---- transport: the bytes go to stdout ---------------------------------- */

void seg_link_tx(const uint8_t *bytes, uint16_t n)
{
  fwrite(bytes, 1, n, stdout);
}

/* ---- vector parsing (the keywords wire_dump needs; unknown ones are a
   hard error exactly as in every other tool that reads a .gvec) ----------- */

static void parse(const char *path, vec_t *v)
{
  FILE *f = fopen(path, "r");
  char line[512];
  int magic = 0;
  if (!f) { die("cannot open vector", path); }
  memset(v, 0, sizeof(*v));
  v->pulse_ticks = 160;
  while (fgets(line, sizeof(line), f)) {
    char kw[32];
    char *p = line;
    while (*p == ' ' || *p == '\t') { p++; }
    if (*p == '#' || *p == '\n' || *p == '\0') { continue; }
    if (sscanf(p, "%31s", kw) != 1) { continue; }
    p += strlen(kw);
    if (!strcmp(kw, "gvec")) {
      int ver = 0;
      if (sscanf(p, "%d", &ver) != 1 || ver != SEGX_VERSION) { die("bad gvec version", path); }
      magic = 1;
    } else if (!strcmp(kw, "name")) {
      char *q;
      while (*p == ' ' || *p == '\t') { p++; }
      strncpy(v->name, p, sizeof(v->name) - 1);
      q = strchr(v->name, '\n');
      if (q) { *q = '\0'; }
    } else if (!strcmp(kw, "step_invert")) {
      v->step_invert = (uint8_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "dir_invert")) {
      v->dir_invert = (uint8_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "homing")) {
      v->homing = (uint8_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "homing_lock")) {
      v->homing_lock = (uint8_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "pulse_ticks")) {
      v->pulse_ticks = (uint32_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "probe_from_tick")) {
      v->probe_from_tick = (uint32_t)strtoul(p, NULL, 0);
    } else if (!strcmp(kw, "pos")) {
      long a = 0, b = 0, c = 0;
      if (sscanf(p, "%ld %ld %ld", &a, &b, &c) != 3) { die("bad pos line", path); }
      v->pos0[0] = (int32_t)a; v->pos0[1] = (int32_t)b; v->pos0[2] = (int32_t)c;
    } else if (!strcmp(kw, "blk")) {
      unsigned gen, s0, s1, s2, sec, dir, flg;
      grbl_blk_frame_t *b;
      if (sscanf(p, "%u %u %u %u %u %i %i", &gen, &s0, &s1, &s2, &sec,
                 (int *)&dir, (int *)&flg) != 7) { die("bad blk line", path); }
      if (v->nblk >= MAX_BLKS) { die("too many blk lines", path); }
      b = &v->blk[v->nblk++];
      b->blk_gen = (uint8_t)gen;
      b->steps[0] = s0; b->steps[1] = s1; b->steps[2] = s2;
      b->step_event_count = sec;
      b->direction_bits = (uint8_t)dir;
      b->flags = (uint8_t)flg;
    } else if (!strcmp(kw, "seg")) {
      unsigned n, cpt, gen, am, pwm;
      grbl_seg_frame_t *s;
      if (sscanf(p, "%u %u %u %u %u", &n, &cpt, &gen, &am, &pwm) != 5) {
        die("bad seg line", path);
      }
      if (v->nseg >= MAX_SEGS) { die("too many seg lines", path); }
      s = &v->seg[v->nseg++];
      s->n_step = (uint16_t)n; s->cycles_per_tick = (uint16_t)cpt;
      s->blk_gen = (uint8_t)gen; s->amass_level = (uint8_t)am;
      s->spindle_pwm = (uint8_t)pwm; s->seq = 0;
    }
    /* Other keywords describe the CONSUMER's environment (f_tick, max_ticks,
       idle_lock, ...). They do not appear on the forward wire and are not the
       shipper's business; oracle.c and tb_segx own them. */
  }
  fclose(f);
  if (!magic) { die("missing 'gvec 1' header", path); }
}

/* ---- ring driver: exactly what the oracle does, minus the ISR ----------- */

int main(int argc, char **argv)
{
  static vec_t v;
  int i, pending = 0, woken = 0;
  uint8_t head = 0, next_head = 1, fill = 0;
  static int blk_written[256];

  if (argc != 2) { die("usage: seg_wire <vector.gvec>", NULL); }
  parse(argv[1], &v);

  grbl_seg_head_set(0);
  grbl_seg_next_head_set(1);
  seg_link_reset();

  /* CONFIG + POS_SET, which on a board is the STP_TMR_INT_ENA override. */
  seg_link_config((uint8_t)(v.step_invert & 7u), (uint8_t)(v.dir_invert & 7u),
                  (uint16_t)v.pulse_ticks,
                  (uint8_t)((v.homing ? SEGX_CFG_FLAG_HOMING : 0) |
                            (v.probe_from_tick ? SEGX_CFG_FLAG_PROBE_ARM : 0)),
                  (uint8_t)((v.homing ? v.homing_lock : 0xff) & 7u),
                  0, v.pos0);

  /* Fill and publish. The ring is walked in the producer's own discipline:
     write the slot head points at, then move head - the invisible-until-strobe
     rule the whole extension exists to preserve. `tail` never advances here
     because nothing consumes; the vector's segment count is bounded by the
     corpus and the loop below asserts it fits. */
  while (pending < v.nseg) {
    grbl_seg_frame_t *s = &v.seg[pending];
    if (next_head == grbl_seg_tail_get()) {
      die("vector needs more ring slots than the frozen ring has; the wire "
          "dumper does not model credit return (tb_segx does)", argv[1]);
    }
    if (!blk_written[s->blk_gen]) {
      for (i = 0; i < v.nblk; i++) {
        if (v.blk[i].blk_gen == s->blk_gen) {
          grbl_blk_write(&v.blk[i]);
          blk_written[s->blk_gen] = 1;
          break;
        }
      }
      if (!blk_written[s->blk_gen]) { die("seg references an undeclared blk", argv[1]); }
    }
    grbl_seg_write(fill, s);

    grbl_seg_head_set(next_head);   /* THE publish strobe */
    seg_link_publish_hook();        /* what GRBL_SEG_PUBLISH tees to */

    head = next_head;
    fill = next_head;
    next_head = (uint8_t)((next_head + 1) % SEGMENT_BUFFER_SIZE);
    pending++;

    /* Credit the segment straight back through the reverse pump, so the ring
       keeps turning over and the cursor/tail relationship is exercised for
       real. This program is not modelling flow control, only serialisation;
       tb_segx re-applies the W=5 window when it plays the stream back. */
    seg_link_credit((uint8_t)pending);

    /* WAKE goes out once the ring is full, not at the end of the stream:
       stock fills the segment buffer and THEN calls st_wake_up, and a replayed
       .gwire has to be a valid in-order session, not a batch. W=5 (§3.4). */
    if (!woken && pending >= 5) { seg_link_wake(1); woken = 1; }
  }
  (void)head;

  if (!woken) { seg_link_wake(1); }
  fflush(stdout);
  fprintf(stderr, "seg_wire: %s - %d segment(s), %u block generation(s), seq now %u\n",
          v.name, v.nseg, (unsigned)seg_link_gen(), (unsigned)seg_link_seq());
  return 0;
}
