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
    input  wire                        i_jmpcond,
    input  wire                        i_prmiss,
    input  wire                        i_prsucc,
    input  wire [`SPTAG_WIDTH-1:0]     i_sptag
);

    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_rd_data_1;
    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_rd_data_2;
    wire [`GSH_PHT_DATA_WIDTH-1:0] pht_wr_data;

    wire sptag_eq_0;
    wire sptag_eq_1;
    wire sptag_eq_2;
    wire sptag_eq_3;
    wire sptag_eq_4;

    reg  [`GSH_GHR_WIDTH-1:0] ghr_backup_0;
    reg  [`GSH_GHR_WIDTH-1:0] ghr_backup_1;
    reg  [`GSH_GHR_WIDTH-1:0] ghr_backup_2;
    reg  [`GSH_GHR_WIDTH-1:0] ghr_backup_3;
    reg  [`GSH_GHR_WIDTH-1:0] ghr_backup_4;
    wire [`GSH_GHR_WIDTH-1:0] ghr_backup_fix;

    assign pht_wr_data = ((pht_rd_data_2 == 2'd0) && (!i_jmpcond))  ? 2'd0 : 
                         ((pht_rd_data_2 == 2'd3) && i_jmpcond) ? 2'd3 :
                         i_jmpcond ? (pht_rd_data_2 + 'd1) : 
                         (pht_rd_data_2 - 'd1);

    assign sptag_eq_0 = (i_sptag == 5'b00001);
    assign sptag_eq_1 = (i_sptag == 5'b00010);
    assign sptag_eq_2 = (i_sptag == 5'b00100);
    assign sptag_eq_3 = (i_sptag == 5'b01000);
    assign sptag_eq_4 = (i_sptag == 5'b10000);

    assign ghr_backup_fix = {`GSH_GHR_WIDTH{sptag_eq_0}} & ghr_backup_0 |
                            {`GSH_GHR_WIDTH{sptag_eq_1}} & ghr_backup_1 |
                            {`GSH_GHR_WIDTH{sptag_eq_2}} & ghr_backup_2 |
                            {`GSH_GHR_WIDTH{sptag_eq_3}} & ghr_backup_3 |
                            {`GSH_GHR_WIDTH{sptag_eq_4}} & ghr_backup_4;

    always @(posedge clk) begin
        if (!rst_n) begin
            o_ghr        <= 'd0;
            ghr_backup_0 <= 'd0;
            ghr_backup_1 <= 'd0;
            ghr_backup_2 <= 'd0;
            ghr_backup_3 <= 'd0;
            ghr_backup_4 <= 'd0;
        end else begin
            // 分支预测失败进行恢复，回归同一起跑线
            if (i_prmiss) begin
                o_ghr        <= ghr_backup_fix;
                ghr_backup_0 <= ghr_backup_fix;
                ghr_backup_1 <= ghr_backup_fix;
                ghr_backup_2 <= ghr_backup_fix;
                ghr_backup_3 <= ghr_backup_fix;
                ghr_backup_4 <= ghr_backup_fix;
            // 分支与预测成功进行对应备份的更新
            end else if (i_prsucc) begin
                ghr_backup_0 <= sptag_eq_0 ? {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond} : ghr_backup_0;
                ghr_backup_1 <= sptag_eq_1 ? {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond} : ghr_backup_1;
                ghr_backup_2 <= sptag_eq_2 ? {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond} : ghr_backup_2;
                ghr_backup_3 <= sptag_eq_3 ? {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond} : ghr_backup_3;
                ghr_backup_4 <= sptag_eq_4 ? {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond} : ghr_backup_4;
            end else if (i_hit_btb) begin
                o_ghr        <= {o_ghr[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};   
                ghr_backup_0 <= {ghr_backup_0[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};
                ghr_backup_1 <= {ghr_backup_1[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};
                ghr_backup_2 <= {ghr_backup_2[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};
                ghr_backup_3 <= {ghr_backup_3[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};
                ghr_backup_4 <= {ghr_backup_4[`GSH_GHR_WIDTH-2:0], o_pred_jmpcond};   
            end
        end
    end

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
