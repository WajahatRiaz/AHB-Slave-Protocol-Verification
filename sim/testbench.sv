//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Test bench to verify AMBA AHB bus slave protocol(simple memory model)   //
//                                                                          //
//  Author: Wajahat Riaz			                                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"
//`include "test_bonus_rw.sv"
//`include "test_bonus_all_read.sv"
//`include "test_bonus_all_write.sv"
//`include "test_bonus_IDLE_NONSEQ.sv"
//`include "test_bonus_no_slave.sv"
//`inlcude "test_bonus_no_data_acces.sv"

module tb_top;

	bit hclk;       // global clock signal
	bit hresetn;    // global reset signal

    // generating our clock signal
	initial begin
		hclk = 0;	
		forever #5 hclk = ~hclk;
	end

	// using the reset signal to initialize all signals to valid levels
	initial begin
		hresetn = 0;	
		#5 hresetn = 1; 
	end
	
	// instancs of the interface and passing the global signals
	dut_interface vif(hclk, hresetn);

	// instance of our dut (AHB slave memory) and assiging ports
	 amba_ahb_slave slave_1(
		.hclk(vif.hclk),
		.hresetn(vif.hresetn),
		.hsel(vif.hsel),
		.haddr(vif.haddr),
		.htrans(vif.htrans),
		.hwrite(vif.hwrite),
		.hsize(vif.hsize),
		.hburst(vif.hburst),
		.hprot(vif.hprot),
		.hwdata(vif.hwdata),
		.hrdata(vif.hrdata),
		.hready(vif.hready),
		.hresp(vif.hresp),
		.error(vif.error)
	);

	// instantiating the tests and passing the interface
	
	 test t1(vif);
   

	// N number of transactions implemented in all tests

	// Add a test case for alternate read/write transactions using the pre_randomize method.	
	
	// test_bonus_rw t2(vif);
	
	// Add a test case for all read transactions using pre_randomize method for checking reset state of design memory.
	
	// test_bonus_all_read t3(vif);
	
	
	// Add a test case for all write transactions using pre_randomize method
	
	// test_bonus_all_write t4(vif);
	
	// Add a test case for all write transactions using pre_randomize method
	
	//test_bonus_IDLE_NONSEQ t5(vif);
	
	// test case to check response incase slave gets disconnected
	
	// test_bonus_no_slave t6(vif);
	
	// test case to check response in case bypassing priviledge level
	//test_bonus_no_data_acces

	initial begin
	// initial block for dumping and creating necessary file for gtkwave
		$dumpvars;
		$dumpfile("dump.vcd");
	end


endmodule




