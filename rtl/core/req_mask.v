`default_nettype none
`include "constants.vh"

module req_mask #(
    parameter REQ_NUM = 2,
    parameter ACK_SEL = 1 
)(
    input  wire [ACK_SEL-1:0] i_mask,
    input  wire [REQ_NUM-1:0] i_req,
    output reg  [REQ_NUM-1:0] o_req_masked
);

    integer i;

    // Mask the certain sel signal and its lower bits
    always @(*) begin
        for (i = 0; i < REQ_NUM; i = i + 1) begin
            if (i <= i_mask) begin
                o_req_masked[i] = 'd0; 
            end else begin
                o_req_masked[i] = i_req[i]; 
            end
        end
    end

endmodule

`default_nettype wire
