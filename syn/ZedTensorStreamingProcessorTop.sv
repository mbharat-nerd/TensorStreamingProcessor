/*
 Top level instance for Tensor Streaming Processor (TSP) on a Zedboard
 
 TSP design was inspired by Groq's 2020 paper:  "Think Fast: A Tensor Streaming
 Processor (TSP) for Accelerating Deep Learning Networks".
  
 
 Bharathwaj Muthuswamy
 bharathwaj.muthuswamy@gmail.com
*/

module ZedTensorStreamingProcessorTop (
	input logic GCLK, // 100 MHz
	input logic BTNC, // active high, for global reset
	output logic LD7,
	output logic LD6,
	output logic LD5,
	output logic LD4,
	output logic LD3,
	output logic LD2,
	output logic LD1,
	output logic LD0);
/*	inout logic [14:0] DDR_addr,
    inout logic [2:0] DDR_ba,
    inout logic DDR_cas_n,
    inout logic DDR_ck_n,
    inout logic DDR_ck_p,
    inout logic DDR_cke,
    inout logic DDR_cs_n,
    inout logic [3:0] DDR_dm,
    inout logic [31:0] DDR_dq,
    inout logic [3:0] DDR_dqs_n,
    inout logic [3:0] DDR_dqs_p,
    inout logic DDR_odt,
    inout logic DDR_ras_n,
    inout logic DDR_reset_n,
    inout logic DDR_we_n,
    inout logic FIXED_IO_ddr_vrn,
    inout logic FIXED_IO_ddr_vrp,
    inout logic [53:0] FIXED_IO_mio,
    inout logic FIXED_IO_ps_clk,
    inout logic FIXED_IO_ps_porb,
    inout logic FIXED_IO_ps_srstb*/
	
	timeunit 1ps;
	timeprecision 1ps;
	
	logic [31:0] instruction_out;
	logic clk, locked;
	
	// TODO:  The ARM core will load code to be executed onto the TSP memory
	// Will be instantiated once TSP subsystem has been tested
	/*design_TSP_wrapper
	   ARM_inst
	   (.*,
	   .reset_rtl(BTNC),
	   .sys_clock(GCLK));
	*/
	
	// PLL clock buffer(s)
	clk_wiz_0 clk_inst 
	       (.clk_out1(clk),  
            .reset(1'b0),
            .locked(locked), 
            .clk_in1(GCLK)); 
    		
	// Classic 2-stage reset synchronizer
	// Need this because BTNC is an asychronous signal coming into FPGA
	logic rst, sync_ff1;	
	always @(posedge GCLK) begin	   
	   sync_ff1 <= BTNC | ~locked;
	   rst <= sync_ff1;
	end
	
	TensorStreamingProcessor
	   TSP_instance 
	       (.*);
	
	// Good practice to always register outputs
	always_ff @(posedge clk) begin
	   {LD7,LD6,LD5,LD4,LD3,LD2,LD1,LD0} <= instruction_out[7:0];
	end	

	
endmodule : ZedTensorStreamingProcessorTop

