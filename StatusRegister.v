module StatusRegister(
  input CLK
);

Register #(16) status_register(CLK);

endmodule