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

module DetectionUnit(
           //input
		   mem_read,       
           idex_rt,
		   ifid_rs,
		   ifid_rt,
		   instruction,
		   branch_signal,
		   jump_jr,
		   
		   //output
		   instruction_o,
		   out
           );
		   
input [1:0]   jump_jr;
input 		  mem_read;
input         branch_signal;
input [5-1:0] idex_rt;
input [5-1:0] ifid_rs;
input [5-1:0] ifid_rt;
input [32-1:0] instruction;

output reg [32-1:0] instruction_o;
output  reg out;

initial  begin
	out = 0;
end

always@(*)begin
	if((mem_read) && ((idex_rt == ifid_rs) ||(idex_rt == ifid_rt)) )begin
		out = 1;
		instruction_o = 32'd0;
	end
	else if(jump_jr != 2'b00)begin
		out =0;
		instruction_o = 32'd0; 
	end
	else if(branch_signal)begin
		out = 0;
		instruction_o = 32'd0;
	end
	else begin 
		out = 0;
		instruction_o = instruction;
	end
end

endmodule
