# Makefile for test

# Path
CORE_DIR = ../rtl/core
SOC_DIR  = ../rtl/soc
SIM_DIR  = .

# OBJS for rtl files, OBJ for testbench files
OBJS = \
$(CORE_DIR)/alloc_issue_disorder.v \
$(CORE_DIR)/alloc_issue_order.v \
$(CORE_DIR)/alloc_unit.v \
$(CORE_DIR)/alu.v \
$(CORE_DIR)/arf.v \
$(CORE_DIR)/decoder.v \
$(CORE_DIR)/dmem.v \
$(CORE_DIR)/exunit_alu.v \
$(CORE_DIR)/exunit_ldst.v \
$(CORE_DIR)/exunit_mul.v \
$(CORE_DIR)/freelist_manager.v \
$(CORE_DIR)/imem.v \
$(CORE_DIR)/imm_gen.v \
$(CORE_DIR)/inst_sel_unit.v \
$(CORE_DIR)/issue_unit.v \
$(CORE_DIR)/ldst.v \
$(CORE_DIR)/mul.v \
$(CORE_DIR)/pc_reg.v \
$(CORE_DIR)/pipeline.v \
$(CORE_DIR)/regfile.v \
$(CORE_DIR)/renaming_table.v \
$(CORE_DIR)/req_arbiter.v \
$(CORE_DIR)/req_mask.v \
$(CORE_DIR)/rob.v \
$(CORE_DIR)/rrf.v \
$(CORE_DIR)/rs_alu_ent.v \
$(CORE_DIR)/rs_alu.v \
$(CORE_DIR)/rs_ldst_ent.v \
$(CORE_DIR)/rs_ldst.v \
$(CORE_DIR)/rs_mul_ent.v \
$(CORE_DIR)/rs_mul.v \
$(CORE_DIR)/rs_req_manager.v \
$(CORE_DIR)/search_unit.v \
$(CORE_DIR)/src_sel_unit.v \
$(CORE_DIR)/srcopr_fwd_unit.v \
$(CORE_DIR)/srcopr_sel_unit.v \
$(CORE_DIR)/stbuf.v \
$(SOC_DIR)/top.v

OBJ = $(SIM_DIR)/top_tb.v

# Parameters
VVP_NAME  = top_tb.vvp

# Clean files
CLEAN_FILES = \
$(SIM_DIR)/simv \
$(SIM_DIR)/*Log \
$(SIM_DIR)/*.daidir \
$(SIM_DIR)/*.conf \
$(SIM_DIR)/*.rc \
$(SIM_DIR)/*.vvp \
$(SIM_DIR)/*.vcd \
$(SIM_DIR)/*.fsdb

# Dependencies
run_vcs: $(OBJS) $(OBJ)
	@echo ""
	@echo "***********************************************************"
	@echo "                     vcs compiling...                      "
	@echo "***********************************************************"
	@echo ""
	vcs -full64 -v2005 -debug_pp -sverilog -fsdb +define+FSDB $(OBJS) $(OBJ) -o $(VVP_NAME)

run_vvp: $(VVP_NAME)
	@echo ""
	@echo "***********************************************************"
	@echo "                      vvp running...                       "
	@echo "***********************************************************"
	@echo ""
	./$(VVP_NAME)

clean:
	@echo ""
	@echo "***********************************************************"
	@echo "                     clean running...                      "
	@echo "***********************************************************"
	@echo ""
	rm -rf $(CLEAN_FILES)

help:
	@echo "Available targets:"
	@echo "  run_vcs : Build the VVP executable"
	@echo "  run_vvp : Run the VVP executable"
	@echo "  clean   : Remove generated files"
