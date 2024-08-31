class source_seqs extends uvm_sequence #(source_xtn); 
	`uvm_object_utils(source_seqs)
	tb_config m_cfg; 
	function new(string name = "source_seqs"); 	
		super.new(name); 
	endfunction 
endclass

class src_small_packet_seq extends source_seqs; 
	`uvm_object_utils(src_small_packet_seq)
	
	function new(string name = "src_small_packet_seq"); 
		super.new(name); 
	endfunction 

	task body();
	//	repeat(2)
		begin 
		assert(uvm_config_db #(tb_config)::get(null,get_full_name, "tb_config", m_cfg)); 

		req = source_xtn::type_id::create("req"); 
		start_item(req); 
		assert(req.randomize() with {header[7:2] inside {[1:20]};
					    header[1:0] == m_cfg.addr;});
		finish_item(req);
		end 
	endtask 
endclass

class src_medium_packet_seq extends source_seqs; 
	`uvm_object_utils(src_medium_packet_seq)
	
	function new(string name = "src_medium_packet_seq");
		super.new(name); 
	endfunction 

	task body(); 
		assert(uvm_config_db #(tb_config)::get(null,get_full_name, "tb_config", m_cfg)); 

		req = source_xtn::type_id::create("req"); 	
		start_item(req); 
		assert(req.randomize() with {header[7:2] inside {[21:40]};
					     header[1:0] == m_cfg.addr;});
		finish_item(req); 
	endtask 
endclass

class src_big_packet_seq extends source_seqs; 
	`uvm_object_utils(src_big_packet_seq)
	
	function new(string name = "src_big_packet_seq");
		super.new(name); 
	endfunction 

	task body(); 
		assert(uvm_config_db #(tb_config)::get(null,get_full_name, "tb_config", m_cfg)); 

		req = source_xtn::type_id::create("req"); 	
		start_item(req); 
		assert(req.randomize() with {header[7:2] inside {[41:60]};
					     header[1:0] == m_cfg.addr;});
		finish_item(req); 
	endtask 
endclass

				     	
		                       
//class 
	//for random parity                                                                                                                                                                          
