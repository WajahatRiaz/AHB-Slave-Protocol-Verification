//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_all_read.sv   											//
//                                                                          //
// Description:                                                             //
// 			Add a test case for all write transactions using pre_randomize  //
//                                                                          //         
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_all_write(dut_interface vif);
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();

			hwrite.rand_mode(0);
			hwrite = 1;          // we want all write transfers

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
