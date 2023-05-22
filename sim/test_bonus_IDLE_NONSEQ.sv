//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        test_bonus_IDLE_NONSEQ.sv   											    //
//                                                                          //
// Description:                                                             //
//          Add a test case for alternate read/write transactions using     //
//          the pre_randomize method.                                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
program automatic test_bonus_IDLE_NONSEQ(dut_interface vif);
	bit ctrl_rw;   // control bit used to switch between read and write transfers
	
	// child class to our transaction class
	class xtransaction extends transaction;
		
		// The method called before randomization
		function void pre_randomize();
			htrans.rand_mode(0);
			hwrite.rand_mode(0);
			hwrite = 1;
			
			
			if (ctrl_rw == 0) begin
				// Do a IDLE transfer
				htrans = 0;
				haddr = 32'h10;  // Address A
			
			end
			else begin
				// Do a NONSEQ transfer
				htrans = 2;
				haddr = 32'h20; // Address B
			
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
