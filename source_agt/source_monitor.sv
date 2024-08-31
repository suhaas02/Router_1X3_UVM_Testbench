class source_monitor extends uvm_monitor; 
	`uvm_component_utils(source_monitor)
	virtual source_if.mon_mp vif; 
	source_agt_config s_cfg;
	uvm_analysis_port #(source_xtn) source_port; 
	function new(string name = "source_monitor", uvm_component parent); 
		super.new(name, parent); 
		source_port = new("source_port", this); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		//source_port = uvm_analysis_port::type_id::create("source_port", this); 
		assert(uvm_config_db #(source_agt_config)::get(this, "", "source_agt_config", s_cfg)); 
	endfunction 

	function void connect_phase(uvm_phase phase); 
		vif = s_cfg.vif; 
	endfunction 

	task run_phase(uvm_phase phase); 
		forever
			collect_data(); 
	endtask 

	task collect_data(); 
		source_xtn  xtnh; 
		xtnh = source_xtn::type_id::create("xtnh"); 
	//	@(vif.mon_cb); 
		wait(vif.mon_cb.busy == 0); //it waits until busy becomes 0; 
		while(vif.mon_cb.pkt_valid !== 1)
			@(vif.mon_cb);
		 	//wait(vif.mon_cb.pkt_valid == 1)
		//	@(vif.mon_cb);
				xtnh.header = vif.mon_cb.data_in;
				xtnh.payload = new[xtnh.header[7:2]]; 
 
				@(vif.mon_cb);

				foreach(xtnh.payload[i])
					begin 
						while(vif.mon_cb.busy !== 0) //SHOULD USE !==0 instead of ==1 its a wire z is expected
						@(vif.mon_cb); 
						xtnh.payload[i] = vif.mon_cb.data_in; 
						@(vif.mon_cb);
					end
								
				xtnh.parity = vif.mon_cb.data_in; 
				repeat(2)
					@(vif.mon_cb);
				xtnh.error = vif.mon_cb.error; 
		`uvm_info("source Monitor", $sformatf("Driving from source monitor %s",xtnh.sprint()), UVM_LOW) 
		source_port.write(xtnh); 
	endtask 
endclass	
		
