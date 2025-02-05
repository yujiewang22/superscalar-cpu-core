`default_nettype none
`include "constants.vh"

module pipeline (
    input  wire                        clk,
    input  wire                        rst_n,
    // Interact with IMEM
    output wire [`RV32_ADDR_WIDTH-1:0] o_imem_addr,
    input  wire [`IMEM_DATA_WIDTH-1:0] i_imem_rd_data,
    // Interact with DMEM
    output wire [`RV32_ADDR_WIDTH-1:0] o_dmem_addr,
    input  wire [`DMEM_DATA_WIDTH-1:0] i_dmem_rd_data,
    output wire                        o_dmem_wr_en,
    output wire [`RV32_DATA_WIDTH-1:0] o_dmem_wr_data
);

    // ******************************************************************* //
    //                              Signals                                //
    // ******************************************************************* //

    // ---------------------------------------------------- //
    // --------------------- Control ---------------------- //
    // ---------------------------------------------------- // 

    wire                        if_kill;
    wire                        id_kill;
    wire                        dp_kill;

    wire                        if_stall;
    wire                        id_stall;
    wire                        dp_stall; 

    // ---------------------------------------------------- //
    // --------------------- IF-Stage --------------------- //
    // ---------------------------------------------------- // 

    wire [`RV32_PC_WIDTH-1:0]   if_pc;

    wire [`IMEM_DATA_WIDTH-1:0] if_imem_rd_data;
    wire                        if_inst_vld_1;
    wire                        if_inst_vld_2;
    wire [`RV32_INST_WIDTH-1:0] if_inst_1;
    wire [`RV32_INST_WIDTH-1:0] if_inst_2;

    wire [`RV32_PC_WIDTH-1:0]   if_pc_1;
    wire [`RV32_PC_WIDTH-1:0]   if_pc_2;
    wire [`GSH_GHR_WIDTH-1:0]   if_ghr;
    wire                        if_pred_jmp;
    wire [`RV32_PC_WIDTH-1:0]   if_pc_btb;

    wire [`RV32_PC_WIDTH-1:0]   if_pred_jmpaddr_1;
    wire [`RV32_PC_WIDTH-1:0]   if_pred_jmpaddr_2;

    // ---------------------------------------------------- //
    // --------------------- ID-Stage --------------------- //
    // ---------------------------------------------------- // 

    reg                         id_pc_1;
    reg                         id_inst_vld_1;
    reg  [`RV32_INST_WIDTH-1:0] id_inst_1;
    wire                        id_illegal_1;
    wire                        id_rs1_rd_en_1;
    wire                        id_rs2_rd_en_1;
    wire                        id_rd_wr_en_1;
    wire [`RV32_ARF_SEL-1:0]    id_rs1_rd_addr_1;
    wire [`RV32_ARF_SEL-1:0]    id_rs2_rd_addr_1;
    wire [`RV32_ARF_SEL-1:0]    id_rd_wr_addr_1;
    wire [`IMM_TYPE_SEL-1:0]    id_imm_type_sel_1;
    wire [`ALU_OP_SEL-1:0]      id_alu_op_sel_1;
    wire [`ALU_SRC1_SEL-1:0]    id_alu_src1_sel_1;
    wire [`ALU_SRC2_SEL-1:0]    id_alu_src2_sel_1;
    wire                        id_mul_signed1_1;
    wire                        id_mul_signed2_1;
    wire                        id_mul_sel_high_1;
    wire                        id_is_st_1;
    wire                        id_is_br_1;
    wire                        id_is_jal_1;
    wire                        id_is_jalr_1;
    reg  [`RV32_PC_WIDTH-1:0]   id_pred_jmpaddr_1;
    wire [`RS_SEL-1:0]          id_rs_sel_1;

    reg                         id_pc_2;
    reg                         id_inst_vld_2;
    reg  [`RV32_INST_WIDTH-1:0] id_inst_2;
    wire                        id_illegal_2;
    wire                        id_rs1_rd_en_2;
    wire                        id_rs2_rd_en_2;
    wire                        id_rd_wr_en_2;
    wire [`RV32_ARF_SEL-1:0]    id_rs1_rd_addr_2;
    wire [`RV32_ARF_SEL-1:0]    id_rs2_rd_addr_2;
    wire [`RV32_ARF_SEL-1:0]    id_rd_wr_addr_2;
    wire [`IMM_TYPE_SEL-1:0]    id_imm_type_sel_2;
    wire [`ALU_OP_SEL-1:0]      id_alu_op_sel_2;
    wire [`ALU_SRC1_SEL-1:0]    id_alu_src1_sel_2;
    wire [`ALU_SRC2_SEL-1:0]    id_alu_src2_sel_2;
    wire                        id_mul_signed1_2;
    wire                        id_mul_signed2_2;
    wire                        id_mul_sel_high_2;
    wire                        id_is_st_2;
    wire                        id_is_br_2;
    wire                        id_is_jal_2;
    wire                        id_is_jalr_2;
    reg  [`RV32_PC_WIDTH-1:0]   id_pred_jmpaddr_2;
    wire [`RS_SEL-1:0]          id_rs_sel_2;

    reg  [`GSH_GHR_WIDTH-1:0]   id_ghr;

    wire                        id_sptag_gen_allocable;
    wire                        id_inst_sp_1;
    wire                        id_inst_sp_2;
    wire [`SPTAG_WIDTH-1:0]     id_inst_sptag_1;
    wire [`SPTAG_WIDTH-1:0]     id_inst_sptag_2;

    // ---------------------------------------------------- //
    // --------------------- DP-Stage --------------------- //
    // ---------------------------------------------------- // 

    reg  [`RV32_PC_WIDTH-1:0]   dp_pc_1;
    reg  [`RV32_INST_WIDTH-1:0] dp_inst_1;
    reg                         dp_rs1_rd_en_1;
    reg                         dp_rs2_rd_en_1;
    reg                         dp_rd_wr_en_1;
    reg  [`RV32_ARF_SEL-1:0]    dp_rs1_rd_addr_1;
    reg  [`RV32_ARF_SEL-1:0]    dp_rs2_rd_addr_1;
    reg  [`RV32_ARF_SEL-1:0]    dp_rd_wr_addr_1;
    reg  [`IMM_TYPE_SEL-1:0]    dp_imm_type_sel_1;
    reg  [`ALU_OP_SEL-1:0]      dp_alu_op_sel_1;
    reg  [`ALU_SRC1_SEL-1:0]    dp_alu_src1_sel_1;
    reg  [`ALU_SRC2_SEL-1:0]    dp_alu_src2_sel_1;
    reg                         dp_mul_signed1_1;
    reg                         dp_mul_signed2_1;
    reg                         dp_mul_sel_high_1;
    reg                         dp_is_st_1;
    reg                         dp_is_br_1;
    reg                         dp_is_jal_1;
    reg                         dp_is_jalr_1;
    reg  [`RV32_PC_WIDTH-1:0]   dp_pred_jmpaddr_1;
    reg  [`RS_SEL-1:0]          dp_rs_sel_1;

    reg  [`RV32_PC_WIDTH-1:0]   dp_pc_2;
    reg  [`RV32_INST_WIDTH-1:0] dp_inst_2;
    reg                         dp_rs1_rd_en_2;
    reg                         dp_rs2_rd_en_2;
    reg                         dp_rd_wr_en_2;
    reg  [`RV32_ARF_SEL-1:0]    dp_rs1_rd_addr_2;
    reg  [`RV32_ARF_SEL-1:0]    dp_rs2_rd_addr_2;
    reg  [`RV32_ARF_SEL-1:0]    dp_rd_wr_addr_2;
    reg  [`IMM_TYPE_SEL-1:0]    dp_imm_type_sel_2;
    reg  [`ALU_OP_SEL-1:0]      dp_alu_op_sel_2;
    reg  [`ALU_SRC1_SEL-1:0]    dp_alu_src1_sel_2;
    reg  [`ALU_SRC2_SEL-1:0]    dp_alu_src2_sel_2;
    reg                         dp_mul_signed1_2;
    reg                         dp_mul_signed2_2;
    reg                         dp_mul_sel_high_2;
    reg                         dp_is_st_2;
    reg                         dp_is_br_2;
    reg                         dp_is_jal_2;
    reg                         dp_is_jalr_2;
    reg  [`RV32_PC_WIDTH-1:0]   dp_pred_jmpaddr_2;
    reg  [`RS_SEL-1:0]          dp_rs_sel_2;

    reg  [`GSH_GHR_WIDTH-1:0]   dp_ghr;

    reg                         dp_vld_1;
    reg                         dp_vld_2;

    wire                        dp_freelist_allocable;
    wire [`ROB_ENT_SEL-1:0]     dp_ptr_1;
    wire [`ROB_ENT_SEL-1:0]     dp_ptr_2;

    wire                        dp_rs1_rd_busy_1;
    wire                        dp_rs2_rd_busy_1;
    wire                        dp_rs1_rd_busy_2;
    wire                        dp_rs2_rd_busy_2;
    wire [`RRF_ENT_SEL-1:0]     dp_rs1_rd_rrftag_1;
    wire [`RRF_ENT_SEL-1:0]     dp_rs2_rd_rrftag_1;
    wire [`RRF_ENT_SEL-1:0]     dp_rs1_rd_rrftag_2;
    wire [`RRF_ENT_SEL-1:0]     dp_rs2_rd_rrftag_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_rd_data_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_rd_data_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_rd_data_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_rd_data_2;

    wire                        dp_rs1_rd_vld_1;
    wire                        dp_rs2_rd_vld_1;
    wire                        dp_rs1_rd_vld_2;
    wire                        dp_rs2_rd_vld_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_rd_rrfdata_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_rd_rrfdata_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_rd_rrfdata_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_rd_rrfdata_2;

    wire                        dp_rs1_srcopr_vld_1;
    wire                        dp_rs2_srcopr_vld_1;
    wire                        dp_rs1_srcopr_vld_2;
    wire                        dp_rs2_srcopr_vld_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_srcopr_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_srcopr_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_srcopr_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_srcopr_2;

    wire                        dp_rs1_srcopr_fwd_vld_1;
    wire                        dp_rs2_srcopr_fwd_vld_1;
    wire                        dp_rs1_srcopr_fwd_vld_2;
    wire                        dp_rs2_srcopr_fwd_vld_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_srcopr_fwd_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_srcopr_fwd_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs1_srcopr_fwd_2;
    wire [`RV32_DATA_WIDTH-1:0] dp_rs2_srcopr_fwd_2;

    wire [`RV32_DATA_WIDTH-1:0] dp_imm_1;
    wire [`RV32_DATA_WIDTH-1:0] dp_imm_2;

    wire                        dp_rs_alu_req_1;
    wire                        dp_rs_alu_req_2;
    wire [`DP_NUM_WIDTH-1:0]    dp_rs_alu_req_num;
    wire                        dp_rs_mul_req_1;
    wire                        dp_rs_mul_req_2;
    wire [`DP_NUM_WIDTH-1:0]    dp_rs_mul_req_num;
    wire                        dp_rs_ldst_req_1;
    wire                        dp_rs_ldst_req_2;
    wire [`DP_NUM_WIDTH-1:0]    dp_rs_ldst_req_num;
    wire                        dp_rs_br_req_1;
    wire                        dp_rs_br_req_2;
    wire [`DP_NUM_WIDTH-1:0]    dp_rs_br_req_num;

    wire [`RS_ALU_ENT_NUM-1:0]  dp_rs_alu_busy_vec;
    wire                        dp_rs_alu_allocable;
    wire                        dp_rs_alu_alloc_sel_vld_1;  
    wire                        dp_rs_alu_alloc_sel_vld_2; 
    wire [`RS_ALU_ENT_SEL-1:0]  dp_rs_alu_alloc_sel_1;
    wire [`RS_ALU_ENT_SEL-1:0]  dp_rs_alu_alloc_sel_2;

    wire [`RS_MUL_ENT_NUM-1:0]  dp_rs_mul_busy_vec;
    wire                        dp_rs_mul_allocable;
    wire                        dp_rs_mul_alloc_sel_vld_1;  
    wire                        dp_rs_mul_alloc_sel_vld_2; 
    wire [`RS_MUL_ENT_SEL-1:0]  dp_rs_mul_alloc_sel_1;
    wire [`RS_MUL_ENT_SEL-1:0]  dp_rs_mul_alloc_sel_2;

    wire [`RS_LDST_ENT_NUM-1:0] dp_rs_ldst_busy_vec;
    wire                        dp_rs_ldst_allocable;
    wire                        dp_rs_ldst_alloc_sel_vld_1;  
    wire                        dp_rs_ldst_alloc_sel_vld_2; 
    wire [`RS_LDST_ENT_SEL-1:0] dp_rs_ldst_alloc_sel_1;
    wire [`RS_LDST_ENT_SEL-1:0] dp_rs_ldst_alloc_sel_2;

    wire [`RS_BR_ENT_NUM-1:0]   dp_rs_br_busy_vec;
    wire                        dp_rs_br_allocable;
    wire                        dp_rs_br_alloc_sel_vld_1;    
    wire                        dp_rs_br_alloc_sel_vld_2;    
    wire [`RS_BR_ENT_SEL-1:0]   dp_rs_br_alloc_sel_1;
    wire [`RS_BR_ENT_SEL-1:0]   dp_rs_br_alloc_sel_2;

    // ---------------------------------------------------- //
    // --------------------- IS-Stage --------------------- //
    // ---------------------------------------------------- //  
 
    wire [`RS_ALU_ENT_NUM-1:0]  is_rs_alu_vld_vec;
    wire                        is_rs_alu_sel_vld;
    wire [`RS_ALU_ENT_SEL-1:0]  is_rs_alu_sel;

    wire [`RS_MUL_ENT_NUM-1:0]  is_rs_mul_vld_vec;
    wire                        is_rs_mul_sel_vld;
    wire [`RS_MUL_ENT_SEL-1:0]  is_rs_mul_sel;

    wire [`RS_LDST_ENT_NUM-1:0] is_rs_ldst_vld_vec;
    wire                        is_rs_ldst_sel_vld;
    wire [`RS_LDST_ENT_SEL-1:0] is_rs_ldst_sel;

    wire [`RS_BR_ENT_NUM-1:0]   is_rs_br_vld_vec;
    wire                        is_rs_br_sel_vld;
    wire [`RS_BR_ENT_SEL-1:0]   is_rs_br_sel;

    wire                        is_rs_alu_vld;
    wire                        is_rs_mul_vld;
    wire                        is_rs_ldst_vld;
    wire                        is_rs_br_vld;

    wire [`ALU_OP_SEL-1:0]      is_alu_op_sel;
    wire [`ALU_SRC1_SEL-1:0]    is_alu_src1_sel;
    wire [`ALU_SRC2_SEL-1:0]    is_alu_src2_sel;
    wire [`RV32_DATA_WIDTH-1:0] is_alu_rs1_srcopr;
    wire [`RV32_DATA_WIDTH-1:0] is_alu_rs2_srcopr;
    wire [`RV32_PC_WIDTH-1:0]   is_alu_pc;
    wire [`RV32_DATA_WIDTH-1:0] is_alu_imm;
    wire [`RRF_ENT_SEL-1:0]     is_alu_rrftag;

    wire                        is_mul_signed1;
    wire                        is_mul_signed2;
    wire                        is_mul_sel_high;
    wire [`RV32_DATA_WIDTH-1:0] is_mul_rs1_srcopr;
    wire [`RV32_DATA_WIDTH-1:0] is_mul_rs2_srcopr;
    wire [`RRF_ENT_SEL-1:0]     is_mul_rrftag;

    wire [`RV32_DATA_WIDTH-1:0] is_ldst_rs1_srcopr;
    wire [`RV32_DATA_WIDTH-1:0] is_ldst_rs2_srcopr;
    wire [`RV32_DATA_WIDTH-1:0] is_ldst_imm;
    wire                        is_ldst_is_st;
    wire [`RRF_ENT_SEL-1:0]     is_ldst_rrftag;

    wire                        is_br_is_jal;
    wire                        is_br_is_jalr;
    wire [`ALU_OP_SEL-1:0]      is_br_alu_op_sel;
    wire [`RV32_DATA_WIDTH-1:0] is_br_rs1_srcopr;
    wire [`RV32_DATA_WIDTH-1:0] is_br_rs2_srcopr;
    wire [`RV32_PC_WIDTH-1:0]   is_br_pc;
    wire [`RV32_DATA_WIDTH-1:0] is_br_imm;
    wire [`RV32_PC_WIDTH-1:0]   is_br_pred_jmpaddr;
    wire [`RRF_ENT_SEL-1:0]     is_br_rrftag; 

    // ---------------------------------------------------- //
    // --------------------- EX-Stage --------------------- //
    // ---------------------------------------------------- //  

    wire                        ex_alu_accessable;
    reg  [`ALU_OP_SEL-1:0]      ex_alu_op_sel;
    reg  [`ALU_SRC1_SEL-1:0]    ex_alu_src1_sel;
    reg  [`ALU_SRC2_SEL-1:0]    ex_alu_src2_sel;
    reg  [`RV32_DATA_WIDTH-1:0] ex_alu_rs1_srcopr;
    reg  [`RV32_PC_WIDTH-1:0]   ex_alu_pc;
    reg  [`RV32_DATA_WIDTH-1:0] ex_alu_rs2_srcopr;
    reg  [`RV32_DATA_WIDTH-1:0] ex_alu_imm;
    reg  [`RRF_ENT_SEL-1:0]     ex_alu_rrftag;
    wire                        exfin_alu;
    wire [`RV32_DATA_WIDTH-1:0] exfin_alu_res;

    wire                        ex_mul_accessable;
    reg                         ex_mul_signed1;
    reg                         ex_mul_signed2;
    reg                         ex_mul_sel_high;
    reg  [`RV32_DATA_WIDTH-1:0] ex_mul_rs1_srcopr;
    reg  [`RV32_DATA_WIDTH-1:0] ex_mul_rs2_srcopr;
    reg  [`RRF_ENT_SEL-1:0]     ex_mul_rrftag;
    wire                        exfin_mul;
    wire [`RV32_DATA_WIDTH-1:0] exfin_mul_res;

    wire                        ex_ldst_accessable;
    reg  [`RV32_DATA_WIDTH-1:0] ex_ldst_rs1_srcopr;
    reg  [`RV32_DATA_WIDTH-1:0] ex_ldst_rs2_srcopr;
    reg  [`RV32_DATA_WIDTH-1:0] ex_ldst_imm;
    reg                         ex_ldst_is_st;  
    reg  [`RRF_ENT_SEL-1:0]     ex_ldst_rrftag;
    wire [`RRF_ENT_SEL-1:0]     ex_ld_rrftag;
    wire [`RV32_ADDR_WIDTH-1:0] ex_ld_addr;
    wire                        exfin_ld;
    wire [`RV32_DATA_WIDTH-1:0] exfin_ld_res;
    wire                        exfin_st;
    wire [`RV32_ADDR_WIDTH-1:0] exfin_st_addr;
    wire [`RV32_DATA_WIDTH-1:0] exfin_st_data;

    wire                        stbuf_full;
    wire                        dmem_occupy;
    wire                        ret_stbuf;
    wire [`RV32_ADDR_WIDTH-1:0] ret_stbuf_addr;
    wire [`RV32_DATA_WIDTH-1:0] ret_stbuf_data;
    wire                        stbuf_addr_hit;
    wire [`RV32_DATA_WIDTH-1:0] stbuf_rd_data;

    wire                        ex_br_accessable;
    reg                         ex_br_is_jal;
    reg                         ex_br_is_jalr;
    reg  [`ALU_OP_SEL-1:0]      ex_br_alu_op_sel;
    reg  [`RV32_DATA_WIDTH-1:0] ex_br_rs1_srcopr;
    reg  [`RV32_DATA_WIDTH-1:0] ex_br_rs2_srcopr;
    reg  [`RV32_PC_WIDTH-1:0]   ex_br_pc;
    reg  [`RV32_DATA_WIDTH-1:0] ex_br_imm;
    reg  [`RV32_PC_WIDTH-1:0]   ex_br_pred_jmpaddr;
    reg  [`RRF_ENT_SEL-1:0]     ex_br_rrftag; 
    wire                        exfin_br;
    wire [`RV32_PC_WIDTH-1:0]   exfin_br_jmpaddr;
    wire                        exfin_br_jmpcond;
    wire                        exfin_prsuc;
    wire                        exfin_prmiss;

    wire [`RRF_ENT_SEL-1:0]     ex_jal_jalr_rrftag;
    wire                        exfin_jal_jalr;
    wire [`RV32_DATA_WIDTH-1:0] exfin_jal_jalr_res;

    // ---------------------------------------------------- //
    // -------------------- COM-Stage --------------------- //
    // ---------------------------------------------------- //  

    wire [`COM_NUM_WIDTH-1:0]   com_num;
    
    wire                        com_vld_1;
    wire [`ROB_ENT_SEL-1:0]     com_ptr_1;
    wire                        com_rd_wr_en_1;
    wire [`RV32_ARF_SEL-1:0]    com_rd_wr_addr_1;
    wire [`RV32_DATA_WIDTH-1:0] com_rd_wr_data_1;

    wire                        com_vld_2;
    wire [`ROB_ENT_SEL-1:0]     com_ptr_2;
    wire                        com_rd_wr_en_2;
    wire [`RV32_ARF_SEL-1:0]    com_rd_wr_addr_2;
    wire [`RV32_DATA_WIDTH-1:0] com_rd_wr_data_2;

    wire                        com_st;
    wire                        com_br;
    wire [`RV32_PC_WIDTH-1:0]   com_pc;
    wire [`GSH_GHR_WIDTH-1:0]   com_ghr;
    wire [`RV32_PC_WIDTH-1:0]   com_jmpaddr;
    wire                        com_jmpcond;

    // ******************************************************************* //
    //                           Instantiations                            //
    // ******************************************************************* //

    // ---------------------------------------------------- //
    // -------------------- Interact ---------------------- //
    // ---------------------------------------------------- // 

    assign o_imem_addr     = if_pc;
    assign if_imem_rd_data = i_imem_rd_data;

    // Reuse one addr port, chosen by dmem_occupy signal
    assign o_dmem_addr     = dmem_occupy ? ex_ld_addr : ret_stbuf_addr;
    assign o_dmem_wr_en    = ret_stbuf;
    assign o_dmem_wr_data  = ret_stbuf_data;

    // ---------------------------------------------------- //
    // --------------------- Control ---------------------- //
    // ---------------------------------------------------- // 

    control_unit u_control_unit (
        .i_dp_freelist_allocable (dp_freelist_allocable),
        .i_dp_rs_alu_allocable   (dp_rs_alu_allocable),
        .i_dp_rs_mul_allocable   (dp_rs_mul_allocable),
        .i_dp_rs_ldst_allocable  (dp_rs_ldst_allocable),
        .i_dp_rs_br_allocable    (dp_rs_br_allocable),
        .i_exfin_prmiss          (exfin_prmiss),
        .o_if_kill               (if_kill),
        .o_id_kill               (id_kill),
        .o_dp_kill               (dp_kill),
        .o_if_stall              (if_stall),
        .o_id_stall              (id_stall),
        .o_dp_stall              (dp_stall),
        .i_is_rs_alu_sel_vld     (is_rs_alu_sel_vld),
        .i_is_rs_mul_sel_vld     (is_rs_mul_sel_vld),
        .i_is_rs_ldst_sel_vld    (is_rs_ldst_sel_vld),
        .i_is_rs_br_sel_vld      (is_rs_br_sel_vld),
        .i_ex_alu_accessable     (ex_alu_accessable),
        .i_ex_mul_accessable     (ex_mul_accessable),
        .i_ex_ldst_accessable    (ex_ldst_accessable),
        .i_ex_br_accessable      (ex_br_accessable),
        .o_is_rs_alu_vld         (is_rs_alu_vld),
        .o_is_rs_mul_vld         (is_rs_mul_vld),
        .o_is_rs_ldst_vld        (is_rs_ldst_vld),
        .o_is_rs_br_vld          (is_rs_br_vld)
    );

    // ---------------------------------------------------- //
    // --------------------- IF-Stage --------------------- //
    // ---------------------------------------------------- //  

    pc_reg u_pc_reg (
        .clk                 (clk),
        .rst_n               (rst_n),
        .i_stall             (if_stall),
        .i_pred_jmpaddr_miss (if_kill),
        .i_jmpaddr           (exfin_br_jmpaddr),
        .i_pred_jmp          (if_pred_jmp), 
        .i_pred_jmpaddr      (if_pc_btb),
        .o_pc                (if_pc)
    );

    assign if_pc_1 = if_pc;
    assign if_pc_2 = if_pc + 'd4;

    inst_sel_unit u_inst_sel_unit (
        .i_sel          (if_pc[3:2]),
        .i_imem_rd_data (if_imem_rd_data),
        .o_inst_vld_1   (if_inst_vld_1),
        .o_inst_vld_2   (if_inst_vld_2),
        .o_inst_1       (if_inst_1),
        .o_inst_2       (if_inst_2)
    );

    br_predictor u_br_predictor (
        .clk           (clk),
        .rst_n         (rst_n),
        .i_inst_vld_1  (if_inst_vld_1),
        .i_inst_vld_2  (if_inst_vld_2),
        .i_pc_1        (if_pc_1),
        .i_pc_2        (if_pc_2),
        .o_ghr         (if_ghr),
        .o_pred_jmp    (if_pred_jmp),
        .o_pc_btb      (if_pc_btb),
        .i_com_br      (com_br),
        .i_com_pc      (com_pc),
        .i_com_ghr     (com_ghr),
        .i_com_jmpaddr (com_jmpaddr),
        .i_com_jmpcond (com_jmpcond)
    );

    assign if_pred_jmpaddr_1 = if_pred_jmp ? if_pc_btb : if_pc_1 + 'd4;
    assign if_pred_jmpaddr_2 = if_pred_jmp ? if_pc_btb : if_pc_2 + 'd4;
    
    // ---------------------------------------------------- //
    // --------------------- ID-Stage --------------------- //
    // ---------------------------------------------------- //  

    always @(posedge clk) begin
        if (!rst_n) begin
            id_pc_1           <= 'd0;
            id_pc_2           <= 'd0;
            id_inst_vld_1     <= 'd0; 
            id_inst_vld_2     <= 'd0; 
            id_inst_1         <= 'd0;
            id_inst_2         <= 'd0;
            id_ghr            <= 'd0;
            id_pred_jmpaddr_1 <= 'd0;
            id_pred_jmpaddr_2 <= 'd0;
        end else begin 
            if (id_kill) begin
                id_pc_1           <= 'd0;
                id_pc_2           <= 'd0;
                id_inst_vld_1     <= 'd0; 
                id_inst_vld_2     <= 'd0; 
                id_inst_1         <= 'd0;
                id_inst_2         <= 'd0;
                id_ghr            <= 'd0;
                id_pred_jmpaddr_1 <= 'd0;
                id_pred_jmpaddr_2 <= 'd0;       
            end else if (id_stall) begin
            end else begin
                id_pc_1           <= if_pc_1;
                id_pc_2           <= if_pc_2;
                id_inst_vld_1     <= if_inst_vld_1;
                id_inst_vld_2     <= if_inst_vld_2;
                id_inst_1         <= if_inst_1;
                id_inst_2         <= if_inst_2;
                id_ghr            <= if_ghr;
                id_pred_jmpaddr_1 <= if_pred_jmpaddr_1;
                id_pred_jmpaddr_2 <= if_pred_jmpaddr_2;
            end
        end
    end

    decoder u_decoder_1 (
        .i_inst         (id_inst_1),
        .o_illegal      (id_illegal_1),
        .o_rs1_rd_en    (id_rs1_rd_en_1),
        .o_rs2_rd_en    (id_rs2_rd_en_1),
        .o_rd_wr_en     (id_rd_wr_en_1),
        .o_rs1_rd_addr  (id_rs1_rd_addr_1),
        .o_rs2_rd_addr  (id_rs2_rd_addr_1),
        .o_rd_wr_addr   (id_rd_wr_addr_1),
        .o_imm_type_sel (id_imm_type_sel_1),
        .o_alu_op_sel   (id_alu_op_sel_1),
        .o_alu_src1_sel (id_alu_src1_sel_1),
        .o_alu_src2_sel (id_alu_src2_sel_1),
        .o_mul_signed1  (id_mul_signed1_1),
        .o_mul_signed2  (id_mul_signed2_1),
        .o_mul_sel_high (id_mul_sel_high_1), 
        .o_is_st        (id_is_st_1),
        .o_is_br        (id_is_br_1),
        .o_is_jal       (id_is_jal_1),
        .o_is_jalr      (id_is_jalr_1),
        .o_rs_sel       (id_rs_sel_1)
    );

    decoder u_decoder_2 (
        .i_inst         (id_inst_2),
        .o_illegal      (id_illegal_2),
        .o_rs1_rd_en    (id_rs1_rd_en_2),
        .o_rs2_rd_en    (id_rs2_rd_en_2),
        .o_rd_wr_en     (id_rd_wr_en_2),
        .o_rs1_rd_addr  (id_rs1_rd_addr_2),
        .o_rs2_rd_addr  (id_rs2_rd_addr_2),
        .o_rd_wr_addr   (id_rd_wr_addr_2),
        .o_imm_type_sel (id_imm_type_sel_2),
        .o_alu_op_sel   (id_alu_op_sel_2),
        .o_alu_src1_sel (id_alu_src1_sel_2),
        .o_alu_src2_sel (id_alu_src2_sel_2),
        .o_mul_signed1  (id_mul_signed1_2),
        .o_mul_signed2  (id_mul_signed2_2),
        .o_mul_sel_high (id_mul_sel_high_2),   
        .o_is_st        (id_is_st_2),      
        .o_is_br        (id_is_br_2),
        .o_is_jal       (id_is_jal_2),
        .o_is_jalr      (id_is_jalr_2),
        .o_rs_sel       (id_rs_sel_2)
    );

    sptag_gen u_sptag_gen (
        .clk            (clk),
        .rst_n          (rst_n),
        .o_allocable    (id_sptag_gen_allocable),
        .i_stall        (id_stall),
        .i_is_br_1      (id_is_br_1),
        .i_is_br_2      (id_is_br_2),
        .o_inst_sp_1    (id_inst_sp_1),
        .o_inst_sp_2    (id_inst_sp_2),
        .o_inst_sptag_1 (id_inst_sptag_1),
        .o_inst_sptag_2 (id_inst_sptag_2),
        .i_prsuc        (),
        .i_prmiss       (),
        .i_sptag_fix    ()
    );

    // ---------------------------------------------------- //
    // --------------------- DP-Stage --------------------- //
    // ---------------------------------------------------- //  

    always @(posedge clk) begin
        if (!rst_n) begin
            // Inst_1
            dp_pc_1           <= 'd0;
            dp_vld_1          <= 'd0;
            dp_inst_1         <= 'd0;
            dp_rs1_rd_en_1    <= 'd0;
            dp_rs2_rd_en_1    <= 'd0;
            dp_rd_wr_en_1     <= 'd0;
            dp_rs1_rd_addr_1  <= 'd0;
            dp_rs2_rd_addr_1  <= 'd0;
            dp_rd_wr_addr_1   <= 'd0;
            dp_imm_type_sel_1 <= 'd0;
            dp_alu_op_sel_1   <= 'd0;
            dp_alu_src1_sel_1 <= 'd0;
            dp_alu_src2_sel_1 <= 'd0;
            dp_mul_signed1_1  <= 'd0;   
            dp_mul_signed2_1  <= 'd0;  
            dp_mul_sel_high_1 <= 'd0;          
            dp_is_st_1        <= 'd0;  
            dp_is_br_1        <= 'd0;
            dp_is_jal_1       <= 'd0;
            dp_is_jalr_1      <= 'd0;
            dp_pred_jmpaddr_1 <= 'd0;
            dp_rs_sel_1       <= 'd0;
            // Inst_2
            dp_pc_2           <= 'd0;   
            dp_vld_2          <= 'd0;
            dp_inst_2         <= 'd0;
            dp_rs1_rd_en_2    <= 'd0;
            dp_rs2_rd_en_2    <= 'd0;
            dp_rd_wr_en_2     <= 'd0;
            dp_rs1_rd_addr_2  <= 'd0;
            dp_rs2_rd_addr_2  <= 'd0;
            dp_rd_wr_addr_2   <= 'd0;
            dp_imm_type_sel_2 <= 'd0;
            dp_alu_op_sel_2   <= 'd0;
            dp_alu_src1_sel_2 <= 'd0;
            dp_alu_src2_sel_2 <= 'd0;
            dp_mul_signed1_1  <= 'd0;   
            dp_mul_signed2_1  <= 'd0;  
            dp_mul_sel_high_1 <= 'd0;  
            dp_is_st_2        <= 'd0;  
            dp_is_br_2        <= 'd0;
            dp_is_jal_2       <= 'd0;
            dp_is_jalr_2      <= 'd0; 
            dp_pred_jmpaddr_2 <= 'd0;
            dp_rs_sel_2       <= 'd0;
        end else begin
            if (dp_kill) begin
                // Inst_1
                dp_pc_1           <= 'd0;
                dp_vld_1          <= 'd0;
                dp_inst_1         <= 'd0;
                dp_rs1_rd_en_1    <= 'd0;
                dp_rs2_rd_en_1    <= 'd0;
                dp_rd_wr_en_1     <= 'd0;
                dp_rs1_rd_addr_1  <= 'd0;
                dp_rs2_rd_addr_1  <= 'd0;
                dp_rd_wr_addr_1   <= 'd0;
                dp_imm_type_sel_1 <= 'd0;
                dp_alu_op_sel_1   <= 'd0;
                dp_alu_src1_sel_1 <= 'd0;
                dp_alu_src2_sel_1 <= 'd0;
                dp_mul_signed1_1  <= 'd0;   
                dp_mul_signed2_1  <= 'd0;  
                dp_mul_sel_high_1 <= 'd0;          
                dp_is_st_1        <= 'd0;  
                dp_is_br_1        <= 'd0;
                dp_is_jal_1       <= 'd0;
                dp_is_jalr_1      <= 'd0;
                dp_pred_jmpaddr_1 <= 'd0;
                dp_rs_sel_1       <= 'd0;
                // Inst_2
                dp_pc_2           <= 'd0;   
                dp_vld_2          <= 'd0;
                dp_inst_2         <= 'd0;
                dp_rs1_rd_en_2    <= 'd0;
                dp_rs2_rd_en_2    <= 'd0;
                dp_rd_wr_en_2     <= 'd0;
                dp_rs1_rd_addr_2  <= 'd0;
                dp_rs2_rd_addr_2  <= 'd0;
                dp_rd_wr_addr_2   <= 'd0;
                dp_imm_type_sel_2 <= 'd0;
                dp_alu_op_sel_2   <= 'd0;
                dp_alu_src1_sel_2 <= 'd0;
                dp_alu_src2_sel_2 <= 'd0;
                dp_mul_signed1_1  <= 'd0;   
                dp_mul_signed2_1  <= 'd0;  
                dp_mul_sel_high_1 <= 'd0;  
                dp_is_st_2        <= 'd0;  
                dp_is_br_2        <= 'd0;
                dp_is_jal_2       <= 'd0;
                dp_is_jalr_2      <= 'd0; 
                dp_pred_jmpaddr_2 <= 'd0;
                dp_rs_sel_2       <= 'd0;
            end else if (dp_stall) begin
            end else begin
                // Inst_1
                dp_pc_1           <= id_pc_1;
                dp_vld_1          <= id_inst_vld_1 && (!id_illegal_1);
                dp_inst_1         <= id_inst_1;
                dp_rs1_rd_en_1    <= id_rs1_rd_en_1;
                dp_rs2_rd_en_1    <= id_rs2_rd_en_1;
                dp_rd_wr_en_1     <= id_rd_wr_en_1;
                dp_rs1_rd_addr_1  <= id_rs1_rd_addr_1;
                dp_rs2_rd_addr_1  <= id_rs2_rd_addr_1;
                dp_rd_wr_addr_1   <= id_rd_wr_addr_1;
                dp_imm_type_sel_1 <= id_imm_type_sel_1;
                dp_alu_op_sel_1   <= id_alu_op_sel_1;
                dp_alu_src1_sel_1 <= id_alu_src1_sel_1;
                dp_alu_src2_sel_1 <= id_alu_src2_sel_1;
                dp_mul_signed1_1  <= id_mul_signed1_1;   
                dp_mul_signed2_1  <= id_mul_signed2_1;  
                dp_mul_sel_high_1 <= id_mul_sel_high_1; 
                dp_is_st_1        <= id_is_st_1;   
                dp_is_br_1        <= id_is_br_1;
                dp_is_jal_1       <= id_is_jal_1;
                dp_is_jalr_1      <= id_is_jalr_1;
                dp_pred_jmpaddr_1 <= id_pred_jmpaddr_1;
                dp_rs_sel_1       <= id_rs_sel_1;
                // Inst_2
                dp_pc_2           <= id_pc_2;
                dp_vld_2          <= id_inst_vld_2 && (!id_illegal_2);
                dp_inst_2         <= id_inst_2;
                dp_rs1_rd_en_2    <= id_rs1_rd_en_2;
                dp_rs2_rd_en_2    <= id_rs2_rd_en_2;
                dp_rd_wr_en_2     <= id_rd_wr_en_2;
                dp_rs1_rd_addr_2  <= id_rs1_rd_addr_2;
                dp_rs2_rd_addr_2  <= id_rs2_rd_addr_2;
                dp_rd_wr_addr_2   <= id_rd_wr_addr_2;
                dp_imm_type_sel_2 <= id_imm_type_sel_2;
                dp_alu_op_sel_2   <= id_alu_op_sel_2;
                dp_alu_src1_sel_2 <= id_alu_src1_sel_2;
                dp_alu_src2_sel_2 <= id_alu_src2_sel_2;
                dp_mul_signed1_1  <= id_mul_signed1_1;   
                dp_mul_signed2_1  <= id_mul_signed2_1;  
                dp_mul_sel_high_1 <= id_mul_sel_high_1; 
                dp_is_st_2        <= id_is_st_2; 
                dp_is_br_2        <= id_is_br_2;
                dp_is_jal_2       <= id_is_jal_2;
                dp_is_jalr_2      <= id_is_jalr_2;
                dp_pred_jmpaddr_2 <= id_pred_jmpaddr_2;
                dp_rs_sel_2       <= id_rs_sel_2;
            end
        end
    end

    freelist_manager u_freelist_manager (
        .clk         (clk),
        .rst_n       (rst_n),
        .i_stall     (dp_stall),
        .i_dp_vld_1  (dp_vld_1),
        .i_dp_vld_2  (dp_vld_2),
        .i_com_num   (com_num),
        .o_allocable (dp_freelist_allocable),
        .o_dp_ptr_1  (dp_ptr_1),
        .o_dp_ptr_2  (dp_ptr_2)
    );

    arf u_arf (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_dp_rd_addr_1     (dp_rs1_rd_addr_1),
        .i_dp_rd_addr_2     (dp_rs2_rd_addr_1),
        .i_dp_rd_addr_3     (dp_rs1_rd_addr_2),
        .i_dp_rd_addr_4     (dp_rs2_rd_addr_2),
        .o_dp_rd_busy_1     (dp_rs1_rd_busy_1),
        .o_dp_rd_busy_2     (dp_rs2_rd_busy_1),
        .o_dp_rd_busy_3     (dp_rs1_rd_busy_2),
        .o_dp_rd_busy_4     (dp_rs2_rd_busy_2),
        .o_dp_rd_rrftag_1   (dp_rs1_rd_rrftag_1),
        .o_dp_rd_rrftag_2   (dp_rs2_rd_rrftag_1),
        .o_dp_rd_rrftag_3   (dp_rs1_rd_rrftag_2),
        .o_dp_rd_rrftag_4   (dp_rs2_rd_rrftag_2),
        .o_dp_rd_data_1     (dp_rs1_rd_data_1),
        .o_dp_rd_data_2     (dp_rs2_rd_data_1),
        .o_dp_rd_data_3     (dp_rs1_rd_data_2),
        .o_dp_rd_data_4     (dp_rs2_rd_data_2),
        .i_dp_vld_1         (dp_vld_1),
        .i_dp_ptr_1         (dp_ptr_1),
        .i_dp_rd_wr_en_1    (dp_rd_wr_en_1),
        .i_dp_rd_wr_addr_1  (dp_rd_wr_addr_1),
        .i_dp_vld_2         (dp_vld_2),
        .i_dp_ptr_2         (dp_ptr_2),
        .i_dp_rd_wr_en_2    (dp_rd_wr_en_2),
        .i_dp_rd_wr_addr_2  (dp_rd_wr_addr_2),
        .i_com_vld_1        (com_vld_1),
        .i_com_rd_wr_en_1   (com_rd_wr_en_1),
        .i_com_rd_wr_addr_1 (com_rd_wr_addr_1),
        .i_com_rd_wr_data_1 (com_rd_wr_data_1),
        .i_com_vld_2        (com_vld_2),
        .i_com_rd_wr_en_2   (com_rd_wr_en_2),
        .i_com_rd_wr_addr_2 (com_rd_wr_addr_2),
        .i_com_rd_wr_data_2 (com_rd_wr_data_2)
    );

    rrf u_rrf (
        .clk                  (clk),
        .rst_n                (rst_n),
        .i_dp_rd_addr_1       (dp_rs1_rd_rrftag_1),
        .i_dp_rd_addr_2       (dp_rs2_rd_rrftag_1),
        .i_dp_rd_addr_3       (dp_rs1_rd_rrftag_2),
        .i_dp_rd_addr_4       (dp_rs2_rd_rrftag_2),
        .o_dp_rd_vld_1        (dp_rs1_rd_vld_1),
        .o_dp_rd_vld_2        (dp_rs2_rd_vld_1),
        .o_dp_rd_vld_3        (dp_rs1_rd_vld_2),
        .o_dp_rd_vld_4        (dp_rs2_rd_vld_2),
        .o_dp_rd_data_1       (dp_rs1_rd_rrfdata_1),
        .o_dp_rd_data_2       (dp_rs2_rd_rrfdata_1),
        .o_dp_rd_data_3       (dp_rs1_rd_rrfdata_2),
        .o_dp_rd_data_4       (dp_rs2_rd_rrfdata_2),
        .i_ex_alu_rrftag      (ex_alu_rrftag),
        .i_exfin_alu          (exfin_alu),
        .i_exfin_alu_res      (exfin_alu_res),
        .i_ex_mul_rrftag      (ex_mul_rrftag),
        .i_exfin_mul          (exfin_mul),
        .i_exfin_mul_res      (exfin_mul_res),
        .i_ex_ld_rrftag       (ex_ld_rrftag),
        .i_exfin_ld           (exfin_ld),
        .i_exfin_ld_res       (exfin_ld_res),
        .i_ex_jal_jalr_rrftag (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (exfin_jal_jalr),
        .i_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .i_com_vld_1          (com_vld_1),
        .i_com_ptr_1          (com_ptr_1),
        .o_com_rd_wr_data_1   (com_rd_wr_data_1),
        .i_com_vld_2          (com_vld_2),
        .i_com_ptr_2          (com_ptr_2),
        .o_com_rd_wr_data_2   (com_rd_wr_data_2)
    );
   
    srcopr_sel_unit u_srcopr_sel_unit_1 (
        .i_arf_rd_addr_eq_0   ((dp_rs1_rd_addr_1 == 'd0) ? 1'b1 : 1'b0),
        .i_arf_rd_addr_eq_rd1 (1'b0),
        .i_rd1_renamed        (dp_ptr_1),
        .i_arf_busy           (dp_rs1_rd_busy_1),
        .i_arf_rrftag         (dp_rs1_rd_rrftag_1),
        .i_arf_data           (dp_rs1_rd_data_1),
        .i_rrf_vld            (dp_rs1_rd_vld_1),
        .i_rrf_data           (dp_rs1_rd_rrfdata_1),
        .o_srcopr_vld         (dp_rs1_srcopr_vld_1),
        .o_srcopr             (dp_rs1_srcopr_1)
    );

    srcopr_sel_unit u_srcopr_sel_unit_2 (
        .i_arf_rd_addr_eq_0   ((dp_rs2_rd_addr_1 == 'd0) ? 1'b1 : 1'b0),
        .i_arf_rd_addr_eq_rd1 (1'b0),
        .i_rd1_renamed        (dp_ptr_1),
        .i_arf_busy           (dp_rs2_rd_busy_1),
        .i_arf_rrftag         (dp_rs2_rd_rrftag_1),
        .i_arf_data           (dp_rs2_rd_data_1),
        .i_rrf_vld            (dp_rs2_rd_vld_1),
        .i_rrf_data           (dp_rs2_rd_rrfdata_1),
        .o_srcopr_vld         (dp_rs2_srcopr_vld_1),
        .o_srcopr             (dp_rs2_srcopr_1)
    );

    srcopr_sel_unit u_srcopr_sel_unit_3 (
        .i_arf_rd_addr_eq_0   ((dp_rs1_rd_addr_2 == 'd0) ? 1'b1 : 1'b0),
        .i_arf_rd_addr_eq_rd1 ((dp_rs1_rd_addr_2 == dp_rd_wr_addr_1) ? 1'b1 : 1'b0),
        .i_rd1_renamed        (dp_ptr_1),
        .i_arf_busy           (dp_rs1_rd_busy_2),
        .i_arf_rrftag         (dp_rs1_rd_rrftag_2),
        .i_arf_data           (dp_rs1_rd_data_2),
        .i_rrf_vld            (dp_rs1_rd_vld_2),
        .i_rrf_data           (dp_rs1_rd_rrfdata_2),
        .o_srcopr_vld         (dp_rs1_srcopr_vld_2),
        .o_srcopr             (dp_rs1_srcopr_2)
    );

    srcopr_sel_unit u_srcopr_sel_unit_4 (
        .i_arf_rd_addr_eq_0   ((dp_rs2_rd_addr_2 == 'd0) ? 1'b1 : 1'b0),
        .i_arf_rd_addr_eq_rd1 ((dp_rs2_rd_addr_2 == dp_rd_wr_addr_1) ? 1'b1 : 1'b0),
        .i_rd1_renamed        (dp_ptr_1),
        .i_arf_busy           (dp_rs2_rd_busy_2),
        .i_arf_rrftag         (dp_rs2_rd_rrftag_2),
        .i_arf_data           (dp_rs2_rd_data_2),
        .i_rrf_vld            (dp_rs2_rd_vld_2),
        .i_rrf_data           (dp_rs2_rd_rrfdata_2),
        .o_srcopr_vld         (dp_rs2_srcopr_vld_2),
        .o_srcopr             (dp_rs2_srcopr_2)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_1 (
        .i_srcopr_vld         (dp_rs1_srcopr_vld_1),
        .i_srcopr             (dp_rs1_srcopr_1),
        .i_ex_alu_rrftag      (ex_alu_rrftag),
        .i_exfin_alu          (exfin_alu),
        .i_exfin_alu_res      (exfin_alu_res),
        .i_ex_mul_rrftag      (ex_mul_rrftag),
        .i_exfin_mul          (exfin_mul),
        .i_exfin_mul_res      (exfin_mul_res),
        .i_ex_ld_rrftag       (ex_ld_rrftag),
        .i_exfin_ld           (exfin_ld),
        .i_exfin_ld_res       (exfin_ld_res), 
        .i_ex_jal_jalr_rrftag (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (exfin_jal_jalr),
        .i_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (dp_rs1_srcopr_fwd_vld_1),
        .o_srcopr_fwd         (dp_rs1_srcopr_fwd_1)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_2 (
        .i_srcopr_vld         (dp_rs2_srcopr_vld_1),
        .i_srcopr             (dp_rs2_srcopr_1),
        .i_ex_alu_rrftag      (ex_alu_rrftag),
        .i_exfin_alu          (exfin_alu),
        .i_exfin_alu_res      (exfin_alu_res),
        .i_ex_mul_rrftag      (ex_mul_rrftag),
        .i_exfin_mul          (exfin_mul),
        .i_exfin_mul_res      (exfin_mul_res),
        .i_ex_ld_rrftag       (ex_ld_rrftag),
        .i_exfin_ld           (exfin_ld),
        .i_exfin_ld_res       (exfin_ld_res),
        .i_ex_jal_jalr_rrftag (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (exfin_jal_jalr),
        .i_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (dp_rs2_srcopr_fwd_vld_1),
        .o_srcopr_fwd         (dp_rs2_srcopr_fwd_1)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_3 (
        .i_srcopr_vld         (dp_rs1_srcopr_vld_2),
        .i_srcopr             (dp_rs1_srcopr_2),
        .i_ex_alu_rrftag      (ex_alu_rrftag),
        .i_exfin_alu          (exfin_alu),
        .i_exfin_alu_res      (exfin_alu_res),
        .i_ex_mul_rrftag      (ex_mul_rrftag),
        .i_exfin_mul          (exfin_mul),
        .i_exfin_mul_res      (exfin_mul_res),
        .i_ex_ld_rrftag       (ex_ld_rrftag),
        .i_exfin_ld           (exfin_ld),
        .i_exfin_ld_res       (exfin_ld_res), 
        .i_ex_jal_jalr_rrftag (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (exfin_jal_jalr),
        .i_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (dp_rs1_srcopr_fwd_vld_2),
        .o_srcopr_fwd         (dp_rs1_srcopr_fwd_2)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_4 (
        .i_srcopr_vld         (dp_rs2_srcopr_vld_2),
        .i_srcopr             (dp_rs2_srcopr_2),
        .i_ex_alu_rrftag      (ex_alu_rrftag),
        .i_exfin_alu          (exfin_alu),
        .i_exfin_alu_res      (exfin_alu_res),
        .i_ex_mul_rrftag      (ex_mul_rrftag),
        .i_exfin_mul          (exfin_mul),
        .i_exfin_mul_res      (exfin_mul_res),
        .i_ex_ld_rrftag       (ex_ld_rrftag),
        .i_exfin_ld           (exfin_ld),
        .i_exfin_ld_res       (exfin_ld_res), 
        .i_ex_jal_jalr_rrftag (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (exfin_jal_jalr),
        .i_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (dp_rs2_srcopr_fwd_vld_2),
        .o_srcopr_fwd         (dp_rs2_srcopr_fwd_2)
    );

    imm_gen u_imm_gen_1 (
        .i_inst         (dp_inst_1),
        .i_imm_type_sel (dp_imm_type_sel_1),
        .o_imm          (dp_imm_1)
    );

    imm_gen u_imm_gen_2 (
        .i_inst         (dp_inst_2),
        .i_imm_type_sel (dp_imm_type_sel_2),
        .o_imm          (dp_imm_2)
    );

    rs_req_manager u_rs_req_manager (
        .i_rs_sel_vld_1    (dp_vld_1),
        .i_rs_sel_vld_2    (dp_vld_2),
        .i_rs_sel_1        (dp_rs_sel_1),
        .i_rs_sel_2        (dp_rs_sel_2),
        .o_rs_alu_req_1    (dp_rs_alu_req_1),
        .o_rs_alu_req_2    (dp_rs_alu_req_2),
        .o_rs_alu_req_num  (dp_rs_alu_req_num),
        .o_rs_mul_req_1    (dp_rs_mul_req_1),
        .o_rs_mul_req_2    (dp_rs_mul_req_2),
        .o_rs_mul_req_num  (dp_rs_mul_req_num),
        .o_rs_ldst_req_1   (dp_rs_ldst_req_1),
        .o_rs_ldst_req_2   (dp_rs_ldst_req_2),
        .o_rs_ldst_req_num (dp_rs_ldst_req_num),
        .o_rs_br_req_1     (dp_rs_br_req_1),
        .o_rs_br_req_2     (dp_rs_br_req_2),
        .o_rs_br_req_num   (dp_rs_br_req_num)
    );

    alloc_issue_disorder #(
        .ENT_NUM           (`RS_ALU_ENT_NUM),
        .ENT_SEL           (`RS_ALU_ENT_SEL)
    ) u_rs_alu_alloc_issue_disorder (
        .i_busy_vec        (dp_rs_alu_busy_vec),
        .i_req_num         (dp_rs_alu_req_num),
        .o_allocable       (dp_rs_alu_allocable),
        .o_alloc_sel_vld_1 (dp_rs_alu_alloc_sel_vld_1), // Not used 
        .o_alloc_sel_vld_2 (dp_rs_alu_alloc_sel_vld_2), // Not used 
        .o_alloc_sel_1     (dp_rs_alu_alloc_sel_1),
        .o_alloc_sel_2     (dp_rs_alu_alloc_sel_2),
        .i_vld_vec         (is_rs_alu_vld_vec),
        .o_issue_sel_vld   (is_rs_alu_sel_vld),
        .o_issue_sel       (is_rs_alu_sel)
    );

    alloc_issue_disorder #(
        .ENT_NUM           (`RS_MUL_ENT_NUM),
        .ENT_SEL           (`RS_MUL_ENT_SEL)
    ) u_rs_mul_alloc_issue_disorder (
        .i_busy_vec        (dp_rs_mul_busy_vec),
        .i_req_num         (dp_rs_mul_req_num),
        .o_allocable       (dp_rs_mul_allocable),
        .o_alloc_sel_vld_1 (dp_rs_mul_alloc_sel_vld_1), // Not used 
        .o_alloc_sel_vld_2 (dp_rs_mul_alloc_sel_vld_2), // Not used 
        .o_alloc_sel_1     (dp_rs_mul_alloc_sel_1),
        .o_alloc_sel_2     (dp_rs_mul_alloc_sel_2),
        .i_vld_vec         (is_rs_mul_vld_vec),
        .o_issue_sel_vld   (is_rs_mul_sel_vld),
        .o_issue_sel       (is_rs_mul_sel)
    );

    alloc_issue_order #(
        .ENT_NUM           (`RS_LDST_ENT_NUM),
        .ENT_SEL           (`RS_LDST_ENT_SEL)
    ) u_rs_ldst_alloc_issue_order (
        .clk               (clk),
        .rst_n             (rst_n),
        .i_stall           (dp_stall),
        .i_busy_vec        (dp_rs_ldst_busy_vec),
        .i_req_num         (dp_rs_ldst_req_num),
        .o_allocable       (dp_rs_ldst_allocable),
        .o_alloc_sel_vld_1 (dp_rs_ldst_alloc_sel_vld_1), // Not used
        .o_alloc_sel_vld_2 (dp_rs_ldst_alloc_sel_vld_2), // Not used
        .o_alloc_sel_1     (dp_rs_ldst_alloc_sel_1),
        .o_alloc_sel_2     (dp_rs_ldst_alloc_sel_2),
        .i_vld_vec         (is_rs_ldst_vld_vec),
        .i_issue_vld       (is_rs_ldst_vld),
        .o_issue_sel_vld   (is_rs_ldst_sel_vld),
        .o_issue_sel       (is_rs_ldst_sel)
    );

    alloc_issue_order #(
        .ENT_NUM           (`RS_BR_ENT_NUM),
        .ENT_SEL           (`RS_BR_ENT_SEL)
    ) u_rs_br_alloc_issue_order (
        .clk               (clk),
        .rst_n             (rst_n),
        .i_stall           (dp_stall),
        .i_busy_vec        (dp_rs_br_busy_vec),
        .i_req_num         (dp_rs_br_req_num),
        .o_allocable       (dp_rs_br_allocable),
        .o_alloc_sel_vld_1 (dp_rs_br_alloc_sel_vld_1), // Not used
        .o_alloc_sel_vld_2 (dp_rs_br_alloc_sel_vld_2), // Not used
        .o_alloc_sel_1     (dp_rs_br_alloc_sel_1),
        .o_alloc_sel_2     (dp_rs_br_alloc_sel_2),
        .i_vld_vec         (is_rs_br_vld_vec),
        .i_issue_vld       (is_rs_br_vld),
        .o_issue_sel_vld   (is_rs_br_sel_vld),
        .o_issue_sel       (is_rs_br_sel)
    );

    // ---------------------------------------------------- //
    // --------------------- IS-Stage --------------------- //
    // ---------------------------------------------------- //  

    rs_alu u_rs_alu (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .o_busy_vec            (dp_rs_alu_busy_vec),
        .o_vld_vec             (is_rs_alu_vld_vec),
        .i_stall               (dp_stall),
        .i_alloc_vld_1         (dp_rs_alu_req_1),
        .i_alloc_sel_1         (dp_rs_alu_req_1 ? dp_rs_alu_alloc_sel_1 : dp_rs_alu_alloc_sel_2),
        .i_dp_alu_op_sel_1     (dp_alu_op_sel_1),
        .i_dp_alu_src1_sel_1   (dp_alu_src1_sel_1),
        .i_dp_alu_src2_sel_1   (dp_alu_src2_sel_1),
        .i_dp_rs1_srcopr_vld_1 ((!dp_rs1_rd_en_1) || dp_rs1_srcopr_fwd_vld_1),  
        .i_dp_rs2_srcopr_vld_1 ((!dp_rs2_rd_en_1) || dp_rs2_srcopr_fwd_vld_1), 
        .i_dp_rs1_srcopr_1     (dp_rs1_srcopr_fwd_1),
        .i_dp_rs2_srcopr_1     (dp_rs2_srcopr_fwd_1),
        .i_dp_pc_1             (dp_pc_1),
        .i_dp_imm_1            (dp_imm_1),
        .i_dp_rrftag_1         (dp_ptr_1),
        .i_alloc_vld_2         (dp_rs_alu_req_2), 
        .i_alloc_sel_2         (dp_rs_alu_req_1 ? dp_rs_alu_alloc_sel_2 : dp_rs_alu_alloc_sel_1),
        .i_dp_alu_op_sel_2     (dp_alu_op_sel_2),
        .i_dp_alu_src1_sel_2   (dp_alu_src1_sel_2),
        .i_dp_alu_src2_sel_2   (dp_alu_src2_sel_2),
        .i_dp_rs1_srcopr_vld_2 ((!dp_rs1_rd_en_2) || dp_rs1_srcopr_fwd_vld_2),  
        .i_dp_rs2_srcopr_vld_2 ((!dp_rs2_rd_en_2) || dp_rs2_srcopr_fwd_vld_2),  
        .i_dp_rs1_srcopr_2     (dp_rs1_srcopr_fwd_2),
        .i_dp_rs2_srcopr_2     (dp_rs2_srcopr_fwd_2),
        .i_dp_pc_2             (dp_pc_2),
        .i_dp_imm_2            (dp_imm_2),
        .i_dp_rrftag_2         (dp_ptr_2),
        .i_is_vld              (is_rs_alu_vld),
        .i_is_sel              (is_rs_alu_sel),
        .o_is_alu_op_sel       (is_alu_op_sel),
        .o_is_alu_src1_sel     (is_alu_src1_sel),
        .o_is_alu_src2_sel     (is_alu_src2_sel),
        .o_is_rs1_srcopr       (is_alu_rs1_srcopr),
        .o_is_rs2_srcopr       (is_alu_rs2_srcopr),
        .o_is_pc               (is_alu_pc),
        .o_is_imm              (is_alu_imm),
        .o_is_rrftag           (is_alu_rrftag),
        .i_ex_alu_rrftag       (ex_alu_rrftag),
        .i_exfin_alu           (exfin_alu),
        .i_exfin_alu_res       (exfin_alu_res),
        .i_ex_mul_rrftag       (ex_mul_rrftag),
        .i_exfin_mul           (exfin_mul),
        .i_exfin_mul_res       (exfin_mul_res),
        .i_ex_ld_rrftag        (ex_ld_rrftag),
        .i_exfin_ld            (exfin_ld),
        .i_exfin_ld_res        (exfin_ld_res),
        .i_ex_jal_jalr_rrftag  (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr      (exfin_jal_jalr),
        .i_exfin_jal_jalr_res  (exfin_jal_jalr_res)   
    );

    rs_mul u_rs_mul (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .o_busy_vec            (dp_rs_mul_busy_vec),
        .o_vld_vec             (is_rs_mul_vld_vec),
        .i_stall               (dp_stall),
        .i_alloc_vld_1         (dp_rs_mul_req_1), 
        .i_alloc_sel_1         (dp_rs_mul_req_1 ? dp_rs_mul_alloc_sel_1 : dp_rs_mul_alloc_sel_2),
        .i_dp_mul_signed1_1    (dp_mul_signed1_1),
        .i_dp_mul_signed2_1    (dp_mul_signed2_1),
        .i_dp_mul_sel_high_1   (dp_mul_sel_high_1),
        .i_dp_rs1_srcopr_vld_1 ((!dp_rs1_rd_en_1) || dp_rs1_srcopr_fwd_vld_1),  
        .i_dp_rs2_srcopr_vld_1 ((!dp_rs2_rd_en_1) || dp_rs2_srcopr_fwd_vld_1),  
        .i_dp_rs1_srcopr_1     (dp_rs1_srcopr_fwd_1),
        .i_dp_rs2_srcopr_1     (dp_rs2_srcopr_fwd_1),
        .i_dp_rrftag_1         (dp_ptr_1),
        .i_alloc_vld_2         (dp_rs_mul_req_2), 
        .i_alloc_sel_2         (dp_rs_mul_req_1 ? dp_rs_mul_alloc_sel_2 : dp_rs_mul_alloc_sel_1),
        .i_dp_mul_signed1_2    (dp_mul_signed1_2),
        .i_dp_mul_signed2_2    (dp_mul_signed2_2),
        .i_dp_mul_sel_high_2   (dp_mul_sel_high_2),
        .i_dp_rs1_srcopr_vld_2 ((!dp_rs1_rd_en_2) || dp_rs1_srcopr_fwd_vld_2),
        .i_dp_rs2_srcopr_vld_2 ((!dp_rs2_rd_en_2) || dp_rs2_srcopr_fwd_vld_2),  
        .i_dp_rs1_srcopr_2     (dp_rs1_srcopr_fwd_2),
        .i_dp_rs2_srcopr_2     (dp_rs2_srcopr_fwd_2),
        .i_dp_rrftag_2         (dp_ptr_2),
        .i_is_vld              (is_rs_mul_vld),
        .i_is_sel              (is_rs_mul_sel),
        .o_is_mul_signed1      (is_mul_signed1),
        .o_is_mul_signed2      (is_mul_signed2),
        .o_is_mul_sel_high     (is_mul_sel_high),
        .o_is_rs1_srcopr       (is_mul_rs1_srcopr),
        .o_is_rs2_srcopr       (is_mul_rs2_srcopr),
        .o_is_rrftag           (is_mul_rrftag),
        .i_ex_alu_rrftag       (ex_alu_rrftag),
        .i_exfin_alu           (exfin_alu),
        .i_exfin_alu_res       (exfin_alu_res),
        .i_ex_mul_rrftag       (ex_mul_rrftag),
        .i_exfin_mul           (exfin_mul),
        .i_exfin_mul_res       (exfin_mul_res),
        .i_ex_ld_rrftag        (ex_ld_rrftag),
        .i_exfin_ld            (exfin_ld),
        .i_exfin_ld_res        (exfin_ld_res),
        .i_ex_jal_jalr_rrftag  (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr      (exfin_jal_jalr),
        .i_exfin_jal_jalr_res  (exfin_jal_jalr_res) 
    );

    rs_ldst u_rs_ldst (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .o_busy_vec            (dp_rs_ldst_busy_vec),
        .o_vld_vec             (is_rs_ldst_vld_vec),
        .i_stall               (dp_stall),
        .i_alloc_vld_1         (dp_rs_ldst_req_1), 
        .i_alloc_sel_1         (dp_rs_ldst_req_1 ? dp_rs_ldst_alloc_sel_1 : dp_rs_ldst_alloc_sel_2),
        .i_dp_rs1_srcopr_vld_1 ((!dp_rs1_rd_en_1) || dp_rs1_srcopr_fwd_vld_1),  
        .i_dp_rs2_srcopr_vld_1 ((!dp_rs2_rd_en_1) || dp_rs2_srcopr_fwd_vld_1),  
        .i_dp_rs1_srcopr_1     (dp_rs1_srcopr_fwd_1),
        .i_dp_rs2_srcopr_1     (dp_rs2_srcopr_fwd_1),
        .i_dp_imm_1            (dp_imm_1),
        .i_dp_is_st_1          (dp_is_st_1),
        .i_dp_rrftag_1         (dp_ptr_1),
        .i_alloc_vld_2         (dp_rs_ldst_req_2), 
        .i_alloc_sel_2         (dp_rs_ldst_req_1 ? dp_rs_ldst_alloc_sel_2 : dp_rs_ldst_alloc_sel_1),
        .i_dp_rs1_srcopr_vld_2 ((!dp_rs1_rd_en_2) || dp_rs1_srcopr_fwd_vld_2), 
        .i_dp_rs2_srcopr_vld_2 ((!dp_rs2_rd_en_2) || dp_rs2_srcopr_fwd_vld_2),  
        .i_dp_rs1_srcopr_2     (dp_rs1_srcopr_fwd_2),
        .i_dp_rs2_srcopr_2     (dp_rs2_srcopr_fwd_2),
        .i_dp_imm_2            (dp_imm_2),
        .i_dp_is_st_2          (dp_is_st_2),
        .i_dp_rrftag_2         (dp_ptr_2),
        .i_is_vld              (is_rs_ldst_vld),    
        .i_is_sel              (is_rs_ldst_sel),
        .o_is_rs1_srcopr       (is_ldst_rs1_srcopr),
        .o_is_rs2_srcopr       (is_ldst_rs2_srcopr),
        .o_is_imm              (is_ldst_imm),
        .o_is_is_st            (is_ldst_is_st),
        .o_is_rrftag           (is_ldst_rrftag),
        .i_ex_alu_rrftag       (ex_alu_rrftag),
        .i_exfin_alu           (exfin_alu),
        .i_exfin_alu_res       (exfin_alu_res),
        .i_ex_mul_rrftag       (ex_mul_rrftag),
        .i_exfin_mul           (exfin_mul),
        .i_exfin_mul_res       (exfin_mul_res),
        .i_ex_ld_rrftag        (ex_ld_rrftag),
        .i_exfin_ld            (exfin_ld),
        .i_exfin_ld_res        (exfin_ld_res),
        .i_ex_jal_jalr_rrftag  (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr      (exfin_jal_jalr),
        .i_exfin_jal_jalr_res  (exfin_jal_jalr_res) 
    );

    rs_br u_rs_br (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .o_busy_vec            (dp_rs_br_busy_vec),
        .o_vld_vec             (is_rs_br_vld_vec),
        .i_stall               (dp_stall),
        .i_alloc_vld_1         (dp_rs_br_req_1),
        .i_alloc_sel_1         (dp_rs_br_req_1 ? dp_rs_br_alloc_sel_1 : dp_rs_br_alloc_sel_2),
        .i_dp_rs1_srcopr_vld_1 ((!dp_rs1_rd_en_1) || dp_rs1_srcopr_vld_1),
        .i_dp_rs2_srcopr_vld_1 ((!dp_rs2_rd_en_1) || dp_rs2_srcopr_vld_1),
        .i_dp_rs1_srcopr_1     (dp_rs1_srcopr_fwd_1),
        .i_dp_rs2_srcopr_1     (dp_rs2_srcopr_fwd_1),
        .i_dp_is_jal_1         (dp_is_jal_1),
        .i_dp_is_jalr_1        (dp_is_jalr_1),
        .i_dp_alu_op_sel_1     (dp_alu_op_sel_1),
        .i_dp_pc_1             (dp_pc_1),
        .i_dp_imm_1            (dp_imm_1),
        .i_dp_pred_jmpaddr_1   (dp_pred_jmpaddr_1),
        .i_dp_rrftag_1         (dp_ptr_1),
        .i_alloc_vld_2         (dp_rs_br_req_2),
        .i_alloc_sel_2         (dp_rs_br_req_1 ? dp_rs_br_alloc_sel_2 : dp_rs_br_alloc_sel_1),
        .i_dp_rs1_srcopr_vld_2 ((!dp_rs1_rd_en_2) || dp_rs1_srcopr_vld_2),
        .i_dp_rs2_srcopr_vld_2 ((!dp_rs2_rd_en_2) || dp_rs2_srcopr_vld_2),
        .i_dp_rs1_srcopr_2     (dp_rs1_srcopr_fwd_2),
        .i_dp_rs2_srcopr_2     (dp_rs2_srcopr_fwd_2),
        .i_dp_is_jal_2         (dp_is_jal_2),
        .i_dp_is_jalr_2        (dp_is_jalr_2),
        .i_dp_alu_op_2         (dp_alu_op_sel_2),
        .i_dp_pc_2             (dp_pc_2),
        .i_dp_imm_2            (dp_imm_2),
        .i_dp_pred_jmpaddr_2   (dp_pred_jmpaddr_2),
        .i_dp_rrftag_2         (dp_ptr_2),
        .i_is_vld              (is_rs_br_vld),
        .i_is_sel              (is_rs_br_sel),
        .o_is_jal              (is_br_is_jal),
        .o_is_jalr             (is_br_is_jalr),
        .o_alu_op_sel          (is_br_alu_op_sel),
        .o_is_rs1_srcopr       (is_br_rs1_srcopr),
        .o_is_rs2_srcopr       (is_br_rs2_srcopr),
        .o_pc                  (is_br_pc),
        .o_is_imm              (is_br_imm),
        .o_pred_jmpaddr        (is_br_pred_jmpaddr),
        .o_is_rrftag           (is_br_rrftag),
        .i_ex_alu_rrftag       (ex_alu_rrftag),
        .i_exfin_alu           (exfin_alu),
        .i_exfin_alu_res       (exfin_alu_res),
        .i_ex_mul_rrftag       (ex_mul_rrftag),
        .i_exfin_mul           (exfin_mul),
        .i_exfin_mul_res       (exfin_mul_res),
        .i_ex_ld_rrftag        (ex_ld_rrftag),
        .i_exfin_ld            (exfin_ld),
        .i_exfin_ld_res        (exfin_ld_res),
        .i_ex_jal_jalr_rrftag  (ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr      (exfin_jal_jalr),
        .i_exfin_jal_jalr_res  (exfin_jal_jalr_res)
    );

    // ---------------------------------------------------- //
    // --------------------- EX-Stage --------------------- //
    // ---------------------------------------------------- //  

    always @(posedge clk) begin
        if (!rst_n) begin
            ex_alu_op_sel         <= 'd0;
            ex_alu_src1_sel       <= 'd0;
            ex_alu_src2_sel       <= 'd0;
            ex_alu_rs1_srcopr     <= 'd0;
            ex_alu_pc             <= 'd0;
            ex_alu_rs2_srcopr     <= 'd0;
            ex_alu_imm            <= 'd0;
            ex_alu_rrftag         <= 'd0;
        end else begin    
            // Maintain until exfinshed, so actually this is a buf rather than pipe-regs
            if (is_rs_alu_vld) begin
                ex_alu_op_sel     <= is_alu_op_sel;
                ex_alu_src1_sel   <= is_alu_src1_sel;
                ex_alu_src2_sel   <= is_alu_src2_sel;
                ex_alu_rs1_srcopr <= is_alu_rs1_srcopr;
                ex_alu_pc         <= is_alu_pc;
                ex_alu_rs2_srcopr <= is_alu_rs2_srcopr;
                ex_alu_imm        <= is_alu_imm;
                ex_alu_rrftag     <= is_alu_rrftag;
            end
        end
    end

    exunit_alu u_exunit_alu (
        .clk          (clk),
        .rst_n        (rst_n),
        .o_accessable (ex_alu_accessable),
        .i_is_vld     (is_rs_alu_vld),
        .i_op_sel     (ex_alu_op_sel),
        .i_src1_sel   (ex_alu_src1_sel),
        .i_src2_sel   (ex_alu_src2_sel),
        .i_rs1        (ex_alu_rs1_srcopr),
        .i_pc         (ex_alu_pc),
        .i_rs2        (ex_alu_rs2_srcopr),
        .i_imm        (ex_alu_imm),
        .o_exfin      (exfin_alu),
        .o_exfin_res  (exfin_alu_res)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            ex_mul_signed1        <= 'd0;
            ex_mul_signed2        <= 'd0;
            ex_mul_sel_high       <= 'd0;
            ex_mul_rs1_srcopr     <= 'd0;
            ex_mul_rs2_srcopr     <= 'd0;  
            ex_alu_rrftag         <= 'd0;
        end else begin    
            // Maintain until exfinshed, so actually this is a buf rather than pipe-regs
            if (is_rs_mul_vld) begin
                ex_mul_signed1    <= is_mul_signed1;
                ex_mul_signed2    <= is_mul_signed2;
                ex_mul_sel_high   <= is_mul_sel_high;
                ex_mul_rs1_srcopr <= is_mul_rs1_srcopr;
                ex_mul_rs2_srcopr <= is_mul_rs2_srcopr;      
                ex_mul_rrftag     <= is_mul_rrftag;
            end
        end
    end

    exunit_mul u_exunit_mul (
        .clk          (clk),
        .rst_n        (rst_n),
        .o_accessable (ex_mul_accessable),
        .i_is_vld     (is_rs_mul_vld),
        .i_signed1    (ex_mul_signed1), 
        .i_signed2    (ex_mul_signed2),
        .i_sel_high   (ex_mul_sel_high),
        .i_src1       (ex_mul_rs1_srcopr),
        .i_src2       (ex_mul_rs2_srcopr),
        .o_exfin      (exfin_mul),
        .o_exfin_res  (exfin_mul_res)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            ex_ldst_rs1_srcopr     <= 'd0;
            ex_ldst_rs2_srcopr     <= 'd0;
            ex_ldst_imm            <= 'd0;
            ex_ldst_is_st          <= 'd0;
            ex_ldst_rrftag         <= 'd0;
        end else begin    
            // Maintain until exfinshed, so actually this is a buf rather than pipe-regs
            if (is_rs_ldst_vld) begin
                ex_ldst_rs1_srcopr <= is_ldst_rs1_srcopr;
                ex_ldst_rs2_srcopr <= is_ldst_rs2_srcopr;
                ex_ldst_imm        <= is_ldst_imm;
                ex_ldst_is_st      <= is_ldst_is_st;
                ex_ldst_rrftag     <= is_ldst_rrftag;
            end
        end
    end

    exunit_ldst u_exunit_ldst (
        .clk              (clk),
        .rst_n            (rst_n),
        .o_accessable     (ex_ldst_accessable),
        .i_is_vld         (is_rs_ldst_vld),
        .i_rs1            (ex_ldst_rs1_srcopr),
        .i_rs2            (ex_ldst_rs2_srcopr),
        .i_imm            (ex_ldst_imm),
        .i_is_st          (ex_ldst_is_st),
        .i_rrftag         (ex_ldst_rrftag),
        .o_ld_addr        (ex_ld_addr),
        .i_stbuf_addr_hit (stbuf_addr_hit),
        .i_stbuf_rd_data  (stbuf_rd_data),
        .o_dmem_occupy    (dmem_occupy),
        .i_dmem_rd_data   (i_dmem_rd_data),
        .o_ex_ld_rrftag   (ex_ld_rrftag), 
        .o_exfin_ld       (exfin_ld),
        .o_exfin_ld_res   (exfin_ld_res),
        .i_stbuf_full     (stbuf_full),
        .o_exfin_st       (exfin_st),
        .o_exfin_st_addr  (exfin_st_addr),
        .o_exfin_st_data  (exfin_st_data)
    );

    stbuf u_stbuf (
        .clk              (clk),
        .rst_n            (rst_n),
        .o_full           (stbuf_full),
        .i_exfin_st       (exfin_st),
        .i_exfin_st_addr  (exfin_st_addr),
        .i_exfin_st_data  (exfin_st_data),
        .i_com_st         (com_st),
        .i_dmem_occupy    (dmem_occupy),
        .o_ret_stbuf      (ret_stbuf),
        .o_ret_stbuf_addr (ret_stbuf_addr),
        .o_ret_stbuf_data (ret_stbuf_data),
        .i_ld_addr        (ex_ld_addr),
        .o_stbuf_addr_hit (stbuf_addr_hit),
        .o_stbuf_rd_data  (stbuf_rd_data)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            ex_br_is_jal           <= 'd0;
            ex_br_is_jalr          <= 'd0;
            ex_br_alu_op_sel       <= 'd0;
            ex_br_rs1_srcopr       <= 'd0;
            ex_br_rs2_srcopr       <= 'd0;
            ex_br_pc               <= 'd0;
            ex_br_imm              <= 'd0;
            ex_br_pred_jmpaddr     <= 'd0;
            ex_br_rrftag           <= 'd0;
        end else begin      
            // Maintain until exfinshed, so actually this is a buf rather than pipe-regs
            if (is_rs_br_vld) begin
                ex_br_is_jal       <= is_br_is_jal;
                ex_br_is_jalr      <= is_br_is_jalr;
                ex_br_alu_op_sel   <= is_br_alu_op_sel;
                ex_br_rs1_srcopr   <= is_br_rs1_srcopr;
                ex_br_rs2_srcopr   <= is_br_rs2_srcopr;
                ex_br_pc           <= is_br_pc;
                ex_br_imm          <= is_br_imm;
                ex_br_pred_jmpaddr <= is_br_pred_jmpaddr;
                ex_br_rrftag       <= is_br_rrftag;
            end
        end
    end

    exunit_br u_exunit_br (
        .clk                  (clk),
        .rst_n                (rst_n),
        .o_accessable         (ex_br_accessable),
        .i_is_vld             (is_rs_br_vld),
        .i_is_jal             (ex_br_is_jal),
        .i_is_jalr            (ex_br_is_jalr),
        .i_alu_op_sel         (ex_br_alu_op_sel),
        .i_rs1                (ex_br_rs1_srcopr),
        .i_rs2                (ex_br_rs2_srcopr),
        .i_pc                 (ex_br_pc),
        .i_imm                (ex_br_imm),
        .i_pred_jmpaddr       (ex_br_pred_jmpaddr),
        .o_exfin_jal_jalr     (exfin_jal_jalr),
        .o_exfin_jal_jalr_res (exfin_jal_jalr_res),
        .o_exfin              (exfin_br),
        .o_exfin_jmpaddr      (exfin_br_jmpaddr),
        .o_exfin_jmpcond      (exfin_br_jmpcond),
        .o_exfin_prsuc        (exfin_prsuc),   
        .o_exfin_prmiss       (exfin_prmiss)
    );

    // ---------------------------------------------------- //
    // -------------------- COM-Stage --------------------- //
    // ---------------------------------------------------- //  

    rob u_rob (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_stall            (dp_stall),
        .i_dp_vld_1         (dp_vld_1),
        .i_dp_ptr_1         (dp_ptr_1),
        .i_dp_rd_wr_en_1    (dp_rd_wr_en_1),
        .i_dp_rd_wr_addr_1  (dp_rd_wr_addr_1),
        .i_dp_is_st_1       (dp_is_st_1),
        .i_dp_is_br_1       (dp_is_br_1),
        .i_dp_pc_1          (dp_pc_1),
        .i_dp_ghr_1         (dp_ghr),   // Share the same ghr       
        .i_dp_vld_2         (dp_vld_2),
        .i_dp_ptr_2         (dp_ptr_2),
        .i_dp_rd_wr_en_2    (dp_rd_wr_en_2),
        .i_dp_rd_wr_addr_2  (dp_rd_wr_addr_2),
        .i_dp_is_st_2       (dp_is_st_2),
        .i_dp_is_br_2       (dp_is_br_2),
        .i_dp_pc_2          (dp_pc_2),
        .i_dp_ghr_2         (dp_ghr),   // Share the same ghr   
        .i_ex_alu_rrftag    (ex_alu_rrftag),
        .i_exfin_alu        (exfin_alu),
        .i_ex_mul_rrftag    (ex_mul_rrftag),
        .i_exfin_mul        (exfin_mul),  
        .i_ex_ld_rrftag     (ex_ld_rrftag), 
        .i_exfin_ld         (exfin_ld),   
        .i_ex_st_rrftag     (ex_ldst_rrftag), 
        .i_exfin_st         (exfin_st), 
        .i_ex_br_rrftag     (ex_br_rrftag),
        .i_exfin_br         (exfin_br),
        .i_exfin_br_jmpaddr (exfin_br_jmpaddr),
        .i_exfin_br_jmpcond (exfin_br_jmpcond),        
        .o_com_num          (com_num),
        .o_com_vld_1        (com_vld_1),
        .o_com_ptr_1        (com_ptr_1),
        .o_com_rd_wr_en_1   (com_rd_wr_en_1),
        .o_com_rd_wr_addr_1 (com_rd_wr_addr_1),
        .o_com_vld_2        (com_vld_2),
        .o_com_ptr_2        (com_ptr_2),
        .o_com_rd_wr_en_2   (com_rd_wr_en_2),
        .o_com_rd_wr_addr_2 (com_rd_wr_addr_2),
        .o_com_st           (com_st),
        .o_com_br           (com_br),
        .o_com_pc           (com_pc),
        .o_com_ghr          (com_ghr),
        .o_com_jmpaddr      (com_jmpaddr),
        .o_com_jmpcond      (com_jmpcond)
    );

endmodule

`default_nettype wire
