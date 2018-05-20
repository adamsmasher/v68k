module Register #(parameter bits=32) (
  input CLK,
  input EN_A,
  input EN_B,
  input S,
  input [bits-1:0] D,
  output [bits-1:0] Q_A,
  output [bits-1:0] Q_B
);

reg [bits-1:0] contents;

always @(posedge CLK) begin
  if (EN_B && S) begin
    contents <= D;
  end
end

assign Q_A = EN_A ? contents : {bits{1'bz}};
assign Q_B = EN_B ? contents : {bits{1'bz}};

endmodule