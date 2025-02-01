`default_nettype none
`include "constants.vh"

module sptag_gen (
    input  wire                      clk,
    input  wire                      rst_n,
    output wire                      o_allocable,
    input  wire                      i_stall,
    input  wire                      i_is_br_1,
    input  wire                      i_is_br_2,
    output wire                      o_inst_sp_1,
    output wire                      o_inst_sp_2,
    output wire [`SPTAG_WIDTH-1:0]   o_inst_sptag_1,
    output wire [`SPTAG_WIDTH-1:0]   o_inst_sptag_2,
    input  wire                      i_prsuc,
    input  wire [`RV32_PC_WIDTH-1:0] i_prmiss,
    input  wire [`SPTAG_WIDTH-1:0]   i_sptag_fix
);

    reg [`SPDEPTH_WIDTH-1:0] spdepth;
    reg [`SPTAG_WIDTH-1:0]   sptag;

    assign o_allocable = (spdepth + i_is_br_1 + i_is_br_2 - i_prsuc < `SPTAG_WIDTH) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (!rst_n) begin
            spdepth     <= 'd0;
            sptag       <= 'd1;
        end else begin
            if (i_prmiss) begin
                spdepth <= 'd0;
                sptag   <= i_sptag_fix;
            end else if (i_stall) begin
                spdepth <= spdepth + i_is_br_1 + i_is_br_2 - i_prsuc;
                sptag   <= o_inst_sptag_2;
            end else begin
                spdepth <= spdepth - i_prsuc;
            end
        end
    end

    assign o_inst_sp_1    = (spdepth == 'd0) ? 1'b0 : 1'b1;
    assign o_inst_sp_2    = ((spdepth == 'd0) && (!i_is_br_1)) ? 1'b0 : 1'b1;
    assign o_inst_sptag_1 = i_is_br_1 ? {sptag[`SPTAG_WIDTH-2:1], sptag[`SPTAG_WIDTH-1]} : sptag;
    assign o_inst_sptag_2 = i_is_br_2 ? {o_inst_sptag_1[`SPTAG_WIDTH-2:1], o_inst_sptag_1[`SPTAG_WIDTH-1]} : o_inst_sptag_1;

endmodule

`default_nettype wire
