module V68k_test(output TEST);

reg reset = 1;
reg halt = 1;
reg clk = 0;

assign TEST = 1;

V68k cpu(reset, halt, clk);

always begin
  clk = 0; #5
  clk = 1; #5;
end

initial begin
  #10 
  reset <= 0;
end
  

endmodule