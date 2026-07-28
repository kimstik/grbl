// segx_crc8.v - one byte of CRC-8/ATM (poly 0x07, init 0x00), combinational.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// Must agree bit for bit with segx_crc8_byte() in
// grbl/platform/extensions/common/segwire.h, or the link rejects every frame
// the host sends. That is not left to inspection: the testbench Verilates this
// module on its own and checks all 65536 (crc, byte) pairs against the C
// function. Same reasoning as segx_slot.v - the checkable pieces are modules.

`default_nettype none

module segx_crc8 (
  input  wire [7:0] c,
  input  wire [7:0] d,
  output wire [7:0] q
);
  // Eight named stages rather than an unpacked array: Verilator cannot prove an
  // array of wires is acyclic and reports the XOR tree as combinational loop.
  wire [7:0] s0 = c ^ d;
  wire [7:0] s1 = s0[7] ? ({s0[6:0], 1'b0} ^ 8'h07) : {s0[6:0], 1'b0};
  wire [7:0] s2 = s1[7] ? ({s1[6:0], 1'b0} ^ 8'h07) : {s1[6:0], 1'b0};
  wire [7:0] s3 = s2[7] ? ({s2[6:0], 1'b0} ^ 8'h07) : {s2[6:0], 1'b0};
  wire [7:0] s4 = s3[7] ? ({s3[6:0], 1'b0} ^ 8'h07) : {s3[6:0], 1'b0};
  wire [7:0] s5 = s4[7] ? ({s4[6:0], 1'b0} ^ 8'h07) : {s4[6:0], 1'b0};
  wire [7:0] s6 = s5[7] ? ({s5[6:0], 1'b0} ^ 8'h07) : {s5[6:0], 1'b0};
  wire [7:0] s7 = s6[7] ? ({s6[6:0], 1'b0} ^ 8'h07) : {s6[6:0], 1'b0};
  assign q      = s7[7] ? ({s7[6:0], 1'b0} ^ 8'h07) : {s7[6:0], 1'b0};
endmodule

`default_nettype wire
