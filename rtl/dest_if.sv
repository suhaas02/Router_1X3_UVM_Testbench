interface dest_if(input bit clock); 
	bit read_enb; 
	logic [7:0] data_out; 
	bit vld_out; 
	
	clocking drv_cb @(posedge clock); 
		default input #1 output #1; 
		output read_enb; 
		input vld_out; 
	endclocking 
	
	clocking mon_cb @(posedge clock); 
		default input #1 output #1; 
		input read_enb, data_out, vld_out; 
	endclocking 

	modport drv_mp(clocking drv_cb); 
	modport mon_mp(clocking mon_cb);  

endinterface 
	
