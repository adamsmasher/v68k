module DataRegisterFile  #(parameter reg_width=32) (
  input CLK,
  input [2:0] REG_SEL_A,
  input [2:0] REG_SEL_B,
  input S,
  input [reg_width-1:0] D,
  output [reg_width-1:0] Q_A,
  output [reg_width-1:0] Q_B
);

wire [7:0] en_a;
wire [7:0] en_b;

Decoder #(3) reg_sel_a(REG_SEL_A, en_a);
Decoder #(3) reg_sel_b(REG_SEL_B, en_b);

genvar i;
generate
  for(i = 0; i < 8; i = i + 1) begin : generate_registers
    Register #(reg_width) d(CLK, en_a[i], en_b[i], S, D, Q_A, Q_B);
  end
endgenerate

endmodule