`default_nettype none
`include "constants.vh"

module inst_sel_unit (
    input  wire [1:0]                  i_sel,
    input  wire [`IMEM_DATA_WIDTH-1:0] i_imem_rd_data,
    output wire                        o_inst_vld_1,
    output wire                        o_inst_vld_2,
    output reg  [`RV32_INST_WIDTH-1:0] o_inst_1,
    output reg  [`RV32_INST_WIDTH-1:0] o_inst_2
);

    wire [`RV32_INST_WIDTH-1:0] inst1;
    wire [`RV32_INST_WIDTH-1:0] inst2;
    wire [`RV32_INST_WIDTH-1:0] inst3;
    wire [`RV32_INST_WIDTH-1:0] inst4;

    assign inst1 = i_imem_rd_data[0+:`RV32_INST_WIDTH];
    assign inst2 = i_imem_rd_data[`RV32_INST_WIDTH+:`RV32_INST_WIDTH];  
    assign inst3 = i_imem_rd_data[(`RV32_INST_WIDTH*2)+:`RV32_INST_WIDTH];  
    assign inst4 = i_imem_rd_data[(`RV32_INST_WIDTH*3)+:`RV32_INST_WIDTH];  

    // Can be optimized by let inst_2 be invalid only when it is only one space left
    always @(*) begin
        o_inst_1 = 'd0;
        o_inst_2 = 'd0;
        case (i_sel)
            'd0: begin
                o_inst_1 = inst1;
                o_inst_2 = inst2;
            end
            'd1: begin
                o_inst_1 = inst2;
                o_inst_2 = inst3;
            end
            'd2: begin
                o_inst_1 = inst3;
                o_inst_2 = inst4;
            end
            'd3: begin
                o_inst_1 = inst4;
                o_inst_2 = inst1;
            end
        endcase
    end

    // Inst_1 is always valid, while inst_2 is valid conditionally
    assign o_inst_vld_1 = 1'b1;
    assign o_inst_vld_2 = !i_sel[0]; 

endmodule

`default_nettype wire
