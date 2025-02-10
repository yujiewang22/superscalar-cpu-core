`default_nettype none
`include "constants.vh"

module arf (
    input  wire                         clk,
    input  wire                         rst_n,
    // Dp-stage read
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_addr_1,
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_addr_2,
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_addr_3,
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_addr_4,
    output wire                         o_dp_rd_busy_1,
    output wire                         o_dp_rd_busy_2,
    output wire                         o_dp_rd_busy_3,
    output wire                         o_dp_rd_busy_4,
    output wire [`RRF_ENT_SEL-1:0]      o_dp_rd_rrftag_1,
    output wire [`RRF_ENT_SEL-1:0]      o_dp_rd_rrftag_2,
    output wire [`RRF_ENT_SEL-1:0]      o_dp_rd_rrftag_3,
    output wire [`RRF_ENT_SEL-1:0]      o_dp_rd_rrftag_4,
    output wire [`RV32_DATA_WIDTH-1:0]  o_dp_rd_data_1,
    output wire [`RV32_DATA_WIDTH-1:0]  o_dp_rd_data_2,
    output wire [`RV32_DATA_WIDTH-1:0]  o_dp_rd_data_3,
    output wire [`RV32_DATA_WIDTH-1:0]  o_dp_rd_data_4,
    // Dp-stage rename
    input  wire                         i_dp_vld_1,
    input  wire [`RRF_ENT_SEL-1:0]      i_dp_ptr_1,
    input  wire                         i_dp_rd_wr_en_1,
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_wr_addr_1,
    input  wire                         i_dp_vld_2,
    input  wire [`RRF_ENT_SEL-1:0]      i_dp_ptr_2,
    input  wire                         i_dp_rd_wr_en_2,
    input  wire [`RV32_ARF_SEL-1:0]     i_dp_rd_wr_addr_2,
    // Com-stage cancel rename and write back
    input  wire                         i_com_vld_1,
    input  wire                         i_com_rd_wr_en_1,
    input  wire [`RV32_ARF_SEL-1:0]     i_com_rd_wr_addr_1,
    input  wire [`RV32_DATA_WIDTH-1:0]  i_com_rd_wr_data_1,
    input  wire                         i_com_vld_2,
    input  wire                         i_com_rd_wr_en_2,
    input  wire [`RV32_ARF_SEL-1:0]     i_com_rd_wr_addr_2,
    input  wire [`RV32_DATA_WIDTH-1:0]  i_com_rd_wr_data_2
);

    regfile u_regfile (
        .clk         (clk),
        .i_rd_addr_1 (i_dp_rd_addr_1),
        .i_rd_addr_2 (i_dp_rd_addr_2),
        .i_rd_addr_3 (i_dp_rd_addr_3),
        .i_rd_addr_4 (i_dp_rd_addr_4),
        .o_rd_data_1 (o_dp_rd_data_1),
        .o_rd_data_2 (o_dp_rd_data_2),
        .o_rd_data_3 (o_dp_rd_data_3),
        .o_rd_data_4 (o_dp_rd_data_4),
        .i_wr_en_1   (i_com_vld_1 && i_com_rd_wr_en_1 && (i_com_rd_wr_addr_1 != 'd0)),
        .i_wr_addr_1 (i_com_rd_wr_addr_1),
        .i_wr_data_1 (i_com_rd_wr_data_1),
        .i_wr_en_2   (i_com_vld_2 && i_com_rd_wr_en_2 && (i_com_rd_wr_addr_2 != 'd0)),
        .i_wr_addr_2 (i_com_rd_wr_addr_2),
        .i_wr_data_2 (i_com_rd_wr_data_2)
    );

    renaming_table u_renaming_table (
        .clk                (clk),
        .rst_n              (rst_n),
        .i_rd_addr_1        (i_dp_rd_addr_1),
        .i_rd_addr_2        (i_dp_rd_addr_2),
        .i_rd_addr_3        (i_dp_rd_addr_3),
        .i_rd_addr_4        (i_dp_rd_addr_4),
        .o_rd_busy_1        (o_dp_rd_busy_1),
        .o_rd_busy_2        (o_dp_rd_busy_2),
        .o_rd_busy_3        (o_dp_rd_busy_3),
        .o_rd_busy_4        (o_dp_rd_busy_4),
        .o_rd_rrftag_1      (o_dp_rd_rrftag_1),
        .o_rd_rrftag_2      (o_dp_rd_rrftag_2),
        .o_rd_rrftag_3      (o_dp_rd_rrftag_3),
        .o_rd_rrftag_4      (o_dp_rd_rrftag_4),
        .i_dp_vld_1         (i_dp_vld_1),
        .i_dp_ptr_1         (i_dp_ptr_1),
        .i_dp_rd_wr_en_1    (i_dp_rd_wr_en_1),
        .i_dp_rd_wr_addr_1  (i_dp_rd_wr_addr_1),
        .i_dp_vld_2         (i_dp_vld_2),
        .i_dp_ptr_2         (i_dp_ptr_2),
        .i_dp_rd_wr_en_2    (i_dp_rd_wr_en_2),
        .i_dp_rd_wr_addr_2  (i_dp_rd_wr_addr_2),
        .i_com_vld_1        (i_com_vld_1),
        .i_com_rd_wr_addr_1 (i_com_rd_wr_addr_1),
        .i_com_vld_2        (i_com_vld_2),
        .i_com_rd_wr_addr_2 (i_com_rd_wr_addr_2)
    );

endmodule

`default_nettype wire
