`default_nettype none
`include "constants.vh"

module rs_ldst (
    input  wire                        clk,
    input  wire                        rst_n,
    // State
    output wire [`RS_LDST_ENT_NUM-1:0] o_busy_vec,
    output wire [`RS_LDST_ENT_NUM-1:0] o_vld_vec,
    // Dp stall
    input  wire                        i_stall,
    // Dp-stage read inst1
    input  wire                        i_alloc_vld_1,
    input  wire [`RS_LDST_ENT_SEL-1:0] i_alloc_sel_1,
    input  wire                        i_dp_rs1_srcopr_vld_1,
    input  wire                        i_dp_rs2_srcopr_vld_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_imm_1,
    input  wire                        i_dp_is_st_1,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag_1,
    // Dp-stage read inst2
    input  wire                        i_alloc_vld_2,
    input  wire [`RS_LDST_ENT_SEL-1:0] i_alloc_sel_2, 
    input  wire                        i_dp_rs1_srcopr_vld_2,
    input  wire                        i_dp_rs2_srcopr_vld_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_imm_2,
    input  wire                        i_dp_is_st_2,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag_2,
    // Is-stage sel
    input  wire                        i_is_vld,
    input  wire [`RS_LDST_ENT_SEL-1:0] i_is_sel,
    // Is-stage read
    output wire [`RV32_DATA_WIDTH-1:0] o_is_rs1_srcopr,
    output wire [`RV32_DATA_WIDTH-1:0] o_is_rs2_srcopr,
    output wire [`RV32_DATA_WIDTH-1:0] o_is_imm,
    output wire                        o_is_is_st,
    output wire [`RRF_ENT_SEL-1:0]     o_is_rrftag,
    // Renew entry when exfinish
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_alu_rrftag,
    input  wire                        i_exfin_alu,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_alu_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_mul_rrftag,
    input  wire                        i_exfin_mul,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_mul_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_ld_rrftag,
    input  wire                        i_exfin_ld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_ld_res
);

    wire [`RV32_DATA_WIDTH-1:0] rs1_srcopr_1;
    wire [`RV32_DATA_WIDTH-1:0] rs2_srcopr_1;
    wire [`RV32_DATA_WIDTH-1:0] imm_1;
    wire                        is_st_1;
    wire [`RRF_ENT_SEL-1:0]     rrftag_1;


    wire [`RV32_DATA_WIDTH-1:0] rs1_srcopr_2;
    wire [`RV32_DATA_WIDTH-1:0] rs2_srcopr_2;
    wire [`RV32_DATA_WIDTH-1:0] imm_2;
    wire                        is_st_2;
    wire [`RRF_ENT_SEL-1:0]     rrftag_2;

    rs_ldst_ent u_rs_ldst_ent_1 (
        .clk                 (clk),
        .rst_n               (rst_n),
        .o_busy              (o_busy_vec[0]),
        .o_vld               (o_vld_vec[0]),
        .i_wr_en             (!i_stall && ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) || (i_alloc_vld_2 && (i_alloc_sel_2 == 'd0)))),
        .i_dp_rs1_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs1_srcopr_vld_1 : i_dp_rs1_srcopr_vld_2),
        .i_dp_rs2_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs2_srcopr_vld_1 : i_dp_rs2_srcopr_vld_2),
        .i_dp_rs1_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs1_srcopr_1 : i_dp_rs1_srcopr_2),
        .i_dp_rs2_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs2_srcopr_1 : i_dp_rs2_srcopr_2),
        .i_dp_imm            ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_imm_1 : i_dp_imm_2),
        .i_dp_is_st          ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_is_st_1 : i_dp_is_st_2),
        .i_dp_rrftag         ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rrftag_1 : i_dp_rrftag_2),
        .i_rd_en             (i_is_vld && (i_is_sel == 'd0)),
        .o_rs1_srcopr        (rs1_srcopr_1),
        .o_rs2_srcopr        (rs2_srcopr_1),
        .o_imm               (imm_1),
        .o_is_st             (is_st_1),
        .o_rrftag            (rrftag_1),
        .i_ex_alu_rrftag     (i_ex_alu_rrftag),
        .i_exfin_alu         (i_exfin_alu),
        .i_exfin_alu_res     (i_exfin_alu_res),
        .i_ex_mul_rrftag     (i_ex_mul_rrftag),
        .i_exfin_mul         (i_exfin_mul),
        .i_exfin_mul_res     (i_exfin_mul_res),
        .i_ex_ld_rrftag      (i_ex_ld_rrftag),
        .i_exfin_ld          (i_exfin_ld),
        .i_exfin_ld_res      (i_exfin_ld_res) 
    );

    rs_ldst_ent u_rs_ldst_ent_2 (
        .clk                 (clk),
        .rst_n               (rst_n),
        .o_busy              (o_busy_vec[1]),
        .o_vld               (o_vld_vec[1]),
        .i_wr_en             (!i_stall && ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) || (i_alloc_vld_2 && (i_alloc_sel_2 == 'd1)))),
        .i_dp_rs1_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs1_srcopr_vld_1 : i_dp_rs1_srcopr_vld_2),
        .i_dp_rs2_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs2_srcopr_vld_1 : i_dp_rs2_srcopr_vld_2),
        .i_dp_rs1_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs1_srcopr_1 : i_dp_rs1_srcopr_2),
        .i_dp_rs2_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs2_srcopr_1 : i_dp_rs2_srcopr_2),
        .i_dp_imm            ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_imm_1 : i_dp_imm_2),
        .i_dp_is_st          ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_is_st_1 : i_dp_is_st_2),
        .i_dp_rrftag         ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rrftag_1 : i_dp_rrftag_2),
        .i_rd_en             (i_is_vld && (i_is_sel == 'd1)),
        .o_rs1_srcopr        (rs1_srcopr_2),
        .o_rs2_srcopr        (rs2_srcopr_2),
        .o_imm               (imm_2),
        .o_is_st             (is_st_2),
        .o_rrftag            (rrftag_2),
        .i_ex_alu_rrftag     (i_ex_alu_rrftag),
        .i_exfin_alu         (i_exfin_alu),
        .i_exfin_alu_res     (i_exfin_alu_res),
        .i_ex_mul_rrftag     (i_ex_mul_rrftag),
        .i_exfin_mul         (i_exfin_mul),
        .i_exfin_mul_res     (i_exfin_mul_res),
        .i_ex_ld_rrftag      (i_ex_ld_rrftag),
        .i_exfin_ld          (i_exfin_ld),
        .i_exfin_ld_res      (i_exfin_ld_res) 
    );

    assign o_is_rs1_srcopr = (i_is_sel == 'd0) ? rs1_srcopr_1 : rs1_srcopr_2;
    assign o_is_rs2_srcopr = (i_is_sel == 'd0) ? rs2_srcopr_1 : rs2_srcopr_2;
    assign o_is_imm        = (i_is_sel == 'd0) ? imm_1 : imm_2;
    assign o_is_is_st      = (i_is_sel == 'd0) ? is_st_1 : is_st_2;
    assign o_is_rrftag     = (i_is_sel == 'd0) ? rrftag_1 : rrftag_2;

endmodule

`default_nettype wire
