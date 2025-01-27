`default_nettype none
`include "constants.vh"

module pht (
    input  wire                           clk,
    input  wire [`GSH_PHT_ENT_SEL-1:0]    i_rd_addr_1,
    input  wire [`GSH_PHT_ENT_SEL-1:0]    i_rd_addr_2,
    output wire [`GSH_PHT_DATA_WIDTH-1:0] o_rd_data_1,
    output wire [`GSH_PHT_DATA_WIDTH-1:0] o_rd_data_2,
    input  wire                           i_wr_en,
    input  wire [`GSH_PHT_ENT_SEL-1:0]    i_wr_addr,
    input  wire [`GSH_PHT_DATA_WIDTH-1:0] i_wr_data
);

    // Use different clk port
    // Use two ram_true_dual_port to have two read ports
    // The write logic is the same for two rams

    ram_true_dual_port #(
        .ADDR_WIDTH  (`GSH_PHT_ENT_SEL),
        .DATA_DEPTH  (`GSH_PHT_ENT_NUM),
        .DATA_WIDTH  (`GSH_PHT_DATA_WIDTH)
    ) u_pht_1 (
        .clk_1       (~clk),
        .i_addr_1    (i_rd_addr_1),
        .o_rd_data_1 (o_rd_data_1),
        .i_wr_en_1   (1'b0),
        .i_wr_data_1 (),
        .clk_2       (clk),
        .i_addr_2    (i_wr_addr),
        .o_rd_data_2 (),
        .i_wr_en_2   (i_wr_en),
        .i_wr_data_2 (i_wr_data)
    );

    ram_true_dual_port #(
        .ADDR_WIDTH  (`GSH_PHT_ENT_SEL),
        .DATA_DEPTH  (`GSH_PHT_ENT_NUM),
        .DATA_WIDTH  (`GSH_PHT_DATA_WIDTH)
    ) u_pht_2 (
        .clk_1       (~clk),
        .i_addr_1    (i_rd_addr_2),
        .o_rd_data_1 (o_rd_data_2),
        .i_wr_en_1   (1'b0),
        .i_wr_data_1 (),
        .clk_2       (clk),
        .i_addr_2    (i_wr_addr),
        .o_rd_data_2 (),
        .i_wr_en_2   (i_wr_en),
        .i_wr_data_2 (i_wr_data)
    );

endmodule

`default_nettype wire
