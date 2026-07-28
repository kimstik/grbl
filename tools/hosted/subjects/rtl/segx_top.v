// segx_top.v - SEGX/1 Profile F executor: link bytes in, step/dir pins out.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// The only thing crossing the left edge is a byte stream (what a SPI slave
// hands over) and the probe pin. The only things crossing the right edge are
// the step/dir/pwm pins and the reverse-channel state (credit, position,
// events, fault). There is no shared memory, no pointer, and no barrier to get
// wrong - which is the point of Profile F.
//
// The reverse SERIALISER is not in this module. The reverse channel's contents
// are exposed as ports and read directly by the testbench; turning them into
// frames on a return wire is stage 4/6 work on the host side and adds nothing
// to executor correctness. Stated plainly because it is the one place this
// prototype stops short of a complete link.

`default_nettype none

module segx_top #(
  parameter FIFO_DEPTH = 5,
  parameter BLK_SLOTS  = 5
) (
  input  wire        clk,
  input  wire        rst_n,

  input  wire        rx_valid,
  input  wire [7:0]  rx_byte,
  input  wire        probe_pin_raw,
  input  wire [15:0] cfg_dir_settle,   // board constant, not a wire field

  output wire        tick_stb,
  output wire [15:0] period,
  output wire [2:0]  step_port,
  output wire [2:0]  dir_port,
  output wire [2:0]  phy_step,
  output wire [2:0]  phy_dir,
  output wire [7:0]  pwm,
  output wire [31:0] pos0,
  output wire [31:0] pos1,
  output wire [31:0] pos2,
  output wire        probe_hit,
  output wire [31:0] probe_pos0,
  output wire [31:0] probe_pos1,
  output wire [31:0] probe_pos2,
  output wire        drained,
  output wire [7:0]  credit,
  output wire [7:0]  fault,
  output wire [15:0] underrun,
  output wire [15:0] frames_ok,
  output wire [31:0] o_params
);

  wire        cfg_we, wake, blk_we, seg_we;
  wire [2:0]  cfg_step_invert, cfg_dir_invert, cfg_homing_lock;
  wire [15:0] cfg_pulse_ticks;
  wire        cfg_homing, cfg_probe_arm, cfg_probe_invert;
  wire [31:0] cfg_pos0, cfg_pos1, cfg_pos2;
  wire [7:0]  wake_epoch;
  wire [7:0]  blk_gen, blk_flags;
  wire [31:0] blk_s0, blk_s1, blk_s2, blk_sec;
  wire [2:0]  blk_dir;
  wire [15:0] seg_nstep, seg_cpt;
  wire [7:0]  seg_gen, seg_amass, seg_pwm;
  wire        fifo_full_unused;
  wire        rx_fault;
  wire [7:0]  rx_fault_code;

  segx_rx u_rx (
    .clk(clk), .rst_n(rst_n),
    .rx_valid(rx_valid), .rx_byte(rx_byte),
    .cfg_we(cfg_we),
    .cfg_step_invert(cfg_step_invert), .cfg_dir_invert(cfg_dir_invert),
    .cfg_pulse_ticks(cfg_pulse_ticks),
    .cfg_homing(cfg_homing), .cfg_homing_lock(cfg_homing_lock),
    .cfg_probe_arm(cfg_probe_arm), .cfg_probe_invert(cfg_probe_invert),
    .cfg_pos0(cfg_pos0), .cfg_pos1(cfg_pos1), .cfg_pos2(cfg_pos2),
    .wake(wake), .wake_epoch(wake_epoch),
    .blk_we(blk_we), .blk_gen(blk_gen),
    .blk_s0(blk_s0), .blk_s1(blk_s1), .blk_s2(blk_s2), .blk_sec(blk_sec),
    .blk_dir(blk_dir), .blk_flags(blk_flags),
    .seg_we(seg_we), .seg_nstep(seg_nstep), .seg_cpt(seg_cpt),
    .seg_gen(seg_gen), .seg_amass(seg_amass), .seg_pwm(seg_pwm),
    .fault(rx_fault), .fault_code(rx_fault_code), .frames_ok(frames_ok),
    .o_params(o_params)
  );

  // $6 lives executor-side: the probe pin physically terminates here (§3.5 R4).
  wire probe_pin = probe_pin_raw ^ cfg_probe_invert;

  segx_exec #(.FIFO_DEPTH(FIFO_DEPTH), .BLK_SLOTS(BLK_SLOTS)) u_exec (
    .clk(clk), .rst_n(rst_n),
    .cfg_we(cfg_we),
    .cfg_step_invert(cfg_step_invert), .cfg_dir_invert(cfg_dir_invert),
    .cfg_pulse_ticks(cfg_pulse_ticks), .cfg_dir_settle(cfg_dir_settle),
    .cfg_homing(cfg_homing), .cfg_homing_lock(cfg_homing_lock),
    .cfg_probe_arm(cfg_probe_arm),
    .cfg_pos0(cfg_pos0), .cfg_pos1(cfg_pos1), .cfg_pos2(cfg_pos2),
    .wake(wake),
    .blk_we(blk_we), .blk_gen(blk_gen),
    .blk_s0(blk_s0), .blk_s1(blk_s1), .blk_s2(blk_s2), .blk_sec(blk_sec),
    .blk_dir(blk_dir), .blk_flags(blk_flags),
    .seg_we(seg_we), .seg_nstep(seg_nstep), .seg_cpt(seg_cpt),
    .seg_gen(seg_gen), .seg_amass(seg_amass), .seg_pwm(seg_pwm),
    .probe_pin(probe_pin),
    .link_fault(rx_fault), .link_fault_code(rx_fault_code),
    .tick_stb(tick_stb), .period(period),
    .step_port(step_port), .dir_port(dir_port),
    .phy_step(phy_step), .phy_dir(phy_dir), .pwm(pwm),
    .pos0(pos0), .pos1(pos1), .pos2(pos2),
    .probe_hit(probe_hit),
    .probe_pos0(probe_pos0), .probe_pos1(probe_pos1), .probe_pos2(probe_pos2),
    .drained(drained), .credit(credit), .fault(fault),
    .fifo_full(fifo_full_unused), .underrun(underrun)
  );

  wire _unused = &{1'b0, wake_epoch, fifo_full_unused, 1'b0};

endmodule

`default_nettype wire
