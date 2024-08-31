interface source_if(input bit clock); 
	bit [7:0] data_in; 
	bit resetn; 
	bit pkt_valid; 
	bit error; 
	bit busy; 
	

	clocking drv_cb @(posedge clock);
		default input #1 output #1;  
		output data_in, resetn, pkt_valid; 
		input busy, error; 
	endclocking 
		
	clocking mon_cb @(posedge clock); 
		default input #1 output #1; 	
		input data_in, resetn, pkt_valid, busy, error; 
	endclocking 

	modport drv_mp(clocking drv_cb);
	modport mon_mp(clocking mon_cb);
endinterface 	
