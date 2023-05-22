//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test.sv   													    //
//                                                                          //
// Description:                                                             //
//          Contains the environment that can be tweaked with different     //
//          configuration settings                                          //  
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

program automatic test(dut_interface vif);

	// child class to our transaction class
	class xtransaction extends transaction;
	
		// the method called before randomization
		function void pre_randomize();

		endfunction

	endclass

	environment env;             // handle of our environment class
	xtransaction xtrans;         // handle to our child class
	int no_transaction = 100;     // defined n number of transactions

	initial begin
		// initialization/instantiations
		env = new(vif, no_transaction);
		xtrans = new();
		env.gen.blueprint =xtrans;   
		// calling the run method of the environment class
		env.run();
	end
	

endprogram
