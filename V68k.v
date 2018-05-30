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

reg n;
reg z;
reg v;
reg c;

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

parameter
  DS_ON  = 1'b0,
  DS_OFF = 1'b1;

parameter
  AS_STROBE = 1'b0,
  AS_OFF    = 1'b1;

parameter
  RW_WRITE = 1'b0,
  RW_READ = 1'b1;

reg [15:0] ir;

reg [31:0] tmp_reg;

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
parameter
  ALU_LO = 1'b0,
  ALU_HI = 1'b1;

//AddressRegisterFile address_regs(CLK);

reg [31:0] pc;

/* parameter INITIALIZE_0 = 0;
parameter INITIALIZE_1 = 1;
parameter GET_OPS = 2;
parameter DO_HI_ADD = 3;
parameter WRITE_BACK = 4;
parameter WRITE_MEM = 5; */

parameter
  FETCH                = 3'b000,
  WAIT_FOR_INSTRUCTION = 3'b001,
  DECODE               = 3'b010,
  EXG_DATA_0           = 3'b011,
  EXG_DATA_1           = 3'b100;

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
          state <= DECODE;
        end
      end
      DECODE: begin
        // each of these top-level conditions corresponds to an Intstruction Format figure in the 68k Programmer's Manual
        // (where possible)
        // they're listed from least to greatest, kinda, sorta
        // TODO: consolidate similar instructions, fix overlapping
        casez (ir)
          16'b0000_0000_0011_1100:; // ORI to CCR
          16'b0000_0010_0011_1100:; // ANDI to CCR
          16'b0000_1010_0011_1100:; // EORI to CCR
          16'b0000_1000_00??_????:; // BTST (static)
          16'b0000_1000_01??_????:; // BCHG (static)
          16'b0000_1000_10??_????:; // BCLR (static)
          16'b0000_1000_11??_????:; // BSET (static)
          16'b0000_0000_????_????:; // ORI
          16'b0000_0010_????_????:; // ANDI
          16'b0000_0100_????_????:; // SUBI
          16'b0000_0110_????_????:; // ADDI
          16'b0000_1010_????_????:; // EORI
          16'b0000_1100_????_????:; // CMPI
          16'b0000_???1_00??_????:; // BTST (dynamic)
          16'b0000_???1_01??_????:; // BCHG (dynamic)
          16'b0000_???1_10??_????:; // BCLR (dynamic)
          16'b0000_???1_11??_????:; // BSET (dynamic)
          16'b0000_????_??00_1???:; // MOVEP
          16'b00??_???0_01??_????:; // MOVEA
          16'b00??_????_????_????:; // MOVE
          16'b0100_1110_0111_0001:  // NOP
          begin
            pc <= pc + 2;
            state <= FETCH;
          end
          16'b0100_0000_11??_????:; // MOVE from SR
          16'b0100_0100_11??_????:; // MOVE to CCR
          16'b0100_0110_????_????:; // NOT
          16'b0100_1?00_1???_????:; // MOVEM
          16'b0100_0000_????_????:; // NEGX
          16'b0100_0100_????_????:; // NEG
          16'b0100_1110_0101_0???:; // LINK
          16'b0100_???1_11??_????:; // LEA
          16'b0100_1000_00??_????:; // NBCD
          16'b0100_1000_0100_0???:; // SWAP
          16'b0100_100?_??00_0???:; // EXT, EXTB
          16'b0100_1010_1111_1100:; // ILLEGAL
          16'b0100_1010_11??_????:; // TAS
          16'b0100_1010_????_????:; // TST
          16'b0100_1110_0100_????:; // TRAP
          16'b0100_1110_0101_1???:; // UNLK
          16'b0100_1110_0111_0101:; // RTS
          16'b0100_1110_0111_0110:; // TRAPV
          16'b0100_1110_0111_0111:; // RTR
          16'b0100_0010_????_????:; // CLR
          16'b0100_1000_01??_????:; // PEA
          16'b0100_????_??0?_????:; // CHK
          16'b0100_1110_10??_????:; // JSR
          16'b0100_1110_11??_????:; // JMP
          16'b0101_???0_????_????:; // ADDQ
          16'b0101_???1_????_????:; // SUBQ
          16'b0101_????_1100_1???:; // DBcc
          16'b0101_????_11??_????:; // Scc
          16'b0110_0000_????_????:; // BRA
          16'b0110_0001_????_????:; // BSR
          16'b0110_????_????_????:; // Bcc
          16'b0111_???0_????_????:  // MOVEQ
          begin
            dreg_sel_b <= ir[11:9];
            dreg_set <= 1;
            dreg_data <= {{24{ir[7]}}, ir[7:0]};
            n <= ir[7];
            z <= ir[7:0] == 0;
            v <= 0;
            c <= 0;
            state <= FETCH;
          end
          16'b1000_???1_0000_????:; // SBCD
          16'b1000_???0_11??_????:; // DIVU
          16'b1000_???1_11??_????:; // DIVS
          16'b1000_????_????_????:; // OR
          16'b1001_???1_??00_????:; // SUBX
          16'b1001_????_????_????:; // SUB
          16'b1001_????_????_????:; // SUBA
          16'b1011_???1_??00_1???:; // CMPM
          16'b1011_????_????_????:; // CMP
          16'b1011_????_????_????:; // CMPA
          16'b1011_????_????_????:; // EOR
          16'b1100_???1_0000_????:; // ABCD
          16'b1100_???1_0100_0???:  // EXG (Dn to Dn)
          begin
            dreg_sel_a <= ir[11:9];
            dreg_sel_b <= ir[2:0];
            state <= EXG_DATA_0;
          end
          16'b1100_????_????_????:; // AND
          16'b1100_???0_11??_????:; // MULU
          16'b1100_???1_11??_????:; // MULS
          16'b1101_???1_??00_????:; // ADDX
          16'b1101_????_????_????:; // ADD
          16'b1101_????_????_????:; // ADDA
          16'b1110_000?_11??_????:; // ASL, ASR (Memory shifts)
          16'b1110_001?_11??_????:; // LSL, LSR (Memory shifts)
          16'b1110_010?_11??_????:; // ROXL, ROXR (Memory shifts)
          16'b1110_011?_11??_????:; // ROL, ROR (Memory shifts)
          16'b1110_????_???0_0???:; // ASL, ASR (Register shifts)
          16'b1110_????_???0_1???:; // LSL, LSR (Register shifts)
          16'b1110_????_???1_0???:; // ROXL, ROXR (Register rotate)
          16'b1110_????_???1_1???:; // ROL, ROR (Register rotate)
        endcase
      end
      EXG_DATA_0: begin
        // we have the two register values loaded into data_out_a and data_out_b
        // copy b into the temporary register and a into b
        dreg_set <= 1;
        dreg_data <= data_out_a;
        tmp_reg <= data_out_b;
        state <= EXG_DATA_1;
      end
      EXG_DATA_1: begin
        dreg_set <= 1;
        dreg_sel_b <= dreg_sel_a;
        dreg_data <= tmp_reg;
        state <= FETCH;
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