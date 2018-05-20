module Mux4 #(parameter width=16) (
  input SEL,
  input [width-1:0] I0,
  input [width-1:0] I1,
  input [width-1:0] I2,
  input [width-1:0] I3,
  output [width-1:0] OUT
);

reg [width-1:0] out;

always @(*) begin
  case (SEL) 
    0: out <= I0;
    1: out <= I1;
    2: out <= I2;
    3: out <= I3;
  endcase
end

assign OUT = out;

endmodule