`default_nettype none
`include "constants.vh"

module rs_mul (
    input  wire                        clk,
    input  wire                        rst_n,
    // State
    output wire [`RS_MUL_ENT_NUM-1:0]  o_busy_vec,
    output wire [`RS_MUL_ENT_NUM-1:0]  o_vld_vec,
    // Dp stall
    input  wire                        i_stall,
    // Dp-stage read inst1
    input  wire                        i_alloc_vld_1,
    input  wire [`RS_MUL_ENT_SEL-1:0]  i_alloc_sel_1,
    input  wire                        i_dp_mul_signed1_1,
    input  wire                        i_dp_mul_signed2_1,
    input  wire                        i_dp_mul_sel_high_1,
    input  wire                        i_dp_rs1_srcopr_vld_1,
    input  wire                        i_dp_rs2_srcopr_vld_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr_1,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag_1,
    // Dp-stage read inst2
    input  wire                        i_alloc_vld_2,
    input  wire [`RS_MUL_ENT_SEL-1:0]  i_alloc_sel_2, 
    input  wire                        i_dp_mul_signed1_2,
    input  wire                        i_dp_mul_signed2_2,
    input  wire                        i_dp_mul_sel_high_2,
    input  wire                        i_dp_rs1_srcopr_vld_2,
    input  wire                        i_dp_rs2_srcopr_vld_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr_2,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag_2,
    // Is-stage sel
    input  wire                        i_is_vld,
    input  wire [`RS_ALU_ENT_SEL-1:0]  i_is_sel,
    // Is-stage read
    input  wire                        o_is_mul_signed1,
    input  wire                        o_is_mul_signed2,
    input  wire                        o_is_mul_sel_high,
    output wire [`RV32_DATA_WIDTH-1:0] o_is_rs1_srcopr,
    output wire [`RV32_DATA_WIDTH-1:0] o_is_rs2_srcopr,
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

    wire                        mul_signed1_1;
    wire                        mul_signed2_1;
    wire                        mul_sel_high_1;
    wire [`RV32_DATA_WIDTH-1:0] rs1_srcopr_1;
    wire [`RV32_DATA_WIDTH-1:0] rs2_srcopr_1;
    wire [`RRF_ENT_SEL-1:0]     rrftag_1;

    wire                        mul_signed1_2;
    wire                        mul_signed2_2;
    wire                        mul_sel_high_2;
    wire [`RV32_DATA_WIDTH-1:0] rs1_srcopr_2;
    wire [`RV32_DATA_WIDTH-1:0] rs2_srcopr_2;
    wire [`RRF_ENT_SEL-1:0]     rrftag_2;

    rs_mul_ent u_rs_mul_ent_1 (
        .clk                 (clk),
        .rst_n               (rst_n),
        .o_busy              (o_busy_vec[0]),
        .o_vld               (o_vld_vec[0]),
        .i_wr_en             (!i_stall && ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) || (i_alloc_vld_2 && (i_alloc_sel_2 == 'd0)))),
        .i_dp_mul_signed1    ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_mul_signed1_1 : i_dp_mul_signed1_2),
        .i_dp_mul_signed2    ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_mul_signed2_1 : i_dp_mul_signed2_2),
        .i_dp_mul_sel_high   ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_mul_sel_high_1 : i_dp_mul_sel_high_2),
        .i_dp_rs1_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs1_srcopr_vld_1 : i_dp_rs1_srcopr_vld_2),
        .i_dp_rs2_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs2_srcopr_vld_1 : i_dp_rs2_srcopr_vld_2),
        .i_dp_rs1_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs1_srcopr_1 : i_dp_rs1_srcopr_2),
        .i_dp_rs2_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rs2_srcopr_1 : i_dp_rs2_srcopr_2),
        .i_dp_rrftag         ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd0)) ? i_dp_rrftag_1 : i_dp_rrftag_2),
        .i_rd_en             (i_is_vld && (i_is_sel == 'd0)),
        .o_mul_signed1       (mul_signed1_1),
        .o_mul_signed2       (mul_signed2_1),
        .o_mul_sel_high      (mul_sel_high_1),
        .o_rs1_srcopr        (rs1_srcopr_1),
        .o_rs2_srcopr        (rs2_srcopr_1),
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

    rs_mul_ent u_rs_mul_ent_2 (
        .clk                 (clk),
        .rst_n               (rst_n),
        .o_busy              (o_busy_vec[1]),
        .o_vld               (o_vld_vec[1]),
        .i_wr_en             (!i_stall && ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) || (i_alloc_vld_2 && (i_alloc_sel_2 == 'd1)))),
        .i_dp_mul_signed1    ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_mul_signed1_1 : i_dp_mul_signed1_2),
        .i_dp_mul_signed2    ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_mul_signed2_1 : i_dp_mul_signed2_2),
        .i_dp_mul_sel_high   ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_mul_sel_high_1 : i_dp_mul_sel_high_2),
        .i_dp_rs1_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs1_srcopr_vld_1 : i_dp_rs1_srcopr_vld_2),
        .i_dp_rs2_srcopr_vld ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs2_srcopr_vld_1 : i_dp_rs2_srcopr_vld_2),
        .i_dp_rs1_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs1_srcopr_1 : i_dp_rs1_srcopr_2),
        .i_dp_rs2_srcopr     ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rs2_srcopr_1 : i_dp_rs2_srcopr_2),
        .i_dp_rrftag         ((i_alloc_vld_1 && (i_alloc_sel_1 == 'd1)) ? i_dp_rrftag_1 : i_dp_rrftag_2),
        .i_rd_en             (i_is_vld && (i_is_sel == 'd1)),
        .o_mul_signed1       (mul_signed1_2),
        .o_mul_signed2       (mul_signed2_2),
        .o_mul_sel_high      (mul_sel_high_2),
        .o_rs1_srcopr        (rs1_srcopr_2),
        .o_rs2_srcopr        (rs2_srcopr_2),
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

    assign o_is_mul_signed1  = (i_is_sel == 'd0) ? mul_signed1_1 : mul_signed1_2;
    assign o_is_mul_signed2  = (i_is_sel == 'd0) ? mul_signed2_1 : mul_signed2_2;
    assign o_is_mul_sel_high = (i_is_sel == 'd0) ? mul_sel_high_1 : mul_sel_high_2;
    assign o_is_rs1_srcopr   = (i_is_sel == 'd0) ? rs1_srcopr_1 : rs1_srcopr_2;
    assign o_is_rs2_srcopr   = (i_is_sel == 'd0) ? rs2_srcopr_1 : rs2_srcopr_2;
    assign o_is_rrftag       = (i_is_sel == 'd0) ? rrftag_1 : rrftag_2;

endmodule

`default_nettype wire