module DataRegisterFile_test (output TEST);

assign TEST = 1;

reg clk;

reg [2:0] reg_sel_a;
reg [2:0] reg_sel_b;
reg s;
reg [31:0] d;
wire [31:0] q_a;
wire [31:0] q_b;

DataRegisterFile ds(clk, reg_sel_a, reg_sel_b, s, d, q_a, q_b);

always begin
  clk = 0; #5
  clk = 1; #5;
end

initial begin
  // we can set via line B
  reg_sel_a <= 0;
  reg_sel_b <= 3;
  s <= 1;
  d <= 32'hF00FF00F;
  #10; // wait til next clock cycle to write
  // we can read via line B, too - and reading is "instant"
  s <= 0;
  #1 if (q_b !== 32'hF00FF00F) begin
    $display("Reading from line B, got %h, expected FOOFFOOF", q_b);
    $stop;
  end
  // we can also read via line A
  reg_sel_a <= 3;
  #1 if (q_a !== 32'hF00FF00F) begin
    $display("Reading from line A, got %h, expected FOOFFOOF", q_a);
    $stop;
  end
  // we can't set via line A!
  reg_sel_b <= 0;
  s <= 1;
  d <= 32'hDADADADA;
  #10 if (q_a !== 32'hF00FF00F) begin
    $display("Reading from line A, got %h, expected FOOFFOOF", q_a);
    $stop;
  end
end

endmodule