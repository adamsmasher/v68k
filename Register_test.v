module Register_test (output TEST);

reg en_a;
reg en_b;
reg s;
reg [3:0] d;
wire [3:0] q_a;
wire [3:0] q_b;

assign TEST = 1;

Register #(4) register(en_a, en_b, s, d, q_a, q_b);

initial begin
  // if the register is not enabled, it should float
  en_a <= 0;
  en_b <= 0;
  s <= 0; 
  #10 if (q_a !== 4'bzzzz || q_b !== 4'bzzzz) begin
    $display("ASSERTION FAILED: q_a = %b, q_b = %b, expected floating", q_a, q_b);
    $stop;
  end
  // we can set the contents of the register by enabling b and s
  en_a <= 0;
  en_b <= 1;
  s <= 1;
  d <= 4'b1010;
  #10
  // if only a is enabled, we should see output on a and b should float
  en_a <= 1;
  en_b <= 0;
  s <= 0;
  #10 if (q_a !== 4'b1010 && q_b !== 4'bzzzz) begin
    $display("ASSERTION FAILED: q_a = %b, q_b = %b, expected q_a = 1010, q_b floating", q_a, q_b);
    $stop;
  end
  // if only b is enabled, we should see output on b and a should float
  en_a <= 0;
  en_b <= 1;
  s <= 0;
  #10 if (q_a !== 4'bzzzz && q_b !== 4'b1010) begin
    $display("ASSERTION FAILED: q_a = %b, q_b = %b, expected q_a floating, q_b = ", q_a, q_b);
    $stop;
  end
  // if s is enabled but b is not enabled, we see no writes
  en_a <= 1;
  en_b <= 0;
  s <= 1;
  d <= 4'b1111;
  #10 if(q_a !== 4'b1010) begin
    $display("ASSERTION FAILED: q_a = %b, expected 1010", q_a);
    $stop;
  end
end

endmodule