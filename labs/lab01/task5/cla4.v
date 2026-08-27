// cla4.v
// Gate-level 4-bit carry-lookahead adder, matching the lecture circuit.
// Every gate needs an explicit delay (constant is fine here, e.g. #(2)) --
// this is the default from Task 2 onward, not a special step.
//
// TODO -- Step 1: generate/propagate signals (one xor + one and per bit)
//   p[i] = a[i] ^ b[i]
//   g[i] = a[i] & b[i]
//
// TODO -- Step 2: direct (non-recursive) carry equations. Verilog's and/or
// primitives accept more than 2 inputs directly, e.g.:
//   and #(2) (t2, p1, p0, g0);
// so you do not need to manually chain 2-input gates.
//   c1 = g0 + p0.cin
//   c2 = g1 + p1.g0 + p1.p0.cin
//   c3 = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
//   c4 = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0 + p3.p2.p1.p0.cin
//
// TODO -- Step 3: sum bits
//   sum[i] = p[i] ^ c[i]     (c0 = cin)

module cla4(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout
);

  
  wire [3:0] p;
  wire [3:0] g;
  wire c1, c2, c3;


  xor #(2) xp0 (p[0], a[0], b[0]);
  xor #(2) xp1 (p[1], a[1], b[1]);
  xor #(2) xp2 (p[2], a[2], b[2]);
  xor #(2) xp3 (p[3], a[3], b[3]);

  and #(2) ag0 (g[0], a[0], b[0]);
  and #(2) ag1 (g[1], a[1], b[1]);
  and #(2) ag2 (g[2], a[2], b[2]);
  and #(2) ag3 (g[3], a[3], b[3]);

  
  wire p0_cin;
  and #(2) a_c1_0 (p0_cin, p[0], cin);
  or  #(2) o_c1   (c1, g[0], p0_cin);

  
  wire p1_g0, p1_p0_cin;
  and #(2) a_c2_0 (p1_g0, p[1], g[0]);
  and #(2) a_c2_1 (p1_p0_cin, p[1], p[0], cin);
  or  #(2) o_c2   (c2, g[1], p1_g0, p1_p0_cin);

  wire p2_g1, p2_p1_g0, p2_p1_p0_cin;
  and #(2) a_c3_0 (p2_g1, p[2], g[1]);
  and #(2) a_c3_1 (p2_p1_g0, p[2], p[1], g[0]);
  and #(2) a_c3_2 (p2_p1_p0_cin, p[2], p[1], p[0], cin);
  or  #(2) o_c3   (c3, g[2], p2_g1, p2_p1_g0, p2_p1_p0_cin);

  
  wire p3_g2, p3_p2_g1, p3_p2_p1_g0, p3_p2_p1_p0_cin;
  and #(2) a_c4_0 (p3_g2, p[3], g[2]);
  and #(2) a_c4_1 (p3_p2_g1, p[3], p[2], g[1]);
  and #(2) a_c4_2 (p3_p2_p1_g0, p[3], p[2], p[1], g[0]);
  and #(2) a_c4_3 (p3_p2_p1_p0_cin, p[3], p[2], p[1], p[0], cin);
  or  #(2) o_c4   (cout, g[3], p3_g2, p3_p2_g1, p3_p2_p1_g0, p3_p2_p1_p0_cin);

 
  xor #(2) xs0 (sum[0], p[0], cin);
  xor #(2) xs1 (sum[1], p[1], c1);
  xor #(2) xs2 (sum[2], p[2], c2);
  xor #(2) xs3 (sum[3], p[3], c3);

endmodule