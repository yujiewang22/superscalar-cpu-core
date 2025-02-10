`default_nettype none
`include "constants.vh"

module exunit_br (
    input  wire                        clk,
    input  wire                        rst_n,
    output wire                        o_accessable,  
    input  wire                        i_is_vld,
    input  wire                        i_is_jal,
    input  wire                        i_is_jalr,
    input  wire [`ALU_OP_SEL-1:0]      i_alu_op_sel,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pred_jmpaddr,
    output wire                        o_exfin_jal_jalr,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_jal_jalr_res,
    output wire                        o_exfin,
    output wire [`RV32_PC_WIDTH-1:0]   o_exfin_jmpaddr,
    output wire                        o_exfin_jmpcond,
    output wire                        o_exfin_prsucc,   
    output wire                        o_exfin_prmiss
);

    reg  busy;

    wire pred_jmpaddr_suc;

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
        .i_is_jal           (i_is_jal),
        .i_is_jalr          (i_is_jalr),
        .i_alu_op_sel       (i_alu_op_sel),
        .i_rs1              (i_rs1),
        .i_rs2              (i_rs2),
        .i_pc               (i_pc),
        .i_imm              (i_imm),
        .i_pred_jmpaddr     (i_pred_jmpaddr),
        .o_jmpaddr          (o_exfin_jmpaddr),
        .o_jmpcond          (o_exfin_jmpcond),
        .o_pred_jmpaddr_suc (pred_jmpaddr_suc)
    );

    // Excute finish in one cycle
    assign o_exfin_jal_jalr     = busy && (i_is_jal || i_is_jalr);
    assign o_exfin_jal_jalr_res = o_exfin_jmpaddr;
    assign o_exfin              = busy;
    assign o_exfin_prsucc       = busy && pred_jmpaddr_suc;
    assign o_exfin_prmiss       = busy && (!pred_jmpaddr_suc);

endmodule

`default_nettype wire
