
module router_synchronizer(clock,resetn,detect_add,write_enb_reg,
									write_enb,data_in,empty_0,empty_1,empty_2,
									read_enb_0,read_enb_1,read_enb_2,
									full_0,full_1,full_2,fifo_full,
									vld_out_0,vld_out_1,vld_out_2,
									soft_reset_0,soft_reset_1,soft_reset_2);

input clock,resetn,detect_add,write_enb_reg,empty_0,empty_1,empty_2,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2;
input [7:0]data_in;
output reg [2:0]write_enb;
output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
output wire vld_out_0,vld_out_1,vld_out_2;

reg [1:0]temp_addr;
reg [4:0]count_0,count_1,count_2;

always@(posedge clock)
begin
if(!resetn)
temp_addr <= 2'd0;
else if(detect_add)
temp_addr <= data_in;
else
temp_addr <= temp_addr;
end

always@(*)
begin
	if(write_enb_reg)
		begin
			case(temp_addr)
				2'b00: write_enb = 3'b001;
				2'b01: write_enb = 3'b010;
				2'b10: write_enb = 3'b100;
				default: write_enb = 3'b000;
			endcase
		end
	else
	write_enb = 3'b000;
end

always@(*)
	begin
		case(temp_addr)
			2'b00: fifo_full = full_0; 
			2'b01: fifo_full = full_1; 
			2'b10: fifo_full = full_2;
			default fifo_full = 0;
		endcase
	end

assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

//soft_reset counter Block
//COUNTER 0
always@(posedge clock)
begin
 if(!resetn)
	 begin
	 count_0 <= 5'd0;
	 soft_reset_0 <= 1'b0;
	 end
 else if(vld_out_0)
	 begin
		if(!read_enb_0)
			 begin
				if(count_0 == 5'd29)//30 CLOCK CYCLES
					 begin
						soft_reset_0 <= 1'b1;
						count_0 <= 5'd0;
					end
				else
					 begin
						count_0 <= count_0 + 1'b1;
						soft_reset_0 <= 1'b0;
					 end
				end
		else 
			count_0 <= 5'd0;
	end
else 
	count_0 <= 5'd0;
end

//COUNTER 1
always@(posedge clock)
begin
 if(!resetn)
	 begin
	 count_1 <= 5'd0;
	 soft_reset_1 <= 1'b0;
	 end
 else if(vld_out_1)
	 begin
		if(!read_enb_1)
			 begin
				if(count_1 == 5'd29)
					 begin
						soft_reset_1 <= 1'b1;
						count_1 <= 5'd0;
					end
				else
					 begin
						count_1 <= count_1+1'b1;
						soft_reset_1 <= 1'b0;
					 end
				end
		else 
			count_1 <= 5'd0;
	end
else 
	count_1 <= 5'd0;
end


//COUNTER 2
always@(posedge clock)
begin
 if(!resetn)
	 begin
	 count_2 <= 5'd0;
	 soft_reset_2<=1'b0;
	 end
 else if(vld_out_2)
	 begin
		if(!read_enb_2)
			 begin
				if(count_2 == 5'd29)
					 begin
						soft_reset_2 <= 1'b1;
						count_2 <= 5'd0;
					end
				else
					 begin
						count_2 <= count_2+1'b1;
						soft_reset_2 <= 1'b0;
					 end
				end
		else 
			count_2 <= 5'd0;
	end
else 
	count_2 <= 5'd0;
end

endmodule




/*
module router_sync (input detect_add, 
                    input [1:0] data_in, 
                    input write_enb_reg, 
                    input clock, 
                    input resetn,                     
                    input read_enb_0,
                    input read_enb_1,
                    input read_enb_2,
                    input empty_0,
                    input empty_1,
                    input empty_2, 
                    input full_0, 
                    input full_1,
                    input full_2,
                    output vld_out_0,
                    output vld_out_1,
                    output vld_out_2,
                    output reg [2:0] write_enb, //one hot encoding
                    output reg fifo_full, 
                    output reg soft_reset_0,
                    output reg soft_reset_1,
                    output reg soft_reset_2);


//extracting address
reg [1:0] address;
always@(posedge clock)
    begin 
        if(!resetn)
            address <= 2'bzz;
        else if(detect_add == 1'b1)
            address <= data_in;//address of the destination must be here
    end 

//fifo full
// always@(posedge clock)
//     begin 
//         case(address)
//             2'b00: fifo_full <= full_0;
//             2'b01: fifo_full <= full_1;
//             2'b10: fifo_full <= full_2;
//             default: fifo_full <= 1'b0;
//         endcase
//     end 


// //one hot encoding for write enable
// always@(posedge clock)
//     begin 
//         if(write_enb_reg)
//             begin
//                 case(address)
//                 2'b00: begin 
//                             write_enb <= 3'b001;
//                        end
//                 2'b01: begin 
//                             write_enb <= 3'b010;
//                        end
//                 // write_enb <= 3'b010;
//                 2'b10: begin 
//                             write_enb <= 3'b100;
//                        end 
//                 // write_enb <= 3'b100;
//                 default: write_enb <= 3'b000;
//                 endcase 
//             end
//     end 

always@(*)
  begin
    case(address)
    2'b00:begin
	  fifo_full<=full_0;
	  if(write_enb_reg)
	  write_enb<=3'b001;
	  else
	  write_enb<=0;
	  end
    2'b01:begin
	  fifo_full<=full_1;
	  if(write_enb_reg)
	  write_enb<=3'b010;
	  else
	  write_enb<=0;
	  end
    2'b10:begin
	  fifo_full<=full_2;
	  if(write_enb_reg)
	  write_enb<=3'b100;
	  else
	  write_enb<=0;
	  end
    default:begin
	  fifo_full<=0;
	  write_enb<=0;
	  end
    endcase
  end

assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

//we need to count 30 clock cycles, after that the soft_reset must be high
reg [4:0] temp0 = 5'b00000;
reg [4:0] temp1 = 5'b00000;
reg [4:0] temp2 = 5'b00000;
always@(posedge clock)
    begin 
        if(!resetn)
            begin
                soft_reset_0 <= 1'b0;
                temp0 <= 5'd0;
            end
        else if(vld_out_0)
            begin 
                if(!read_enb_0)
                    begin 
                        if(temp0 == 29)
                            begin 
                                soft_reset_0 <= 1'b1;
                                temp0 <=5'd0;
                            end
                        else 
                            begin 
                                soft_reset_0 <= 1'b0;
                                temp0 <= temp0 + 1'b1;
                            end
                    end 
            end
        else
            temp0 <= 0;
    end

always@(posedge clock)
    begin 
        if(!resetn)
            begin
                soft_reset_1 <= 1'b0;
                temp1 <= 5'd0;
            end
        else if(vld_out_1)
            begin 
                if(!read_enb_1)
                    begin 
                        if(temp1 == 29)
                            begin 
                                soft_reset_1 <= 1'b1;
                                temp1 <=5'd0;
                            end
                        else 
                            begin 
                                soft_reset_1 <= 1'b0;
                                temp1 <= temp1 + 1'b1;
                            end
                    end 
            end
        else
            temp1 <= 0;
    end

always@(posedge clock)
    begin 
        if(!resetn)
            begin
                soft_reset_2 <= 1'b0;
                temp2 <= 5'd0;
            end
        else if(vld_out_2)
            begin 
                if(!read_enb_2)
                    begin 
                        if(temp2 == 29)
                            begin 
                                soft_reset_2 <= 1'b1;
                                temp2 <=5'd0;
                            end
                        else 
                            begin 
                                soft_reset_2 <= 1'b0;
                                temp2 <= temp2 + 1'b1;
                            end
                    end 
            end
        else
            temp2 <= 0;
    end


endmodule 
*/

/*
module sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,vld_out_0,vld_out_1,vld_out_2,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,write_enb);

input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;

output vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;
output reg[2:0] write_enb;
output reg fifo_full;

reg [1:0]temp;
reg [5:0]count0,count1,count2;
input [1:0]data_in;
reg soft_reset_0;
reg soft_reset_1;
reg soft_reset_2;


always@(temp or full_0 or full_1 or full_2)
begin
  case(temp)
    2'b00: fifo_full=full_0;
    2'b01: fifo_full=full_1;
    2'b10: fifo_full=full_2;
    default: fifo_full=0;
  endcase
end

always@(posedge clock)
begin
  if(!resetn)
   temp<=0;
  else if(detect_add)
    temp<=data_in;
  else 
    temp<=temp;
end

always@(temp or write_enb or write_enb_reg)
begin
  if(write_enb_reg)
    begin
      case(temp)
        2'b00: write_enb=3'b001;
        2'b01: write_enb=3'b010;
        2'b10: write_enb=3'b100;
      default: write_enb=3'b000;
      endcase
    end
	 else write_enb=0;
end

assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

always@(posedge clock)
begin
  if(!resetn)
    begin
      count0<=0;
      soft_reset_0<=0;
    end
  else if(!read_enb_0 && vld_out_0)
    begin
      if(count0<29)
         count0<=count0+1;
      if(count0>=29)
         soft_reset_0<=1'b1;
      if(read_enb_0)
         count0<=0;
    end
end 


always@(posedge clock)
begin
  if(!resetn)
    begin
      count1<=0;
      soft_reset_1<=0;
     end
  else if(!read_enb_1 && vld_out_1)
    begin
      if(count1<29)
         count1<=count1+1;
      if(count1>=29)
         soft_reset_1<=1'b1;
      if(read_enb_1)
         count1<=0;
    end
end 

always@(posedge clock)
begin
  if(!resetn)
    begin
      count2<=0;
      soft_reset_2<=0;
     end
  else if(!read_enb_2 && vld_out_2)
    begin
      if(count2<29)
         count2<=count2+1;
      if(count2>=29)
         soft_reset_2<=1'b1;
      if(read_enb_2)
         count2<=0;
    end
end 
endmodule 

*/

/*
module router_sync(clk,rst,read_enb_0,read_enb_1,read_enb_2,detect_add,data_in,write_enb_reg,empty_0,empty_1,empty_2,full_0,full_1,full_2,soft_reset_0,soft_reset_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2,fifo_full,write_enb);
input clk,rst,read_enb_0,read_enb_1,read_enb_2;
input write_enb_reg;
input [1:0]data_in;
input detect_add,empty_0,empty_1,empty_2,full_0,full_1,full_2;
output reg [2:0] write_enb;
output reg soft_reset_0,soft_reset_1,soft_reset_2;
output vld_out_0,vld_out_1,vld_out_2;
output reg fifo_full;
reg [1:0]temp_reg;
reg [5:0]count_0,count_1,count_2;
always@(posedge clk)
begin
	if(~rst)
		temp_reg<=2'b0;
	else if(detect_add)
	begin
		temp_reg<=data_in;
	end
	else
		temp_reg<=temp_reg;
end
always@(*)
begin
	if(write_enb_reg)
	begin
		case(temp_reg)
			2'b00:write_enb<=3'b001;
			2'b01:write_enb<=3'b010;
			2'b10:write_enb<=3'b100;
			2'b11:write_enb<=3'b000;
		endcase
	end
	else
		write_enb<=3'b000;
end
always@(*)
begin
	case(temp_reg)
		2'b00:fifo_full<=full_0;
		2'b01:fifo_full<=full_1;
		2'b10:fifo_full<=full_2;
		2'b11:fifo_full<=1'b0;
	endcase
end
assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;
always@(posedge clk)
begin
if(~rst)
begin
	count_0<= 5'h1;
	soft_reset_0 <= 1'b0;
end
else 
	begin
		if(~vld_out_0)
			begin
				count_0<=5'h1;
				soft_reset_0<=1'b0;
			end
		else 
			begin
				if(read_enb_0)
					begin
						count_0<=5'h1;
						soft_reset_0<=1'b0;
					end
				 else
					begin
						if(count_0==5'd30)
							begin
								soft_reset_0<=1'b1;
								count_0<=5'h1;
							end
						else
							begin
								soft_reset_0<=1'b0;
								count_0<=count_0+1'b1;
							end
					end
			end
	end
end

always@(posedge clk)
begin
if(~rst)
begin
	count_1 <= 5'h1;
	soft_reset_1 <= 1'b0;
end
else 
	begin
		if(~vld_out_1)
			begin
				count_1<=5'h1;
				soft_reset_1<=1'b0;
			end
		else 
			begin
				if(read_enb_1)
					begin
						count_1<=5'h1;
						soft_reset_1<=1'b0;
					end
				else 
					begin
						if(count_1==5'd30)
							begin
								soft_reset_1<=1'b1;
								count_1<=5'h1;
							end
						else
							begin
								soft_reset_1<=1'b0;
								count_1<=count_1+1'b1;
							end
					end
			end
	end
end

always@(posedge clk)
begin
if(~rst)
begin
	count_2 <= 5'h1;
	soft_reset_2 <= 1'b0;
end
else 
	begin
		if(~vld_out_2)
			begin
				count_2<=5'h1;
				soft_reset_2<=1'b0;
			end
		else 
			begin
				if(read_enb_2)
					begin
						count_2<=5'h1;
						soft_reset_2<=1'b0;
					end
				else 
					begin
						if(count_2==5'd30)
							begin
								soft_reset_2<=1'b1;
								count_2<=5'h1;
							end
						else
							begin
								soft_reset_2<=1'b0;
								count_2<=count_2+1'b1;
							end
					end
			end
	end
end

endmodule
*/
