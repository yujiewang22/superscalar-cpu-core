`default_nettype none
`include "constants.vh"

module br (
    input  wire                        i_is_jal,
    input  wire                        i_is_jalr,
    input  wire [`ALU_OP_SEL-1:0]      i_alu_op_sel,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pred_jmpaddr,
    output wire [`RV32_PC_WIDTH-1:0]   o_jmpaddr,
    output wire                        o_jmpcond,
    output wire                        o_pred_jmpaddr_suc
);

    wire [`RV32_DATA_WIDTH-1:0] comp_res;
    wire [`RV32_PC_WIDTH-1:0]   jmpaddr;
        
    assign jmpaddr   = (i_is_jalr ? i_rs1 : i_pc) + i_imm;
    assign o_jmpcond = i_is_jal || i_is_jalr || comp_res[0];
    assign o_jmpaddr = o_jmpcond ? jmpaddr : (i_pc + 'd4);

    alu u_alu (
        .i_op_sel (i_alu_op_sel),
        .i_src1   (i_rs1),
        .i_src2   (i_rs2),
        .o_res    (comp_res)
    );

    assign o_pred_jmpaddr_suc = (i_pred_jmpaddr == o_jmpaddr);

endmodule

`default_nettype wire
