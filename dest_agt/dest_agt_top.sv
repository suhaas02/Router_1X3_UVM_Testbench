class dest_agt_top extends uvm_env;
	`uvm_component_utils(dest_agt_top)
	dest_agent dagt[]; 
	tb_config tb_cfg; 
	function new(string name = "dest_agt_top", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(tb_config)::get(this, "", "tb_config", tb_cfg)); 
		dagt = new[tb_cfg.no_of_dagts]; 
		foreach(dagt[i])
			begin 
				uvm_config_db #(dest_agt_config)::set(this, $sformatf("dagt[%0d]*", i),"dest_agt_config" , tb_cfg.d_cfg[i]);
				dagt[i] = dest_agent::type_id::create($sformatf("dagt[%0d]", i), this);    
			end	
	endfunction 
endclass

