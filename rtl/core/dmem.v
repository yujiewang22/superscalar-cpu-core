`default_nettype none
`include "constants.vh"

module dmem (
    input  wire                        clk,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output reg  [`DMEM_DATA_WIDTH-1:0] o_rd_data,
    input  wire                        i_wr_en,
    input  wire [`RV32_DATA_WIDTH-1:0] i_wr_data
);

    reg [`DMEM_DATA_WIDTH-1:0] mem [0:`DMEM_DATA_DEPTH-1];

    always @(posedge clk) begin
        // No need for reset
        o_rd_data <= mem[i_addr[`DMEM_ADDR_WIDTH-1:0]];
        if (i_wr_en) begin
            mem[i_addr[`DMEM_ADDR_WIDTH-1:0]] <= i_wr_data;
        end
    end

endmodule

`default_nettype wire
