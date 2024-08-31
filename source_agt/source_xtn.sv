class source_xtn extends uvm_sequence_item; 
	//`uvm_object_utils(source_xtn)
	rand bit[7:0] header; 
	rand bit [7:0] payload[]; 
	bit [7:0] parity; 	
	bit pkt_valid; 
	bit resetn; 
	bit error; 
//	bit clock; 
	constraint range{ header[1:0] != 2'b11; 
			  payload.size() == header[7:2]; 
			  header[7:2] != 0;};	
	`uvm_object_utils_begin(source_xtn)		
		`uvm_field_int(header, UVM_ALL_ON +UVM_DEC)	
		`uvm_field_array_int(payload, UVM_ALL_ON +UVM_DEC)
		`uvm_field_int(parity, UVM_ALL_ON +UVM_DEC)
		`uvm_field_int(pkt_valid, UVM_ALL_ON)
		`uvm_field_int(resetn, UVM_ALL_ON)
		`uvm_field_int(error, UVM_ALL_ON)
	`uvm_object_utils_end
	function new(string name = "source_xtn");
		super.new(name); 
	endfunction

	//overriding do_print virtual method
	/*
	virtual function void do_print(uvm_printer printer);
		printer.print_field("header", head, 8, UVM_DEC); 
		printer.print_field("parity", parity, 8, UVM_DEC); 
		//payload 
		//complete this do_print method
	endfunction
	*/
	function void post_randomize(); 
		parity = header; 
		foreach(payload[i])
			parity = parity ^ payload[i]; 
	endfunction    
endclass 

