
//--Sun Jiru, Nanjing University--

`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000   
`define REG_BUS    63 : 0     
`define INST_ADD   8'h11

`define ALU_ADD    0
`define ALU_SUB    1
`define ALU_SLT    2
`define ALU_SLTU   3
`define ALU_XOR    4
`define ALU_OR     5
`define ALU_AND    6
`define ALU_SLL    7
`define ALU_SRL    8
`define ALU_SRA    9
`define ALU_BUS    9 : 0

`define BJ_BEQ  0
`define BJ_BNE  1
`define BJ_BLT  2
`define BJ_BGE  3
`define BJ_BLTU 4
`define BJ_BGEU 5
`define BJ_JALR 6
`define BJ_JAL  7
`define BJ_BUS  7 : 0

`define INST_I_LOAD        0
`define INST_I_FENCE       1
`define INST_I_ARITH_DWORD 2
`define INST_U_AUIPC       3
`define INST_I_ARITH_WORD  4
`define INST_S             5
`define INST_R_DWORD       6
`define INST_U_LUI         7
`define INST_R_WORD        8
`define INST_B             9
`define INST_I_JALR        10
`define INST_J             11
`define INST_I_SYS         12
`define OP_BUS             12 : 0