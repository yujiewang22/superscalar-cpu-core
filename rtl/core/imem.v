`default_nettype none
`include "constants.vh"

module imem (
    input  wire                        clk,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output wire [`IMEM_DATA_WIDTH-1:0] o_rd_data
);

    ram_1r1w_1port #(
        .ADDR_WIDTH (`IMEM_ADDR_WIDTH),
        .DATA_DEPTH (`IMEM_DATA_DEPTH),
        .DATA_WIDTH (`IMEM_DATA_WIDTH)
    ) u_imem (
        .clk        (clk),
        .i_addr     (i_addr[`IMEM_ADDR_WIDTH-1:0]),
        .o_rd_data  (o_rd_data),
        .i_wr_en    (1'b0),
        .i_wr_data  ()
    );

endmodule

`default_nettype wire
