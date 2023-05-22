//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_no_data_acces.sv   										    //
//                                                                          //
// Description:                                                             //
//          Test case if salve is disconnected during transactions          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_no_data_acces(dut_interface vif);
	bit [3:0] ctrl_rw;   // control bit used to switch between read and write transfers
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();
			constraint_hprot.constraint_mode(0);  // turning off the constraint to hprot
			hprot.rand_mode(0);  // turning off randomization for hprot
			
			if (ctrl_rw == 0) begin
				hprot = 2;
			end
			
			else if (ctrl_rw == 1) begin
			
				hprot = 1;
			end
			
			else if (ctrl_rw == 2) begin
				// Disconnecting slave 
				hprot = 4;
			end
			
			else begin
				
				hprot = 1;
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
