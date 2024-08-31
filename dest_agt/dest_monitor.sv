class dest_monitor extends uvm_monitor; 
	`uvm_component_utils(dest_monitor)
	virtual dest_if.mon_mp vif; 
	dest_agt_config d_cfg;
	uvm_analysis_port #(dest_xtn) dest_port; 
	function new(string name = "dest_monitor", uvm_component parent); 
		super.new(name, parent); 
		dest_port = new("dest_port", this); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		//dest_port = uvm_analysis_port::type_id::create("dest_port", this); 
		assert(uvm_config_db #(dest_agt_config)::get(this, "", "dest_agt_config", d_cfg)); 
	endfunction 

	function void connect_phase(uvm_phase phase); 
		vif = d_cfg.vif; 
	endfunction 

	task run_phase(uvm_phase phase);
		//phase.raise_objection(this);
		//#10000;   
		forever
begin 
			collect_data(); 
end
		//phase.drop_objection(this); 
	endtask 

	task collect_data(); 
		dest_xtn xtn; 
		xtn = dest_xtn::type_id::create("xtn"); 
		//wait(vif.mon_cb.read_enb == 1);

		while(vif.mon_cb.read_enb !== 1)
			@(vif.mon_cb);
 
//		wait(vif.mon_cb.read_enb == 1)
		@(vif.mon_cb); //hint  
		xtn.header = vif.mon_cb.data_out; 
		xtn.payload = new[xtn.header[7:2]]; 
		@(vif.mon_cb); 
		foreach(xtn.payload[i])
			begin
				xtn.payload[i] = vif.mon_cb.data_out; 
				@(vif.mon_cb); 
      			end
		
		xtn.parity = vif.mon_cb.data_out;
		 repeat(2)
			@(vif.mon_cb); 
		`uvm_info("dest monitor", $sformatf("Printing from destination monitor %s", xtn.sprint()), UVM_LOW)
		dest_port.write(xtn); 
//repeat(2)
//			@(vif.mon_cb); 

	endtask 
	
endclass	
		

