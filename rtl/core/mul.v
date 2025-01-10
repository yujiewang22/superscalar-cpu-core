`default_nettype none
`include "constants.vh"

module mul (
    input  wire                               i_signed1,
    input  wire                               i_signed2,
    input  wire                               i_sel_high,
    input  wire signed [`RV32_DATA_WIDTH-1:0] i_src1,
    input  wire signed [`RV32_DATA_WIDTH-1:0] i_src2,
    output wire [`RV32_DATA_WIDTH-1:0]        o_res
);

    wire signed [`RV32_DATA_WIDTH:0]     src1_unsigned;
    wire signed [`RV32_DATA_WIDTH:0]     src2_unsigned;

    wire signed [`RV32_DATA_WIDTH*2-1:0] res_uu;
    wire signed [`RV32_DATA_WIDTH*2-1:0] res_us;
    wire signed [`RV32_DATA_WIDTH*2-1:0] res_su; 
    wire signed [`RV32_DATA_WIDTH*2-1:0] res_ss;

    reg  signed [`RV32_DATA_WIDTH*2-1:0] res;

    // Addional zero as unsigned
    assign src1_unsigned = {1'b0, i_src1};
    assign src2_unsigned = {1'b0, i_src2};

    // Truncation
    assign res_uu = src1_unsigned * src2_unsigned;
    assign res_us = src1_unsigned * i_src2;
    assign res_su = i_src1 * src2_unsigned; 
    assign res_ss = i_src1 * i_src2;

    always @(*) begin
        res = 'd0;
        case ({i_signed1, i_signed2})
            2'b00: res = res_uu;
            2'b01: res = res_us;
            2'b10: res = res_su;
            2'b11: res = res_ss;
        endcase
    end

    assign o_res = i_sel_high ? res[`RV32_DATA_WIDTH+:`RV32_DATA_WIDTH] : res[0+:`RV32_DATA_WIDTH];

endmodule

`default_nettype wire
