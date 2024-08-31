class source_agt_top extends uvm_env;
	`uvm_component_utils(source_agt_top)
	source_agent sagt[]; 
	tb_config tb_cfg; 
	function new(string name = "source_agt_top", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(tb_config)::get(this, "", "tb_config", tb_cfg)); 
		sagt = new[tb_cfg.no_of_sagts]; 
		foreach(sagt[i])
			begin 
				uvm_config_db #(source_agt_config)::set(this, $sformatf("sagt[%0d]*", i), "source_agt_config", tb_cfg.s_cfg[i]);
				sagt[i] = source_agent::type_id::create($sformatf("sagt[%0d]", i), this);    
			end	
	endfunction 
endclass
