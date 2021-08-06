
//--Sun Jiru, Nanjing University--

`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000
`define PC_START   64'h00000000_80000000
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
`define ALU_ANDN   10
`define ALU_WRI    11
`define ALU_BUS    11 : 0

`define BJ_BEQ  0
`define BJ_BNE  1
`define BJ_BLT  2
`define BJ_BGE  3
`define BJ_BLTU 4
`define BJ_BGEU 5
`define BJ_JALR 6
`define BJ_JAL  7
`define BJ_BUS  7 : 0

`define LOAD_LB  0
`define LOAD_LH  1
`define LOAD_LW  2
`define LOAD_LD  3
`define LOAD_LBU 4
`define LOAD_LHU 5
`define LOAD_LWU 6
`define LOAD_BUS 6 : 0

`define SAVE_SB  0
`define SAVE_SH  1
`define SAVE_SW  2
`define SAVE_SD  3
`define SAVE_BUS 3 : 0

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
`define INST_I_EXP         12
`define INST_I_CSR_IMM     13
`define INST_I_CSR_REG     14
`define INST_PUTCH         15
`define OP_BUS             15 : 0

`define CSR_MISA       0
`define CSR_MCYCLE     1
`define CSR_MVENDORID   2
`define CSR_MARCHID    3
`define CSR_MIMPID     4
`define CSR_MHARTID    5
`define CSR_BUS        5 : 0

`define EXE_TO_REG   0
`define MEM_TO_REG   1
`define PC_TO_REG    2
`define CSR_TO_REG   3
`define REG_CTRL_BUS 3 : 0

`define SOFT_ITRP  3
`define TIMER_ITRP 7
`define EXTER_ITRP 11
`define ITRP_BUS   11 : 0

`define EXCP_INST_MISAL 0
`define EXCP_INST_ACC   1
`define EXCP_ILG_INST   2
`define EXCP_BRK_PT     3
`define EXCP_LOAD_MISAL 4
`define EXCP_LOAD_ACC   5
`define EXCP_STOR_MISAL 6
`define EXCP_STOR_ACC   7
`define EXCP_ECALL_M    11
`define EXCP_INST_PAGE  12
`define EXCP_LOAD_PAGE  13
`define EXCP_STOR_PAGE  15
`define EXCP_BUS        15 : 0