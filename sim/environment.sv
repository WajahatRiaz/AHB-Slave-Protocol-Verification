//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        environment.sv									    		    //
//                                                                          //
// Description:                                                             //
//          Contains all the verification components in a layered testbench //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
class environment;
  
  	generator gen;      			    // handle to generator class
  	scoreboard scor;    			    // handle to scoreboard class
  	driver drv;         			    // handle to driver class
  	monitor mon;         			    // handle to monitor class
  	mailbox #(transaction) gen2drv;     // mailbox for IPC between generator and monitor
	mailbox #(transaction) mon2scor;    // mailbox for IPC between monitor and scoreboard
	int no_transaction;                 // defines our max transaction limit
	event doneGen;                      // the event to synchronize our generator

  	virtual dut_interface vif;          // pointer to our interface
  	
  	// The new constructor for initializations
  	
	function new(virtual dut_interface vif, int no_transaction);
  	
		gen2drv = new();
		mon2scor = new();
		this.no_transaction=no_transaction;
		this.vif = vif;
    	gen = new(gen2drv, doneGen, no_transaction);
    	drv = new(gen2drv, vif, no_transaction);
    	mon = new(mon2scor, vif, no_transaction);
    	scor = new(mon2scor, no_transaction);    
	endfunction

  // the pre_test to carry out some important tasks before running the actual test
  task pre_test();
	$display("Running pre_test");
	drv.reset();   // reset every signal to valid levels
  
  endtask

  task test();
    $display("Running test");
    // we want to run our main methods to run in parallel
    fork
      gen.main();
      drv.main();
      mon.main();
      scor.main();      
    join_any

    
  endtask

	task post_test();
		// waiting for the generator to send all stimuli to monitor	
		wait(doneGen.triggered);
	  	
	  	// waitng for the follwing events
	  	fork
			wait(drv.local_count == no_transaction);
	  		wait(mon.local_count == no_transaction);
      		wait(scor.local_count== no_transaction);
		join
  
  endtask

	task run();
	    // calling the methods
		pre_test();
		test();
		post_test();
		// ending our simulation
		$finish;
	endtask

endclass
