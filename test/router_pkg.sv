package router_pkg; 
	//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv
	`include "uvm_macros.svh"
	//`include "tb_defs.sv"
	//`include "write_xtn.sv"
	`include "source_xtn.sv"
	`include "source_agt_config.sv"
	`include "dest_agt_config.sv"	
	
	`include "tb_config.sv"
	`include "source_driver.sv"
	`include "source_monitor.sv"
	
	`include "source_sequencer.sv"
	`include "source_agent.sv"
	`include "source_agt_top.sv"
	
	`include "dest_xtn.sv"
	`include "dest_monitor.sv"
	`include "dest_sequencer.sv"
	`include "dest_seqs.sv"
	`include "dest_driver.sv"
	`include "dest_agent.sv"
	`include "dest_agt_top.sv"
	`include "source_seqs.sv"
	
	//virtual sequence and sequencer; 	
	`include "virtual_seqr.sv"
	`include "virtual_seqs.sv"
	`include "scoreboard.sv"

	`include "environment.sv"
	
	`include "test.sv"
endpackage
