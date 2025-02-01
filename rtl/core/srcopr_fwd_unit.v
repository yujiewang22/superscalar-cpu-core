`default_nettype none
`include "constants.vh"

module srcopr_fwd_unit (
    input  wire                        i_srcopr_vld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_srcopr,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_alu_rrftag,
    input  wire                        i_exfin_alu,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_alu_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_mul_rrftag,
    input  wire                        i_exfin_mul,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_mul_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_ld_rrftag,
    input  wire                        i_exfin_ld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_ld_res,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_jal_jalr_rrftag,
    input  wire                        i_exfin_jal_jalr,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_jal_jalr_res,
    output wire                        o_srcopr_fwd_vld,
    output wire [`RV32_DATA_WIDTH-1:0] o_srcopr_fwd
);

    wire srcopr_fwd_alu_vld;
    wire srcopr_fwd_mul_vld;
    wire srcopr_fwd_ld_vld;
    wire srcopr_fwd_jal_jalr_vld;

    assign srcopr_fwd_alu_vld      = i_exfin_alu && (i_srcopr[`RRF_ENT_SEL-1:0] == i_ex_alu_rrftag);
    assign srcopr_fwd_mul_vld      = i_exfin_mul && (i_srcopr[`RRF_ENT_SEL-1:0] == i_ex_mul_rrftag);
    assign srcopr_fwd_ld_vld       = i_exfin_ld  && (i_srcopr[`RRF_ENT_SEL-1:0] == i_ex_ld_rrftag);   
    assign srcopr_fwd_jal_jalr_vld = i_exfin_jal_jalr && (i_srcopr[`RRF_ENT_SEL-1:0] == i_ex_jal_jalr_rrftag);


    // Matain unchange when vld
    // Change when !vld only once 

    assign o_srcopr_fwd_vld = i_srcopr_vld || srcopr_fwd_alu_vld || srcopr_fwd_mul_vld || srcopr_fwd_ld_vld || srcopr_fwd_jal_jalr_vld;

    assign o_srcopr_fwd = i_srcopr_vld            ? i_srcopr        : 
                          srcopr_fwd_alu_vld      ? i_exfin_alu_res :
                          srcopr_fwd_mul_vld      ? i_exfin_mul_res :
                          srcopr_fwd_ld_vld       ? i_exfin_ld_res  :    
                          srcopr_fwd_jal_jalr_vld ? i_exfin_jal_jalr_res :                    
                          i_srcopr;

endmodule

`default_nettype wire
