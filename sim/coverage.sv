//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Name:                                                                   //
//        coverage.sv                                                       //
//                                                                          //
// Description:                                                             //
//          Checks the coverage                                             //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

class coverage;
  transaction trans;
  bit sel_cov;

  covergroup combinational_coverage;
    option.per_instance = 1;
    option.name = "combinational";
    select: coverpoint trans.hsel {
      bins 			on = {1};
    }
    addr:	coverpoint trans.haddr {
      bins 			addr[10]= {[0:(2**10)-1]};
    }
    transf: coverpoint trans.htrans {
      bins			transf[] = {`H_IDLE, `H_BUSY, `H_NONSEQ};
    }
    write:	coverpoint trans.hwrite;
    size:	coverpoint trans.hsize {
      bins			size[] = {`H_SIZE_8,`H_SIZE_16,`H_SIZE_32};
    }
    burst:	coverpoint trans.hburst {
      bins			burst[]={`H_SINGLE};
    }
    prot:	coverpoint trans.hprot {
      bins			prot[]= {1};}

   	tresp:	coverpoint trans.hresp;
    tready: coverpoint trans.hready;
    all_cross: cross select,addr,transf,write,size,burst,prot,tresp,tready;
  endgroup

  covergroup transition_coverage;
  	option.per_instance = 1;
    option.name = "transitional";
  endgroup
  
  function new(input bit sel_cov=0);
    this.sel_cov = sel_cov;
    if(sel_cov) transition_coverage = new();
    combinational_coverage = new();      
  endfunction : new

  task sample(transaction trans);
	this.trans = trans;
    if(sel_cov) transition_coverage.sample();
    combinational_coverage.sample();
  endtask:sample

endclass
