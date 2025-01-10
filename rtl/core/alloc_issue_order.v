`default_nettype none
`include "constants.vh"

module alloc_issue_order #(
    parameter ENT_NUM = 2,
    parameter ENT_SEL = 1
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_stall,
    input  wire [ENT_NUM-1:0]       i_busy_vec,
    input  wire [`DP_NUM_WIDTH-1:0] i_req_num,
    output wire                     o_allocable,
    output wire                     o_alloc_sel_vld_1,
    output wire                     o_alloc_sel_vld_2,
    output wire [ENT_SEL-1:0]       o_alloc_sel_1,
    output wire [ENT_SEL-1:0]       o_alloc_sel_2,
    input  wire [ENT_NUM-1:0]       i_vld_vec,
    input  wire                     i_issue_vld,
    output wire                     o_issue_sel_vld,
    output wire [ENT_SEL-1:0]       o_issue_sel
);

    reg [ENT_SEL-1:0] alloc_ptr;
    reg [ENT_SEL-1:0] issue_ptr;

    always @(posedge clk) begin
        if (!rst_n) begin
            alloc_ptr <= 'd0;
        end else begin
            if (i_stall) begin 
            end else begin
                alloc_ptr <= alloc_ptr + i_req_num; 
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            issue_ptr <= 'd0;
        end else begin
            if (i_issue_vld && o_issue_sel_vld) begin
                issue_ptr <= issue_ptr + 'd1;  
            end
        end
    end

    assign o_allocable = (i_req_num == 'd0) ||                 
                         ((i_req_num == 'd1) && o_alloc_sel_vld_1) ||
                         ((i_req_num == 'd2) && o_alloc_sel_vld_1 && o_alloc_sel_vld_2);

    assign o_alloc_sel_vld_1 = !i_busy_vec[o_alloc_sel_1];
    assign o_alloc_sel_vld_2 = !i_busy_vec[o_alloc_sel_2];                          
    assign o_alloc_sel_1     = alloc_ptr;
    assign o_alloc_sel_2     = alloc_ptr + 'd1; 

    assign o_issue_sel_vld   = i_vld_vec[issue_ptr];   
    assign o_issue_sel       = issue_ptr;

endmodule

`default_nettype wire
