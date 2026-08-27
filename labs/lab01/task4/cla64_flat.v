module cla64_flat(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [63:0] p, g;
  wire [64:0] c;

  // Propagate and Generate (#2 delay)
  assign #2 p = a ^ b;
  assign #2 g = a & b;
  assign c[0] = cin;

  // 64 parallel two-level carry equations (#4 delay)
  genvar i, j;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_c
      wire [i:0] terms;
      for (j = 0; j < i; j = j + 1) begin : gen_terms
        assign terms[j] = g[j] & (&p[i:j+1]);
      end
      assign terms[i] = cin & (&p[i:0]);
      assign #4 c[i+1] = g[i] | (|terms);
    end
  endgenerate

  // Sum equations (#2 delay)
  assign #2 sum = p ^ c[63:0];
  assign cout = c[64];

endmodule
