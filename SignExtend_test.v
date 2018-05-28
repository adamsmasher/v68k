module SignExtend_test(output TEST);

assign TEST = 1;

reg [7:0] from;
wire [15:0] to;

SignExtend sext(from, to);

initial begin
  from = 8'h7F;
  #1 if (to !== 16'h007F) begin
    $display("Expected 007F, got %h", to);
    $stop;
  end
  from = 8'hFF;
  #1 if (to !== 16'hFFFF) begin
    $display("Expected FFFF, got %h", to);
    $stop;
  end
end

endmodule