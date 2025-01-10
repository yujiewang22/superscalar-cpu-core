`default_nettype none
`include "constants.vh"

module alu (
    input  wire [`ALU_OP_SEL-1:0]      i_op_sel,        
    input  wire [`RV32_DATA_WIDTH-1:0] i_src1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_src2,
    output reg  [`RV32_DATA_WIDTH-1:0] o_res
);

    wire [`RV32_SHAMT_WIDTH-1:0] shamt;

    assign shamt = i_src2[`RV32_SHAMT_WIDTH-1:0];

    always @(*) begin
        o_res = 'd0;
        case (i_op_sel)
            `ALU_OP_ADD:  o_res = i_src1 + i_src2;
            `ALU_OP_SUB:  o_res = i_src1 - i_src2;
            `ALU_OP_AND:  o_res = i_src1 & i_src2;
            `ALU_OP_OR:   o_res = i_src1 | i_src2;
            `ALU_OP_XOR:  o_res = i_src1 ^ i_src2;
            `ALU_OP_SLL:  o_res = i_src1 << shamt;
            `ALU_OP_SRL:  o_res = i_src1 >> shamt;
            `ALU_OP_SRA:  o_res = $signed(i_src1) >>> shamt;
            `ALU_OP_SEQ:  o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {i_src1 == i_src2}};
            `ALU_OP_SNE:  o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {i_src1 != i_src2}};
            `ALU_OP_SLT:  o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {$signed(i_src1) < $signed(i_src2)}};
            `ALU_OP_SLTU: o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {i_src1 < i_src2}};
            `ALU_OP_SGE:  o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {$signed(i_src1) >= $signed(i_src2)}};
            `ALU_OP_SGEU: o_res = {{{`RV32_DATA_WIDTH-1}{1'b0}}, {i_src1 >= i_src2}};
        endcase
    end

endmodule

`default_nettype wire
