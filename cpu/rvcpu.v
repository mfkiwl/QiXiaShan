
/* verilator lint_off UNUSED */
//--xuezhen--

`timescale 1ns / 1ps

`include "defines.v"


module rvcpu(
  input wire            clk,
  input wire            rst,
  input wire  [31 : 0]  inst,
  
  output wire [63 : 0]  inst_addr, 
  output wire           inst_ena
);


// id_stage
// id_stage -> regfile
wire rs1_r_ena;
wire [4 : 0]rs1_r_addr;
wire rs2_r_ena;
wire [4 : 0]rs2_r_addr;
wire rd_w_ena;
wire [4 : 0]rd_w_addr;

// id_stage -> exe_stage
wire [`REG_BUS] exe_op1;
wire [`REG_BUS] exe_op2;
wire [`OP_BUS] op_info;
wire [`ALU_BUS] alu_info;
wire [`BJ_BUS]  bj_info;
wire is_word_opt;

// id stage -> mem_stage
wire mem_w_ena;

// id stage -> wb_stage
wire mem_to_reg;

// id_stage -> if_stage
wire [`REG_BUS] jmp_imm;

// regfile -> id_stage
wire [`REG_BUS] r_data1;
wire [`REG_BUS] r_data2;

// exe_stage -> mem/wb_stage
wire [`REG_BUS] exe_data;
// exe_stage -> if_stage
wire bj_ena;

// mem_stage -> wb_stage
wire [`REG_BUS] mem_r_data;

// wb_stage -> regfile
wire [`REG_BUS] rd_data;

if_stage If_stage(
  .clk(clk),
  .rst(rst),
  
  .inst_addr(inst_addr),
  .inst_ena(inst_ena)
);

id_stage Id_stage(
  .rst(rst),
  .inst(inst),
  .r_data1(r_data1),
  .r_data2(r_data2),
  .inst_addr(inst_addr),

  .rs1_r_ena(rs1_r_ena),
  .rs1_r_addr(rs1_r_addr),
  .rs2_r_ena(rs2_r_ena),
  .rs2_r_addr(rs2_r_addr),
  .rd_w_ena(rd_w_ena),
  .rd_w_addr(rd_w_addr),

  .is_word_opt(is_word_opt),
  .exe_op1(exe_op1),
  .exe_op2(exe_op2),
  .mem_to_reg(mem_to_reg),
  .mem_w_ena(mem_w_ena),

  .op_info(op_info),
  .alu_info(alu_info),
  .bj_info(bj_info),
  .jmp_imm(jmp_imm)
);

exe_stage Exe_stage(
  .rst(rst),
  .exe_op1(exe_op1),
  .exe_op2(exe_op2),
  .is_word_opt(is_word_opt),
  .op_info(op_info),
  .alu_info(alu_info),
  .bj_info(bj_info),
  
  .rd_data(exe_data),
  .bj_ena(bj_ena)
);

mem_stage Mem_stage(
  .rst(rst),
  .addr(exe_data),
  .mem_w_ena(mem_w_ena),

  .mem_r_data(mem_r_data)
);

wb_stage Wb_stage(
  .rst(rst),
  .mem_to_reg(mem_to_reg),
  .exe_data(exe_data),
  .mem_data(mem_r_data),

  .w_data(rd_data)
);

regfile Regfile(
  .clk(clk),
  .rst(rst),
  .w_addr(rd_w_addr),
  .w_data(rd_data),
  .w_ena(rd_w_ena),
  
  .r_addr1(rs1_r_addr),
  .r_data1(r_data1),
  .r_ena1(rs1_r_ena),
  .r_addr2(rs2_r_addr),
  .r_data2(r_data2),
  .r_ena2(rs2_r_ena)
);

endmodule
