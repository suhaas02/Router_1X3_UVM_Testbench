
module register(clock,resetn,pkt_valid,
					 data_in,fifo_full,rst_int_reg,
					 detect_add,ld_state,laf_state,
					 full_state,lfd_state,parity_done,
					 low_pkt_valid,err,dout);

//Input/Output Port Declaration
input clock,resetn,pkt_valid;
input [7:0] data_in;
input fifo_full,detect_add,ld_state,laf_state,
 full_state,lfd_state,rst_int_reg;
output reg parity_done,low_pkt_valid,err;
output reg [7:0] dout;

//Internal Register declaration
 reg [7:0] hold_header_byte,fifo_full_state_byte,internal_parity,packet_parity_byte;

//Parity_done
always@(posedge clock)
begin
if(!resetn)
		parity_done<=1'b0;
else if(detect_add)
		parity_done <= 1'b0;
else if(ld_state && !fifo_full && !pkt_valid)
		parity_done <= 1'b1;
else if(laf_state && low_pkt_valid && !parity_done)
		parity_done<=1'b1; 
end

//________________ ________________________________________________________________
//low_packet_valid
always@(posedge clock)
	begin
		if(!resetn)
			low_pkt_valid <= 1'b0;
		else
			begin
				if(rst_int_reg)
					low_pkt_valid <= 1'b0;
				else if(ld_state && !pkt_valid)
					low_pkt_valid <= 1'b1;
			end
	end
//________________________________________________________________________________
//error
always@(posedge clock)
	begin
	 if(!resetn)
		err<=1'b0;
	 else
		 begin
			if(parity_done)
				begin
					if(internal_parity != packet_parity_byte)
						err<=1'b1;
					else
						err<=1'b0;
				end
		 end
	end
//________________________________________________________________________________
//dout
always@(posedge clock)
begin
	if(!resetn)
		dout <= 1'b0;
	else if (detect_add && pkt_valid && data_in[1:0]!=3)
		dout<=dout;
	else if(lfd_state)
		dout <= hold_header_byte;
	else if(ld_state && !fifo_full)
		dout <= data_in;
	else if(ld_state && fifo_full)
		dout <= dout;
	else if(laf_state)
		dout <= fifo_full_state_byte;
	else
		dout <= dout;
 end
 

//Hold_Header_Byte
always@(posedge clock)
begin
	if(!resetn)
		hold_header_byte <= 8'b0;
	else if(detect_add && pkt_valid && data_in[1:0]!=3)
		hold_header_byte <= data_in;
	else
		hold_header_byte <= hold_header_byte;
end

//________________________________________________________________________________
//FIFO_Full_State_Byte
always@(posedge clock)
	begin
		if(!resetn)
			fifo_full_state_byte <= 8'b0;
		else if(ld_state && fifo_full)
			fifo_full_state_byte <= data_in;
		else 
			fifo_full_state_byte <= fifo_full_state_byte;
	end
//________________________________________________________________________________
//Internal_Parity_Byte
always@(posedge clock)
	begin
		if(!resetn)
			internal_parity <= 8'b0;
		else if(detect_add)
			internal_parity <= 8'b0;
		else if(lfd_state)
			internal_parity <= internal_parity ^ hold_header_byte;
		else if(pkt_valid && ld_state && ~full_state)
			internal_parity <= internal_parity ^ data_in;
		else
			internal_parity<=internal_parity;
	end
//________________________________________________________________________________
//Packet_Parity_Byte
always@(posedge clock)
	begin
		if(!resetn)
			packet_parity_byte <= 8'b0;
		else if(detect_add)
			packet_parity_byte <= 8'd0;
		else if(ld_state && ~pkt_valid)
			packet_parity_byte <= data_in;
		else
			packet_parity_byte <= packet_parity_byte;
	end
endmodule








/*
module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,
                  ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,
                  parity_done,low_pkt_valid,dout);

input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
input [7:0]data_in;
output reg err,parity_done,low_pkt_valid;
output reg [7:0]dout;
reg [7:0]header,int_reg,int_parity,ext_parity;
  
	always@(posedge clock)
   	begin
      if(!resetn)
      	begin
	     dout    	 <=0;
	     header  	 <=0;
	     int_reg 	 <=0;
       	end
      else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)
	     header<=data_in;
      else if(lfd_state)
	     dout<=header;
      else if(ld_state && !fifo_full)
	     dout<=data_in;
      else if(ld_state && fifo_full)
	     int_reg<=data_in;
      else if(laf_state)
	     dout<=int_reg;
     end

    always@(posedge clock)
	   	begin
            if(!resetn)
	 			low_pkt_valid<=0; 
         	else if(rst_int_reg)
	 			low_pkt_valid<=0;
            else if(ld_state && !pkt_valid) 
         		low_pkt_valid<=1;
		end
	
	always@(posedge clock)
	begin
      if(!resetn)
	  parity_done<=0;
     else if(detect_add)
	  parity_done<=0;
      else if((ld_state && !fifo_full && !pkt_valid)
              ||(laf_state && low_pkt_valid && !parity_done))
	  parity_done<=1;
	end

	always@(posedge clock)
	begin
      if(!resetn)
	 int_parity<=0;
	else if(detect_add)
	 int_parity<=0;
	else if(lfd_state && pkt_valid)
	 int_parity<=int_parity^header;
	else if(ld_state && pkt_valid && !full_state)
	 int_parity<=int_parity^data_in;
	else
	 int_parity<=int_parity;
	end
	 
	always@(posedge clock)
		begin
          if(!resetn)
	  			err<=0;
	      else if(parity_done)
	       		begin
	 				if (int_parity==ext_parity)
	    				err<=0;
	 				else 
	    			err<=1;
	 			end
	 	   else
	    		err<=0;
	    end

	always@(posedge clock)
	begin
      if(!resetn)
	  		ext_parity<=0;
      else if(detect_add)
	  		ext_parity<=0;
      else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && !parity_done && low_pkt_valid))
	  		ext_parity<=data_in;
	 end

endmodule
*/

/*
module register(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

input [7:0]data_in;
input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;

output reg[7:0]dout;
output reg err,parity_done,low_packet_valid;

reg [7:0] full_state_byte,internal_parity,header,packet_parity;

//dout
always@(posedge clock)
begin
  if(!resetn)
  dout<=0;
  else
  begin
   if(~(detect_add))
         begin
           if(~(lfd_state))
             begin
               if(~(ld_state && ~fifo_full))
                  begin
                     if(~(ld_state && fifo_full))
                        begin 
                          if(~(laf_state))
                            dout<=dout;
                          else
                            dout<=full_state_byte;
                        end
                       else
                         dout<=dout;
                   end
                 else
                   dout<=data_in;
             end
           else
              dout<=header;
         end
       else
          dout<=dout; 
  end
end

//fifo_full_byte
always@(posedge clock)
begin
  if(!resetn)
    full_state_byte<=0;
  else 
  begin
     if(ld_state && fifo_full)
          full_state_byte<=data_in;
      else
         full_state_byte<=full_state_byte;
  end
end

//Header
always@(posedge clock)
begin
  if(!resetn)
    header<=0;
  else 
  begin
    if(detect_add && pkt_valid && (data_in[1:0]!=3))
        header<=data_in;
    else
        header<=header;
  end
end

//parity
always@(posedge clock)
begin
  if(!resetn)
     internal_parity<=0;
  else 
  begin
  if(detect_add)
      internal_parity<=0;
  else if(lfd_state)
      internal_parity<= internal_parity ^ header ;
  else
    if(ld_state && pkt_valid && ~full_state)
        internal_parity<= internal_parity ^data_in;
  //else 
  //      internal_parity<=internal_parity;
  end
end

//low_packet_valid
always@(posedge clock)
begin
  if(!resetn)
    low_packet_valid<=0;
  else 
  begin
    if(rst_int_reg)
        low_packet_valid<=1'b0;
    else if(ld_state && ~(pkt_valid))
        low_packet_valid<=1'b1;
    else 
        low_packet_valid <= low_packet_valid;
  end
end


//paritydone
always@(posedge clock)
begin
  if(!resetn)
    parity_done<=0;
  else
  begin
    if(detect_add)
    parity_done <= 0;
    else if( (ld_state && ~(pkt_valid) && ~fifo_full) || (laf_state && (low_packet_valid) && ~parity_done))
          parity_done<=1'b1;
    else
          parity_done<=parity_done;
  end
end

//packet parity
always@(posedge clock)
begin
  if(!resetn)
    packet_parity<=0;
  else if(ld_state && ~pkt_valid)
    packet_parity<=data_in;
  else
    packet_parity<=packet_parity;
end

//error          
always@(posedge clock)
begin
  if(~resetn)
    err <= 0;
  else
    begin  
      if(parity_done)
      begin
        if(internal_parity==packet_parity)
         err<=1'b0;
        else
          err<=1'b1;         
      end
      else
        err<=1'b0;
    end
end
endmodule

*/


/*
module router_reg(clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,dout,err,low_pkt_valid,parity_done);
input clk,rst,pkt_valid;
input [7:0]data_in;
input fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
output reg [7:0]dout;
output  reg err,low_pkt_valid,parity_done;
reg [7:0]header,internal_parity;
reg [7:0]packet_parity,ffs;
always@(posedge clk)
begin
	if(~rst)
		dout<=0;
	else
	begin
		if(detect_add && pkt_valid && data_in[1:0]!=3)
		begin
			header<=data_in;
		end
		else if(lfd_state)
			dout<=header;
		else if(ld_state && ~fifo_full)
			dout<=data_in;
		else if(ld_state && fifo_full)
			ffs<=dout;
		else if(laf_state)
			dout<=ffs;
		else
			dout<=dout;
	end
end
//full state logic
always@(posedge clk)
begin
	if(~rst)
		internal_parity<=0;
	else
	begin
		if(detect_add)
			internal_parity<=0;
		else if(lfd_state)
			internal_parity <= internal_parity ^ header;
		else if(pkt_valid && ld_state && ~full_state)
			internal_parity <= internal_parity ^ data_in;
		else 
			internal_parity <= internal_parity;
	end
end
//packet parity calculation
always@(posedge clk)
begin
	if(~rst)
		packet_parity<=0;
	else if(detect_add)
		packet_parity<=0;
	else if(ld_state && ~pkt_valid)
		packet_parity<=data_in;
	else
		packet_parity<=packet_parity;
	//end
end
always@(posedge clk)
begin
	if(~rst)
		parity_done<=1'b0;
	else if(ld_state && ~fifo_full && ~pkt_valid)
		parity_done<=1'b1;
	else if(laf_state && low_pkt_valid)
		parity_done<=1'b0;
end
always@(posedge clk)
begin
	if(~rst)
		low_pkt_valid<=1'b0;
	else 
		low_pkt_valid<=~pkt_valid;
end
always@(posedge clk)
begin
	if(~rst)
		err<=1'b0;
	else if(~parity_done )
		err<=1'b0;
	else 
	begin
		if(packet_parity==internal_parity)
			err<=1'b0;
		else 
			err<=1'b1;
	end
end
endmodule

*/
