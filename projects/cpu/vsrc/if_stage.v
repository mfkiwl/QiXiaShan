
/* verilator lint_off UNUSED */
//--Sun Jiru, Nanjing University--

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  input wire bj_ena,
  input wire [`REG_BUS] new_pc,
  
  input wire excp_jmp_ena,
  input wire [`REG_BUS] excp_pc,

  output wire [63 : 0]pc_o
  
  );

  reg [`REG_BUS]pc;

  // fetch an instruction
  always@(posedge clk)
  begin
    if( rst == 1'b1 ) begin
      pc <= `PC_START ;
    end
    else begin
      pc <= excp_jmp_ena ? excp_pc :
            bj_ena       ? new_pc  :
            (pc + 4) ;
    end
  end
  
  assign pc_o = pc;

endmodule
