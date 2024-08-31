
module fsm_control(clock,resetn,pkt_valid,
						 data_in,parity_done,low_packet_valid,
						 fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,
						 soft_reset_0,soft_reset_1,soft_reset_2,
						 write_enb_reg,detect_add,ld_state,laf_state,
						 lfd_state,full_state,rst_int_reg,busy);

//Input/Outport_Declaration
 input clock,resetn,pkt_valid,parity_done,low_packet_valid,
 fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,
 soft_reset_0,soft_reset_1,soft_reset_2;
 input [1:0] data_in;
 output write_enb_reg,detect_add,ld_state,laf_state,
 lfd_state,full_state,rst_int_reg,busy;
//State_Parameter_Declaration 
 localparam decode_address = 3'b000, //0
				wait_till_empty = 3'b001, //1
				load_first_data = 3'b010, //2
				load_data = 3'b011, //3
				load_parity = 3'b100, //4
				fifo_full_state = 3'b101, //5
				load_after_full = 3'b110, //6
				check_parity_error = 3'b111; //7
//Internal_Registers
reg [2:0] present_state, next_state;
reg [1:0] temp;
//temp_logic
 always@(posedge clock)
begin
 if(~resetn)
temp <= 2'b0;
 else if(detect_add) 
temp <= data_in;
end
//_______________________________________________________________________________________
//Present state_logic 
 always@(posedge clock)
		begin
		 if(!resetn)
		 present_state <= decode_address;
		 else if ((soft_reset_0) || (soft_reset_1) || (soft_reset_2))
		 present_state <= decode_address;
		 else
		 present_state <= next_state;
		end
//_______________________________________________________________________________________
//Next state_Logic 
 always@(*)
begin
 case(present_state)
		decode_address : begin
								 if((pkt_valid && (data_in==2'b00) && fifo_empty_0)||
									 (pkt_valid && (data_in==2'b01) && fifo_empty_1)||
									 (pkt_valid && (data_in==2'b10) && fifo_empty_2))
									 
									 next_state = load_first_data;
								 
								 else if((pkt_valid && (data_in==2'b00) && !fifo_empty_0)||
											 (pkt_valid && (data_in==2'b01) && !fifo_empty_1)||
											 (pkt_valid && (data_in==2'b10) && !fifo_empty_2))
								 
											next_state = wait_till_empty;
								 else

								 next_state = decode_address; 

								 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		load_first_data : begin
								 next_state = load_data;
								 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		wait_till_empty : begin
								 if((fifo_empty_0 && (temp==0))||
										(fifo_empty_1 && (temp==1))||
											(fifo_empty_2 && (temp==2)))
												
												next_state=load_first_data;
								 else
												next_state=wait_till_empty;
								 end
		load_data : begin
						 if(fifo_full==1'b1)
							next_state=fifo_full_state;
						 else
							 begin
							 if (!fifo_full && !pkt_valid)
									next_state=load_parity;
							 else
									next_state=load_data;
							 end
						 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		fifo_full_state : begin
								 if(fifo_full==0)
										next_state=load_after_full;
								 else
										next_state=fifo_full_state;
							 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		load_after_full : begin
								 if(!parity_done && low_packet_valid)
										next_state=load_parity;
								 else if(!parity_done && !low_packet_valid)
										next_state=load_data;
								 else if(parity_done==1'b1)
											next_state=decode_address;
									else
											next_state=load_after_full;
									
								 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 load_parity : begin
								next_state=check_parity_error;
							end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		check_parity_error : begin
										 if(!fifo_full)
												next_state=decode_address;
										 else
												next_state=fifo_full_state;
										 end
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		default :
						next_state = next_state;
	endcase
end
//Output_Logic
assign busy=((present_state==load_first_data)||
					(present_state==load_parity)||
					 (present_state==fifo_full_state)||
					(present_state==load_after_full)||
					 (present_state==wait_till_empty)||
					(present_state==check_parity_error))?1'b1:1'b0;
assign write_enb_reg=(/*(present_state==load_first_data)||*/
								(present_state==load_data)||
							 (present_state==load_after_full)||
							 (present_state==load_parity))?1'b1:1'b0;
assign ld_state =((present_state==load_data))?1'b1:1'b0;
assign detect_add =((present_state==decode_address))?1'b1:1'b0;
assign lfd_state =((present_state==load_first_data))?1'b1:1'b0;
assign full_state =((present_state==fifo_full_state))?1'b1:1'b0;
assign laf_state =((present_state==load_after_full))?1'b1:1'b0;
assign rst_int_reg=((present_state==check_parity_error))?1'b1:1'b0;


endmodule




















//defining all the ports
/*
module router_fsm(input clock, resetn, pkt_valid, 
                  input parity_done, soft_reset_0, soft_reset_1, soft_reset_2, fifo_full, 
                  input [1:0] data_in,
                  input low_pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2, 
                  output busy, detect_add, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state);

//declare the states as parameters
parameter DECODE_ADDRESS = 4'b0000,
          LOAD_FIRST_DATA = 4'b0001, 
          LOAD_DATA = 4'b0010, 
          FIFO_FULL_STATE = 4'b0011, 
          LOAD_AFTER_FULL = 4'b0100, 
          LOAD_PARITY = 4'b0101, 
          CHECK_PARITY_ERROR = 4'b0110, 
          WAIT_TILL_EMPTY = 4'b0111;

//declare internal variables
reg [3:0] state;
reg[3:0]next_state;

//temp variable for storing the address; 
reg [1:0]address;
always@(posedge clock)
    begin 
        if(!resetn)
            address <= 2'bzz;
        else
            address <= data_in; 
    end

//current state logic 
always@(posedge clock)
    begin 
        if(!resetn)
            state <= DECODE_ADDRESS; 
        else if(soft_reset_0|| soft_reset_1|| soft_reset_2)   
            state <= DECODE_ADDRESS; 
        else 
            state <= next_state; 
    end 

//next state logic 
always@(*)
    begin 
        case(state)
            DECODE_ADDRESS: 
                            begin 
                                if((pkt_valid && data_in == 2'b00 && fifo_empty_0) || (pkt_valid && data_in == 2'b01 && fifo_empty_1) || 
                                (pkt_valid && data_in == 2'b10 && fifo_empty_2))
                                    next_state <= LOAD_FIRST_DATA;
                                else if((pkt_valid && data_in == 2'b00 && !fifo_empty_0) || (pkt_valid && data_in == 2'b01 && !fifo_empty_1) || 
                                (pkt_valid && data_in == 2'b10 && !fifo_empty_2))
                                    next_state <= WAIT_TILL_EMPTY; 
                                else    
                                    next_state <= DECODE_ADDRESS; 
                            end 
            
            LOAD_FIRST_DATA: 
                            begin
                                next_state <= LOAD_DATA; 
                            end 
            
            LOAD_DATA: 
                        begin 
                            if(fifo_full)
                                next_state <= FIFO_FULL_STATE; 
                            else if(!fifo_full && !pkt_valid)
                                next_state <= LOAD_PARITY; 
                            else 
                                next_state <= LOAD_DATA; 
                        end 
            
            FIFO_FULL_STATE: 
                            begin 
                                if(!fifo_full)
                                    next_state <= LOAD_AFTER_FULL;
                                else
                                    next_state <= FIFO_FULL_STATE; 
                            end 

            LOAD_AFTER_FULL: 
                            begin 
                                if(!parity_done && low_pkt_valid)
                                    next_state <= LOAD_PARITY; 
                                else if(!parity_done && !low_pkt_valid)
                                    next_state <= LOAD_DATA; 
                                else if(parity_done)
                                    next_state <= DECODE_ADDRESS; 
                            end 
            
            LOAD_PARITY: 
                        begin 
                            next_state <= CHECK_PARITY_ERROR; 
                        end 
            
            CHECK_PARITY_ERROR: 
                                begin 
                                    if(!fifo_full)
                                        next_state <= DECODE_ADDRESS; 
                                    else if(fifo_full)
                                        next_state <= FIFO_FULL_STATE;
                                end 
                                
            WAIT_TILL_EMPTY : 
                            begin 
                                if(((fifo_empty_0) && (address[1:0] ==  2'b00)) || ((fifo_empty_1) && (address[1:0] ==  2'b01)) || ((fifo_empty_2) && (address[1:0] ==  2'b10)))
                                    next_state <= LOAD_FIRST_DATA;
                                else    
                                    next_state <= WAIT_TILL_EMPTY; 
                            end 
	   default: next_state <= DECODE_ADDRESS;
        endcase
    end 

assign detect_add = (state == DECODE_ADDRESS) ? 1'b1 : 1'b0;
assign ld_state = (state == LOAD_DATA) ? 1'b1 : 1'b0;
assign laf_state = (state == LOAD_AFTER_FULL) ? 1'b1 : 1'b0;
assign full_state = (state == FIFO_FULL_STATE) ? 1'b1 : 1'b0;
assign write_enb_reg = (state == LOAD_PARITY || state == LOAD_AFTER_FULL || state == LOAD_DATA) ? 1'b1 : 1'b0;
assign rst_int_reg = (state == CHECK_PARITY_ERROR) ? 1'b1 : 1'b0;
assign lfd_state = (state == LOAD_FIRST_DATA) ? 1'b1 : 1'b0;
assign busy = (state == LOAD_DATA || state == LOAD_AFTER_FULL || state == FIFO_FULL_STATE || state == LOAD_PARITY || state == WAIT_TILL_EMPTY || 
                state == LOAD_FIRST_DATA) ? 1'b1 : 1'b0;
endmodule 
*/

/*
module fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

input [1:0]data_in;

input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;

output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

parameter decode_address= 3'b000,
          load_first_data= 3'b001,
          wait_till_empty=3'b010,
          load_data=3'b011,
          load_parity=3'b100,
          fifo_full_state=3'b101,
          load_after_full=3'b110,
          check_parity_error=3'b111;

reg[2:0] next_state,present_state; 

always@(posedge clock)
begin
  if(~resetn)
    present_state<= decode_address;
 else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
    present_state<=decode_address;
  else
     present_state<= next_state;
end
 
always@(*)
begin
  next_state=present_state;
  case(present_state)
  decode_address: begin
                 if((pkt_valid && (data_in[1:0]==2'd0) && fifo_empty_0) || 
                   (pkt_valid && (data_in[1:0]==2'd1) && fifo_empty_1) ||
                   (pkt_valid && (data_in[1:0]==2'd2) && fifo_empty_2))
                 next_state= load_first_data;
                 if((pkt_valid && (data_in[1:0]==2'd0) && ~fifo_empty_0) || 
                   (pkt_valid && (data_in[1:0]==2'd1) && ~fifo_empty_1) ||
                   (pkt_valid && (data_in[1:0]==2'd2) && ~fifo_empty_2))
                  next_state=wait_till_empty;
                end

  load_first_data: next_state= load_data;
 
  wait_till_empty: begin
                 if(fifo_empty_0 || fifo_empty_1 || fifo_empty_2)
                   next_state=load_first_data;
                 if(~(fifo_empty_0) || ~(fifo_empty_1) || ~(fifo_empty_2))
                   next_state= wait_till_empty;
                  end
  load_data:  begin
            if(fifo_full==1'b1)
              next_state=fifo_full_state;
            if(fifo_full==1'b0 && pkt_valid==1'b0)
              next_state=load_parity;  
            end
  load_parity: next_state= check_parity_error;

  fifo_full_state:begin
                 if(fifo_full==1'b0)
                    next_state=load_after_full;
                 if(fifo_full==1'b1)
                    next_state=fifo_full_state;
                  end
  load_after_full:begin 
                if(parity_done==1'b0 && low_packet_valid==1'b1)
                   next_state=load_parity;
                 if(parity_done==1'b0 && low_packet_valid==1'b0)
                   next_state=load_data;
                 if(parity_done)
                   next_state=decode_address;
                 end
  check_parity_error: begin
                     if(!fifo_full)
                      next_state= decode_address;
                    if(fifo_full)
                      next_state= fifo_full_state; 
                     end
  endcase
end

assign detect_add= (present_state==decode_address); 

assign lfd_state=(present_state==load_first_data);

assign busy= ((present_state==load_first_data)||(present_state==load_parity)||(present_state==fifo_full_state)||(present_state==load_after_full)||(present_state==wait_till_empty)||(present_state==check_parity_error));

assign ld_state= (present_state==load_data);

assign write_enb_reg= ((present_state==load_data)||(present_state==load_parity)||(present_state==load_after_full));

assign full_state=(present_state==fifo_full_state);

assign laf_state=(present_state==load_after_full);

assign rst_int_reg=(present_state==check_parity_error);

endmodule
*/


/*
module router_fsm(clk,rst,pkt_valid,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy);
input clk,rst,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;
output detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy; 
reg [1:0]temp_adr;
parameter DA=3'b000,
	LFD=3'b001,
	L_D=3'b010,
	LP=3'b011,
	FFS=3'b100,
	LAF=3'b101,
	CPE=3'b110,
	WTE=3'b111;
reg [2:0]state,next_state;
always@(posedge clk)
begin
	if(~rst)
		state<=DA;
	else if(soft_reset_0||soft_reset_1||soft_reset_2)
		state<=DA;
	else
		state<=next_state;
end
always@(*)
begin
	next_state=DA;
	case(state)
		DA:
			if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0)||(pkt_valid && (data_in[1:0]==1) && fifo_empty_1)||(pkt_valid && (data_in[1:0]==2) && fifo_empty_2))
				next_state = LFD;
		
			
			else if((pkt_valid && (data_in[1:0]==0) && ~fifo_empty_0)||(pkt_valid && (data_in[1:0]==1) && ~fifo_empty_1)||(pkt_valid && (data_in[1:0]==2) && ~fifo_empty_2))
				next_state = WTE;
			else
				next_state = DA;
		LFD: next_state = L_D;
		L_D:
			if(~fifo_full && ~pkt_valid)
				next_state =LP;
			else if(fifo_full)
					next_state =FFS;
			else
				next_state =L_D;
		FFS:
			if(~fifo_full)
				next_state =LAF;
			else
				next_state=FFS;
		LAF:
			if(~parity_done && ~low_pkt_valid)
				next_state=L_D;
			else if(~parity_done && low_pkt_valid)
				next_state = LP;
			else
				next_state = DA;
		LP:  next_state=CPE;
		CPE:
			if(fifo_full)
				next_state=FFS;
			else if(~fifo_full)
				next_state=DA;
		WTE:
			if((fifo_empty_0 && (data_in==0)) || (fifo_empty_1 && (data_in==1)) || (fifo_empty_2 && (data_in==2)))
				next_state= LFD;
			else
				next_state=WTE;
	endcase
end
assign lfd_state=(state==LFD)?1'b1:1'b0;
assign ld_state=(state==L_D)?1'b1:1'b0;
assign write_enb_reg=(state==L_D ||state== LAF ||state== LP)?1'b1:1'b0;
assign laf_state=(state==LAF)?1'b1:1'b0;
assign full_state=(state==FFS)?1'b1:1'b0;
assign rst_int_reg=(state==CPE)?1'b1:1'b0;
assign detect_add=(state==DA)?1'b1:1'b0;
assign busy=(state==DA||state==L_D)?1'b0:1'b1;
endmodule


*/
