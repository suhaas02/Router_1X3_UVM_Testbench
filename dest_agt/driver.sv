class dest_driver extends uvm_driver; 
	`uvm_component_utils(dest_driver)
	virtual dest_if vif; 
	dest_agt_config d_cfg;
	function new(string name = "dest_driver", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(dest_agt_config)::get(this, "", "dest_agt_config", d_cfg)); 
	endfunction 

	function void connect_phase(uvm_phase phase); 
		vif = d_cfg.vif; 
	endfunction 
endclass 
