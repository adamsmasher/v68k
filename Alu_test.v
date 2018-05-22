module Alu_test(output TEST);

parameter bits = 16;

reg [bits-1:0] a;
reg [bits-1:0] b;
wire [bits-1:0] o;
reg [2:0] op = 0; // add
reg x = 0;
wire c;
wire z;
wire v;
wire n;

assign TEST = 1;

Alu #(bits) alu(a, b, o, op, x, c, z, v, n);

initial begin
  // zero
  a <= 0; 
  b <= 0;
  #10 if (o !== 0 || c !== 0 || z !== 1 || v !== 0 || n !== 0) begin
    $display("Adding 0 + 0, got %H, expected 0", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive, no overflow or carry
  a <= 16'h010F;
  b <= 16'h010F; 
  #10 if (o !== 16'h021E || c !== 0 || z !== 0 || v !== 0 || n !== 0) begin
    $display("Adding 010F + 010F, got %H, expected 021E", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive, overflow no carry
  a <= 16'h7FFF;
  b <= 16'h0001;
  #10 if (o !== 16'h8000 || c !== 0 || z !== 0 || v !== 1 || n !== 1) begin
    $display("Adding 7FFF + 0001, got %H, expected 8000", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // positive + positive (unsigned), carry
  // (a.k.a positive + negative)
  a <= 16'hFFFF;
  b <= 16'h0001;
  #10 if (o !== 0 || c !== 1 || z !== 1 || v !== 0 || n !== 0) begin
    $display("Adding FFFF + 0001, got %H, expected 0", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // negative + negative, no overflow
  a <= 16'hFFFF;
  b <= 16'hFFFF;
  #10 if (o !== 16'hFFFE || c !== 1 || z !== 0 || v !== 0 || n !== 1) begin
    $display("Adding FFFF + FFFF, got %H, expected FFFE", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
  // negative + negative, overflow
  a <= 16'hFFFF;
  b <= 16'h8000;
  #10 if (o !== 16'h7FFF || c !== 1 || z !== 0 || v !== 1 || n !== 0) begin
    $display("Adding FFFF + 1000, got %H, expected 7FFF", o);
    $display("CZVN: %b %b %b %b", c, z, v, n);
    $stop;
  end
end

endmodule