
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
//--Sun Jiru, Nanjing University--

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

// all types
wire [6 : 0] opcode = inst[6 : 0];
wire [4 : 0] rd = inst[11 :  7];
wire [2 : 0] func3 = inst[14 : 12];
wire [4 : 0] rs1 = inst[19 : 15];
// R-type
wire [4 : 0] rs2 = inst[24 : 20];
wire [6 : 0] func7 = inst[31 : 25];
// I-type
wire [11 : 0] immI = inst[31 : 20];
// S-type
wire [11 : 0] immS = {inst[31 : 25], inst[11 : 7]};
// B-type
wire [12 : 0] immB = {inst[31], inst[7], inst[30 : 25], inst[11 : 8], 1'b0};
// U-type
wire [19 : 0] immU = inst[31 : 12];
// J-type
wire [20 : 0] immJ = {inst[31], inst[19 : 12], inst[20], inst[30 : 21], 1'b0};


// decode func3
wire func3_0 = (func3 == 3'h0);
wire func3_1 = (func3 == 3'h1);
wire func3_2 = (func3 == 3'h2);
wire func3_3 = (func3 == 3'h3);
wire func3_4 = (func3 == 3'h4);
wire func3_5 = (func3 == 3'h5);
wire func3_6 = (func3 == 3'h6);
wire func3_7 = (func3 == 3'h7);

// decode func7
wire func7_00 = (func7 == 7'h00);
wire func7_20 = (func7 == 7'h20);

// decode imm12
wire imm12_000 = (immI == 12'h000);
wire imm12_001 = (immI == 12'h001);

// decode type
wire inst_i_load        = (opcode == 7'h03);
wire inst_i_fence       = (opcode == 7'h0f);
wire inst_i_arith_dword = (opcode == 7'h13);
wire inst_u_auipc       = (opcode == 7'h17);
wire inst_i_arith_word  = (opcode == 7'h1b);
wire inst_s             = (opcode == 7'h23);
wire inst_r_dword       = (opcode == 7'h33);
wire inst_u_lui         = (opcode == 7'h37);
wire inst_r_word        = (opcode == 7'h3b);
wire inst_b             = (opcode == 7'h63);
wire inst_i_jalr        = (opcode == 7'h67);
wire inst_j             = (opcode == 7'h6f);
wire inst_i_sys         = (opcode == 7'h73);
assign op_info = {inst_i_sys, inst_j, inst_i_jalr, inst_b, inst_r_word, inst_u_lui,
                  inst_r_dword, inst_s, inst_i_arith_word, inst_u_auipc, inst_i_arith_dword, 
                  inst_i_fence, inst_i_load
                 };
assign is_word_opt = inst_r_word | inst_i_arith_word;

// decode arithmetic
wire inst_lb      = inst_i_load & func3_0;
wire inst_lh      = inst_i_load & func3_1;
wire inst_lw      = inst_i_load & func3_2;
wire inst_ld      = inst_i_load & func3_3;
wire inst_lbu     = inst_i_load & func3_4;
wire inst_lhu     = inst_i_load & func3_5;
wire inst_lwu     = inst_i_load & func3_6;

wire inst_fence   = inst_i_fence & func3_0;
wire inst_fence_i = inst_i_fence & func3_1;

wire inst_addi    = inst_i_arith_dword & func3_0 & func7_00;
wire inst_slli    = inst_i_arith_dword & func3_1;
wire inst_slti    = inst_i_arith_dword & func3_2;
wire inst_sltiu   = inst_i_arith_dword & func3_3;
wire inst_xori    = inst_i_arith_dword & func3_4;
wire inst_srli    = inst_i_arith_dword & func3_5 & func7_00;
wire inst_srai    = inst_i_arith_dword & func3_5 & func7_20;
wire inst_ori     = inst_i_arith_dword & func3_6;
wire inst_andi    = inst_i_arith_dword & func3_7;

wire inst_auipc   = inst_u_auipc;

wire inst_addiw   = inst_i_arith_word & func3_0;
wire inst_slliw   = inst_i_arith_word & func3_1;
wire inst_srliw   = inst_i_arith_word & func3_5 & func7_00;
wire inst_sraiw   = inst_i_arith_word & func3_5 & func7_20;

wire inst_sb      = inst_s & func3_0;
wire inst_sh      = inst_s & func3_1;
wire inst_sw      = inst_s & func3_2;
wire inst_sd      = inst_s & func3_3;

wire inst_add     = inst_r_dword & func3_0 & func7_00;
wire inst_sub     = inst_r_dword & func3_0 & func7_20;
wire inst_sll     = inst_r_dword & func3_1;
wire inst_slt     = inst_r_dword & func3_2;
wire inst_sltu    = inst_r_dword & func3_3;
wire inst_xor     = inst_r_dword & func3_4;
wire inst_srl     = inst_r_dword & func3_5 & func7_00;
wire inst_sra     = inst_r_dword & func3_5 & func7_20;
wire inst_or      = inst_r_dword & func3_6;
wire inst_and     = inst_r_dword & func3_7;

wire inst_lui     = inst_u_lui;

wire inst_addw    = inst_r_word & func3_0 & func7_00;
wire inst_subw    = inst_r_word & func3_0 & func7_20;
wire inst_sllw    = inst_r_word & func3_1;
wire inst_srlw    = inst_r_word & func3_5 & func7_00;
wire inst_sraw    = inst_r_word & func3_5 & func7_20;

wire inst_beq     = inst_b & func3_0;
wire inst_bne     = inst_b & func3_1;
wire inst_blt     = inst_b & func3_4;
wire inst_bge     = inst_b & func3_5;
wire inst_bltu    = inst_b & func3_6;
wire inst_bgeu    = inst_b & func3_7;

wire inst_jalr    = inst_i_jalr;
wire inst_jal     = inst_j;
wire inst_ecall   = inst_i_sys & func3_0 & imm12_000;
wire inst_ebreak  = inst_i_sys & func3_0 & imm12_001;
wire inst_csrrw   = inst_i_sys & func3_1;
wire inst_csrrs   = inst_i_sys & func3_2;
wire inst_csrrc   = inst_i_sys & func3_3;
wire inst_csrrwi  = inst_i_sys & func3_5;
wire inst_csrrsi  = inst_i_sys & func3_6;
wire inst_csrrci  = inst_i_sys & func3_7;

assign alu_info[`ALU_ADD]  = inst_add  | inst_addi   | inst_addw | inst_auipc 
                           | inst_lui  | inst_i_load | inst_s | inst_jal | inst_jalr;
assign alu_info[`ALU_SUB]  = inst_sub  | inst_subw   | inst_b;
assign alu_info[`ALU_SLT]  = inst_slt  | inst_slti   | inst_blt  | inst_bge;
assign alu_info[`ALU_SLTU] = inst_sltu | inst_sltiu  | inst_bltu | inst_bgeu;
assign alu_info[`ALU_XOR]  = inst_xor  | inst_xori   | inst_beq  | inst_bne;
assign alu_info[`ALU_OR]   = inst_or   | inst_ori;
assign alu_info[`ALU_AND]  = inst_and  | inst_andi;
assign alu_info[`ALU_SLL]  = inst_sll  | inst_slli   | inst_sllw;
assign alu_info[`ALU_SRL]  = inst_srl  | inst_srli   | inst_srlw;
assign alu_info[`ALU_SRA]  = inst_sra  | inst_srai   | inst_sraw;

assign bj_info[`BJ_BEQ]  = inst_beq;
assign bj_info[`BJ_BNE]  = inst_bne;
assign bj_info[`BJ_BLT]  = inst_blt;
assign bj_info[`BJ_BGE]  = inst_bge;
assign bj_info[`BJ_BLTU] = inst_bltu;
assign bj_info[`BJ_BGEU] = inst_bgeu;
assign bj_info[`BJ_JALR] = inst_jalr;
assign bj_info[`BJ_JAL]  = inst_jal;

assign rs1_r_ena  = ~rst & (inst_i_load | inst_i_fence | inst_i_arith_dword 
                          | inst_i_arith_word | inst_r_dword | inst_r_word
                          | inst_b | inst_i_jalr | inst_i_sys);
assign rs1_r_addr = (rs1_r_ena == 1'b1) ? rs1 : 0;
assign rs2_r_ena  = ~rst & (inst_r_dword | inst_r_word | inst_s | inst_b);
assign rs2_r_addr = (rs2_r_ena == 1'b1) ? rs2 : 0;

assign rd_w_ena   = ~rst & (inst_i_load | inst_i_fence | inst_i_arith_dword
                          | inst_u_auipc | inst_i_arith_word | inst_r_dword
                          | inst_u_lui | inst_r_word | inst_i_jalr | inst_j
                          | inst_i_sys);
assign rd_w_addr  = (rd_w_ena == 1'b1) ? rd : 0;

assign exe_op1 = {64{~rst}} & (
                ({64{inst_i_load}}        & r_data1)
              | ({64{inst_i_fence}}       & r_data1)
              | ({64{inst_i_arith_dword}} & r_data1)
              | ({64{inst_u_auipc}}       & inst_addr)
              | ({64{inst_i_arith_word}}  & r_data1)
              | ({64{inst_s}}             & r_data1)
              | ({64{inst_r_dword}}       & r_data1)
              | ({64{inst_u_lui}}         & 64'b0)
              | ({64{inst_r_word}}        & r_data1)
              | ({64{inst_b}}             & r_data1)
              | ({64{inst_i_sys}}         & r_data1)
             );

assign exe_op2 = {64{~rst}} & (
                ({64{inst_i_load}}        & {{52{immI[11]}}, immI})
              | ({64{inst_i_fence}}       & {{52{immI[11]}}, immI})
              | ({64{inst_i_arith_dword}} & {{52{immI[11]}}, immI})
              | ({64{inst_u_auipc}}       & {{44{immU[19]}}, immU})
              | ({64{inst_i_arith_word}}  & {{52{immI[11]}}, immI})
              | ({64{inst_s}}             & {{52{immI[11]}}, immI})
              | ({64{inst_r_dword}}       & r_data2)
              | ({64{inst_u_lui}}         & {{32{immU[19]}}, immU, 12'b0})
              | ({64{inst_r_word}}        & r_data2)
              | ({64{inst_b}}             & r_data2)
              | ({64{inst_i_sys}}         & 64'b0)
             );

assign jmp_imm = ({64{inst_b}} & {{51{immB[12]}}, immB})
               | ({64{inst_j}} & {{43{immJ[20]}}, immJ})
               | ({64{inst_i_jalr}} & r_data1 + {{52{immI[11]}}, immI} - inst_addr);

assign mem_to_reg = (rst == 1'b1) ? 0 : inst_i_load;
assign mem_w_ena = (rst == 1'b1) ? 0 : inst_s;

endmodule
