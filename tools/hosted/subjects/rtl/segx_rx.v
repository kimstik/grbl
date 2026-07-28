// segx_rx.v - SEGX/1 Profile F receive path: byte stream -> decoded frames.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// Mirrors grbl/platform/extensions/common/segwire.h. Those constants are
// exported on o_params and the testbench compares them against the C header's
// values, so the two definitions cannot drift apart silently.
//
//   SOF TAG LEN PAYLOAD[LEN] CRC8      CRC over TAG, LEN, PAYLOAD
//
// The frame boundary is the validity strobe. That is the entire answer to the
// missing barrier at stepper.c's publish store: on a framed link there is no
// window in which payload and strobe can be reordered, because the strobe IS
// the last byte of the payload. Nothing downstream of here ever sees a
// half-written segment.
//
// The receiver is deliberately a counter and a shift register, not a state
// machine over a payload buffer: SOF is not byte-stuffed, so every frame's
// length is known from LEN and resynchronisation is by CRC rejection.

`default_nettype none

module segx_rx (
  input  wire        clk,
  input  wire        rst_n,

  input  wire        rx_valid,
  input  wire [7:0]  rx_byte,

  output reg         cfg_we,
  output reg  [2:0]  cfg_step_invert,
  output reg  [2:0]  cfg_dir_invert,
  output reg  [15:0] cfg_pulse_ticks,
  output reg         cfg_homing,
  output reg  [2:0]  cfg_homing_lock,
  output reg         cfg_probe_arm,
  output reg         cfg_probe_invert,
  output reg  [31:0] cfg_pos0,
  output reg  [31:0] cfg_pos1,
  output reg  [31:0] cfg_pos2,

  output reg         wake,
  output reg  [7:0]  wake_epoch,

  output reg         blk_we,
  output reg  [7:0]  blk_gen,
  output reg  [31:0] blk_s0,
  output reg  [31:0] blk_s1,
  output reg  [31:0] blk_s2,
  output reg  [31:0] blk_sec,
  output reg  [2:0]  blk_dir,
  output reg  [7:0]  blk_flags,

  output reg         seg_we,
  output reg  [15:0] seg_nstep,
  output reg  [15:0] seg_cpt,
  output reg  [7:0]  seg_gen,
  output reg  [7:0]  seg_amass,
  output reg  [7:0]  seg_pwm,

  output reg         fault,
  output reg  [7:0]  fault_code,
  output reg  [15:0] frames_ok,

  output wire [31:0] o_params    // {TAG_CFG, TAG_BLK, TAG_SEG, SOF}
);

  localparam [7:0] SOF     = 8'ha5;
  localparam [7:0] TAG_SEG = 8'h01;
  localparam [7:0] TAG_BLK = 8'h02;
  localparam [7:0] TAG_CFG = 8'h03;
  localparam [7:0] TAG_WAKE= 8'h04;
  localparam [7:0] MAXLEN  = 8'd19;

  localparam [1:0] S_SOF = 2'd0, S_TAG = 2'd1, S_LEN = 2'd2, S_PAY = 2'd3;

  assign o_params = {TAG_CFG, TAG_BLK, TAG_SEG, SOF};

  reg [1:0] st;
  reg [7:0] tag, len, idx, crc;
  reg [7:0] pay [0:19];          // MAXLEN payload + the CRC byte position
  reg [7:0] seq_next;
  reg       seq_primed;

  // One combinational CRC unit, fed the running remainder and the byte on the
  // wire. Every state that consumes a byte uses the same result.
  wire [7:0] crc_next;
  segx_crc8 u_crc (.c(crc), .d(rx_byte), .q(crc_next));

  integer j;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_SOF; tag <= 8'd0; len <= 8'd0; idx <= 8'd0; crc <= 8'd0;
      cfg_we <= 1'b0; blk_we <= 1'b0; seg_we <= 1'b0; wake <= 1'b0;
      fault <= 1'b0; fault_code <= 8'd0; frames_ok <= 16'd0;
      seq_next <= 8'd0; seq_primed <= 1'b0;
      cfg_step_invert <= 3'd0; cfg_dir_invert <= 3'd0;
      cfg_pulse_ticks <= 16'd0; cfg_homing <= 1'b0; cfg_homing_lock <= 3'b111;
      cfg_probe_arm <= 1'b0; cfg_probe_invert <= 1'b0;
      cfg_pos0 <= 32'd0; cfg_pos1 <= 32'd0; cfg_pos2 <= 32'd0;
      wake_epoch <= 8'd0;
      blk_gen <= 8'd0; blk_s0 <= 32'd0; blk_s1 <= 32'd0; blk_s2 <= 32'd0;
      blk_sec <= 32'd0; blk_dir <= 3'd0; blk_flags <= 8'd0;
      seg_nstep <= 16'd0; seg_cpt <= 16'd0; seg_gen <= 8'd0;
      seg_amass <= 8'd0; seg_pwm <= 8'd0;
      for (j = 0; j <= 19; j = j + 1) pay[j] <= 8'd0;
    end else begin
      cfg_we <= 1'b0; blk_we <= 1'b0; seg_we <= 1'b0; wake <= 1'b0;

      if (rx_valid && !fault) begin
        case (st)
          S_SOF: if (rx_byte == SOF) begin crc <= 8'd0; st <= S_TAG; end
          S_TAG: begin
            tag <= rx_byte;
            crc <= crc_next;   // crc is 0 here: S_SOF cleared it
            st  <= S_LEN;
          end
          S_LEN: begin
            if (rx_byte > MAXLEN) begin
              fault <= 1'b1; fault_code <= 8'd7;   // SEGX_FAULT_BAD_TAG
            end else begin
              len <= rx_byte;
              crc <= crc_next;
              idx <= 8'd0;
              st  <= S_PAY;
            end
          end
          S_PAY: begin
            if (idx < len) begin
              pay[idx[4:0]] <= rx_byte;
              crc <= crc_next;
              idx <= idx + 8'd1;
            end else begin
              // trailing CRC byte: the frame is valid iff it matches
              st <= S_SOF;
              if (rx_byte != crc) begin
                fault <= 1'b1; fault_code <= 8'd2;  // SEGX_FAULT_CRC
              end else begin
                frames_ok <= frames_ok + 16'd1;
                case (tag)
                  TAG_SEG: begin
                    if (seq_primed && pay[7] != seq_next) begin
                      fault <= 1'b1; fault_code <= 8'd3; // SEGX_FAULT_SEQ_GAP
                    end else begin
                      seq_primed <= 1'b1;
                      seq_next   <= pay[7] + 8'd1;
                      seg_nstep  <= {pay[1], pay[0]};
                      seg_cpt    <= {pay[3], pay[2]};
                      seg_gen    <= pay[4];
                      seg_amass  <= pay[5];
                      seg_pwm    <= pay[6];
                      seg_we     <= 1'b1;
                    end
                  end
                  TAG_BLK: begin
                    blk_gen   <= pay[0];
                    blk_s0    <= {pay[4],  pay[3],  pay[2],  pay[1]};
                    blk_s1    <= {pay[8],  pay[7],  pay[6],  pay[5]};
                    blk_s2    <= {pay[12], pay[11], pay[10], pay[9]};
                    blk_sec   <= {pay[16], pay[15], pay[14], pay[13]};
                    blk_dir   <= pay[17][2:0];
                    blk_flags <= pay[18];
                    blk_we    <= 1'b1;
                  end
                  TAG_CFG: begin
                    cfg_step_invert  <= pay[0][2:0];
                    cfg_dir_invert   <= pay[1][2:0];
                    cfg_pulse_ticks  <= {pay[3], pay[2]};
                    cfg_homing       <= pay[4][0];
                    cfg_probe_arm    <= pay[4][1];
                    cfg_homing_lock  <= pay[5][2:0];
                    cfg_probe_invert <= pay[6][0];
                    cfg_pos0 <= {pay[10], pay[9],  pay[8],  pay[7]};
                    cfg_pos1 <= {pay[14], pay[13], pay[12], pay[11]};
                    cfg_pos2 <= {pay[18], pay[17], pay[16], pay[15]};
                    cfg_we   <= 1'b1;
                  end
                  TAG_WAKE: begin
                    wake_epoch <= pay[0];
                    wake       <= 1'b1;
                    seq_primed <= 1'b0;   // epoch rule: seq restarts at WAKE
                  end
                  default: begin
                    fault <= 1'b1; fault_code <= 8'd7; // SEGX_FAULT_BAD_TAG
                  end
                endcase
              end
            end
          end
        endcase
      end
    end
  end

endmodule

`default_nettype wire
