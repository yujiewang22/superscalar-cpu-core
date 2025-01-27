`default_nettype none
`include "constants.vh"

module exunit_br (
    input  wire                        clk,
    input  wire                        rst_n,
    output wire                        o_accessable,  
    input  wire                        i_is_vld,
    input  wire                        i_is_jal,
    input  wire                        i_is_jalr,
    input  wire [`ALU_OP_SEL-1:0]      i_alu_op,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pred_jmpaddr,
    output wire                        o_exfin,
    output wire [`RV32_PC_WIDTH-1:0]   o_exfin_jmpaddr,
    output wire                        o_exfin_jmpcond,
    output wire                        o_exfin_predsuc
);

    reg  busy;

    assign o_accessable = 1'b1;
    
    // i_is_vld controls the busy signal one cycle ahead
    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end else begin
            busy <= i_is_vld;
        end
    end

    br u_br (
        .i_is_jal       (i_is_jal),
        .i_is_jalr      (i_is_jalr),
        .i_alu_op       (i_alu_op),
        .i_rs1          (i_rs1),
        .i_rs2          (i_rs2),
        .i_pc           (i_pc),
        .i_imm          (i_imm),
        .i_pred_jmpaddr (i_pred_jmpaddr),
        .o_jmpaddr      (o_exfin_jmpaddr),
        .o_jmpcond      (o_exfin_jmpcond),
        .o_predsuc      (o_exfin_predsuc)
    );

    // Excute finish in one cycle
    assign o_exfin = busy;

endmodule

`default_nettype wire
