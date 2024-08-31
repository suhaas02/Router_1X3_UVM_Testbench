
module fifo(clock,resetn,soft_reset,write_enb,
            read_enb,lfd_state,data_in,full,empty,data_out);

input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
input[7:0]data_in;
output reg [7:0]data_out;
output full,empty;

reg lfd_temp;
reg[8:0]fifo[15:0];
reg [4:0]wr_pt,rd_pt;
reg  [6:0] temp_count;
integer i,j;

//assign full =((wr_pt == 16)&&(rd_pt == 0));
assign full = (wr_pt == {~rd_pt[4],rd_pt[3:0]});//00000, 10000// 01111, 11111, 01010, 11010
assign empty = (wr_pt == rd_pt);

 
always@(posedge clock)
begin
 
  if(lfd_state)
		lfd_temp <= lfd_state;
	else
		lfd_temp <= 1'b0;
end


//write logic
always@(posedge clock)
begin
	if(!resetn) //active low reset
		 begin
			wr_pt <= 0;
			for(i=0;i<16;i=i+1)
				fifo[i] <= 0;
		 end
	else if(soft_reset)
		 begin
			wr_pt <= 0;
			for(j=0;j<16;j=j+1)
				fifo[j] <= 0;
		 end
	else if(write_enb && !full)
		begin
			fifo[wr_pt[3:0]] <= {lfd_temp, data_in};//1,  10001010 = 110001010
			wr_pt <= wr_pt+1'b1;
		end
	/*else if(full || temp_count == 0) //down count all bytes are written including parity byte
		wr_pt <= 0;*/
		
	else
		wr_pt <= wr_pt;
end

//counter logic
// counter is used to down count 
always@(posedge clock)
begin
	if(!resetn) 
		  temp_count <= 0;
	else if(soft_reset)
		  temp_count <= 0;
	           
	else if(read_enb && !empty)//header byte presence
			begin
				if(fifo[rd_pt[3:0]][8]==1'b1) // fifo[rd_pt] = 101001010
					temp_count <= fifo[rd_pt[3:0]][7:2]+1;/// payload length + parity = 16
				else 
				temp_count <= temp_count - 1'b1;//down counting from payload1 to 16 t0 parity
			end
	else if(temp_count == 0)
			data_out <= 8'bz;
	else
			temp_count <= temp_count;
end


//read logic
always@(posedge clock)
 begin
   if(!resetn)
         begin
         data_out <= 8'd0;
         rd_pt <= 4'd0;
         end
	else if(soft_reset)
         begin
           data_out <= 8'dz;
           rd_pt <= 4'd0;
         end
		
   else if(read_enb && !empty)
         begin
           data_out <= fifo[rd_pt[3:0]][7:0]; //fifo[7:0]
           rd_pt <= rd_pt + 1'b1;
         end
			
	/*else if(read_enb && empty)
		begin
        data_out <= 8'bz;
		  rd_pt <= 4'd0;
		 end*/
		 
/*	else if(temp_count == 0)
		begin
			data_out <= 8'bz;
			/*rd_pt <= 4'd0;
		end*/
		
	else
		
			/*data_out <= data_out;*/
			rd_pt <= rd_pt;
end
 
endmodule 

                                   
















//define all the ports
/*
module router_fifo(input clock, 
            input resetn, 
            input write_enb, 
            input soft_reset, 
            input read_enb, 
            input [7:0] data_in, 
            input lfd_state, 
            output empty,
            output full, 
            output  reg [7:0] data_out);

//internal variables
reg [4:0]rd_ptr = 5'b0;
reg [4:0]wr_ptr = 5'b0;
reg [8:0] mem [15:0];

//write operation 
integer i;
always@(posedge clock)
    begin 
        
        if(!resetn)
            begin 
                for(i = 0; i < 16; i = i + 1)
                    begin 
                        mem[i] <=9'b0;
                    end
                wr_ptr <= 5'b0;
            end 
        else if(soft_reset)
            begin 
                for(i = 0; i < 16; i = i + 1)
                    begin 
                        mem[i] <= 9'b0;
                    end
                wr_ptr <= 5'b0;
            end 
        else if(write_enb == 1'b1 && full == 1'b0)
            begin 
                mem[wr_ptr] <= {lfd_state, data_in};
                wr_ptr <= wr_ptr + 1'b1;
            end 
        else    
            begin 
                wr_ptr <= wr_ptr;
            end
    end 

//read operation 
reg [6:0]count;
always@(posedge clock)
    begin 
        if(!resetn)
            begin 
                rd_ptr <= 5'b0;
                data_out <= 8'd0;
            end
        else if(soft_reset)
            begin 
                data_out <= 8'dz;
                rd_ptr <= 5'b0;
            end 
         else if(read_enb == 1'b1 && empty == 1'b0)
            begin 
                data_out <= mem[rd_ptr[4:0]][7:0];
                rd_ptr <= rd_ptr + 1'b1;
            end
      else if(count ==7'b0)
            begin
                data_out <= 8'bz;
            end
     else if(empty)
        data_out <= 8'bz;

        else    
            rd_ptr <= rd_ptr;
        
    end     

always@(posedge clock)
    begin 
        if(!resetn)
            begin 
                count <= 7'b0;
            end 
        else if(soft_reset)
            begin
                count <= 0;
            end
        else if(read_enb == 1 && empty == 0)
            begin 
                if(mem[rd_ptr[4:0]][8] == 1)
                    begin 
                        count <= mem[rd_ptr[4:0]][7:2] + 1'b1;
                    end
                else if(count != 6'b0)
                    count <= count - 1'b1;
                else 
                    count <= count;
            end 
  else 
       count <= count;
    
    end

//full and empty conditions
assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
assign full = ((wr_ptr[4] != rd_ptr[4]) && (wr_ptr[3:0] == rd_ptr[3:0])) ? 1'b1 : 1'b0;
endmodule 
*/
/*
module fifo(clock,resetn,data_in,read_enb,write_enb,data_out,full,empty,lfd_state,soft_reset);
                          
parameter width=9,depth=16;
input lfd_state;
input [width-2:0] data_in;
input clock,resetn,read_enb,write_enb,soft_reset;
reg [4:0]rd_pointer,wr_pointer;
output reg [width-2:0] data_out;
reg [6:0]count;

output full,empty;
integer i;

reg [width-1:0] mem[depth-1:0];
reg temp;

assign full=((wr_pointer[4] != rd_pointer[4]) && (wr_pointer[3:0]==rd_pointer[3:0]));
assign empty= wr_pointer==rd_pointer;

always@(posedge clock)
begin
  if(~resetn)
    temp=0;
  else 
    temp=lfd_state;
end

//write
always@(posedge clock)
begin 
  if(~resetn)
    begin 
      //data_out<=0;
      for(i=0;i<=15;i=i+1)
         mem[i]<=0;
    end
  else if(soft_reset)
    begin
      // data_out=0;
       for(i=0;i<=15;i=i+1)
        mem[i]<=0;
    end
  else if(write_enb && !full)
    begin
      if(lfd_state)
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
    else
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
     end
end

//read
always@(posedge clock)
begin 
     if(~resetn)
       begin 
         data_out <= 0;
       end
else if(soft_reset)
      begin
	      data_out <= 8'bz;
      end
else if(read_enb && !empty)
      begin
         data_out <= mem[rd_pointer[3:0]][7:0];
      end
      else if(count==0 && data_out != 0)
      data_out <= 8'bzzzzzzzz;
end
         
//counter
always@(posedge clock)
begin
if(~resetn)
count<=0;
else if(soft_reset)
count<=0;
 if(read_enb && !empty)
     begin
      if(mem[rd_pointer[3:0]][8])
         begin
          count <= mem[rd_pointer[3:0]][7:2] +1;
          end
     else
       if(count!=0)
         begin
         count <= count-1;
         end
    end  
end
     
always@(posedge clock)
begin
  if(~resetn || soft_reset)
	begin
      rd_pointer <= 0;
      wr_pointer <= 0;
	end
	else
	begin
      if(write_enb && !full)
          wr_pointer <= wr_pointer+1;
      if(read_enb && !empty)
          rd_pointer <= rd_pointer+1;
	end
end

endmodule
*/


/*
module fifo(clk,rst,sft_rst,wr,rd,lfd_state,wr_data,full,empty,data_out);
input clk,rst,lfd_state,sft_rst;
input wr,rd;
reg [6:0]count;
reg lfd;
output  full,empty;
input [7:0]wr_data;
output reg [7:0]data_out;
integer i;
reg [8:0]mem[15:0];
reg [4:0]wr_ptr,rd_ptr;
always@(posedge clk)
				lfd <= lfd_state;
always@(posedge clk)
begin
	if(~rst)
		begin
			for(i=0;i<16;i=i+1)
			begin
				mem[i]<=0;
			end
			wr_ptr<=0;
		end
	else if(sft_rst)
		begin
			for(i=0;i<16;i=i+1)
			begin
				mem[i]<=8'b0;
			end
			
		end
	else if(wr && ~full)
	begin
		wr_ptr<=wr_ptr+1'b1;
		mem[wr_ptr]<={lfd,wr_data};
		
	end
end
always@(posedge clk)
begin
	if(~rst)
		begin
			data_out<=8'b0;
			rd_ptr<=5'b00000;
		end
	else if(sft_rst)
		begin
			data_out<=8'bz;
			rd_ptr<=5'b00000;
		end
	else if(count==0 && data_out !=0)
		begin
			data_out<=8'bz;
		end
	else if(rd &&~empty)
	begin
		data_out<=mem[rd_ptr][7:0];
		rd_ptr<=rd_ptr+1'b1;
	end
end
always@(posedge clk)
begin
	if(~rst)
	begin
		count<=0;
	end
	if(rd && ~empty)
	begin
		if(mem[rd_ptr[3:0]][8]==1)
		begin
			count<=mem[rd_ptr[3:0]][7:2]+1'b1;
		end
		else begin
		if(count != 0)
			count<=count-1'b1;
		end
	end
end
assign full=(wr_ptr==16 && rd_ptr==5'b00000)?1'b1:1'b0;
assign empty =(wr_ptr==rd_ptr)?1'b1:1'b0;
endmodule

*/
