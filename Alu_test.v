module Alu_test(output TEST);

parameter bits = 16;

reg clk;
reg [bits-1:0] a;
reg [bits-1:0] b;
wire [bits-1:0] o;
wire c;
wire z;
wire v;
wire n;

assign TEST = 1;

Alu #(bits) alu(clk, a, b, o, c, z, v, n);

always begin
  clk <= 0; #5
  clk <= 1; #5
  ;
end

initial begin
  // zero
  a <= 0; 
  b <= 0;
  #10 if (o !== 0) begin
    $display("Adding 0 + 0, got %H, expected 0", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive, no overflow or carry
  a <= 16'h010F;
  b <= 16'h010F; 
  #10 if (o !== 16'h021E) begin
    $display("Adding 010F + 010F, got %H, expected 021E", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive, overflow no carry
  a <= 16'h7FFF;
  b <= 16'h0001;
  #10 if (o !== 16'h8000) begin
    $display("Adding 7FFF + 0001, got %H, expected 8000", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive (unsigned), carry
  // (a.k.a positive + negative)
  a <= 16'hFFFF;
  b <= 16'h0001;
  #10 if (o !== 0) begin
    $display("Adding FFFF + 0001, got %H, expected 0", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // negative + negative, no overflow
  a <= 16'hFFFF;
  b <= 16'hFFFF;
  #10 if (o !== 16'hFFFE) begin
    $display("Adding FFFF + FFFF, got %H, expected FFFE", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // negative + negative, overflow
  a <= 16'hFFFF;
  b <= 16'h1000;
  #10 if (o !== 16'h0FFF) begin
    $display("Adding FFFF + 1000, got %H, expected 0FFF", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
end

endmodule