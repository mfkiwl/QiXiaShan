
/* verilator lint_off UNUSED */
//--Sun Jiru, Nanjing University--

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  
  // pipeline control
  input wire id_allowin,
  output wire if_ready_go,
  output wire if_id_valid,

  input wire bj_ena,
  input wire [`REG_BUS] new_pc,
  
  input wire excp_jmp_ena,
  input wire [`REG_BUS] excp_pc,

  output reg [`REG_BUS] pc,
  output wire [`EXCP_BUS] if_excp
  );
  
  // pipeline control
  wire if_valid = 1'b1;
  assign if_ready_go = 1'b1;
  assign if_id_valid = if_valid && if_ready_go;

  // fetch an instruction
  always@(posedge clk)
  begin
    if( rst == 1'b1 ) begin
      pc <= `PC_START - 4;
    end
    else if (id_allowin) begin
      pc <= excp_jmp_ena ? excp_pc :
            bj_ena       ? new_pc  :
            (pc + 4) ;
    end
    else begin
      pc <= pc;
    end
  end

  assign if_excp[`EXCP_INST_MISAL] = (pc[1] | pc[0]);

endmodule
