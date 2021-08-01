
//--Sun Jiru, Nanjing University--

`include "defines.v"

module exe_stage_alu(
  input wire rst,
  input wire [`REG_BUS] op1,
  input wire [`REG_BUS] op2,
  input wire [`OP_BUS] op_info,
  input wire [`ALU_BUS] alu_info,
  input wire is_word_opt,

  output wire [`REG_BUS] alu_output,
  output wire [`BJ_BUS] bj_data
  );
  
  wire op_add  = alu_info[`ALU_ADD];
  wire op_sub  = alu_info[`ALU_SUB];
  wire op_slt  = alu_info[`ALU_SLT];
  wire op_sltu = alu_info[`ALU_SLTU];
  wire op_xor  = alu_info[`ALU_XOR];
  wire op_or   = alu_info[`ALU_OR];
  wire op_and  = alu_info[`ALU_AND];
  wire op_sll  = alu_info[`ALU_SLL];
  wire op_srl  = alu_info[`ALU_SRL];
  wire op_sra  = alu_info[`ALU_SRA];

  // left-shifter and right-shifter
  wire op_shift = op_sll | op_srl | op_sra;
  wire [`REG_BUS] shifter_op1 = op1;
  wire [`REG_BUS] shifter_in1 = {64{op_shift}} &
          //   In order to save area and just use one left-shifter, we
          //   convert the right-shift op into left-shift operation
          (
               (op_srl || op_sra) ? 
                 {
    op1[00], op1[01], op1[02], op1[03],
    op1[04], op1[05], op1[06], op1[07],
    op1[08], op1[09], op1[10], op1[11],
    op1[12], op1[13], op1[14], op1[15],
    op1[16], op1[17], op1[18], op1[19],
    op1[20], op1[21], op1[22], op1[23],
    op1[24], op1[25], op1[26], op1[27],
    op1[28], op1[29], op1[30], op1[31],
    op1[32], op1[33], op1[34], op1[35],
    op1[36], op1[37], op1[38], op1[39],
    op1[40], op1[41], op1[42], op1[43],
    op1[44], op1[45], op1[46], op1[47],
    op1[48], op1[49], op1[50], op1[51],
    op1[52], op1[53], op1[54], op1[55],
    op1[56], op1[57], op1[58], op1[59],
    op1[60], op1[61], op1[62],shifter_op1[63]
                 } : shifter_op1
          );
  wire [4 : 0] shifter_in2 = {5{op_shift}} & op2[4 : 0];

  wire [`REG_BUS] shifter_res = (shifter_in1 << shifter_in2);

  wire [`REG_BUS] sll_res = shifter_res;
  wire [`REG_BUS] srl_res =  
                 {
    shifter_res[00],shifter_res[01],shifter_res[02],shifter_res[03],
    shifter_res[04],shifter_res[05],shifter_res[06],shifter_res[07],
    shifter_res[08],shifter_res[09],shifter_res[10],shifter_res[11],
    shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
    shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
    shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
    shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
    shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31],
    shifter_res[32],shifter_res[33],shifter_res[34],shifter_res[35],
    shifter_res[36],shifter_res[37],shifter_res[38],shifter_res[39],
    shifter_res[40],shifter_res[41],shifter_res[42],shifter_res[43],
    shifter_res[44],shifter_res[45],shifter_res[46],shifter_res[47],
    shifter_res[48],shifter_res[49],shifter_res[50],shifter_res[51],
    shifter_res[52],shifter_res[53],shifter_res[54],shifter_res[55],
    shifter_res[56],shifter_res[57],shifter_res[58],shifter_res[59],
    shifter_res[60],shifter_res[61],shifter_res[62],shifter_res[63]
                 };
  wire [`REG_BUS] eff_mask = (~(64'b0)) >> shifter_in2;
  wire [`REG_BUS] sra_res =
               (srl_res & eff_mask) | ({64{op1[63]}} & (~eff_mask));

  // add & sub operation
  wire temp_add = op_add;
  wire temp_sub = op_sub | op_slt | op_sltu;
  wire op_addsub = temp_add | temp_sub;
  wire op_unsigned = op_sltu;
  wire [64 : 0] adder_op1 = {~op_unsigned & op1[63], op1};
  wire [64 : 0] adder_op2 = {~op_unsigned & op1[63], op2};
  wire [64 : 0] adder_in1 = {65{op_addsub}} & adder_op1;
  wire [64 : 0] adder_in2 = {65{op_addsub}} & (temp_sub ? (~adder_op2) : (adder_op2));
  wire [64 : 0] adder_cin = (op_addsub & op_sub) ? 65'b1 : 65'b0;
  wire [64 : 0] add_res   = adder_in1 + adder_in2 + adder_cin;
  wire [`REG_BUS] slt_res   = {{63{1'b0}}, (op_slt | op_sltu) & add_res[64]};
  wire [`REG_BUS] sltu_res  = slt_res;

  // logic operation
  wire [`REG_BUS] xor_res = op1 ^ op2;
  wire [`REG_BUS] or_res  = op1 | op2;
  wire [`REG_BUS] and_res = op1 & op2;
  
  wire [`REG_BUS] debug1 = 
                      ({64{op_sll}}    & sll_res)
                    | ({64{op_srl}}    & srl_res)
                    | ({64{op_sra}}    & sra_res)
                    | ({64{op_slt}}    & slt_res)
                    | ({64{op_sltu}}   & sltu_res)
                    ;
  wire [`REG_BUS] debug2 = 
                     ({64{op_addsub}} & add_res[63 : 0])
                    | ({64{op_xor}}    & xor_res)
                    | ({64{op_or}}     & or_res)
                    | ({64{op_and}}    & and_res)
                    ;

  wire [`REG_BUS] temp_output = {64{~rst}} & ( 
                      ({64{op_sll}}    & sll_res)
                    | ({64{op_srl}}    & srl_res)
                    | ({64{op_sra}}    & sra_res)
                    | ({64{op_slt}}    & slt_res)
                    | ({64{op_sltu}}   & sltu_res)
                    | ({64{op_add | op_sub}} & add_res[63 : 0])
                    | ({64{op_xor}}    & xor_res)
                    | ({64{op_or}}     & or_res)
                    | ({64{op_and}}    & and_res)
                      );
  assign alu_output = {is_word_opt ? {32{temp_output[31]}} : temp_output[63 : 32], temp_output[31 : 0]};
  
  wire eq_res = ~(|xor_res);
  assign bj_data[`BJ_BEQ]  = eq_res;
  assign bj_data[`BJ_BNE]  = ~eq_res;
  assign bj_data[`BJ_BLT]  = slt_res[0];
  assign bj_data[`BJ_BGE]  = ~slt_res[0];
  assign bj_data[`BJ_BLTU] = sltu_res[0];
  assign bj_data[`BJ_BGEU] = ~sltu_res[0];
  assign bj_data[`BJ_JALR] = 1'b1;
  assign bj_data[`BJ_JAL]  = 1'b1;
endmodule