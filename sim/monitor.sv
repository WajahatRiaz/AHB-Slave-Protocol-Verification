//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        monitor.sv													    //
//                                                                          //
// Description:                                                             //
//           Monitor the design input/output ports to capture activity      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
`define MON_IF vif.MONITOR.cb_monitor
class monitor;
	
	transaction trans;                 // transaction class handle
	mailbox #(transaction) mon2scor;   // mailbox to send data from monitor to scoreboard
	int no_transaction;                // max count of transactions
	int local_count = 0;               // local count to keep track of the transactions completed
	virtual dut_interface vif;         // pointer to the interface of DUT
	
	// The new constructor for initialization
	function new(mailbox #(transaction) mon2scor, virtual dut_interface vif, int no_transaction);
		this.mon2scor = mon2scor;
		this.vif = vif;
		this.no_transaction = no_transaction;
	endfunction

  task main();
		trans = new();
		while(local_count < no_transaction) begin
			// sampling data from the interface of the DUT
			trans.hsel<=`MON_IF.hsel;
			trans.haddr<=`MON_IF.haddr;
			trans.htrans<=`MON_IF.htrans;
			trans.hwrite<=`MON_IF.hwrite;
			trans.hsize<=`MON_IF.hsize;
			trans.hburst<=`MON_IF.hburst;
			trans.hprot<=`MON_IF.hprot;
			trans.error<=`MON_IF.error;
			// waiting for the clocking block event
			@(`MON_IF);
			trans.hready=`MON_IF.hready;
			trans.hresp=`MON_IF.hresp;
			trans.hwdata=`MON_IF.hwdata;
			trans.hrdata=`MON_IF.hrdata;
			//sending data to scoreboard via the mailbox
			mon2scor.put(trans);
			local_count++;
        end
	endtask
endclass

