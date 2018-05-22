module V68k (
  input RESET,
  input HALT,
  input CLK,
  // address bus
  output reg [23:1] A,
  output reg UDS,  // asserted if we want to read the hi byte of a word
  output reg LDS,  // asserted if we want to read the lo byte of a word
  output reg AS,  // asserted when address on bus is valid
  // data bus
  inout [15:0] D,
  input DTACK,  // asserted when data on bus is valid
  output reg RW,  // low to write, high to read
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

//StatusRegister status_register(CLK);

// set which data registers we want data ports A and B to point to
reg [2:0] dreg_sel_a;
reg [2:0] dreg_sel_b;
// set if we want to set the register on data port B to dreg_data
reg dreg_set;
reg [31:0] dreg_data;
// the output of data ports A and B
wire [31:0] data_out_a;
wire [31:0] data_out_b;
DataRegisterFile data_regs(CLK, dreg_sel_a, dreg_sel_b, dreg_set, dreg_data, data_out_a, data_out_b);

// TODO: this is an oversimplification - we should only be driving D if it's safe
reg [15:0] d_out;
assign D = d_out;

parameter DS_ON = 1'b0;
parameter DS_OFF = 1'b1;

parameter AS_STROBE = 1'b0;
parameter AS_OFF = 1'b1;

parameter RW_WRITE = 1'b0;
parameter RW_READ = 1'b1;

reg [15:0] ir;

// set to indicate where we want the ALU's inputs to come from
reg alu_sel_a;
reg alu_sel_b;
// the wires that connect the ALU's inputs to the ALU
wire [15:0] alu_in_a;
wire [15:0] alu_in_b;
// Mux's to select the input for the ALU based on the alu_sel registers
Mux2 alu_mux_a(alu_sel_a, data_out_a[15:0], data_out_a[31:16], alu_in_a);
Mux2 alu_mux_b(alu_sel_b, data_out_b[15:0], data_out_b[31:16], alu_in_b);
// output from the ALU
wire [15:0] alu_out;
Alu alu(alu_in_a, alu_in_b, alu_out);

// indicate whether we want the input to the ALU to come from the hi word or the lo word
parameter ALU_LO = 1'b0;
parameter ALU_HI = 1'b1;

//AddressRegisterFile address_regs(CLK);

reg [31:0] pc;

/* parameter INITIALIZE_0 = 0;
parameter INITIALIZE_1 = 1;
parameter GET_OPS = 2;
parameter DO_HI_ADD = 3;
parameter WRITE_BACK = 4;
parameter WRITE_MEM = 5; */

parameter FETCH = 3'b000;
parameter WAIT_FOR_INSTRUCTION = 3'b001;

reg [2:0] state;

always @(posedge CLK) begin
  if(RESET) begin
    dreg_set <= 0;
    // TODO: read the initial PC from memory
    pc <= 0;
    state <= FETCH;
  end else begin
    case (state)
      FETCH: begin
        A <= pc[23:1];
        // read both the upper and lower byte
        UDS <= DS_ON;
        LDS <= DS_ON;
        AS <= AS_STROBE;
        RW <= RW_READ;
        state <= WAIT_FOR_INSTRUCTION;
      end
      WAIT_FOR_INSTRUCTION: begin
        if (DTACK) begin
          ir <= D;
          AS <= AS_OFF;
          UDS <= DS_OFF;
          LDS <= DS_OFF;
        end
      end
/*      INITIALIZE_0: begin
        dreg_set <= 1;
        dreg_sel_b <= 0;
        dreg_data <= 1;
        state <= INITIALIZE_1;
      end
      INITIALIZE_1: begin
        dreg_set <= 1;
        dreg_sel_b <= 1;
        dreg_data <= 1;
        state <= GET_OPS;
      end
      GET_OPS: begin
        dreg_set <= 0;
        dreg_sel_a <= 0;
        dreg_sel_b <= 1;
        alu_sel_a <= 0;
        alu_sel_b <= 0;
        state <= DO_HI_ADD;
      end
      DO_HI_ADD: begin
        dreg_data[15:0] <= alu_out;
        alu_sel_a <= 1;
        alu_sel_b <= 1;
        state <= WRITE_BACK;
      end
      WRITE_BACK: begin
        dreg_data[31:16] <= alu_out;
        dreg_sel_b <= 0;
        dreg_set <= 1;
        state <= WRITE_MEM;
      end
      WRITE_MEM: begin
        dreg_set <= 0;
        d_out <= dreg_data[15:0];
        state <= GET_OPS;
      end */
    endcase
  end    
end

endmodule