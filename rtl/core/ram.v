`default_nettype none
`include "constants.vh"

module ram_1r1w_1port #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output reg  [DATA_WIDTH-1:0] o_rd_data,
    input  wire                  i_wr_en,
    input  wire [DATA_WIDTH-1:0] i_wr_data
);

    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];

    always @(posedge clk) begin
        // No need to reset the memory
        o_rd_data <= mem[i_addr];
        if (i_wr_en) begin
            mem[i_addr] <= i_wr_data;
        end
    end

endmodule

module ram_1r1w_2port #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] i_rd_addr,
    output reg  [DATA_WIDTH-1:0] o_rd_data,
    input  wire                  i_wr_en,
    input  wire [ADDR_WIDTH-1:0] i_wr_addr,
    input  wire [DATA_WIDTH-1:0] i_wr_data
);

    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];

    always @(posedge clk) begin
        // No need to reset the memory
        o_rd_data <= mem[i_rd_addr];
        if (i_wr_en) begin
            mem[i_wr_addr] <= i_wr_data;
        end
    end

endmodule

module ram_true_dual_port #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk_1,
    input  wire [ADDR_WIDTH-1:0] i_addr_1,
    output reg  [DATA_WIDTH-1:0] o_rd_data_1,
    input  wire                  i_wr_en_1,
    input  wire [DATA_WIDTH-1:0] i_wr_data_1,
    input  wire                  clk_2,
    input  wire [ADDR_WIDTH-1:0] i_addr_2,
    output reg  [DATA_WIDTH-1:0] o_rd_data_2,
    input  wire                  i_wr_en_2,
    input  wire [DATA_WIDTH-1:0] i_wr_data_2
);

    reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];

    always @(posedge clk_1) begin
        // No need to reset the memory
        o_rd_data_1 <= mem[i_addr_1];
        if (i_wr_en_1) begin
            mem[i_addr_1] <= i_wr_data_1;
        end
    end

    always @(posedge clk_2) begin
        // No need to reset the memory
        o_rd_data_2 <= mem[i_addr_2];
        if (i_wr_en_2) begin
            mem[i_addr_2] <= i_wr_data_2;
        end
    end

endmodule

`default_nettype wire
