//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        2010/8/16
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	func_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	//***************************************************
	branchType_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;
input  [6-1:0] func_i;

output         RegWrite_o;
output [4-1:0] ALU_op_o;
output [1:0]   ALUSrc_o;
output [1:0]   RegDst_o;
output         Branch_o;

/***DADA***/
output reg [2-1:0]	branchType_o;



output reg [1:0]	Jump_o;
output reg	MemRead_o;
output reg	MemWrite_o;
output reg [1:0]	MemtoReg_o;
 
//Internal Signals
reg    [4-1:0] ALU_op_o;
reg    [1:0]   ALUSrc_o;
reg            RegWrite_o;
reg    [1:0]   RegDst_o;
reg            Branch_o;


initial  begin
	Branch_o = 0;
end

//Parameter


//Main function

always@(*)begin
	case(instr_op_i)
		6'b000000:begin			//R-type including the MULTIPLICATION
			case(func_i)
				6'b101010:ALU_op_o <= 4'b1111;
				default:ALU_op_o <= 4'b0010;
			endcase
        end
		6'b001000:begin			//ADDI			
			ALU_op_o <= 4'b0100;
	    end
		6'b001101:begin			//ORI
		    ALU_op_o <= 4'b0101;
        end
		6'b000100:begin			//BEQ
		    ALU_op_o <= 4'b0001;
        end
		6'b100011:begin			//lw
		    ALU_op_o <= 4'b0000;
        end		
	
		6'b101011:begin			//sw
		    ALU_op_o <= 4'b0000;
        end
		6'b000010:begin			//jump
		    ALU_op_o <= 4'b0000;	//or X
        end
		
		//branch
		6'b000111:begin			//bgt
		    ALU_op_o <= 4'b1011;	
        end
		6'b000101:begin			//bnez
		    ALU_op_o <= 4'b1010;	
        end
		6'b000001:begin			//bgez
		    ALU_op_o <= 4'b1001;		
        end
		
		//lui
		6'b001111:begin	
		    ALU_op_o <= 4'b1000;		
        end
	endcase
end

always@(*)begin
	case(instr_op_i)
		6'b000000: ALUSrc_o <= 2'b00;
		6'b001000: ALUSrc_o <= 2'b01;
		6'b001101: ALUSrc_o <= 2'b10; //zero extension
		6'b000100: ALUSrc_o <= 2'b00;
		6'b100011: ALUSrc_o <= 2'b01;
		6'b101011: ALUSrc_o <= 2'b01;
		6'b000010: ALUSrc_o <= 2'b00;	//or X
		//branch
		6'b000111: ALUSrc_o <= 2'b00;  //bgt = branch greater than
		6'b000101: ALUSrc_o <= 2'b00;   //bnez = branch non equal zero
		6'b000001: ALUSrc_o <= 2'b00;   //bgez = branch greater equal zero
		6'b000100: ALUSrc_o <= 2'b00;  //beq = branch equal
		//lui
		6'b001111: ALUSrc_o <= 2'b10; //zero
	endcase
end

always@(*)begin
	case(instr_op_i)
		6'b000000:begin
			if(func_i == 6'b001000)
				RegWrite_o <= 0;
			else 
				RegWrite_o <= 1;
		end
		6'b001000:RegWrite_o <= 1;
		6'b001101:RegWrite_o <= 1;
		6'b000100:RegWrite_o <= 0;
		6'b100011:RegWrite_o <= 1;
		6'b101011:RegWrite_o <= 0;
		6'b000010:RegWrite_o <= 0;	
		//lui
		6'b001111: RegWrite_o <= 1;
		//jal
		6'b000011: RegWrite_o <= 1;
		default: RegWrite_o <= 0;	
		
	endcase
end
always@(*)begin
	case(instr_op_i)
		6'b000000:RegDst_o <= 1;
		6'b001000:RegDst_o <= 0;
		6'b001101:RegDst_o <= 0;
		6'b000100:RegDst_o <= 0;
		6'b100011:RegDst_o <= 0;
		6'b101011:RegDst_o <= 0;		//or X
		6'b000010:RegDst_o <= 0;		//or X
		//lui
		6'b001111: RegDst_o <= 0;
		//jal
		6'b000011:RegDst_o <= 2;	
	endcase
end
always@(*)begin
	case(instr_op_i)
		6'b000000:Branch_o <= 0;
		6'b001000:Branch_o <= 0;
		6'b001101:Branch_o <= 0;
		6'b000100:Branch_o <= 1;
		6'b100011:Branch_o <= 0;
		6'b101011:Branch_o <= 0;
		6'b000010:Branch_o <= 0;
		6'b000111:Branch_o <= 1;  //bgt = branch greater than
		6'b000101:Branch_o <= 1;  //bnez = branch non equal zero
		6'b000001:Branch_o <= 1;  //bgez = branch greater equal zero
		6'b000100:Branch_o <= 1;  //beq = branch equal
		//lui
		6'b001111: Branch_o <= 0;
	endcase
end

/***DADA: branchType***/
always@(*)begin
	case(instr_op_i)
		6'b000111:branchType_o <=3;  //bgt = branch greater than
		6'b000101:branchType_o <=2;  //bnez = branch non equal zero
		6'b000001:branchType_o <=1;  //bgez = branch greater equal zero
		6'b000100:branchType_o <=0;  //beq = branch equal
	endcase
end



always@(*)begin
	case(instr_op_i)
		6'b000010:Jump_o <= 1;
		//jal
		6'b000011:Jump_o <= 1;
		//jr
		6'b000000:begin
			if(func_i == 6'b001000)
				Jump_o <= 2;
			else 
				Jump_o <= 0;
		end
		default: Jump_o <= 0;
	endcase
end
always@(*)begin
	case(instr_op_i)
		6'b000000:MemRead_o <= 0;
		6'b001000:MemRead_o <= 0;
		6'b001101:MemRead_o <= 0;
		6'b000100:MemRead_o <= 0;
		6'b100011:MemRead_o <= 1;
		6'b101011:MemRead_o <= 0;
		6'b000010:MemRead_o <= 0;
		default: MemRead_o <= 0;
	endcase
end
always@(*)begin
	case(instr_op_i)
		6'b000000:MemWrite_o <= 0;
		6'b001000:MemWrite_o <= 0;
		6'b001101:MemWrite_o <= 0;
		6'b000100:MemWrite_o <= 0;
		6'b100011:MemWrite_o <= 0;	
		6'b101011:MemWrite_o <= 1;
		6'b000010:MemWrite_o <= 0;
		default: MemWrite_o <= 0;
	endcase
end
always@(*)begin
	case(instr_op_i)
		6'b000000:MemtoReg_o	<= 0;		
		6'b001000:MemtoReg_o	<= 0;		
		6'b001101:MemtoReg_o	<= 0;		
		6'b000100:MemtoReg_o	<= 0;		
		6'b100011:MemtoReg_o	<= 1;			
		6'b101011:MemtoReg_o	<= 0;    //or X	
		6'b000010:MemtoReg_o	<= 0;
		
		//lui
		6'b001111:MemtoReg_o <= 0;
		
		//jal
		6'b000011:MemtoReg_o	<= 2;
	endcase
end



endmodule





                    
                    