module Mux2 #(parameter width=16) (
  input SEL,
  input [width-1:0] I0,
  input [width-1:0] I1,
  output [width-1:0] OUT
);

assign OUT = SEL == 0 ? I0 : I1;

endmodule