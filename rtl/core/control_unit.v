`default_nettype none
`include "constants.vh"

module control_unit (
    input  wire i_dp_freelist_allocable,
    input  wire i_dp_rs_alu_allocable,
    input  wire i_dp_rs_mul_allocable,
    input  wire i_dp_rs_ldst_allocable,
    input  wire i_dp_rs_br_allocable,
    input  wire i_exfin_prmiss,
    output wire o_if_kill, 
    output wire o_id_kill,
    output wire o_dp_kill,
    output wire o_if_stall,
    output wire o_id_stall,
    output wire o_dp_stall,
    input  wire i_is_rs_alu_sel_vld,
    input  wire i_is_rs_mul_sel_vld,
    input  wire i_is_rs_ldst_sel_vld,
    input  wire i_is_rs_br_sel_vld,
    input  wire i_ex_alu_accessable,
    input  wire i_ex_mul_accessable,
    input  wire i_ex_ldst_accessable,
    input  wire i_ex_br_accessable,
    output wire o_is_rs_alu_vld,
    output wire o_is_rs_mul_vld,
    output wire o_is_rs_ldst_vld,
    output wire o_is_rs_br_vld
);

    // Flush the pipeline
    assign o_if_kill  = i_exfin_prmiss;
    assign o_id_kill  = i_exfin_prmiss || (o_if_stall && (!o_id_stall));
    assign o_dp_kill  = i_exfin_prmiss || (o_id_stall && (!o_dp_stall));

    // Stall the pipeline
    assign o_if_stall = o_id_stall;
    assign o_id_stall = o_dp_stall;
    assign o_dp_stall = !(i_dp_freelist_allocable && i_dp_rs_alu_allocable && i_dp_rs_mul_allocable && i_dp_rs_ldst_allocable && i_dp_rs_br_allocable);

    // Control the issue-stage
    assign o_is_rs_alu_vld  = i_is_rs_alu_sel_vld  && i_ex_alu_accessable;
    assign o_is_rs_mul_vld  = i_is_rs_mul_sel_vld  && i_ex_mul_accessable;
    assign o_is_rs_ldst_vld = i_is_rs_ldst_sel_vld && i_ex_ldst_accessable;
    assign o_is_rs_br_vld   = i_is_rs_br_sel_vld   && i_ex_br_accessable;

endmodule

`default_nettype wire
