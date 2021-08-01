`include "defines.v"

module mem_stage(
  input rst,
  input [`REG_BUS] r_data2,
  input [`LOAD_BUS] load_info,
  input [`SAVE_BUS] save_info,
  input [`REG_BUS] mem_addr,
  input [`REG_BUS] mem_rd_data,

  output [`REG_BUS] mem_data,
  output [`REG_BUS] mem_wr_data,
  output [7 : 0] byte_enable
);

wire addr_0 = (mem_addr[2 : 0] == 3'h0);
wire addr_1 = (mem_addr[2 : 0] == 3'h1);
wire addr_2 = (mem_addr[2 : 0] == 3'h2);
wire addr_3 = (mem_addr[2 : 0] == 3'h3);
wire addr_4 = (mem_addr[2 : 0] == 3'h4);
wire addr_5 = (mem_addr[2 : 0] == 3'h5);
wire addr_6 = (mem_addr[2 : 0] == 3'h6);
wire addr_7 = (mem_addr[2 : 0] == 3'h7);

wire op_lb  = load_info[`LOAD_LB];
wire op_lh  = load_info[`LOAD_LH];
wire op_lw  = load_info[`LOAD_LW];
wire op_ld  = load_info[`LOAD_LD];
wire op_lbu = load_info[`LOAD_LBU];
wire op_lhu = load_info[`LOAD_LHU];
wire op_lwu = load_info[`LOAD_LWU];

wire [`REG_BUS] mem_part = mem_rd_data >> ({mem_addr[2 : 0], 3'b0});

assign mem_data = {64{~rst}} & (
                  ({64{op_lb}} & {{56{mem_part[7 ]}}, mem_part[7  : 0]}) |
                  ({64{op_lh}} & {{48{mem_part[15]}}, mem_part[15 : 0]}) |
                  ({64{op_lw}} & {{32{mem_part[31]}}, mem_part[31 : 0]}) |
                  ({64{op_ld}} & mem_part) |
                  ({64{op_lbu}} & {56'b0, mem_part[7  : 0]}) |
                  ({64{op_lhu}} & {48'b0, mem_part[15 : 0]}) |
                  ({64{op_lwu}} & {32'b0, mem_part[31 : 0]})
);

wire op_sb = save_info[`SAVE_SB];
wire op_sh = save_info[`SAVE_SH];
wire op_sw = save_info[`SAVE_SW];
wire op_sd = save_info[`SAVE_SD];

assign byte_enable[0] = (op_sb & addr_0) | (op_sh & addr_0) | (op_sw & addr_0) | (op_sd & addr_0);
assign byte_enable[1] = (op_sb & addr_1) | (op_sh & addr_0) | (op_sw & addr_0) | (op_sd & addr_0);
assign byte_enable[2] = (op_sb & addr_2) | (op_sh & addr_2) | (op_sw & addr_0) | (op_sd & addr_0);
assign byte_enable[3] = (op_sb & addr_3) | (op_sh & addr_2) | (op_sw & addr_0) | (op_sd & addr_0);
assign byte_enable[4] = (op_sb & addr_4) | (op_sh & addr_4) | (op_sw & addr_4) | (op_sd & addr_0);
assign byte_enable[5] = (op_sb & addr_5) | (op_sh & addr_4) | (op_sw & addr_4) | (op_sd & addr_0);
assign byte_enable[6] = (op_sb & addr_6) | (op_sh & addr_6) | (op_sw & addr_4) | (op_sd & addr_0);
assign byte_enable[7] = (op_sb & addr_7) | (op_sh & addr_6) | (op_sw & addr_4) | (op_sd & addr_0);

assign mem_wr_data = r_data2 << ({mem_addr[2 : 0], 3'b0});

endmodule