`include "constants.vh"
`default_nettype none

module top_tb();

    // ----------------------------------------------------------------- //
    // ************************* 测试文件说明：************************** //
    // --> 1、配置测试二进制文件                                             
    // --> 2、配置仿真周期数                                                 
    // --> 3、配置仿真打印的结束信息                         
    // --> 4、配置仿真打印的每周期信息          
    // ***************************************************************** //
    // ----------------------------------------------------------------- //

    // ******************************** // 
    //         配置测试二进制文件         
    // ******************************** // 

    // ----const----
    // parameter INST_FILE_PATH = "./isa/rv32_lui.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_auipc.txt";
    // ----jump----
    // parameter INST_FILE_PATH = "./isa/rv32_jal.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_jalr.txt";
    // ----br----
    // parameter INST_FILE_PATH = "./isa/rv32_beq_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_beq_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bne_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bne_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_blt_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_blt_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bge_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bge_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bltu_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bltu_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bgeu_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bgeu_ntaken.txt";
    // ----load----
    // parameter INST_FILE_PATH = "./isa/rv32_lb.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lh.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lw.txt";      // pass
    // parameter INST_FILE_PATH = "./isa/rv32_lbu.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lhu.txt";
    // ----store----
    // parameter INST_FILE_PATH = "./isa/rv32_sb.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sh.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sw.txt";      // pass
    // ----op_i----
    // parameter INST_FILE_PATH = "./isa/rv32_addi.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_slti.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_sltiu.txt";   // pass
    // parameter INST_FILE_PATH = "./isa/rv32_xori.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_ori.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_andi.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_slli.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_srli.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_srai.txt";    // pass
    // ----op---
    // parameter INST_FILE_PATH = "./isa/rv32_add.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_sub.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_sll.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_slt.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_sltu.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_xor.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_srl.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_sra.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_or.txt";      // pass
    // parameter INST_FILE_PATH = "./isa/rv32_and.txt";     // pass
    // ----mul----
    // parameter INST_FILE_PATH = "./isa/rv32_mul.txt";     // pass
    // parameter INST_FILE_PATH = "./isa/rv32_mulh.txt";    // pass
    // parameter INST_FILE_PATH = "./isa/rv32_mulhsu.txt";  // pass
    // parameter INST_FILE_PATH = "./isa/rv32_mulhu.txt";   // pass

    // ******************************** // 
    //          配置仿真周期数
    // ******************************** //  

    parameter HALF_CLK_PERIOD       = 50;    // **MODIFY HERE** 时钟半周期
    parameter CLK_PERIOD            = HALF_CLK_PERIOD * 2;
    parameter SIM_INTERVAL_CYCLE    = 1;     // **MODIFY HERE** 初始间隔
    parameter SIM_INTERVAL_TIME     = SIM_INTERVAL_CYCLE * CLK_PERIOD;   
    parameter SIM_CYCLE             = 15;    // **MODIFY HERE** 仿真时间
    parameter SIM_TIME              = SIM_CYCLE * CLK_PERIOD;

    // ******************************** // 
    //      配置仿真打印的结束信息
    // ******************************** // 

    integer i;
    reg 	   clk;
    reg 	   rst_n;
    reg [31:0] clk_cycle;

    initial begin
        #SIM_INTERVAL_TIME;
        #SIM_TIME;
        display_regfile();
        $finish;
    end

    // ******************************** // 
    //      配置仿真打印的每周期信息
    // ******************************** // 

    initial begin  
        while(1) begin
            @(posedge clk)            
            display_cycle();
            display_control();
            display_if_stage();
            display_id_stage();
            display_dp_stage();
            display_is_stage();
            display_ex_stage();
            display_interact_dmem();
            display_com_stage();
            display_dmem();
            display_stbuf();
        end
    end
    
    // ----------------------------------------------------------------- //

    top u_top(
	    .clk(clk),
	    .rst_n(rst_n)
	);

    initial begin  
        $readmemb(INST_FILE_PATH, u_top.u_imem.mem);
    end

    initial begin
        clk = 0;
        forever #HALF_CLK_PERIOD clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #SIM_INTERVAL_TIME rst_n = 1;
    end
   
    initial begin
        clk_cycle = 32'h0;
        #SIM_INTERVAL_TIME clk_cycle = 32'h0;
    end
   
    always @(posedge clk) begin
        clk_cycle <= clk_cycle + 1;
    end

    // ----------------------------------------------------------------- //

    task display_space;
        begin
            $display(""); 
        end
    endtask

    task display_cycle;
        begin
            $display("*******************************************");
            $display("                [CYCLE %2d]", clk_cycle);
            $display("*******************************************");                   
        end
    endtask


    task display_regfile;
        begin
            $display("----------------REGFILE--------------------"); 
            for(i = 0; i < 32 ; i = i + 1)begin
                $display("x%2d value is : %h", i, u_top.u_pipeline.u_arf.u_regfile.mem[i]);
            end
        end
    endtask   


    task display_control;
        begin
            $display("----------------------CONTROL-------------------------");
            $display("stall_if            : %1b", u_top.u_pipeline.stall_if);
            $display("stall_id            : %1b", u_top.u_pipeline.stall_id);
            $display("stall_dp            : %1b", u_top.u_pipeline.stall_dp);
            // $display("freelist_allocable      : %1b", u_top.u_pipeline.freelist_allocable);
            // $display("dp_rs_alu_req_1         : %1b", u_top.u_pipeline.dp_rs_alu_req_1);  
            // $display("dp_rs_alu_req_2         : %1b", u_top.u_pipeline.dp_rs_alu_req_2); 
            // $display("dp_rs_alu_req_num       : %1d", u_top.u_pipeline.dp_rs_alu_req_num);  
            // $display("rs_alu_allocable        : %1b", u_top.u_pipeline.rs_alu_allocable);   
            // $display("dp_rs_mul_req_1         : %1b", u_top.u_pipeline.dp_rs_mul_req_1);  
            // $display("dp_rs_mul_req_2         : %1b", u_top.u_pipeline.dp_rs_mul_req_2); 
            // $display("dp_rs_mul_req_num       : %1d", u_top.u_pipeline.dp_rs_mul_req_num); 
            // $display("rs_mul_allocable        : %1b", u_top.u_pipeline.rs_mul_allocable);         
        end
    endtask

    task display_if_stage;
        begin
            $display("-------------------------IF----------------------------");
            $display("if_pc               : %8h", u_top.u_pipeline.if_pc);
            $display("if_inst_1           : %8h", u_top.u_pipeline.if_inst_1);
            $display("if_inst_2           : %8h", u_top.u_pipeline.if_inst_2);
        end
    endtask

    task display_id_stage;
        begin
            $display("-------------------------ID----------------------------");
            $display("id_rs1_rd_en_1      : %b", u_top.u_pipeline.id_rs1_rd_en_1);
            $display("id_rd_wr_en_1       : %b", u_top.u_pipeline.id_rd_wr_en_1);
            $display("id_rs1_rd_addr_1    : %2d", u_top.u_pipeline.id_rs1_rd_addr_1);
            $display("id_rd_wr_addr_1     : %2d", u_top.u_pipeline.id_rd_wr_addr_1);
            display_space();    
            $display("id_rs1_rd_en_2      : %b", u_top.u_pipeline.id_rs1_rd_en_2);
            $display("id_rd_wr_en_2       : %b", u_top.u_pipeline.id_rd_wr_en_2);
            $display("id_rs1_rd_addr_2    : %2d", u_top.u_pipeline.id_rs1_rd_addr_2);
            $display("id_rd_wr_addr_2     : %2d", u_top.u_pipeline.id_rd_wr_addr_2);
        end
    endtask

    task display_dp_stage;
        begin
            $display("-------------------------DP----------------------------");
            $display("dp_vld_1                : %1b", u_top.u_pipeline.dp_vld_1);
            $display("dp_vld_2                : %1b", u_top.u_pipeline.dp_vld_2);
            // display_space();    
            // $display("dp_vld_1                : %1b", u_top.u_pipeline.u_rob.i_dp_vld_1);
            // $display("dp_ptr_1                : %2d", u_top.u_pipeline.u_rob.i_dp_ptr_1);
            // $display("dp_rd_wr_en_1           : %1b", u_top.u_pipeline.u_rob.i_dp_rd_wr_en_1);
            // $display("dp_rd_wr_addr_1         : %2d", u_top.u_pipeline.u_rob.i_dp_rd_wr_addr_1);
            // $display("dp_vld_2                : %1b", u_top.u_pipeline.u_rob.i_dp_vld_2);
            // $display("dp_ptr_2                : %2d", u_top.u_pipeline.u_rob.i_dp_ptr_2);
            // $display("dp_rd_wr_en_2           : %1b", u_top.u_pipeline.u_rob.i_dp_rd_wr_en_2);
            // $display("dp_rd_wr_addr_2         : %2d", u_top.u_pipeline.u_rob.i_dp_rd_wr_addr_2);
            // display_space();             
            // $display("rs_alu_alloc_sel_vld_1  : %1b", u_top.u_pipeline.rs_alu_alloc_sel_vld_1);
            // $display("rs_alu_alloc_sel_1      : %1b", u_top.u_pipeline.rs_alu_alloc_sel_1);         
            // $display("rs_mul_alloc_sel_vld_1  : %1b", u_top.u_pipeline.rs_mul_alloc_sel_vld_1);
            // $display("rs_mul_alloc_sel_1      : %1b", u_top.u_pipeline.rs_mul_alloc_sel_1);    
            $display("rs_ldst_alloc_sel_vld_1  : %1b", u_top.u_pipeline.rs_ldst_alloc_sel_vld_1);
            $display("rs_ldst_alloc_sel_1      : %1b", u_top.u_pipeline.rs_ldst_alloc_sel_1);       
            // $display("dp_rs1_srcopr_fwd_vld_1 : %1b", u_top.u_pipeline.dp_rs1_srcopr_fwd_vld_1);
            // $display("dp_rs2_srcopr_fwd_vld_1 : %1b", u_top.u_pipeline.dp_rs2_srcopr_fwd_vld_1);
            // $display("dp_rs1_srcopr_fwd_1     : %8h", u_top.u_pipeline.dp_rs1_srcopr_fwd_1);
            // $display("dp_rs2_srcopr_fwd_1     : %8h", u_top.u_pipeline.dp_rs2_srcopr_fwd_1); 
            // display_space();      
            // $display("rs_alu_alloc_sel_vld_2  : %1b", u_top.u_pipeline.rs_alu_alloc_sel_vld_2);
            // $display("rs_alu_alloc_sel_2      : %1b", u_top.u_pipeline.rs_alu_alloc_sel_2);
            // $display("rs_mul_alloc_sel_vld_2  : %1b", u_top.u_pipeline.rs_mul_alloc_sel_vld_2);
            // $display("rs_mul_alloc_sel_2      : %1b", u_top.u_pipeline.rs_mul_alloc_sel_2);    
            $display("rs_ldst_alloc_sel_vld_2  : %1b", u_top.u_pipeline.rs_ldst_alloc_sel_vld_2);
            $display("rs_ldst_alloc_sel_2      : %1b", u_top.u_pipeline.rs_ldst_alloc_sel_2);           
            // $display("dp_rs1_srcopr_fwd_vld_2 : %1b", u_top.u_pipeline.dp_rs1_srcopr_fwd_vld_2);
            // $display("dp_rs2_srcopr_fwd_vld_2 : %1b", u_top.u_pipeline.dp_rs2_srcopr_fwd_vld_2);
            // $display("dp_rs1_srcopr_fwd_2     : %8h", u_top.u_pipeline.dp_rs1_srcopr_fwd_2);
            // $display("dp_rs2_srcopr_fwd_2     : %8h", u_top.u_pipeline.dp_rs2_srcopr_fwd_2);  
            // display_space();    
            // $display("rs_alu_free_vec         : %2b", u_top.u_pipeline.u_rs_alu_alloc_unit.free_vec);
            // $display("rs_alu_free_vec_masked  : %2b", u_top.u_pipeline.u_rs_alu_alloc_unit.free_vec_masked);   
            // $display("rs_alu_busy_vec         : %2b", u_top.u_pipeline.rs_alu_busy_vec);
            // $display("rs_alu_vld_vec          : %2b", u_top.u_pipeline.rs_alu_vld_vec); 
            // $display("rs_mul_free_vec         : %2b", u_top.u_pipeline.u_rs_mul_alloc_unit.free_vec);
            // $display("rs_mul_free_vec_masked  : %2b", u_top.u_pipeline.u_rs_mul_alloc_unit.free_vec_masked);   
            // $display("rs_mul_busy_vec         : %2b", u_top.u_pipeline.rs_mul_busy_vec);
            // $display("rs_mul_vld_vec          : %2b", u_top.u_pipeline.rs_mul_vld_vec);  
            $display("rs_ldst_busy_vec         : %2b", u_top.u_pipeline.rs_ldst_busy_vec);
            $display("rs_ldst_vld_vec          : %2b", u_top.u_pipeline.rs_ldst_vld_vec);  
        end
    endtask

    task display_is_stage;
        begin
            $display("-------------------------IS----------------------------");
            // $display("is_rs_alu_vld     : %b", u_top.u_pipeline.is_rs_alu_vld);
            // $display("is_rs_alu_sel     : %b", u_top.u_pipeline.is_rs_alu_sel);
            // $display("is_alu_rs1_srcopr : %d", u_top.u_pipeline.is_alu_rs1_srcopr);
            // $display("is_imm            : %d", u_top.u_pipeline.is_alu_imm);     
            // $display("is_alu_rrftag     : %d", u_top.u_pipeline.is_alu_rrftag);       
            // $display("is_rs_mul_vld     : %b", u_top.u_pipeline.is_rs_mul_vld);
            // $display("is_rs_mul_sel     : %b", u_top.u_pipeline.is_rs_mul_sel);
            // $display("is_mul_signed1    : %b", u_top.u_pipeline.is_mul_signed1);
            // $display("is_mul_signed2    : %b", u_top.u_pipeline.is_mul_signed2);
            // $display("is_mul_sel_high   : %b", u_top.u_pipeline.is_mul_sel_high);
            // $display("is_mul_rs1_srcopr : %b", u_top.u_pipeline.is_mul_rs1_srcopr);
            // $display("is_mul_rs2_srcopr : %b", u_top.u_pipeline.is_mul_rs2_srcopr);   
            // $display("is_mul_rrftag     : %d", u_top.u_pipeline.is_mul_rrftag);            
            $display("is_rs_ldst_vld     : %b", u_top.u_pipeline.is_rs_ldst_vld);
            $display("is_rs_ldst_sel     : %b", u_top.u_pipeline.is_rs_ldst_sel);
            $display("is_ldst_rs1_srcopr : %d", u_top.u_pipeline.is_ldst_rs1_srcopr);
            $display("is_ldst_rs2_srcopr : %d", u_top.u_pipeline.is_ldst_rs2_srcopr);
            $display("is_imm             : %d", u_top.u_pipeline.is_ldst_imm);                    
        end
    endtask

    task display_ex_stage;
        begin
            $display("-------------------------EX----------------------------");
            // $display("op_sel            : %d", u_top.u_pipeline.u_exunit_alu.i_op_sel);    
            // $display("src1              : %d", u_top.u_pipeline.u_exunit_alu.src1);
            // $display("src2              : %d", u_top.u_pipeline.u_exunit_alu.src2);
            // $display("ex_alu_rrftag     : %d", u_top.u_pipeline.ex_alu_rrftag);
            // $display("exfin_alu         : %b", u_top.u_pipeline.exfin_alu);
            // $display("exfin_alu_res     : %d", u_top.u_pipeline.exfin_alu_res);
            // $display("signed1           : %b", u_top.u_pipeline.u_exunit_mul.i_signed1);    
            // $display("signed2           : %b", u_top.u_pipeline.u_exunit_mul.i_signed2);    
            // $display("sel_high          : %b", u_top.u_pipeline.u_exunit_mul.i_sel_high);    
            // $display("src1              : %b", u_top.u_pipeline.u_exunit_mul.i_src1);
            // $display("src2              : %b", u_top.u_pipeline.u_exunit_mul.i_src2);
            // $display("ex_mul_rrftag     : %d", u_top.u_pipeline.ex_mul_rrftag);
            // $display("exfin_mul         : %b", u_top.u_pipeline.exfin_mul);
            // $display("exfin_mul_res     : %b", u_top.u_pipeline.exfin_mul_res);
            $display("stbuf_addr_hit_sel : %d", u_top.u_pipeline.u_stbuf.stbuf_addr_hit_sel);
            $display("stbuf_addr_hit     : %b", u_top.u_pipeline.stbuf_addr_hit);
            $display("stbuf_rd_data      : %d", u_top.u_pipeline.stbuf_rd_data);
            $display("ex_ld_rrftag       : %d", u_top.u_pipeline.ex_ld_rrftag);
            $display("exfin_ld           : %b", u_top.u_pipeline.exfin_ld);
            $display("exfin_ld_res       : %d", u_top.u_pipeline.exfin_ld_res);
            $display("exfin_st           : %b", u_top.u_pipeline.exfin_st);
            $display("exfin_st_addr      : %d", u_top.u_pipeline.exfin_st_addr);
            $display("exfin_st_data      : %h", u_top.u_pipeline.exfin_st_data);         
        end
    endtask    

    task display_interact_dmem;
        begin
            $display("----------------------IO/DMEM---------------------------");
            $display("dmem_occupy            : %b", u_top.u_pipeline.dmem_occupy);            
            $display("dmem_addr              : %d", u_top.u_pipeline.o_dmem_addr);    
            $display("dmem_rd_data           : %d", u_top.u_pipeline.i_dmem_rd_data);             
            $display("dmem_wr_en             : %b", u_top.u_pipeline.o_dmem_wr_en);
            $display("dmem_wr_data           : %d", u_top.u_pipeline.o_dmem_wr_data);
        end
    endtask

    task display_com_stage;
        begin
            $display("-------------------------COM----------------------------");
            $display("com_ptr          : %2d", u_top.u_pipeline.u_rob.com_ptr);
            $display("com_vld_1        : %b", u_top.u_pipeline.com_vld_1);
            $display("com_rd_wr_en_1   : %b", u_top.u_pipeline.com_rd_wr_en_1);
            $display("com_rd_wr_addr_1 : %d", u_top.u_pipeline.com_rd_wr_addr_1);
            $display("com_rd_wr_data_1 : %d", u_top.u_pipeline.com_rd_wr_data_1);
            $display("com_stbuf        : %b", u_top.u_pipeline.com_stbuf);            
        end
    endtask   

    task display_dmem;
        begin
            $display("------------------------DMEM----------------------------");
            $display("mem[1]           : %h", u_top.u_dmem.mem[1]);
        end
    endtask  

    task display_stbuf;
        begin
            $display("-----------------STBUF---------------------"); 
            for(i = 0; i < 32 ; i = i + 1)begin
                $display("STBUF[%2d] : %h", i, u_top.u_pipeline.u_stbuf.data[i]);
            end
        end
    endtask 

endmodule

`default_nettype wire
