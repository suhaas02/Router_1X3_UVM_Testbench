class dest_seqs extends uvm_sequence #(dest_xtn); 
	`uvm_object_utils(dest_seqs)
	tb_config m_cfg;
	function new(string name = "dest_seqs");
		super.new(name); 
	endfunction 

	
endclass

class dest_small_packet extends dest_seqs; 
	`uvm_object_utils(dest_small_packet); 
	
	function new(string name = "dest_small_packet"); 
		super.new(name); 
	endfunction 

	task body();
	//	repeat(2)
 begin 
	//	assert(uvm_config_db #(tb_config)::get(null, get_full_name(), "tb_config", m_cfg)); 
		req = dest_xtn::type_id::create("req"); 
		start_item(req); 
		assert(req.randomize() with {delay inside {[1:9]};});
		finish_item(req);
		end 
	endtask 

endclass

class dest_corrupt_packet extends dest_seqs; 
	`uvm_object_utils(dest_corrupt_packet)
	
	function new(string name = "dest_corrupt_packet"); 
		super.new(name); 
	endfunction 

	task body(); 
	//	assert(uvm_config_db #(tb_config)::get(this, "", "tb_config", m_cfg)); 
		req = dest_xtn::type_id::create("req"); 
		start_item(req); 
		assert(req.randomize() with {delay == 25;}); 
		finish_item(req); 
	endtask 
endclass  
