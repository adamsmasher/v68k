module V68k_test(output TEST);

reg reset = 1;
reg halt = 1;
reg clk = 0;

assign TEST = 1;

wire [23:1] a;
wire uds;
wire lds;
wire as;

wire [15:0] d;

V68k cpu(reset, halt, clk, a, uds, lds, as, d);

always begin
  clk = 0; #5
  clk = 1; #5;
end

initial begin
  #10 
  reset <= 0;
end

always @(posedge clk) begin
  $display(d);
end
  

endmodule
