class dest_xtn extends uvm_sequence_item; 
	//`uvm_object_utils(dest_xtn)
	
	bit [7:0] header; 
	bit [7:0] payload[];
	bit [7:0] parity; 
	rand bit [5:0] delay; 
	
	`uvm_object_utils_begin(dest_xtn)
		`uvm_field_int(header, UVM_ALL_ON +UVM_BIN)
		`uvm_field_array_int(payload, UVM_ALL_ON +UVM_DEC)	
		`uvm_field_int(parity, UVM_ALL_ON +UVM_DEC)
		`uvm_field_int(delay, UVM_ALL_ON +UVM_DEC)
	`uvm_object_utils_end
	
	function new(string name = "dest_xtn"); 
		super.new(name); 
	endfunction 

endclass 

	
