`include "constants.vh"

`default_nettype none

module top (
    input wire clk,
    input wire rst_n
);

    wire [`RV32_ADDR_WIDTH-1:0] imem_addr;
    wire [`IMEM_DATA_WIDTH-1:0] imem_rd_data;
    wire [`RV32_ADDR_WIDTH-1:0] dmem_addr;
    wire [`DMEM_DATA_WIDTH-1:0] dmem_rd_data;
    wire                        dmem_wr_en;
    wire [`RV32_DATA_WIDTH-1:0] dmem_wr_data;

    pipeline u_pipeline (
        .clk            (clk),
        .rst_n          (rst_n),
        .o_imem_addr    (imem_addr),
        .i_imem_rd_data (imem_rd_data),
        .o_dmem_addr    (dmem_addr),
        .i_dmem_rd_data (dmem_rd_data),
        .o_dmem_wr_en   (dmem_wr_en),
        .o_dmem_wr_data (dmem_wr_data)
    );

    imem u_imem (
        .clk       (~clk),
        .i_addr    ({4'd0, imem_addr[`RV32_ADDR_WIDTH-1:4]}),
        .o_rd_data (imem_rd_data)
    );

    dmem u_dmem (
        .clk       (clk),
        .i_addr    ({2'd0, dmem_addr[`RV32_ADDR_WIDTH-1:2]}),
        .o_rd_data (dmem_rd_data),
        .i_wr_en   (dmem_wr_en),
        .i_wr_data (dmem_wr_data)
    );

endmodule

`default_nettype wire
