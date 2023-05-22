//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//       generator.sv													    //
//                                                                          //
// Description:                                                             //
//             Generates different input stimulus to be driven to DUT       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
class generator;

	transaction blueprint;           // handle of transaction class
	mailbox #(transaction) gen2drv;  // mailbox to send data from generator to driver
	int no_transaction;              // variable defines max amount transactions
	event doneGen;                   // event to signal that generator has done its job

	// constructor of the class for intitialization 
	function new(mailbox #(transaction) gen2drv, event doneGen, int no_transaction);
		this.gen2drv = gen2drv;
		this.doneGen = doneGen;
		blueprint = new();                   
		this.no_transaction=no_transaction;
	endfunction


	task main();
		for(int i=0; i< no_transaction; i++)begin
			// generate error if randomization fails
			if (!(blueprint.randomize())) $fatal("Generator: randomization error");
			gen2drv.put(blueprint.copy);   
		end
		$display("Generator: all packets sent to driver");
		->doneGen;     // triggering that generator has done it's job
	endtask
endclass

