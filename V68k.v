module V68k (
  input RESET,
  input HALT,
  input CLK,
  // address bus
  output [23:1] A,
  output UDS,
  output LDS,
  output AS,  // asserted when address on bus is valid
  // data bus
  inout [15:0] D,
  input DTACK,  // asserted when data on bus is valid
  output RW,  // low to write, high to read
  // synchronous peripherals
  output E,  // continuous clock for peripheral sync, low for 6 CPU clocks, high for 4
  input VPA,  // set by the address decoder when address bus is pointing at a peripheral to trigger E-synced cycles; also when set, interrupt vector is chosen by D0-D7; otherwise, interrupt is chosen based on IPL0-IPL2
  output VMA,  // set to acknowledge VPA/address is valid on address bus
  // interrupts
  input [2:0] IPL,  // set to request an interrupt of the given priority
  // bus control
  input BR,  // set to request the bus
  output BG,  // set to grant the bus
  input BGACK,  // set to hold bus
  input BERR,  // set to indicate a bus error
  // debug
  output [2:0] FC
);

reg [15:0] alu_a;
reg [15:0] alu_b;
wire [15:0] alu_out;
Alu alu(alu_a, alu_b, alu_out);

//StatusRegister status_register(CLK);

reg [2:0] dreg_sel_a;
reg [2:0] dreg_sel_b;
reg dreg_set;
wire [31:0] data_out_a;
wire [31:0] data_out_b;
reg [31:0] dreg_data;
DataRegisterFile data_regs(dreg_sel_a, dreg_sel_b, dreg_set, dreg_data, data_out_a, data_out_b);

//AddressRegisterFile address_regs(CLK);

//reg [31:0] pc;

parameter INITIALIZE_0 = 0;
parameter INITIALIZE_1 = 1;
parameter GET_LO_OPS = 2;
parameter GET_HI_OPS = 3;
parameter WRITE_BACK = 4;
  
reg [2:0] state;

always @(posedge CLK) begin
  if(RESET) begin
    dreg_set <= 0;
 //   pc <= 0;
    state <= INITIALIZE_0;
  end else begin
  //  pc <= pc + 1;
    case (state)
      INITIALIZE_0: begin
        dreg_set <= 1;
        dreg_sel_b <= 0;
        dreg_data <= 1;
        state <= INITIALIZE_1;
      end
      INITIALIZE_1: begin
        dreg_set <= 1;
        dreg_sel_b <= 1;
        dreg_data <= 1;
        state <= GET_LO_OPS;
      end
      GET_LO_OPS: begin
        dreg_set <= 0;
        dreg_sel_a <= 0;
        dreg_sel_b <= 1;
        alu_a <= data_out_a[15:0];
        alu_b <= data_out_b[15:0];
        state <= GET_HI_OPS;
      end
      GET_HI_OPS: begin
        dreg_data[15:0] <= alu_out;
        alu_a <= data_out_a[31:16];
        alu_b <= data_out_b[31:16];
        state <= WRITE_BACK;
      end
      WRITE_BACK: begin
        dreg_data[31:16] <= alu_out;
        dreg_sel_b <= 0;
        dreg_set <= 1;
        state <= GET_LO_OPS;
      end
    endcase
  end    
end

endmodule