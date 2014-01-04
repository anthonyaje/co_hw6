//Subject:     CO project 2 - forward
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        2010/8/17
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
     
module ForwardingUnit(
               exmem_rd_i,
               exmem_rw_i,
               memwb_rd_i,
			   memwb_rw_i,
			   write_to_memory_i,
			   
               idex_rs_i,
               idex_rt_i,
               forward1_o,
               forward2_o,
			   mux_control_o
               );


input [5-1:0] 	exmem_rd_i;
input 	exmem_rw_i;
input [5-1:0]   memwb_rd_i;
input 	memwb_rw_i;
input 	   write_to_memory_i;
			   
input     [5-1:0]    idex_rs_i;
input     [5-1:0]    idex_rt_i;

output reg [1:0] forward1_o;
output reg [1:0] forward2_o;
output reg [1:0] mux_control_o;

always@(*)begin
	//forward from exmem
	if((exmem_rw_i) && (exmem_rd_i !=0) && (exmem_rd_i == idex_rs_i) )begin
		forward1_o = 2'b01;
	end
	else if( (memwb_rw_i) && (memwb_rd_i!=0) && (memwb_rd_i == idex_rs_i) )begin
		forward1_o = 2'b10;
	end
	else begin
		forward1_o = 0;
	end
end

always@(*)begin
	if(write_to_memory_i)begin
		forward2_o = 0;
	end
	else if((exmem_rw_i) && (exmem_rd_i !=0) && (exmem_rd_i == idex_rt_i) )begin
		forward2_o = 2'b01;
	end
	else if( (memwb_rw_i) && (memwb_rd_i!=0) && (memwb_rd_i == idex_rt_i) )begin
		forward2_o = 2'b10;
	end
	else begin
		forward2_o = 0;
	end
end

always@(*)begin
	if((write_to_memory_i))begin
		if((exmem_rw_i) && (exmem_rd_i !=0) && (exmem_rd_i == idex_rt_i))begin
			mux_control_o = 1;
		end		
		else if( (memwb_rw_i) && (memwb_rd_i!=0) && (memwb_rd_i == idex_rt_i) )begin
			mux_control_o = 2;
		end
		else begin
			mux_control_o = 0;
		end
	end
	else
		mux_control_o = 0;
end
endmodule