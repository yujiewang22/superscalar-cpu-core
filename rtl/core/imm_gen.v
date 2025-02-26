`default_nettype none
`include "constants.vh"

module imm_gen (
    input  wire [`RV32_INST_WIDTH-1:0] i_inst,
    input  wire [`IMM_TYPE_SEL-1:0]    i_imm_type_sel,
    output reg  [`RV32_DATA_WIDTH-1:0] o_imm
);

    wire [`RV32_DATA_WIDTH-1:0] imm_i;
    wire [`RV32_DATA_WIDTH-1:0] imm_s;
    wire [`RV32_DATA_WIDTH-1:0] imm_b;
    wire [`RV32_DATA_WIDTH-1:0] imm_j;
    wire [`RV32_DATA_WIDTH-1:0] imm_u;

    assign imm_i = {{20{i_inst[31]}}, i_inst[31:20]};
    assign imm_s = {{20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]};
    assign imm_b = {{20{i_inst[31]}}, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    assign imm_j = {{12{i_inst[31]}}, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21]};
    assign imm_u = {{12{i_inst[31]}}, i_inst[31:12]};

    always @(*) begin
        o_imm = 'd0;
        case (i_imm_type_sel)
            `IMM_TYPE_I: o_imm = imm_i;
            `IMM_TYPE_S: o_imm = imm_s;
            `IMM_TYPE_B: o_imm = imm_b;
            `IMM_TYPE_J: o_imm = imm_j;
            `IMM_TYPE_U: o_imm = imm_u;
        endcase
    end

endmodule

`default_nettype wire
