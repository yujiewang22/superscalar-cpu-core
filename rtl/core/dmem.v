`default_nettype none
`include "constants.vh"

module dmem (
    input  wire                        clk,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output wire [`DMEM_DATA_WIDTH-1:0] o_rd_data,
    input  wire                        i_wr_en,
    input  wire [`RV32_DATA_WIDTH-1:0] i_wr_data
);

    ram_1r1w_1port #(
        .ADDR_WIDTH (`DMEM_ADDR_WIDTH),
        .DATA_DEPTH (`DMEM_DATA_DEPTH),
        .DATA_WIDTH (`DMEM_DATA_WIDTH)
    ) u_dmem (
        .clk        (clk),
        .i_addr     (i_addr[`DMEM_ADDR_WIDTH-1:0]),
        .o_rd_data  (o_rd_data),
        .i_wr_en    (i_wr_en),
        .i_wr_data  (i_wr_data)
    );

endmodule

`default_nettype wire
