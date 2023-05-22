//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        scoreboard.sv													    //
//                                                                          //
// Description:                                                             //
//          Checks output from the design with expected behavior            //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
`include "coverage.sv"
class scoreboard;
  	coverage cg;                      // handle to our coverage
  	transaction trans;                // handle to the transaction class
  	mailbox #(transaction) mon2scor;  // mailbox to receive data from the monitor
  	int no_transaction;               // max amount of transctions
	int local_count =0;               // local count to track how many transactions have been completed
	int idle_count=0;                 // to keep track of our IDLE transactions
	int busy_count=0;                 // to keep track of our BUSY transactions

	bit [7:0] mem[0:1023];            // emulating a memory in scoreboard, similar to slave
	
	// The new constructor for intialization
	function new(mailbox #(transaction) mon2scor, int no_transaction);
    	this.mon2scor = mon2scor;
		this.no_transaction=no_transaction;
		// slave device initializes some chunks of memory as per below logic
		for (int i = 0; i< 256; i++) mem[i] = i;
	endfunction

task main();
	trans = new();
	cg = new();
		while(local_count < no_transaction) begin
			// fetching data from the mailbox
			mon2scor.get(trans);
			
			// We want to make sure that our slave device is connected
			if(trans.hsel==1)begin	
				
				// checking if our transfer was IDLE or not
				if(trans.htrans== 0) begin
					// an IDLE transfer does nothing so I just printed some things to verify 
            		idle_count++; 
            	
					if(trans.hresp == 0) $display("[ScoreBoard]| Slave response is OKAY to an IDLE trans: LEGAL\n");
            		else $display("[ScoreBoard]| Slave response is ERROR to an IDLE trans: ILLEGAL\n");
          		
				end
          
         		// checking if our transfer was BUSY or not
		  		else if(trans.htrans== 1) begin 
            		// an IDLE transfer does nothing so I just printed some things to verify 
            		busy_count++;
					if(trans.hresp== 0) $display("[ScoreBoard]| Slave response is OKAY to an BUSY trans: LEGAL\n");
					else $display("[ScoreBoard]| Slave response is ERROR to an BUSY trans: ILLEGAL\n");
				end
				
				// checking if our transfer was NONSEQ or not
				else if (trans.htrans == 2)begin
				
					// Checking if we have a write transfer
					if( trans.hwrite==1) begin
						$display("[ScoreBoard]| write operaton-> hszie:%0h haddr:%0h hwdata:%0h\n", trans.hsize, trans.haddr, trans.hwdata);
						
						// write operation for byte
						if(trans.hsize == 0) begin
							mem[trans.haddr] = trans.hwdata;
						end
						
						// write operation for halfword
						else if (trans.hsize == 1) begin
							mem[trans.haddr] = trans.hwdata[7:0];
							mem[trans.haddr + 1] = trans.hwdata[15:8];
						end
						
						// write operation for word
						else if (trans.hsize == 2) begin
							mem[trans.haddr] = trans.hwdata[7:0];
							mem[trans.haddr + 1] = trans.hwdata[15:8];
							mem[trans.haddr + 2] = trans.hwdata[23:16];
							mem[trans.haddr + 3] = trans.hwdata[31:24];
						end
						
					end
				
					// this for read transfer	
					else if (trans.hwrite==0) begin
					
						$write("[ScoreBoard]| read operation-> ");
						
						// read operation for byte						
						if (trans.hsize == 0)begin
						
							if (trans.haddr[1:0] == 0)begin
								if (trans.hrdata[7:0] == mem[trans.haddr]) 
									print_byte_result(trans, 1);  // print that result passed
						 		else 
						 			print_byte_result(trans, 0); // print that result failed
							end

							if(trans.haddr[1:0]==1) begin
								if (trans.hrdata[15:8] == mem[trans.haddr]) 
									print_byte_result(trans, 1);  // print that result passed
						 		else 
						 			print_byte_result(trans, 0); // print that result failed
							end

							if(trans.haddr[1:0]==2) begin
								if (trans.hrdata[23:16] == mem[trans.haddr]) 
									print_byte_result(trans, 1);  // print that result passed
								else 
									print_byte_result(trans, 0); // print that result failed
							end

							if(trans.haddr[1:0]==3) begin
								if (trans.hrdata[31:24] == mem[trans.haddr]) 
									print_byte_result(trans, 1);  // print that result passed
						 		else
						 			 print_byte_result(trans, 0); // print that result failed
							end
					
						end

						// read operation for halfword
						if (trans.hsize == 1)begin
						
							if(trans.haddr[0] == 0) begin
						 		if (trans.hrdata[15:0] == {mem[trans.haddr+1], mem[trans.haddr]}) 
						 			print_halfword_result(trans, 1); // print that result passed
						 		else 
						 			print_halfword_result(trans, 0);  // print that result failed
							end
						
						 	if(trans.haddr[0] == 1) begin
						 		if (trans.hrdata[31:16] == {mem[trans.haddr+1], mem[trans.haddr]}) 
						 			print_halfword_result(trans, 1); // print that result passed
						 		else 
						 			print_halfword_result(trans, 0);  // print that result failed
							end
						end
					
						// read operation for word
						if (trans.hsize ==2)begin
							if (trans.hrdata == {mem[trans.haddr+3], mem[trans.haddr+2], mem[trans.haddr+1], mem[trans.haddr]}) 
								print_word_result(trans, 1);  // print that result passed
							else 
								print_word_result(trans, 0); // print that result failed
						end

					end
				end
			end
			
			// we also wish to log when slave was not connected
			else $display("Slave not connected yet");
			cg.sample(trans);
			local_count++;
		end
endtask

	// function to print whether whether our word transfer was successful or not
	function void print_word_result(transaction trans, int result);
		$write("hsize:%0h ", trans.hsize);
		$write("rdata:%0h ",trans.hrdata);
		$write("mem[%0h]:%0h mem[%0h]:%0h ",(trans.haddr+3), mem[trans.haddr+3], trans.haddr+2, mem[trans.haddr+2]);
		$write("mem[%0h]:%0h mem[%0h]:%0h ",(trans.haddr+1), mem[trans.haddr+1], trans.haddr, mem[trans.haddr]);
		if(result == 1) $display("[TEST PASSED]\n");
		else $display("TEST FAILED\n");


	endfunction
	
	// function to print whether whether our byte transfer was successful or not
	function void print_byte_result(transaction trans, int result);
		$write("hsize:%0h ", trans.hsize);
		if (trans.haddr[1:0]==2'b00) $write("rdata:%0h ",trans.hrdata[7:0]);
		if (trans.haddr[1:0]==2'b01) $write("rdata:%0h ",trans.hrdata[15:8]);
		if (trans.haddr[1:0]==2'b10) $write("rdata:%0h ",trans.hrdata[23:16]);
		if (trans.haddr[1:0]==2'b11) $write("rdata:%0h ",trans.hrdata[31:24]);
 		$write("mem[%0h]:%0h ", trans.haddr, mem[trans.haddr]);
		if(result == 1) $display("[TEST PASSED]\n");
		else $display("[TEST FAILED]\n");

	endfunction

	// function to print whether whether our halfword transfer was successful or not		
	function void print_halfword_result(transaction trans, int result);
		$write("hsize:%0h ", trans.hsize);
		$write("hrdata:%0h ", trans.hrdata);
		$write("mem[%0h]:%0h mem[%0h]:%0h ",(trans.haddr+1), mem[trans.haddr+1], trans.haddr, mem[trans.haddr]);
		if(result == 1) $display("[TEST PASSED]\n");
		else $display("[TEST FAILED]\n");
	endfunction

endclass

