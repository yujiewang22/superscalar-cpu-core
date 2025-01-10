`default_nettype none
`include "constants.vh"

module src1_sel_unit (
    input  wire [`ALU_SRC1_SEL-1:0]    i_sel,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    output reg  [`RV32_DATA_WIDTH-1:0] o_src
);

    always @(*) begin
        o_src = 'd0;
        case (i_sel)
            `ALU_SRC1_RS1: o_src = i_rs1;
            `ALU_SRC1_PC: o_src = i_pc;
        endcase
    end

endmodule

module src2_sel_unit (
    input  wire [`ALU_SRC2_SEL-1:0]    i_sel,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    output reg  [`RV32_DATA_WIDTH-1:0] o_src
);

    always @(*) begin
        o_src = 'd0;
        case (i_sel)
            `ALU_SRC2_RS2: o_src = i_rs2;
            `ALU_SRC2_IMM: o_src = i_imm;
        endcase
    end
    
endmodule

`default_nettype wire
