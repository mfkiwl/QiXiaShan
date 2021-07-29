`include "defines.v"

module mem_stage(
  input rst,
  input [`REG_BUS] r_data2,
  input [`LOAD_BUS] load_info,
  input [`SAVE_BUS] save_info,
  input [`REG_BUS] mem_rd_data,

  output [`REG_BUS] mem_data,
  output [`REG_BUS] mem_wr_data,
  output [7 : 0] byte_enable
);

wire op_lb  = load_info[`LOAD_LB];
wire op_lh  = load_info[`LOAD_LH];
wire op_lw  = load_info[`LOAD_LW];
wire op_ld  = load_info[`LOAD_LD];
wire op_lbu = load_info[`LOAD_LBU];
wire op_lhu = load_info[`LOAD_LHU];
wire op_lwu = load_info[`LOAD_LWU];

assign mem_data = {64{~rst}} & (
                  ({64{op_lb}} & {{56{mem_rd_data[7 ]}}, mem_rd_data[7  : 0]}) |
                  ({64{op_lh}} & {{48{mem_rd_data[15]}}, mem_rd_data[15 : 0]}) |
                  ({64{op_lw}} & {{32{mem_rd_data[31]}}, mem_rd_data[31 : 0]}) |
                  ({64{op_ld}} & mem_rd_data) |
                  ({64{op_lbu}} & {56'b0, mem_rd_data[7  : 0]}) |
                  ({64{op_lhu}} & {48'b0, mem_rd_data[15 : 0]}) |
                  ({64{op_lwu}} & {32'b0, mem_rd_data[31 : 0]})
);

wire op_sb = save_info[`SAVE_SB];
wire op_sh = save_info[`SAVE_SH];
wire op_sw = save_info[`SAVE_SW];
wire op_sd = save_info[`SAVE_SD];

assign byte_enable[0] = op_sb | op_sh | op_sw | op_sd;
assign byte_enable[1] = op_sh | op_sw | op_sd;
assign byte_enable[2] = op_sw | op_sd;
assign byte_enable[3] = op_sw | op_sd;
assign byte_enable[4] = op_sd;
assign byte_enable[5] = op_sd;
assign byte_enable[6] = op_sd;
assign byte_enable[7] = op_sd;

assign mem_wr_data = r_data2;

endmodule