
//--xuezhen--

`include "defines.v"

module exe_stage(
  input wire rst,
  input wire [4 : 0] inst_type_i,
  input wire [7 : 0] inst_opcode,
  input wire [`REG_BUS] exe_op1,
  input wire [`REG_BUS] exe_op2,
  input wire is_word_opt,
  input wire [`OP_BUS] op_info,
  input wire [`ALU_BUS] alu_info,
  inout wire [`BJ_BUS] bj_info,

  output reg  [`REG_BUS]rd_data,
  output wire bj_ena
);

// alu -> bj
wire [`BJ_BUS] bj_data;
/*
exe_stage_alu Exe_stage_alu(
  .rst(rst),
  .op1(exe_op1),
  .op2(exe_op2),
  .op_info(op_info),
  .alu_info(alu_info),
  .is_word_opt(is_word_opt),

  .alu_output(rd_data),
  .bj_data(bj_data)
);

exe_stage_bj Exe_stage_bj(
  .rst(rst),
  .bj_info(bj_info),
  .bj_data(bj_data),

  .bj_ena(bj_ena)
);
*/

always@( * )
begin
  if( rst == 1'b1 )
  begin
    rd_data = `ZERO_WORD;
  end
  else
  begin
    case( inst_opcode )
	  `INST_ADD: begin rd_data = exe_op1 + exe_op2;  end
	  default:   begin rd_data = `ZERO_WORD; end
	endcase
  end
end



endmodule
