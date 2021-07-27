`include "defines.v"

module mem_stage(
  input wire rst,
  input wire [`REG_BUS]addr,
  input wire mem_w_ena,

  output wire [`REG_BUS] mem_r_data
);

assign mem_r_data = 64'b0;

endmodule