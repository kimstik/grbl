// segx_ice40.v - synthesis wrapper: the executor as it would sit on an iCE40.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// Everything that exists only for the testbench is gone here - o_params,
// frames_ok, the position and probe latches are narrowed to what a reverse-
// channel serialiser would actually shift out, and the SPI slave is real
// (mode 0, MSB first, NSS-framed) instead of a byte port.
//
// The point of this file is a NUMBER, not a bitstream: synth.sh runs yosys and
// nextpnr-ice40 and prints measured LUT/FF/carry/BRAM usage and the timing
// estimate at 48 MHz. SEGMENT-RUNTIME-PLAN §4 stage 5 says the UP5K-vs-HX8K
// choice "changes cycle bookkeeping and must be made BEFORE goldens freeze";
// the goldens are frozen, so the number decides whether they stay frozen.
//
// The reverse serialiser is deliberately NOT here: it is not on the critical
// path, it does not affect conformance, and inventing one would inflate the
// utilisation figure with logic nobody has reviewed.

`default_nettype none

module segx_ice40 (
  input  wire        clk_48,      // from the host's MCO: one oscillator, no drift
  input  wire        rst_n,

  // SPI slave, mode 0, MSB first. NSS low frames a byte stream.
  input  wire        spi_nss,
  input  wire        spi_sck,
  input  wire        spi_mosi,

  input  wire        probe_pin_raw,
  input  wire        kill_n,      // §3.5 R5: combinationally gates step output

  output wire [2:0]  step_pin,
  output wire [2:0]  dir_pin,
  output wire        pwm_pin,
  output wire        drained_pin, // event line -> host EXTI
  output wire        fault_pin,
  output wire [7:0]  credit_pin   // parallel here; a serialiser is stage 6
);

  // ---- SPI slave: two-flop synchronise, edge detect, 8-bit shift ---------
  reg [2:0] sck_s, nss_s;
  reg [1:0] mosi_s;
  always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin sck_s <= 3'd0; nss_s <= 3'b111; mosi_s <= 2'd0; end
    else begin
      sck_s  <= {sck_s[1:0], spi_sck};
      nss_s  <= {nss_s[1:0], spi_nss};
      mosi_s <= {mosi_s[0], spi_mosi};
    end
  end
  wire sck_rise = (sck_s[2:1] == 2'b01);
  wire nss_active = ~nss_s[2];

  reg [7:0] sh;
  reg [2:0] bitn;
  reg       rx_valid;
  reg [7:0] rx_byte;
  always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin sh <= 8'd0; bitn <= 3'd0; rx_valid <= 1'b0; rx_byte <= 8'd0; end
    else begin
      rx_valid <= 1'b0;
      if (!nss_active) begin
        bitn <= 3'd0;
      end else if (sck_rise) begin
        sh   <= {sh[6:0], mosi_s[1]};
        bitn <= bitn + 3'd1;
        if (bitn == 3'd7) begin
          rx_byte  <= {sh[6:0], mosi_s[1]};
          rx_valid <= 1'b1;
        end
      end
    end
  end

  wire [2:0]  phy_step, phy_dir;
  wire [7:0]  pwm;
  wire        drained, tick_stb;
  wire [7:0]  fault;
  wire [31:0] pos0, pos1, pos2, pp0, pp1, pp2;
  wire [15:0] period, underrun, frames_ok;
  wire [2:0]  step_port, dir_port;
  wire        probe_hit;
  wire [31:0] o_params;

  segx_top u_top (
    .clk(clk_48), .rst_n(rst_n),
    .rx_valid(rx_valid), .rx_byte(rx_byte),
    .probe_pin_raw(probe_pin_raw),
    .cfg_dir_settle(16'd8),        // 167 ns at 48 MHz; stock has none at all
    .tick_stb(tick_stb), .period(period),
    .step_port(step_port), .dir_port(dir_port),
    .phy_step(phy_step), .phy_dir(phy_dir), .pwm(pwm),
    .pos0(pos0), .pos1(pos1), .pos2(pos2),
    .probe_hit(probe_hit), .probe_pos0(pp0), .probe_pos1(pp1), .probe_pos2(pp2),
    .drained(drained), .credit(credit_pin), .fault(fault),
    .underrun(underrun), .frames_ok(frames_ok), .o_params(o_params)
  );

  // KILL is combinational on purpose (§3.5 R5): a hard-limit or reset must stop
  // the pins within gate delays, not within a mailbox round trip. It gates the
  // OUTPUT, never the state, so position stays whatever the last tick made it -
  // which stock also declares lost after a hard-limit kill.
  assign step_pin = kill_n ? phy_step : 3'd0;
  assign dir_pin  = phy_dir;

  // Placeholder PWM: one comparator against a free-running 8-bit ramp. Real
  // laser work wants the $30/$31 scaling and inversion; out of scope here, and
  // stated so the utilisation number is not read as covering it.
  reg [7:0] ramp;
  always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) ramp <= 8'd0; else ramp <= ramp + 8'd1;
  end
  assign pwm_pin = (pwm != 8'd0) && (ramp < pwm);

  assign drained_pin = drained;
  assign fault_pin   = (fault != 8'd0);

  wire _unused = &{1'b0, tick_stb, period, step_port, dir_port, probe_hit,
                   pos0, pos1, pos2, pp0, pp1, pp2, underrun, frames_ok,
                   o_params, 1'b0};

endmodule

`default_nettype wire
