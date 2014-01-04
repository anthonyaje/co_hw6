`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NCTU
// Engineer: 
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

module BranchAlu(
           src1,       
           src2,
		   opcode,
           result
           );


input signed[32-1:0] src1;
input signed[32-1:0] src2;
input [6-1:0] opcode;

output reg    result;

initial  begin
	result = 0;
end

always@(*)begin
	case(opcode)
		6'b000100:begin
			result = (src1 == src2)?1:0;
		end
		6'b000101:begin
			result = (src1 != src2)?1:0;
		end
		6'b000001:begin
			result = (src1 >= src2)?1:0;
		end
		6'b000111:begin
			result = (src1 > src2)?1:0;
		end
		default:
			result = 0;
	endcase
end

endmodule
