module AddressRegisterFile  #(parameter reg_width=32) (
  input CLK,
  input [2:0] REG_SEL,
  input SUPERVISOR_MODE,
  input S,
  input [reg_width-1:0] D,
  output [reg_width-1:0] Q
);

wire [7:0] en;
wire [7:0] en_gnd;

Decoder #(3) reg_sel(REG_SEL, en);
assign en_gnd = 8'b0;


wire [reg_width-1:0] q_gnd;

// TODO: this doesn't actually work lol

genvar i;
generate
  for(i = 0; i < 8; i = i + 1) begin : generate_registers
    Register #(reg_width) a(CLK, en[i], en_gnd[i], S, D, Q, q_gnd[i]);
  end
endgenerate

endmodule