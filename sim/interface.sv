//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        interface.sv													    //
//                                                                          //
// Description:                                                             //
//             Contains design signals that can be driven or monitored      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
interface dut_interface(input logic hclk, input logic hresetn);
	
	logic 		hsel;
	logic [31:0] 	haddr;
	logic [1:0] 	htrans;
	logic 		hwrite;
	logic [2:0] 	hsize;
	logic [2:0]	hburst;
	logic [3:0]     hprot;
	logic [31:0]	hwdata;
	
	logic [31:0]	hrdata;
	logic 		hready;
	logic 		hresp;
	wor 		error;

clocking cb_driver @(posedge hclk);
	default input #1 output #1;
	output hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, error;
	input hrdata, hresp, hready;
endclocking

clocking cb_monitor @(posedge hclk);
	default input #1 output #1;
	input hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, error;
	input hrdata, hready, hresp;
endclocking

modport DRIVER(clocking cb_driver, input hclk, hresetn);
modport MONITOR(clocking cb_monitor, input hclk, hresetn);

endinterface
