//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        transaction.sv												    //
//                                                                          //
// Description:                                                             //
//           Fields required to generate the stimulus                       //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
class transaction;

	rand  bit [31:0]    haddr;
	rand  bit [1:0]     htrans;
	rand  bit [2:0]     hsize;
	randc bit [2:0]     hburst;
    randc bit [3:0]     hprot;
    randc bit [31:0]    hwdata;
    randc bit	        error;
	rand  bit           hsel;
	
	randc bit           hwrite;
		  bit [31:0]    hrdata;
     	  bit           hready;
    	  bit 			hresp;
	
	// Method for implementing blueprint pattern
	virtual function transaction copy;
		copy = new;
		copy.haddr=haddr;
		copy.htrans=htrans;
		copy.hwrite=hwrite;
		copy.hsize=hsize;
		copy.hburst=hburst;
		copy.hprot=hprot;
	    copy.hwdata=hwdata;
		copy.hrdata=hrdata;
		copy.hready=hready;
		copy.hresp=hresp;
		copy.error=error;
		copy.hsel=hsel;
	endfunction
	
	 // To select the slave memory hsel needs to be 1
	constraint constraint_hsel{ hsel == 1;}           
	
	// As per  instructions we are only considering single burst transactions
	constraint constraint_hburst {hburst==0;}                  
	
	// Transfer sizes of byte, half word and word only
	constraint constraint_hsize{ hsize inside{[0:2]};}   
	      
	// Protection control for data access only
	constraint constraint_hprot{ hprot == 1;}                  
	 
	
	// Transfer types i.e. IDLE, BUSY and NONSEQ
	constraint constraint_htrans{ htrans dist{2'b00:/10 , 2'b01:/10, 2'b10:/80};}
	
	constraint constraint_haddr{if (hsize == 1) haddr[1:0] == 0;  // address alignment to halfword boundary
								if (hsize ==2) haddr[0] == 0;     // address alignment to word boundary
								haddr inside {[0:1023]};          // The size of the slave memory is smaller
								solve hsize before haddr;}    

	// Error constraint for basic transaction								                              
	constraint constraint_error{error==0;}

	function void print_trans();
		$display("--------------------------");	
		$display("My transaction packet:");
		$display("--------------------------");	
		$display("| haddr : 32'h%0h", haddr);
		$display("| htrans: 2'b%0b", htrans);
		$display("| hwrite: 1'b%0b", hwrite);
	 	$display("| hsize : 3'b%0b", hsize);
		$display("| hburst: 3'b%0b", hburst);
     	$display("| hprot : 4'b%0b", hprot);
     	$display("| hwdata : 32'h%0h", hwdata);
     	$display("| error : 1'b%0b", error);
		$display("| hrdata: 32'h%0h", hrdata);
     	$display("| hready: 1'b%0b", hready);
    	$display("| hresp : 1'b%0b", hresp);
	 	$display("| hsel  : 1'b%0b",hsel);
		$display("--------------------------");	
		
	endfunction
endclass
