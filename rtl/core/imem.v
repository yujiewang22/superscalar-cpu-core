`default_nettype none
`include "constants.vh"

module imem (
    input  wire                        clk,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output reg  [`IMEM_DATA_WIDTH-1:0] o_rd_data
);

    reg [`IMEM_DATA_WIDTH-1:0] mem [0:`IMEM_DATA_DEPTH-1];

    always @(posedge clk) begin
        // No need for reset
        o_rd_data <= mem[i_addr[`IMEM_ADDR_WIDTH-1:0]];
    end

endmodule

`default_nettype wire
