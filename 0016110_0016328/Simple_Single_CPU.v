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
module Simple_Single_CPU(
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
wire [32-1:0] adder1_o;
wire [32-1:0] adder2_o;
wire [32-1:0] inst_o;
wire [32-1:0] write_data;
wire [32-1:0] RSdata_o;
wire [32-1:0] RTdata_o;
wire [32-1:0] SE_data;
wire [32-1:0] SE_data_shift;
wire [32-1:0] ALU_in2;
wire [32-1:0] ALU_res;
wire [32-1:0] memData;
wire [32-1:0] Reg_Write_Data;
wire [32-1:0] jump_address;
wire [32-1:0] pc_mux;

wire [4-1:0] ALUCtrl;

wire [5-1:0] write_reg;

wire  [1:0]reg_des;
wire  reg_write;
wire  [4-1:0] alu_op;
wire  mem_write;
wire  [1:0] alu_src;
wire  branch;
wire  zero_flag;
wire  cout_flag;
wire  overflow_flag;
wire  select_adder2;
wire [2:0] bonus;
wire [2-1:0]branchType;
wire [1:0]jump;
wire memRead;
wire memWrite;
wire [1:0] memToReg;
wire [27:0] temp_jump_add;

wire [31:0] zero_ex;
assign zero_ex = {16'd0, inst_o[15:0]};
assign select_adder2 = (branchType==0)?(branch&zero_flag):(branch&ALU_res[0]);
assign tem_jump_wire = jump_address[27:0];
assign jump_address = {adder1_o[31:28],temp_jump_add};

//Create components
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_n (rst_n),     
	    .pc_in_i(pc_source) ,   
	    .pc_out_o(pc_output) 
	    );
	
Adder Adder1(
        .src1_i(four),     
	    .src2_i(pc_output),     
	    .sum_o(adder1_o)    
	    );
//*****************************************
Shift_Left_Two_28 Shifter_jump(
        .data_i(inst_o[25:0]),
        .data_o(jump_address[27:0])
        ); 		

MUX_3to1 #(.size(32)) Mux_PC_JUMP(
        .data0_i(pc_mux),
        .data1_i(jump_address),
        .data2_i(RSdata_o),
        .select_i(jump),
        .data_o(pc_source)
        );	
//#########################################
	
Instr_Memory IM(
        .pc_addr_i(pc_output),  
	    .instr_o(inst_o)    
	    );

MUX_3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(inst_o[20:16]),
        .data1_i(inst_o[15:11]),
		.data2_i(5'd31),
        .select_i(reg_des),
        .data_o(write_reg)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(inst_o[25:21]) ,  
        .RTaddr_i(inst_o[20:16]) ,  
        .RDaddr_i(write_reg) ,  
        .RDdata_i(Reg_Write_Data)  , 
        .RegWrite_i(reg_write),
        .RSdata_o(RSdata_o) ,  
        .RTdata_o(RTdata_o)   
        );
//*****************************************************	
Decoder Decoder(
        .instr_op_i(inst_o[31:26]), 
		.func_i(inst_o[5:0]),
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
//######################################################
ALU_Ctrl AC(
        .funct_i(inst_o[5:0]),   
        .ALUOp_i(alu_op),   
        .ALUCtrl_o(ALUCtrl),
		.bonus_control_o(bonus)
        );
	
Sign_Extend SE(
        .data_i(inst_o[15:0]),
        .data_o(SE_data)
        );

MUX_3to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata_o),
        .data1_i(SE_data),
        .data2_i(zero_ex),
        .select_i(alu_src),
        .data_o(ALU_in2)
        );	
		
alu ALU(
		.rst_n(rst_n),
        .src1(RSdata_o),
	    .src2(ALU_in2),
	    .ALU_control(ALUCtrl),
		.bonus_control(bonus),
	    .result(ALU_res),
		.zero(zero_flag),
		.cout(cout_flag),
		.overflow(overflow_flag)
	    );		
//********************************************************//add module Data Memory
Data_Memory DM(
	.clk_i(clk_i),
	.addr_i(ALU_res),
	.data_i(RTdata_o),
	.MemRead_i(memRead),
	.MemWrite_i(memWrite),
	.data_o(memData)
);

MUX_3to1 #(.size(32)) Mux_Data_Mem(
        .data0_i(ALU_res),
        .data1_i(memData),
		.data2_i(adder1_o),
        .select_i(memToReg),
        .data_o(Reg_Write_Data)
        );	

//##########################################################

Adder Adder2(
        .src1_i(adder1_o),     
	    .src2_i(SE_data_shift),     
	    .sum_o(adder2_o)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(SE_data),
        .data_o(SE_data_shift)
        ); 		

	
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(adder1_o),
        .data1_i(adder2_o),
        .select_i(select_adder2),
        .data_o(pc_mux)
        );	

endmodule
		  


