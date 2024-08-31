class scoreboard extends uvm_scoreboard; 
	`uvm_component_utils(scoreboard)
	uvm_tlm_analysis_fifo #(source_xtn) source_fifo; 
	uvm_tlm_analysis_fifo #(dest_xtn) dest_fifo[]; 
	tb_config tb_cfg; 
	source_xtn sxtn; 
	dest_xtn dxtn;
	
	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 

		uvm_config_db #(tb_config)::get(this, "", "tb_config", tb_cfg); 
			endfunction 
	
	covergroup source; 
		address : coverpoint sxtn.header[1:0]{
				illegal_bins add = {3};}
		payload_size: coverpoint sxtn.header[7:2]{
				bins small_pkt = {[1: 16]};
				bins mid_pkt = {[17:40]}; 
				bins big_pkt = {[41:63]}; 
			}
 
	//	payload: coverpoint sxtn.payload;
	//	parity : coverpoint sxtn.parity; 
	//	error : coverpoint sxtn.error; 
	endgroup 

	covergroup destination; 
		address : coverpoint dxtn.header[1:0]{
				illegal_bins add = {3};}
		payload_size: coverpoint dxtn.header[7:2]{
				bins small_pkt = {[1: 16]};
				bins mid_pkt = {[17:40]}; 
				bins big_pkt = {[41:63]}; 
			}

	endgroup 
	function new(string name = "scoreboard", uvm_component parent); 
		super.new(name, parent); 
		source_fifo = new("source_fifo", this); 
		dest_fifo = new[3];
		
		foreach(dest_fifo[i])
			dest_fifo[i] = new($sformatf("dest_fifo[%0d]", i), this); 
		source = new; 
		destination = new; 

	endfunction 

	task run_phase(uvm_phase phase); 
		fork 
			begin 
				forever 
					begin 
						source_fifo.get(sxtn);
						//	$display("sxtn: %p", sxtn); 
						source.sample();  
					end
			end

			begin 
				forever
				begin
					fork 
						begin 
							dest_fifo[0].get(dxtn); 
							destination.sample(); 
							check_data(dxtn); 
						end
						
						begin 
							dest_fifo[1].get(dxtn); 
							destination.sample(); 
							check_data(dxtn); 
						end

						begin 
							dest_fifo[2].get(dxtn); 
							destination.sample(); 
							check_data(dxtn); 
						end
					join_any
					disable fork;
				end 
			end
		join 
	endtask  
	
	task check_data(dest_xtn dxtn);
	`uvm_info(get_type_name(),$sformatf("source_xtn %s dest_xtn %s",sxtn.sprint,dxtn.sprint),UVM_LOW) 
		if(sxtn.header == dxtn.header)	
			`uvm_info(get_full_name, "Header compared successfully", UVM_LOW)
		else
			`uvm_info(get_full_name, "Header mismatch", UVM_LOW)

		if(sxtn.payload == dxtn.payload)	
			`uvm_info(get_full_name, "Payload compared successfully", UVM_LOW)
		else
			`uvm_info(get_full_name, "Payload mismatch", UVM_LOW)

		if(sxtn.parity == dxtn.parity)	
			`uvm_info(get_full_name, "Parity compared successfully", UVM_LOW)
		else
			`uvm_info(get_full_name, "Parity mismatch", UVM_LOW)


	endtask 	
	
endclass
