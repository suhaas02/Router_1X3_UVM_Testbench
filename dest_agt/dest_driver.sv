class dest_driver extends uvm_driver #(dest_xtn); 
	`uvm_component_utils(dest_driver)
	virtual dest_if.drv_mp vif; 
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

	task run_phase(uvm_phase phase); 
		forever 
			begin 
				seq_item_port.get_next_item(req); 
				send_to_dut(req); 
				seq_item_port.item_done(); 
			end
	endtask 

	task send_to_dut(dest_xtn xtn); 
		while(vif.drv_cb.vld_out !== 1)
			@(vif.drv_cb);
		repeat(xtn.delay)
			@(vif.drv_cb); 
		
		vif.drv_cb.read_enb <= 1'b1;
	//	wait(vif.drv_cb.vld_out == 0);
		while(vif.drv_cb.vld_out !==0)
		@(vif.drv_cb);
	
	//	@(vif.drv_cb); 
		vif.drv_cb.read_enb <= 1'b0; 
		`uvm_info(get_type_name, $sformatf("Printing from destination driver 1 %s", xtn.sprint()), UVM_LOW)
	endtask 
endclass 
