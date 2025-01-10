`default_nettype none
`include "constants.vh"

module exunit_alu (
    input  wire                        clk,
    input  wire                        rst_n,
    output wire                        o_inaccessable,    
    input  wire                        i_is_vld,
    input  wire [`ALU_OP_SEL-1:0]      i_op_sel,      
    input  wire [`ALU_SRC1_SEL-1:0]    i_src1_sel,
    input  wire [`ALU_SRC2_SEL-1:0]    i_src2_sel,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    output wire                        o_exfin,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_res
);

    // Every excution finish in certain one clock
    // So the busy signal have no shakehand with previous issue signal 
    reg                         busy;

    wire [`RV32_DATA_WIDTH-1:0] src1;
    wire [`RV32_DATA_WIDTH-1:0] src2;
    wire [`RV32_DATA_WIDTH-1:0] res;

    assign o_inaccessable = 1'b0;

    // i_is_vld controls the busy signal one cycle ahead
    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end else begin
            busy <= i_is_vld;
        end
    end

    src1_sel_unit u_src1_sel_unit (
        .i_sel (i_src1_sel),
        .i_rs1 (i_rs1),
        .i_pc  (i_pc),
        .o_src (src1)
    );

    src2_sel_unit u_src2_sel_unit (
        .i_sel (i_src2_sel),
        .i_rs2 (i_rs2),
        .i_imm (i_imm),
        .o_src (src2)
    );

    alu u_alu (
        .i_op_sel (i_op_sel),
        .i_src1   (src1),
        .i_src2   (src2),
        .o_res    (o_exfin_res)
    );

    // Excute finish in one cycle
    assign o_exfin = busy;

endmodule

`default_nettype wire
