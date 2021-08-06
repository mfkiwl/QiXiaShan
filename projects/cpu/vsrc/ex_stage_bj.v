//branch and jump
//--Sun Jiru, Nanjing University--

`include "defines.v"

module ex_stage_bj (
  input wire rst,
  input wire [`BJ_BUS] bj_info,
  input wire [`BJ_BUS] bj_data,
  input wire [`REG_BUS] jmp_imm,
  input wire [`REG_BUS] exe_op1,
  input wire [`REG_BUS] now_pc,
  
  output wire bj_ena,
  output wire [`REG_BUS] new_pc
  );
  
  assign new_pc = jmp_imm + (bj_info[`BJ_JALR] ? exe_op1 : now_pc);
  assign bj_ena = ~rst & (|(bj_info & bj_data));
endmodule