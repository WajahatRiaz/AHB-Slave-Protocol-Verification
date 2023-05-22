//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        driver.sv			    										    //
//                                                                          //
// Description:                                                             //
//             Drives the generated stimulus to the design                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
`define DRIV_IF vif.DRIVER.cb_driver
class driver;

	transaction trans;               // handle of the transaction class
	mailbox #(transaction) gen2drv;  // mailbox to receive data from generator
	int local_count = 0;             // local count to keep track of our transactions
	int no_transaction;              // max limit of transactions
	virtual dut_interface vif;       // pointer to our interface to connect with DUT

	// The new constructor for initialization
	function new(mailbox #(transaction) gen2drv, virtual dut_interface vif, int no_transaction);
		this.gen2drv = gen2drv;
		this.vif = vif;
		this.no_transaction = no_transaction;
	endfunction
	
	// what hresetn (global signal) can do
		task reset();
		// since hresetn is the only active low signal 
		wait(!vif.hresetn); 
		// Initializing all values to valid levels
		`DRIV_IF.hsel<=0;
		`DRIV_IF.haddr<=0;
		`DRIV_IF.htrans<=0;
		`DRIV_IF.hwrite<=0;
		`DRIV_IF.hsize<=0;
		`DRIV_IF.hburst<=0;
		`DRIV_IF.hprot<=0;
		`DRIV_IF.hwdata<=0;
		`DRIV_IF.error<=0;
		// we want to wait for the hresetn to be high again
		wait(vif.hresetn);
	endtask

	// driving our signals to DUT
	task drive();
		trans = new(); 
		while (local_count < no_transaction)begin
  			// getting the transaction from the generator
  			gen2drv.get(trans);  
			// waiting for the clocking block event		
			@(`DRIV_IF);
			
			`DRIV_IF.hsel<=trans.hsel;
			`DRIV_IF.hwrite<=trans.hwrite;
			`DRIV_IF.htrans<=trans.htrans;
			`DRIV_IF.hsize<=trans.hsize;
			`DRIV_IF.hburst<=trans.hburst;
			`DRIV_IF.hprot<=trans.hprot;
			`DRIV_IF.error<=trans.error;
			`DRIV_IF.haddr<=trans.haddr;
			`DRIV_IF.hwdata<=trans.hwdata;
			
			// waiting for hready signal to be 1 i.e. transfer completed / error cycle two completed
			wait(`DRIV_IF.hready);
			local_count++;
		end
	endtask

	task main();
    	wait(vif.hresetn);  // waiting for the hresetn to be asserted so that we can send stimulus to DUT
		drive();            // calling the drive method to pass signals to DUT
  	endtask
endclass

