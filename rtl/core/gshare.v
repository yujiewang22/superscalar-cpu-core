`default_nettype none
`include "constants.vh"

module gshare (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    output reg  [`GSH_GHR_WIDTH-1:0]   o_ghr,
    output wire                        o_pred_jmpcond,
    input  wire                        i_hit_btb,
    input  wire                        i_pht_wr_en,
    input  wire [`GSH_PHT_ENT_SEL-1:0] i_pht_wr_addr,
    input  wire                        i_jmpcond
);

    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_rd_data_1;
    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_rd_data_2;
    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_wr_data;

    assign pht_wr_data = ((pht_rd_data_2 == 2'd0) && (!i_jmpcond))  ? 2'd0 : 
                         ((pht_rd_data_2 == 2'd3) && i_jmpcond) ? 2'd3 :
                         i_jmpcond ? (pht_rd_data_2 + 'd1) : 
                         (pht_rd_data_2 - 'd1);

    // Shift left to renew the bhr in if-stage
    always @(posedge clk) begin
        if (!rst_n) begin
            o_ghr <= 'd0;
        end else begin
            if (i_hit_btb) begin
                o_ghr <= {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};      
            end
        end
    end

    // This idx has some problems
    // Can be replaced by a simple fsm
    pht u_pht (
        .clk         (clk),
        .i_rd_addr_1 (i_pc[2+:`GSH_PHT_ENT_SEL] ^ o_ghr), 
        .i_rd_addr_2 (i_pht_wr_addr),
        .o_rd_data_1 (pht_rd_data_1),
        .o_rd_data_2 (pht_rd_data_2),
        .i_wr_en     (i_pht_wr_en),
        .i_wr_addr   (i_pht_wr_addr),
        .i_wr_data   (pht_wr_data)
    );

    assign o_pred_jmpcond = (pht_rd_data_1 > 'd1) ? 1'b1 : 1'b0; 

endmodule

`default_nettype wire
