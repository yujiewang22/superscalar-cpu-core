`default_nettype none
`include "constants.vh"

module rs_alloc_unit #(
    parameter RS_ENT_NUM = 2,
    parameter RS_ENT_SEL = 1
)(
    input  wire [RS_ENT_NUM-1:0]    i_busy_vec,
    input  wire [`DP_NUM_WIDTH-1:0] i_req_num,
    output wire                     o_allocable,
    output wire                     o_sel_vld_1,
    output wire                     o_sel_vld_2,
    output wire [RS_ENT_SEL-1:0]    o_sel_1,
    output wire [RS_ENT_SEL-1:0]    o_sel_2
);

    wire [RS_ENT_NUM-1:0] free_vec;
    wire [RS_ENT_NUM-1:0] free_vec_masked;

    // Free signal is inversed from busy signal
    assign free_vec = ~i_busy_vec;

    req_arbiter #(
        .REQ_NUM(RS_ENT_NUM),
        .ACK_SEL(RS_ENT_SEL)
    ) u_req_arbiter_1 (
        .i_req(free_vec),
        .o_ack_vld(o_sel_vld_1),
        .o_ack(o_sel_1)
    );

    req_mask #(
        .REQ_NUM(RS_ENT_NUM),
        .ACK_SEL(RS_ENT_SEL)
    ) u_req_mask (
        .i_mask(o_sel_1),
        .i_req(free_vec),
        .o_req_masked(free_vec_masked)
    );

    req_arbiter #(
        .REQ_NUM(RS_ENT_NUM),
        .ACK_SEL(RS_ENT_SEL)
    ) u_req_arbiter_2 (
        .i_req(free_vec_masked),
        .o_ack_vld(o_sel_vld_2),
        .o_ack(o_sel_2)
    );

    // Allocable signal used to stall the pipeline outside this module
    assign o_allocable = (i_req_num <= ({1'b0, o_sel_vld_1} + {1'b0, o_sel_vld_2})) ? 1'b1 : 1'b0;

endmodule

`default_nettype wire
