
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
//--xuezhen--

`include "defines.v"

module id_stage(
  input wire rst,
  input wire [31 : 0] inst,
  input wire [`REG_BUS] r_data1,
  input wire [`REG_BUS] r_data2,
  input wire [`REG_BUS] inst_addr,
  
  output wire rs1_r_ena,
  output wire [4 : 0]rs1_r_addr,
  output wire rs2_r_ena,
  output wire [4 : 0]rs2_r_addr,
  output wire rd_w_ena,
  output wire [4 : 0]rd_w_addr,
  
  output wire [4 : 0]inst_type,
  output wire [7 : 0]inst_opcode,
  output wire is_word_opt,
  output wire [`REG_BUS]exe_op1,
  output wire [`REG_BUS]exe_op2,

  output wire mem_to_reg,
  output wire mem_w_ena,

  output wire [`OP_BUS]  op_info,
  output wire [`ALU_BUS] alu_info,
  output wire [`BJ_BUS]  bj_info,
  output wire [`REG_BUS] jmp_imm
);




// I-type
wire [6  : 0]opcode;
wire [4  : 0]rd;
wire [2  : 0]func3;
wire [4  : 0]rs1;
wire [11 : 0]imm;
assign opcode = inst[6  :  0];
assign rd     = inst[11 :  7];
assign func3  = inst[14 : 12];
assign rs1    = inst[19 : 15];
assign imm    = inst[31 : 20];

wire inst_addi =   ~opcode[2] & ~opcode[3] & opcode[4] & ~opcode[5] & ~opcode[6]
                 & ~func3[0] & ~func3[1] & ~func3[2];

// arith inst: 10000; logic: 01000;
// load-store: 00100; j: 00010;  sys: 000001
assign inst_type[4] = ( rst == 1'b1 ) ? 0 : inst_addi;

assign inst_opcode[0] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[1] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[2] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[3] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[4] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[5] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[6] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[7] = (  rst == 1'b1 ) ? 0 : 0;




assign rs1_r_ena  = ( rst == 1'b1 ) ? 0 : inst_type[4];
assign rs1_r_addr = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? rs1 : 0 );
assign rs2_r_ena  = 0;
assign rs2_r_addr = 0;

assign rd_w_ena   = ( rst == 1'b1 ) ? 0 : inst_type[4];
assign rd_w_addr  = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? rd  : 0 );

assign exe_op1 = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? r_data1 : 0 );
assign exe_op2 = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? { {52{imm[11]}}, imm } : 0 );

wire inst_load = ~opcode[2] & ~opcode[3] & ~opcode[4] & ~opcode[5] & ~opcode[6];
assign mem_to_reg = (rst == 1'b1) ? 0 : inst_load;
wire inst_save = ~opcode[2] & ~opcode[3] & ~opcode[4] & opcode[5] & ~opcode[6];
assign mem_w_ena = (rst == 1'b1) ? 0 : inst_save;

endmodule
