`timescale 1ns / 1ps
//--Sun Jiru, Nanjing University

module RAM_1W2R(
  input clk,
    
  input [`REG_BUS]inst_addr,
  input inst_ena,
  output [31:0]inst,

  // DATA PORT
  input mem_wr_ena,
  input mem_rd_ena,
  input [7:0]byte_enable,
  input [`REG_BUS]mem_addr,
  input [`REG_BUS]mem_wr_data,
  output [`REG_BUS]mem_rd_data
);

  // INST PORT

  wire[`REG_BUS] inst_2 = ram_read_helper(inst_ena,{3'b000,(inst_addr-`PC_START)>>3});

  assign inst = inst_addr[2] ? inst_2[63:32] : inst_2[31:0];

  // DATA PORT 
    
  assign mem_rd_data = ram_read_helper(mem_rd_ena, {3'b000,(mem_addr-`PC_START)>>3});

  // 掩码转换
  wire [`REG_BUS] wmask = { {8{byte_enable[7]}},
                            {8{byte_enable[6]}},
                            {8{byte_enable[5]}},
                            {8{byte_enable[4]}},
                            {8{byte_enable[3]}},
                            {8{byte_enable[2]}},
                            {8{byte_enable[1]}},
                            {8{byte_enable[0]}}};

  //wire [`REG_BUS] wr_data = {mem_wr_data[31:0],mem_rd_data[63:32]};

  always @(posedge clk) begin
    ram_write_helper((mem_addr-`PC_START)>>3, mem_wr_data, wmask, mem_wr_ena);
  end

endmodule

