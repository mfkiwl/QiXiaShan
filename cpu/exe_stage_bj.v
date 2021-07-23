//branch and jump
//--Sun Jiru, Nanjing University--
`include "defines.v"

module exe_stage_bj (
  input wire rst,
  input wire [`BJ_BUS] bj_info,
  input wire [`BJ_BUS] bj_data,
  
  output wire bj_ena
  );
  assign bj_ena = ~rst & (|(bj_info & bj_data));
endmodule