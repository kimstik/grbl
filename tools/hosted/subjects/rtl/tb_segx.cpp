/*
  tb_segx.cpp - Verilated SEGX/1 executor as a conformance subject.

  Part of Grbl / Intelligence assisted / License: MIT

  Contract, identical to every other subject (ci/seg_conformance.py):
      tb_segx <vector.gvec>   -> .gtrace on stdout, exit 0

  The subject plays HOST. It serialises the vector into Profile F frames using
  grbl/platform/extensions/common/segwire.h - the same header the firmware
  shipper uses - and clocks them into the RTL one byte per cycle, respecting the
  credit window W=5. Nothing is poked into the design's internals; everything
  the executor learns, it learns from bytes.

  Two things this proves that no C or Python subject can:

  (1) THE CLK COLUMN IS MEASURED, NOT MODELLED. The golden trace's third field
      is the cumulative F_TICK clock at each tick. Here it comes from counting
      actual simulated clock edges. A tick divider off by one shifts every row.
      The arithmetic model is computed in parallel and compared at every tick
      (--strict-clk, on by default), so the two can never quietly agree by both
      being wrong in the same place.

  (2) PULSE SHAPE. The trace records the latched port bits; the pin is a
      pulse-gated version of them. Width in clocks and DIR-to-STEP setup are
      measured here and reported on stderr, and checked exactly in --selfcheck.

  Options beyond the subject contract (all default to the value the conformance
  run uses, so the trace is a pure function of the vector):
      --byte-gap N        idle clocks between link bytes (models SPI bit rate)
      --credit-latency N  clocks before a completion credit reaches the host
      --dir-settle N      clocks DIR leads the pulse
      --selfcheck         property tests, no vector
*/

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <string>
#include <vector>
#include <deque>
#include <map>

#include "verilated.h"
#include "Vsegx_top.h"
#include "Vsegx_slot.h"
#include "Vsegx_crc8.h"

#include "segwire.h"

#define W_WINDOW 5

struct Blk {
  uint8_t gen; uint32_t s[3]; uint32_t sec; uint8_t dir; uint8_t flags;
};
struct Seg {
  uint16_t n_step, cpt; uint8_t gen, amass, pwm;
};

struct Vec {
  std::string name = "(unnamed)";
  uint64_t f_tick = 16000000ull;
  uint32_t pulse_ticks = 160;
  uint32_t pulse_us = 10;
  uint8_t step_invert = 0, dir_invert = 0, invert_st_enable = 0, idle_lock = 25;
  uint8_t homing = 0, homing_lock = 0;
  uint32_t probe_from_tick = 0;
  int32_t pos0[3] = {0, 0, 0};
  uint32_t max_ticks = 2000000u;
  std::map<int, Blk> blks;
  std::vector<Seg> segs;
};

static const char *fault_name(unsigned c)
{
  switch (c) {
    case SEGX_FAULT_NSTEP0:      return "nstep0";
    case SEGX_FAULT_CRC:         return "crc";
    case SEGX_FAULT_SEQ_GAP:     return "seq_gap";
    case SEGX_FAULT_UNKNOWN_BLK: return "unknown_blk";
    case SEGX_FAULT_OVERFLOW:    return "overflow";
    case SEGX_FAULT_AMASS:       return "amass";
    case SEGX_FAULT_BAD_TAG:     return "bad_tag";
    default:                     return "?";
  }
}

static void die(const std::string &m)
{
  fprintf(stderr, "tb_segx: %s\n", m.c_str());
  exit(2);
}

static long tonum(const std::string &s) { return strtol(s.c_str(), NULL, 0); }

static Vec parse(const char *path)
{
  Vec v;
  FILE *f = fopen(path, "r");
  char line[512];
  bool magic = false;
  if (!f) die(std::string("cannot open vector: ") + path);
  while (fgets(line, sizeof(line), f)) {
    std::vector<std::string> t;
    char *p = strtok(line, " \t\r\n");
    while (p) { t.push_back(p); p = strtok(NULL, " \t\r\n"); }
    if (t.empty() || t[0][0] == '#') continue;
    const std::string &k = t[0];
    if (k == "gvec") { if (tonum(t[1]) != SEGX_VERSION) die("bad gvec version"); magic = true; }
    else if (k == "name") { v.name = t[1]; for (size_t i = 2; i < t.size(); i++) v.name += " " + t[i]; }
    else if (k == "f_tick") v.f_tick = (uint64_t)tonum(t[1]);
    else if (k == "pulse_ticks") v.pulse_ticks = (uint32_t)tonum(t[1]);
    else if (k == "pulse_us") v.pulse_us = (uint32_t)tonum(t[1]);
    else if (k == "step_invert") v.step_invert = (uint8_t)tonum(t[1]);
    else if (k == "dir_invert") v.dir_invert = (uint8_t)tonum(t[1]);
    else if (k == "invert_st_enable") v.invert_st_enable = (uint8_t)tonum(t[1]);
    else if (k == "idle_lock") v.idle_lock = (uint8_t)tonum(t[1]);
    else if (k == "homing") v.homing = (uint8_t)tonum(t[1]);
    else if (k == "homing_lock") v.homing_lock = (uint8_t)tonum(t[1]);
    else if (k == "probe_from_tick") v.probe_from_tick = (uint32_t)tonum(t[1]);
    else if (k == "max_ticks") v.max_ticks = (uint32_t)tonum(t[1]);
    else if (k == "pos") { for (int i = 0; i < 3; i++) v.pos0[i] = (int32_t)tonum(t[1 + i]); }
    else if (k == "blk") {
      Blk b;
      b.gen = (uint8_t)tonum(t[1]);
      b.s[0] = (uint32_t)tonum(t[2]); b.s[1] = (uint32_t)tonum(t[3]); b.s[2] = (uint32_t)tonum(t[4]);
      b.sec = (uint32_t)tonum(t[5]); b.dir = (uint8_t)tonum(t[6]); b.flags = (uint8_t)tonum(t[7]);
      v.blks[b.gen] = b;
    } else if (k == "seg") {
      Seg s;
      s.n_step = (uint16_t)tonum(t[1]); s.cpt = (uint16_t)tonum(t[2]);
      s.gen = (uint8_t)tonum(t[3]); s.amass = (uint8_t)tonum(t[4]); s.pwm = (uint8_t)tonum(t[5]);
      v.segs.push_back(s);
    } else die("unknown keyword '" + k + "'");
  }
  fclose(f);
  if (!magic) die("missing 'gvec 1' header");
  return v;
}

/* ---- link driver -------------------------------------------------------- */

struct Link {
  std::deque<uint8_t> q;
  int gap = 0, gap_left = 0;

  void frame(uint8_t tag, const uint8_t *pay, uint8_t len)
  {
    uint8_t buf[SEGX_MAX_FRAME];
    uint16_t n = segx_frame_build(buf, tag, pay, len);
    for (uint16_t i = 0; i < n; i++) q.push_back(buf[i]);
  }
};

static uint64_t g_cycle = 0;

/* ---- pulse-shape observer ----------------------------------------------- */

struct PulseStat {
  uint64_t pulses = 0, width_ok = 0, truncated = 0;
  uint64_t min_setup = UINT64_MAX;
  uint64_t last_dir_change = 0;
  bool in_pulse = false;
  uint64_t pulse_start = 0;
  uint32_t prev_step = 0, prev_dir = 0;
  bool primed = false;

  bool observe = false;   // pins are only meaningful once CFG has landed: before
                          // it, the resting level is 0 rather than $2, and a
                          // non-zero $2 would otherwise read as a first pulse

  void sample(uint32_t phy_step, uint32_t phy_dir, uint32_t rest_step,
              uint32_t expect_width, bool tick_boundary)
  {
    if (!observe) return;
    if (primed && phy_dir != prev_dir) last_dir_change = g_cycle;
    bool active = (phy_step != rest_step);
    if (active && !in_pulse) {
      in_pulse = true;
      pulse_start = g_cycle;
      pulses++;
      if (primed) {
        uint64_t setup = g_cycle - last_dir_change;
        if (setup < min_setup) min_setup = setup;
      }
    } else if (!active && in_pulse) {
      in_pulse = false;
      uint64_t w = g_cycle - pulse_start;
      if (w == expect_width) width_ok++;
    }
    if (tick_boundary && in_pulse && g_cycle != pulse_start) truncated++;
    prev_step = phy_step; prev_dir = phy_dir; primed = true;
  }
};

/* ---- main --------------------------------------------------------------- */

static Vsegx_top *top;
static Link g_link;
static int opt_byte_gap = 0, opt_credit_latency = 0, opt_dir_settle = 0;
static bool opt_strict_clk = true;

static void clk_cycle(bool feed)
{
  top->clk = 0;
  if (feed && !g_link.q.empty() && g_link.gap_left == 0) {
    top->rx_valid = 1;
    top->rx_byte = g_link.q.front();
    g_link.q.pop_front();
    g_link.gap_left = opt_byte_gap;
  } else {
    top->rx_valid = 0;
    if (g_link.gap_left) g_link.gap_left--;
  }
  top->eval();
}

static bool pre_tick()   /* combinational tick_stb for the cycle about to clock */
{
  return top->tick_stb != 0;
}

static void posedge()
{
  top->clk = 1;
  top->eval();
  g_cycle++;
}

static int selfcheck();

int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);
  const char *vpath = NULL;
  bool do_selfcheck = false;

  for (int i = 1; i < argc; i++) {
    std::string a = argv[i];
    if (a == "--byte-gap" && i + 1 < argc) opt_byte_gap = atoi(argv[++i]);
    else if (a == "--credit-latency" && i + 1 < argc) opt_credit_latency = atoi(argv[++i]);
    else if (a == "--dir-settle" && i + 1 < argc) opt_dir_settle = atoi(argv[++i]);
    else if (a == "--no-strict-clk") opt_strict_clk = false;
    else if (a == "--selfcheck") do_selfcheck = true;
    else if (a.size() && a[0] == '-' && a.rfind("-V", 0) == 0) continue;  /* verilator arg */
    else if (a.size() && a[0] == '+') continue;
    else if (a.size() && a[0] == '-') die("unknown option " + a);
    else vpath = argv[i];
  }

  if (do_selfcheck) return selfcheck();
  if (!vpath) die("usage: tb_segx [options] <vector.gvec>");

  Vec v = parse(vpath);
  top = new Vsegx_top;

  /* Cross-check: the RTL's own framing constants against segwire.h. If someone
     edits one side, this fires before a single vector runs. */
  top->clk = 0; top->rst_n = 0; top->rx_valid = 0; top->rx_byte = 0;
  top->probe_pin_raw = 0; top->cfg_dir_settle = opt_dir_settle;
  top->eval();
  uint32_t want_params = ((uint32_t)SEGX_TAG_CFG << 24) | ((uint32_t)SEGX_TAG_BLK << 16) |
                         ((uint32_t)SEGX_TAG_SEG << 8) | (uint32_t)SEGX_SOF;
  if (top->o_params != want_params) {
    fprintf(stderr, "tb_segx: RTL framing constants 0x%08x != segwire.h 0x%08x\n",
            (unsigned)top->o_params, (unsigned)want_params);
    return 2;
  }

  for (int i = 0; i < 4; i++) { clk_cycle(false); posedge(); }
  top->rst_n = 1;
  for (int i = 0; i < 2; i++) { clk_cycle(false); posedge(); }

  const uint8_t step_inv = (uint8_t)(v.step_invert & 7u);
  const uint8_t dir_inv  = (uint8_t)(v.dir_invert & 7u);
  const uint8_t hlock    = v.homing ? v.homing_lock : 0xff;

  /* CFG */
  {
    grbl_cfg_frame_t c;
    uint8_t pay[SEGX_CFG_WIRE_LEN];
    memset(&c, 0, sizeof(c));
    c.step_invert = step_inv;
    c.dir_invert = dir_inv;
    c.pulse_ticks = (uint16_t)v.pulse_ticks;
    c.flags = (uint8_t)((v.homing ? SEGX_CFG_FLAG_HOMING : 0) |
                        (v.probe_from_tick ? SEGX_CFG_FLAG_PROBE_ARM : 0));
    c.homing_lock = (uint8_t)(hlock & 7u);
    c.probe_invert = 0;
    c.pos[0] = v.pos0[0]; c.pos[1] = v.pos0[1]; c.pos[2] = v.pos0[2];
    segx_cfg_encode(&c, pay);
    g_link.frame(SEGX_TAG_CFG, pay, SEGX_CFG_WIRE_LEN);
  }

  /* Ship segments; a BLK goes out before the first SEG that references it
     (invariant F1). This is exactly what the host shipper does. */
  size_t next_seg = 0;
  std::map<int, bool> blk_sent;
  uint8_t pushed = 0;
  uint8_t seq = 0;

  auto ship_one = [&]() {
    const Seg &s = v.segs[next_seg];
    if (!blk_sent[s.gen]) {
      if (v.blks.find(s.gen) == v.blks.end()) die("vector references an undeclared blk");
      const Blk &b = v.blks[s.gen];
      grbl_blk_frame_t bf;
      uint8_t pay[SEGX_BLK_WIRE_LEN];
      bf.blk_gen = b.gen;
      bf.steps[0] = b.s[0]; bf.steps[1] = b.s[1]; bf.steps[2] = b.s[2];
      bf.step_event_count = b.sec;
      bf.direction_bits = b.dir;
      bf.flags = b.flags;
      segx_blk_encode(&bf, pay);
      g_link.frame(SEGX_TAG_BLK, pay, SEGX_BLK_WIRE_LEN);
      blk_sent[s.gen] = true;
    }
    grbl_seg_frame_t sf;
    uint8_t pay[SEGX_SEG_WIRE_LEN];
    sf.n_step = s.n_step; sf.cycles_per_tick = s.cpt; sf.blk_gen = s.gen;
    sf.amass_level = s.amass; sf.spindle_pwm = s.pwm; sf.seq = seq++;
    segx_seg_encode(&sf, pay);
    g_link.frame(SEGX_TAG_SEG, pay, SEGX_SEG_WIRE_LEN);
    next_seg++;
    pushed++;
  };

  while (next_seg < v.segs.size() && pushed < W_WINDOW) ship_one();

  /* WAKE last: stock fills the segment buffer, then calls st_wake_up(). */
  { uint8_t epoch = 1; g_link.frame(SEGX_TAG_WAKE, &epoch, 1); }

  /* ---- run ------------------------------------------------------------- */
  std::vector<std::string> out;
  char buf[256];

  out.push_back("# gtrace/1");
  out.push_back("V " + v.name);
  snprintf(buf, sizeof(buf),
           "C f_tick=%llu pulse_ticks=%u step_invert=0x%02x dir_invert=0x%02x "
           "rest_step=0x%02x rest_dir=0x%02x homing=%d homing_lock=0x%02x",
           (unsigned long long)v.f_tick, (unsigned)v.pulse_ticks,
           v.step_invert, v.dir_invert, step_inv, dir_inv, (int)v.homing, hlock);
  out.push_back(buf);

  uint64_t clk_model = 0;
  uint64_t tick = 0;
  uint64_t first_tick_cycle = 0;
  bool started = false;
  int32_t probe_p[3] = {0, 0, 0};
  uint64_t probe_tick = 0;
  int32_t pos[3] = {0, 0, 0};
  bool ended = false;
  PulseStat ps;
  std::deque<std::pair<uint64_t, uint8_t> > credit_pipe;
  uint8_t credit_seen = 0;

  const uint64_t CYCLE_BUDGET = 40000000ull;

  while (!ended && g_cycle < CYCLE_BUDGET) {
    /* probe pin: high from probe_from_tick onward, sampled at the tick */
    top->probe_pin_raw = (v.probe_from_tick && (tick + 1) >= v.probe_from_tick) ? 1 : 0;

    clk_cycle(true);
    bool is_tick = pre_tick();
    if (is_tick) ps.observe = true;
    ps.sample(top->phy_step, top->phy_dir, step_inv, v.pulse_ticks, is_tick);
    posedge();
    uint64_t tick_cycle = g_cycle - 1;
    bool probe_now = (top->probe_hit != 0);

    if (is_tick && !top->fault) {
      // A tick's Bresenham retires two clocks after its edge (segx_exec.v:
      // phase 1 accumulates, phase 2 compares). The trace is a record of a
      // COMPLETED tick, so it is sampled once the pipeline has drained - the
      // port bits, period and pwm are already stable at the edge, the
      // position is not. Those two clocks are inside the tick interval and
      // are counted like any other; a tick short enough to collide with them
      // is SEGX_FAULT_TOO_FAST and is caught below, not silently mis-sampled.
      for (int k = 0; k < 2; k++) {
        clk_cycle(true);
        if (pre_tick()) {
          fprintf(stderr, "tb_segx: tick %llu collided with the previous "
                          "tick's pipeline (cycles_per_tick < 3)\n",
                  (unsigned long long)(tick + 2));
          return 3;
        }
        ps.sample(top->phy_step, top->phy_dir, step_inv, v.pulse_ticks, false);
        posedge();
      }
    }

    /* reverse channel: credits arrive after credit_latency clocks */
    credit_pipe.push_back(std::make_pair(g_cycle + (uint64_t)opt_credit_latency,
                                         (uint8_t)top->credit));
    while (!credit_pipe.empty() && credit_pipe.front().first <= g_cycle) {
      credit_seen = credit_pipe.front().second;
      credit_pipe.pop_front();
    }
    while (next_seg < v.segs.size() &&
           (uint8_t)(pushed - credit_seen) < W_WINDOW) ship_one();

    if (!is_tick) continue;

    if (top->fault) {
      snprintf(buf, sizeof(buf), "X %llu %llu FAULT code=%u %s",
               (unsigned long long)(tick + 1), (unsigned long long)clk_model,
               (unsigned)top->fault, fault_name(top->fault));
      out.push_back(buf);
      ended = true;
      break;
    }

    if (!started) { started = true; first_tick_cycle = tick_cycle; }
    uint64_t measured = tick_cycle - first_tick_cycle;
    if (opt_strict_clk && measured != clk_model) {
      fprintf(stderr, "tb_segx: tick %llu clock mismatch: measured %llu, model %llu\n",
              (unsigned long long)(tick + 1), (unsigned long long)measured,
              (unsigned long long)clk_model);
      return 3;
    }

    tick++;
    pos[0] = (int32_t)top->pos0; pos[1] = (int32_t)top->pos1; pos[2] = (int32_t)top->pos2;
    snprintf(buf, sizeof(buf), "T %llu %llu %u 0x%02x 0x%02x %u %d %d %d",
             (unsigned long long)tick, (unsigned long long)clk_model,
             (unsigned)top->period, (unsigned)(top->dir_port & 7),
             (unsigned)top->step_port, (unsigned)top->pwm,
             pos[0], pos[1], pos[2]);
    out.push_back(buf);

    if (probe_now) {
      probe_tick = tick;
      probe_p[0] = (int32_t)top->probe_pos0;
      probe_p[1] = (int32_t)top->probe_pos1;
      probe_p[2] = (int32_t)top->probe_pos2;
      snprintf(buf, sizeof(buf), "X %llu %llu PROBE %d %d %d",
               (unsigned long long)tick, (unsigned long long)clk_model,
               probe_p[0], probe_p[1], probe_p[2]);
      out.push_back(buf);
    }

    if (top->drained && next_seg < v.segs.size()) {
      // Host-side underrun, which is the authoritative one: the executor ran
      // dry while this host still had segments it had not shipped. In stock
      // that cannot happen (one core, one program order); over a link it is
      // the credit-staleness stutter of SEGX/1 §3.5 R1, and it destroys the
      // velocity profile with zero lost steps, so it must never be silent.
      fprintf(stderr, "tb_segx: FAIL - executor drained at tick %llu with %zu "
                      "segment(s) still unshipped (credit staleness, "
                      "byte-gap=%d credit-latency=%d)\n",
              (unsigned long long)tick, v.segs.size() - next_seg,
              opt_byte_gap, opt_credit_latency);
      return 4;
    }

    if (top->drained) {
      snprintf(buf, sizeof(buf), "X %llu %llu DRAIN pwm=%u idle=1",
               (unsigned long long)tick, (unsigned long long)clk_model,
               (unsigned)top->pwm);
      out.push_back(buf);
      clk_model += (uint64_t)top->period + 1;
      ended = true;
      break;
    }

    clk_model += (uint64_t)top->period + 1;
    if (tick >= v.max_ticks) {
      snprintf(buf, sizeof(buf), "X %llu %llu TICK_LIMIT",
               (unsigned long long)tick, (unsigned long long)clk_model);
      out.push_back(buf);
      ended = true;
      break;
    }
  }

  if (!ended) die("cycle budget exhausted before the executor drained");

  snprintf(buf, sizeof(buf),
           "Z ticks=%llu clk=%llu pos=%d,%d,%d probe=%d,%d,%d probe_tick=%llu",
           (unsigned long long)tick, (unsigned long long)clk_model,
           pos[0], pos[1], pos[2], probe_p[0], probe_p[1], probe_p[2],
           (unsigned long long)probe_tick);
  out.push_back(buf);

  for (size_t i = 0; i < out.size(); i++) printf("%s\n", out[i].c_str());

  fprintf(stderr, "tb_segx: %s cycles=%llu frames=%u credit=%u underrun=%u "
                  "pulses=%llu width_ok=%llu truncated=%llu min_dir_setup=%s\n",
          v.name.c_str(), (unsigned long long)g_cycle, (unsigned)top->frames_ok,
          (unsigned)top->credit, (unsigned)top->underrun,
          (unsigned long long)ps.pulses, (unsigned long long)ps.width_ok,
          (unsigned long long)ps.truncated,
          ps.min_setup == UINT64_MAX ? "n/a" : std::to_string(ps.min_setup).c_str());

  if (top->underrun) {
    fprintf(stderr, "tb_segx: FAIL - executor underran %u time(s); the host still "
                    "owed work when the FIFO emptied\n", (unsigned)top->underrun);
    return 4;
  }

  delete top;
  return 0;
}

/* ---- property self-checks ----------------------------------------------- */

static int fails = 0, passes = 0;
static void chk(bool c, const char *what)
{
  if (c) passes++;
  else { fails++; printf("  FAIL: %s\n", what); }
}

static int selfcheck()
{
  /* (1) gen -> slot, all 256 inputs, against C's %. The RTL's only piece of
     non-obvious arithmetic, checked exhaustively rather than by inspection. */
  {
    Vsegx_slot *m = new Vsegx_slot;
    int bad = 0;
    for (int g = 0; g < 256; g++) {
      m->g = (uint8_t)g;
      m->eval();
      if (m->s != SEGX_GEN_TO_SLOT((unsigned)g)) {
        if (bad < 5) printf("  FAIL: segx_slot(%d) = %u, expected %u\n",
                            g, (unsigned)m->s, (unsigned)SEGX_GEN_TO_SLOT((unsigned)g));
        bad++;
      }
    }
    chk(bad == 0, "segx_slot == gen % 5 for all 256 generations");
    delete m;
  }

  /* (1b) CRC-8 unit, all 65536 (remainder, byte) pairs against segwire.h.
     If these two ever disagree the link rejects every frame the host sends,
     which is a bring-up failure that looks like a wiring fault. */
  {
    Vsegx_crc8 *m = new Vsegx_crc8;
    int bad = 0;
    for (int c = 0; c < 256; c++) {
      for (int d = 0; d < 256; d++) {
        m->c = (uint8_t)c; m->d = (uint8_t)d;
        m->eval();
        if (m->q != segx_crc8_byte((uint8_t)c, (uint8_t)d)) bad++;
      }
    }
    chk(bad == 0, "segx_crc8 == segx_crc8_byte() for all 65536 (crc, byte) pairs");
    delete m;
  }

  /* (2) CRC-8 agreement between segwire.h and the RTL receiver. Feed a frame
     whose CRC is deliberately wrong and confirm the executor faults; feed the
     same frame correct and confirm it does not. */
  for (int corrupt = 0; corrupt < 2; corrupt++) {
    Vsegx_top *t = new Vsegx_top;
    uint8_t pay[SEGX_CFG_WIRE_LEN];
    grbl_cfg_frame_t c;
    memset(&c, 0, sizeof(c));
    c.pulse_ticks = 160;
    segx_cfg_encode(&c, pay);
    uint8_t fr[SEGX_MAX_FRAME];
    uint16_t n = segx_frame_build(fr, SEGX_TAG_CFG, pay, SEGX_CFG_WIRE_LEN);
    if (corrupt) fr[n - 1] ^= 0x01;

    t->clk = 0; t->rst_n = 0; t->rx_valid = 0; t->cfg_dir_settle = 0;
    t->probe_pin_raw = 0; t->eval();
    for (int i = 0; i < 4; i++) { t->clk = 0; t->eval(); t->clk = 1; t->eval(); }
    t->rst_n = 1;
    for (uint16_t i = 0; i < n; i++) {
      t->clk = 0; t->rx_valid = 1; t->rx_byte = fr[i]; t->eval();
      t->clk = 1; t->eval();
    }
    t->clk = 0; t->rx_valid = 0; t->eval(); t->clk = 1; t->eval();
    if (corrupt) chk(t->fault == SEGX_FAULT_CRC, "a one-bit CRC error faults the executor");
    else chk(t->fault == 0 && t->frames_ok == 1, "a well-formed CFG frame is accepted");
    delete t;
  }

  /* (3) Sequence gap. Two SEG frames with seq 0 then 2. */
  {
    Vsegx_top *t = new Vsegx_top;
    t->clk = 0; t->rst_n = 0; t->rx_valid = 0; t->cfg_dir_settle = 0;
    t->probe_pin_raw = 0; t->eval();
    for (int i = 0; i < 4; i++) { t->clk = 0; t->eval(); t->clk = 1; t->eval(); }
    t->rst_n = 1;
    uint8_t seqs[2] = {0, 2};
    for (int k = 0; k < 2; k++) {
      grbl_seg_frame_t s;
      uint8_t pay[SEGX_SEG_WIRE_LEN], fr[SEGX_MAX_FRAME];
      s.n_step = 4; s.cycles_per_tick = 99; s.blk_gen = 1; s.amass_level = 0;
      s.spindle_pwm = 0; s.seq = seqs[k];
      segx_seg_encode(&s, pay);
      uint16_t n = segx_frame_build(fr, SEGX_TAG_SEG, pay, SEGX_SEG_WIRE_LEN);
      for (uint16_t i = 0; i < n; i++) {
        t->clk = 0; t->rx_valid = 1; t->rx_byte = fr[i]; t->eval();
        t->clk = 1; t->eval();
      }
    }
    t->clk = 0; t->rx_valid = 0; t->eval(); t->clk = 1; t->eval();
    chk(t->fault == SEGX_FAULT_SEQ_GAP, "a dropped SEG frame faults on the sequence gap");
    delete t;
  }

  /* (4) Credit window. Push W+1 segments without any completing and confirm
     the executor reports overflow rather than silently dropping one. */
  {
    Vsegx_top *t = new Vsegx_top;
    t->clk = 0; t->rst_n = 0; t->rx_valid = 0; t->cfg_dir_settle = 0;
    t->probe_pin_raw = 0; t->eval();
    for (int i = 0; i < 4; i++) { t->clk = 0; t->eval(); t->clk = 1; t->eval(); }
    t->rst_n = 1;
    for (int k = 0; k < W_WINDOW + 1; k++) {
      grbl_seg_frame_t s;
      uint8_t pay[SEGX_SEG_WIRE_LEN], fr[SEGX_MAX_FRAME];
      s.n_step = 4; s.cycles_per_tick = 99; s.blk_gen = 1; s.amass_level = 0;
      s.spindle_pwm = 0; s.seq = (uint8_t)k;
      segx_seg_encode(&s, pay);
      uint16_t n = segx_frame_build(fr, SEGX_TAG_SEG, pay, SEGX_SEG_WIRE_LEN);
      for (uint16_t i = 0; i < n; i++) {
        t->clk = 0; t->rx_valid = 1; t->rx_byte = fr[i]; t->eval();
        t->clk = 1; t->eval();
      }
    }
    t->clk = 0; t->rx_valid = 0; t->eval(); t->clk = 1; t->eval();
    chk(t->fault == SEGX_FAULT_OVERFLOW,
        "exceeding the W=5 credit window faults instead of dropping a segment");
    delete t;
  }

  /* (5) Pulse shape: width == $0 in clocks, DIR leads STEP by dir_settle.
     Neither property is expressible in the golden trace, which samples latched
     bits at tick boundaries; both are what an oscilloscope would measure. */
  {
    const int settle = 8, pulse = 40, period = 400;
    Vsegx_top *t = new Vsegx_top;
    t->clk = 0; t->rst_n = 0; t->rx_valid = 0; t->cfg_dir_settle = settle;
    t->probe_pin_raw = 0; t->eval();
    for (int i = 0; i < 4; i++) { t->clk = 0; t->eval(); t->clk = 1; t->eval(); }
    t->rst_n = 1;

    Link L;
    grbl_cfg_frame_t c;
    uint8_t pay[SEGX_CFG_WIRE_LEN];
    memset(&c, 0, sizeof(c));
    c.pulse_ticks = pulse;
    segx_cfg_encode(&c, pay);
    L.frame(SEGX_TAG_CFG, pay, SEGX_CFG_WIRE_LEN);
    {
      grbl_blk_frame_t b;
      uint8_t bp[SEGX_BLK_WIRE_LEN];
      b.blk_gen = 1; b.steps[0] = 80; b.steps[1] = 0; b.steps[2] = 0;
      b.step_event_count = 80; b.direction_bits = 0; b.flags = 0;
      segx_blk_encode(&b, bp);
      L.frame(SEGX_TAG_BLK, bp, SEGX_BLK_WIRE_LEN);
      grbl_blk_frame_t b2 = b;
      b2.blk_gen = 2; b2.direction_bits = 1;
      segx_blk_encode(&b2, bp);
      L.frame(SEGX_TAG_BLK, bp, SEGX_BLK_WIRE_LEN);
    }
    for (int k = 0; k < 4; k++) {
      grbl_seg_frame_t s;
      uint8_t sp[SEGX_SEG_WIRE_LEN];
      s.n_step = 3; s.cycles_per_tick = period; s.blk_gen = (k < 2) ? 1 : 2;
      s.amass_level = 0; s.spindle_pwm = 0; s.seq = (uint8_t)k;
      segx_seg_encode(&s, sp);
      L.frame(SEGX_TAG_SEG, sp, SEGX_SEG_WIRE_LEN);
    }
    { uint8_t e = 1; L.frame(SEGX_TAG_WAKE, &e, 1); }

    uint64_t cyc = 0, pstart = 0, dchg = 0;
    bool inp = false, primed = false;
    uint32_t pd = 0, pstep = 0;
    int widths_ok = 0, widths_bad = 0, setups_ok = 0, setups_bad = 0, edges = 0;
    while (cyc < 20000 && !t->drained) {
      t->clk = 0;
      if (!L.q.empty()) { t->rx_valid = 1; t->rx_byte = L.q.front(); L.q.pop_front(); }
      else t->rx_valid = 0;
      t->eval();
      t->clk = 1; t->eval();
      cyc++;
      if (primed && t->phy_dir != pd) dchg = cyc;
      bool act = (t->phy_step != 0);
      if (act && !inp) {
        inp = true; pstart = cyc; edges++;
        if (primed && dchg) {
          if (cyc - dchg >= (uint64_t)settle) setups_ok++; else setups_bad++;
        }
      } else if (!act && inp) {
        inp = false;
        if (cyc - pstart == (uint64_t)pulse) widths_ok++; else widths_bad++;
      }
      pd = t->phy_dir; pstep = t->phy_step; primed = true;
    }
    (void)pstep;
    chk(edges >= 4, "the pulse-shape vector actually produced pulses");
    chk(widths_bad == 0 && widths_ok >= 4, "every step pulse is exactly $0 clocks wide");
    chk(setups_bad == 0, "DIR leads every pulse by at least dir_settle clocks");
    chk(t->drained != 0, "the pulse-shape vector drained");
    delete t;
  }

  printf("tb_segx --selfcheck: %d passed, %d failed\n", passes, fails);
  return fails ? 1 : 0;
}
