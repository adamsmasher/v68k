module SignExtend #(parameter from=8, to=16)(
  input [from-1:0] FROM,
  output [to-1:0] TO
);

assign TO = {{(to-from){FROM[from-1]}}, FROM};

endmodule
