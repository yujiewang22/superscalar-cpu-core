`default_nettype none
`include "constants.vh"

module pc_reg (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      i_stall,
    input  wire                      i_pred_jmpaddr_miss,
    input  wire [`RV32_PC_WIDTH-1:0] i_jmpaddr,
    input  wire                      i_pred_jmp, 
    input  wire [`RV32_PC_WIDTH-1:0] i_pred_jmpaddr,
    output reg  [`RV32_PC_WIDTH-1:0] o_pc
);

    wire [`RV32_PC_WIDTH-1:0] pc_inc;

    // Pc add 8 rather than 4
    assign pc_inc = o_pc + 'd8;

    always @(posedge clk) begin
        if (!rst_n) begin
            o_pc <= `DEFAULT_PC;
        end else if (i_stall) begin
        end else if (i_pred_jmpaddr_miss) begin
            o_pc <= i_jmpaddr;
        end else if (i_pred_jmp) begin
            o_pc <= i_pred_jmpaddr;
        end else begin
            o_pc <= pc_inc;
        end
    end

endmodule

`default_nettype wire
