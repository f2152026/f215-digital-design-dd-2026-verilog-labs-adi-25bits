module dut(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // Option 1: 64-bit Ripple-Carry Adder
  // rca64 u_rca (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  // Option 2: 64-bit Flat CLA
  // cla64_flat u_flat (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  // Option 3: 64-bit Blocked CLA (16 x 4-bit)
  cla64_blocked u_blocked (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

endmodule