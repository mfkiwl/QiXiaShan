
//--Sun Jiru, Nanjing University--

`include "defines.v"

module wb_stage (
    input wire rst,
    input wire mem_to_reg,
    input wire [`REG_BUS] exe_data,
    input wire [`REG_BUS] mem_data,

    output wire [`REG_BUS] w_data
);

assign w_data = (rst == 1'b1) ? 0 : ((mem_to_reg == 1'b1) ? mem_data : exe_data);
    
endmodule