
//--Sun Jiru, Nanjing University--

`include "defines.v"

module wb_stage (
  input wire clk,
  input wire rst,

  // pipeline control
  output wire wb_allowin,
  
  input wire [`REG_CTRL_BUS] reg_wr_ctrl,
  input wire [`REG_BUS] exe_data,
  input wire [`REG_BUS] mem_data,
  input wire [`REG_BUS] pc_data,
  input wire [`REG_BUS] csr_data,
  
  output wire [`REG_BUS] w_data
  );
  
  assign wb_allowin = 1'b1;

  wire mem_to_reg = reg_wr_ctrl[`MEM_TO_REG];
  wire pc_to_reg  = reg_wr_ctrl[`PC_TO_REG ];
  wire exe_to_reg = reg_wr_ctrl[`EXE_TO_REG];
  wire csr_to_reg = reg_wr_ctrl[`CSR_TO_REG];

  assign w_data = (rst == 1'b1) ? 0 : ((mem_to_reg == 1'b1) ? mem_data : exe_data);
  assign w_data = {64{~rst}} & (
      ({64{mem_to_reg}} & mem_data)
    | ({64{pc_to_reg}}  & (pc_data + 64'd4))
    | ({64{exe_to_reg}} & exe_data)
    | ({64{csr_to_reg}} & csr_data)
  );

endmodule