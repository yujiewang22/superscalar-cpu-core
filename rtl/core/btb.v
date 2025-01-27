`default_nettype none
`include "constants.vh"

module btb (
    input  wire                      clk,
    input  wire                      rst_n,
    // Read
    input  wire                      i_inst_vld_1,
    input  wire                      i_inst_vld_2,
    input  wire [`RV32_PC_WIDTH-1:0] i_pc_1,
    input  wire [`RV32_PC_WIDTH-1:0] i_pc_2,
    output wire                      o_hit_btb,
    output wire [`RV32_PC_WIDTH-1:0] o_pc_btb,
    // Write
    input  wire                      i_wr_en,
    input  wire [`RV32_PC_WIDTH-1:0] i_jmpsrc,
    input  wire [`RV32_PC_WIDTH-1:0] i_jmpaddr
);

    reg  [`BTB_ENT_NUM-1:0] vld;

    wire [`RV32_PC_WIDTH-1:0] bia_rd_data;

    wire [`BTB_ENT_SEL-1:0] rd_idx_1;
    wire [`BTB_ENT_SEL-1:0] rd_idx_2;
    wire                    hit_btb_1;
    wire                    hit_btb_2;
    wire                    wr_idx;

    // Can be optimized by using a part of the PC here
    // Pc_1 and pc_2 are mapped to the same entry
    assign rd_idx_1  = i_pc_1[3+:`BTB_ENT_SEL];
    assign rd_idx_2  = i_pc_2[3+:`BTB_ENT_SEL];
    assign hit_btb_1 = i_inst_vld_1 && vld[rd_idx_1] && (bia_rd_data == i_pc_1);
    assign hit_btb_2 = i_inst_vld_2 && vld[rd_idx_2] && (bia_rd_data == i_pc_2);
    assign o_hit_btb = hit_btb_1 || hit_btb_2;
    assign wr_idx    = i_jmpsrc[3+:`BTB_ENT_SEL];

    // Vld
    // Only need to be written once, and no need to be cleared
    always @(posedge clk) begin
        if (!rst_n) begin
            vld <= 'd0;
        end else begin
            if (i_wr_en) begin
                vld[wr_idx] <= 'd1;
            end
        end
    end

    // Use ram for large storage rather than always regs
    // Though in negedge clk, the read and write are in the same clock cycle comparatively

    ram_1r1w_2port #(
        .ADDR_WIDTH (`BTB_ENT_SEL),
        .DATA_DEPTH (`BTB_ENT_NUM),
        .DATA_WIDTH (`RV32_PC_WIDTH)
    ) u_bia (
        .clk        (~clk), // Negedge
        .i_rd_addr  (rd_idx_1), 
        .o_rd_data  (bia_rd_data),
        .i_wr_en    (i_wr_en),
        .i_wr_addr  (wr_idx),
        .i_wr_data  (i_jmpsrc)
    );

    ram_1r1w_2port #(
        .ADDR_WIDTH (`BTB_ENT_SEL),
        .DATA_DEPTH (`BTB_ENT_NUM),
        .DATA_WIDTH (`RV32_PC_WIDTH)
    ) u_bta (
        .clk        (~clk), // Negedge
        .i_rd_addr  (rd_idx_1),
        .o_rd_data  (o_pc_btb),
        .i_wr_en    (i_wr_en),
        .i_wr_addr  (wr_idx),
        .i_wr_data  (i_jmpaddr)
    );

endmodule

`default_nettype wire
