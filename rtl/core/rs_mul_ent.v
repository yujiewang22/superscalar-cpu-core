`default_nettype none
`include "constants.vh"

module rs_mul_ent (
    input  wire                        clk,
    input  wire                        rst_n,
    // state 
    output reg                         o_busy,
    output wire                        o_vld,
    // Write entry
    input  wire                        i_wr_en,
    input  wire                        i_dp_mul_signed1,
    input  wire                        i_dp_mul_signed2,
    input  wire                        i_dp_mul_sel_high,
    input  wire                        i_dp_rs1_srcopr_vld,
    input  wire                        i_dp_rs2_srcopr_vld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs1_srcopr,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dp_rs2_srcopr,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_rrftag,
    // Read entry
    input  wire                        i_rd_en,
    output reg                         o_mul_signed1,
    output reg                         o_mul_signed2,
    output reg                         o_mul_sel_high,
    output reg  [`RV32_DATA_WIDTH-1:0] o_rs1_srcopr,
    output reg  [`RV32_DATA_WIDTH-1:0] o_rs2_srcopr,
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
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_ld_res
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
            o_mul_signed1  <= 'd0;
            o_mul_signed2  <= 'd0;
            o_mul_sel_high <= 'd0;
            rs1_srcopr_vld <= 'd0;
            rs2_srcopr_vld <= 'd0;
            o_rs1_srcopr   <= 'd0;
            o_rs2_srcopr   <= 'd0;
            o_rrftag       <= 'd0;
        end else begin
            if (i_wr_en) begin
                o_mul_signed1  <= i_dp_mul_signed1;
                o_mul_signed2  <= i_dp_mul_signed2;
                o_mul_sel_high <= i_dp_mul_sel_high;
                rs1_srcopr_vld <= i_dp_rs1_srcopr_vld;
                rs2_srcopr_vld <= i_dp_rs2_srcopr_vld;
                o_rs1_srcopr   <= i_dp_rs1_srcopr;
                o_rs2_srcopr   <= i_dp_rs2_srcopr;
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
        .i_srcopr_vld       (rs1_srcopr_vld),
        .i_srcopr           (o_rs1_srcopr),
        .i_ex_alu_rrftag    (i_ex_alu_rrftag),
        .i_exfin_alu        (i_exfin_alu),
        .i_exfin_alu_res    (i_exfin_alu_res),
        .i_ex_mul_rrftag    (i_ex_mul_rrftag),
        .i_exfin_mul        (i_exfin_mul),
        .i_exfin_mul_res    (i_exfin_mul_res),
        .i_ex_ld_rrftag     (i_ex_ld_rrftag),
        .i_exfin_ld         (i_exfin_ld),
        .i_exfin_ld_res     (i_exfin_ld_res),
        .o_srcopr_fwd_vld   (rs1_srcopr_fwd_vld),
        .o_srcopr_fwd       (rs1_srcopr_fwd)
    );

    srcopr_fwd_unit u_srcopr_fwd_unit_2 (
        .i_srcopr_vld       (rs2_srcopr_vld),
        .i_srcopr           (o_rs2_srcopr),
        .i_ex_alu_rrftag    (i_ex_alu_rrftag),
        .i_exfin_alu        (i_exfin_alu),
        .i_exfin_alu_res    (i_exfin_alu_res),
        .i_ex_mul_rrftag    (i_ex_mul_rrftag),
        .i_exfin_mul        (i_exfin_mul),
        .i_exfin_mul_res    (i_exfin_mul_res),
        .i_ex_ld_rrftag     (i_ex_ld_rrftag),
        .i_exfin_ld         (i_exfin_ld),
        .i_exfin_ld_res     (i_exfin_ld_res),
        .o_srcopr_fwd_vld   (rs2_srcopr_fwd_vld),
        .o_srcopr_fwd       (rs2_srcopr_fwd)
    );

    // Dependency, vld can be set only when busy is set
    assign o_vld = o_busy && rs1_srcopr_vld && rs2_srcopr_vld;

endmodule

`default_nettype wire
