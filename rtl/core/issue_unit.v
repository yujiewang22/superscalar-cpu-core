`default_nettype none
`include "constants.vh"

// Issue only one inst per cycle, rather than two insts
module issue_unit #(
    parameter ENT_NUM = 2,
    parameter ENT_SEL = 1
)(
    input  wire [ENT_NUM-1:0] i_vld_vec,
    output wire               o_sel_vld,
    output wire [ENT_SEL-1:0] o_sel
);

    req_arbiter #(
        .REQ_NUM (ENT_NUM),
        .ACK_SEL (ENT_SEL)
    ) u_req_arbiter (
        .i_req     (i_vld_vec),
        .o_ack_vld (o_sel_vld),
        .o_ack     (o_sel)
    );

endmodule

`default_nettype wire
