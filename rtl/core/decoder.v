`default_nettype none
`include "constants.vh"

module decoder (
    input  wire [`RV32_INST_WIDTH-1:0] i_inst,
    // illegal inst
    output wire                        o_illegal,
    // Arf
    output reg                         o_rs1_rd_en,
    output reg                         o_rs2_rd_en,
    output reg                         o_rd_wr_en,
    output wire [`RV32_ARF_SEL-1:0]    o_rs1_rd_addr,
    output wire [`RV32_ARF_SEL-1:0]    o_rs2_rd_addr,
    output wire [`RV32_ARF_SEL-1:0]    o_rd_wr_addr,
    // Imm
    output reg  [`IMM_TYPE_SEL-1:0]    o_imm_type_sel,
    // Alu
    output reg  [`ALU_OP_SEL-1:0]      o_alu_op_sel,
    output reg  [`ALU_SRC1_SEL-1:0]    o_alu_src1_sel,
    output reg  [`ALU_SRC2_SEL-1:0]    o_alu_src2_sel,
    // Mul
    output reg                         o_mul_signed1,
    output reg                         o_mul_signed2,
    output reg                         o_mul_sel_high,   
    // Ldst
    output reg                         o_is_st,
    // Br
    output reg                         o_is_br,
    output reg                         o_is_jal,
    output reg                         o_is_jalr,
    // Rs
    output reg  [`RS_SEL-1:0]          o_rs_sel
);

    wire [`RV32_OPCODE_WIDTH-1:0] opcode;
    wire [`RV32_FUNCT3_WIDTH-1:0] funct3;
    wire [`RV32_FUNCT7_WIDTH-1:0] funct7;
    wire [`ALU_OP_SEL-1:0]        sel_add_or_sub;
    wire [`ALU_OP_SEL-1:0]        sel_srl_or_sra;
    wire [`RS_SEL-1:0]            sel_rs_alu_or_rs_mul;

    assign opcode = i_inst[`RV32_OPCODE_RANGE];
    assign funct3 = i_inst[`RV32_FUNCT3_RANGE];
    assign funct7 = i_inst[`RV32_FUNCT7_RANGE];

    // Sel parrallelly
    assign sel_add_or_sub       = (opcode[5] && i_inst[30]) ? `ALU_OP_SUB : `ALU_OP_ADD;    // Fast decode
    assign sel_srl_or_sra       = i_inst[30] ? `ALU_OP_SRA : `ALU_OP_SRL;
    assign sel_rs_alu_or_rs_mul = i_inst[25] ? `RS_MUL : `RS_ALU;

    assign o_rs1_rd_addr = i_inst[`RV32_RS1_RANGE];
    assign o_rs2_rd_addr = i_inst[`RV32_RS2_RANGE];
    assign o_rd_wr_addr  = i_inst[`RV32_RD_RANGE];

    // Simple illegal detect, to be further modified
    assign o_illegal = (i_inst == 'd0);

    // Decode opcode
    always @(*) begin
        o_rs1_rd_en    = 'd0;
        o_rs2_rd_en    = 'd0;
        o_rd_wr_en     = 'd0;
        o_imm_type_sel = 'd0;
        o_alu_src1_sel = 'd0;
        o_alu_src2_sel = 'd0;
        o_is_st        = 'd0;
        o_is_br        = 'd0;
        o_is_jal       = 'd0;
        o_is_jalr      = 'd0;
        o_rs_sel       = 'd0;
        case (opcode)
            `RV32_OPCODE_OP_IMM: begin
                o_rs1_rd_en    = 'd1;
                o_rd_wr_en     = 'd1;
                o_imm_type_sel = `IMM_TYPE_I;
                o_alu_src1_sel = `ALU_SRC1_RS1;
                o_alu_src2_sel = `ALU_SRC2_IMM;
                o_rs_sel       = `RS_ALU;
            end
            `RV32_OPCODE_OP: begin
                o_rs1_rd_en    = 'd1;
                o_rs2_rd_en    = 'd1;
                o_rd_wr_en     = 'd1;
                o_alu_src1_sel = `ALU_SRC1_RS1;
                o_alu_src2_sel = `ALU_SRC2_RS2;
                o_rs_sel       = sel_rs_alu_or_rs_mul;
            end
            `RV32_OPCODE_LD: begin  
                o_rs1_rd_en    = 'd1; 
                o_rd_wr_en     = 'd1;      
                o_imm_type_sel = `IMM_TYPE_I;   
                o_rs_sel       = `RS_LDST;
            end
            `RV32_OPCODE_ST: begin  
                o_rs1_rd_en    = 'd1;
                o_rs2_rd_en    = 'd1;     
                o_is_st        = 'd1;      
                o_imm_type_sel = `IMM_TYPE_S;   
                o_rs_sel       = `RS_LDST;
            end
            `RV32_OPCODE_BR: begin
                o_rs1_rd_en     = 'd1;
                o_rs2_rd_en     = 'd1;
                o_imm_type_sel  = `IMM_TYPE_B;
                o_is_br         = 'd1;
                o_rs_sel        = `RS_BR;
            end
            `RV32_OPCODE_JAL: begin
                o_rd_wr_en     = 'd1;
                o_imm_type_sel = `IMM_TYPE_J;
                o_is_br        = 'd1;
                o_is_jal       = 'd1;
                o_rs_sel       = `RS_BR;
            end
            `RV32_OPCODE_JALR: begin
                o_rs1_rd_en    = 'd1;
                o_rd_wr_en     = 'd1;
                o_imm_type_sel = `IMM_TYPE_I;
                o_is_br        = 'd1;
                o_is_jalr      = 'd1;
                o_rs_sel       = `RS_BR;
            end
        endcase
    end

    // Decode alu funct3
    always @(*) begin
        o_alu_op_sel = 'd0;
        case (funct3)
            `RV32_FUNCT3_ADD_SUB: begin
                o_alu_op_sel = sel_add_or_sub; 
            end
            `RV32_FUNCT3_SLL: begin
                o_alu_op_sel = `ALU_OP_SLL; 
            end
            `RV32_FUNCT3_SLT: begin
                o_alu_op_sel = `ALU_OP_SLT; 
            end
            `RV32_FUNCT3_SLTU: begin
                o_alu_op_sel = `ALU_OP_SLTU; 
            end
            `RV32_FUNCT3_XOR: begin
                o_alu_op_sel = `ALU_OP_XOR; 
            end
            `RV32_FUNCT3_SRL_SRA: begin
                o_alu_op_sel = sel_srl_or_sra; 
            end
            `RV32_FUNCT3_OR: begin
                o_alu_op_sel = `ALU_OP_OR; 
            end
            `RV32_FUNCT3_AND: begin
                o_alu_op_sel = `ALU_OP_AND; 
            end
        endcase
    end
    
    // Decode mul funct3
    always @(*) begin
        o_mul_signed1  <= 'd0;
        o_mul_signed2  <= 'd0;
        o_mul_sel_high <= 'd0;
        case (funct3)
            `RV32_FUNCT3_MUL: begin
                o_mul_signed1  <= 'd1;
                o_mul_signed2  <= 'd1;
            end
            `RV32_FUNCT3_MULH: begin
                o_mul_signed1  <= 'd1;
                o_mul_signed2  <= 'd1;
                o_mul_sel_high <= 'd1;
            end
            `RV32_FUNCT3_MULHSU: begin
                o_mul_signed1  <= 'd1;
                o_mul_sel_high <= 'd1;
            end
            `RV32_FUNCT3_MULHU: begin
                o_mul_sel_high <= 'd1;
            end
        endcase
    end

endmodule

`default_nettype wire
