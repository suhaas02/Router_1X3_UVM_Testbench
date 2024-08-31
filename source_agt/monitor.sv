class source_monitor extends uvm_monitor; 
	`uvm_component_utils(source_monitor)
	virtual source_if vif; 
	source_agt_config s_cfg;
	function new(string name = "source_monitor", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(source_agt_config)::get(this, "", "source_agt_config", s_cfg)); 
	endfunction 

	function void connect_phase(uvm_phase phase); 
		this.vif = s_cfg.vif; 
	endfunction 
endclass	
		
