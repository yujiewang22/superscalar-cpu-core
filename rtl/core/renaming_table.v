`default_nettype none
`include "constants.vh"

module renaming_table (
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire [`RV32_ARF_SEL-1:0] i_rd_addr_1,
    input  wire [`RV32_ARF_SEL-1:0] i_rd_addr_2,
    input  wire [`RV32_ARF_SEL-1:0] i_rd_addr_3,
    input  wire [`RV32_ARF_SEL-1:0] i_rd_addr_4,
    output wire                     o_rd_busy_1,
    output wire                     o_rd_busy_2,
    output wire                     o_rd_busy_3,
    output wire                     o_rd_busy_4,
    output wire [`RRF_ENT_SEL-1:0]  o_rd_rrftag_1,
    output wire [`RRF_ENT_SEL-1:0]  o_rd_rrftag_2,
    output wire [`RRF_ENT_SEL-1:0]  o_rd_rrftag_3,
    output wire [`RRF_ENT_SEL-1:0]  o_rd_rrftag_4,

    input  wire                     i_dp_vld_1,
    input  wire [`RRF_ENT_SEL-1:0]  i_dp_ptr_1,
    input  wire                     i_dp_rd_wr_en_1,
    input  wire [`RV32_ARF_SEL-1:0] i_dp_rd_wr_addr_1,

    input  wire                     i_dp_vld_2,
    input  wire [`RRF_ENT_SEL-1:0]  i_dp_ptr_2,
    input  wire                     i_dp_rd_wr_en_2,
    input  wire [`RV32_ARF_SEL-1:0] i_dp_rd_wr_addr_2,

    input  wire                     i_com_vld_1,
    input  wire [`RV32_ARF_SEL-1:0] i_com_rd_wr_addr_1,

    input  wire                     i_com_vld_2,
    input  wire [`RV32_ARF_SEL-1:0] i_com_rd_wr_addr_2
);

    reg [`RV32_ARF_SEL-1:0] busy;
    reg [`RRF_ENT_SEL-1:0]  rrftag [0:`RV32_ARF_SEL-1];

    // Busy sets when dispatch, clears when commit
    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 'd0;
        end else begin
            if (i_dp_vld_1 && i_dp_rd_wr_en_1) begin
                busy[i_dp_rd_wr_addr_1] <= 1'b1;
            end
            if (i_dp_vld_2 && i_dp_rd_wr_en_2) begin
                busy[i_dp_rd_wr_addr_2] <= 1'b1;
            end
            // No need to use rd_wr_en signal here
            if (i_com_vld_1) begin
                busy[i_com_rd_wr_addr_1] <= 1'b0;
            end
            if (i_com_vld_2) begin
                busy[i_com_rd_wr_addr_2] <= 1'b0;
            end
        end
    end

    // Rrftag updates when dispatch
    always @(posedge clk) begin
        if (i_dp_vld_1) begin
            rrftag[i_dp_rd_wr_addr_1] <= i_dp_ptr_1;
        end
        if (i_dp_vld_2) begin
            rrftag[i_dp_rd_wr_addr_2] <= i_dp_ptr_2;
        end
    end

    assign o_rd_busy_1   = busy[i_rd_addr_1];
    assign o_rd_busy_2   = busy[i_rd_addr_2];
    assign o_rd_busy_3   = busy[i_rd_addr_3];
    assign o_rd_busy_4   = busy[i_rd_addr_4];
    assign o_rd_rrftag_1 = rrftag[i_rd_addr_1];
    assign o_rd_rrftag_2 = rrftag[i_rd_addr_2];
    assign o_rd_rrftag_3 = rrftag[i_rd_addr_3];
    assign o_rd_rrftag_4 = rrftag[i_rd_addr_4];

endmodule

`default_nettype wire
