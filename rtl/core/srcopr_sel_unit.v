`default_nettype none
`include "constants.vh"

module srcopr_sel_unit (
    // Oher signals for sel
    input  wire                        i_arf_rd_addr_eq_0,
    input  wire                        i_arf_rd_addr_eq_rd1,
    input  wire [`RRF_ENT_SEL-1:0]     i_rd1_renamed,
    // Five read signals for sel
    input  wire                        i_arf_busy,
    input  wire [`RRF_ENT_SEL-1:0]     i_arf_rrftag,
    input  wire [`RV32_DATA_WIDTH-1:0] i_arf_data,
    input  wire                        i_rrf_vld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rrf_data,
    // Srcopr can also be rrftag, after zero-extend
    output wire                        o_srcopr_vld,
    output wire [`RV32_DATA_WIDTH-1:0] o_srcopr
);

    wire [`RV32_DATA_WIDTH-1:0] rd1_renamed_zext;
    wire [`RV32_DATA_WIDTH-1:0] rrftag_zext;

    assign rd1_renamed_zext = {{{`RV32_DATA_WIDTH-`RRF_ENT_SEL}{1'b0}}, i_rd1_renamed};
    assign rrftag_zext = {{{`RV32_DATA_WIDTH-`RRF_ENT_SEL}{1'b0}}, i_arf_rrftag};

    assign o_srcopr_vld = i_arf_rd_addr_eq_0 || ((!i_arf_rd_addr_eq_rd1) && ((!i_arf_busy) || i_rrf_vld));

    assign o_srcopr = i_arf_rd_addr_eq_0   ? 'd0 :
                      i_arf_rd_addr_eq_rd1 ? rd1_renamed_zext :
                      !i_arf_busy          ? i_arf_data :
                      i_rrf_vld            ? i_rrf_data :
                      rrftag_zext;    
endmodule

`default_nettype wire
