`default_nettype none
`include "constants.vh"

module search_begin_unit #(
    parameter REQ_NUM = 2,
    parameter ACK_SEL = 1
)(
    input  wire [REQ_NUM-1:0] i_req,
    output reg                o_ack_vld,
    output reg  [ACK_SEL-1:0] o_ack
);

    integer i;

    // Lower bit have higher priority
    always @(*) begin
        o_ack_vld = 'd0;
        o_ack     = 'd0;
        for (i = REQ_NUM - 1; i >= 0; i = i - 1) begin
            if (i_req[i]) begin
                o_ack_vld = 'd1;
                o_ack     = i;
            end
            // Generate latch
        end
    end

endmodule

module search_end_unit #(
    parameter REQ_NUM = 2,
    parameter ACK_SEL = 1
)(
    input  wire [REQ_NUM-1:0] i_req,
    output reg                o_ack_vld,
    output reg  [ACK_SEL-1:0] o_ack
);

    integer i;

    // Higher bit have higher priority
    always @(*) begin
        o_ack_vld = 'd0;
        o_ack     = 'd0;
        for (i = 0; i < REQ_NUM; i = i + 1) begin
            if (i_req[i]) begin
                o_ack_vld = 'd1;
                o_ack     = i;
            end
            // Generate latch
        end
    end
    
endmodule

`default_nettype wire
