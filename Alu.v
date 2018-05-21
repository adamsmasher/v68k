module Alu #(parameter bits=16) (
  input CLK,
  input [bits-1:0] A,
  input [bits-1:0] B,
  output [bits-1:0] O,
  output C,
  output Z,
  output V,
  output N
);

// one extra bit for carry
reg [bits:0] result;

always @(posedge CLK) begin
  result <= A + B;
end

assign O = result[bits-1:0];
assign C = result[bits];
assign Z = ~|O;
assign V = (A[bits-1] == B[bits-1]) && (B[bits-1] != O[bits-1]);
assign N = O[bits-1];

endmodule