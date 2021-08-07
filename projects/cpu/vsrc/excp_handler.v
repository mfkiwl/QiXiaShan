//--Sun Jiru, Nanjing Uniersity--

`include "defines.v"

module excp_handler (
  input wire [`EXCP_BUS] if_excp,
  input wire [`EXCP_BUS] id_excp,
  input wire [`EXCP_BUS] mem_excp,
  input wire [`ITRP_BUS] itrp_info,
  input wire [`REG_BUS] now_pc,
  input wire [31 : 0] now_inst,
  input wire [`REG_BUS] mem_acc_addr,
  input wire excp_exit,

  output wire excp_enter,
  
  // to CSRs
  output wire [`REG_BUS] mcause_wr_data,
  output wire [`REG_BUS] mepc_wr_data,
  output wire [`REG_BUS] mtval_wr_data,
  output wire [`REG_BUS] mstatus_wr_data,
  
  // from CSRs
  input wire [`REG_BUS] mstatus_rd_data,
  input wire [`REG_BUS] mtvec_rd_data,
  input wire [`REG_BUS] mepc_rd_data,

  // to if_stage
  output wire excp_jmp_ena,
  output wire [`EXCP_BUS] excp_pc
  );


  // generate excp_ena
  wire [`EXCP_BUS] excp_info = if_excp | id_excp | mem_excp;
  wire sp_excp_ena = |excp_info;
  wire sp_itrp_ena = |itrp_info;
  assign excp_enter = sp_excp_ena | sp_itrp_ena;
  
  // generate mcause
  // decode machine interruption
  wire soft_itrp = itrp_info[`SOFT_ITRP];
  wire timer_itrp = itrp_info[`TIMER_ITRP];
  wire exter_itrp = itrp_info[`EXTER_ITRP];
  wire [62 : 0] itrp_idx = (
      ({63{soft_itrp}}       & 63'd3)
    | ({63{timer_itrp}}      & 63'd7)
    | ({63{exter_itrp}}      & 63'd11)
  );
  // decode exception
  wire excp_inst_misal = excp_info[`EXCP_INST_MISAL];
  wire excp_inst_acc = excp_info[`EXCP_INST_ACC];
  wire excp_ilg_inst = excp_info[`EXCP_ILG_INST];
  wire excp_brk_pt = excp_info[`EXCP_BRK_PT];
  wire excp_load_misal = excp_info[`EXCP_LOAD_MISAL];
  wire excp_load_acc = excp_info[`EXCP_LOAD_ACC];
  wire excp_stor_misal = excp_info[`EXCP_STOR_MISAL];
  wire excp_stor_acc = excp_info[`EXCP_STOR_ACC];
  wire excp_ecall_m = excp_info[`EXCP_ECALL_M];
  wire excp_inst_page = excp_info[`EXCP_INST_PAGE];
  wire excp_load_page = excp_info[`EXCP_LOAD_PAGE];
  wire excp_stor_page = excp_info[`EXCP_STOR_PAGE];
  wire [62 : 0] excp_idx = (
      ({63{excp_inst_misal}} & 63'd0)
    | ({63{excp_inst_acc}}   & 63'd1)
    | ({63{excp_ilg_inst}}   & 63'd2)
    | ({63{excp_brk_pt}}     & 63'd3)
    | ({63{excp_load_misal}} & 63'd4)
    | ({63{excp_load_acc}}   & 63'd5)
    | ({63{excp_stor_misal}} & 63'd6)
    | ({63{excp_stor_acc}}   & 63'd7)
    | ({63{excp_ecall_m}}    & 63'd11)
    | ({63{excp_inst_page}}  & 63'd12)
    | ({63{excp_load_page}}  & 63'd13)
    | ({63{excp_stor_page}}  & 63'd15)
  );
  wire inst_acc_fault = excp_inst_misal | excp_inst_acc | excp_inst_page ;
  wire mem_acc_fault = excp_load_misal | excp_load_acc | excp_stor_misal 
                     | excp_stor_acc | excp_load_page | excp_stor_page;

  assign mcause_wr_data = { sp_itrp_ena ? 1'b1 : 1'b0,
    (itrp_idx | excp_idx)
  };
  // TODO: interruption should have higher priority here
  
  assign mepc_wr_data = (
      ({64{sp_itrp_ena}} & now_pc + 4)
    | ({64{sp_excp_ena}} & now_pc)
  );

  assign mtval_wr_data = (
      ({64{inst_acc_fault}} & now_pc)
    | ({64{excp_ilg_inst}}  & {32'b0, now_inst})
    | ({64{mem_acc_fault}}  & mem_acc_addr)
  );
  
  wire [63 : 8] mstatus_p1 = mstatus_rd_data[63 : 8];
  wire mstatus_mpie = mstatus_rd_data[7];
  wire [6 : 4] mstatus_p2 = mstatus_rd_data[6 : 4];
  wire mstatus_mie = mstatus_rd_data[3];
  wire [2 : 0] mstatus_p3 = mstatus_rd_data[2 : 0];
  wire [`REG_BUS] mstatus_excp_enter = {mstatus_p1, mstatus_mie, mstatus_p2, 1'b0, mstatus_p3};
  wire [`REG_BUS] mstatus_excp_exit = {mstatus_p1, 1'b1, mstatus_p2, mstatus_mpie, mstatus_p3};

  assign mstatus_wr_data = (
      ({64{excp_enter}} & mstatus_excp_enter)
    | ({64{excp_exit}} & mstatus_excp_exit)
  );

  wire [1  : 0] mtvec_mode = mtvec_rd_data[1  : 0];
  wire mtvec_mode0 = (mtvec_mode == 2'b0);
  wire mtvec_mode1 = (mtvec_mode == 2'b1);
  wire [61 : 0] mtvec_base = mtvec_rd_data[63 : 2];
  wire [63 : 0] excp_enter_pc = 
      ({64{mtvec_mode0}} & {mtvec_base, 2'b0}) // mode0, jump to base
    | ({64{mtvec_mode1}} & { // mode1
           ({60{sp_excp_ena}} & mtvec_base) // when exception, jump to base
         | ({60{sp_itrp_ena}} & (mtvec_base + itrp_idx)) // when interruption, jump to base + code
        , 2'b0
      });
  wire [63 : 0] excp_exit_pc = mepc_rd_data;
  assign excp_jmp_ena = excp_enter | excp_exit;
  assign excp_pc = ({64{excp_enter}} & excp_enter_pc) | ({64{excp_exit}} & excp_exit_pc);
endmodule