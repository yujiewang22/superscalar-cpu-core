`default_nettype none
`include "constants.vh"

module regfile (
    input  wire                        clk,
    input  wire [`RV32_ARF_SEL-1:0]    i_rd_addr_1,
    input  wire [`RV32_ARF_SEL-1:0]    i_rd_addr_2,
    input  wire [`RV32_ARF_SEL-1:0]    i_rd_addr_3,
    input  wire [`RV32_ARF_SEL-1:0]    i_rd_addr_4,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data_1,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data_2,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data_3,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data_4,
    input  wire                        i_wr_en_1,
    input  wire [`RV32_ARF_SEL-1:0]    i_wr_addr_1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_wr_data_1,
    input  wire                        i_wr_en_2,
    input  wire [`RV32_ARF_SEL-1:0]    i_wr_addr_2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_wr_data_2
);

    reg [`RV32_DATA_WIDTH-1:0] mem [0:`RV32_ARF_SEL-1];

    // Four read ports
    assign o_rd_data_1 = mem[i_rd_addr_1];
    assign o_rd_data_2 = mem[i_rd_addr_2];
    assign o_rd_data_3 = mem[i_rd_addr_3];
    assign o_rd_data_4 = mem[i_rd_addr_4];  

    // Two write ports
    // If both write ports write to the same address, the second write will overwrite the first write
    always @(posedge clk) begin
        if (i_wr_en_1) begin
            mem[i_wr_addr_1] <= i_wr_data_1;
        end
        if (i_wr_en_2) begin
            mem[i_wr_addr_2] <= i_wr_data_2;
        end
    end

endmodule

`default_nettype wire
