`default_nettype none
`include "constants.vh"

module br_predictor (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      i_inst_vld_1,
    input  wire                      i_inst_vld_2,
    input  wire [`RV32_PC_WIDTH-1:0] i_pc_1,
    input  wire [`RV32_PC_WIDTH-1:0] i_pc_2,
    output reg  [`GSH_GHR_WIDTH-1:0] o_ghr,
    output wire                      o_pred_jmp,
    output wire [`RV32_PC_WIDTH-1:0] o_pc_btb,
    input  wire                      i_com_br,
    input  wire [`RV32_PC_WIDTH-1:0] i_com_pc,
    input  wire [`GSH_GHR_WIDTH-1:0] i_com_ghr,
    input  wire [`RV32_PC_WIDTH-1:0] i_com_jmpaddr,
    input  wire                      i_com_jmpcond
);

    wire hit_btb;
    wire pred_jmpcond;

    btb u_btb (
        .clk          (clk),
        .rst_n        (rst_n),
        .i_inst_vld_1 (i_inst_vld_1),
        .i_inst_vld_2 (i_inst_vld_2),
        .i_pc_1       (i_pc_1),
        .i_pc_2       (i_pc_2),
        .o_hit_btb    (hit_btb),
        .o_pc_btb     (o_pc_btb),
        .i_wr_en      (i_com_br),
        .i_jmpsrc     (i_com_pc),
        .i_jmpaddr    (i_com_jmpaddr)
    );

    gshare u_gshare (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_pc           (i_pc_1),
        .o_ghr          (o_ghr),
        .o_pred_jmpcond (pred_jmpcond),
        .i_hit_btb      (hit_btb),
        .i_pht_wr_en    (i_com_br),
        .i_pht_wr_addr  (i_com_pc[2+:`GSH_PHT_ENT_SEL] ^ i_com_ghr),
        .i_jmpcond      (i_com_jmpcond)
    ); 

    assign o_pred_jmp = hit_btb && pred_jmpcond;

endmodule

`default_nettype wire
