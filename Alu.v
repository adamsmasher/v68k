module Alu #(parameter bits=16) (
  input [bits-1:0] A,
  input [bits-1:0] B,
  output [bits-1:0] O,
  input [2:0] op,
  input X,
  output C,
  output Z,
  output V,
  output N
);

localparam ADD = 3'b000;
localparam SUB = 3'b001;
localparam AND = 3'b010;
localparam OR  = 3'b011;
localparam XOR = 3'b100;
// TODO: further cases

// one extra bit for carry
reg [bits:0] result;

always @(*) begin
  case(op)
    ADD: result <= A + B + X;
    SUB: result <= A - B - X;
    AND: result <= A & B;
    OR: result <= A | B;
    XOR: result <= A ^ B;
    default: result <= A; // TODO: ???
  endcase
end

assign O = result[bits-1:0];
assign C = result[bits];
assign Z = ~|O;
assign V = (A[bits-1] == B[bits-1]) && (B[bits-1] != O[bits-1]);
assign N = O[bits-1];

endmodule