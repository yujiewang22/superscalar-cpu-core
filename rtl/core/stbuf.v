`default_nettype none
`include "constants.vh"

module stbuf (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        o_full,
    input  wire                        i_exfin_st,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_exfin_st_addr,
    input  wire [`RV32_DATA_WIDTH-1:0] i_exfin_st_data,
    input  wire                        i_com_stbuf,
    input  wire                        i_dmem_occupy,
    output wire                        o_ret_stbuf,
    output wire [`RV32_ADDR_WIDTH-1:0] o_ret_stbuf_addr,
    output wire [`RV32_DATA_WIDTH-1:0] o_ret_stbuf_data,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_ld_addr,
    output wire                        o_stbuf_addr_hit,
    output wire [`RV32_DATA_WIDTH-1:0] o_stbuf_rd_data
);

    // Entry
    reg  [`STBUF_ENT_NUM-1:0]   vld;
    reg  [`STBUF_ENT_NUM-1:0]   com;
    reg  [`RV32_ADDR_WIDTH-1:0] addr [0:`STBUF_ENT_NUM-1];
    reg  [`RV32_DATA_WIDTH-1:0] data [0:`STBUF_ENT_NUM-1];

    // Ptr
    reg  [`STBUF_ENT_SEL-1:0] fin_ptr;
    reg  [`STBUF_ENT_SEL-1:0] com_ptr;
    reg  [`STBUF_ENT_SEL-1:0] ret_ptr;

    wire ret_vld;

    wire [`STBUF_ENT_NUM-1:0]   stbuf_addr_hit_vec;
    wire [`STBUF_ENT_SEL-1:0]   stbuf_addr_hit_vec_rot_shamt;
    wire [2*`STBUF_ENT_NUM-1:0] stbuf_addr_hit_vec_rot;
    wire [`STBUF_ENT_SEL-1:0]   stbuf_addr_hit_sel_rot;
    wire [`STBUF_ENT_SEL-1:0]   stbuf_addr_hit_sel;

    assign ret_vld = vld[ret_ptr] && com[ret_ptr] && (!i_dmem_occupy);

    assign stbuf_addr_hit_vec_rot_shamt = `STBUF_ENT_NUM - fin_ptr;
    assign stbuf_addr_hit_vec_rot = {stbuf_addr_hit_vec, stbuf_addr_hit_vec} << stbuf_addr_hit_vec_rot_shamt;
    assign stbuf_addr_hit_sel = stbuf_addr_hit_sel_rot + fin_ptr;
    
    always @(posedge clk) begin
        if (i_exfin_st) begin
            addr[fin_ptr] <= i_exfin_st_addr;
            data[fin_ptr] <= i_exfin_st_data;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            vld     <= 'd0;
            fin_ptr <= 'd0;
        end else begin
            if (i_exfin_st) begin
                vld[fin_ptr] <= 'd1;
                fin_ptr      <= fin_ptr + 'd1;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            vld     <= 'd0;
            com     <= 'd0;
            fin_ptr <= 'd0;
            com_ptr <= 'd0;
            ret_ptr <= 'd0;
        end else begin 
            if (i_exfin_st) begin
                vld[fin_ptr] <= 'd1;
                fin_ptr      <= fin_ptr + 'd1;
            end
            if (i_com_stbuf) begin
                com[com_ptr] <= 'd1;
                com_ptr      <= com_ptr + 'd1;
            end
            if (ret_vld) begin
                vld[ret_ptr] <= 'd0;
                com[ret_ptr] <= 'd0;
                ret_ptr      <= ret_ptr + 'd1;
            end
        end
    end

    // Search algorithm
    generate 
        genvar i;
        for (i = 0; i < `STBUF_ENT_NUM; i = i + 1) begin: hit_vec
            assign stbuf_addr_hit_vec[i] = ((addr[i] == i_ld_addr) && vld[i]) ? 1'b1 : 1'b0;
        end
    endgenerate

    search_end_unit #(
        .REQ_NUM   (`STBUF_ENT_NUM),
        .ACK_SEL   (`STBUF_ENT_SEL)
    ) u_search_end_unit (
        .i_req     (stbuf_addr_hit_vec_rot[`STBUF_ENT_NUM+:`STBUF_ENT_NUM]),
        .o_ack_vld (o_stbuf_addr_hit),
        .o_ack     (stbuf_addr_hit_sel_rot)
    );

    assign o_full           = (fin_ptr == ret_ptr) && (vld[fin_ptr]);
    assign o_ret_stbuf      = ret_vld;
    assign o_ret_stbuf_addr = addr[ret_ptr];
    assign o_ret_stbuf_data = data[ret_ptr];
    assign o_stbuf_rd_data  = data[stbuf_addr_hit_sel];

endmodule

`default_nettype wire
