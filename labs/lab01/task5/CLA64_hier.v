// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.
wire [63:0] p, g;
  wire [15:0] P_blk, G_blk;
  wire [16:0] c_blk;


  assign #2 p = a ^ b;
  assign #2 g = a & b;

  
  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : gen_blk_pg
      assign #2 P_blk[k] = &p[4*k + 3 : 4*k];
      assign #4 G_blk[k] = g[4*k + 3] | 
                           (p[4*k + 3] & g[4*k + 2]) | 
                           (p[4*k + 3] & p[4*k + 2] & g[4*k + 1]) | 
                           (p[4*k + 3] & p[4*k + 2] & p[4*k + 1] & g[4*k]);
    end
  endgenerate

  
  assign c_blk[0] = cin;
  
  genvar m, n;
  generate
    for (m = 0; m < 16; m = m + 1) begin : gen_hier_carries
      wire [m:0] terms;
      for (n = 0; n < m; n = n + 1) begin : gen_hier_p_terms
        assign terms[n] = G_blk[n] & (&P_blk[m : n+1]);
      end
      assign terms[m] = cin & (&P_blk[m : 0]);
      assign #4 c_blk[m+1] = G_blk[m] | (|terms);
    end
  endgenerate

 
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_internal_sum
      wire [2:0] c_int;

      assign #4 c_int[0] = g[4*i] | (p[4*i] & c_blk[i]);
      assign #4 c_int[1] = g[4*i + 1] | (p[4*i + 1] & g[4*i]) | (p[4*i + 1] & p[4*i] & c_blk[i]);
      assign #4 c_int[2] = g[4*i + 2] | (p[4*i + 2] & g[4*i + 1]) | (p[4*i + 2] & p[4*i + 1] & g[4*i]) | (p[4*i + 2] & p[4*i + 1] & p[4*i] & c_blk[i]);

   
      assign #2 sum[4*i]     = p[4*i]     ^ c_blk[i];
      assign #2 sum[4*i + 1] = p[4*i + 1] ^ c_int[0];
      assign #2 sum[4*i + 2] = p[4*i + 2] ^ c_int[1];
      assign #2 sum[4*i + 3] = p[4*i + 3] ^ c_int[2];
    end
  endgenerate

  assign cout = c_blk[16];

endmodule
