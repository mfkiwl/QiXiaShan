
//--Sun Jiru, Nanjing University

`include "defines.v"

module reg_ifid(
  input clk,
  input rst,
  input [`REG_BUS] if_pc,
  input [31 : 0] if_inst,
  
  output [`REG_BUS] pc_id,
  output [31 : 0] inst_id
  );
  
  always@ (posedge clk) begin
    pc_id <= {64{~rst}} & if_pc;
    inst_id <= {32{~rst}} & if_inst;
  end

endmodule