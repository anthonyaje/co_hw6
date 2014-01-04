//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
        clk_i,
		rst_n
		);
		
//I/O port
input         clk_i;
input         rst_n;

//Internal Signals 
wire [32-1:0] pc_source;
wire [32-1:0] pc_output;
wire [32-1:0] four = 32'd4;
wire [32-1:0] adder1_o, adder1_oo,adder1_ooo;
wire [32-1:0] inst_o, inst_oo, inst_ooo;
wire [32-1:0] adder2_o,adder2_oo;
wire [32-1:0] write_data;
wire [32-1:0] RSdata_o,RSdata_oo;
wire [32-1:0] RTdata_o,RTdata_oo,RTdata_ooo;
wire [32-1:0] SE_data, SE_data_oo;
wire [32-1:0] SE_data_shift;
wire [32-1:0] ALU_in2;
wire [32-1:0] ALU_res, ALU_res_oo, ALU_res_ooo;
wire [32-1:0] memData,memData_oo;
wire [32-1:0] Reg_Write_Data;
wire [32-1:0] jump_address,jump_address_oo,jump_address_ooo,jump_address_oooo;
wire [32-1:0] pc_mux;


wire [5-1:0] rw_mux_in1, rw_mux_in2; 
wire  [1:0] reg_des, reg_des_oo;
wire  reg_write, reg_write_oo, reg_write_ooo, reg_write_oo_f;
wire  [4-1:0] alu_op, alu_op_oo;
wire  [1:0] alu_src, alu_src_oo;
wire [2-1:0]branchType, branchType_oo;
wire [1:0]jump, jump_oo;
wire memRead, memRead_oo, memRead_ooo;
wire memWrite, memWrite_oo, memWrite_ooo, memWrite_oo_f;
wire [1:0] memToReg, memToReg_oo, memToReg_ooo, memToReg_oooo;
wire  branch, branch_oo, branch_ooo;


wire [4-1:0] ALUCtrl;
wire [5-1:0] write_reg,write_reg_oo,write_reg_ooo,write_reg_oooo;
wire  zero_flag, zero_flag_oo;
wire  cout_flag;
wire  overflow_flag;
wire  select_adder2;
wire [2:0] bonus;
wire [27:0] temp_jump_wire;
wire [31:0] zero_ex, zero_ex_oo;

wire [4:0] rs_oo;
wire [1:0] fw1_control;
wire [1:0] fw2_control;
wire [31:0] fw_alu_in1;
wire [31:0] fw_alu_in2;
wire [1:0] flush_mux_ifid;
wire [31:0] mux_inst_o;
wire branch_alu_res,branch_alu_res_oo;
wire branch_flush_signal;
wire detection_signal;
wire [31:0] inst_oo_temp;

wire [31:0] fw_mux_input;
wire [1:0] store_mux_select;
wire [32-1:0] store_value_mux_o;
wire [32-1:0] mux_adder1_o;

assign branch_flush_signal = (branch_alu_res_oo & branch_ooo) | jump_oo[1] | jump_oo[0];
assign flush_mux_ifid = { detection_signal, branch_flush_signal };
assign zero_ex = {16'd0, inst_o[15:0]};

MUX_3to1 #(.size(32)) Mux_PC_JUMP(
        .data0_i(pc_mux),
        .data1_i(jump_address),
        .data2_i(fw_alu_in1),		//FIX ME: jr instruction 
        .select_i(jump_oo),
        .data_o(pc_source)
       );	
	
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(adder1_o),	//pc+4
        .data1_i(adder2_oo),	//pc+4+signed-extended immediate value
        .select_i(branch_flush_signal),
        .data_o(pc_mux)
        );	
		
		
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_n (rst_n),     
	    .pc_in_i(pc_source),
		.pc_load_control(detection_signal),
	    .pc_out_o(pc_output) 
	    );
	
Adder Adder1(
        .src1_i(four),     
	    .src2_i(pc_output),     
	    .sum_o(adder1_o)    
	    );

	
Instr_Memory IM(
        .pc_addr_i(pc_output),  
	    .instr_o(inst_o)    
	    );		

		
MUX_3to1 #(.size(32)) Mux_adder1_o(
        .data0_i(adder1_o),
        .data1_i(32'd0),
        .data2_i(adder1_oo),
        .select_i(flush_mux_ifid),
        .data_o(mux_adder1_o)
        );	
		
Pipe_Reg #(.size(32)) IF_ID_1(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i(mux_adder1_o),
		.data_o(adder1_oo)
		);
	
MUX_3to1 #(.size(32)) Mux_Pipe_Reg_IFID(
        .data0_i(inst_o),
        .data1_i(32'd0),
        .data2_i(inst_oo_temp),
        .select_i(flush_mux_ifid),
        .data_o(mux_inst_o)
        );	
		
Pipe_Reg #(.size(32)) IF_ID_2(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i(mux_inst_o),
		.data_o(inst_oo_temp)
		);
//~~~~~~~~~~~~~~~IF/ID~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
			
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(inst_oo[25:21]) ,  
        .RTaddr_i(inst_oo[20:16]) ,  
        .RDaddr_i(write_reg_ooo) ,  
        .RDdata_i(Reg_Write_Data)  , 
        .RegWrite_i(reg_write_oooo),
        .RSdata_o(RSdata_o),  
        .RTdata_o(RTdata_o)   
        );
		
		
		
DetectionUnit detectionUnit(
		   .mem_read(memRead_oo),       
           .idex_rt(rw_mux_in1),
		   .ifid_rs(inst_oo_temp[25:21]),
		   .ifid_rt(inst_oo_temp[20:16]),
		   .instruction(inst_oo_temp),
		   .branch_signal(branch_alu_res_oo),
		   .jump_jr(jump_oo),
		   
		   .instruction_o(inst_oo),
		   .out(detection_signal)
		);

Adder Adder2(
        .src1_i(adder1_ooo),     
	    .src2_i(SE_data_shift),     
	    .sum_o(adder2_o)      
	    );
	

/*
Shift_Left_Two_28 Shifter_jump(
        .data_i(inst_oo[25:0]),
        .data_o(jump_address[27:0])
        ); 
*/

Shift_Left_Two_28 Shifter_jump(
        .data_i(inst_oo[25:0]),
		.data_i2(adder1_oo[31:28]),
        .data_o(jump_address)
        );
				
	
//MUX_2to1 #(.size(32)) Mux_Instruction(
//        .data0_i(inst_oo_temp),
//        .data1_i(32'd0),	// TODO
//        .select_i(detection_signal),
//        .data_o(inst_oo)
//        );	
		
						
				
Decoder Decoder(
        .instr_op_i(inst_oo[31:26]), 
		.func_i(inst_oo[5:0]),
	    .RegWrite_o(reg_write), 
	    .ALU_op_o(alu_op),   
	    .ALUSrc_o(alu_src),   
	    .RegDst_o(reg_des),   
		.Branch_o(branch),
		.branchType_o(branchType),
		.Jump_o(jump),
		.MemRead_o(memRead),
		.MemWrite_o(memWrite),
		.MemtoReg_o(memToReg)
	    );
		
Sign_Extend SE(
        .data_i(inst_oo[15:0]),
        .data_o(SE_data)
        );

Pipe_Reg #(.size(18)) ID_EX_1(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i({reg_write,alu_op,alu_src,reg_des,branch,branchType,jump,memRead,memWrite,memToReg}),
		.data_o({reg_write_oo,alu_op_oo,alu_src_oo,reg_des_oo,branch_oo,branchType_oo,jump_oo,memRead_oo,memWrite_oo,memToReg_oo})
		);

Pipe_Reg #(.size(96)) ID_EX_2(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i({adder1_oo,RSdata_o,RTdata_o}),
		.data_o({adder1_ooo,RSdata_oo,RTdata_oo})
		);

Pipe_Reg #(.size(74)) ID_EX_3(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i({SE_data, inst_oo[20:16], inst_oo[15:11], zero_ex}),
	.data_o({SE_data_oo, rw_mux_in1, rw_mux_in2, zero_ex_oo })
	);
		
Pipe_Reg #(.size(32)) ID_EX_4(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i(jump_address),
		.data_o(jump_address_oo)
		);
		
Pipe_Reg #(.size(5)) ID_EX_5(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i(inst_oo[25:21]),
		.data_o(rs_oo)
		);
		
Pipe_Reg #(.size(32)) ID_EX_6(       //N is the total length of input/output
		.rst_i(rst_n),
		.clk_i(clk_i),   
		.data_i(inst_oo),
		.data_o(inst_ooo)
		);
		
//~~~~~~~~~~~~~~~~~~ID/EX~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		

BranchAlu branchAlu(
		.src1(fw_alu_in1),
		.src2(ALU_in2),
		.opcode(inst_ooo[31:26]),
		.result(branch_alu_res)
		);

Shift_Left_Two_32 Shifter(
        .data_i(SE_data_oo),
        .data_o(SE_data_shift)
        ); 

alu ALU(
		.rst_n(rst_n),
        .src1(fw_alu_in1),
	    .src2(ALU_in2),
	    .ALU_control(ALUCtrl),
		.bonus_control(bonus),
	    .result(ALU_res),
		.zero(zero_flag),
		.cout(cout_flag),
		.overflow(overflow_flag)
	    );		

MUX_3to1 #(.size(32)) Mux_fw1(
        .data0_i(RSdata_oo),
        .data1_i(fw_mux_input),
        .data2_i(Reg_Write_Data),
        .select_i(fw1_control),
        .data_o(fw_alu_in1)
        );
		
MUX_3to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(fw_alu_in2),
        .data1_i(SE_data_oo),
        .data2_i(zero_ex_oo),
        .select_i(alu_src_oo),
        .data_o(ALU_in2)
        );
		
MUX_3to1 #(.size(32)) Mux_fw2(
        .data0_i(RTdata_oo),
        .data1_i(fw_mux_input),
        .data2_i(Reg_Write_Data),
        .select_i(fw2_control),
        .data_o(fw_alu_in2)
        );
		
ALU_Ctrl AC(
		.funct_i(SE_data_oo[5:0]),   
		.ALUOp_i(alu_op_oo),   
		.ALUCtrl_o(ALUCtrl),
		.bonus_control_o(bonus)
	);
	
MUX_3to1 #(.size(5)) Mux_Write_Reg(
		.data0_i(rw_mux_in1),
		.data1_i(rw_mux_in2),
		.data2_i(5'd31),
		.select_i(reg_des_oo),
		.data_o(write_reg)
);

//flush reg_write_oo
MUX_2to1 #(.size(1)) Mux_flush_reg_write_oo(
        .data0_i(reg_write_oo),
        .data1_i(1'd0),
        .select_i(branch_flush_signal),
        .data_o(reg_write_oo_f)
        );
	
//flush memWrite_oo
MUX_2to1 #(.size(1)) Mux_flush_memWrite_oo(
        .data0_i(memWrite_oo),
        .data1_i(1'd0),
        .select_i(branch_flush_signal),
        .data_o(memWrite_oo_f)
        );

Pipe_Reg #(.size(38)) EX_MEM_1(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i({reg_write_oo_f, memRead_oo, memWrite_oo_f, branch_oo, memToReg_oo, adder2_o}),
	.data_o({reg_write_ooo, memRead_ooo, memWrite_ooo, branch_ooo, memToReg_ooo, adder2_oo})
);
	
Pipe_Reg #(.size(33)) EX_MEM_2(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i({zero_flag,ALU_res}),
	.data_o({zero_flag_oo,ALU_res_oo})
	);
	
Pipe_Reg #(.size(37)) EX_MEM_3(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i({store_value_mux_o,write_reg}),
	.data_o({RTdata_ooo,write_reg_oo})
	);

//for branch condition	
Pipe_Reg #(.size(1)) EX_MEM_4(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i(branch_alu_res),
	.data_o(branch_alu_res_oo)
	);

ForwardingUnit fdunit (
   .exmem_rd_i(write_reg_oo),
   .exmem_rw_i(reg_write_ooo),
   .memwb_rd_i(write_reg_ooo),
   .memwb_rw_i(reg_write_oooo),
   .write_to_memory_i(memWrite_oo),
   
   .idex_rs_i(rs_oo),
   .idex_rt_i(rw_mux_in1),
   .forward1_o(fw1_control),
   .forward2_o(fw2_control),
   .mux_control_o(store_mux_select)
   
);

MUX_3to1 #(.size(32)) Mux_Store_Reg(
		.data0_i(RTdata_oo),
		.data1_i(ALU_res_oo),
		.data2_i(Reg_Write_Data),
		.select_i(store_mux_select),
		.data_o(store_value_mux_o)
);



/********************************************EX/MEM**********************************************************/
MUX_2to1 #(.size(32)) Mux_memory_select(
		.data0_i(ALU_res_oo),
		.data1_i(memData),
		.select_i(memRead_ooo),
		.data_o(fw_mux_input)
);

Data_Memory DM(
	.clk_i(clk_i),
	.addr_i(ALU_res_oo),
	.data_i(RTdata_ooo),
	.MemRead_i(memRead_ooo),
	.MemWrite_i(memWrite_ooo),
	.data_o(memData)
);

Pipe_Reg #(.size(72)) MEM_WB_1(       //N is the total length of input/output
	.rst_i(rst_n),
	.clk_i(clk_i),   
	.data_i({memData, memToReg_ooo, reg_write_ooo, write_reg_oo,ALU_res_oo}),
	.data_o({memData_oo, memToReg_oooo,reg_write_oooo, write_reg_ooo, ALU_res_ooo})  
);


//*********************************************************************************************

MUX_3to1 #(.size(32)) Mux_Data_Mem(
        .data0_i(ALU_res_ooo),
        .data1_i(memData_oo),
		.data2_i(adder1_o),	//FIX ME: jal instruction 
        .select_i(memToReg_oooo),
        .data_o(Reg_Write_Data)
        );	

endmodule
		  


  