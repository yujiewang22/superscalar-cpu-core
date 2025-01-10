`default_nettype none
`include "constants.vh"

module exunit_mul (
    input  wire                        clk,
    input  wire                        rst_n,
    output wire                        o_inaccessable,  
    input  wire                        i_is_vld,
    input  wire                        i_signed1,
    input  wire                        i_signed2,
    input  wire                        i_sel_high,
    input  wire [`RV32_DATA_WIDTH-1:0] i_src1,
    input  wire [`RV32_DATA_WIDTH-1:0] i_src2,   
    output wire                        o_exfin,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_res
);

    // Every excution finish in certain one clock
    // So the busy signal have no shakehand with previous issue signal 
    reg busy;

    assign o_inaccessable = 1'b0;

    // i_is_vld controls the busy signal one cycle ahead
    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end else begin
            busy <= i_is_vld;
        end
    end

    mul u_mul (
        .i_signed1  (i_signed1),
        .i_signed2  (i_signed2),
        .i_sel_high (i_sel_high),
        .i_src1     (i_src1),
        .i_src2     (i_src2),
        .o_res      (o_exfin_res)
    );

    // Excute finish in one cycle
    assign o_exfin = busy;

endmodule

`default_nettype wire
