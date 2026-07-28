// segx_exec.v - SEGX/1 segment executor, synthesisable.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// This is a CANDIDATE far-side executor, written from the contract text
// (grbl/platform/docs/SEGMENT-RUNTIME-PLAN.md §3.3) in a language that shares
// nothing with the oracle. It is registered as a conformance subject: it must
// reproduce the frozen ISR's tick trace byte for byte over the whole corpus,
// and where it does not, the divergence is declared and committed
// (divergences.txt) rather than tolerated.
//
// Everything here runs in the F_TICK clock domain. `clk` IS the stepper timer
// clock - the thing `cycles_per_tick` is denominated in (§3.1). On the first
// intended board that is the ch32v006's 48 MHz exported on MCO, so host and
// executor share one oscillator by construction and there is no drift term.
//
// TIMING MODEL, which is half the contract:
//   - a tick fires when the down-counter reaches 0; it is then reloaded with
//     the CURRENT segment's cycles_per_tick, so the interval to the next tick
//     is (cycles_per_tick + 1) clocks. AVR-CTC semantics: a new period takes
//     effect on the arriving segment's FIRST tick without stopping the counter.
//   - the port bits emitted at tick k are the ones COMPUTED at tick k-1. Stock
//     writes the port at the top of the ISR from the previous ISR's result, so
//     the pulse for tick k's Bresenham update physically appears at tick k+1.
//     An executor that emits its own tick's result is one tick early on every
//     edge of every trace.
//
// WHY THE TICK IS SPREAD OVER THREE CYCLES, measured not guessed. The obvious
// shape - one tick, one clock, three 32-bit Bresenham lanes - was built first
// and synthesised: nextpnr-ice40 placed it at 11.9 MHz on an iCE40UP5K and
// 30.4 MHz on an HX8K, against a 48 MHz target. The critical path was one
// unbroken chain: q_rd -> FIFO mux -> gen%5 -> block-store mux -> AMASS shift
// -> 32-bit add -> 32-bit compare/subtract.
//
// That whole chain is unnecessary, because nothing it produces is needed until
// the NEXT tick, which is at minimum three clocks away and in practice
// thousands. So it is broken into pieces that each get their own clock:
//
//   PREFETCH (3 clocks, any time the FIFO head is not yet decoded)
//     p1: latch the head's SEG fields (FIFO mux only)
//     p2: gen % 5
//     p3: read the block store, apply the AMASS shift, latch
//   TICK EDGE (1 clock)
//     drive the port registers, load cur_* from the prefetched h_*, reload the
//     tick divider, decrement step_count. All register-to-register.
//   PHASE 1 (tick+1)   sum_i = counter_i + steps_i          one carry chain
//   PHASE 2 (tick+2)   compare/subtract, position, step bits  one carry chain
//
// The cost is a stated minimum: cycles_per_tick MUST be >= 3, i.e. a tick may
// not be shorter than 4 clocks. At 48 MHz that caps the step rate at 12 MHz,
// which is four orders of magnitude above any stepper. A segment that violates
// it FAULTs (SEGX_FAULT_TOO_FAST) rather than silently skipping work - stock
// has no such limit, so this is a declared divergence, and it is checked.

`default_nettype none

module segx_exec #(
  parameter FIFO_DEPTH = 5,      // = W, the credit window (§3.4). Not a knob:
                                 // 5 is what keeps the frozen block-slot
                                 // pigeonhole proof valid and pins committed
                                 // motion to stock's ~50 ms.
  parameter BLK_SLOTS  = 5       // SEGMENT_BUFFER_SIZE - 1
) (
  input  wire        clk,
  input  wire        rst_n,

  // ---- configuration (written by a CFG frame; also carries POS_SET) -------
  input  wire        cfg_we,
  input  wire [2:0]  cfg_step_invert,
  input  wire [2:0]  cfg_dir_invert,
  input  wire [15:0] cfg_pulse_ticks,
  input  wire [15:0] cfg_dir_settle,
  input  wire        cfg_homing,
  input  wire [2:0]  cfg_homing_lock,
  input  wire        cfg_probe_arm,
  input  wire [31:0] cfg_pos0,
  input  wire [31:0] cfg_pos1,
  input  wire [31:0] cfg_pos2,

  input  wire        wake,        // WAKE(epoch): start ticking, forget last blk

  // ---- BLK store write (invariant F1: before the first referencing SEG) ---
  input  wire        blk_we,
  input  wire [7:0]  blk_gen,
  input  wire [31:0] blk_s0,
  input  wire [31:0] blk_s1,
  input  wire [31:0] blk_s2,
  input  wire [31:0] blk_sec,
  input  wire [2:0]  blk_dir,
  input  wire [7:0]  blk_flags,

  // ---- SEG FIFO push -----------------------------------------------------
  input  wire        seg_we,
  input  wire [15:0] seg_nstep,
  input  wire [15:0] seg_cpt,
  input  wire [7:0]  seg_gen,
  input  wire [7:0]  seg_amass,
  input  wire [7:0]  seg_pwm,

  input  wire        probe_pin,   // already $6-corrected by the CFG decoder
  input  wire        link_fault,  // sticky fault raised by the receive path
  input  wire [7:0]  link_fault_code,

  // ---- observation / reverse channel -------------------------------------
  output wire        tick_stb,
  output reg  [15:0] period,
  output reg  [2:0]  step_port,   // latched bits (what the golden trace records)
  output reg  [2:0]  dir_port,
  output wire [2:0]  phy_step,    // physical pin: pulse-gated, $0 wide
  output wire [2:0]  phy_dir,
  output reg  [7:0]  pwm,
  output reg  [31:0] pos0,
  output reg  [31:0] pos1,
  output reg  [31:0] pos2,
  output reg         probe_hit,   // one-cycle pulse, coincident with its tick
  output reg  [31:0] probe_pos0,
  output reg  [31:0] probe_pos1,
  output reg  [31:0] probe_pos2,
  output reg         drained,
  output reg  [7:0]  credit,      // cumulative completed segments (== tail)
  output reg  [7:0]  fault,       // SEGX_FAULT_*, first one wins
  output wire        fifo_full,
  output reg  [15:0] underrun     // work arriving after a drain (see below)
);

  // ---- configuration registers ------------------------------------------
  reg [2:0]  c_step_inv, c_dir_inv, c_homing_lock;
  reg [15:0] c_pulse, c_settle;
  reg        c_homing;

  // ---- block store -------------------------------------------------------
  reg [31:0] b_s0   [0:BLK_SLOTS-1];
  reg [31:0] b_s1   [0:BLK_SLOTS-1];
  reg [31:0] b_s2   [0:BLK_SLOTS-1];
  reg [31:0] b_sec  [0:BLK_SLOTS-1];
  reg [2:0]  b_dir  [0:BLK_SLOTS-1];
  reg [7:0]  b_flg  [0:BLK_SLOTS-1];
  reg [BLK_SLOTS-1:0] b_valid;

  // ---- segment FIFO ------------------------------------------------------
  reg [15:0] q_nstep [0:FIFO_DEPTH-1];
  reg [15:0] q_cpt   [0:FIFO_DEPTH-1];
  reg [7:0]  q_gen   [0:FIFO_DEPTH-1];
  reg [7:0]  q_amass [0:FIFO_DEPTH-1];
  reg [7:0]  q_pwm   [0:FIFO_DEPTH-1];
  reg [2:0]  q_rd, q_wr, q_cnt;

  wire fifo_empty = (q_cnt == 3'd0);
  assign fifo_full = (q_cnt == FIFO_DEPTH[2:0]);

  // ---- prefetched head (everything the tick edge needs, already a register)
  reg [15:0] h_nstep, h_cpt;
  reg [7:0]  h_gen, h_amass, h_pwm;
  reg [2:0]  h_slot, h_dir;
  reg [7:0]  h_flg;
  reg [31:0] h_sec, h_s0, h_s1, h_s2;
  reg        h_blkok;
  reg [1:0]  pf;              // 0 idle, 1 SEG latched, 2 slot latched, 3 valid
  wire       h_valid = (pf == 2'd3);

  wire [2:0] pf_slot;
  segx_slot u_slot_seg (.g(h_gen), .s(pf_slot));

  wire [2:0] blk_slot;
  segx_slot u_slot_blk (.g(blk_gen), .s(blk_slot));

  // ---- executor state ----------------------------------------------------
  reg        run;
  reg        seg_active;
  reg [15:0] tickdiv;
  reg [15:0] step_count;
  reg [31:0] cnt0, cnt1, cnt2;
  reg [31:0] sum0, sum1, sum2;
  reg [31:0] cur_s0, cur_s1, cur_s2, cur_sec;
  reg [2:0]  cur_dir, cur_slot;
  reg [7:0]  cur_gen;
  reg [7:0]  cur_flg;
  reg        have_blk;
  reg [2:0]  step_next, dir_next;
  reg        probe_armed;
  reg [1:0]  ph;              // 0 idle, 1 = add phase, 2 = compare phase

  assign tick_stb = run & (tickdiv == 16'd0) & (fault == 8'd0);

  wire pop       = tick_stb & ~seg_active & h_valid;
  wire drain_now = tick_stb & ~seg_active & ~h_valid & fifo_empty & (pf == 2'd0);


  // A tick that arrives before the pipeline is ready. Only reachable with
  // cycles_per_tick < 3 (or a FIFO head that has not finished decoding, which
  // needs the same), so it is the executor's minimum-period rule made
  // enforceable instead of assumed.
  wire flt_fast  = tick_stb & ((ph != 2'd0) |
                               (~seg_active & ~h_valid & ~drain_now));
  wire flt_nstep0 = pop & (h_nstep == 16'd0);
  wire flt_amass  = pop & (h_amass > 8'd3);
  wire flt_noblk  = pop & ~h_blkok;
  wire [7:0] flt_code = flt_nstep0 ? 8'd1 :      // SEGX_FAULT_NSTEP0
                        flt_amass  ? 8'd6 :      // SEGX_FAULT_AMASS
                        flt_noblk  ? 8'd4 :      // SEGX_FAULT_UNKNOWN_BLK
                        flt_gengap ? 8'd9 :      // SEGX_FAULT_GEN_GAP
                        flt_fast   ? 8'd8 : 8'd0;// SEGX_FAULT_TOO_FAST
  wire flt_any = flt_nstep0 | flt_amass | flt_noblk | flt_fast | flt_gengap;

  // One place decides the occupancy, so a simultaneous push and pop cannot be
  // counted by two different branches of the same always block.
  wire do_push = seg_we & ~fifo_full;
  wire do_pop  = pop & ~flt_any;

  wire [15:0] sc_now  = pop ? h_nstep : step_count;
  wire [15:0] sc_next = sc_now - 16'd1;
  wire        seg_done = (sc_next == 16'd0);

  wire blk_chg = pop & (~have_blk | (h_slot != cur_slot));

  // The wire carries an 8-bit GENERATION, not the host's mod-5 ring index
  // (§3.2), and the reason is exactly this check: generations advance by
  // exactly one per planner block, so a dropped BLK frame shows up as a gap. A
  // ring index cannot express that - 4 -> 0 is indistinguishable from 4 -> 5.
  //
  // Without this the generation field is decorative: `gen % 5` is all the
  // block lookup needs, so an executor that only does the lookup accepts a
  // stream carrying raw slot indices and nobody notices. That is not a
  // hypothetical - it is what this design did until a shipper defect
  // (ship the slot instead of the counter) was injected and the whole corpus
  // still passed.
  wire gen_step_ok = (h_gen == (cur_gen + 8'd1));
  wire flt_gengap  = pop & have_blk & (h_gen != cur_gen) & ~gen_step_ok;

  // Phase 2: compare and subtract. Stock's counters are uint32_t and
  // stepper.c:427 is `>`, not `>=`; both are load-bearing.
  wire hit0 = (sum0 > cur_sec);
  wire hit1 = (sum1 > cur_sec);
  wire hit2 = (sum2 > cur_sec);
  wire [2:0] raw_step = {hit2, hit1, hit0};
  // The homing lock gates the PULSE only, and only AFTER the counter and
  // position update: locked axes keep counting (stepper.c:463-468).
  wire [2:0] lock_step = c_homing ? (raw_step & c_homing_lock) : raw_step;
  wire [2:0] out_step  = lock_step ^ c_step_inv;

  // The probe samples the pin ONCE per tick, BEFORE that tick's Bresenham
  // updates (probe_state_monitor at stepper.c:413 precedes :421). Off by one
  // step if inverted, and one step is exactly what a probe measures. Latching
  // at the tick edge, before phase 2 moves the position, is that ordering.
  wire probe_take = tick_stb & ~drain_now & ~flt_any & probe_armed & probe_pin;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      c_step_inv <= 3'd0; c_dir_inv <= 3'd0; c_homing_lock <= 3'b111;
      c_pulse <= 16'd0; c_settle <= 16'd0; c_homing <= 1'b0;
      q_rd <= 3'd0; q_wr <= 3'd0; q_cnt <= 3'd0;
      b_valid <= {BLK_SLOTS{1'b0}};
      pf <= 2'd0; h_nstep <= 16'd0; h_cpt <= 16'd0; h_gen <= 8'd0;
      h_amass <= 8'd0; h_pwm <= 8'd0; h_slot <= 3'd0; h_dir <= 3'd0;
      h_flg <= 8'd0; h_sec <= 32'd0; h_s0 <= 32'd0; h_s1 <= 32'd0;
      h_s2 <= 32'd0; h_blkok <= 1'b0;
      run <= 1'b0; seg_active <= 1'b0; tickdiv <= 16'd0; ph <= 2'd0;
      step_count <= 16'd0; period <= 16'd0; pwm <= 8'd0;
      cnt0 <= 32'd0; cnt1 <= 32'd0; cnt2 <= 32'd0;
      sum0 <= 32'd0; sum1 <= 32'd0; sum2 <= 32'd0;
      cur_s0 <= 32'd0; cur_s1 <= 32'd0; cur_s2 <= 32'd0; cur_sec <= 32'd0;
      cur_dir <= 3'd0; cur_slot <= 3'd0; cur_flg <= 8'd0; cur_gen <= 8'd0;
      have_blk <= 1'b0;
      step_next <= 3'd0; dir_next <= 3'd0; step_port <= 3'd0; dir_port <= 3'd0;
      pos0 <= 32'd0; pos1 <= 32'd0; pos2 <= 32'd0;
      probe_armed <= 1'b0; probe_hit <= 1'b0;
      probe_pos0 <= 32'd0; probe_pos1 <= 32'd0; probe_pos2 <= 32'd0;
      drained <= 1'b0; credit <= 8'd0; fault <= 8'd0; underrun <= 16'd0;
    end else begin
      probe_hit <= 1'b0;

      if (link_fault && fault == 8'd0) begin
        fault <= link_fault_code;
        run <= 1'b0;
      end

      // ---- CFG ------------------------------------------------------------
      if (cfg_we) begin
        c_step_inv    <= cfg_step_invert;
        c_dir_inv     <= cfg_dir_invert;
        c_pulse       <= cfg_pulse_ticks;
        c_settle      <= cfg_dir_settle;
        c_homing      <= cfg_homing;
        c_homing_lock <= cfg_homing_lock;
        probe_armed   <= cfg_probe_arm;
        pos0 <= cfg_pos0; pos1 <= cfg_pos1; pos2 <= cfg_pos2;
        // Resting port levels ARE the invert masks; stock seeds them in
        // st_wake_up so the first tick cannot pulse.
        step_next <= cfg_step_invert; step_port <= cfg_step_invert;
        dir_next  <= cfg_dir_invert;  dir_port  <= cfg_dir_invert;
      end

      // ---- BLK store write ------------------------------------------------
      if (blk_we) begin
        b_s0[blk_slot]    <= blk_s0;
        b_s1[blk_slot]    <= blk_s1;
        b_s2[blk_slot]    <= blk_s2;
        b_sec[blk_slot]   <= blk_sec;
        b_dir[blk_slot]   <= blk_dir;
        b_flg[blk_slot]   <= blk_flags;
        b_valid[blk_slot] <= 1'b1;
      end

      // ---- SEG FIFO push --------------------------------------------------
      if (seg_we && fifo_full && fault == 8'd0) begin
        fault <= 8'd5; run <= 1'b0;              // SEGX_FAULT_OVERFLOW
      end
      if (do_push) begin
        q_nstep[q_wr] <= seg_nstep;
        q_cpt[q_wr]   <= seg_cpt;
        q_gen[q_wr]   <= seg_gen;
        q_amass[q_wr] <= seg_amass;
        q_pwm[q_wr]   <= seg_pwm;
        q_wr <= (q_wr == FIFO_DEPTH[2:0]-3'd1) ? 3'd0 : q_wr + 3'd1;
      end
      q_cnt <= q_cnt + (do_push ? 3'd1 : 3'd0) - (do_pop ? 3'd1 : 3'd0);

      // UNDERRUN, and the shape of the counter matters. The obvious phrasing -
      // "drained while the FIFO was not empty" - is a guard that CANNOT FIRE:
      // a drain requires the FIFO to be empty by construction. What the
      // executor can observe is the signature of the stutter SEGX/1 §3.5 R1
      // warns about: it ran dry, reported DRAINED, the host saw a spurious
      // cycle-stop - and then more work arrived without an intervening WAKE.
      if (do_push && drained) begin underrun <= underrun + 16'd1; end

      // ---- head prefetch: two clocks, off the tick's critical path ---------
      if (do_pop) begin
        pf <= 2'd0;
      end else begin
        case (pf)
          2'd0: if (!fifo_empty) begin
                  h_nstep <= q_nstep[q_rd];
                  h_cpt   <= q_cpt[q_rd];
                  h_gen   <= q_gen[q_rd];
                  h_amass <= q_amass[q_rd];
                  h_pwm   <= q_pwm[q_rd];
                  pf      <= 2'd1;
                end
          2'd1: begin
                  h_slot <= pf_slot;      // gen % 5 gets its own clock: at 64%
                  pf     <= 2'd2;         // utilisation on an UP5K this net was
                end                       // the critical path, measured
          2'd2: begin
                  h_sec   <= b_sec[h_slot];
                  h_dir   <= b_dir[h_slot];
                  h_flg   <= b_flg[h_slot];
                  h_blkok <= b_valid[h_slot];
                  h_s0    <= b_s0[h_slot] >> h_amass[1:0];
                  h_s1    <= b_s1[h_slot] >> h_amass[1:0];
                  h_s2    <= b_s2[h_slot] >> h_amass[1:0];
                  pf      <= 2'd3;
                end
          default: ;
        endcase
      end

      // ---- WAKE -----------------------------------------------------------
      if (wake) begin
        run <= 1'b1;
        drained <= 1'b0;
        tickdiv <= 16'd0;
        // "the first blk_gen must differ from the reset value so counters
        // initialise on the very first block" (§3.3 reset convention)
        have_blk <= 1'b0;
      end

      // ---- tick edge ------------------------------------------------------
      if (tick_stb) begin
        if (flt_any) begin
          fault <= flt_code;
          run   <= 1'b0;
        end else begin
          // pipeline: this tick's port bits are last tick's computation
          step_port <= step_next;
          dir_port  <= dir_next;
          tickdiv   <= pop ? h_cpt : period;
          period    <= pop ? h_cpt : period;

          if (pop) begin
            seg_active <= 1'b1;
            pwm        <= h_pwm;
            cur_slot   <= h_slot;
            cur_gen    <= h_gen;
            have_blk   <= 1'b1;
            cur_sec    <= h_sec;
            cur_dir    <= h_dir;
            cur_flg    <= h_flg;
            cur_s0     <= h_s0; cur_s1 <= h_s1; cur_s2 <= h_s2;
            dir_next   <= h_dir ^ c_dir_inv;
            q_rd       <= (q_rd == FIFO_DEPTH[2:0]-3'd1) ? 3'd0 : q_rd + 3'd1;
          end

          if (blk_chg) begin
            cnt0 <= h_sec >> 1; cnt1 <= h_sec >> 1; cnt2 <= h_sec >> 1;
          end

          if (drain_now) begin
            drained <= 1'b1;
            run     <= 1'b0;
            // On drain after a pwm-rate-adjusted block the spindle is forced
            // off (stepper.c:402-405). Stock reads this through the never
            // cleared exec_block pointer; here the flag is latched at load, so
            // the same behaviour without the stale/NULL read.
            if (cur_flg[0]) begin pwm <= 8'd0; end
          end else begin
            if (probe_take) begin
              probe_armed <= 1'b0;
              probe_hit   <= 1'b1;
              probe_pos0  <= pos0; probe_pos1 <= pos1; probe_pos2 <= pos2;
            end
            step_count <= sc_next;
            if (seg_done) begin
              seg_active <= 1'b0;
              credit     <= credit + 8'd1;   // credit on COMPLETION (§3.4)
            end
            ph <= 2'd1;
          end
        end
      end else if (run) begin
        tickdiv <= tickdiv - 16'd1;
      end

      // ---- phase 1: accumulate (one carry chain) --------------------------
      if (ph == 2'd1) begin
        sum0 <= cnt0 + cur_s0;
        sum1 <= cnt1 + cur_s1;
        sum2 <= cnt2 + cur_s2;
        ph   <= 2'd2;
      end

      // ---- phase 2: compare, subtract, step, move (one carry chain) -------
      if (ph == 2'd2) begin
        cnt0 <= hit0 ? (sum0 - cur_sec) : sum0;
        cnt1 <= hit1 ? (sum1 - cur_sec) : sum1;
        cnt2 <= hit2 ? (sum2 - cur_sec) : sum2;
        if (hit0) begin pos0 <= cur_dir[0] ? (pos0 - 32'd1) : (pos0 + 32'd1); end
        if (hit1) begin pos1 <= cur_dir[1] ? (pos1 - 32'd1) : (pos1 + 32'd1); end
        if (hit2) begin pos2 <= cur_dir[2] ? (pos2 - 32'd1) : (pos2 + 32'd1); end
        step_next <= out_step;
        ph <= 2'd0;
      end
    end
  end

  // ---- pulse shaper ------------------------------------------------------
  // DIR is driven at the tick edge; the pulse starts c_settle clocks later and
  // lasts c_pulse clocks. Stock has no settle time at all (the AVR writes DIR
  // and STEP a few instructions apart); this is the one place the executor is
  // deliberately BETTER than the thing it replicates, and it is invisible to
  // the golden trace because the trace records the latched bits, not the pin.
  reg [15:0] settle_cnt, pulse_cnt;
  reg        settling, pulsing;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      settle_cnt <= 16'd0; pulse_cnt <= 16'd0;
      settling <= 1'b0; pulsing <= 1'b0;
    end else if (tick_stb && !flt_any) begin
      settling   <= (c_settle != 16'd0);
      settle_cnt <= c_settle - 16'd1;
      pulsing    <= (c_settle == 16'd0);
      pulse_cnt  <= c_pulse - 16'd1;
    end else if (settling) begin
      if (settle_cnt == 16'd0) begin settling <= 1'b0; pulsing <= 1'b1; end
      else settle_cnt <= settle_cnt - 16'd1;
    end else if (pulsing) begin
      if (pulse_cnt == 16'd0) pulsing <= 1'b0;
      else pulse_cnt <= pulse_cnt - 16'd1;
    end
  end

  assign phy_step = pulsing ? step_port : c_step_inv;
  assign phy_dir  = dir_port;

  // silence the unused-slice lint without hiding it in a wildcard
  wire _unused = &{1'b0, cur_flg[7:1], h_flg[7:1], h_amass[7:2], 1'b0};

endmodule

`default_nettype wire
