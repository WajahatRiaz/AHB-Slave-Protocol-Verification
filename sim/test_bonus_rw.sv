//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_rw.sv   											    //
//                                                                          //
// Description:                                                             //
//          Add a test case for alternate read/write transactions using     //
//          the pre_randomize method.                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_rw(dut_interface vif);
	bit ctrl_rw;   // control bit used to switch between read and write transfers
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();
			haddr.rand_mode(0);
			hwrite.rand_mode(0);
			haddr = 32'h10; // Fixing the address
			
			if (ctrl_rw == 0) begin
				// Do a read transfer
				hwrite = 0;
			end
			else begin
				// Do a write transfer
				hwrite = 1;
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
