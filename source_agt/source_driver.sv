class source_driver extends uvm_driver #(source_xtn) ; 
	`uvm_component_utils(source_driver)
	virtual source_if.drv_mp vif; 
	source_agt_config s_cfg;
	function new(string name = "source_driver", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(source_agt_config)::get(this, "", "source_agt_config", s_cfg)); 
	endfunction 

	function void connect_phase(uvm_phase phase); 
		vif = s_cfg.vif; 
	endfunction

	task run_phase(uvm_phase phase); 
		forever 
			begin 
				seq_item_port.get_next_item(req); 
				@(vif.drv_cb);
					vif.drv_cb.resetn <= 0; 
				@(vif.drv_cb);
					vif.drv_cb.resetn <= 1; 
 
				drive_to_dut(req); 
				seq_item_port.item_done(); 
			end
	endtask  

	task drive_to_dut(source_xtn xtn); 
	
		//	@(vif.drv_cb);
		wait(vif.drv_cb.busy == 0);
		//while(vif.drv_cb.busy !== 0)
		//	@(vif.drv_cb); 
		@(vif.drv_cb);
		vif.drv_cb.pkt_valid <= 1'b1; 
		vif.drv_cb.data_in <= xtn.header; 
		@(vif.drv_cb); 		
	//	`uvm_info("Source driver", $sformatf("Printing from source driver %s", xtn.sprint()), UVM_LOW)
		foreach(xtn.payload[i])
			begin 
				while(vif.drv_cb.busy !== 1'b0)
					@(vif.drv_cb); 
				vif.drv_cb.data_in <= xtn.payload[i]; 
				@(vif.drv_cb); 
			end 
		while(vif.drv_cb.busy !== 0) // ; SEMI-COLON IS NOT EXPECTED
			@(vif.drv_cb);
		vif.drv_cb.pkt_valid <= 1'b0; 
		vif.drv_cb.data_in <= xtn.parity; 
		repeat(30)
			@(vif.drv_cb); 
//		repeat(40)
//			@(vif.drv_cb); 
	
		`uvm_info("Source driver", $sformatf("Printing from source driver %s", xtn.sprint()), UVM_LOW)
				 
	endtask 
		
endclass 

