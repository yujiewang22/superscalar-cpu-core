`default_nettype none
`include "constants.vh"

// Issue only one inst per cycle, rather than two insts
module rs_issue_unit #(
    parameter RS_ENT_NUM = 2,
    parameter RS_ENT_SEL = 1
)(
    input  wire [RS_ENT_NUM-1:0] i_vld_vec,
    output wire                  o_sel_vld,
    output wire [RS_ENT_SEL-1:0] o_sel
);

    req_arbiter #(
        .REQ_NUM(RS_ENT_NUM),
        .ACK_SEL(RS_ENT_SEL)
    ) u_req_arbiter (
        .i_req(i_vld_vec),
        .o_ack_vld(o_sel_vld),
        .o_ack(o_sel)
    );

endmodule

`default_nettype wire
