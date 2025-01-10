`default_nettype none
`include "constants.vh"

module freelist_manager (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      i_stall,
    input  wire                      i_dp_vld_1,
    input  wire                      i_dp_vld_2,
    input  wire [`COM_NUM_WIDTH-1:0] i_com_num,
    output wire                      o_allocable,
    output wire [`ROB_ENT_SEL-1:0]   o_dp_ptr_1,
    output wire [`ROB_ENT_SEL-1:0]   o_dp_ptr_2
);

    reg  [`ROB_ENT_SEL:0]    free_num; // A bit more to achieve 64
    reg  [`ROB_ENT_SEL-1:0]  dp_ptr;

    wire [`DP_NUM_WIDTH-1:0] dp_num;

    assign dp_num = {1'b0, i_dp_vld_1} + {1'b0, i_dp_vld_2};

    always @(posedge clk) begin
        if (!rst_n) begin
            free_num <= `ROB_ENT_NUM;
        end else begin
            // i_stall is coupling with o_allocable outside this module
            if (i_stall) begin
                free_num <= free_num + i_com_num;
            end else begin
                free_num <= free_num - dp_num + i_com_num;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            dp_ptr <= 'd0;
        end else begin
            if (i_stall) begin
                dp_ptr <= dp_ptr;
            end else begin
                dp_ptr <= dp_ptr + dp_num;
            end
        end
    end

    assign o_allocable = ((free_num + i_com_num) >= dp_num) ? 1'b1 : 1'b0;
    assign o_dp_ptr_1 = dp_ptr;
    assign o_dp_ptr_2 = dp_ptr + 'd1;

endmodule

`default_nettype wire
