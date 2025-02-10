// ******************************************************************* //
//                               DEFINE                                //
// ******************************************************************* //

// SUPERSCALAR
`define SUPERSCALAR_NUM       2
`define SUPERSCALAR_NUM_WIDTH 2
`define DP_NUM_WIDTH          `SUPERSCALAR_NUM_WIDTH
`define COM_NUM_WIDTH         `SUPERSCALAR_NUM_WIDTH

// PC
`define DEFAULT_PC            `RV32_PC_WIDTH'd0

// IMEM & DMEM
`define IMEM_DATA_WIDTH       128
`define IMEM_DATA_DEPTH       1024
`define IMEM_ADDR_WIDTH       10
`define DMEM_DATA_WIDTH       32
`define DMEM_DATA_DEPTH       1024
`define DMEM_ADDR_WIDTH       10

// BTB
`define BTB_ENT_NUM           512
`define BTB_ENT_SEL           9

// GSH
`define GSH_PHT_ENT_NUM       1024
`define GSH_PHT_ENT_SEL       10
`define GSH_PHT_DATA_WIDTH    2
`define GSH_GHR_WIDTH         10

// ROB & RRF
`define ROB_ENT_NUM           64
`define ROB_ENT_SEL           6
`define RRF_ENT_NUM           `ROB_ENT_NUM
`define RRF_ENT_SEL           `ROB_ENT_SEL

// SP
`define SPTAG_NUM             5
`define SPTAG_WIDTH           5
`define SPDEPTH_WIDTH         3  

// RS SEL
`define RS_SEL                2
`define RS_ALU                `RS_SEL'd0
`define RS_MUL                `RS_SEL'd1
`define RS_LDST               `RS_SEL'd2
`define RS_BR                 `RS_SEL'd3

// RS ENT
`define RS_ALU_ENT_NUM        2
`define RS_ALU_ENT_SEL        1
`define RS_MUL_ENT_NUM        2
`define RS_MUL_ENT_SEL        1
`define RS_LDST_ENT_NUM       2
`define RS_LDST_ENT_SEL       1
`define RS_BR_ENT_NUM         2
`define RS_BR_ENT_SEL         1

// STBUF
`define STBUF_ENT_NUM         32
`define STBUF_ENT_SEL         5
  
// IMM TYPE
`define IMM_TYPE_SEL          3
`define IMM_TYPE_I            `IMM_TYPE_SEL'd0
`define IMM_TYPE_S            `IMM_TYPE_SEL'd1
`define IMM_TYPE_B            `IMM_TYPE_SEL'd3
`define IMM_TYPE_J            `IMM_TYPE_SEL'd4
`define IMM_TYPE_U            `IMM_TYPE_SEL'd5

// ALU SRC
`define ALU_SRC1_SEL          1    
`define ALU_SRC1_RS1          `ALU_SRC1_SEL'd0
`define ALU_SRC1_PC           `ALU_SRC1_SEL'd1
`define ALU_SRC2_SEL          1
`define ALU_SRC2_RS2          `ALU_SRC2_SEL'd0
`define ALU_SRC2_IMM          `ALU_SRC2_SEL'd1

// ALU OP
`define ALU_OP_SEL            4
`define ALU_OP_ADD            `ALU_OP_SEL'd0
`define ALU_OP_SUB            `ALU_OP_SEL'd1
`define ALU_OP_AND            `ALU_OP_SEL'd2
`define ALU_OP_OR             `ALU_OP_SEL'd3
`define ALU_OP_XOR            `ALU_OP_SEL'd4
`define ALU_OP_SLL            `ALU_OP_SEL'd5
`define ALU_OP_SRL            `ALU_OP_SEL'd6
`define ALU_OP_SRA            `ALU_OP_SEL'd7
`define ALU_OP_SEQ            `ALU_OP_SEL'd8
`define ALU_OP_SNE            `ALU_OP_SEL'd9
`define ALU_OP_SLT            `ALU_OP_SEL'd10
`define ALU_OP_SLTU           `ALU_OP_SEL'd11
`define ALU_OP_SGE            `ALU_OP_SEL'd12
`define ALU_OP_SGEU           `ALU_OP_SEL'd13

// ******************************************************************* //
//                                 RV32                                //
// ******************************************************************* //

`define RV32_PC_WIDTH         32
`define RV32_INST_WIDTH       32
  
`define RV32_DATA_WIDTH       32
`define RV32_ADDR_WIDTH       32
  
`define RV32_SHAMT_WIDTH      5
  
`define RV32_ARF_NUM          32
`define RV32_ARF_SEL          5
  
`define RV32_RS1_RANGE        19:15
`define RV32_RS2_RANGE        24:20
`define RV32_RD_RANGE         11:7
  
`define RV32_OPCODE_WIDTH     7
`define RV32_FUNCT3_WIDTH     3
`define RV32_FUNCT7_WIDTH     7
`define RV32_OPCODE_RANGE     6:0
`define RV32_FUNCT3_RANGE     14:12
`define RV32_FUNCT7_RANGE     31:25

`define RV32_OPCODE_LUI       `RV32_OPCODE_WIDTH'b0110111
`define RV32_OPCODE_AUIPC     `RV32_OPCODE_WIDTH'b0010111
`define RV32_OPCODE_JAL       `RV32_OPCODE_WIDTH'b1101111
`define RV32_OPCODE_JALR      `RV32_OPCODE_WIDTH'b1100111
`define RV32_OPCODE_BR        `RV32_OPCODE_WIDTH'b1100011
`define RV32_OPCODE_LD        `RV32_OPCODE_WIDTH'b0000011
`define RV32_OPCODE_ST        `RV32_OPCODE_WIDTH'b0100011
`define RV32_OPCODE_OP_IMM    `RV32_OPCODE_WIDTH'b0010011
`define RV32_OPCODE_OP        `RV32_OPCODE_WIDTH'b0110011

`define RV32_FUNCT3_ADD_SUB   `RV32_FUNCT3_WIDTH'd0
`define RV32_FUNCT3_SLL       `RV32_FUNCT3_WIDTH'd1
`define RV32_FUNCT3_SLT       `RV32_FUNCT3_WIDTH'd2
`define RV32_FUNCT3_SLTU      `RV32_FUNCT3_WIDTH'd3
`define RV32_FUNCT3_XOR       `RV32_FUNCT3_WIDTH'd4
`define RV32_FUNCT3_SRL_SRA   `RV32_FUNCT3_WIDTH'd5
`define RV32_FUNCT3_OR        `RV32_FUNCT3_WIDTH'd6
`define RV32_FUNCT3_AND       `RV32_FUNCT3_WIDTH'd7

`define RV32_FUNCT3_MUL       `RV32_FUNCT3_WIDTH'd0
`define RV32_FUNCT3_MULH      `RV32_FUNCT3_WIDTH'd1
`define RV32_FUNCT3_MULHSU    `RV32_FUNCT3_WIDTH'd2
`define RV32_FUNCT3_MULHU     `RV32_FUNCT3_WIDTH'd3

`define RV32_FUNCT7_ADD       `RV32_FUNCT7_WIDTH'b0000000
`define RV32_FUNCT7_SUB       `RV32_FUNCT7_WIDTH'b0100000
`define RV32_FUNCT7_SRL       `RV32_FUNCT7_WIDTH'b0000000
`define RV32_FUNCT7_SRA       `RV32_FUNCT7_WIDTH'b0100000
