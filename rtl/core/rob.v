`default_nettype none
`include "constants.vh"

module rob (
    input  wire                        clk,
    input  wire                        rst_n,
    // Dp stall
    input  wire                        i_stall,
    // Dp-stage write
    input  wire                        i_dp_vld_1,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_ptr_1,
    input  wire                        i_dp_rd_wr_en_1,
    input  wire [`RV32_ARF_SEL-1:0]    i_dp_rd_wr_addr_1,
    input  wire                        i_dp_is_st_1,
    input  wire                        i_dp_is_br_1,
    input  wire [`RV32_PC_WIDTH-1:0]   i_dp_pc_1,
    input  wire [`GSH_GHR_WIDTH-1:0]   i_dp_ghr_1,
    input  wire                        i_dp_vld_2,
    input  wire [`RRF_ENT_SEL-1:0]     i_dp_ptr_2,
    input  wire                        i_dp_rd_wr_en_2,
    input  wire [`RV32_ARF_SEL-1:0]    i_dp_rd_wr_addr_2,
    input  wire                        i_dp_is_st_2,
    input  wire                        i_dp_is_br_2,
    input  wire [`RV32_PC_WIDTH-1:0]   i_dp_pc_2,
    input  wire [`GSH_GHR_WIDTH-1:0]   i_dp_ghr_2,
    // Exfin-stage renew
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_alu_rrftag,
    input  wire                        i_exfin_alu,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_mul_rrftag,
    input  wire                        i_exfin_mul,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_ld_rrftag, 
    input  wire                        i_exfin_ld, 
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_st_rrftag, 
    input  wire                        i_exfin_st,
    input  wire [`RRF_ENT_SEL-1:0]     i_ex_br_rrftag, 
    input  wire                        i_exfin_br,
    input  wire [`RV32_PC_WIDTH-1:0]   i_exfin_br_jmpaddr, 
    input  wire                        i_exfin_br_jmpcond,  
    // Com-stage 
    output wire [`COM_NUM_WIDTH-1:0]   o_com_num,
    output wire                        o_com_vld_1,
    output wire [`ROB_ENT_SEL-1:0]     o_com_ptr_1,
    output wire                        o_com_rd_wr_en_1,
    output wire [`RV32_ARF_SEL-1:0]    o_com_rd_wr_addr_1,
    output wire                        o_com_vld_2,
    output wire [`ROB_ENT_SEL-1:0]     o_com_ptr_2,
    output wire                        o_com_rd_wr_en_2,
    output wire [`RV32_ARF_SEL-1:0]    o_com_rd_wr_addr_2,
    output wire                        o_com_st,
    output wire                        o_com_br,
    output wire [`RV32_PC_WIDTH-1:0]   o_com_pc,
    output wire [`GSH_GHR_WIDTH-1:0]   o_com_ghr,
    output wire [`RV32_PC_WIDTH-1:0]   o_com_jmpaddr,
    output wire                        o_com_jmpcond
);

    // Maintain com_ptr here
    reg  [`RRF_ENT_SEL-1:0]   com_ptr;

    // Attributes in rob
    reg  [`ROB_ENT_NUM-1:0]   finish;
    reg  [`ROB_ENT_NUM-1:0]   rd_wr_en;
    reg  [`RV32_ARF_SEL-1:0]  rd_wr_addr [0:`ROB_ENT_NUM-1];
    reg  [`ROB_ENT_NUM-1:0]   is_st;
    reg  [`ROB_ENT_NUM-1:0]   is_br;
    reg  [`RV32_PC_WIDTH-1:0] pc [0:`ROB_ENT_NUM-1];
    reg  [`GSH_GHR_WIDTH-1:0] ghr [0:`ROB_ENT_NUM-1];
    reg  [`RV32_PC_WIDTH-1:0] jmpaddr [0:`ROB_ENT_NUM-1];
    reg  [`ROB_ENT_NUM-1:0]   jmpcond;  

    wire com_ptr_finish_1;
    wire com_ptr_finish_2;

    assign o_com_ptr_1      = com_ptr;
    assign o_com_ptr_2      = com_ptr + 'd1;
    assign com_ptr_finish_1 = finish[o_com_ptr_1];
    assign com_ptr_finish_2 = finish[o_com_ptr_2];

    // Com_ptr
    // Renew when detect finish
    always @(posedge clk) begin
        if (!rst_n) begin
            com_ptr <= 'd0;
        end else begin
            com_ptr <= com_ptr + o_com_vld_1 + o_com_vld_2;
        end
    end

    // Finish
    // clr when dispatch, set when exfinish, reclr when next dispatch
    always @(posedge clk) begin
        if (!rst_n) begin
            finish <= 'd0;
        end else begin
            if (i_stall) begin  
                finish[i_dp_ptr_1] <= finish[i_dp_ptr_1];
                finish[i_dp_ptr_2] <= finish[i_dp_ptr_2];
            end else begin
                if (i_dp_vld_1) begin
                    finish[i_dp_ptr_1] <= 'd0;
                end
                if (i_dp_vld_2) begin
                    finish[i_dp_ptr_2] <= 'd0;
                end     
            end  
            if (i_exfin_alu) begin
                finish[i_ex_alu_rrftag] <= 'd1;
            end
            if (i_exfin_mul) begin
                finish[i_ex_mul_rrftag] <= 'd1;
            end
            if (i_exfin_ld) begin
                finish[i_ex_ld_rrftag] <= 'd1;
            end
            if (i_exfin_st) begin
                finish[i_ex_st_rrftag] <= 'd1;
            end
            if (i_exfin_br) begin
                finish[i_ex_br_rrftag] <= 'd1;
            end
        end
    end

    // Other attributes
    // Overwritten when next dp, no need to clr
    always @(posedge clk) begin
        if (i_stall) begin
        end else begin
            if (i_dp_vld_1) begin
                rd_wr_en[i_dp_ptr_1]   <= i_dp_rd_wr_en_1;
                rd_wr_addr[i_dp_ptr_1] <= i_dp_rd_wr_addr_1;
                is_st[i_dp_ptr_1]      <= i_dp_is_st_1;
                is_br[i_dp_ptr_1]      <= i_dp_is_br_1;
                pc[i_dp_ptr_1]         <= i_dp_pc_1;
                ghr[i_dp_ptr_1]        <= i_dp_ghr_1;
            end
            if (i_dp_vld_2) begin
                rd_wr_en[i_dp_ptr_2]   <= i_dp_rd_wr_en_2;
                rd_wr_addr[i_dp_ptr_2] <= i_dp_rd_wr_addr_2;
                is_st[i_dp_ptr_2]      <= i_dp_is_st_2;
                is_br[i_dp_ptr_2]      <= i_dp_is_br_2;
                pc[i_dp_ptr_2]         <= i_dp_pc_2;
                ghr[i_dp_ptr_2]        <= i_dp_ghr_2;
            end     
            if (i_exfin_br) begin
                jmpaddr[i_ex_br_rrftag] <= i_exfin_br_jmpaddr;
                jmpcond[i_ex_br_rrftag] <= i_exfin_br_jmpcond;
            end
        end      
    end

    // Com_vld_2 must wait for com_vld_1
    // St and br are commited one by one, and can be optimized here
    assign o_com_num          = {1'b0, o_com_vld_1} + {1'b0, o_com_vld_2};
    assign o_com_vld_1        = com_ptr_finish_1; 
    assign o_com_rd_wr_en_1   = rd_wr_en[o_com_ptr_1];
    assign o_com_rd_wr_addr_1 = rd_wr_addr[o_com_ptr_1];
    assign o_com_vld_2        = com_ptr_finish_1 && com_ptr_finish_2 && (!is_st[o_com_ptr_1]) && (!is_br[o_com_ptr_1]); 
    assign o_com_rd_wr_en_2   = rd_wr_en[o_com_ptr_2];
    assign o_com_rd_wr_addr_2 = rd_wr_addr[o_com_ptr_2];
    assign o_com_st           = (o_com_vld_1 && is_st[o_com_ptr_1]) || (o_com_vld_2 && is_st[o_com_ptr_2]);
    assign o_com_br           = (o_com_vld_1 && is_br[o_com_ptr_1]) || (o_com_vld_2 && is_br[o_com_ptr_2]); 
    assign o_com_pc           = is_br[o_com_ptr_1] ? i_dp_pc_1 : i_dp_pc_2;
    assign o_com_ghr          = is_br[o_com_ptr_1] ? ghr[o_com_ptr_1] : ghr[o_com_ptr_2];
    assign o_com_jmpaddr      = is_br[o_com_ptr_1] ? jmpaddr[o_com_ptr_1] : jmpaddr[o_com_ptr_2];
    assign o_com_jmpcond      = is_br[o_com_ptr_1] ? jmpcond[o_com_ptr_1] : jmpcond[o_com_ptr_2];

endmodule

`default_nettype wire
