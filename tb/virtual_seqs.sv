class virtual_seqs extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(virtual_seqs)

	tb_config tb_cfg; 
	dest_sequencer dseqr[]; 
	source_sequencer sseqr[];
	virtual_seqr vseqr;   	
	function new(string name = "virtual_seqs"); 
		super.new(name); 
	endfunction 

	task body(); 
		assert(uvm_config_db #(tb_config)::get(null, get_full_name, "tb_config", tb_cfg)); 
		dseqr = new[tb_cfg.no_of_dagts]; 
		sseqr = new[tb_cfg.no_of_sagts]; 
		
		if(!$cast(vseqr, m_sequencer))
			`uvm_fatal(get_full_name, "Pointing of m_seqr to v_seqr has been failed")

		foreach(dseqr[i])
			dseqr[i] = vseqr.dseqr[i];
		foreach(sseqr[i])
			sseqr[i] = vseqr.sseqr[i]; 
	endtask 
endclass

/*
class virtual_seqs_extd extends virtual_seqs; 
	`uvm_object_utils(virtual_seqs_extd)
	source_small_packet_seq sseq_1; 
	source_medium_packet_seq sseq2; 
	source_big_packet_seq sseq3; 
	dest_small_packet dseq1; 
	dest_corrupt_packet dseq2; 

	function new(string name = "virtual_seqs_extd");
		super.new(name); 
	endfunction 
	
	task body;
		super.body(); 

		sseq1 = source_small_packet_seq::type_id::create("sseq1");
		sseq2 = source_medium_packet_seq::type_id::create("sseq2"); 
		sseq3 = source_big_packet_seq::type_id::create("sseq3"); 

		repeat(2)
			begin 
				foreach(sseqr[i])
					begin 
						
					end	
			end		

endclass
*/

class small_vseq extends virtual_seqs; 
	`uvm_object_utils(small_vseq)
	src_small_packet_seq sseq_1; 
	dest_small_packet dseq_1; 

	function new(string name = "small_vseq"); 
		super.new(name);
	endfunction 

	task body(); 
		super.body(); 
		sseq_1 = src_small_packet_seq::type_id::create("sseq_1");
		dseq_1 = dest_small_packet::type_id::create("dseq_1"); 
		repeat(3)	
			begin 
				fork
					//foreach(sseqr[i])
begin
						sseq_1.start(sseqr[0]);
end
begin
					//foreach(dseqr[i])
						dseq_1.start(dseqr[tb_cfg.addr]);
end	
						$display("here is address: %d", tb_cfg.addr); 
				join 
			end		
	endtask 
endclass

class medium_vseq extends virtual_seqs; 
	`uvm_object_utils(medium_vseq)
	src_medium_packet_seq sseq_2; 
	dest_corrupt_packet dseq_2; 

	function new(string name = "medium_vseq"); 
		super.new(name);
	endfunction 

	task body(); 
		super.body(); 
		sseq_2 = src_medium_packet_seq::type_id::create("sseq_2");
		dseq_2 = dest_corrupt_packet::type_id::create("dseq_2"); 
		repeat(2)	
			begin 
				fork
					//foreach(sseqr[i])
						sseq_2.start(sseqr[0]);
					//foreach(dseqr[i])
						dseq_2.start(dseqr[tb_cfg.addr]); 
				join
			end		
	endtask 
endclass

//still write 2rd seq, i.e big packet
class big_vseq extends virtual_seqs; 
	`uvm_object_utils(big_vseq)
	src_big_packet_seq sseq_3; 
	dest_corrupt_packet dseq_2; 

	function new(string name = "big._vseq"); 
		super.new(name);
	endfunction 

	task body(); 
		super.body(); 
		sseq_3 = src_big_packet_seq::type_id::create("sseq_3");
		dseq_2 = dest_corrupt_packet::type_id::create("dseq_2"); 
		//repeat(2)
		for(int i = 0; i < 2; i++)	
			begin 
				fork
					//foreach(sseqr[i])
						sseq_3.start(sseqr[0]);
					//foreach(dseqr[i])
						dseq_2.start(dseqr[tb_cfg.addr]); 
				join
			end		
	endtask 
endclass
 
