module Mux8 #(parameter width=16) (
  input SEL,
  input [width-1:0] I0,
  input [width-1:0] I1,
  input [width-1:0] I2,
  input [width-1:0] I3,
  input [width-1:0] I4,
  input [width-1:0] I5,
  input [width-1:0] I6,
  input [width-1:0] I7,
  output [width-1:0] OUT
);

reg [width-1:0] out;

always @(*) begin
  case (SEL) 
    0: out <= I0;
    1: out <= I1;
    2: out <= I2;
    3: out <= I3;
    4: out <= I4;
    5: out <= I5;
    6: out <= I6;
    7: out <= I7;
  endcase
end

assign OUT = out;

endmodule