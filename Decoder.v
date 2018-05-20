module Decoder #(parameter n) (
  input [n-1:0] in,
  output [2**n - 1:0] out
);

assign out = 1'b1 << in;

endmodule
