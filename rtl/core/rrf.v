`default_nettype none
`include "constants.vh"

module rrf (
    input  wire                           clk,
    input  wire                           rst_n,
    // Dp-stage read
    input  wire [`RRF_ENT_SEL-1:0]        i_dp_rd_addr_1,
    input  wire [`RRF_ENT_SEL-1:0]        i_dp_rd_addr_2,
    input  wire [`RRF_ENT_SEL-1:0]        i_dp_rd_addr_3,
    input  wire [`RRF_ENT_SEL-1:0]        i_dp_rd_addr_4,
    output wire                           o_dp_rd_vld_1,
    output wire                           o_dp_rd_vld_2,
    output wire                           o_dp_rd_vld_3,
    output wire                           o_dp_rd_vld_4,
    output wire [`RV32_DATA_WIDTH-1:0]    o_dp_rd_data_1,
    output wire [`RV32_DATA_WIDTH-1:0]    o_dp_rd_data_2,
    output wire [`RV32_DATA_WIDTH-1:0]    o_dp_rd_data_3,
    output wire [`RV32_DATA_WIDTH-1:0]    o_dp_rd_data_4,
    // Exfin-stage write
    input  wire [`RRF_ENT_SEL-1:0]        i_ex_alu_rrftag,
    input  wire                           i_exfin_alu,
    input  wire [`RV32_DATA_WIDTH-1:0]    i_exfin_alu_res,
    input  wire [`RRF_ENT_SEL-1:0]        i_ex_mul_rrftag,
    input  wire                           i_exfin_mul,
    input  wire [`RV32_DATA_WIDTH-1:0]    i_exfin_mul_res,
    input  wire [`RRF_ENT_SEL-1:0]        i_ex_ld_rrftag,
    input  wire                           i_exfin_ld,
    input  wire [`RV32_DATA_WIDTH-1:0]    i_exfin_ld_res,
    input  wire [`RRF_ENT_SEL-1:0]        i_ex_jal_jalr_rrftag,
    input  wire                           i_exfin_jal_jalr,
    input  wire [`RV32_DATA_WIDTH-1:0]    i_exfin_jal_jalr_res,
    // Com-stage read to arf
    input  wire                           i_com_vld_1,
    input  wire [`RRF_ENT_SEL-1:0]        i_com_ptr_1,
    output wire [`RV32_DATA_WIDTH-1:0]    o_com_rd_wr_data_1,
    input  wire                           i_com_vld_2,
    input  wire [`RRF_ENT_SEL-1:0]        i_com_ptr_2,
    output wire [`RV32_DATA_WIDTH-1:0]    o_com_rd_wr_data_2
);

    // Entries in rrf
    reg [`RRF_ENT_NUM-1:0]     vld;
    reg [`RV32_DATA_WIDTH-1:0] data [0:`RRF_ENT_NUM-1];

    assign o_dp_rd_vld_1  = vld[i_dp_rd_addr_1];
    assign o_dp_rd_vld_2  = vld[i_dp_rd_addr_2];
    assign o_dp_rd_vld_3  = vld[i_dp_rd_addr_3];
    assign o_dp_rd_vld_4  = vld[i_dp_rd_addr_4];
    assign o_dp_rd_data_1 = data[i_dp_rd_addr_1];
    assign o_dp_rd_data_2 = data[i_dp_rd_addr_2];
    assign o_dp_rd_data_3 = data[i_dp_rd_addr_3];
    assign o_dp_rd_data_4 = data[i_dp_rd_addr_4];

    // vld
    // Set when exfinish, clr when commit
    always @(posedge clk) begin
        if (!rst_n) begin
            vld <= 'd0;
        end else begin
            if (i_exfin_alu) begin
                vld[i_ex_alu_rrftag] <= 'd1;
            end
            if (i_exfin_mul) begin
                vld[i_ex_mul_rrftag] <= 'd1;
            end
            if (i_exfin_ld) begin
                vld[i_ex_ld_rrftag] <= 'd1;
            end
            if (i_exfin_jal_jalr) begin
                vld[i_ex_jal_jalr_rrftag] <= 'd1;
            end
            if (i_com_vld_1) begin
                vld[i_com_ptr_1] <= 'd0;
            end
            if (i_com_vld_2) begin
                vld[i_com_ptr_2] <= 'd0;
            end
        end
    end

    // data
    // renew when exfinish
    always @(posedge clk) begin
        if (i_exfin_alu) begin
            data[i_ex_alu_rrftag] <= i_exfin_alu_res;
        end
        if (i_exfin_mul) begin
            data[i_ex_mul_rrftag] <= i_exfin_mul_res;
        end
        if (i_exfin_ld) begin
            data[i_ex_ld_rrftag] <= i_exfin_ld_res;
        end
        if (i_exfin_jal_jalr) begin
            data[i_ex_jal_jalr_rrftag] <= i_exfin_jal_jalr_res;
        end
    end

    assign o_com_rd_wr_data_1 = data[i_com_ptr_1];
    assign o_com_rd_wr_data_2 = data[i_com_ptr_2];

endmodule

`default_nettype wire
