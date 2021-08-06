
//--Sun Jiru, Nanjing Univeristy--

`include "defines.v"

module csrfile(
  input clk,
  input rst,
  input csr_wr_ena,
  input [11 : 0] csr_wr_addr,
  input csr_rd_ena,
  input [11 : 0] csr_rd_addr,
  input [`REG_BUS] csr_wr_data,

  output [`REG_BUS] csr_rd_data,
  output [`REG_BUS] csr_o [`CSR_BUS]
  );

  // 0x301 Machine ISA Register
  wire sel_misa = (csr_rd_addr == 12'h301);
  wire rd_misa = sel_misa & csr_rd_ena;
  wire [`REG_BUS] csr_misa = {
    2'b10
    ,4'b0 //WIRI
    ,1'b0 //              25 Z Reserved
    ,1'b0 //              24 Y Reserved
    ,1'b0 //              23 X Non-standard extensions present
    ,1'b0 //              22 W Reserved
    ,1'b0 //              21 V Tentatively reserved for Vector extension 20 U User mode implemented
    ,1'b0 //              20 U User mode implemented
    ,1'b0 //              19 T Tentatively reserved for Transactional Memory extension
    ,1'b0 //              18 S Supervisor mode implemented
    ,1'b0 //              17 R Reserved
    ,1'b0 //              16 Q Quad-precision floating-point extension
    ,1'b0 //              15 P Tentatively reserved for Packed-SIMD extension
    ,1'b0 //              14 O Reserved
    ,1'b0 //              13 N User-level interrupts supported
    ,1'b0 //              12 M Integer Multiply/Divide extension
    ,1'b0 //              11 L Tentatively reserved for Decimal Floating-Point extension
    ,1'b0 //              10 K Reserved
    ,1'b0 //              9 J Reserved
    ,1'b1 //              8 I RV32I/64I/128I base ISA
    ,1'b0 //              7 H Hypervisor mode implemented
    ,1'b0 //              6 G Additional standard extensions present
    ,1'b0 //              5 F Single-precision floating-point extension
    ,1'b0 //              4 E RV32E base ISA
    ,1'b0 //              3 D Double-precision floating-point extension
    ,1'b0 //              2 C Compressed extension
    ,1'b0 //              1 B Tentatively reserved for Bit operations extension
    ,1'b0 //              0 A Atomic extension
  };

  assign csr_o [`CSR_MISA] = csr_misa;
  
  // 0xB00 Cycle Counter
  wire sel_rd_mcycle = (csr_rd_addr == 12'hb00);
  wire sel_wr_mcycle = (csr_wr_addr == 12'hb00);
  wire rd_mcycle = (csr_rd_ena & sel_rd_mcycle);
  wire wr_mcycle = (csr_wr_ena & sel_wr_mcycle);
  reg [`REG_BUS] csr_mcycle;

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      csr_mcycle <= `ZERO_WORD;
    end
    else if (wr_mcycle) begin
      csr_mcycle <= csr_wr_data;
    end
    else begin
      csr_mcycle <= csr_mcycle + 64'b1;
    end
  end

  assign csr_o [`CSR_MCYCLE] = csr_mcycle;

  // 0xF11 Machine Vendor ID Register
  wire sel_mvendorid = (csr_rd_addr == 12'hf11);
  wire rd_mvendorid = (csr_rd_ena & sel_mvendorid);
  wire [`REG_BUS] csr_mvendorid = `ZERO_WORD;
  assign csr_o [`CSR_MVENDORID] = csr_mvendorid;
  
  // 0xF12 Machine Architecture ID Register
  wire sel_marchid= (csr_rd_addr == 12'hf12);
  wire rd_marchid = (csr_rd_ena & sel_marchid);
  wire [`REG_BUS] csr_marchid = `ZERO_WORD;
  assign csr_o [`CSR_MARCHID] = csr_marchid;
  
  // 0xF13 Machine Implementation ID Register
  wire sel_mimpid= (csr_rd_addr == 12'hf13);
  wire rd_mimpid = (csr_rd_ena & sel_mimpid);
  wire [`REG_BUS] csr_mimpid = `ZERO_WORD;
  assign csr_o [`CSR_MIMPID] = csr_mimpid;

  // 0xF14 Hart ID Register
  wire sel_mhartid= (csr_rd_addr == 12'hf14);
  wire rd_mhartid = (csr_rd_ena & sel_mhartid);
  wire [`REG_BUS] csr_mhartid = `ZERO_WORD;
  assign csr_o [`CSR_MHARTID] = csr_mhartid;

  assign csr_rd_data = {64{~rst}} & (
      ({64{rd_misa}}      & csr_misa)
    | ({64{rd_mcycle}}    & csr_mcycle)
    | ({64{rd_mvendorid}} & csr_mvendorid)
    | ({64{rd_marchid}}   & csr_marchid)
    | ({64{rd_mimpid}}    & csr_mimpid)
    | ({64{rd_mhartid}}   & csr_mhartid)
  );
 
endmodule