`default_nettype none
`include "constants.vh"

module alloc_issue_disorder #(
    parameter ENT_NUM = 2,
    parameter ENT_SEL = 1
)(
    input  wire [ENT_NUM-1:0]       i_busy_vec,
    input  wire [`DP_NUM_WIDTH-1:0] i_req_num,
    output wire                     o_allocable,
    output wire                     o_alloc_sel_vld_1,
    output wire                     o_alloc_sel_vld_2,
    output wire [ENT_SEL-1:0]       o_alloc_sel_1,
    output wire [ENT_SEL-1:0]       o_alloc_sel_2,
    input  wire [ENT_NUM-1:0]       i_vld_vec,
    output wire                     o_issue_sel_vld,
    output wire [ENT_SEL-1:0]       o_issue_sel
);

    alloc_unit #(
        .ENT_NUM     (ENT_NUM),
        .ENT_SEL     (ENT_SEL)
    ) u_alloc_unit (
        .i_busy_vec  (i_busy_vec),
        .i_req_num   (i_req_num),
        .o_allocable (o_allocable),
        .o_sel_vld_1 (o_alloc_sel_vld_1),
        .o_sel_vld_2 (o_alloc_sel_vld_2),
        .o_sel_1     (o_alloc_sel_1),
        .o_sel_2     (o_alloc_sel_2)
    );

    issue_unit #(
        .ENT_NUM   (ENT_NUM),
        .ENT_SEL   (ENT_SEL)
    ) u_issue_unit (
        .i_vld_vec (i_vld_vec),
        .o_sel_vld (o_issue_sel_vld),
        .o_sel     (o_issue_sel)
    );

endmodule

`default_nettype wire
