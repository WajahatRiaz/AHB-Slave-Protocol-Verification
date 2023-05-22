//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_all_read.sv   											//
//                                                                          //
// Description:                                                             //
// 			Add a test case for all read transactions using pre_randomize   //
//          method for checking reset state of design memory.               //         
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_all_read(dut_interface vif);
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();

			hwrite.rand_mode(0);
			hwrite = 0;          // we want all read transfers

		endfunction
	endclass
	
	environment env;             // handle of our environment class
	xtransaction xtrans;         // handle to our child class
	int no_transaction = 20;     // defined n number of transactions

	initial begin
		// initialization/instantiations
		env = new(vif, no_transaction);
		xtrans = new();
		env.gen.blueprint =xtrans;   
		// calling the run method of the environment class
		env.run();
	end

endprogram
