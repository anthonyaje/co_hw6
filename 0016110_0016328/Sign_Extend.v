//Subject:     CO project 2 - Sign extend
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Sign_Extend(
    data_i,
    data_o
    );
               
//I/O ports
input   [16-1:0] data_i;
output  [32-1:0] data_o;

//Internal Signals
reg     [32-1:0] data_o;

//Sign extended
	always@(*)begin
		if(data_i[15]==0)begin
			data_o[31:16] <= 16'b0000_0000_0000_0000;
			data_o[15:0] <= data_i;
		end
		else if(data_i[15]==1)begin
			data_o[31:16] <= 16'b1111_1111_1111_1111;
			data_o[15:0] <= data_i;
		end
		
	end
endmodule      
     