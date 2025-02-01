`default_nettype none
`include "constants.vh"

module ldst (
    input  wire                        clk,
    input  wire                        rst_n,    
    // State
    input  wire                        i_busy,
    // Ex
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
    output reg  [`RRF_ENT_SEL-1:0]     o_ex_ld_rrftag,
    output wire                        o_exfin_ld,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_ld_res,
    // St
    input  wire                        i_stbuf_full,
    output wire                        o_exfin_st,
    output wire [`RV32_ADDR_WIDTH-1:0] o_exfin_st_addr,
    output wire [`RV32_DATA_WIDTH-1:0] o_exfin_st_data
);

    // Addr can be reused to optimize

    reg                         busy_reg;
    reg                         is_st_reg;
    reg                         stbuf_addr_hit_reg;
    reg  [`RV32_DATA_WIDTH-1:0] stbuf_rd_data_reg;

    wire [`RV32_ADDR_WIDTH-1:0] addr;

    assign addr = i_rs1 + i_imm;

    // Can be optimized by exfin when stbuf_addr_hit
    always @(posedge clk) begin
        if (!rst_n) begin
            busy_reg           <= 'd0;
            is_st_reg          <= 'd0;
            stbuf_addr_hit_reg <= 'd0;
            stbuf_rd_data_reg  <= 'd0;
            o_ex_ld_rrftag     <= 'd0;
        end else begin
            busy_reg           <= i_busy;
            is_st_reg          <= i_is_st;
            stbuf_addr_hit_reg <= i_stbuf_addr_hit;
            stbuf_rd_data_reg  <= i_stbuf_rd_data;
            o_ex_ld_rrftag     <= i_rrftag;
        end
    end

    assign o_ld_addr       = addr;
    assign o_dmem_occupy   = i_busy && (!i_is_st);
    assign o_exfin_ld      = busy_reg && (!is_st_reg);
    assign o_exfin_ld_res  = stbuf_addr_hit_reg ? stbuf_rd_data_reg : i_dmem_rd_data;

    assign o_exfin_st      = i_busy && i_is_st && (!i_stbuf_full);
    assign o_exfin_st_addr = addr;
    assign o_exfin_st_data = i_rs2;

endmodule

`default_nettype wire
