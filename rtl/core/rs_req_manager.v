`default_nettype none
`include "constants.vh"

module rs_req_manager (
    input  wire                     i_rs_sel_vld_1,
    input  wire                     i_rs_sel_vld_2,
    input  wire [`RS_SEL-1:0]       i_rs_sel_1,
    input  wire [`RS_SEL-1:0]       i_rs_sel_2,
    output wire                     o_rs_alu_req_1,
    output wire                     o_rs_alu_req_2,
    output wire [`DP_NUM_WIDTH-1:0] o_rs_alu_req_num,
    output wire                     o_rs_mul_req_1,
    output wire                     o_rs_mul_req_2,
    output wire [`DP_NUM_WIDTH-1:0] o_rs_mul_req_num,
    output wire                     o_rs_ldst_req_1,
    output wire                     o_rs_ldst_req_2,
    output wire [`DP_NUM_WIDTH-1:0] o_rs_ldst_req_num,
    output wire                     o_rs_br_req_1,
    output wire                     o_rs_br_req_2,
    output wire [`DP_NUM_WIDTH-1:0] o_rs_br_req_num
);

    assign o_rs_alu_req_1    = (i_rs_sel_vld_1 && (i_rs_sel_1 == `RS_ALU)) ? 1'b1 : 1'b0;
    assign o_rs_alu_req_2    = (i_rs_sel_vld_2 && (i_rs_sel_2 == `RS_ALU)) ? 1'b1 : 1'b0;
    assign o_rs_alu_req_num  = {1'b0, o_rs_alu_req_1} + {1'b0, o_rs_alu_req_2};

    assign o_rs_mul_req_1    = (i_rs_sel_vld_1 && (i_rs_sel_1 == `RS_MUL)) ? 1'b1 : 1'b0;
    assign o_rs_mul_req_2    = (i_rs_sel_vld_2 && (i_rs_sel_2 == `RS_MUL)) ? 1'b1 : 1'b0;
    assign o_rs_mul_req_num  = {1'b0, o_rs_mul_req_1} + {1'b0, o_rs_mul_req_2};

    assign o_rs_ldst_req_1   = (i_rs_sel_vld_1 && (i_rs_sel_1 == `RS_LDST)) ? 1'b1 : 1'b0;
    assign o_rs_ldst_req_2   = (i_rs_sel_vld_2 && (i_rs_sel_2 == `RS_LDST)) ? 1'b1 : 1'b0;
    assign o_rs_ldst_req_num = {1'b0, o_rs_ldst_req_1} + {1'b0, o_rs_ldst_req_2};
    
    assign o_rs_br_req_1     = (i_rs_sel_vld_1 && (i_rs_sel_1 == `RS_BR)) ? 1'b1 : 1'b0;
    assign o_rs_br_req_2     = (i_rs_sel_vld_2 && (i_rs_sel_2 == `RS_BR)) ? 1'b1 : 1'b0;
    assign o_rs_br_req_num   = {1'b0, o_rs_br_req_1} + {1'b0, o_rs_br_req_2};

endmodule

`default_nettype wire
