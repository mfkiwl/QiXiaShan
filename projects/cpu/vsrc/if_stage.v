
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

  output wire [63 : 0]pc_o,
  output wire [`EXCP_BUS] if_excp
  );

  reg [`REG_BUS]pc;

  // fetch an instruction
  always@(posedge clk)
  begin
    if( rst == 1'b1 ) begin
      pc <= `PC_START - 4;
    end
    else begin
      pc <= excp_jmp_ena ? excp_pc :
            bj_ena       ? new_pc  :
            (pc + 4) ;
    end
  end
  
  assign pc_o = pc;
  assign if_excp[`EXCP_INST_MISAL] = (pc[1] | pc[0]);

endmodule
