class dest_agent extends uvm_agent; 
	`uvm_component_utils(dest_agent)
	
	dest_monitor monh; 
	dest_driver drvh; 
	dest_sequencer seqrh; 
	dest_agt_config d_cfg; 
	function new(string name = "dest_agent", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 	
		super.build_phase(phase); 
		assert(uvm_config_db #(dest_agt_config)::get(this, "", "dest_agt_config", d_cfg)); 
		monh = dest_monitor::type_id::create("monh", this); 
		if(d_cfg.is_active == UVM_ACTIVE)
			begin 
				drvh = dest_driver::type_id::create("drvh", this);  
				seqrh = dest_sequencer::type_id::create("seqrh", this); 
			end
	endfunction 

	function void connect_phase(uvm_phase phase); 
		if(d_cfg.is_active == UVM_ACTIVE)
			drvh.seq_item_port.connect(seqrh.seq_item_export); 
	endfunction 
endclass


