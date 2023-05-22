//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_no_slave.sv   										    //
//                                                                          //
// Description:                                                             //
//          Test case if salve is disconnected during transactions          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_no_slave(dut_interface vif);
	bit [3:0] ctrl_rw;   // control bit used to switch between read and write transfers
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();
		
			constraint_hsel.constraint_mode(0);  // disabling the constraint
			hsel.rand_mode(0);     //disabling randomization for hsel 
			
 			if (ctrl_rw == 0) begin
				hsel = 1;
			end
			
			else if (ctrl_rw == 1) begin
			
				hsel = 1;
			end
			
			else if (ctrl_rw == 2) begin
				// Disconnecting slave 
				hsel = 0;
			end
			
			else begin
				
				hsel = 1;
			end
			
			
			ctrl_rw++;
		endfunction
	endclass
	
	environment env;             // handle of our environment class
	xtransaction xtrans;         // handle to our child class
	int no_transaction = 10;     // defined n number of transactions

	initial begin
		// initialization/instantiations
		env = new(vif, no_transaction);
		xtrans = new();
		env.gen.blueprint =xtrans;   
		// calling the run method of the environment class
		env.run();
	end

endprogram
