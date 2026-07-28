// segx_slot.v - blk_gen -> block-store slot, = gen % 5, without a divider.
//
// Part of Grbl / Intelligence assisted / License: MIT
//
// SEGX/1 puts an 8-bit generation counter on the wire rather than the host's
// mod-5 ring index (§3.2), precisely so a wrap is detectable. The executor
// still has to land it in one of SEGMENT_BUFFER_SIZE-1 = 5 block slots, and
// SEGX_GEN_TO_SLOT in segframe.h is `gen % 5`.
//
// 16 == 1 (mod 5), so folding the nibbles preserves the residue. Twice gets the
// value to <= 16, then at most three subtractions finish it. No divider, one
// LUT level.
//
// This is a separate module for one reason: it is the only piece of
// non-obvious arithmetic in the executor, and as a module the testbench can
// Verilate it alone and check all 256 inputs against C's `%`. A function
// buried in an always block could not be checked that way, and "it looked
// right" is how this project has shipped guards that could not fire.

`default_nettype none

module segx_slot (
  input  wire [7:0] g,
  output wire [2:0] s
);
  wire [4:0] a = {1'b0, g[7:4]} + {1'b0, g[3:0]};          // <= 30
  wire [4:0] b = a[4] ? ({1'b0, a[3:0]} + 5'd1) : a;       // <= 16, same residue
  assign s = (b >= 5'd15) ? (b[2:0] - 3'd7) :              // b in {15,16}
             (b >= 5'd10) ? (b[2:0] - 3'd2) :
             (b >= 5'd5)  ? (b[2:0] - 3'd5) : b[2:0];
endmodule

`default_nettype wire
