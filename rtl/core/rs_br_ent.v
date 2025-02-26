`default_nettype none
`include "constants.vh"

module rs_ldst_ent (
    input  wire                        clk,
    input  wire                        rst_n,
    // state 
    output reg                         o_busy,
    output wire                        o_vld,
    // Write entry
    input  wire                        i_wr_en,
    input  wire                        i_dp_rs1_srcopr_vld,
    input  wire                        i_dp_rs2_srcopr_vld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr,
    input  wire                        i_dp_is_jal,
    input  wire                        i_dp_is_jalr,
    input  wire [`ALU_OP_SEL-1:0]      i_dp_alu_op_sel,
    input  wire [`RV32_PC_WIDTH-1:0]   i_dp_pc,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_imm,
    input  wire [`RV32_PC_WIDTH-1:0]   i_dp_pred_jmpaddr,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag,
    // Read entry
    input  wire                        i_rd_en,
    output reg  [`RV32_DATA_WIDTH-1:0] o_rs1_srcopr,
    output reg  [`RV32_DATA_WIDTH-1:0] o_rs2_srcopr,
    output reg                         o_is_jal,
    output reg                         o_is_jalr,
    output reg  [`ALU_OP_SEL-1:0]      o_alu_op_sel,
    output reg  [`RV32_PC_WIDTH-1:0]   o_pc,
    output reg  [`RV32_DATA_WIDTH-1:0] o_imm,
    output reg  [`RV32_PC_WIDTH-1:0]   o_pred_jmpaddr,
    output reg  [`RRF_ENT_SEL-1:0]     o_rrftag,
    // Renew entry when exfinish
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_alu_rrftag,
    input  wire                        i_exfin_alu,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_alu_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_mul_rrftag,
    input  wire                        i_exfin_mul,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_mul_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_ld_rrftag,
    input  wire                        i_exfin_ld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_ld_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_jal_jalr_rrftag,
    input  wire                        i_exfin_jal_jalr,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_jal_jalr_res
);

    reg                         rs1_srcopr_vld;
    reg                         rs2_srcopr_vld;

    wire                        rs1_srcopr_fwd_vld;
    wire                        rs2_srcopr_fwd_vld;
    wire [`RV32_DATA_WIDTH-1:0] rs1_srcopr_fwd;
    wire [`RV32_DATA_WIDTH-1:0] rs2_srcopr_fwd;

    // Busy
    // No succession, both read/write take two cycles
    always @(posedge clk) begin
        if (!rst_n) begin
            o_busy <= 'd0;
        end else begin
            if (i_wr_en) begin
                o_busy <= 'd1;
            end
            if (i_rd_en) begin
                o_busy <= 'd0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            rs1_srcopr_vld <= 'd0;
            rs2_srcopr_vld <= 'd0;
            o_rs1_srcopr   <= 'd0;
            o_rs2_srcopr   <= 'd0;
            o_is_jal       <= 'd0;
            o_is_jalr      <= 'd0;
            o_alu_op_sel   <= 'd0;
            o_pc           <= 'd0;
            o_imm          <= 'd0;
            o_pred_jmpaddr <= 'd0;
            o_rrftag       <= 'd0;
        end else begin
            if (i_wr_en) begin
                rs1_srcopr_vld <= i_dp_rs1_srcopr_vld;
                rs2_srcopr_vld <= i_dp_rs2_srcopr_vld;
                o_rs1_srcopr   <= i_dp_rs1_srcopr;
                o_rs2_srcopr   <= i_dp_rs2_srcopr;
                o_is_jal       <= i_dp_is_jal;
                o_is_jalr      <= i_dp_is_jalr;
                o_alu_op_sel   <= i_dp_alu_op_sel;
                o_pc           <= i_dp_pc;
                o_imm          <= i_dp_imm;
                o_pred_jmpaddr <= i_dp_pred_jmpaddr;
                o_rrftag       <= i_dp_rrftag;
            end else begin
                // Alwasys renewed by fwd unit
                rs1_srcopr_vld <= rs1_srcopr_fwd_vld;
                rs2_srcopr_vld <= rs2_srcopr_fwd_vld;
                o_rs1_srcopr   <= rs1_srcopr_fwd;
                o_rs2_srcopr   <= rs2_srcopr_fwd;
            end
        end
    end

    srcopr_fwd_unit u_srcopr_fwd_unit_1 (
        .i_srcopr_vld         (rs1_srcopr_vld),
        .i_srcopr             (o_rs1_srcopr),
        .i_ex_alu_rrftag      (i_ex_alu_rrftag),
        .i_exfin_alu          (i_exfin_alu),
        .i_exfin_alu_res      (i_exfin_alu_res),
        .i_ex_mul_rrftag      (i_ex_mul_rrftag),
        .i_exfin_mul          (i_exfin_mul),
        .i_exfin_mul_res      (i_exfin_mul_res),
        .i_ex_ld_rrftag       (i_ex_ld_rrftag),
        .i_exfin_ld           (i_exfin_ld),
        .i_exfin_ld_res       (i_exfin_ld_res),
        .i_ex_jal_jalr_rrftag (i_ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (i_exfin_jal_jalr),
        .i_exfin_jal_jalr_res (i_exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (rs1_srcopr_fwd_vld),
        .o_srcopr_fwd         (rs1_srcopr_fwd)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_2 (
        .i_srcopr_vld         (rs2_srcopr_vld),
        .i_srcopr             (o_rs2_srcopr),
        .i_ex_alu_rrftag      (i_ex_alu_rrftag),
        .i_exfin_alu          (i_exfin_alu),
        .i_exfin_alu_res      (i_exfin_alu_res),
        .i_ex_mul_rrftag      (i_ex_mul_rrftag),
        .i_exfin_mul          (i_exfin_mul),
        .i_exfin_mul_res      (i_exfin_mul_res),
        .i_ex_ld_rrftag       (i_ex_ld_rrftag),
        .i_exfin_ld           (i_exfin_ld),
        .i_exfin_ld_res       (i_exfin_ld_res),
        .i_ex_jal_jalr_rrftag (i_ex_jal_jalr_rrftag),
        .i_exfin_jal_jalr     (i_exfin_jal_jalr),
        .i_exfin_jal_jalr_res (i_exfin_jal_jalr_res),
        .o_srcopr_fwd_vld     (rs2_srcopr_fwd_vld),
        .o_srcopr_fwd         (rs2_srcopr_fwd)
    );

    // Dependency, vld can be set only when busy is set
    assign o_vld = o_busy && rs1_srcopr_vld && rs2_srcopr_vld;

endmodule

`default_nettype wire
