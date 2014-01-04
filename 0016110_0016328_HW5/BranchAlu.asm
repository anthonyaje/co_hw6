`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NCTU
// Engineer: 0016328, CHIANG Chen-Hao
//
// Create Date:    15:15:11 08/18/2010
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module alu(
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
		   bonus_control, // 3 bits bonus control input(input) 
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );


input           rst_n;
input signed[32-1:0] src1;
input signed[32-1:0] src2;
input   [4-1:0] ALU_control;
input   [3-1:0] bonus_control; 

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;

reg    [32-1:0] result;
reg             zero;
reg             cout;
reg             overflow;

reg  [31:0]result1;
reg [31:0]s1,s2;

always@(*)begin
	case(ALU_control)
		8:begin
			result <= src1 * src2;
		end
		0:begin
			result <= src1 & src2;
		end
		1:begin
			result <= src1 | src2;
		end
		2:begin
			result <= src1 + src2;
		end
		6:begin
			result <= src1 - src2;
		end
		12:begin
			result <= ~(src1 & src2);
		end
		13:begin
			result <= ~(src1 & src2);
		end
		7:begin
			case(bonus_control)
				3'b000:begin
					result <= (src1<src2)?1:0;
				end
				3'b001:begin //sgt
					result <= (src1>src2)?1:0;
				end
				3'b010:begin 
					result <= (src1<=src2)?1:0;
				end
				3'b011:begin //ge
					result <= (src1>=src2)?1:0;
				end
				3'b110:begin //eq
					result <= (src1==src2)?1:0;
				end
				3'b100:begin //neq
					result <= (src1!=src2)?1:0;
				end
				3'b101:begin //greater than or equal to src2-1
					result <= (src1>=(src2-1))?1:0;
				end
			endcase
		end
	endcase
end

always@(*)begin
	if(result==0)begin
		zero <= 1;
	end
	else begin
		zero <= 0;
	end
end


always@(*)begin
	case(ALU_control)
		2:begin
			//addition
			{cout,result1} <= s1 + s2;
		end
		6:begin
			//subtraction
			{cout,result1} <= s1 - s2 ;
		end
		
		default:begin
			cout <= 0;
		end
		
	endcase
end


always@(*)begin
	case(ALU_control)
		2:begin
			//addition
			if(src1[31]&&src2[31]&&(result[31]))begin
				overflow <= 0;
			end
			else if(~(src1[31]&&src2[31]&&(result[31])))begin
				overflow <= 0;
			end
			else begin
				overflow <= 1;
			end
		end
		default:begin
			overflow <= 0;
		end
	endcase
end

endmodule
