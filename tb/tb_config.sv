class tb_config extends uvm_object; 
	`uvm_object_utils(tb_config)
	source_agt_config s_cfg[]; 
	dest_agt_config d_cfg[];
	int no_of_sagts = 1;
	int no_of_dagts = 3;
	bit has_scoreboard = 1;
	bit [1:0] addr;  
	function new(string name = "tb_config");
		super.new(name); 
	endfunction 

endclass
