module top;
	import router_pkg::*; 
	import uvm_pkg::*; 
	`include "uvm_macros.svh" 
	
	bit clock; 
	always #10 clock = ~clock; 
	source_if sif0(clock); 
	dest_if dif0(clock); 
	dest_if dif1(clock); 
	dest_if dif2(clock); 
	/*
	router_top DUV(.clock(clock), .busy(sif0.busy), .err(sif0.error), .data_in(sif0.data_in), .pkt_valid(sif0.pkt_valid), .resetn(sif0.resetn), .vld_out_0(dif0.vld_out), .vld_out_1(dif1.vld_out), .vld_out_2(dif2.vld_out), .read_enb_0(dif0.read_enb), .read_enb_1(dif1.read_enb), .read_enb_2(dif2.read_enb), .data_out_0(dif0.data_out), .data_out_1(dif1.data_out), .data_out_2(dif2.data_out)); 
	*/

	//pd code
	/*
	router_top DUV(.clk(clock), .busy(sif0.busy), .err(sif0.error), .data_in(sif0.data_in), .pkt_valid(sif0.pkt_valid), .rst(sif0.resetn), .vld_out_0(dif0.vld_out), .vld_out_1(dif1.vld_out), .vld_out_2(dif2.vld_out), .read_enb_0(dif0.read_enb), .read_enb_1(dif1.read_enb), .read_enb_2(dif2.read_enb), .dout_out_0(dif0.data_out), .dout_out_1(dif1.data_out), .dout_out_2(dif2.data_out)); 
	*/
	
	router_top DUV(.clock(clock),
		.resetn(sif0.resetn),
		.read_enb_0(dif0.read_enb),
		.read_enb_1(dif1.read_enb),
		.read_enb_2(dif2.read_enb),
		.pkt_valid(sif0.pkt_valid),
		.data_in(sif0.data_in),
		.data_out_0(dif0.data_out),
		.data_out_1(dif1.data_out),
		.data_out_2(dif2.data_out),
		.valid_out_0(dif0.vld_out),
		.valid_out_1(dif1.vld_out),
		.valid_out_2(dif2.vld_out),
		.error(sif0.error),
		.busy(sif0.busy));


	initial 
		begin
			`ifdef VCS
			$fsdbDumpvars(0,top);
			`endif 
			uvm_config_db #(virtual source_if)::set(null, "*", "sif0", sif0); 
			uvm_config_db #(virtual dest_if)::set(null, "*", "dif0", dif0); 
			uvm_config_db #(virtual dest_if)::set(null, "*", "dif1", dif1); 
			uvm_config_db #(virtual dest_if)::set(null, "*", "dif2", dif2); 
			uvm_top.enable_print_topology = 1; 
			run_test(); 
		end

	
	property pkt_vld; 	
		@(posedge clock) $rose(sif0.pkt_valid) |=> sif0.busy; 
	endproperty 

	property stable; 
		@(posedge clock) sif0.busy |=> $stable(sif0.data_in); 
	endproperty 

	property rd_enb1; 
		@(posedge clock) $rose(dif0.vld_out) |=> ##[0:29] (dif0.read_enb);
	endproperty 

	property rd_enb2; 
		@(posedge clock) $rose(dif1.vld_out) |=> ##[0:29] (dif1.read_enb);
	endproperty 	

	property rd_enb3; 
		@(posedge clock) $rose(dif2.vld_out) |=> ##[0:29] (dif2.read_enb);
	endproperty 	

	/*
	property vld_out1; 
	//	@(posedge clock) 
			bit[1:0]addr;
        	@(posedge clock) ($rose(in.pkt_valid)addr = in.data_in[1:0]) ##3 (addr==0) | ->in0.v_out;	
	endproperty 

	property vld_out2; 
	//	@(posedge clock) 
			bit[1:0]addr;
        	@(posedge clock) ($rose(in.pkt_valid)addr = in.data_in[1:0]) ##3 (addr==0) | ->in0.v_out;	
	endproperty 

	property vld_out2; 
	//	@(posedge clock) 
			bit[1:0]addr;
        	@(posedge clock) ($rose(in.pkt_valid)addr = in.data_in[1:0]) ##3 (addr==0) | ->in0.v_out;	
	endproperty 
	*/

	property valid ; 
		@(posedge clock)
        $rose(sif0.pkt_valid)|->##3 dif0.vld_out| dif1.vld_out| dif2.vld_out;
	endproperty 

	property read_1;
      //  bit[1:0]addr;
        @(posedge clock)
        $fell(dif0.vld_out) |-> $fell(dif0.read_enb);
endproperty

property read_2;
      //  bit[1:0]addr;
        @(posedge clock)
        $fell(dif1.vld_out) |=> $fell(dif1.read_enb);
endproperty

property read_3;
      //  bit[1:0]addr;
        @(posedge clock)
        $fell(dif2.vld_out) |=> $fell(dif2.read_enb);
endproperty


	pkt_valid: cover property(pkt_vld); 
	stable_data_in: cover property(stable); 
	read_enb1: cover property (rd_enb1); 
	read_enb2: cover property (rd_enb2); 
	read_enb3: cover property (rd_enb3); 
	valid_out: cover property (valid); 	
	vld_out_read1: cover property(read_1); 
	vld_out_read2: cover property(read_2); 
	vld_out_read3: cover property(read_3); 
	

endmodule 
			
	
