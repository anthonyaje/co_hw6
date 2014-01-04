//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o,
		  bonus_control_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [4-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
output		[3-1:0] bonus_control_o;     
	
//Internal Signals
reg        [4-1:0] ALUCtrl_o;
reg		 [3-1:0] bonus_control_o;   
//Parameter


//Select exact operation
	
always@(*)begin
	if(ALUOp_i[3]==0)begin
		if(ALUOp_i[2]==0)begin
			case(ALUOp_i[1])
				0:begin
					case(ALUOp_i[0])
						0:begin
							ALUCtrl_o <= 4'b0010; 	//ALUop 000 -> lw /sw
						end
						1:begin
							ALUCtrl_o <= 4'b0110;	// ALUop 001: BEQ
						end
					endcase
				end
				1:begin
					if(funct_i[3:0]==4'b0010)begin
						ALUCtrl_o <= 4'b0110; 		//R-type Substract
					end
					else if(funct_i[3:0]==4'b1010)begin
						ALUCtrl_o <= 4'b0111; 		//Set Less Than
					end
					else if(ALUOp_i[0]==0)begin
						case(funct_i[5:0])
							6'b100000:begin
								ALUCtrl_o <= 4'b0010; //Rtype ADD
							end
							6'b100100:begin
								ALUCtrl_o <= 4'b0000; //Rtype AND
							end
							6'b100101:begin
								ALUCtrl_o <= 4'b0001;	//Rtype OR
							end
							6'b011000:begin
								ALUCtrl_o <= 4'b1000;	//Rtypt MUL ALU input set to 1000
							end
						endcase
					end
				end
			endcase 
		end
		else if(ALUOp_i[2]==1)begin
			if(ALUOp_i == 3'b100)begin				// 1xx means I-type;  100 is assigned for ADDI, then give AND ALUcntrl to AL
				ALUCtrl_o <= 4'b0010;
			end	
			else if(ALUOp_i == 3'b101)begin
				ALUCtrl_o <= 4'b0001;				// 001 for ORI, then give OR ALU_control to ALU
			end
		end
	end
	
	else begin
		case(ALUOp_i)
			4'b1011: ALUCtrl_o <= 4'd7;  //sgt
			4'b1010: ALUCtrl_o <= 4'd7;  //neq
			4'b1111: ALUCtrl_o <= 4'd7;
			4'b1001: ALUCtrl_o <= 4'd7;  ////greater than or equal to src2-1
			4'b1000: ALUCtrl_o <= 4'd2;  ////greater than or equal to src2-1
			default: ALUCtrl_o <= 4'b1111; //debug
		endcase
	end
end
       
	   
always@(*)begin
	case(ALUOp_i)
		//4'
		4'b1011: bonus_control_o <= 3'b001;  //sgt
		4'b1010: bonus_control_o <= 3'b100;  //neq
		4'b1001: bonus_control_o <= 3'b101;  ////greater than or equal to src2-1
		4'b1111: bonus_control_o <= 3'b000;
	endcase
end

endmodule     





                    
                    