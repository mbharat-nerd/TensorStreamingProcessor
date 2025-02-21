// The *proper* way to design an asynchronous FIFO, using Gray code counters so
// clock domain transitions are correct between the write and read clock domains

// Reference:  Clifford Cummings' Async FIFO notes (eloquently explained by Gisselquist)

module async_fifo
    #(parameter DSIZE = 2,
      parameter ASIZE = 4)
    (input logic i_wclk, 
     input logic i_wrst, 
     input logic i_wr,
     input logic [DSIZE-1:0] i_wdata,
     output logic o_wfull,
     input logic i_rclk,
     input logic i_rrst,
     input logic i_rd,
     output logic [DSIZE-1:0] o_rdata,
     output logic o_rempty);
     

    wire [ASIZE-1:0] waddr, raddr;
    wire wfull_next, rempty_next;
    // Counters - gray and regular
    logic [ASIZE:0] wgray, wbin, wq2_rgray, wq1_rgray;
    logic [ASIZE:0] rgray, rbin, rq2_wgray, rq1_wgray;
    
    wire [ASIZE:0] wgraynext, wbinnext;
    wire [ASIZE:0] rgraynext, rbinnext;
    
    logic [DSIZE-1:0] mem [0:((1<<ASIZE)-1)];
    
    // Cross clock domains
    // Read Gray pointer into write clock domain
    always_ff @(posedge i_wclk) begin
        if (i_wrst) 
            { wq2_rgray, wq1_rgray } <= '0;             
        else 
            { wq2_rgray, wq1_rgray } <= { wq1_rgray, rgray };        
    end
    
    // Write Gray pointer into read clock domain
    always_ff @(posedge i_rclk) begin
        if (i_rrst) begin
            { rq2_wgray, rq1_wgray } <= '0;
        end
        else begin
            { rq2_wgray, rq1_wgray } <= { rq1_wgray, wgray };
        end            
    end
    
    
    // Calculate the next write address, and the next graycode pointer.
    assign    wbinnext  = wbin + { {(ASIZE){1'b0}}, ((i_wr) && (!o_wfull)) };
    assign    wgraynext = (wbinnext >> 1) ^ wbinnext;
   
    assign	waddr = wbin[ASIZE-1:0];
   
    // Register these two values--the address and its Gray code
    // representation
    initial    { wbin, wgray } = 0;
    always_ff @(posedge i_wclk) begin
       if (i_wrst)
           { wbin, wgray } <= 0;
       else
           { wbin, wgray } <= { wbinnext, wgraynext };
    end           
   
    assign  wfull_next = (wgraynext == { ~wq2_rgray[ASIZE:ASIZE-1],wq2_rgray[ASIZE-2:0] });
    
    // Calculate whether or not the register will be full on the next clock.
    initial    o_wfull = 0;
    always_ff @(posedge i_wclk) begin
        if (i_wrst)
            o_wfull <= 1'b0;
        else
            o_wfull <= wfull_next;
    end            
            
    // Write to the FIFO on a clock
    always_ff @(posedge i_wclk) begin
        if ((i_wr)&&(!o_wfull))
            mem[waddr] <= i_wdata;
    end
      
    // Calculate the next read address,
	assign	rbinnext  = rbin + { {(ASIZE){1'b0}}, ((i_rd)&&(!o_rempty)) };
	// and the next Gray code version associated with it
	assign	rgraynext = (rbinnext >> 1) ^ rbinnext;

	// Register these two values, the read address and the Gray code version
	// of it, on the next read clock
	//
	initial	{ rbin, rgray } = 0;
	always_ff @(posedge i_rclk) begin
	   if (i_rrst)
		  { rbin, rgray } <= 0;
	   else
		  { rbin, rgray } <= { rbinnext, rgraynext };
    end		  

	// Memory read address Gray code and pointer calculation
	assign	raddr = rbin[ASIZE-1:0];
    
    // Determine if we'll be empty on the next clock
	assign	rempty_next = (rgraynext == rq2_wgray);

	initial o_rempty = 1;
	always_ff @(posedge i_rclk) begin
	   if (i_rrst)
	       o_rempty <= 1'b1;
	   else
	       o_rempty <= rempty_next;
    end
	//
	// Read from the memory--a clockless read here, clocked by the next
	// read FLOP in the next processing stage (somewhere else)
	//
	assign	o_rdata = mem[raddr];


endmodule: async_fifo
     