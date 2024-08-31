class test extends uvm_test; 
	`uvm_component_utils(test)
	environment env_h; 
	//scoreboard sb_h; 
	tb_config tb_cfg; 
	source_agt_config s_cfg[]; 
	dest_agt_config d_cfg[];
	int no_of_sagts = 1; 
	int no_of_dagts = 3; 
 	bit [1:0] addr; 
	function new(string name = "test", uvm_component parent); 	
		super.new(name, parent);
	endfunction 

	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
		tb_cfg = tb_config::type_id::create("tb_cfg"); 
		tb_cfg.s_cfg = new[no_of_sagts]; 
		tb_cfg.d_cfg = new[no_of_dagts]; 
		s_cfg = new[no_of_sagts]; 
		foreach(s_cfg[i])
			begin 
				s_cfg[i] = source_agt_config::type_id::create($sformatf("s_cfg[%0d]", i));
				assert(uvm_config_db #(virtual source_if)::get(this, "", $sformatf("sif%0d", i), s_cfg[i].vif));
				s_cfg[i].is_active = UVM_ACTIVE; 
				tb_cfg.s_cfg[i] = s_cfg[i]; 
			end

		d_cfg = new[no_of_dagts]; 
		foreach(d_cfg[i])
			begin 
				d_cfg[i] = dest_agt_config::type_id::create($sformatf("d_cfg[%0d]", i));
				assert(uvm_config_db #(virtual dest_if)::get(this, "", $sformatf("dif%0d", i), d_cfg[i].vif));
				d_cfg[i].is_active = UVM_ACTIVE; 
				tb_cfg.d_cfg[i] = d_cfg[i]; 
			end

		tb_cfg.no_of_sagts = no_of_sagts; 
		tb_cfg.no_of_dagts = no_of_dagts;
	//	tb_cfg.addr = {$random} % 3; 
		uvm_config_db #(tb_config)::set(this, "*", "tb_config", tb_cfg); 
		env_h = environment::type_id::create("env_h", this); 
	endfunction 
	
	task run_phase(uvm_phase phase); 
		//addr = {$random} % 3; 
	//	assert(this.randomize()); 
	//	uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", addr); 
	endtask 
endclass
	

class small_vtest extends test; 
	`uvm_component_utils(small_vtest)
	src_small_packet_seq small_seq;
	dest_small_packet dsmall_seq;
	bit [1:0] addr; 
	//for virtual sequence; 
	small_vseq sv_seq;
	function new(string name = "small_vtest", uvm_component parent); 
		super.new(name, parent); 
	endfunction 	
	
	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
	endfunction 

	task run_phase(uvm_phase phase);
		//repeat(2)
		//begin 
		phase.raise_objection(this);
		/* 
		small_seq = src_small_packet_seq::type_id::create("small_seq");
		dsmall_seq = dest_small_packet::type_id::create("dsmall_seq"); 
		*/
		//for virtual sequence; 
		sv_seq = small_vseq::type_id::create("sv_seq"); 
 		addr = 0;
		uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", addr); 

		//for normal sequence starting on virtual sequencer; 
		/*
		fork
			small_seq.start(env_h.sagt_top.sagt[0].seqrh); 
			dsmall_seq.start(env_h.dagt_top.dagt[tb_cfg.addr].seqrh);
		join
		//#30;
		*/
		//for virtual sequence; 
		super.run_phase(phase); 
		sv_seq.start(env_h.vseqr); 
		phase.drop_objection(this); 
		//end
	endtask 
endclass

class  medium_vtest extends test; 
	`uvm_component_utils(medium_vtest)
	
	src_medium_packet_seq mid_seq;
	dest_corrupt_packet dcorr_seq; 


	medium_vseq mv_seq; 
	function new(string name = "medium_vtest", uvm_component parent); 
		super.new(name, parent); 
	endfunction 	
	
	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
	endfunction 

	task run_phase(uvm_phase phase); 
		phase.raise_objection(this); 
		//assert(this.randomize()); 
		addr = 1;
		uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", addr); 

		/*	
		mid_seq = src_medium_packet_seq::type_id::create("mid_seq"); 
		dcorr_seq = dest_corrupt_packet::type_id::create("dcorr_seq");
		*/

		//for normal sequence, starting on sequencer; 
		/* 
		fork
			mid_seq.start(env_h.sagt_top.sagt[0].seqrh); 
			dcorr_seq.start(env_h.dagt_top.dagt[tb_cfg.addr].seqrh);
		join
		*/
		super.run_phase(phase);
		mv_seq = medium_vseq::type_id::create("mv_seq"); 
		mv_seq.start(env_h.vseqr); 
		phase.drop_objection(this); 
	endtask 
endclass

//here add virtual sequence and start it; 
class  big_vtest extends test; 
	`uvm_component_utils(big_vtest)
	big_vseq b_seq; 
	/*
	src_big_packet_seq big_seq;
	dest_small_packet dsmall_seq;
	*/
	function new(string name = "big_vtest", uvm_component parent); 
		super.new(name, parent); 
	endfunction 	
	
	function void build_phase(uvm_phase phase); 
		super.build_phase(phase); 
	endfunction 

	task run_phase(uvm_phase phase); 
		phase.raise_objection(this); 
		/*
		big_seq = src_big_packet_seq::type_id::create("big_seq"); 
		dsmall_seq = dest_small_packet::type_id::create("dsmall_seq"); 
		

		fork
			big_seq.start(env_h.sagt_top.sagt[0].seqrh);
			dsmall_seq.start(env_h.dagt_top.dagt[tb_cfg.addr].seqrh);
		join
		*/
		addr = 2;
		uvm_config_db #(bit[1:0])::set(this, "*", "bit[1:0]", addr); 

		super.run_phase(phase); 
		b_seq = big_vseq::type_id::create("b_seq"); 
		b_seq.start(env_h.vseqr); 
	
		phase.drop_objection(this); 
	endtask 
endclass


			
