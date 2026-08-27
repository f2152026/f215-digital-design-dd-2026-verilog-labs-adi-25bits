module dut(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  
  cla64_blocked u_blocked (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

endmodule