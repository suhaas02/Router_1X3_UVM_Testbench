 class environment extends uvm_env; 
	`uvm_component_utils(environment)
	tb_config tb_cfg; 
	source_agt_top sagt_top; 
	dest_agt_top dagt_top; 
	virtual_seqr vseqr; 
	scoreboard sbh; 
	function new(string name = "environment", uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		assert(uvm_config_db #(tb_config)::get(this, "", "tb_config", tb_cfg));
		sagt_top = source_agt_top::type_id::create("sagt_top", this);    
			
	
		dagt_top = dest_agt_top::type_id::create("dagt_top", this);    
		vseqr = virtual_seqr::type_id::create("vseqr", this);
		sbh = scoreboard::type_id::create("sbh", this); 
		
	endfunction 

	//connect phase, only for connecting the virtual sequencer with the sequencers in agent;
	 
	function void connect_phase(uvm_phase phase); 
		//foreach(tb_cfg.no_of_sagts)
		for(int i = 0; i < tb_cfg.no_of_sagts; i++)
			vseqr.sseqr[i] = sagt_top.sagt[i].seqrh; 

		//foreach(tb_cfg.no_of_dagts)
		for(int i = 0; i < tb_cfg.no_of_dagts; i++)
			vseqr.dseqr[i] = dagt_top.dagt[i].seqrh; 

		sagt_top.sagt[0].monh.source_port.connect(sbh.source_fifo.analysis_export); 
		for(int i = 0; i < tb_cfg.no_of_dagts; i++)
			dagt_top.dagt[i].monh.dest_port.connect(sbh.dest_fifo[i].analysis_export); 
	endfunction
	 
endclass

	
