class virtual_seqr extends uvm_sequencer #(uvm_sequence_item); 

	`uvm_component_utils(virtual_seqr)
	
	tb_config tb_cfg; 
	source_sequencer sseqr[]; 
	dest_sequencer dseqr[]; 
	function new(string name = "virtual_seqr", uvm_component parent);
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(tb_config)::get(this, "", "tb_config", tb_cfg)); 
		sseqr = new[tb_cfg.no_of_sagts]; 
		dseqr = new[tb_cfg.no_of_dagts]; 
		
	endfunction 

	

endclass 
