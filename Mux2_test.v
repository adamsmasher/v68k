module Mux2_test (output TEST);

assign TEST = 1;

reg [15:0] a = 16'h0123;
reg [15:0] b = 16'hFEDC;

reg sel;

wire [15:0] out;

Mux2 mux(sel, a, b, out);

initial begin
  sel <= 0;
  #1 if (out !== 16'h0123) begin
    $stop;
  end
  sel <= 1;
  #1 if (out !== 16'hFEDC) begin
    $stop;
  end
end

endmodule