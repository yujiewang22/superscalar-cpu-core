`default_nettype none
`include "constants.vh"

module mpft (
    input  wire clk,
    input  wire rst_n,

    input  wire                    i_id_inst_sp_1,
    input  wire                    i_id_inst_sp_2,
    input  wire [`SPTAG_WIDTH-1:0] i_id_inst_sptag_1,
    input  wire [`SPTAG_WIDTH-1:0] i_id_inst_sptag_2,

    input  wire                    i_exfin_br_prsucc,
    input  wire                    i_exfin_br_prmiss,
    input  wire [`SPTAG_WIDTH-1:0] i_exfin_br_sptag
);

    // Contribute
    reg  [`SPTAG_WIDTH-1:0] vld;
    reg  [`SPTAG_WIDTH-1:0] data [0:`SPTAG_NUM-1];

    wire [`SPTAG_WIDTH-1:0] vld_mod;
    wire [`SPTAG_WIDTH-1:0] set_data_0;
    wire [`SPTAG_WIDTH-1:0] set_data_1;
    wire [`SPTAG_WIDTH-1:0] set_data_2;
    wire [`SPTAG_WIDTH-1:0] set_data_3;
    wire [`SPTAG_WIDTH-1:0] set_data_4;

    wire [`SPTAG_WIDTH-1:0] clr_data_0;
    wire [`SPTAG_WIDTH-1:0] clr_data_1;
    wire [`SPTAG_WIDTH-1:0] clr_data_2;
    wire [`SPTAG_WIDTH-1:0] clr_data_3;
    wire [`SPTAG_WIDTH-1:0] clr_data_4;

    always @(posedge clk) begin
        if (rst_n) begin
            vld <= 'd0;
        end else begin
            // Prmiss
            if (i_exfin_br_prmiss) begin
                vld <= 'd0;
            // Clr
            end else if (i_exfin_br_prsucc) begin
                vld <= vld & (~i_exfin_br_sptag);
            // Set and maintain 
            end else begin
                vld <=(i_id_inst_sp_1 ? i_id_inst_sptag_1 : 'd0) | (i_id_inst_sp_2 ? i_id_inst_sptag_2 : 'd0) | vld;
            end
        end
    end

    assign vld_mod = i_id_inst_sp_1 ? (vld | i_id_inst_sptag_1) : vld;

    assign set_data_0 = ((i_id_inst_sp_1 && i_id_inst_sptag_1[0]) ? (vld | 5'b00001) : 5'd0) |
                        ((i_id_inst_sp_2 && i_id_inst_sptag_2[0]) ? (vld_mod | 5'b00001) : 5'd0);
    assign set_data_1 = ((i_id_inst_sp_1 && i_id_inst_sptag_1[1]) ? (vld | 5'b00010) : 5'd0) |
                        ((i_id_inst_sp_2 && i_id_inst_sptag_2[1]) ? (vld_mod | 5'b00010) : 5'd0);
    assign set_data_2 = ((i_id_inst_sp_1 && i_id_inst_sptag_1[2]) ? (vld | 5'b00100) : 5'd0) |
                        ((i_id_inst_sp_2 && i_id_inst_sptag_2[2]) ? (vld_mod | 5'b00100) : 5'd0);
    assign set_data_3 = ((i_id_inst_sp_1 && i_id_inst_sptag_1[3]) ? (vld | 5'b01000) : 5'd0) |
                        ((i_id_inst_sp_2 && i_id_inst_sptag_2[3]) ? (vld_mod | 5'b01000) : 5'd0);
    assign set_data_4 = ((i_id_inst_sp_1 && i_id_inst_sptag_1[4]) ? (vld | 5'b10000) : 5'd0) |
                        ((i_id_inst_sp_2 && i_id_inst_sptag_2[4]) ? (vld_mod | 5'b10000) : 5'd0);

    always @(posedge clk) begin
        if (!rst_n) begin
            data[0] <= 'd0;
            data[1] <= 'd0;
            data[2] <= 'd0;
            data[3] <= 'd0;
            data[4] <= 'd0;
        end else begin
            if (i_exfin_br_prmiss) begin
                data[0] <= 'd0;
                data[1] <= 'd0;
                data[2] <= 'd0;
                data[3] <= 'd0;
                data[4] <= 'd0;
            end else if (i_exfin_br_prsucc) begin 
                data[0] <= data[0] & clr_data_0;
                data[1] <= data[1] & clr_data_1;
                data[2] <= data[2] & clr_data_2;
                data[3] <= data[3] & clr_data_3;
                data[4] <= data[4] & clr_data_4;
            end else begin
                data[0] <= data[0] | set_data_0;
                data[1] <= data[1] | set_data_1;
                data[2] <= data[2] | set_data_2;
                data[3] <= data[3] | set_data_3;
                data[4] <= data[4] | set_data_4;
            end
        end
    end

endmodule

`default_nettype wire
