//Subject:      CO project 2 - Shift_Left_Two_32
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Shift_Left_Two_28(
    data_i,
    data_o
    );

//I/O ports                    
input [26-1:0] data_i;
output [28-1:0] data_o;

//shift left 2
	assign data_o[27:0] = {data_i[25:0],2'b00};
endmodule
