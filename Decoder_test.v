module Decoder_test(output TEST);

parameter n = 3;

reg [2:0] in;
wire [7:0] out;

assign TEST = 1;

Decoder #(n) decoder(in, out);

initial begin
  // zero
  in = 3'b000; #1
  if (out !== 8'b00000001) begin
    $display("Input: 0, Expected: 00000001, Got: %b", out);
    $stop;
  end
  // two
  in = 3'b010; #1
  if (out !== 8'b00000100) begin
    $display("Input: 2, Expected: 00000100, Got: %b", out);
    $stop;
  end
  // full
  in = 3'b111; #1
  if (out !== 8'b10000000) begin
    $display("Input: 7, Expected: 10000000, Got: %b", out);   
    $stop;
  end
end

endmodule