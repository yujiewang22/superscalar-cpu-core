`default_nettype none
`include "constants.vh"

module exunit_ldst (
    input  wire                        clk,
    input  wire                        rst_n,    
    // State
    output wire                        o_accessable,
    // Ex
    input  wire                        i_is_vld,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1,  
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2,  
    input  wire [`RV32_DATA_WIDTH-1:0] i_imm,
    input  wire                        i_is_st,
    input  wire [`RRF_ENT_SEL-1:0]     i_rrftag,
    // Ld
    output wire [`RV32_ADDR_WIDTH-1:0] o_ld_addr,
    input  wire                        i_stbuf_addr_hit,
    input  wire [`RV32_DATA_WIDTH-1:0] i_stbuf_rd_data,
    output wire                        o_dmem_occupy,
    input  wire [`RV32_DATA_WIDTH-1:0] i_dmem_rd_data,
    output wire [`RRF_ENT_SEL-1:0]     o_ex_ld_rrftag,
    output wire                        o_exfin_ld,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_ld_res,
    // St
    input  wire                        i_stbuf_full,
    output wire                        o_exfin_st,
    output wire [`RV32_ADDR_WIDTH-1:0] o_exfin_st_addr,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_st_data
);

    reg  busy;

    assign o_accessable = !(busy && i_is_st && i_stbuf_full);

    // i_is_vld controls the busy signal one cycle ahead
    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end else begin
            busy <= i_is_vld || (!o_accessable);
        end
    end

    ldst u_ldst (
        .clk              (clk),
        .rst_n            (rst_n),
        .i_busy           (busy),
        .i_rs1            (i_rs1),
        .i_rs2            (i_rs2),
        .i_imm            (i_imm),
        .i_is_st          (i_is_st),
        .i_rrftag         (i_rrftag),
        .o_ld_addr        (o_ld_addr),
        .o_dmem_occupy    (o_dmem_occupy),
        .i_stbuf_addr_hit (i_stbuf_addr_hit),
        .i_stbuf_rd_data  (i_stbuf_rd_data),
        .i_dmem_rd_data   (i_dmem_rd_data),
        .o_ex_ld_rrftag   (o_ex_ld_rrftag),
        .o_exfin_ld       (o_exfin_ld),
        .o_exfin_ld_res   (o_exfin_ld_res),
        .i_stbuf_full     (i_stbuf_full),
        .o_exfin_st       (o_exfin_st),
        .o_exfin_st_addr  (o_exfin_st_addr),
        .o_exfin_st_data  (o_exfin_st_data)
    );

endmodule

`default_nettype wire
